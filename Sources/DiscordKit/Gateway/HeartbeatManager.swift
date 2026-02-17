import Foundation

actor HeartbeatManager {

    private var task: Task<Void, Never>?
    private var missedAcks: Int = 0
    private let maxMissedAcks = 2

    func start(
        intervalMs: Int,
        sequenceProvider: @escaping @Sendable () async -> Int?,
        onHeartbeat: @escaping @Sendable (Int?) async -> Void,
        onZombieDetected: @escaping @Sendable () async -> Void
    ) {
        stop()

        let safeIntervalMs = max(intervalMs, 1)
        let intervalNs = UInt64(safeIntervalMs) * 1_000_000
        let jitterNs = UInt64.random(in: 0..<intervalNs)

        task = Task { [weak self] in
            try? await Task.sleep(nanoseconds: jitterNs)

            while !Task.isCancelled {
                guard let self else { return }

                let seq = await sequenceProvider()
                logger.debug("Sending heartbeat (seq: \(seq.map(String.init) ?? "null"))")
                await onHeartbeat(seq)
                await self.recordHeartbeatSent()

                try? await Task.sleep(nanoseconds: intervalNs)

                if await self.missedAcks >= self.maxMissedAcks {
                    logger.warning("Heartbeat ACK not received — connection is zombied. Reconnecting.")
                    await onZombieDetected()
                    return
                }
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
        missedAcks = 0
    }

    func didReceiveACK() {
        missedAcks = 0
        logger.debug("Heartbeat ACK received")
    }

    private func recordHeartbeatSent() {
        missedAcks += 1
    }
}
