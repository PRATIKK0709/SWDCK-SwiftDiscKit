import Foundation

public struct Guild: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let icon: String?
    public let ownerId: String
    public let memberCount: Int?
    public let description: String?
    public let preferredLocale: String

    public var iconURL: URL? {
        guard let icon else { return nil }
        return URL(string: "https://cdn.discordapp.com/icons/\(id)/\(icon).png")
    }
}

public struct GuildMember: Codable, Sendable {
    public let user: DiscordUser?
    public let nick: String?
    public let roles: [String]
    public let joinedAt: String?
    public let deaf: Bool?
    public let mute: Bool?

    public var displayName: String {
        nick ?? user?.displayName ?? "Unknown"
    }

    public init(
        user: DiscordUser?,
        nick: String?,
        roles: [String],
        joinedAt: String?,
        deaf: Bool?,
        mute: Bool?
    ) {
        self.user = user
        self.nick = nick
        self.roles = roles
        self.joinedAt = joinedAt
        self.deaf = deaf
        self.mute = mute
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.user = try container.decodeIfPresent(DiscordUser.self, forKey: .user)
        self.nick = try container.decodeIfPresent(String.self, forKey: .nick)
        self.roles = try container.decodeIfPresent([String].self, forKey: .roles) ?? []
        self.joinedAt = try container.decodeIfPresent(String.self, forKey: .joinedAt)
        self.deaf = try container.decodeIfPresent(Bool.self, forKey: .deaf)
        self.mute = try container.decodeIfPresent(Bool.self, forKey: .mute)
    }
}
