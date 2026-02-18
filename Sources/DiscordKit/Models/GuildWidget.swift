import Foundation

public struct GuildWidgetSettings: Codable, Sendable {
    public let enabled: Bool
    public let channelId: String?
}

public struct GuildWidget: Codable, Sendable {
    public let id: String
    public let name: String
    public let instantInvite: String?
    public let channels: [GuildWidgetChannel]?
    public let members: [GuildWidgetMember]?
    public let presenceCount: Int?
}

public struct GuildWidgetChannel: Codable, Sendable {
    public let id: String
    public let name: String
    public let position: Int?
}

public struct GuildWidgetMember: Codable, Sendable {
    public let id: String
    public let username: String
    public let discriminator: String?
    public let avatar: String?
    public let status: String?
    public let avatarUrl: String?
}

public struct ModifyGuildWidget: Codable, Sendable {
    public let enabled: Bool?
    public let channelId: String?

    public init(enabled: Bool? = nil, channelId: String? = nil) {
        self.enabled = enabled
        self.channelId = channelId
    }
}
