import Foundation

enum Routes {
    static let baseURL = "https://discord.com/api/v10"
    static let gateway = "\(baseURL)/gateway"
    static let gatewayBot = "\(baseURL)/gateway/bot"

    static func channel(_ channelId: String) -> String {
        "\(baseURL)/channels/\(channelId)"
    }

    static func channelWebhooks(_ channelId: String) -> String {
        "\(baseURL)/channels/\(channelId)/webhooks"
    }

    static func messages(_ channelId: String) -> String {
        "\(baseURL)/channels/\(channelId)/messages"
    }

    static func channelInvites(_ channelId: String) -> String {
        "\(baseURL)/channels/\(channelId)/invites"
    }

    static func typing(_ channelId: String) -> String {
        "\(baseURL)/channels/\(channelId)/typing"
    }

    static func messagePins(_ channelId: String) -> String {
        "\(baseURL)/channels/\(channelId)/messages/pins"
    }

    static func pins(_ channelId: String) -> String {
        "\(baseURL)/channels/\(channelId)/pins"
    }

    static func messagePin(_ channelId: String, messageId: String) -> String {
        "\(baseURL)/channels/\(channelId)/messages/pins/\(messageId)"
    }

    static func pin(_ channelId: String, messageId: String) -> String {
        "\(baseURL)/channels/\(channelId)/pins/\(messageId)"
    }

    static func message(_ channelId: String, messageId: String) -> String {
        "\(baseURL)/channels/\(channelId)/messages/\(messageId)"
    }

    static func messageCrosspost(_ channelId: String, messageId: String) -> String {
        "\(baseURL)/channels/\(channelId)/messages/\(messageId)/crosspost"
    }

    static func messageThread(_ channelId: String, messageId: String) -> String {
        "\(baseURL)/channels/\(channelId)/messages/\(messageId)/threads"
    }

    static func messageReactionMe(_ channelId: String, messageId: String, emoji: String) -> String {
        "\(baseURL)/channels/\(channelId)/messages/\(messageId)/reactions/\(emoji)/@me"
    }

    static func messageReactions(_ channelId: String, messageId: String, emoji: String) -> String {
        "\(baseURL)/channels/\(channelId)/messages/\(messageId)/reactions/\(emoji)"
    }

    static func messageReactionUser(_ channelId: String, messageId: String, emoji: String, userId: String) -> String {
        "\(baseURL)/channels/\(channelId)/messages/\(messageId)/reactions/\(emoji)/\(userId)"
    }

    static func messageReactions(_ channelId: String, messageId: String) -> String {
        "\(baseURL)/channels/\(channelId)/messages/\(messageId)/reactions"
    }

    static func bulkDeleteMessages(_ channelId: String) -> String {
        "\(baseURL)/channels/\(channelId)/messages/bulk-delete"
    }

    static func channelThreads(_ channelId: String) -> String {
        "\(baseURL)/channels/\(channelId)/threads"
    }

    static func channelPermission(_ channelId: String, overwriteId: String) -> String {
        "\(baseURL)/channels/\(channelId)/permissions/\(overwriteId)"
    }

    static func channelArchivedPublicThreads(_ channelId: String) -> String {
        "\(baseURL)/channels/\(channelId)/threads/archived/public"
    }

    static func channelArchivedPrivateThreads(_ channelId: String) -> String {
        "\(baseURL)/channels/\(channelId)/threads/archived/private"
    }

    static func channelJoinedPrivateArchivedThreads(_ channelId: String) -> String {
        "\(baseURL)/channels/\(channelId)/users/@me/threads/archived/private"
    }

    static func threadMembers(_ channelId: String) -> String {
        "\(baseURL)/channels/\(channelId)/thread-members"
    }

    static func threadMember(_ channelId: String, userId: String) -> String {
        "\(baseURL)/channels/\(channelId)/thread-members/\(userId)"
    }

    static func threadMemberMe(_ channelId: String) -> String {
        "\(baseURL)/channels/\(channelId)/thread-members/@me"
    }

    static func guild(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)"
    }

    static func guildAuditLogs(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/audit-logs"
    }

    static func guildBans(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/bans"
    }

    static func guildBan(_ guildId: String, userId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/bans/\(userId)"
    }

    static func guildWebhooks(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/webhooks"
    }

    static func guildInvites(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/invites"
    }

    static func guildMember(_ guildId: String, userId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/members/\(userId)"
    }

    static func guildMembers(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/members"
    }

    static func guildMembersSearch(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/members/search"
    }

    static func guildRoles(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/roles"
    }

    static func guildRole(_ guildId: String, roleId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/roles/\(roleId)"
    }

    static func guildChannels(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/channels"
    }

    static func guildPrune(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/prune"
    }

    static func guildActiveThreads(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/threads/active"
    }

    static func guildMemberRole(_ guildId: String, userId: String, roleId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
    }

    static func invite(_ code: String) -> String {
        "\(baseURL)/invites/\(code)"
    }

    static func webhook(_ webhookId: String) -> String {
        "\(baseURL)/webhooks/\(webhookId)"
    }

    static func webhook(_ webhookId: String, token: String) -> String {
        "\(baseURL)/webhooks/\(webhookId)/\(token)"
    }

    static func webhookMessage(_ webhookId: String, token: String, messageId: String) -> String {
        "\(baseURL)/webhooks/\(webhookId)/\(token)/messages/\(messageId)"
    }

    static func globalCommands(_ applicationId: String) -> String {
        "\(baseURL)/applications/\(applicationId)/commands"
    }

    static func globalCommand(_ applicationId: String, commandId: String) -> String {
        "\(baseURL)/applications/\(applicationId)/commands/\(commandId)"
    }

    static func guildCommands(_ applicationId: String, guildId: String) -> String {
        "\(baseURL)/applications/\(applicationId)/guilds/\(guildId)/commands"
    }

    static func guildCommand(_ applicationId: String, guildId: String, commandId: String) -> String {
        "\(baseURL)/applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
    }

    static func interactionResponse(_ interactionId: String, token: String) -> String {
        "\(baseURL)/interactions/\(interactionId)/\(token)/callback"
    }

    static func originalInteractionResponse(_ applicationId: String, token: String) -> String {
        "\(baseURL)/webhooks/\(applicationId)/\(token)/messages/@original"
    }

    static func followupMessage(_ applicationId: String, token: String) -> String {
        "\(baseURL)/webhooks/\(applicationId)/\(token)"
    }

    static func followupMessage(_ applicationId: String, token: String, messageId: String) -> String {
        "\(baseURL)/webhooks/\(applicationId)/\(token)/messages/\(messageId)"
    }

    static let currentUser = "\(baseURL)/users/@me"

    static func user(_ userId: String) -> String {
        "\(baseURL)/users/\(userId)"
    }
}
