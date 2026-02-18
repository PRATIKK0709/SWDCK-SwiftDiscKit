import Foundation


public struct Sticker: Codable, Sendable {
    public let id: String
    public let packId: String?
    public let name: String
    public let description: String?
    public let tags: String?
    public let type: StickerType?
    public let formatType: StickerFormatType?
    public let available: Bool?
    public let guildId: String?
    public let user: DiscordUser?
    public let sortValue: Int?
}

public enum StickerType: Int, Codable, Sendable {
    case standard = 1
    case guild = 2
}

public enum StickerFormatType: Int, Codable, Sendable {
    case png = 1
    case apng = 2
    case lottie = 3
    case gif = 4
}

public struct StickerItem: Codable, Sendable {
    public let id: String
    public let name: String
    public let formatType: StickerFormatType?
}

public struct StickerPack: Codable, Sendable {
    public let id: String
    public let stickers: [Sticker]
    public let name: String
    public let skuId: String
    public let coverStickerId: String?
    public let description: String
    public let bannerAssetId: String?
}

public struct StickerPacksResponse: Codable, Sendable {
    public let stickerPacks: [StickerPack]
}

public struct CreateGuildSticker: Codable, Sendable {
    public let name: String
    public let description: String
    public let tags: String

    public init(name: String, description: String, tags: String) {
        self.name = name
        self.description = description
        self.tags = tags
    }
}

public struct ModifyGuildSticker: Codable, Sendable {
    public let name: String?
    public let description: String?
    public let tags: String?

    public init(name: String? = nil, description: String? = nil, tags: String? = nil) {
        self.name = name
        self.description = description
        self.tags = tags
    }
}
