import Foundation

public struct Guild: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let icon: String?
    public let iconHash: String?
    public let splash: String?
    public let discoverySplash: String?
    public let owner: Bool?
    public let ownerId: String?
    public let permissions: String?
    public let afkChannelId: String?
    public let afkTimeout: Int?
    public let widgetEnabled: Bool?
    public let widgetChannelId: String?
    public let verificationLevel: Int?
    public let defaultMessageNotifications: Int?
    public let explicitContentFilter: Int?
    public let roles: [GuildRole]?
    public let emojis: [JSONValue]?
    public let features: [String]?
    public let mfaLevel: Int?
    public let applicationId: String?
    public let systemChannelId: String?
    public let systemChannelFlags: Int?
    public let rulesChannelId: String?
    public let maxPresences: Int?
    public let maxMembers: Int?
    public let vanityUrlCode: String?
    public let memberCount: Int?
    public let description: String?
    public let banner: String?
    public let premiumTier: Int?
    public let premiumSubscriptionCount: Int?
    public let preferredLocale: String?
    public let publicUpdatesChannelId: String?
    public let maxVideoChannelUsers: Int?
    public let maxStageVideoChannelUsers: Int?
    public let approximateMemberCount: Int?
    public let approximatePresenceCount: Int?
    public let welcomeScreen: JSONValue?
    public let nsfwLevel: Int?
    public let stickers: [JSONValue]?
    public let premiumProgressBarEnabled: Bool?
    public let safetyAlertsChannelId: String?
    public let unavailable: Bool?

    public var iconURL: URL? {
        guard let icon else { return nil }
        return URL(string: "https://cdn.discordapp.com/icons/\(id)/\(icon).png")
    }

    public var bannerURL: URL? {
        guard let banner else { return nil }
        return URL(string: "https://cdn.discordapp.com/banners/\(id)/\(banner).png")
    }
}

public struct GuildRole: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let description: String?
    public let color: Int
    public let hoist: Bool
    public let icon: String?
    public let unicodeEmoji: String?
    public let position: Int
    public let permissions: String
    public let managed: Bool
    public let mentionable: Bool
    public let tags: GuildRoleTags?
    public let flags: Int?
}

public struct GuildRoleTags: Codable, Sendable {
    public let botId: String?
    public let integrationId: String?
    public let premiumSubscriber: Bool?
    public let subscriptionListingId: String?
    public let availableForPurchase: Bool?
    public let guildConnections: Bool?
}

public struct GuildMember: Codable, Sendable {
    public let user: DiscordUser?
    public let nick: String?
    public let avatar: String?
    public let banner: String?
    public let roles: [String]
    public let joinedAt: String?
    public let premiumSince: String?
    public let deaf: Bool?
    public let mute: Bool?
    public let flags: Int?
    public let pending: Bool?
    public let permissions: String?
    public let communicationDisabledUntil: String?
    public let unusualDmActivityUntil: String?
    public let avatarDecorationData: AvatarDecorationData?

    public var displayName: String {
        nick ?? user?.displayName ?? "Unknown"
    }

    public init(
        user: DiscordUser?,
        nick: String?,
        avatar: String?,
        banner: String?,
        roles: [String],
        joinedAt: String?,
        premiumSince: String?,
        deaf: Bool?,
        mute: Bool?,
        flags: Int?,
        pending: Bool?,
        permissions: String?,
        communicationDisabledUntil: String?,
        unusualDmActivityUntil: String?,
        avatarDecorationData: AvatarDecorationData?
    ) {
        self.user = user
        self.nick = nick
        self.avatar = avatar
        self.banner = banner
        self.roles = roles
        self.joinedAt = joinedAt
        self.premiumSince = premiumSince
        self.deaf = deaf
        self.mute = mute
        self.flags = flags
        self.pending = pending
        self.permissions = permissions
        self.communicationDisabledUntil = communicationDisabledUntil
        self.unusualDmActivityUntil = unusualDmActivityUntil
        self.avatarDecorationData = avatarDecorationData
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.user = try container.decodeIfPresent(DiscordUser.self, forKey: .user)
        self.nick = try container.decodeIfPresent(String.self, forKey: .nick)
        self.avatar = try container.decodeIfPresent(String.self, forKey: .avatar)
        self.banner = try container.decodeIfPresent(String.self, forKey: .banner)
        self.roles = try container.decodeIfPresent([String].self, forKey: .roles) ?? []
        self.joinedAt = try container.decodeIfPresent(String.self, forKey: .joinedAt)
        self.premiumSince = try container.decodeIfPresent(String.self, forKey: .premiumSince)
        self.deaf = try container.decodeIfPresent(Bool.self, forKey: .deaf)
        self.mute = try container.decodeIfPresent(Bool.self, forKey: .mute)
        self.flags = try container.decodeIfPresent(Int.self, forKey: .flags)
        self.pending = try container.decodeIfPresent(Bool.self, forKey: .pending)
        self.permissions = try container.decodeIfPresent(String.self, forKey: .permissions)
        self.communicationDisabledUntil = try container.decodeIfPresent(String.self, forKey: .communicationDisabledUntil)
        self.unusualDmActivityUntil = try container.decodeIfPresent(String.self, forKey: .unusualDmActivityUntil)
        self.avatarDecorationData = try container.decodeIfPresent(AvatarDecorationData.self, forKey: .avatarDecorationData)
    }
}
