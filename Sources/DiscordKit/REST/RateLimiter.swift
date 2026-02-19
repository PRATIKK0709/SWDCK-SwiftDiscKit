import Foundation

actor RateLimiter {

    private struct Bucket {
        var remaining: Int
        var resetAt: Date
        var limit: Int
    }

    private var buckets: [String: Bucket] = [:]
    private var routeToBucketScope: [String: String] = [:]
    private var globalResetAt: Date?


    func waitIfNeeded(for route: String) async {
        if let globalResetAt {
            let globalDelay = globalResetAt.timeIntervalSinceNow
            if globalDelay > 0 {
                logger.warning("Global rate limit active. Waiting \(String(format: "%.2f", globalDelay))s")
                try? await Task.sleep(nanoseconds: UInt64(globalDelay * 1_000_000_000))
            } else {
                self.globalResetAt = nil
            }
        }

        guard let bucketScope = routeToBucketScope[route],
              let bucket = buckets[bucketScope]
        else { return }

        if bucket.remaining <= 0 {
            let now = Date()
            let delay = bucket.resetAt.timeIntervalSince(now)
            if delay > 0 {
                logger.warning("Rate limit hit for route \(route). Waiting \(String(format: "%.2f", delay))s")
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
    }

    func update(route: String, headers: [AnyHashable: Any]) {
        let normalized = normalizeHeaders(headers)

        guard
            let bucketId = normalized["x-ratelimit-bucket"],
            let remaining = Int(normalized["x-ratelimit-remaining"] ?? ""),
            let limit = Int(normalized["x-ratelimit-limit"] ?? "")
        else { return }

        let resetAt: Date
        if let resetAfter = Double(normalized["x-ratelimit-reset-after"] ?? "") {
            resetAt = Date().addingTimeInterval(resetAfter)
        } else if let reset = Double(normalized["x-ratelimit-reset"] ?? "") {
            resetAt = Date(timeIntervalSince1970: reset)
        } else {
            return
        }

        let bucketScope = bucketScopeKey(bucketId: bucketId, route: route)
        routeToBucketScope[route] = bucketScope
        buckets[bucketScope] = Bucket(remaining: remaining, resetAt: resetAt, limit: limit)

        if remaining == 0 {
            logger.debug("Bucket \(bucketId) exhausted. Resets at \(resetAt)")
        }
    }

    func handleGlobalRateLimit(retryAfter: Double) async {
        globalResetAt = Date().addingTimeInterval(retryAfter)
        logger.warning("Global rate limit! Waiting \(retryAfter)s")
        try? await Task.sleep(nanoseconds: UInt64(retryAfter * 1_000_000_000))
        globalResetAt = nil
    }

    private func normalizeHeaders(_ headers: [AnyHashable: Any]) -> [String: String] {
        var normalized: [String: String] = [:]
        for (key, value) in headers {
            let normalizedKey = String(describing: key).lowercased()
            normalized[normalizedKey] = String(describing: value)
        }
        return normalized
    }

    private func bucketScopeKey(bucketId: String, route: String) -> String {
        "\(bucketId)|\(majorParameterKey(from: route))"
    }

    private func majorParameterKey(from route: String) -> String {
        let path = routePath(from: route)
        let segments = path
            .split(separator: "/", omittingEmptySubsequences: true)
            .map(String.init)

        guard !segments.isEmpty else { return "global" }

        var parts: [String] = []
        for index in segments.indices {
            let segment = segments[index]
            if segment == "channels" || segment == "guilds" {
                guard index + 1 < segments.count else { continue }
                let id = segments[index + 1]
                if id != ":id" {
                    parts.append("\(segment):\(id)")
                }
                continue
            }

            if segment == "webhooks" {
                guard index + 1 < segments.count else { continue }
                let webhookId = segments[index + 1]
                if webhookId != ":id" {
                    parts.append("webhooks:\(webhookId)")
                }
                if index + 2 < segments.count {
                    let token = segments[index + 2]
                    if token != ":id", token != "messages" {
                        parts.append("token:\(token)")
                    }
                }
            }
        }

        return parts.isEmpty ? "global" : parts.joined(separator: "|")
    }

    private func routePath(from route: String) -> String {
        guard let separatorIndex = route.firstIndex(of: ":") else {
            return route
        }
        return String(route[route.index(after: separatorIndex)...])
    }
}
