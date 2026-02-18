import Foundation

public struct SendMessagePayload: Sendable {
    public let content: String?
    public let embeds: [Embed]?
    public let allowedMentions: AllowedMentions?
    public let messageReference: MessageReference?
    public let stickerIds: [String]?
    public let flags: Int?

    public init(
        content: String? = nil,
        embeds: [Embed]? = nil,
        allowedMentions: AllowedMentions? = nil,
        messageReference: MessageReference? = nil,
        stickerIds: [String]? = nil,
        flags: Int? = nil
    ) {
        self.content = content
        self.embeds = embeds
        self.allowedMentions = allowedMentions
        self.messageReference = messageReference
        self.stickerIds = stickerIds
        self.flags = flags
    }
}

public struct EditMessagePayload: Sendable {
    public let content: String?
    public let embeds: [Embed]?
    public let allowedMentions: AllowedMentions?
    public let flags: Int?

    public init(
        content: String? = nil,
        embeds: [Embed]? = nil,
        allowedMentions: AllowedMentions? = nil,
        flags: Int? = nil
    ) {
        self.content = content
        self.embeds = embeds
        self.allowedMentions = allowedMentions
        self.flags = flags
    }
}
