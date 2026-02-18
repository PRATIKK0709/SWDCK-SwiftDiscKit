import Foundation

// MARK: - Event Handler Type Aliases

public typealias GuildHandler = @Sendable (Guild) async throws -> Void
public typealias GuildDeleteHandler = @Sendable (GuildDeleteEvent) async throws -> Void
public typealias ChannelHandler = @Sendable (Channel) async throws -> Void
public typealias GuildMemberAddHandler = @Sendable (GuildMemberAddEvent) async throws -> Void
public typealias GuildMemberRemoveHandler = @Sendable (GuildMemberRemoveEvent) async throws -> Void
public typealias GuildMemberUpdateHandler = @Sendable (GuildMemberUpdateEvent) async throws -> Void
public typealias MessageUpdateHandler = @Sendable (Message) async throws -> Void
public typealias MessageDeleteHandler = @Sendable (MessageDeleteEvent) async throws -> Void
public typealias MessageReactionAddHandler = @Sendable (MessageReactionAddEvent) async throws -> Void
public typealias MessageReactionRemoveHandler = @Sendable (MessageReactionRemoveEvent) async throws -> Void
public typealias TypingStartHandler = @Sendable (TypingStartEvent) async throws -> Void
public typealias PresenceUpdateHandler = @Sendable (PresenceUpdateEvent) async throws -> Void


// MARK: - Event Payload Structs

public struct GuildDeleteEvent: Codable, Sendable {
    public let id: String
    public let unavailable: Bool?
}

public struct GuildMemberAddEvent: Codable, Sendable {
    public let guildId: String
    public let user: DiscordUser?
    public let nick: String?
    public let roles: [String]?
    public let joinedAt: String?
    public let deaf: Bool?
    public let mute: Bool?
}

public struct GuildMemberRemoveEvent: Codable, Sendable {
    public let guildId: String
    public let user: DiscordUser
}

public struct GuildMemberUpdateEvent: Codable, Sendable {
    public let guildId: String
    public let user: DiscordUser
    public let nick: String?
    public let roles: [String]?
    public let joinedAt: String?
    public let premiumSince: String?
}

public struct MessageDeleteEvent: Codable, Sendable {
    public let id: String
    public let channelId: String
    public let guildId: String?
}

public struct MessageReactionAddEvent: Codable, Sendable {
    public let userId: String
    public let channelId: String
    public let messageId: String
    public let guildId: String?
    public let emoji: ReactionEmoji
}

public struct MessageReactionRemoveEvent: Codable, Sendable {
    public let userId: String
    public let channelId: String
    public let messageId: String
    public let guildId: String?
    public let emoji: ReactionEmoji
}

public struct ReactionEmoji: Codable, Sendable {
    public let id: String?
    public let name: String?
    public let animated: Bool?
}

public struct TypingStartEvent: Codable, Sendable {
    public let channelId: String
    public let guildId: String?
    public let userId: String
    public let timestamp: Int
}

public struct PresenceUpdateEvent: Codable, Sendable {
    public let user: PartialUser
    public let guildId: String?
    public let status: String?
    public let activities: [DiscordActivity]?
}

public struct PartialUser: Codable, Sendable {
    public let id: String
    public let username: String?
    public let discriminator: String?
    public let globalName: String?
    public let avatar: String?
}
