import Foundation

public struct ApplicationCommandPermission: Codable, Sendable {
    public let id: String
    public let type: Int
    public let permission: Bool

    public init(id: String, type: Int, permission: Bool) {
        self.id = id
        self.type = type
        self.permission = permission
    }
}

public struct GuildApplicationCommandPermissions: Codable, Sendable {
    public let id: String
    public let applicationId: String
    public let guildId: String
    public let permissions: [ApplicationCommandPermission]

    public init(id: String, applicationId: String, guildId: String, permissions: [ApplicationCommandPermission]) {
        self.id = id
        self.applicationId = applicationId
        self.guildId = guildId
        self.permissions = permissions
    }
}

public struct EditGuildApplicationCommandPermissions: Encodable, Sendable {
    public let permissions: [ApplicationCommandPermission]

    public init(permissions: [ApplicationCommandPermission]) {
        self.permissions = permissions
    }
}

public struct GroupDMAddRecipient: Encodable, Sendable {
    public let accessToken: String
    public let nick: String?

    public init(accessToken: String, nick: String? = nil) {
        self.accessToken = accessToken
        self.nick = nick
    }
}

public struct FollowAnnouncementChannel: Encodable, Sendable {
    public let webhookChannelId: String

    public init(webhookChannelId: String) {
        self.webhookChannelId = webhookChannelId
    }
}

public struct FollowedChannel: Codable, Sendable {
    public let channelId: String
    public let webhookId: String
}

public struct InviteTargetUsersResult: Codable, Sendable {
    public let users: [DiscordUser]?
    public let totalCount: Int?
    public let status: String?
}

public struct InviteTargetUsersJobStatus: Codable, Sendable {
    public let status: String?
    public let totalCount: Int?
    public let processedCount: Int?
    public let failedCount: Int?
    public let completed: Bool?
}

public struct InviteTargetUsersUpdate: Encodable, Sendable {
    public let users: [String]

    public init(users: [String]) {
        self.users = users
    }
}

public struct CurrentUserGuildsQuery: Sendable {
    public let before: String?
    public let after: String?
    public let limit: Int?
    public let withCounts: Bool?

    public init(before: String? = nil, after: String? = nil, limit: Int? = nil, withCounts: Bool? = nil) {
        self.before = before
        self.after = after
        self.limit = limit
        self.withCounts = withCounts
    }
}

public struct UserGuild: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let icon: String?
    public let banner: String?
    public let owner: Bool?
    public let permissions: String?
    public let features: [String]?
    public let approximateMemberCount: Int?
    public let approximatePresenceCount: Int?
}

public struct ModifyCurrentUser: Encodable, Sendable {
    public let username: String?
    public let avatar: String?
    public let banner: String?

    public init(username: String? = nil, avatar: String? = nil, banner: String? = nil) {
        self.username = username
        self.avatar = avatar
        self.banner = banner
    }
}

public struct CreateDM: Encodable, Sendable {
    public let recipientId: String

    public init(recipientId: String) {
        self.recipientId = recipientId
    }
}

public struct UserConnection: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let type: String
    public let revoked: Bool?
    public let integrations: [JSONValue]?
    public let verified: Bool?
    public let friendSync: Bool?
    public let showActivity: Bool?
    public let twoWayLink: Bool?
    public let visibility: Int?
}

public struct ApplicationRoleConnection: Codable, Sendable {
    public let platformName: String?
    public let platformUsername: String?
    public let metadata: [String: String]?
}

public struct PutApplicationRoleConnection: Encodable, Sendable {
    public let platformName: String?
    public let platformUsername: String?
    public let metadata: [String: String]?

    public init(
        platformName: String? = nil,
        platformUsername: String? = nil,
        metadata: [String: String]? = nil
    ) {
        self.platformName = platformName
        self.platformUsername = platformUsername
        self.metadata = metadata
    }
}

public struct ApplicationRoleConnectionMetadataRecord: Codable, Sendable {
    public let type: Int
    public let key: String
    public let name: String
    public let nameLocalizations: [String: String]?
    public let description: String
    public let descriptionLocalizations: [String: String]?

