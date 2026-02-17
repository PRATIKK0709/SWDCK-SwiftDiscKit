import Foundation

public final class RESTClient: Sendable {

    private let token: String
    private let session: URLSession
    private let rateLimiter: RateLimiter
    private let maxRetries = 3

    init(token: String) {
        self.token = token
        self.rateLimiter = RateLimiter()
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "User-Agent": "DiscordBot (DiscordKit, 1.0.0)"
        ]
        self.session = URLSession(configuration: config)
    }


    @discardableResult
    func request<T: Decodable>(
        method: String,
        url: String,
        body: Encodable? = nil,
        decodeAs type: T.Type
    ) async throws -> T {
        let data = try await rawRequest(method: method, url: url, body: body)
        return try JSONCoder.decode(type, from: data)
    }

    func requestVoid(method: String, url: String, body: Encodable? = nil) async throws {
        _ = try await rawRequest(method: method, url: url, body: body)
    }

    private func rawRequest(
        method: String,
        url urlString: String,
        body: Encodable?
    ) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw DiscordError.connectionFailed(reason: "Invalid URL: \(urlString)")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bot \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body {
            request.httpBody = try JSONCoder.encode(body)
        }

        let routeKey = "\(method):\(url.path)"

        for attempt in 1...maxRetries {
            await rateLimiter.waitIfNeeded(for: routeKey)

            let (data, response): (Data, URLResponse)
            do {
                (data, response) = try await session.data(for: request)
            } catch {
                if attempt < maxRetries {
                    try? await Task.sleep(nanoseconds: UInt64(attempt) * 1_000_000_000)
                    continue
                }
                throw DiscordError.connectionFailed(reason: error.localizedDescription)
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                throw DiscordError.connectionFailed(reason: "Non-HTTP response")
            }

            await rateLimiter.update(route: routeKey, headers: httpResponse.allHeaderFields)

            switch httpResponse.statusCode {
            case 200...299:
                logger.debug("✓ \(method) \(urlString) → \(httpResponse.statusCode)")
                return data

            case 401:
                throw DiscordError.invalidToken

            case 429:
                let retryResponse = try? JSONCoder.decode(RateLimitResponse.self, from: data)
                let retryAfter = retryResponse?.retryAfter
                    ?? headerDouble("Retry-After", from: httpResponse.allHeaderFields)
                    ?? 1.0
                let isGlobal = retryResponse?.global
                    ?? headerBool("X-RateLimit-Global", from: httpResponse.allHeaderFields)
                    ?? false

                if isGlobal {
                    await rateLimiter.handleGlobalRateLimit(retryAfter: retryAfter)
                } else {
                    try? await Task.sleep(nanoseconds: UInt64(retryAfter * 1_000_000_000))
                }

                if attempt < maxRetries { continue }
                throw DiscordError.rateLimited(retryAfter: retryAfter)

            case 400...499:
                let bodyStr = String(data: data, encoding: .utf8) ?? "<binary>"
                logger.error("HTTP \(httpResponse.statusCode) for \(method) \(urlString): \(bodyStr)")
                throw DiscordError.httpError(statusCode: httpResponse.statusCode, body: bodyStr)

            case 500...599:
                logger.warning("Server error \(httpResponse.statusCode), attempt \(attempt)/\(maxRetries)")
                if attempt < maxRetries {
                    try? await Task.sleep(nanoseconds: 1_000_000_000 * UInt64(attempt))
                    continue
                }
                let bodyStr = String(data: data, encoding: .utf8) ?? "<binary>"
                throw DiscordError.httpError(statusCode: httpResponse.statusCode, body: bodyStr)

            default:
                let bodyStr = String(data: data, encoding: .utf8) ?? "<binary>"
                throw DiscordError.httpError(statusCode: httpResponse.statusCode, body: bodyStr)
            }
        }

        throw DiscordError.connectionFailed(reason: "Max retries exceeded for \(method) \(urlString)")
    }


    func getCurrentUser() async throws -> DiscordUser {
        try await request(method: "GET", url: Routes.currentUser, decodeAs: DiscordUser.self)
    }


    func getChannel(channelId: String) async throws -> Channel {
        try await request(method: "GET", url: Routes.channel(channelId), decodeAs: Channel.self)
    }


    @discardableResult
    func sendMessage(
        channelId: String,
        content: String,
        messageReference: MessageReference? = nil
    ) async throws -> Message {
        let body = SendMessageBody(content: content, messageReference: messageReference)
        var msg = try await request(method: "POST", url: Routes.messages(channelId), body: body, decodeAs: Message.self)
        msg._rest = self
        return msg
    }

    @discardableResult
    func sendComponentsV2Message(
        channelId: String,
        components: [ComponentV2Node],
        messageReference: MessageReference? = nil
    ) async throws -> Message {
        let body = SendComponentsV2MessageBody(
            flags: DiscordMessageFlags.isComponentsV2,
            components: components,
            messageReference: messageReference,
            attachments: nil
        )
        var msg = try await request(
            method: "POST",
            url: Routes.messages(channelId),
            body: body,
            decodeAs: Message.self
        )
        msg._rest = self
        return msg
    }

    @discardableResult
    func sendComponentsV2Message(
        channelId: String,
        components: [ComponentV2Node],
        attachments: [DiscordFileUpload],
        messageReference: MessageReference? = nil
    ) async throws -> Message {
        guard let url = URL(string: Routes.messages(channelId)) else {
            throw DiscordError.connectionFailed(reason: "Invalid URL: \(Routes.messages(channelId))")
        }

        let attachmentMetadata = attachments.enumerated().map { index, file in
            UploadAttachmentMetadata(id: index, filename: file.filename, description: file.description)
        }

        let payload = SendComponentsV2MessageBody(
            flags: DiscordMessageFlags.isComponentsV2,
            components: components,
            messageReference: messageReference,
            attachments: attachmentMetadata
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bot \(token)", forHTTPHeaderField: "Authorization")

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = try buildMultipartBody(
            boundary: boundary,
            payload: payload,
            attachments: attachments
        )

        let routeKey = "POST:\(url.path)"

        for attempt in 1...maxRetries {
            await rateLimiter.waitIfNeeded(for: routeKey)

            let (data, response): (Data, URLResponse)
            do {
                (data, response) = try await session.data(for: request)
            } catch {
                if attempt < maxRetries {
                    try? await Task.sleep(nanoseconds: UInt64(attempt) * 1_000_000_000)
                    continue
                }
                throw DiscordError.connectionFailed(reason: error.localizedDescription)
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                throw DiscordError.connectionFailed(reason: "Non-HTTP response")
            }

            await rateLimiter.update(route: routeKey, headers: httpResponse.allHeaderFields)

            switch httpResponse.statusCode {
            case 200...299:
                var message = try JSONCoder.decode(Message.self, from: data)
                message._rest = self
                return message
            case 401:
                throw DiscordError.invalidToken
            case 429:
                let retryAfter = headerDouble("Retry-After", from: httpResponse.allHeaderFields) ?? 1.0
                try? await Task.sleep(nanoseconds: UInt64(retryAfter * 1_000_000_000))
                if attempt < maxRetries { continue }
                throw DiscordError.rateLimited(retryAfter: retryAfter)
            default:
                let body = String(data: data, encoding: .utf8) ?? "<binary>"
                throw DiscordError.httpError(statusCode: httpResponse.statusCode, body: body)
            }
        }

        throw DiscordError.connectionFailed(reason: "Max retries exceeded for multipart request")
    }

    func deleteMessage(channelId: String, messageId: String) async throws {
        try await requestVoid(method: "DELETE", url: Routes.message(channelId, messageId: messageId))
    }


    func getApplicationId() async throws -> String {
        let user = try await getCurrentUser()
        return user.id
    }

    @discardableResult
    func createGlobalCommand(
        applicationId: String,
        command: SlashCommandDefinition
    ) async throws -> ApplicationCommand {
        try await request(
            method: "POST",
            url: Routes.globalCommands(applicationId),
            body: command,
            decodeAs: ApplicationCommand.self
        )
    }

    func bulkOverwriteGlobalCommands(
        applicationId: String,
        commands: [SlashCommandDefinition]
    ) async throws -> [ApplicationCommand] {
        try await request(
            method: "PUT",
            url: Routes.globalCommands(applicationId),
            body: commands,
            decodeAs: [ApplicationCommand].self
        )
    }

    func createGuildCommand(
        applicationId: String,
        guildId: String,
        command: SlashCommandDefinition
    ) async throws -> ApplicationCommand {
        try await request(
            method: "POST",
            url: Routes.guildCommands(applicationId, guildId: guildId),
            body: command,
            decodeAs: ApplicationCommand.self
        )
    }

    func bulkOverwriteGuildCommands(
        applicationId: String,
        guildId: String,
        commands: [SlashCommandDefinition]
    ) async throws -> [ApplicationCommand] {
        try await request(
            method: "PUT",
            url: Routes.guildCommands(applicationId, guildId: guildId),
            body: commands,
            decodeAs: [ApplicationCommand].self
        )
    }

    @discardableResult
    func createSlashCommand(
        applicationId: String,
        command: SlashCommandDefinition,
        guildId: String? = nil
    ) async throws -> ApplicationCommand {
        if let guildId {
            return try await createGuildCommand(
                applicationId: applicationId,
                guildId: guildId,
                command: command
            )
        }
        return try await createGlobalCommand(
            applicationId: applicationId,
            command: command
        )
    }


    func createInteractionResponse(
        interactionId: String,
        token: String,
        response: InteractionResponse
    ) async throws {
        try await requestVoid(
            method: "POST",
            url: Routes.interactionResponse(interactionId, token: token),
            body: response
        )
    }

    @discardableResult
    func editInteractionResponse(
        applicationId: String,
        token: String,
        content: String
    ) async throws -> Message {
        let body = EditInteractionBody(content: content)
        var msg = try await request(
            method: "PATCH",
            url: Routes.originalInteractionResponse(applicationId, token: token),
            body: body,
            decodeAs: Message.self
        )
        msg._rest = self
        return msg
    }

    @discardableResult
    func createFollowup(
        applicationId: String,
        token: String,
        content: String,
        ephemeral: Bool = false
    ) async throws -> Message {
        let body = FollowupBody(content: content, flags: ephemeral ? 64 : nil)
        var msg = try await request(
            method: "POST",
            url: Routes.followupMessage(applicationId, token: token),
            body: body,
            decodeAs: Message.self
        )
        msg._rest = self
        return msg
    }
}

