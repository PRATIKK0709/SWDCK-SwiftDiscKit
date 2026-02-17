import Foundation

public struct ArchivedThreadsResponse: Codable, Sendable {
    public var threads: [Channel]
    public let members: [ChannelThreadMember]
    public let hasMore: Bool
}

public struct ArchivedThreadsQuery: Sendable {
    public let before: String?
    public let limit: Int?

    public init(before: String? = nil, limit: Int? = nil) {
        self.before = before
        self.limit = limit
    }
}

public struct ThreadMembersQuery: Sendable {
    public let withMember: Bool?
    public let after: String?
    public let limit: Int?

    public init(withMember: Bool? = nil, after: String? = nil, limit: Int? = nil) {
        self.withMember = withMember
        self.after = after
        self.limit = limit
    }
}

public struct CreateGuildChannel: Encodable, Sendable {
    public let name: String
    public let type: Int?
    public let topic: String?
    public let bitrate: Int?
    public let userLimit: Int?
    public let rateLimitPerUser: Int?
    public let position: Int?
    public let permissionOverwrites: [ChannelPermissionOverwrite]?
    public let parentId: String?
    public let nsfw: Bool?
    public let rtcRegion: String?
    public let videoQualityMode: Int?
    public let defaultAutoArchiveDuration: Int?
    public let defaultReactionEmoji: ChannelDefaultReactionEmoji?
    public let availableTags: [ChannelForumTag]?
    public let defaultSortOrder: Int?
    public let defaultForumLayout: Int?
    public let defaultThreadRateLimitPerUser: Int?

    public init(
        name: String,
        type: Int? = nil,
        topic: String? = nil,
        bitrate: Int? = nil,
        userLimit: Int? = nil,
        rateLimitPerUser: Int? = nil,
        position: Int? = nil,
        permissionOverwrites: [ChannelPermissionOverwrite]? = nil,
        parentId: String? = nil,
        nsfw: Bool? = nil,
        rtcRegion: String? = nil,
        videoQualityMode: Int? = nil,
        defaultAutoArchiveDuration: Int? = nil,
        defaultReactionEmoji: ChannelDefaultReactionEmoji? = nil,
        availableTags: [ChannelForumTag]? = nil,
        defaultSortOrder: Int? = nil,
        defaultForumLayout: Int? = nil,
        defaultThreadRateLimitPerUser: Int? = nil
    ) {
        self.name = name
        self.type = type
        self.topic = topic
        self.bitrate = bitrate
        self.userLimit = userLimit
        self.rateLimitPerUser = rateLimitPerUser
        self.position = position
        self.permissionOverwrites = permissionOverwrites
        self.parentId = parentId
        self.nsfw = nsfw
        self.rtcRegion = rtcRegion
        self.videoQualityMode = videoQualityMode
        self.defaultAutoArchiveDuration = defaultAutoArchiveDuration
        self.defaultReactionEmoji = defaultReactionEmoji
        self.availableTags = availableTags
        self.defaultSortOrder = defaultSortOrder
        self.defaultForumLayout = defaultForumLayout
        self.defaultThreadRateLimitPerUser = defaultThreadRateLimitPerUser
    }
}

public struct ModifyChannel: Encodable, Sendable {
    public let name: String?
    public let type: Int?
    public let position: Int?
    public let topic: String?
    public let nsfw: Bool?
    public let rateLimitPerUser: Int?
    public let bitrate: Int?
    public let userLimit: Int?
    public let permissionOverwrites: [ChannelPermissionOverwrite]?
    public let parentId: String?
    public let rtcRegion: String?
    public let videoQualityMode: Int?
    public let defaultAutoArchiveDuration: Int?
    public let flags: Int?
    public let availableTags: [ChannelForumTag]?
    public let defaultReactionEmoji: ChannelDefaultReactionEmoji?
    public let defaultThreadRateLimitPerUser: Int?
    public let defaultSortOrder: Int?
    public let defaultForumLayout: Int?
    public let archived: Bool?
    public let autoArchiveDuration: Int?
    public let locked: Bool?
    public let invitable: Bool?
    public let appliedTags: [String]?

    public init(
        name: String? = nil,
        type: Int? = nil,
        position: Int? = nil,
        topic: String? = nil,
        nsfw: Bool? = nil,
        rateLimitPerUser: Int? = nil,
        bitrate: Int? = nil,
        userLimit: Int? = nil,
        permissionOverwrites: [ChannelPermissionOverwrite]? = nil,
        parentId: String? = nil,
        rtcRegion: String? = nil,
        videoQualityMode: Int? = nil,
        defaultAutoArchiveDuration: Int? = nil,
        flags: Int? = nil,
        availableTags: [ChannelForumTag]? = nil,
        defaultReactionEmoji: ChannelDefaultReactionEmoji? = nil,
        defaultThreadRateLimitPerUser: Int? = nil,
        defaultSortOrder: Int? = nil,
        defaultForumLayout: Int? = nil,
        archived: Bool? = nil,
        autoArchiveDuration: Int? = nil,
        locked: Bool? = nil,
        invitable: Bool? = nil,
        appliedTags: [String]? = nil
    ) {
        self.name = name
        self.type = type
        self.position = position
        self.topic = topic
        self.nsfw = nsfw
        self.rateLimitPerUser = rateLimitPerUser
        self.bitrate = bitrate
        self.userLimit = userLimit
        self.permissionOverwrites = permissionOverwrites
        self.parentId = parentId
        self.rtcRegion = rtcRegion
        self.videoQualityMode = videoQualityMode
        self.defaultAutoArchiveDuration = defaultAutoArchiveDuration
        self.flags = flags
        self.availableTags = availableTags
        self.defaultReactionEmoji = defaultReactionEmoji
        self.defaultThreadRateLimitPerUser = defaultThreadRateLimitPerUser
        self.defaultSortOrder = defaultSortOrder
        self.defaultForumLayout = defaultForumLayout
        self.archived = archived
        self.autoArchiveDuration = autoArchiveDuration
        self.locked = locked
        self.invitable = invitable
        self.appliedTags = appliedTags
    }
}

public struct StartThreadFromMessage: Encodable, Sendable {
    public let name: String
    public let autoArchiveDuration: Int?
    public let rateLimitPerUser: Int?

    public init(name: String, autoArchiveDuration: Int? = nil, rateLimitPerUser: Int? = nil) {
        self.name = name
        self.autoArchiveDuration = autoArchiveDuration
        self.rateLimitPerUser = rateLimitPerUser
    }
}

public struct StartThreadWithoutMessage: Encodable, Sendable {
    public let name: String
    public let autoArchiveDuration: Int?
    public let type: Int?
    public let invitable: Bool?
    public let rateLimitPerUser: Int?

    public init(
        name: String,
        autoArchiveDuration: Int? = nil,
        type: Int? = nil,
        invitable: Bool? = nil,
        rateLimitPerUser: Int? = nil
    ) {
        self.name = name
        self.autoArchiveDuration = autoArchiveDuration
        self.type = type
        self.invitable = invitable
        self.rateLimitPerUser = rateLimitPerUser
    }
}