    public init(
        type: Int,
        key: String,
        name: String,
        nameLocalizations: [String: String]? = nil,
        description: String,
        descriptionLocalizations: [String: String]? = nil
    ) {
        self.type = type
        self.key = key
        self.name = name
        self.nameLocalizations = nameLocalizations
        self.description = description
        self.descriptionLocalizations = descriptionLocalizations
    }
}

public struct DiscordApplication: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String?
    public let icon: String?
    public let description: String?
    public let rpcOrigins: [String]?
    public let botPublic: Bool?
    public let botRequireCodeGrant: Bool?
    public let termsOfServiceUrl: String?
    public let privacyPolicyUrl: String?
    public let owner: DiscordUser?
    public let summary: String?
    public let verifyKey: String?
    public let team: JSONValue?
    public let guildId: String?
    public let primarySkuId: String?
    public let slug: String?
    public let coverImage: String?
    public let flags: Int?
    public let tags: [String]?
    public let installParams: JSONValue?
    public let customInstallUrl: String?
    public let roleConnectionsVerificationUrl: String?
}

public struct ModifyApplication: Encodable, Sendable {
    public let customInstallUrl: String?
    public let description: String?
    public let roleConnectionsVerificationUrl: String?
    public let installParams: JSONValue?
    public let flags: Int?
    public let icon: String?
    public let coverImage: String?
    public let interactionsEndpointUrl: String?
    public let tags: [String]?

    public init(
        customInstallUrl: String? = nil,
        description: String? = nil,
        roleConnectionsVerificationUrl: String? = nil,
        installParams: JSONValue? = nil,
        flags: Int? = nil,
        icon: String? = nil,
        coverImage: String? = nil,
        interactionsEndpointUrl: String? = nil,
        tags: [String]? = nil
    ) {
        self.customInstallUrl = customInstallUrl
        self.description = description
        self.roleConnectionsVerificationUrl = roleConnectionsVerificationUrl
        self.installParams = installParams
        self.flags = flags
        self.icon = icon
        self.coverImage = coverImage
        self.interactionsEndpointUrl = interactionsEndpointUrl
        self.tags = tags
    }
}

public struct OAuth2Authorization: Codable, Sendable {
    public let application: DiscordApplication
    public let scopes: [String]
    public let expires: String?
    public let user: DiscordUser?
}

public struct VoiceRegion: Codable, Sendable {
    public let id: String
    public let name: String
    public let optimal: Bool
    public let deprecated: Bool
    public let custom: Bool
}

public struct VoiceState: Codable, Sendable {
    public let guildId: String?
    public let channelId: String?
    public let userId: String
    public let member: GuildMember?
    public let sessionId: String
    public let deaf: Bool
    public let mute: Bool
    public let selfDeaf: Bool
    public let selfMute: Bool
    public let selfStream: Bool?
    public let selfVideo: Bool
    public let suppress: Bool
    public let requestToSpeakTimestamp: String?
}

public struct ModifyCurrentUserVoiceState: Encodable, Sendable {
    public let channelId: String?
    public let suppress: Bool?
    public let requestToSpeakTimestamp: String?

    public init(channelId: String? = nil, suppress: Bool? = nil, requestToSpeakTimestamp: String? = nil) {
        self.channelId = channelId
        self.suppress = suppress
        self.requestToSpeakTimestamp = requestToSpeakTimestamp
    }
}

public struct ModifyUserVoiceState: Encodable, Sendable {
    public let channelId: String
    public let suppress: Bool?

    public init(channelId: String, suppress: Bool? = nil) {
        self.channelId = channelId
        self.suppress = suppress
    }
}

public struct VoiceServerUpdateEvent: Codable, Sendable {
    public let token: String
    public let guildId: String
    public let endpoint: String?
}

public struct GuildIntegration: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String?
    public let type: String?
    public let enabled: Bool?
    public let syncing: Bool?
    public let roleId: String?
    public let enableEmoticons: Bool?
    public let expireBehavior: Int?
    public let expireGracePeriod: Int?
    public let user: DiscordUser?
    public let account: JSONValue?
    public let syncedAt: String?
    public let subscriberCount: Int?
    public let revoked: Bool?
    public let application: JSONValue?
    public let scopes: [String]?
}

public struct ModifyCurrentGuildMember: Encodable, Sendable {
    public let nick: String?

    public init(nick: String? = nil) {
        self.nick = nick
    }
}

public struct ModifyCurrentGuildNick: Encodable, Sendable {
    public let nick: String

