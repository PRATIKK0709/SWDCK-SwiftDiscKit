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
    public let mentionRoles: [String]?
    public let mentionChannels: [MessageMentionChannel]?
    public let attachments: [Attachment]
    public let embeds: [Embed]
    public let reactions: [MessageReaction]?
    public let nonce: JSONValue?
    public let pinned: Bool
    public let webhookId: String?
    public let type: MessageType
    public let activity: MessageActivity?
    public let application: MessageApplication?
    public let applicationId: String?
    public let messageReference: MessageReference?
    public let flags: Int?
    public let referencedMessage: MessageReferencedMessage?
    public let interaction: MessageInteraction?
    public let interactionMetadata: MessageInteractionMetadata?
    public let thread: Channel?
    public let components: [JSONValue]?
    public let stickerItems: [MessageStickerItem]?
    public let stickers: [JSONValue]?
    public let member: GuildMember?
    public let position: Int?
    public let roleSubscriptionData: MessageRoleSubscriptionData?
    public let resolved: JSONValue?
    public let poll: JSONValue?
    public let call: MessageCall?

    var _rest: RESTClient?

    enum CodingKeys: String, CodingKey {
        case id, channelId, guildId, author, content, timestamp
        case editedTimestamp, tts, mentionEveryone, mentions, mentionRoles, mentionChannels
        case attachments, embeds, reactions, nonce, pinned, webhookId, type, activity, application
        case applicationId, messageReference, flags, referencedMessage, interaction, interactionMetadata
        case thread, components, stickerItems, stickers, member, position, roleSubscriptionData
        case resolved, poll, call
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
    case guildBoostTier1 = 9
    case guildBoostTier2 = 10
    case guildBoostTier3 = 11
    case channelFollowAdd = 12
    case guildDiscoveryDisqualified = 14
    case guildDiscoveryRequalified = 15
    case guildDiscoveryGracePeriodInitialWarning = 16
    case guildDiscoveryGracePeriodFinalWarning = 17
    case threadCreated = 18
    case reply = 19
    case chatInputCommand = 20
    case threadStarterMessage = 21
    case guildInviteReminder = 22
    case contextMenuCommand = 23
    case autoModerationAction = 24
    case roleSubscriptionPurchase = 25
    case interactionPremiumUpsell = 26
    case stageStart = 27
    case stageEnd = 28
    case stageSpeaker = 29
    case stageTopic = 31
    case guildApplicationPremiumSubscription = 32
    case guildIncidentAlertModeEnabled = 36
    case guildIncidentAlertModeDisabled = 37
    case guildIncidentReportRaid = 38
    case guildIncidentReportFalseAlarm = 39
    case purchaseNotification = 44
    case pollResult = 46
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

public struct MessageMentionChannel: Codable, Sendable, Identifiable {
    public let id: String
    public let guildId: String?
    public let type: Int?
    public let name: String?
}

public struct MessageReaction: Codable, Sendable {
    public let count: Int?
    public let countDetails: MessageReactionCountDetails?
    public let me: Bool?
    public let meBurst: Bool?
    public let emoji: MessageEmoji
    public let burstColors: [String]?
}

public struct MessageReactionCountDetails: Codable, Sendable {
    public let burst: Int?
    public let normal: Int?
}

public struct MessageEmoji: Codable, Sendable {
    public let id: String?
    public let name: String?
    public let animated: Bool?
}

public struct MessageActivity: Codable, Sendable {
    public let type: Int?
    public let partyId: String?
}

public struct MessageApplication: Codable, Sendable, Identifiable {
    public let id: String
    public let coverImage: String?
    public let description: String?
    public let icon: String?
    public let name: String?
}

public struct MessageInteraction: Codable, Sendable {
    public let id: String
    public let type: Int?
    public let name: String?
    public let user: DiscordUser?
}

public struct MessageInteractionMetadata: Codable, Sendable {
    public let id: String?
    public let type: Int?
    public let user: DiscordUser?
    public let originalResponseMessageId: String?
    public let interactedMessageId: String?
    public let authorizingIntegrationOwners: [String: String]?
}

public struct MessageStickerItem: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String?
    public let formatType: Int?
}

public struct MessageRoleSubscriptionData: Codable, Sendable {
    public let roleSubscriptionListingId: String?
    public let tierName: String?
    public let totalMonthsSubscribed: Int?
    public let isRenewal: Bool?
}

public struct MessageCall: Codable, Sendable {
    public let participants: [String]?
    public let endedTimestamp: String?
}

public struct MessageReferencedMessage: Codable, Sendable, Identifiable {
    public let id: String
    public let channelId: String
    public let guildId: String?
    public let author: DiscordUser?
    public let content: String?
    public let timestamp: String?
    public let editedTimestamp: String?
    public let tts: Bool?
    public let mentionEveryone: Bool?
    public let mentions: [DiscordUser]?
    public let mentionRoles: [String]?
    public let attachments: [Attachment]?
    public let embeds: [Embed]?
    public let pinned: Bool?
    public let type: MessageType?
    public let flags: Int?
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
    public let timestamp: String?

    public init(
        title: String? = nil,
        type: String? = nil,
        description: String? = nil,
        url: String? = nil,
        color: Int? = nil,
        footer: EmbedFooter? = nil,
        image: EmbedMedia? = nil,
        thumbnail: EmbedMedia? = nil,
        author: EmbedAuthor? = nil,
        fields: [EmbedField]? = nil,
        timestamp: String? = nil
    ) {
        self.title = title
        self.type = type
        self.description = description
        self.url = url
        self.color = color
        self.footer = footer
        self.image = image
        self.thumbnail = thumbnail
        self.author = author
        self.fields = fields
        self.timestamp = timestamp
    }
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


public struct EmbedBuilder: Sendable {
    var title: String?
    var description: String?
    var url: String?
    var color: Int?
    var timestamp: String?
    var fields: [EmbedField] = []
    var footer: EmbedFooter?
    var author: EmbedAuthor?
    var image: EmbedMedia?
    var thumbnail: EmbedMedia?

    public init() {}

    public mutating func setTitle(_ title: String) { self.title = title }
    public mutating func setDescription(_ desc: String) { self.description = desc }
    public mutating func setURL(_ url: String) { self.url = url }
    public mutating func setColor(_ hex: Int) { self.color = hex }
    public mutating func setTimestamp(_ iso8601: String) { self.timestamp = iso8601 }
    public mutating func addField(name: String, value: String, inline: Bool = false) {
        fields.append(EmbedField(name: name, value: value, inline: inline))
    }
    public mutating func setFooter(_ text: String, iconUrl: String? = nil) {
        footer = EmbedFooter(text: text, iconUrl: iconUrl)
    }
    public mutating func setAuthor(name: String, url: String? = nil, iconUrl: String? = nil) {
        author = EmbedAuthor(name: name, url: url, iconUrl: iconUrl)
    }
    public mutating func setImage(url: String) {
        image = EmbedMedia(url: url, proxyUrl: nil, height: nil, width: nil)
    }
    public mutating func setThumbnail(url: String) {
        thumbnail = EmbedMedia(url: url, proxyUrl: nil, height: nil, width: nil)
    }

    public func build() -> Embed {
        Embed(
            title: title, type: "rich", description: description,
            url: url, color: color, footer: footer,
            image: image, thumbnail: thumbnail, author: author,
            fields: fields, timestamp: timestamp
        )
    }
}