private extension RESTClient {
    func headerValue(_ name: String, from headers: [AnyHashable: Any]) -> String? {
        let lowercasedName = name.lowercased()
        for (key, value) in headers where String(describing: key).lowercased() == lowercasedName {
            return String(describing: value)
        }
        return nil
    }

    func headerDouble(_ name: String, from headers: [AnyHashable: Any]) -> Double? {
        guard let raw = headerValue(name, from: headers) else { return nil }
        return Double(raw)
    }

    func headerBool(_ name: String, from headers: [AnyHashable: Any]) -> Bool? {
        guard let raw = headerValue(name, from: headers)?.lowercased() else { return nil }
        switch raw {
        case "1", "true":
            return true
        case "0", "false":
            return false
        default:
            return nil
        }
    }

    func buildMultipartBody(
        boundary: String,
        payload: SendComponentsV2MessageBody,
        attachments: [DiscordFileUpload]
    ) throws -> Data {
        var body = Data()
        let lineBreak = "\r\n"

        func append(_ string: String) {
            body.append(Data(string.utf8))
        }

        append("--\(boundary)\(lineBreak)")
        append("Content-Disposition: form-data; name=\"payload_json\"\(lineBreak)")
        append("Content-Type: application/json\(lineBreak)\(lineBreak)")
        let payloadData = try JSONCoder.encode(payload)
        body.append(payloadData)
        append(lineBreak)

        for (index, file) in attachments.enumerated() {
            append("--\(boundary)\(lineBreak)")
            append("Content-Disposition: form-data; name=\"files[\(index)]\"; filename=\"\(file.filename)\"\(lineBreak)")
            append("Content-Type: \(file.contentType)\(lineBreak)\(lineBreak)")
            body.append(file.data)
            append(lineBreak)
        }

        append("--\(boundary)--\(lineBreak)")
        return body
    }
}


private struct SendMessageBody: Encodable {
    let content: String
    let messageReference: MessageReference?
}

private struct SendComponentsV2MessageBody: Encodable {
    let flags: Int
    let components: [ComponentV2Node]
    let messageReference: MessageReference?
    let attachments: [UploadAttachmentMetadata]?
}

private struct UploadAttachmentMetadata: Encodable {
    let id: Int
    let filename: String
    let description: String?
}

private struct EditInteractionBody: Encodable {
    let content: String
}

private struct FollowupBody: Encodable {
    let content: String
    let flags: Int?
}

private struct RateLimitResponse: Decodable {
    let message: String
    let retryAfter: Double
    let global: Bool
}


public struct ApplicationCommand: Codable, Sendable, Identifiable {
    public let id: String
    public let applicationId: String
    public let name: String
    public let description: String
    public let version: String
}