    public init(nick: String) {
        self.nick = nick
    }
}

public struct AddGuildMember: Encodable, Sendable {
    public let accessToken: String
    public let nick: String?
    public let roles: [String]?
    public let mute: Bool?
    public let deaf: Bool?

    public init(
        accessToken: String,
        nick: String? = nil,
        roles: [String]? = nil,
        mute: Bool? = nil,
        deaf: Bool? = nil
    ) {
        self.accessToken = accessToken
        self.nick = nick
        self.roles = roles
        self.mute = mute
        self.deaf = deaf
    }
}

public struct BulkBan: Encodable, Sendable {
    public let userIds: [String]
    public let deleteMessageSeconds: Int?

    public init(userIds: [String], deleteMessageSeconds: Int? = nil) {
        self.userIds = userIds
        self.deleteMessageSeconds = deleteMessageSeconds
    }
}

public struct BulkBanResult: Codable, Sendable {
    public let bannedUsers: [String]
    public let failedUsers: [String]
}

public struct GuildIncidentActions: Encodable, Sendable {
    public let invitesDisabledUntil: String?
    public let dmsDisabledUntil: String?

    public init(invitesDisabledUntil: String? = nil, dmsDisabledUntil: String? = nil) {
        self.invitesDisabledUntil = invitesDisabledUntil
        self.dmsDisabledUntil = dmsDisabledUntil
    }
}

public struct GuildTemplate: Codable, Sendable {
    public let code: String
    public let name: String
    public let description: String?
    public let usageCount: Int?
    public let creatorId: String?
    public let creator: DiscordUser?
    public let createdAt: String?
    public let updatedAt: String?
    public let sourceGuildId: String?
    public let serializedSourceGuild: JSONValue?
    public let isDirty: Bool?
}

public struct CreateGuildTemplate: Encodable, Sendable {
    public let name: String
    public let description: String?

    public init(name: String, description: String? = nil) {
        self.name = name
        self.description = description
    }
}

public struct ModifyGuildTemplate: Encodable, Sendable {
    public let name: String?
    public let description: String?

    public init(name: String? = nil, description: String? = nil) {
        self.name = name
        self.description = description
    }
}

public struct CreateGuildFromTemplate: Encodable, Sendable {
    public let name: String
    public let icon: String?

    public init(name: String, icon: String? = nil) {
        self.name = name
        self.icon = icon
    }
}

public struct GuildScheduledEvent: Codable, Sendable, Identifiable {
    public let id: String
    public let guildId: String?
    public let channelId: String?
    public let creatorId: String?
    public let name: String
    public let description: String?
    public let scheduledStartTime: String
    public let scheduledEndTime: String?
    public let privacyLevel: Int
    public let status: Int
    public let entityType: Int
    public let entityId: String?
    public let entityMetadata: GuildScheduledEventMetadata?
    public let creator: DiscordUser?
    public let userCount: Int?
    public let image: String?
}

public struct GuildScheduledEventMetadata: Codable, Sendable {
    public let location: String?

    public init(location: String? = nil) {
        self.location = location
    }
}

public struct CreateGuildScheduledEvent: Encodable, Sendable {
    public let channelId: String?
    public let entityMetadata: GuildScheduledEventMetadata?
    public let name: String
    public let privacyLevel: Int
    public let scheduledStartTime: String
    public let scheduledEndTime: String?
    public let description: String?
    public let entityType: Int
    public let image: String?

    public init(
        channelId: String? = nil,
        entityMetadata: GuildScheduledEventMetadata? = nil,
        name: String,
        privacyLevel: Int,
        scheduledStartTime: String,
        scheduledEndTime: String? = nil,
        description: String? = nil,
        entityType: Int,
        image: String? = nil
    ) {
        self.channelId = channelId
        self.entityMetadata = entityMetadata
        self.name = name
        self.privacyLevel = privacyLevel
        self.scheduledStartTime = scheduledStartTime
        self.scheduledEndTime = scheduledEndTime
        self.description = description
        self.entityType = entityType
        self.image = image
    }
}

public struct ModifyGuildScheduledEvent: Encodable, Sendable {
    public let channelId: String?
    public let entityMetadata: GuildScheduledEventMetadata?
    public let name: String?
    public let privacyLevel: Int?
    public let scheduledStartTime: String?
    public let scheduledEndTime: String?
    public let description: String?
    public let entityType: Int?
    public let status: Int?
    public let image: String?

