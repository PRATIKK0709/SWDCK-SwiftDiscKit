import Foundation

public enum WebhookType: Int, Codable, Sendable {
    case incoming = 1
    case channelFollower = 2
    case application = 3
    case unknown = -1

    public init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(Int.self)
        self = WebhookType(rawValue: raw) ?? .unknown
    }
}

public struct Webhook: Codable, Sendable, Identifiable {
    public let id: String
    public let type: WebhookType
    public let guildId: String?
    public let channelId: String?
    public let user: DiscordUser?
    public let name: String?
    public let avatar: String?
    public let token: String?
    public let applicationId: String?
    public let sourceGuild: WebhookSourceGuild?
    public let sourceChannel: WebhookSourceChannel?
    public let url: String?
}

public struct WebhookSourceGuild: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String?
    public let icon: String?
}

public struct WebhookSourceChannel: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String?
}

public struct CreateWebhook: Encodable, Sendable {
    public let name: String
    public let avatar: String?

    public init(name: String, avatar: String? = nil) {
        self.name = name
        self.avatar = avatar
    }
}

public struct ModifyWebhook: Encodable, Sendable {
    public let name: String?
    public let avatar: String?
    public let channelId: String?

    public init(name: String? = nil, avatar: String? = nil, channelId: String? = nil) {
        self.name = name
        self.avatar = avatar
        self.channelId = channelId
    }
}

public struct ExecuteWebhook: Encodable, Sendable {
    public let content: String?
    public let username: String?
    public let avatarUrl: String?
    public let tts: Bool?
    public let embeds: [Embed]?
    public let allowedMentions: WebhookAllowedMentions?
    public let components: [JSONValue]?
    public let attachments: [Attachment]?
    public let flags: Int?
    public let threadName: String?

    public init(
        content: String? = nil,
        username: String? = nil,
        avatarUrl: String? = nil,
        tts: Bool? = nil,
        embeds: [Embed]? = nil,
        allowedMentions: WebhookAllowedMentions? = nil,
        components: [JSONValue]? = nil,
        attachments: [Attachment]? = nil,
        flags: Int? = nil,
        threadName: String? = nil
    ) {
        self.content = content
        self.username = username
        self.avatarUrl = avatarUrl
        self.tts = tts
        self.embeds = embeds
        self.allowedMentions = allowedMentions
        self.components = components
        self.attachments = attachments
        self.flags = flags
        self.threadName = threadName
    }
}

public struct EditWebhookMessage: Encodable, Sendable {
    public let content: String?
    public let embeds: [Embed]?
    public let allowedMentions: WebhookAllowedMentions?
    public let components: [JSONValue]?
    public let attachments: [Attachment]?
    public let flags: Int?

    public init(
        content: String? = nil,
        embeds: [Embed]? = nil,
        allowedMentions: WebhookAllowedMentions? = nil,
        components: [JSONValue]? = nil,
        attachments: [Attachment]? = nil,
        flags: Int? = nil
    ) {
        self.content = content
        self.embeds = embeds
        self.allowedMentions = allowedMentions
        self.components = components
        self.attachments = attachments
        self.flags = flags
    }
}

public struct WebhookAllowedMentions: Encodable, Sendable {
    public let parse: [String]?
    public let roles: [String]?
    public let users: [String]?
    public let repliedUser: Bool?

    public init(parse: [String]? = nil, roles: [String]? = nil, users: [String]? = nil, repliedUser: Bool? = nil) {
        self.parse = parse
        self.roles = roles
        self.users = users
        self.repliedUser = repliedUser
    }
}

public struct ExecuteWebhookQuery: Sendable {
    public let wait: Bool?
    public let threadId: String?

    public init(wait: Bool? = nil, threadId: String? = nil) {
        self.wait = wait
        self.threadId = threadId
    }
}

public struct WebhookMessageQuery: Sendable {
    public let threadId: String?

    public init(threadId: String? = nil) {
        self.threadId = threadId
    }
}
