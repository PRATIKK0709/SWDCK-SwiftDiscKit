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

public struct GuildMembersQuery: Sendable {
    public let limit: Int?
    public let after: String?

    public init(limit: Int? = nil, after: String? = nil) {
        self.limit = limit
        self.after = after
    }
}

public struct GuildMemberSearchQuery: Sendable {
    public let query: String
    public let limit: Int?

    public init(query: String, limit: Int? = nil) {
        self.query = query
        self.limit = limit
    }
}

public struct ModifyGuildMember: Encodable, Sendable {
    public let nick: String?
    public let roles: [String]?
    public let mute: Bool?
    public let deaf: Bool?
    public let channelId: String?
    public let communicationDisabledUntil: String?
    public let flags: Int?

    public init(
        nick: String? = nil,
        roles: [String]? = nil,
        mute: Bool? = nil,
        deaf: Bool? = nil,
        channelId: String? = nil,
        communicationDisabledUntil: String? = nil,
        flags: Int? = nil
    ) {
        self.nick = nick
        self.roles = roles
        self.mute = mute
        self.deaf = deaf
        self.channelId = channelId
        self.communicationDisabledUntil = communicationDisabledUntil
        self.flags = flags
    }
}

public struct GuildAuditLog: Codable, Sendable {
    public let auditLogEntries: [GuildAuditLogEntry]
    public let users: [DiscordUser]
    public let webhooks: [Webhook]
    public let integrations: [JSONValue]?
    public let threads: [Channel]?
    public let applicationCommands: [ApplicationCommand]?
    public let autoModerationRules: [JSONValue]?
    public let guildScheduledEvents: [JSONValue]?
}

public struct GuildAuditLogEntry: Codable, Sendable, Identifiable {
    public let id: String
    public let targetId: String?
    public let changes: [GuildAuditLogChange]?
    public let userId: String?
    public let actionType: Int
    public let options: GuildAuditLogEntryOptions?
    public let reason: String?
}

public struct GuildAuditLogChange: Codable, Sendable {
    public let newValue: JSONValue?
    public let oldValue: JSONValue?
    public let key: String
}

public struct GuildAuditLogEntryOptions: Codable, Sendable {
    public let applicationId: String?
    public let autoModerationRuleName: String?
    public let autoModerationRuleTriggerType: String?
    public let channelId: String?
    public let count: String?
    public let deleteMemberDays: String?
    public let id: String?
    public let membersRemoved: String?
    public let messageId: String?
    public let roleName: String?
    public let type: String?
    public let integrationType: String?
}

public struct GuildAuditLogQuery: Sendable {
    public let userId: String?
    public let actionType: Int?
    public let before: String?
    public let after: String?
    public let limit: Int?

    public init(
        userId: String? = nil,
        actionType: Int? = nil,
        before: String? = nil,
        after: String? = nil,
        limit: Int? = nil
    ) {
        self.userId = userId
        self.actionType = actionType
        self.before = before
        self.after = after
        self.limit = limit
    }
}

public struct GuildBan: Codable, Sendable {
    public let reason: String?
    public let user: DiscordUser
}

public struct GuildBansQuery: Sendable {
    public let limit: Int?
    public let before: String?
    public let after: String?

    public init(limit: Int? = nil, before: String? = nil, after: String? = nil) {
        self.limit = limit
        self.before = before
        self.after = after
    }
}

public struct CreateGuildBan: Encodable, Sendable {
    public let deleteMessageSeconds: Int?

    public init(deleteMessageSeconds: Int? = nil) {
        self.deleteMessageSeconds = deleteMessageSeconds
    }
}

public struct GuildPruneCountQuery: Sendable {
    public let days: Int?
    public let includeRoles: [String]?

    public init(days: Int? = nil, includeRoles: [String]? = nil) {
        self.days = days
        self.includeRoles = includeRoles
    }
}

public struct BeginGuildPrune: Encodable, Sendable {
    public let days: Int?
    public let computePruneCount: Bool?
    public let includeRoles: [String]?

    public init(days: Int? = nil, computePruneCount: Bool? = nil, includeRoles: [String]? = nil) {
        self.days = days
        self.computePruneCount = computePruneCount
        self.includeRoles = includeRoles
    }
}

public struct GuildPruneResult: Codable, Sendable {
    public let pruned: Int?
}

public struct ModifyGuild: Encodable, Sendable {
    public let name: String?
    public let verificationLevel: Int?
    public let defaultMessageNotifications: Int?
    public let explicitContentFilter: Int?
    public let afkChannelId: String?
    public let afkTimeout: Int?
    public let icon: String?
    public let ownerId: String?
    public let splash: String?
    public let discoverySplash: String?
    public let banner: String?
    public let systemChannelId: String?
    public let systemChannelFlags: Int?
    public let rulesChannelId: String?
    public let publicUpdatesChannelId: String?
    public let preferredLocale: String?
    public let features: [String]?
    public let description: String?
    public let premiumProgressBarEnabled: Bool?
    public let safetyAlertsChannelId: String?

    public init(
        name: String? = nil,
        verificationLevel: Int? = nil,
        defaultMessageNotifications: Int? = nil,
        explicitContentFilter: Int? = nil,
        afkChannelId: String? = nil,
        afkTimeout: Int? = nil,
        icon: String? = nil,
        ownerId: String? = nil,
        splash: String? = nil,
        discoverySplash: String? = nil,
        banner: String? = nil,
        systemChannelId: String? = nil,
        systemChannelFlags: Int? = nil,
        rulesChannelId: String? = nil,
        publicUpdatesChannelId: String? = nil,
        preferredLocale: String? = nil,
        features: [String]? = nil,
        description: String? = nil,
        premiumProgressBarEnabled: Bool? = nil,
        safetyAlertsChannelId: String? = nil
    ) {
        self.name = name
        self.verificationLevel = verificationLevel
        self.defaultMessageNotifications = defaultMessageNotifications
        self.explicitContentFilter = explicitContentFilter
        self.afkChannelId = afkChannelId
        self.afkTimeout = afkTimeout
        self.icon = icon
        self.ownerId = ownerId
        self.splash = splash
        self.discoverySplash = discoverySplash
        self.banner = banner
        self.systemChannelId = systemChannelId
        self.systemChannelFlags = systemChannelFlags
        self.rulesChannelId = rulesChannelId
        self.publicUpdatesChannelId = publicUpdatesChannelId
        self.preferredLocale = preferredLocale
        self.features = features
        self.description = description
        self.premiumProgressBarEnabled = premiumProgressBarEnabled
        self.safetyAlertsChannelId = safetyAlertsChannelId
    }
}

public struct ModifyGuildChannelPosition: Encodable, Sendable {
    public let id: String
    public let position: Int?
    public let lockPermissions: Bool?
    public let parentId: String?

    public init(
        id: String,
        position: Int? = nil,
        lockPermissions: Bool? = nil,
        parentId: String? = nil
    ) {
        self.id = id
        self.position = position
        self.lockPermissions = lockPermissions
        self.parentId = parentId
    }
}

public struct ModifyGuildRolePosition: Encodable, Sendable {
    public let id: String
    public let position: Int?

    public init(id: String, position: Int? = nil) {
        self.id = id
        self.position = position
    }
}
