import Foundation

public struct DiscordUser: Codable, Sendable, Identifiable {
    public let id: String
    public let username: String
    public let discriminator: String
    public let globalName: String?
    public let avatar: String?
    public let bot: Bool?
    public let system: Bool?
    public let mfaEnabled: Bool?
    public let banner: String?
    public let accentColor: Int?
    public let locale: String?
    public let verified: Bool?
    public let email: String?
    public let flags: Int?
    public let premiumType: Int?
    public let publicFlags: Int?
    public let avatarDecorationData: AvatarDecorationData?

    public var displayName: String {
        globalName ?? username
    }

    public var avatarURL: URL? {
        guard let avatar else { return nil }
        return URL(string: "https://cdn.discordapp.com/avatars/\(id)/\(avatar).png")
    }

    public var bannerURL: URL? {
        guard let banner else { return nil }
        return URL(string: "https://cdn.discordapp.com/banners/\(id)/\(banner).png")
    }

    public var tag: String {
        discriminator == "0" ? username : "\(username)#\(discriminator)"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case discriminator
        case globalName
        case avatar
        case bot
        case system
        case mfaEnabled
        case banner
        case accentColor
        case locale
        case verified
        case email
        case flags
        case premiumType
        case publicFlags
        case avatarDecorationData
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeStringLossy(forKey: .id)
        self.username = (try? container.decodeIfPresent(String.self, forKey: .username)) ?? "unknown"
        self.discriminator = (try? container.decodeIfPresent(String.self, forKey: .discriminator)) ?? "0"
        self.globalName = try? container.decodeIfPresent(String.self, forKey: .globalName)
        self.avatar = try? container.decodeIfPresent(String.self, forKey: .avatar)
        self.bot = try? container.decodeIfPresent(Bool.self, forKey: .bot)
        self.system = try? container.decodeIfPresent(Bool.self, forKey: .system)
        self.mfaEnabled = try? container.decodeIfPresent(Bool.self, forKey: .mfaEnabled)
        self.banner = try? container.decodeIfPresent(String.self, forKey: .banner)
        self.accentColor = try? container.decodeIfPresent(Int.self, forKey: .accentColor)
        self.locale = try? container.decodeIfPresent(String.self, forKey: .locale)
        self.verified = try? container.decodeIfPresent(Bool.self, forKey: .verified)
        self.email = try? container.decodeIfPresent(String.self, forKey: .email)
        self.flags = try? container.decodeIfPresent(Int.self, forKey: .flags)
        self.premiumType = try? container.decodeIfPresent(Int.self, forKey: .premiumType)
        self.publicFlags = try? container.decodeIfPresent(Int.self, forKey: .publicFlags)
        self.avatarDecorationData = try? container.decodeIfPresent(AvatarDecorationData.self, forKey: .avatarDecorationData)
    }
}

public struct AvatarDecorationData: Codable, Sendable {
    public let asset: String?
    public let skuId: String?
}

private extension KeyedDecodingContainer {
    func decodeStringLossy(forKey key: Key) throws -> String {
        if let stringValue = try? decode(String.self, forKey: key) {
            return stringValue
        }
        if let intValue = try? decode(Int.self, forKey: key) {
            return String(intValue)
        }
        if let doubleValue = try? decode(Double.self, forKey: key) {
            return String(doubleValue)
        }
        throw DecodingError.dataCorruptedError(
            forKey: key,
            in: self,
            debugDescription: "Expected string-compatible value"
        )
    }
}
