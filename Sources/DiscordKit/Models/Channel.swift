import Foundation

public enum ChannelType: Int, Codable, Sendable {
    case guildText       = 0
    case dm              = 1
    case guildVoice      = 2
    case groupDm         = 3
    case guildCategory   = 4
    case guildAnnouncement = 5
    case announcementThread = 10
    case publicThread    = 11
    case privateThread   = 12
    case guildStageVoice = 13
    case guildDirectory  = 14
    case guildForum      = 15
    case guildMedia      = 16
    case unknown         = -1

    public init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(Int.self)
        self = ChannelType(rawValue: raw) ?? .unknown
    }
}

public struct Channel: Codable, Sendable, Identifiable {
    public let id: String
    public let type: ChannelType
    public let guildId: String?
    public let name: String?
    public let topic: String?
    public let nsfw: Bool?
    public let position: Int?
    public let permissionOverwrites: [ChannelPermissionOverwrite]?
    public let parentId: String?
    public let rateLimitPerUser: Int?
    public let lastMessageId: String?
    public let bitrate: Int?
    public let userLimit: Int?
    public let recipients: [DiscordUser]?
    public let icon: String?
    public let ownerId: String?
    public let applicationId: String?
    public let managed: Bool?
    public let lastPinTimestamp: String?
    public let rtcRegion: String?
    public let videoQualityMode: Int?
    public let messageCount: Int?
    public let memberCount: Int?
    public let threadMetadata: ChannelThreadMetadata?
    public let member: ChannelThreadMember?
    public let defaultAutoArchiveDuration: Int?
    public let permissions: String?
    public let flags: Int?
    public let totalMessageSent: Int?
    public let defaultThreadRateLimitPerUser: Int?
    public let availableTags: [ChannelForumTag]?
    public let appliedTags: [String]?
    public let defaultReactionEmoji: ChannelDefaultReactionEmoji?
    public let defaultSortOrder: Int?
    public let defaultForumLayout: Int?

    public var isTextBased: Bool {
        [.guildText, .dm, .groupDm, .guildAnnouncement, .publicThread, .privateThread].contains(type)
    }
}

public struct ChannelPermissionOverwrite: Codable, Sendable {
    public let id: String
    public let type: Int
    public let allow: String
    public let deny: String
}

public struct ChannelThreadMetadata: Codable, Sendable {
    public let archived: Bool?
    public let autoArchiveDuration: Int?
    public let archiveTimestamp: String?
    public let locked: Bool?
    public let invitable: Bool?
    public let createTimestamp: String?
}

public struct ChannelThreadMember: Codable, Sendable {
    public let id: String?
    public let userId: String?
    public let joinTimestamp: String?
    public let flags: Int?
    public let member: GuildMember?
    public let presence: JSONValue?
    public let muteConfig: JSONValue?
    public let muted: Bool?
}

public struct ChannelForumTag: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let moderated: Bool?
    public let emojiId: String?
    public let emojiName: String?
}

public struct ChannelDefaultReactionEmoji: Codable, Sendable {
    public let emojiId: String?
    public let emojiName: String?
}
