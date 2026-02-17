import Foundation

public struct Message: Codable, Sendable, Identifiable {
    public let id: String
    public let channelId: String
    public let guildId: String?
    public let author: DiscordUser
    public let content: String
    public let timestamp: String
    public let editedTimestamp: String?
    public let tts: Bool
    public let mentionEveryone: Bool
    public let mentions: [DiscordUser]
    public let attachments: [Attachment]
    public let embeds: [Embed]
    public let pinned: Bool
    public let type: MessageType
    public let member: GuildMember?

    var _rest: RESTClient?

    enum CodingKeys: String, CodingKey {
        case id, channelId, guildId, author, content, timestamp
        case editedTimestamp, tts, mentionEveryone, mentions
        case attachments, embeds, pinned, type, member
    }

    @discardableResult
    public func reply(_ content: String) async throws -> Message {
        guard let rest = _rest else {
            throw DiscordError.unknown("Message has no REST client attached — cannot reply.")
        }
        return try await rest.sendMessage(
            channelId: channelId,
            content: content,
            messageReference: MessageReference(messageId: id, channelId: channelId, guildId: guildId)
        )
    }

    @discardableResult
    public func respond(_ content: String) async throws -> Message {
        guard let rest = _rest else {
            throw DiscordError.unknown("Message has no REST client attached.")
        }
        return try await rest.sendMessage(channelId: channelId, content: content)
    }
}

public enum MessageType: Int, Codable, Sendable {
    case `default` = 0
    case recipientAdd = 1
    case recipientRemove = 2
    case call = 3
    case channelNameChange = 4
    case channelIconChange = 5
    case channelPinnedMessage = 6
    case userJoin = 7
    case guildBoost = 8
    case reply = 19
    case chatInputCommand = 20
    case unknown = -1

    public init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(Int.self)
        self = MessageType(rawValue: raw) ?? .unknown
    }
}

public struct MessageReference: Codable, Sendable {
    public let messageId: String?
    public let channelId: String?
    public let guildId: String?
}

public struct MessageHistoryQuery: Sendable {
    public let around: String?
    public let before: String?
    public let after: String?
    public let limit: Int?

    public init(
        around: String? = nil,
        before: String? = nil,
        after: String? = nil,
        limit: Int? = nil
    ) {
        self.around = around
        self.before = before
        self.after = after
        self.limit = limit
    }
}

public struct Attachment: Codable, Sendable, Identifiable {
    public let id: String
    public let filename: String
    public let size: Int
    public let url: String
    public let proxyUrl: String
    public let contentType: String?
    public let width: Int?
    public let height: Int?
}

public struct Embed: Codable, Sendable {
    public let title: String?
    public let type: String?
    public let description: String?
    public let url: String?
    public let color: Int?
    public let footer: EmbedFooter?
    public let image: EmbedMedia?
    public let thumbnail: EmbedMedia?
    public let author: EmbedAuthor?
    public let fields: [EmbedField]?
}

public struct EmbedFooter: Codable, Sendable {
    public let text: String
    public let iconUrl: String?
}

public struct EmbedMedia: Codable, Sendable {
    public let url: String
    public let proxyUrl: String?
    public let height: Int?
    public let width: Int?
}

public struct EmbedAuthor: Codable, Sendable {
    public let name: String
    public let url: String?
    public let iconUrl: String?
}

public struct EmbedField: Codable, Sendable {
    public let name: String
    public let value: String
    public let inline: Bool?
}


public struct EmbedBuilder {
    var title: String?
    var description: String?
    var color: Int?
    var fields: [EmbedField] = []
    var footer: EmbedFooter?
    var author: EmbedAuthor?

    public init() {}

    public mutating func setTitle(_ title: String) { self.title = title }
    public mutating func setDescription(_ desc: String) { self.description = desc }
    public mutating func setColor(_ hex: Int) { self.color = hex }
    public mutating func addField(name: String, value: String, inline: Bool = false) {
        fields.append(EmbedField(name: name, value: value, inline: inline))
    }
    public mutating func setFooter(_ text: String) { footer = EmbedFooter(text: text, iconUrl: nil) }

    func build() -> Embed {
        Embed(
            title: title, type: "rich", description: description,
            url: nil, color: color, footer: footer,
            image: nil, thumbnail: nil, author: author, fields: fields
        )
    }
}