    public init(
        channelId: String? = nil,
        entityMetadata: GuildScheduledEventMetadata? = nil,
        name: String? = nil,
        privacyLevel: Int? = nil,
        scheduledStartTime: String? = nil,
        scheduledEndTime: String? = nil,
        description: String? = nil,
        entityType: Int? = nil,
        status: Int? = nil,
        image: String? = nil
    ) {
        self.channelId = channelId
        self.entityMetadata = entityMetadata
        self.name = name
        self.privacyLevel = privacyLevel
        self.scheduledStartTime = scheduledStartTime
        self.scheduledEndTime = scheduledEndTime
        self.description = description
        self.entityType = entityType
        self.status = status
        self.image = image
    }
}

public struct GuildScheduledEventsQuery: Sendable {
    public let withUserCount: Bool?

    public init(withUserCount: Bool? = nil) {
        self.withUserCount = withUserCount
    }
}

public struct GuildScheduledEventUsersQuery: Sendable {
    public let limit: Int?
    public let withMember: Bool?
    public let before: String?
    public let after: String?

    public init(limit: Int? = nil, withMember: Bool? = nil, before: String? = nil, after: String? = nil) {
        self.limit = limit
        self.withMember = withMember
        self.before = before
        self.after = after
    }
}

public struct GuildScheduledEventUser: Codable, Sendable {
    public let guildScheduledEventId: String?
    public let user: DiscordUser
    public let member: GuildMember?
}

public struct StageInstance: Codable, Sendable {
    public let id: String?
    public let guildId: String
    public let channelId: String
    public let topic: String
    public let privacyLevel: Int
    public let discoverableDisabled: Bool?
    public let guildScheduledEventId: String?
}

public struct CreateStageInstance: Encodable, Sendable {
    public let channelId: String
    public let topic: String
    public let privacyLevel: Int
    public let sendStartNotification: Bool?
    public let guildScheduledEventId: String?

    public init(
        channelId: String,
        topic: String,
        privacyLevel: Int,
        sendStartNotification: Bool? = nil,
        guildScheduledEventId: String? = nil
    ) {
        self.channelId = channelId
        self.topic = topic
        self.privacyLevel = privacyLevel
        self.sendStartNotification = sendStartNotification
        self.guildScheduledEventId = guildScheduledEventId
    }
}

public struct ModifyStageInstance: Encodable, Sendable {
    public let topic: String?
    public let privacyLevel: Int?

    public init(topic: String? = nil, privacyLevel: Int? = nil) {
        self.topic = topic
        self.privacyLevel = privacyLevel
    }
}

public struct AutoModerationRule: Codable, Sendable, Identifiable {
    public let id: String
    public let guildId: String
    public let name: String
    public let creatorId: String?
    public let eventType: Int
    public let triggerType: Int
    public let triggerMetadata: AutoModerationTriggerMetadata?
    public let actions: [AutoModerationAction]
    public let enabled: Bool
    public let exemptRoles: [String]
    public let exemptChannels: [String]
}

public struct AutoModerationTriggerMetadata: Codable, Sendable {
    public let keywordFilter: [String]?
    public let regexPatterns: [String]?
    public let presets: [Int]?
    public let allowList: [String]?
    public let mentionTotalLimit: Int?
    public let mentionRaidProtectionEnabled: Bool?
}

public struct AutoModerationAction: Codable, Sendable {
    public let type: Int
    public let metadata: AutoModerationActionMetadata?

    public init(type: Int, metadata: AutoModerationActionMetadata? = nil) {
        self.type = type
        self.metadata = metadata
    }
}

public struct AutoModerationActionMetadata: Codable, Sendable {
    public let channelId: String?
    public let durationSeconds: Int?
    public let customMessage: String?

    public init(channelId: String? = nil, durationSeconds: Int? = nil, customMessage: String? = nil) {
        self.channelId = channelId
        self.durationSeconds = durationSeconds
        self.customMessage = customMessage
    }
}

public struct CreateAutoModerationRule: Encodable, Sendable {
    public let name: String
    public let eventType: Int
    public let triggerType: Int
    public let triggerMetadata: AutoModerationTriggerMetadata?
    public let actions: [AutoModerationAction]
    public let enabled: Bool?
    public let exemptRoles: [String]?
    public let exemptChannels: [String]?

