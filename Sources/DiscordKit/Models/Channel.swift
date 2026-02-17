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
    public let parentId: String?
    public let rateLimitPerUser: Int?
    public let lastMessageId: String?

    public var isTextBased: Bool {
        [.guildText, .dm, .groupDm, .guildAnnouncement, .publicThread, .privateThread].contains(type)
    }
}
