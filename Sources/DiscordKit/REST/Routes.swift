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

    static func channelRecipient(_ channelId: String, userId: String) -> String {
        "\(baseURL)/channels/\(channelId)/recipients/\(userId)"
    }

    static func channelFollowers(_ channelId: String) -> String {
        "\(baseURL)/channels/\(channelId)/followers"
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

    static func guildIntegrations(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/integrations"
    }

    static func guildIntegration(_ guildId: String, integrationId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/integrations/\(integrationId)"
    }

    static func guildOnboarding(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/onboarding"
    }

    static func guildPreview(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/preview"
    }

    static func guildRegions(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/regions"
    }

    static func guildRoleMemberCounts(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/roles/member-counts"
    }

    static func guildScheduledEvents(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/scheduled-events"
    }

    static func guildScheduledEvent(_ guildId: String, eventId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/scheduled-events/\(eventId)"
    }

    static func guildScheduledEventUsers(_ guildId: String, eventId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/scheduled-events/\(eventId)/users"
    }

    static func guildTemplates(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/templates"
    }

    static func guildTemplate(_ guildId: String, code: String) -> String {
        "\(baseURL)/guilds/\(guildId)/templates/\(code)"
    }

    static func guildTemplate(code: String) -> String {
        "\(baseURL)/guilds/templates/\(code)"
    }

    static func guildVanityURL(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/vanity-url"
    }

    static func guildWelcomeScreen(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/welcome-screen"
    }

    static func guildWidget(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/widget"
    }

    static func guildWidgetJSON(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/widget.json"
    }

    static func guildWidgetPNG(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/widget.png"
    }

    static func guildBulkBan(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/bulk-ban"
    }

    static func guildIncidentActions(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/incident-actions"
    }

    static func guildMemberMe(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/members/@me"
    }

    static func guildMemberNickMe(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/members/@me/nick"
    }

    static func guildAutoModerationRules(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/auto-moderation/rules"
    }

    static func guildAutoModerationRule(_ guildId: String, ruleId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
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

    static func inviteTargetUsers(_ code: String) -> String {
        "\(baseURL)/invites/\(code)/target-users"
    }

    static func inviteTargetUsersJobStatus(_ code: String) -> String {
        "\(baseURL)/invites/\(code)/target-users/job-status"
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

    static func webhookGithub(_ webhookId: String, token: String) -> String {
        "\(baseURL)/webhooks/\(webhookId)/\(token)/github"
    }

    static func webhookSlack(_ webhookId: String, token: String) -> String {
        "\(baseURL)/webhooks/\(webhookId)/\(token)/slack"
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

    static func guildCommandPermissions(_ applicationId: String, guildId: String) -> String {
        "\(baseURL)/applications/\(applicationId)/guilds/\(guildId)/commands/permissions"
    }

    static func guildCommandPermissions(_ applicationId: String, guildId: String, commandId: String) -> String {
        "\(baseURL)/applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
    }

    static func currentApplication() -> String {
        "\(baseURL)/applications/@me"
    }

    static func application(_ applicationId: String) -> String {
        "\(baseURL)/applications/\(applicationId)"
    }

    static func applicationActivityInstance(_ applicationId: String, instanceId: String) -> String {
        "\(baseURL)/applications/\(applicationId)/activity-instances/\(instanceId)"
    }

    static func applicationRoleConnectionMetadata(_ applicationId: String) -> String {
        "\(baseURL)/applications/\(applicationId)/role-connections/metadata"
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

    static func currentUserGuilds() -> String {
        "\(baseURL)/users/@me/guilds"
    }

    static func currentUserGuild(_ guildId: String) -> String {
        "\(baseURL)/users/@me/guilds/\(guildId)"
    }

    static func currentUserGuildMember(_ guildId: String) -> String {
        "\(baseURL)/users/@me/guilds/\(guildId)/member"
    }

    static func currentUserChannels() -> String {
        "\(baseURL)/users/@me/channels"
    }

    static func currentUserConnections() -> String {
        "\(baseURL)/users/@me/connections"
    }

    static func currentUserApplicationRoleConnection(_ applicationId: String) -> String {
        "\(baseURL)/users/@me/applications/\(applicationId)/role-connection"
    }

    static func guildVoiceStateMe(_ guildId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/voice-states/@me"
    }

    static func guildVoiceState(_ guildId: String, userId: String) -> String {
        "\(baseURL)/guilds/\(guildId)/voice-states/\(userId)"
    }

    static func voiceRegions() -> String {
        "\(baseURL)/voice/regions"
    }

    static func stageInstances() -> String {
        "\(baseURL)/stage-instances"
    }

    static func stageInstance(_ channelId: String) -> String {
        "\(baseURL)/stage-instances/\(channelId)"
    }

    static func oauth2CurrentAuthorization() -> String {
        "\(baseURL)/oauth2/@me"
    }

    static func oauth2CurrentApplication() -> String {
        "\(baseURL)/oauth2/applications/@me"
    }
}