    public init(
        name: String,
        eventType: Int,
        triggerType: Int,
        triggerMetadata: AutoModerationTriggerMetadata? = nil,
        actions: [AutoModerationAction],
        enabled: Bool? = nil,
        exemptRoles: [String]? = nil,
        exemptChannels: [String]? = nil
    ) {
        self.name = name
        self.eventType = eventType
        self.triggerType = triggerType
        self.triggerMetadata = triggerMetadata
        self.actions = actions
        self.enabled = enabled
        self.exemptRoles = exemptRoles
        self.exemptChannels = exemptChannels
    }
}

public struct ModifyAutoModerationRule: Encodable, Sendable {
    public let name: String?
    public let eventType: Int?
    public let triggerMetadata: AutoModerationTriggerMetadata?
    public let actions: [AutoModerationAction]?
    public let enabled: Bool?
    public let exemptRoles: [String]?
    public let exemptChannels: [String]?

    public init(
        name: String? = nil,
        eventType: Int? = nil,
        triggerMetadata: AutoModerationTriggerMetadata? = nil,
        actions: [AutoModerationAction]? = nil,
        enabled: Bool? = nil,
        exemptRoles: [String]? = nil,
        exemptChannels: [String]? = nil
    ) {
        self.name = name
        self.eventType = eventType
        self.triggerMetadata = triggerMetadata
        self.actions = actions
        self.enabled = enabled
        self.exemptRoles = exemptRoles
        self.exemptChannels = exemptChannels
    }
}

public struct GuildEmoji: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String?
    public let roles: [String]?
    public let user: DiscordUser?
    public let requireColons: Bool?
    public let managed: Bool?
    public let animated: Bool?
    public let available: Bool?
}

public struct CreateGuildEmoji: Encodable, Sendable {
    public let name: String
    public let image: String
    public let roles: [String]?

    public init(name: String, image: String, roles: [String]? = nil) {
        self.name = name
        self.image = image
        self.roles = roles
    }
}

public struct ModifyGuildEmoji: Encodable, Sendable {
    public let name: String?
    public let roles: [String]?

    public init(name: String? = nil, roles: [String]? = nil) {
        self.name = name
        self.roles = roles
    }
}

public struct ApplicationEmojisResponse: Codable, Sendable {
    public let items: [GuildEmoji]
}

public struct CreateApplicationEmoji: Encodable, Sendable {
    public let name: String
    public let image: String

    public init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}

public struct ModifyApplicationEmoji: Encodable, Sendable {
    public let name: String?

    public init(name: String? = nil) {
        self.name = name
    }
}

public struct Lobby: Codable, Sendable, Identifiable {
    public let id: String
    public let applicationId: String?
    public let capacity: Int?
    public let locked: Bool?
    public let metadata: [String: String]?
    public let members: [LobbyMember]?
    public let linkedChannelIds: [String]?
    public let secret: String?
}

public struct CreateLobby: Encodable, Sendable {
    public let capacity: Int?
    public let locked: Bool?
    public let metadata: [String: String]?

    public init(capacity: Int? = nil, locked: Bool? = nil, metadata: [String: String]? = nil) {
        self.capacity = capacity
        self.locked = locked
        self.metadata = metadata
    }
}

public struct ModifyLobby: Encodable, Sendable {
    public let capacity: Int?
    public let locked: Bool?
    public let metadata: [String: String]?

    public init(capacity: Int? = nil, locked: Bool? = nil, metadata: [String: String]? = nil) {
        self.capacity = capacity
        self.locked = locked
        self.metadata = metadata
    }
}

public struct LobbyMember: Codable, Sendable {
    public let id: String
    public let metadata: [String: String]?
}

public struct ModifyLobbyMember: Encodable, Sendable {
    public let metadata: [String: String]?

    public init(metadata: [String: String]? = nil) {
        self.metadata = metadata
    }
}

public struct LobbyChannelLinking: Encodable, Sendable {
    public let channelId: String?

    public init(channelId: String? = nil) {
        self.channelId = channelId
    }
}

