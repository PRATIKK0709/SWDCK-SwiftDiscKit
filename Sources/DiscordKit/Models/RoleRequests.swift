import Foundation

public struct CreateGuildRole: Encodable, Sendable {
    public let name: String?
    public let permissions: String?
    public let color: Int?
    public let hoist: Bool?
    public let icon: String?
    public let unicodeEmoji: String?
    public let mentionable: Bool?

    public init(
        name: String? = nil,
        permissions: String? = nil,
        color: Int? = nil,
        hoist: Bool? = nil,
        icon: String? = nil,
        unicodeEmoji: String? = nil,
        mentionable: Bool? = nil
    ) {
        self.name = name
        self.permissions = permissions
        self.color = color
        self.hoist = hoist
        self.icon = icon
        self.unicodeEmoji = unicodeEmoji
        self.mentionable = mentionable
    }
}

public struct ModifyGuildRole: Encodable, Sendable {
    public let name: String?
    public let permissions: String?
    public let color: Int?
    public let hoist: Bool?
    public let icon: String?
    public let unicodeEmoji: String?
    public let mentionable: Bool?

    public init(
        name: String? = nil,
        permissions: String? = nil,
        color: Int? = nil,
        hoist: Bool? = nil,
        icon: String? = nil,
        unicodeEmoji: String? = nil,
        mentionable: Bool? = nil
    ) {
        self.name = name
        self.permissions = permissions
        self.color = color
        self.hoist = hoist
        self.icon = icon
        self.unicodeEmoji = unicodeEmoji
        self.mentionable = mentionable
    }
}
