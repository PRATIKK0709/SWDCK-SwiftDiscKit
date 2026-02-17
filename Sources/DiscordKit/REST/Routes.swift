import Foundation

enum Routes {
    static let baseURL = "https://discord.com/api/v10"
    static let gatewayBot = "\(baseURL)/gateway/bot"

    static func channel(_ channelId: String) -> String {
        "\(baseURL)/channels/\(channelId)"
    }

    static func messages(_ channelId: String) -> String {
        "\(baseURL)/channels/\(channelId)/messages"
    }

    static func message(_ channelId: String, messageId: String) -> String {
        "\(baseURL)/channels/\(channelId)/messages/\(messageId)"
    }

    static func bulkDeleteMessages(_ channelId: String) -> String {
        "\(baseURL)/channels/\(channelId)/messages/bulk-delete"
    }

    static func guild(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)"
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

    static func guildChannels(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/channels"
    }

    static func guildMemberRole(_ guildId: String, userId: String, roleId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
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