public struct SoundboardSound: Codable, Sendable, Identifiable {
    public let soundId: String
    public let name: String
    public let volume: Double?
    public let emojiId: String?
    public let emojiName: String?
    public let available: Bool?
    public let guildId: String?
    public let user: DiscordUser?
    public var id: String { soundId }
}

public struct SoundboardSoundsResponse: Codable, Sendable {
    public let items: [SoundboardSound]
}

public struct CreateGuildSoundboardSound: Encodable, Sendable {
    public let name: String
    public let sound: String
    public let volume: Double?
    public let emojiId: String?
    public let emojiName: String?

    public init(
        name: String,
        sound: String,
        volume: Double? = nil,
        emojiId: String? = nil,
        emojiName: String? = nil
    ) {
        self.name = name
        self.sound = sound
        self.volume = volume
        self.emojiId = emojiId
        self.emojiName = emojiName
    }
}

public struct ModifyGuildSoundboardSound: Encodable, Sendable {
    public let name: String?
    public let volume: Double?
    public let emojiId: String?
    public let emojiName: String?

    public init(
        name: String? = nil,
        volume: Double? = nil,
        emojiId: String? = nil,
        emojiName: String? = nil
    ) {
        self.name = name
        self.volume = volume
        self.emojiId = emojiId
        self.emojiName = emojiName
    }
}

public struct SendSoundboardSound: Encodable, Sendable {
    public let soundId: String
    public let sourceGuildId: String?

    public init(soundId: String, sourceGuildId: String? = nil) {
        self.soundId = soundId
        self.sourceGuildId = sourceGuildId
    }
}

public struct PollAnswerVotersQuery: Sendable {
    public let after: String?
    public let limit: Int?

    public init(after: String? = nil, limit: Int? = nil) {
        self.after = after
        self.limit = limit
    }
}

public struct PollAnswerVotersResponse: Codable, Sendable {
    public let users: [DiscordUser]
}

public struct SKU: Codable, Sendable, Identifiable {
    public let id: String
    public let type: Int
    public let applicationId: String
    public let name: String
    public let slug: String
    public let flags: Int?
}

public struct Entitlement: Codable, Sendable, Identifiable {
    public let id: String
    public let skuId: String
    public let applicationId: String
    public let userId: String?
    public let type: Int?
    public let subscriptionId: String?
    public let promotionId: String?
    public let deleted: Bool?
    public let giftCodeFlags: Int?
    public let startsAt: String?
    public let endsAt: String?
    public let guildId: String?
    public let consumed: Bool?
}

public struct CreateTestEntitlement: Encodable, Sendable {
    public let skuId: String
    public let ownerId: String
    public let ownerType: Int

    public init(skuId: String, ownerId: String, ownerType: Int) {
        self.skuId = skuId
        self.ownerId = ownerId
        self.ownerType = ownerType
    }
}

public struct EntitlementsQuery: Sendable {
    public let userId: String?
    public let skuIds: [String]?
    public let before: String?
    public let after: String?
    public let limit: Int?
    public let guildId: String?
    public let excludeEnded: Bool?
    public let excludeDeleted: Bool?

    public init(
        userId: String? = nil,
        skuIds: [String]? = nil,
        before: String? = nil,
        after: String? = nil,
        limit: Int? = nil,
        guildId: String? = nil,
        excludeEnded: Bool? = nil,
        excludeDeleted: Bool? = nil
    ) {
        self.userId = userId
        self.skuIds = skuIds
        self.before = before
        self.after = after
        self.limit = limit
        self.guildId = guildId
        self.excludeEnded = excludeEnded
        self.excludeDeleted = excludeDeleted
    }
}

public struct Subscription: Codable, Sendable, Identifiable {
    public let id: String
    public let userId: String?
    public let skuIds: [String]?
    public let entitlementIds: [String]?
    public let currentPeriodStart: String?
    public let currentPeriodEnd: String?
    public let status: Int?
    public let canceledAt: String?
    public let country: String?
    public let renewalSkuIds: [String]?
}

public struct SkuSubscriptionsQuery: Sendable {
    public let before: String?
    public let after: String?
    public let limit: Int?
    public let userId: String?

    public init(
        before: String? = nil,
        after: String? = nil,
        limit: Int? = nil,
        userId: String? = nil
    ) {
        self.before = before
        self.after = after
        self.limit = limit
        self.userId = userId
    }
}
