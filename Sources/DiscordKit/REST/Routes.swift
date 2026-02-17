import Foundation

enum Routes {
    static let baseURL = "https://discord.com/api/v10"

    static func channel(_ channelId: String) -> String {
        "\(baseURL)/channels/\(channelId)"
    }

    static func messages(_ channelId: String) -> String {
        "\(baseURL)/channels/\(channelId)/messages"
    }

    static func message(_ channelId: String, messageId: String) -> String {
        "\(baseURL)/channels/\(channelId)/messages/\(messageId)"
    }

    static func guild(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)"
    }

    static func guildMember(_ guildId: String, userId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/members/\(userId)"
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

    static func interactionResponse(_ interactionId: String, token: String) -> String {
        "\(baseURL)/interactions/\(interactionId)/\(token)/callback"
    }

    static func originalInteractionResponse(_ applicationId: String, token: String) -> String {
        "\(baseURL)/webhooks/\(applicationId)/\(token)/messages/@original"
    }

    static func followupMessage(_ applicationId: String, token: String) -> String {
        "\(baseURL)/webhooks/\(applicationId)/\(token)"
    }

    static let currentUser = "\(baseURL)/users/@me"

    static func user(_ userId: String) -> String {
        "\(baseURL)/users/\(userId)"
    }
}
