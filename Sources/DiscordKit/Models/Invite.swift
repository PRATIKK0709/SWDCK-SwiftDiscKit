import Foundation

public struct Invite: Codable, Sendable {
    public let type: Int?
    public let code: String
    public let guild: InviteGuild?
    public let channel: InviteChannel?
    public let inviter: DiscordUser?
    public let targetType: Int?
    public let targetUser: DiscordUser?
    public let targetApplication: InviteTargetApplication?
    public let approximatePresenceCount: Int?
    public let approximateMemberCount: Int?
    public let expiresAt: String?
    public let stageInstance: InviteStageInstance?
    public let guildScheduledEvent: InviteGuildScheduledEvent?
    public let uses: Int?
    public let maxUses: Int?
    public let maxAge: Int?
    public let temporary: Bool?
    public let createdAt: String?
    public let flags: Int?
}

public struct InviteGuild: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String?
    public let splash: String?
    public let banner: String?
    public let description: String?
    public let icon: String?
    public let features: [String]?
    public let verificationLevel: Int?
    public let vanityUrlCode: String?
    public let nsfwLevel: Int?
    public let premiumSubscriptionCount: Int?
}

public struct InviteChannel: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String?
    public let type: Int?
}

public struct InviteTargetApplication: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String?
    public let icon: String?
    public let description: String?
    public let rpcOrigins: [String]?
    public let botPublic: Bool?
    public let botRequireCodeGrant: Bool?
    public let termsOfServiceUrl: String?
    public let privacyPolicyUrl: String?
    public let verifyKey: String?
    public let flags: Int?
    public let maxParticipants: Int?
}

public struct InviteStageInstance: Codable, Sendable {
    public let members: [GuildMember]?
    public let participantCount: Int?
    public let speakerCount: Int?
    public let topic: String?
}

public struct InviteGuildScheduledEvent: Codable, Sendable, Identifiable {
    public let id: String
    public let guildId: String?
    public let channelId: String?
    public let creatorId: String?
    public let name: String?
    public let description: String?
    public let scheduledStartTime: String?
    public let scheduledEndTime: String?
    public let privacyLevel: Int?
    public let status: Int?
    public let entityType: Int?
    public let entityId: String?
    public let entityMetadata: JSONValue?
    public let creator: DiscordUser?
    public let userCount: Int?
    public let image: String?
}

public struct CreateChannelInvite: Sendable {
    public let maxAge: Int?
    public let maxUses: Int?
    public let temporary: Bool?
    public let unique: Bool?
    public let targetType: Int?
    public let targetUserId: String?
    public let targetApplicationId: String?
    public let targetEventId: String?
    public let flags: Int?
    public let roleIds: [String]?
    public let targetUsersFileData: Data?
    public let targetUsersFileName: String

    public init(
        maxAge: Int? = nil,
        maxUses: Int? = nil,
        temporary: Bool? = nil,
        unique: Bool? = nil,
        targetType: Int? = nil,
        targetUserId: String? = nil,
        targetApplicationId: String? = nil,
        targetEventId: String? = nil,
        flags: Int? = nil,
        roleIds: [String]? = nil,
        targetUsersFileData: Data? = nil,
        targetUsersFileName: String = "target_users.csv"
    ) {
        self.maxAge = maxAge
        self.maxUses = maxUses
        self.temporary = temporary
        self.unique = unique
        self.targetType = targetType
        self.targetUserId = targetUserId
        self.targetApplicationId = targetApplicationId
        self.targetEventId = targetEventId
        self.flags = flags
        self.roleIds = roleIds
        self.targetUsersFileData = targetUsersFileData
        self.targetUsersFileName = targetUsersFileName
    }
}

public struct GetInviteQuery: Sendable {
    public let withCounts: Bool?
    public let withExpiration: Bool?
    public let guildScheduledEventId: String?

    public init(
        withCounts: Bool? = nil,
        withExpiration: Bool? = nil,
        guildScheduledEventId: String? = nil
    ) {
        self.withCounts = withCounts
        self.withExpiration = withExpiration
        self.guildScheduledEventId = guildScheduledEventId
    }
}

struct CreateChannelInvitePayload: Encodable {
    let maxAge: Int?
    let maxUses: Int?
    let temporary: Bool?
    let unique: Bool?
    let targetType: Int?
    let targetUserId: String?
    let targetApplicationId: String?
    let targetEventId: String?
    let flags: Int?
    let roleIds: [String]?
}
