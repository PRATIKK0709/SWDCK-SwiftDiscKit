import Foundation

enum GatewayState {
    case disconnected
    case connecting
    case connected
    case resuming
    case disconnecting
}

actor GatewayClient {

    private let token: String
    private let intents: GatewayIntents

    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession
    private var state: GatewayState = .disconnected
    private let heartbeat = HeartbeatManager()

    private var sessionId: String?
    private var resumeGatewayURL: String?
    private var lastSequence: Int?
    private var reconnectAttempts = 0
    private let maxReconnectDelay: Double = 60
    private static let defaultGatewayURL = "wss://gateway.discord.gg/?v=10&encoding=json"

    private var onDispatch: (@Sendable (String, RawJSON) async -> Void)?
    private var onReady: (@Sendable (ReadyData) async -> Void)?

    init(token: String, intents: GatewayIntents) {
        self.token = token
        self.intents = intents
        self.session = URLSession(configuration: .default)
    }

    func setEventHandlers(
        onReady: @escaping @Sendable (ReadyData) async -> Void,
        onDispatch: @escaping @Sendable (String, RawJSON) async -> Void
    ) {
        self.onReady = onReady
        self.onDispatch = onDispatch
    }


    private var initialGatewayURL: String?

    func connect(with gatewayURL: String) async throws {
        state = .connecting
        reconnectAttempts = 0
        initialGatewayURL = gatewayURL
        try await openWebSocket(to: gatewayURL)
    }

    func disconnect() async {
        state = .disconnecting
        await heartbeat.stop()
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        state = .disconnected
    }

    func updatePresence(_ update: DiscordPresenceUpdate) async throws {
        guard state == .connected || state == .resuming else {
            throw DiscordError.gatewayDisconnected(code: nil, reason: "Cannot update presence before the gateway is connected.")
        }
        let payload = PresenceUpdatePayload(d: update)
        try await sendJSONThrowing(payload)
        logger.info("Updated bot presence to \(update.status.rawValue)")
    }


    private func openWebSocket(to urlString: String) async throws {
        guard let url = URL(string: urlString) else {
            throw DiscordError.connectionFailed(reason: "Invalid gateway URL: \(urlString)")
        }

        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        state = .connected

        logger.info("Gateway WebSocket opened to \(urlString)")

        await startReceiveLoop()
    }

    private func startReceiveLoop() async {
        while state == .connected || state == .resuming {
            do {
                guard let task = webSocketTask else { break }
                let message = try await task.receive()

                switch message {
                case .string(let text):
                    await handleRawMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        await handleRawMessage(text)
                    }
                @unknown default:
                    break
                }
            } catch {
                if state == .disconnecting { break }
                logger.error("Gateway receive error: \(error)")
                await handleDisconnect(error: error)
                break
            }
        }
    }


    private func handleRawMessage(_ text: String) async {
        guard let data = text.data(using: .utf8) else { return }

        let payload: GatewayPayload
        do {
            payload = try JSONCoder.decode(GatewayPayload.self, from: data)
        } catch {
            logger.error("Failed to decode gateway payload: \(error)")
            return
        }

        if let seq = payload.s { lastSequence = seq }

        guard let opcode = GatewayOpcode(rawValue: payload.op) else {
            logger.warning("Unknown opcode: \(payload.op)")
            return
        }

        switch opcode {
        case .hello:
            await handleHello(payload)

        case .dispatch:
            await handleDispatch(payload)

        case .heartbeatACK:
            await heartbeat.didReceiveACK()

        case .heartbeat:
            await sendHeartbeat()

        case .reconnect:
            logger.info("Gateway requested reconnect")
            await scheduleReconnect(canResume: true)

        case .invalidSession:
            let canResume = (try? payload.d?.decode(Bool.self)) ?? false
            logger.warning("Invalid session, canResume: \(canResume)")
            await scheduleReconnect(canResume: canResume)

        default:
            logger.debug("Unhandled opcode: \(opcode)")
        }
    }

    private func handleHello(_ payload: GatewayPayload) async {
        guard let helloData = try? payload.d?.decode(HelloData.self) else {
            logger.error("Failed to decode HELLO payload")
            return
        }

        logger.info("Gateway HELLO received. Heartbeat interval: \(helloData.heartbeatInterval)ms")

        await heartbeat.start(
            intervalMs: helloData.heartbeatInterval,
            sequenceProvider: { [weak self] in
                await self?.lastSequence
            },
            onHeartbeat: { [weak self] _ in
                await self?.sendHeartbeat()
            },
            onZombieDetected: { [weak self] in
                await self?.scheduleReconnect(canResume: true)
            }
        )

        if let sessionId, let _ = resumeGatewayURL, let seq = lastSequence {
            logger.info("Sending RESUME for session \(sessionId)")
            state = .resuming
            await sendResume(sessionId: sessionId, seq: seq)
        } else {
            logger.info("Sending IDENTIFY")
            await sendIdentify()
        }
    }

    private func handleDispatch(_ payload: GatewayPayload) async {
        guard let eventName = payload.t else { return }
        guard let data = payload.d else { return }

        logger.debug("Dispatch event: \(eventName)")

        if eventName == "READY" {
            if let ready = try? data.decode(ReadyData.self) {
                sessionId = ready.sessionId
                resumeGatewayURL = ready.resumeGatewayUrl
                reconnectAttempts = 0
                state = .connected
                logger.info("Bot ready! Logged in as \(ready.user.tag)")
                await onReady?(ready)
            }
            return
        }

        if eventName == "RESUMED" {
            state = .connected
            reconnectAttempts = 0
            logger.info("Session successfully resumed")
            return
        }

        await onDispatch?(eventName, data)
    }

    private func handleDisconnect(error: Error?) async {
        guard state != .disconnecting else { return }
        logger.warning("Gateway disconnected: \(error?.localizedDescription ?? "unknown")")
        await scheduleReconnect(canResume: true)
    }


    private func scheduleReconnect(canResume: Bool) async {
        if !canResume {
            sessionId = nil
            resumeGatewayURL = nil
            lastSequence = nil
        }

        await heartbeat.stop()
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        state = .disconnected

        reconnectAttempts += 1
        let delay = min(pow(2.0, Double(reconnectAttempts - 1)), maxReconnectDelay)
        logger.info("Reconnecting in \(delay)s (attempt \(reconnectAttempts))")
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

        do {
            let url = Self.resolvedReconnectURL(
                canResume: canResume,
                resumeGatewayURL: resumeGatewayURL,
                initialGatewayURL: initialGatewayURL
            )
            state = .connecting
            try await openWebSocket(to: url)
        } catch {
            logger.error("Reconnect failed: \(error)")
            await scheduleReconnect(canResume: false)
        }
    }

    static func resolvedReconnectURL(
        canResume: Bool,
        resumeGatewayURL: String?,
        initialGatewayURL: String?
    ) -> String {
        (canResume ? resumeGatewayURL : nil) ?? initialGatewayURL ?? defaultGatewayURL
    }


    private func sendHeartbeat() async {
        let payload = HeartbeatPayload(d: lastSequence)
        await sendJSON(payload)
    }

    private func sendIdentify() async {
        let payload = IdentifyPayload(d: .init(
            token: token,
            intents: intents.rawValue,
            properties: .init(os: "linux", browser: "SWDCK", device: "SWDCK")
        ))
        await sendJSON(payload)
    }

    private func sendResume(sessionId: String, seq: Int) async {
        let payload = ResumePayload(d: .init(
            token: token,
            sessionId: sessionId,
            seq: seq
        ))
        await sendJSON(payload)
    }

    private func sendJSON<T: Encodable>(_ value: T) async {
        do {
            try await sendJSONThrowing(value)
        } catch {
            logger.error("Failed to send gateway payload: \(error)")
        }
    }

    private func sendJSONThrowing<T: Encodable>(_ value: T) async throws {
        let data = try JSONCoder.encode(value)
        let text = String(data: data, encoding: .utf8) ?? ""
        guard let task = webSocketTask else {
            throw DiscordError.gatewayDisconnected(code: nil, reason: "Gateway websocket is not available.")
        }
        try await task.send(.string(text))
    }
}
