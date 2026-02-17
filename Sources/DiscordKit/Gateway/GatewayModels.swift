import Foundation


enum GatewayOpcode: Int, Codable {
    case dispatch             = 0
    case heartbeat            = 1
    case identify             = 2
    case presenceUpdate       = 3
    case voiceStateUpdate     = 4
    case resume               = 6
    case reconnect            = 7
    case requestGuildMembers  = 8
    case invalidSession       = 9
    case hello                = 10
    case heartbeatACK         = 11
}


struct GatewayPayload: Decodable {
    let op: Int
    let s: Int?        // sequence number (only present for op 0 Dispatch)
    let t: String?     // event name (only present for op 0 Dispatch)
    let d: RawJSON?    // event data — varies per event type

    enum CodingKeys: String, CodingKey { case op, s, t, d }
}

struct RawJSON: Decodable {
    let data: Data

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let val = try? container.decode(AnyDecodable.self) {
            data = (try? JSONSerialization.data(withJSONObject: val.value, options: [.fragmentsAllowed])) ?? Data()
        } else {
            data = Data()
        }
    }

    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try JSONCoder.decode(type, from: data)
    }
}


struct HeartbeatPayload: Encodable {
    let op: Int = 1
    let d: Int?
}

struct IdentifyPayload: Encodable {
    let op: Int = 2
    let d: IdentifyData

    struct IdentifyData: Encodable {
        let token: String
        let intents: Int
        let properties: Properties
        let compress: Bool = false

        struct Properties: Encodable {
            let os: String
            let browser: String
            let device: String

            enum CodingKeys: String, CodingKey {
                case os = "$os"
                case browser = "$browser"
                case device = "$device"
            }
        }
    }
}

struct ResumePayload: Encodable {
    let op: Int = 6
    let d: ResumeData

    struct ResumeData: Encodable {
        let token: String
        let sessionId: String
        let seq: Int
    }
}

struct PresenceUpdatePayload: Encodable {
    let op: Int = GatewayOpcode.presenceUpdate.rawValue
    let d: DiscordPresenceUpdate
}


struct HelloData: Decodable {
    let heartbeatInterval: Int
}

public struct ReadyData: Decodable, Sendable {
    public let v: Int
    public let user: DiscordUser
    public let sessionId: String
    public let resumeGatewayUrl: String
    public let application: ReadyApplication
}

public struct ReadyApplication: Decodable, Sendable {
    public let id: String
    public let flags: Int?
}

public enum DiscordPresenceStatus: String, Codable, Sendable {
    case online
    case idle
    case dnd
    case invisible
}

public enum DiscordActivityType: Int, Codable, Sendable {
    case playing = 0
    case streaming = 1
    case listening = 2
    case watching = 3
    case custom = 4
    case competing = 5
}

public struct DiscordActivity: Codable, Sendable {
    public let name: String
    public let type: DiscordActivityType

    public init(name: String, type: DiscordActivityType = .playing) {
        self.name = name
        self.type = type
    }
}

public struct DiscordPresenceUpdate: Codable, Sendable {
    public let since: Int?
    public let activities: [DiscordActivity]
    public let status: DiscordPresenceStatus
    public let afk: Bool

    public init(
        since: Int? = nil,
        activities: [DiscordActivity] = [],
        status: DiscordPresenceStatus,
        afk: Bool = false
    ) {
        self.since = since
        self.activities = activities
        self.status = status
        self.afk = afk
    }
}

public struct GatewayBot: Codable, Sendable {
    public let url: String
    public let shards: Int?
    public let sessionStartLimit: SessionStartLimit
}

public struct GatewayInfo: Codable, Sendable {
    public let url: String
}

public struct SessionStartLimit: Codable, Sendable {
    public let total: Int
    public let remaining: Int
    public let resetAfter: Int
    public let maxConcurrency: Int
}


public struct GatewayIntents: OptionSet, Sendable {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    public static let guilds                     = GatewayIntents(rawValue: 1 << 0)
    public static let guildMembers               = GatewayIntents(rawValue: 1 << 1)
    public static let guildModeration            = GatewayIntents(rawValue: 1 << 2)
    public static let guildEmojisAndStickers     = GatewayIntents(rawValue: 1 << 3)
    public static let guildIntegrations          = GatewayIntents(rawValue: 1 << 4)
    public static let guildWebhooks              = GatewayIntents(rawValue: 1 << 5)
    public static let guildInvites               = GatewayIntents(rawValue: 1 << 6)
    public static let guildVoiceStates           = GatewayIntents(rawValue: 1 << 7)
    public static let guildPresences             = GatewayIntents(rawValue: 1 << 8)
    public static let guildMessages              = GatewayIntents(rawValue: 1 << 9)
    public static let guildMessageReactions      = GatewayIntents(rawValue: 1 << 10)
    public static let guildMessageTyping         = GatewayIntents(rawValue: 1 << 11)
    public static let directMessages            = GatewayIntents(rawValue: 1 << 12)
    public static let directMessageReactions    = GatewayIntents(rawValue: 1 << 13)
    public static let directMessageTyping       = GatewayIntents(rawValue: 1 << 14)
    public static let messageContent             = GatewayIntents(rawValue: 1 << 15)
    public static let guildScheduledEvents       = GatewayIntents(rawValue: 1 << 16)
    public static let autoModerationConfiguration = GatewayIntents(rawValue: 1 << 20)
    public static let autoModerationExecution    = GatewayIntents(rawValue: 1 << 21)

    public static let `default`: GatewayIntents = [
        .guilds, .guildMessages, .directMessages, .messageContent, .guildMessageReactions
    ]
}


struct AnyDecodable: Decodable {
    let value: Any

    init(from decoder: Decoder) throws {
        if let c = try? decoder.singleValueContainer() {
            if let v = try? c.decode(Bool.self)              { value = v; return }
            if let v = try? c.decode(Int.self)               { value = v; return }
            if let v = try? c.decode(Double.self)            { value = v; return }
            if let v = try? c.decode(String.self)            { value = v; return }
            if let v = try? c.decode([String: AnyDecodable].self) { value = v.mapValues { $0.value }; return }
            if let v = try? c.decode([AnyDecodable].self)    { value = v.map { $0.value }; return }
            if c.decodeNil()                                  { value = NSNull(); return }
        }
        value = NSNull()
    }
}
