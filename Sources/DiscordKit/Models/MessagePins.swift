import Foundation

public struct MessagePinsPage: Codable, Sendable {
    public var items: [MessagePin]
    public let hasMore: Bool
}

public struct MessagePin: Codable, Sendable {
    public let pinnedAt: String
    public var message: Message

    enum CodingKeys: String, CodingKey {
        case pinnedAt, message
    }
}

public struct MessagePinsQuery: Sendable {
    public let before: String?
    public let limit: Int?

    public init(before: String? = nil, limit: Int? = nil) {
        self.before = before
        self.limit = limit
    }
}

public struct ReactionUsersQuery: Sendable {
    public let after: String?
    public let limit: Int?
    public let type: ReactionType?

    public init(after: String? = nil, limit: Int? = nil, type: ReactionType? = nil) {
        self.after = after
        self.limit = limit
        self.type = type
    }
}

public enum ReactionType: Int, Codable, Sendable {
    case normal = 0
    case burst = 1
}
