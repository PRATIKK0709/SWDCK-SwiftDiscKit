import Foundation

public struct DiscordUser: Codable, Sendable, Identifiable {
    public let id: String
    public let username: String
    public let discriminator: String
    public let globalName: String?
    public let avatar: String?
    public let bot: Bool?
    public let system: Bool?
    public let publicFlags: Int?

    public var displayName: String {
        globalName ?? username
    }

    public var avatarURL: URL? {
        guard let avatar else { return nil }
        return URL(string: "https://cdn.discordapp.com/avatars/\(id)/\(avatar).png")
    }

    public var tag: String {
        discriminator == "0" ? username : "\(username)#\(discriminator)"
    }
}
