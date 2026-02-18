# Discord API Endpoint Coverage

This file lists Discord HTTP endpoints from the official docs and tracks SwiftDiscKit coverage.

- Source docs: https://github.com/discord/discord-api-docs
- Source commit: `df79d92`
- Extracted on: `2026-02-17`
- Verified against current SwiftDiscKit implementation on: `2026-02-18`
- Endpoint coverage audit refreshed on: `2026-02-18` (cross-checked with `Routes.swift` + `RESTClient.swift`)
- Scope: all `<Route method="...">...</Route>` entries under `developers/**` excluding `developers/change-log.mdx`

## Summary

- Total documented endpoints in scope: **219**
- Implemented in SwiftDiscKit: **186**
- Remaining: **33**

## Implemented Endpoints (Highlights)

Full authoritative status for all 219 endpoints is in the matrix below.

| Method | Endpoint | SwiftDiscKit Mapping |
|---|---|---|
| `POST` | `/applications/{application.id}/commands` | `RESTClient.createGlobalCommand / createSlashCommand` |
| `POST` | `/applications/{application.id}/guilds/{guild.id}/commands` | `RESTClient.createGuildCommand` |
| `PUT` | `/applications/{application.id}/commands` | `RESTClient.bulkOverwriteGlobalCommands` |
| `PUT` | `/applications/{application.id}/guilds/{guild.id}/commands` | `RESTClient.bulkOverwriteGuildCommands` |
| `GET` | `/gateway` | `RESTClient.getGateway` |
| `GET` | `/gateway/bot` | `RESTClient.getGatewayBot` |
| `GET` | `/applications/{application.id}/commands` | `RESTClient.getGlobalCommands` |
| `GET` | `/applications/{application.id}/commands/{command.id}` | `RESTClient.getGlobalCommand` |
| `GET` | `/applications/{application.id}/guilds/{guild.id}/commands` | `RESTClient.getGuildCommands` |
| `GET` | `/applications/{application.id}/guilds/{guild.id}/commands/{command.id}` | `RESTClient.getGuildCommand` |
| `PATCH` | `/applications/{application.id}/commands/{command.id}` | `RESTClient.editGlobalCommand` |
| `PATCH` | `/applications/{application.id}/guilds/{guild.id}/commands/{command.id}` | `RESTClient.editGuildCommand` |
| `DELETE` | `/applications/{application.id}/commands/{command.id}` | `RESTClient.deleteGlobalCommand` |
| `DELETE` | `/applications/{application.id}/guilds/{guild.id}/commands/{command.id}` | `RESTClient.deleteGuildCommand` |
| `DELETE` | `/webhooks/{application.id}/{interaction.token}/messages/{message.id}` | `RESTClient.deleteFollowupMessage` |
| `DELETE` | `/webhooks/{application.id}/{interaction.token}/messages/@original` | `RESTClient.deleteOriginalInteractionResponse` |
| `GET` | `/webhooks/{application.id}/{interaction.token}/messages/{message.id}` | `RESTClient.getFollowupMessage` |
| `GET` | `/webhooks/{application.id}/{interaction.token}/messages/@original` | `RESTClient.getOriginalInteractionResponse` |
| `PATCH` | `/webhooks/{application.id}/{interaction.token}/messages/@original` | `RESTClient.editInteractionResponse` |
| `PATCH` | `/webhooks/{application.id}/{interaction.token}/messages/{message.id}` | `RESTClient.editFollowupMessage` |
| `POST` | `/interactions/{interaction.id}/{interaction.token}/callback` | `RESTClient.createInteractionResponse` |
| `POST` | `/webhooks/{application.id}/{interaction.token}` | `RESTClient.createFollowup` |
| `GET` | `/channels/{channel.id}` | `RESTClient.getChannel` |
| `PATCH` | `/channels/{channel.id}` | `RESTClient.modifyChannel` |
| `DELETE` | `/channels/{channel.id}` | `RESTClient.deleteChannel` |
| `PUT` | `/channels/{channel.id}/permissions/{overwrite.id}` | `RESTClient.editChannelPermission` |
| `DELETE` | `/channels/{channel.id}/permissions/{overwrite.id}` | `RESTClient.deleteChannelPermission` |
| `GET` | `/channels/{channel.id}/invites` | `RESTClient.getChannelInvites` |
| `GET` | `/channels/{channel.id}/webhooks` | `RESTClient.getChannelWebhooks` |
| `GET` | `/channels/{channel.id}/thread-members` | `RESTClient.getThreadMembers` |
| `GET` | `/channels/{channel.id}/thread-members/{user.id}` | `RESTClient.getThreadMember` |
| `GET` | `/channels/{channel.id}/threads/archived/private` | `RESTClient.getPrivateArchivedThreads` |
| `GET` | `/channels/{channel.id}/threads/archived/public` | `RESTClient.getPublicArchivedThreads` |
| `GET` | `/channels/{channel.id}/users/@me/threads/archived/private` | `RESTClient.getJoinedPrivateArchivedThreads` |
| `POST` | `/channels/{channel.id}/invites` | `RESTClient.createChannelInvite` |
| `POST` | `/channels/{channel.id}/messages/{message.id}/threads` | `RESTClient.startThreadFromMessage` |
| `POST` | `/channels/{channel.id}/threads` | `RESTClient.startThreadWithoutMessage` |
| `POST` | `/channels/{channel.id}/webhooks` | `RESTClient.createWebhook` |
| `POST` | `/channels/{channel.id}/typing` | `RESTClient.triggerTyping` |
| `PUT` | `/channels/{channel.id}/thread-members/@me` | `RESTClient.joinThread` |
| `PUT` | `/channels/{channel.id}/thread-members/{user.id}` | `RESTClient.addThreadMember` |
| `DELETE` | `/channels/{channel.id}/thread-members/@me` | `RESTClient.leaveThread` |
| `GET` | `/guilds/{guild.id}` | `RESTClient.getGuild` |
| `PATCH` | `/guilds/{guild.id}` | `RESTClient.modifyGuild` |
| `GET` | `/guilds/{guild.id}/audit-logs` | `RESTClient.getGuildAuditLog` |
| `GET` | `/guilds/{guild.id}/bans` | `RESTClient.getGuildBans` |
| `GET` | `/guilds/{guild.id}/bans/{user.id}` | `RESTClient.getGuildBan` |
| `PUT` | `/guilds/{guild.id}/bans/{user.id}` | `RESTClient.createGuildBan` |
| `DELETE` | `/guilds/{guild.id}/bans/{user.id}` | `RESTClient.deleteGuildBan` |
| `GET` | `/guilds/{guild.id}/channels` | `RESTClient.getGuildChannels` |
| `PATCH` | `/guilds/{guild.id}/channels` | `RESTClient.modifyGuildChannelPositions` |
| `POST` | `/guilds/{guild.id}/channels` | `RESTClient.createGuildChannel` |
| `GET` | `/guilds/{guild.id}/invites` | `RESTClient.getGuildInvites` |
| `GET` | `/guilds/{guild.id}/members` | `RESTClient.getGuildMembers` |
| `GET` | `/guilds/{guild.id}/members/search` | `RESTClient.searchGuildMembers` |
| `GET` | `/guilds/{guild.id}/members/{user.id}` | `RESTClient.getGuildMember` |
| `GET` | `/guilds/{guild.id}/prune` | `RESTClient.getGuildPruneCount` |
| `POST` | `/guilds/{guild.id}/prune` | `RESTClient.beginGuildPrune` |
| `GET` | `/guilds/{guild.id}/roles` | `RESTClient.getGuildRoles` |
| `PATCH` | `/guilds/{guild.id}/roles` | `RESTClient.modifyGuildRolePositions` |
| `GET` | `/guilds/{guild.id}/roles/{role.id}` | `RESTClient.getGuildRole` |
| `GET` | `/guilds/{guild.id}/threads/active` | `RESTClient.getActiveGuildThreads` |
| `GET` | `/guilds/{guild.id}/webhooks` | `RESTClient.getGuildWebhooks` |
| `PATCH` | `/guilds/{guild.id}/members/{user.id}` | `RESTClient.modifyGuildMember` |
| `PATCH` | `/guilds/{guild.id}/roles/{role.id}` | `RESTClient.modifyGuildRole` |
| `PUT` | `/guilds/{guild.id}/members/{user.id}/roles/{role.id}` | `RESTClient.addGuildMemberRole` |
| `DELETE` | `/guilds/{guild.id}/members/{user.id}/roles/{role.id}` | `RESTClient.removeGuildMemberRole` |
| `DELETE` | `/guilds/{guild.id}/roles/{role.id}` | `RESTClient.deleteGuildRole` |
| `POST` | `/guilds/{guild.id}/roles` | `RESTClient.createGuildRole` |
| `DELETE` | `/channels/{channel.id}/messages/{message.id}` | `RESTClient.deleteMessage` |
| `DELETE` | `/channels/{channel.id}/messages/{message.id}/reactions` | `RESTClient.deleteAllReactions` |
| `DELETE` | `/channels/{channel.id}/messages/{message.id}/reactions/{emoji.id}` | `RESTClient.deleteAllReactionsForEmoji` |
| `DELETE` | `/channels/{channel.id}/messages/{message.id}/reactions/{emoji.id}/@me` | `RESTClient.deleteOwnReaction` |
| `DELETE` | `/channels/{channel.id}/messages/{message.id}/reactions/{emoji.id}/{user.id}` | `RESTClient.deleteUserReaction` |
| `GET` | `/channels/{channel.id}/messages` | `RESTClient.getMessages` |
| `GET` | `/channels/{channel.id}/messages/pins` | `RESTClient.getMessagePins` |
| `GET` | `/channels/{channel.id}/messages/{message.id}` | `RESTClient.getMessage` |
| `GET` | `/channels/{channel.id}/messages/{message.id}/reactions/{emoji.id}` | `RESTClient.getReactions` |
| `GET` | `/channels/{channel.id}/pins` | `RESTClient.getPins` |
| `PATCH` | `/channels/{channel.id}/messages/{message.id}` | `RESTClient.editMessage` |
| `POST` | `/channels/{channel.id}/messages` | `RESTClient.sendMessage / sendComponentsV2Message` |
| `POST` | `/channels/{channel.id}/messages/bulk-delete` | `RESTClient.bulkDeleteMessages` |
| `POST` | `/channels/{channel.id}/messages/{message.id}/crosspost` | `RESTClient.crosspostMessage` |
| `PUT` | `/channels/{channel.id}/messages/pins/{message.id}` | `RESTClient.pinMessage` |
| `PUT` | `/channels/{channel.id}/messages/{message.id}/reactions/{emoji.id}/@me` | `RESTClient.createReaction` |
| `PUT` | `/channels/{channel.id}/pins/{message.id}` | `RESTClient.pin` |
| `DELETE` | `/channels/{channel.id}/messages/pins/{message.id}` | `RESTClient.unpinMessage` |
| `DELETE` | `/channels/{channel.id}/pins/{message.id}` | `RESTClient.unpin` |
| `DELETE` | `/invites/{invite.code}` | `RESTClient.deleteInvite` |
| `GET` | `/invites/{invite.code}` | `RESTClient.getInvite` |
| `DELETE` | `/webhooks/{webhook.id}` | `RESTClient.deleteWebhook(webhookId:)` |
| `DELETE` | `/webhooks/{webhook.id}/{webhook.token}` | `RESTClient.deleteWebhook(webhookId:token:)` |
| `DELETE` | `/webhooks/{webhook.id}/{webhook.token}/messages/{message.id}` | `RESTClient.deleteWebhookMessage` |
| `GET` | `/webhooks/{webhook.id}` | `RESTClient.getWebhook(webhookId:)` |
| `GET` | `/webhooks/{webhook.id}/{webhook.token}` | `RESTClient.getWebhook(webhookId:token:)` |
| `GET` | `/webhooks/{webhook.id}/{webhook.token}/messages/{message.id}` | `RESTClient.getWebhookMessage` |
| `PATCH` | `/webhooks/{webhook.id}` | `RESTClient.modifyWebhook(webhookId:modify:)` |
| `PATCH` | `/webhooks/{webhook.id}/{webhook.token}` | `RESTClient.modifyWebhook(webhookId:token:modify:)` |
| `PATCH` | `/webhooks/{webhook.id}/{webhook.token}/messages/{message.id}` | `RESTClient.editWebhookMessage` |
| `POST` | `/webhooks/{webhook.id}/{webhook.token}` | `RESTClient.executeWebhook` |
| `GET` | `/users/@me` | `RESTClient.getCurrentUser` |
| `GET` | `/users/{user.id}` | `RESTClient.getUser` |

## Full Endpoint Matrix

| Status | Method | Endpoint | Source | SwiftDiscKit Mapping |
|---|---|---|---|---|
| Implemented | `GET` | `/gateway` | `developers/events/gateway.mdx` | RESTClient.getGateway |
| Implemented | `GET` | `/gateway/bot` | `developers/events/gateway.mdx` | RESTClient.getGatewayBot |
| Implemented | `DELETE` | `/applications/{application.id}/commands/{command.id}` | `developers/interactions/application-commands.mdx` | RESTClient.deleteGlobalCommand |
| Implemented | `DELETE` | `/applications/{application.id}/guilds/{guild.id}/commands/{command.id}` | `developers/interactions/application-commands.mdx` | RESTClient.deleteGuildCommand |
| Implemented | `GET` | `/applications/{application.id}/commands` | `developers/interactions/application-commands.mdx` | RESTClient.getGlobalCommands |
| Implemented | `GET` | `/applications/{application.id}/commands/{command.id}` | `developers/interactions/application-commands.mdx` | RESTClient.getGlobalCommand |
| Implemented | `GET` | `/applications/{application.id}/guilds/{guild.id}/commands` | `developers/interactions/application-commands.mdx` | RESTClient.getGuildCommands |
| Implemented | `GET` | `/applications/{application.id}/guilds/{guild.id}/commands/permissions` | `developers/interactions/application-commands.mdx` | RESTClient.getGuildCommandPermissions |
| Implemented | `GET` | `/applications/{application.id}/guilds/{guild.id}/commands/{command.id}` | `developers/interactions/application-commands.mdx` | RESTClient.getGuildCommand |
| Implemented | `GET` | `/applications/{application.id}/guilds/{guild.id}/commands/{command.id}/permissions` | `developers/interactions/application-commands.mdx` | RESTClient.getCommandPermissions |
| Implemented | `PATCH` | `/applications/{application.id}/commands/{command.id}` | `developers/interactions/application-commands.mdx` | RESTClient.editGlobalCommand |
| Implemented | `PATCH` | `/applications/{application.id}/guilds/{guild.id}/commands/{command.id}` | `developers/interactions/application-commands.mdx` | RESTClient.editGuildCommand |
| Implemented | `POST` | `/applications/{application.id}/commands` | `developers/interactions/application-commands.mdx` | RESTClient.createGlobalCommand / createSlashCommand |
| Implemented | `POST` | `/applications/{application.id}/guilds/{guild.id}/commands` | `developers/interactions/application-commands.mdx` | RESTClient.createGuildCommand |
| Implemented | `PUT` | `/applications/{application.id}/commands` | `developers/interactions/application-commands.mdx` | RESTClient.bulkOverwriteGlobalCommands |
| Implemented | `PUT` | `/applications/{application.id}/guilds/{guild.id}/commands` | `developers/interactions/application-commands.mdx` | RESTClient.bulkOverwriteGuildCommands |
| Implemented | `PUT` | `/applications/{application.id}/guilds/{guild.id}/commands/permissions` | `developers/interactions/application-commands.mdx` | RESTClient.bulkOverwriteGuildCommandPermissions |
| Implemented | `PUT` | `/applications/{application.id}/guilds/{guild.id}/commands/{command.id}/permissions` | `developers/interactions/application-commands.mdx` | RESTClient.setGuildCommandPermissions |
| Implemented | `DELETE` | `/webhooks/{application.id}/{interaction.token}/messages/@original` | `developers/interactions/receiving-and-responding.mdx` | RESTClient.deleteOriginalInteractionResponse |
| Implemented | `DELETE` | `/webhooks/{application.id}/{interaction.token}/messages/{message.id}` | `developers/interactions/receiving-and-responding.mdx` | RESTClient.deleteFollowupMessage |
| Implemented | `GET` | `/webhooks/{application.id}/{interaction.token}/messages/@original` | `developers/interactions/receiving-and-responding.mdx` | RESTClient.getOriginalInteractionResponse |
| Implemented | `GET` | `/webhooks/{application.id}/{interaction.token}/messages/{message.id}` | `developers/interactions/receiving-and-responding.mdx` | RESTClient.getFollowupMessage |
| Implemented | `PATCH` | `/webhooks/{application.id}/{interaction.token}/messages/@original` | `developers/interactions/receiving-and-responding.mdx` | RESTClient.editInteractionResponse |
| Implemented | `PATCH` | `/webhooks/{application.id}/{interaction.token}/messages/{message.id}` | `developers/interactions/receiving-and-responding.mdx` | RESTClient.editFollowupMessage |
| Implemented | `POST` | `/interactions/{interaction.id}/{interaction.token}/callback` | `developers/interactions/receiving-and-responding.mdx` | RESTClient.createInteractionResponse |
| Implemented | `POST` | `/webhooks/{application.id}/{interaction.token}` | `developers/interactions/receiving-and-responding.mdx` | RESTClient.createFollowup |
| Implemented | `GET` | `/applications/{application.id}/role-connections/metadata` | `developers/resources/application-role-connection-metadata.mdx` | RESTClient.getApplicationRoleConnectionMetadata |
| Implemented | `PUT` | `/applications/{application.id}/role-connections/metadata` | `developers/resources/application-role-connection-metadata.mdx` | RESTClient.updateApplicationRoleConnectionMetadata |
| Implemented | `GET` | `/applications/@me` | `developers/resources/application.mdx` | RESTClient.getCurrentApplication |
| Implemented | `GET` | `/applications/{application.id}/activity-instances/{instance_id}` | `developers/resources/application.mdx` | RESTClient.getApplicationActivityInstance |
| Implemented | `PATCH` | `/applications/@me` | `developers/resources/application.mdx` | RESTClient.modifyCurrentApplication |
| Implemented | `GET` | `/guilds/{guild.id}/audit-logs` | `developers/resources/audit-log.mdx` | RESTClient.getGuildAuditLog |
| Implemented | `DELETE` | `/guilds/{guild.id}/auto-moderation/rules/{auto_moderation_rule.id}` | `developers/resources/auto-moderation.mdx` | RESTClient.deleteGuildAutoModerationRule |
| Implemented | `GET` | `/guilds/{guild.id}/auto-moderation/rules` | `developers/resources/auto-moderation.mdx` | RESTClient.getGuildAutoModerationRules |
| Implemented | `GET` | `/guilds/{guild.id}/auto-moderation/rules/{auto_moderation_rule.id}` | `developers/resources/auto-moderation.mdx` | RESTClient.getGuildAutoModerationRule |
| Implemented | `PATCH` | `/guilds/{guild.id}/auto-moderation/rules/{auto_moderation_rule.id}` | `developers/resources/auto-moderation.mdx` | RESTClient.modifyGuildAutoModerationRule |
| Implemented | `POST` | `/guilds/{guild.id}/auto-moderation/rules` | `developers/resources/auto-moderation.mdx` | RESTClient.createGuildAutoModerationRule |
| Implemented | `DELETE` | `/channels/{channel.id}` | `developers/resources/channel.mdx` | RESTClient.deleteChannel |
| Implemented | `DELETE` | `/channels/{channel.id}/permissions/{overwrite.id}` | `developers/resources/channel.mdx` | RESTClient.deleteChannelPermission |
| Implemented | `DELETE` | `/channels/{channel.id}/recipients/{user.id}` | `developers/resources/channel.mdx` | RESTClient.deleteChannelRecipient |
| Implemented | `DELETE` | `/channels/{channel.id}/thread-members/@me` | `developers/resources/channel.mdx` | RESTClient.leaveThread |
| Implemented | `DELETE` | `/channels/{channel.id}/thread-members/{user.id}` | `developers/resources/channel.mdx` | RESTClient.removeThreadMember |
| Implemented | `GET` | `/channels/{channel.id}` | `developers/resources/channel.mdx` | RESTClient.getChannel |
| Implemented | `GET` | `/channels/{channel.id}/invites` | `developers/resources/channel.mdx` | RESTClient.getChannelInvites |
| Implemented | `GET` | `/channels/{channel.id}/thread-members` | `developers/resources/channel.mdx` | RESTClient.getThreadMembers |
| Implemented | `GET` | `/channels/{channel.id}/thread-members/{user.id}` | `developers/resources/channel.mdx` | RESTClient.getThreadMember |
| Implemented | `GET` | `/channels/{channel.id}/threads/archived/private` | `developers/resources/channel.mdx` | RESTClient.getPrivateArchivedThreads |
| Implemented | `GET` | `/channels/{channel.id}/threads/archived/public` | `developers/resources/channel.mdx` | RESTClient.getPublicArchivedThreads |
| Implemented | `GET` | `/channels/{channel.id}/users/@me/threads/archived/private` | `developers/resources/channel.mdx` | RESTClient.getJoinedPrivateArchivedThreads |
| Implemented | `PATCH` | `/channels/{channel.id}` | `developers/resources/channel.mdx` | RESTClient.modifyChannel |
| Implemented | `POST` | `/channels/{channel.id}/followers` | `developers/resources/channel.mdx` | RESTClient.followAnnouncementChannel |
| Implemented | `POST` | `/channels/{channel.id}/invites` | `developers/resources/channel.mdx` | RESTClient.createChannelInvite |
| Implemented | `POST` | `/channels/{channel.id}/messages/{message.id}/threads` | `developers/resources/channel.mdx` | RESTClient.startThreadFromMessage |
| Implemented | `POST` | `/channels/{channel.id}/threads` | `developers/resources/channel.mdx` | RESTClient.startThreadWithoutMessage |
| Implemented | `POST` | `/channels/{channel.id}/typing` | `developers/resources/channel.mdx` | RESTClient.triggerTyping |
| Implemented | `PUT` | `/channels/{channel.id}/permissions/{overwrite.id}` | `developers/resources/channel.mdx` | RESTClient.editChannelPermission |
| Implemented | `PUT` | `/channels/{channel.id}/recipients/{user.id}` | `developers/resources/channel.mdx` | RESTClient.addChannelRecipient |
| Implemented | `PUT` | `/channels/{channel.id}/thread-members/@me` | `developers/resources/channel.mdx` | RESTClient.joinThread |
| Implemented | `PUT` | `/channels/{channel.id}/thread-members/{user.id}` | `developers/resources/channel.mdx` | RESTClient.addThreadMember |
| Remaining | `DELETE` | `/applications/{application.id}/emojis/{emoji.id}` | `developers/resources/emoji.mdx` | - |
| Implemented | `DELETE` | `/guilds/{guild.id}/emojis/{emoji.id}` | `developers/resources/emoji.mdx` | RESTClient.deleteGuildEmoji |
| Remaining | `GET` | `/applications/{application.id}/emojis` | `developers/resources/emoji.mdx` | - |
| Remaining | `GET` | `/applications/{application.id}/emojis/{emoji.id}` | `developers/resources/emoji.mdx` | - |
| Implemented | `GET` | `/guilds/{guild.id}/emojis` | `developers/resources/emoji.mdx` | RESTClient.getGuildEmojis |
| Implemented | `GET` | `/guilds/{guild.id}/emojis/{emoji.id}` | `developers/resources/emoji.mdx` | RESTClient.getGuildEmoji |
| Remaining | `PATCH` | `/applications/{application.id}/emojis/{emoji.id}` | `developers/resources/emoji.mdx` | - |
| Implemented | `PATCH` | `/guilds/{guild.id}/emojis/{emoji.id}` | `developers/resources/emoji.mdx` | RESTClient.modifyGuildEmoji |
| Remaining | `POST` | `/applications/{application.id}/emojis` | `developers/resources/emoji.mdx` | - |
| Implemented | `POST` | `/guilds/{guild.id}/emojis` | `developers/resources/emoji.mdx` | RESTClient.createGuildEmoji |
| Remaining | `DELETE` | `/applications/{application.id}/entitlements/{entitlement.id}` | `developers/resources/entitlement.mdx` | - |
| Implemented | `GET` | `/applications/{application.id}/entitlements` | `developers/resources/entitlement.mdx` | RESTClient.getApplicationEntitlements |
| Remaining | `GET` | `/applications/{application.id}/entitlements/{entitlement.id}` | `developers/resources/entitlement.mdx` | - |
| Remaining | `POST` | `/applications/{application.id}/entitlements` | `developers/resources/entitlement.mdx` | - |
| Implemented | `POST` | `/applications/{application.id}/entitlements/{entitlement.id}/consume` | `developers/resources/entitlement.mdx` | RESTClient.consumeEntitlement |
| Implemented | `DELETE` | `/guilds/{guild.id}/scheduled-events/{guild_scheduled_event.id}` | `developers/resources/guild-scheduled-event.mdx` | RESTClient.deleteGuildScheduledEvent |
| Implemented | `GET` | `/guilds/{guild.id}/scheduled-events` | `developers/resources/guild-scheduled-event.mdx` | RESTClient.getGuildScheduledEvents |
| Implemented | `GET` | `/guilds/{guild.id}/scheduled-events/{guild_scheduled_event.id}` | `developers/resources/guild-scheduled-event.mdx` | RESTClient.getGuildScheduledEvent |
| Implemented | `GET` | `/guilds/{guild.id}/scheduled-events/{guild_scheduled_event.id}/users` | `developers/resources/guild-scheduled-event.mdx` | RESTClient.getGuildScheduledEventUsers |
| Implemented | `PATCH` | `/guilds/{guild.id}/scheduled-events/{guild_scheduled_event.id}` | `developers/resources/guild-scheduled-event.mdx` | RESTClient.modifyGuildScheduledEvent |
| Implemented | `POST` | `/guilds/{guild.id}/scheduled-events` | `developers/resources/guild-scheduled-event.mdx` | RESTClient.createGuildScheduledEvent |
| Implemented | `DELETE` | `/guilds/{guild.id}/templates/{template.code}` | `developers/resources/guild-template.mdx` | RESTClient.deleteGuildTemplate |
| Implemented | `GET` | `/guilds/templates/{template.code}` | `developers/resources/guild-template.mdx` | RESTClient.getGuildTemplate |
| Implemented | `GET` | `/guilds/{guild.id}/templates` | `developers/resources/guild-template.mdx` | RESTClient.getGuildTemplates |
| Implemented | `PATCH` | `/guilds/{guild.id}/templates/{template.code}` | `developers/resources/guild-template.mdx` | RESTClient.modifyGuildTemplate |
| Implemented | `POST` | `/guilds/{guild.id}/templates` | `developers/resources/guild-template.mdx` | RESTClient.createGuildTemplate |
| Implemented | `PUT` | `/guilds/{guild.id}/templates/{template.code}` | `developers/resources/guild-template.mdx` | RESTClient.syncGuildTemplate |
| Implemented | `DELETE` | `/guilds/{guild.id}/bans/{user.id}` | `developers/resources/guild.mdx` | RESTClient.deleteGuildBan |
| Implemented | `DELETE` | `/guilds/{guild.id}/integrations/{integration.id}` | `developers/resources/guild.mdx` | RESTClient.deleteGuildIntegration |
| Implemented | `DELETE` | `/guilds/{guild.id}/members/{user.id}` | `developers/resources/guild.mdx` | RESTClient.removeGuildMember |
| Implemented | `DELETE` | `/guilds/{guild.id}/members/{user.id}/roles/{role.id}` | `developers/resources/guild.mdx` | RESTClient.removeGuildMemberRole |
| Implemented | `DELETE` | `/guilds/{guild.id}/roles/{role.id}` | `developers/resources/guild.mdx` | RESTClient.deleteGuildRole |
| Implemented | `GET` | `/guilds/{guild.id}` | `developers/resources/guild.mdx` | RESTClient.getGuild |
| Implemented | `GET` | `/guilds/{guild.id}/bans` | `developers/resources/guild.mdx` | RESTClient.getGuildBans |
| Implemented | `GET` | `/guilds/{guild.id}/bans/{user.id}` | `developers/resources/guild.mdx` | RESTClient.getGuildBan |
| Implemented | `GET` | `/guilds/{guild.id}/channels` | `developers/resources/guild.mdx` | RESTClient.getGuildChannels |
| Implemented | `GET` | `/guilds/{guild.id}/integrations` | `developers/resources/guild.mdx` | RESTClient.getGuildIntegrations |
| Implemented | `GET` | `/guilds/{guild.id}/invites` | `developers/resources/guild.mdx` | RESTClient.getGuildInvites |
| Implemented | `GET` | `/guilds/{guild.id}/members` | `developers/resources/guild.mdx` | RESTClient.getGuildMembers |
| Implemented | `GET` | `/guilds/{guild.id}/members/search` | `developers/resources/guild.mdx` | RESTClient.searchGuildMembers |
| Implemented | `GET` | `/guilds/{guild.id}/members/{user.id}` | `developers/resources/guild.mdx` | RESTClient.getGuildMember |
| Implemented | `GET` | `/guilds/{guild.id}/onboarding` | `developers/resources/guild.mdx` | RESTClient.getGuildOnboarding |
| Implemented | `GET` | `/guilds/{guild.id}/preview` | `developers/resources/guild.mdx` | RESTClient.getGuildPreview |
| Implemented | `GET` | `/guilds/{guild.id}/prune` | `developers/resources/guild.mdx` | RESTClient.getGuildPruneCount |
| Implemented | `GET` | `/guilds/{guild.id}/regions` | `developers/resources/guild.mdx` | RESTClient.getGuildRegions |
| Implemented | `GET` | `/guilds/{guild.id}/roles` | `developers/resources/guild.mdx` | RESTClient.getGuildRoles |
| Implemented | `GET` | `/guilds/{guild.id}/roles/member-counts` | `developers/resources/guild.mdx` | RESTClient.getGuildRoleMemberCounts |
| Implemented | `GET` | `/guilds/{guild.id}/roles/{role.id}` | `developers/resources/guild.mdx` | RESTClient.getGuildRole |
| Implemented | `GET` | `/guilds/{guild.id}/threads/active` | `developers/resources/guild.mdx` | RESTClient.getActiveGuildThreads |
| Implemented | `GET` | `/guilds/{guild.id}/vanity-url` | `developers/resources/guild.mdx` | RESTClient.getGuildVanityURL |
| Implemented | `GET` | `/guilds/{guild.id}/welcome-screen` | `developers/resources/guild.mdx` | RESTClient.getGuildWelcomeScreen |
| Implemented | `GET` | `/guilds/{guild.id}/widget` | `developers/resources/guild.mdx` | RESTClient.getGuildWidgetSettings |
| Implemented | `GET` | `/guilds/{guild.id}/widget.json` | `developers/resources/guild.mdx` | RESTClient.getGuildWidget |
| Implemented | `GET` | `/guilds/{guild.id}/widget.png` | `developers/resources/guild.mdx` | RESTClient.getGuildWidgetImage |
| Implemented | `PATCH` | `/guilds/{guild.id}` | `developers/resources/guild.mdx` | RESTClient.modifyGuild |
| Implemented | `PATCH` | `/guilds/{guild.id}/channels` | `developers/resources/guild.mdx` | RESTClient.modifyGuildChannelPositions |
| Implemented | `PATCH` | `/guilds/{guild.id}/members/@me` | `developers/resources/guild.mdx` | RESTClient.modifyCurrentGuildMember |
| Implemented | `PATCH` | `/guilds/{guild.id}/members/@me/nick` | `developers/resources/guild.mdx` | RESTClient.modifyCurrentGuildNick |
| Implemented | `PATCH` | `/guilds/{guild.id}/members/{user.id}` | `developers/resources/guild.mdx` | RESTClient.modifyGuildMember |
| Implemented | `PATCH` | `/guilds/{guild.id}/roles` | `developers/resources/guild.mdx` | RESTClient.modifyGuildRolePositions |
| Implemented | `PATCH` | `/guilds/{guild.id}/roles/{role.id}` | `developers/resources/guild.mdx` | RESTClient.modifyGuildRole |
| Implemented | `PATCH` | `/guilds/{guild.id}/welcome-screen` | `developers/resources/guild.mdx` | RESTClient.modifyGuildWelcomeScreen |
| Implemented | `PATCH` | `/guilds/{guild.id}/widget` | `developers/resources/guild.mdx` | RESTClient.modifyGuildWidget |
| Implemented | `POST` | `/guilds/{guild.id}/bulk-ban` | `developers/resources/guild.mdx` | RESTClient.bulkBanGuildMembers |
| Implemented | `POST` | `/guilds/{guild.id}/channels` | `developers/resources/guild.mdx` | RESTClient.createGuildChannel |
| Implemented | `POST` | `/guilds/{guild.id}/prune` | `developers/resources/guild.mdx` | RESTClient.beginGuildPrune |
| Implemented | `POST` | `/guilds/{guild.id}/roles` | `developers/resources/guild.mdx` | RESTClient.createGuildRole |
| Implemented | `PUT` | `/guilds/{guild.id}/bans/{user.id}` | `developers/resources/guild.mdx` | RESTClient.createGuildBan |
| Implemented | `PUT` | `/guilds/{guild.id}/incident-actions` | `developers/resources/guild.mdx` | RESTClient.setGuildIncidentActions |
| Implemented | `PUT` | `/guilds/{guild.id}/members/{user.id}` | `developers/resources/guild.mdx` | RESTClient.addGuildMember |
| Implemented | `PUT` | `/guilds/{guild.id}/members/{user.id}/roles/{role.id}` | `developers/resources/guild.mdx` | RESTClient.addGuildMemberRole |
| Implemented | `PUT` | `/guilds/{guild.id}/onboarding` | `developers/resources/guild.mdx` | RESTClient.modifyGuildOnboarding |
| Implemented | `DELETE` | `/invites/{invite.code}` | `developers/resources/invite.mdx` | RESTClient.deleteInvite |
| Implemented | `GET` | `/invites/{invite.code}` | `developers/resources/invite.mdx` | RESTClient.getInvite |
| Implemented | `GET` | `/invites/{invite.code}/target-users` | `developers/resources/invite.mdx` | RESTClient.getInviteTargetUsers |
| Implemented | `GET` | `/invites/{invite.code}/target-users/job-status` | `developers/resources/invite.mdx` | RESTClient.getInviteTargetUsersJobStatus |
| Implemented | `PUT` | `/invites/{invite.code}/target-users` | `developers/resources/invite.mdx` | RESTClient.updateInviteTargetUsers |
| Remaining | `DELETE` | `/lobbies/{lobby.id}` | `developers/resources/lobby.mdx` | - |
| Remaining | `DELETE` | `/lobbies/{lobby.id}/members/@me` | `developers/resources/lobby.mdx` | - |
| Remaining | `DELETE` | `/lobbies/{lobby.id}/members/{user.id}` | `developers/resources/lobby.mdx` | - |
| Remaining | `GET` | `/lobbies/{lobby.id}` | `developers/resources/lobby.mdx` | - |
| Remaining | `PATCH` | `/lobbies/{lobby.id}` | `developers/resources/lobby.mdx` | - |
| Remaining | `PATCH` | `/lobbies/{lobby.id}/channel-linking` | `developers/resources/lobby.mdx` | - |
| Remaining | `POST` | `/lobbies` | `developers/resources/lobby.mdx` | - |
| Remaining | `PUT` | `/lobbies/{lobby.id}/members/{user.id}` | `developers/resources/lobby.mdx` | - |
| Implemented | `DELETE` | `/channels/{channel.id}/messages/pins/{message.id}` | `developers/resources/message.mdx` | RESTClient.unpinMessage |
| Implemented | `DELETE` | `/channels/{channel.id}/messages/{message.id}` | `developers/resources/message.mdx` | RESTClient.deleteMessage |
| Implemented | `DELETE` | `/channels/{channel.id}/messages/{message.id}/reactions` | `developers/resources/message.mdx` | RESTClient.deleteAllReactions |
| Implemented | `DELETE` | `/channels/{channel.id}/messages/{message.id}/reactions/{emoji.id}` | `developers/resources/message.mdx` | RESTClient.deleteAllReactionsForEmoji |
| Implemented | `DELETE` | `/channels/{channel.id}/messages/{message.id}/reactions/{emoji.id}/@me` | `developers/resources/message.mdx` | RESTClient.deleteOwnReaction |
| Implemented | `DELETE` | `/channels/{channel.id}/messages/{message.id}/reactions/{emoji.id}/{user.id}` | `developers/resources/message.mdx` | RESTClient.deleteUserReaction |
| Implemented | `DELETE` | `/channels/{channel.id}/pins/{message.id}` | `developers/resources/message.mdx` | RESTClient.unpin |
| Implemented | `GET` | `/channels/{channel.id}/messages` | `developers/resources/message.mdx` | RESTClient.getMessages |
| Implemented | `GET` | `/channels/{channel.id}/messages/pins` | `developers/resources/message.mdx` | RESTClient.getMessagePins |
| Implemented | `GET` | `/channels/{channel.id}/messages/{message.id}` | `developers/resources/message.mdx` | RESTClient.getMessage |
| Implemented | `GET` | `/channels/{channel.id}/messages/{message.id}/reactions/{emoji.id}` | `developers/resources/message.mdx` | RESTClient.getReactions |
| Implemented | `GET` | `/channels/{channel.id}/pins` | `developers/resources/message.mdx` | RESTClient.getPins |
| Implemented | `PATCH` | `/channels/{channel.id}/messages/{message.id}` | `developers/resources/message.mdx` | RESTClient.editMessage |
| Implemented | `POST` | `/channels/{channel.id}/messages` | `developers/resources/message.mdx` | RESTClient.sendMessage / sendComponentsV2Message |
| Implemented | `POST` | `/channels/{channel.id}/messages/bulk-delete` | `developers/resources/message.mdx` | RESTClient.bulkDeleteMessages |
| Implemented | `POST` | `/channels/{channel.id}/messages/{message.id}/crosspost` | `developers/resources/message.mdx` | RESTClient.crosspostMessage |
| Implemented | `PUT` | `/channels/{channel.id}/messages/pins/{message.id}` | `developers/resources/message.mdx` | RESTClient.pinMessage |
| Implemented | `PUT` | `/channels/{channel.id}/messages/{message.id}/reactions/{emoji.id}/@me` | `developers/resources/message.mdx` | RESTClient.createReaction |
| Implemented | `PUT` | `/channels/{channel.id}/pins/{message.id}` | `developers/resources/message.mdx` | RESTClient.pin |
| Implemented | `GET` | `/channels/{channel.id}/polls/{message.id}/answers/{answer_id}` | `developers/resources/poll.mdx` | RESTClient.getPollAnswerVoters |
| Implemented | `POST` | `/channels/{channel.id}/polls/{message.id}/expire` | `developers/resources/poll.mdx` | RESTClient.expirePoll |
| Implemented | `GET` | `/applications/{application.id}/skus` | `developers/resources/sku.mdx` | RESTClient.getApplicationSKUs |
| Remaining | `DELETE` | `/guilds/{guild.id}/soundboard-sounds/{sound.id}` | `developers/resources/soundboard.mdx` | - |
| Remaining | `GET` | `/guilds/{guild.id}/soundboard-sounds` | `developers/resources/soundboard.mdx` | - |
| Remaining | `GET` | `/guilds/{guild.id}/soundboard-sounds/{sound.id}` | `developers/resources/soundboard.mdx` | - |
| Remaining | `GET` | `/soundboard-default-sounds` | `developers/resources/soundboard.mdx` | - |
| Remaining | `PATCH` | `/guilds/{guild.id}/soundboard-sounds/{sound.id}` | `developers/resources/soundboard.mdx` | - |
| Remaining | `POST` | `/channels/{channel.id}/send-soundboard-sound` | `developers/resources/soundboard.mdx` | - |
| Remaining | `POST` | `/guilds/{guild.id}/soundboard-sounds` | `developers/resources/soundboard.mdx` | - |
| Implemented | `DELETE` | `/stage-instances/{channel.id}` | `developers/resources/stage-instance.mdx` | RESTClient.deleteStageInstance |
| Implemented | `GET` | `/stage-instances/{channel.id}` | `developers/resources/stage-instance.mdx` | RESTClient.getStageInstance |
| Implemented | `PATCH` | `/stage-instances/{channel.id}` | `developers/resources/stage-instance.mdx` | RESTClient.modifyStageInstance |
| Implemented | `POST` | `/stage-instances` | `developers/resources/stage-instance.mdx` | RESTClient.createStageInstance |
| Remaining | `DELETE` | `/guilds/{guild.id}/stickers/{sticker.id}` | `developers/resources/sticker.mdx` | - |
| Remaining | `GET` | `/guilds/{guild.id}/stickers` | `developers/resources/sticker.mdx` | - |
| Remaining | `GET` | `/guilds/{guild.id}/stickers/{sticker.id}` | `developers/resources/sticker.mdx` | - |
| Remaining | `GET` | `/sticker-packs` | `developers/resources/sticker.mdx` | - |
| Remaining | `GET` | `/sticker-packs/{pack.id}` | `developers/resources/sticker.mdx` | - |
| Remaining | `GET` | `/stickers/{sticker.id}` | `developers/resources/sticker.mdx` | - |
| Remaining | `PATCH` | `/guilds/{guild.id}/stickers/{sticker.id}` | `developers/resources/sticker.mdx` | - |
| Remaining | `POST` | `/guilds/{guild.id}/stickers` | `developers/resources/sticker.mdx` | - |
| Remaining | `GET` | `/skus/{sku.id}/subscriptions` | `developers/resources/subscription.mdx` | - |
| Remaining | `GET` | `/skus/{sku.id}/subscriptions/{subscription.id}` | `developers/resources/subscription.mdx` | - |
| Implemented | `DELETE` | `/users/@me/guilds/{guild.id}` | `developers/resources/user.mdx` | RESTClient.leaveGuild |
| Implemented | `GET` | `/users/@me` | `developers/resources/user.mdx` | RESTClient.getCurrentUser |
| Implemented | `GET` | `/users/@me/applications/{application.id}/role-connection` | `developers/resources/user.mdx` | RESTClient.getCurrentUserApplicationRoleConnection |
| Implemented | `GET` | `/users/@me/connections` | `developers/resources/user.mdx` | RESTClient.getCurrentUserConnections |
| Implemented | `GET` | `/users/@me/guilds` | `developers/resources/user.mdx` | RESTClient.getCurrentUserGuilds |
| Implemented | `GET` | `/users/@me/guilds/{guild.id}/member` | `developers/resources/user.mdx` | RESTClient.getCurrentUserGuildMember |
| Implemented | `GET` | `/users/{user.id}` | `developers/resources/user.mdx` | RESTClient.getUser |
| Implemented | `PATCH` | `/users/@me` | `developers/resources/user.mdx` | RESTClient.modifyCurrentUser |
| Implemented | `POST` | `/users/@me/channels` | `developers/resources/user.mdx` | RESTClient.createDM |
| Implemented | `PUT` | `/users/@me/applications/{application.id}/role-connection` | `developers/resources/user.mdx` | RESTClient.updateCurrentUserApplicationRoleConnection |
| Implemented | `GET` | `/guilds/{guild.id}/voice-states/@me` | `developers/resources/voice.mdx` | RESTClient.getCurrentUserVoiceState |
| Implemented | `GET` | `/guilds/{guild.id}/voice-states/{user.id}` | `developers/resources/voice.mdx` | RESTClient.getVoiceState |
| Implemented | `GET` | `/voice/regions` | `developers/resources/voice.mdx` | RESTClient.getVoiceRegions |
| Implemented | `PATCH` | `/guilds/{guild.id}/voice-states/@me` | `developers/resources/voice.mdx` | RESTClient.modifyCurrentUserVoiceState |
| Implemented | `PATCH` | `/guilds/{guild.id}/voice-states/{user.id}` | `developers/resources/voice.mdx` | RESTClient.modifyUserVoiceState |
| Implemented | `DELETE` | `/webhooks/{webhook.id}` | `developers/resources/webhook.mdx` | RESTClient.deleteWebhook(webhookId:) |
| Implemented | `DELETE` | `/webhooks/{webhook.id}/{webhook.token}` | `developers/resources/webhook.mdx` | RESTClient.deleteWebhook(webhookId:token:) |
| Implemented | `DELETE` | `/webhooks/{webhook.id}/{webhook.token}/messages/{message.id}` | `developers/resources/webhook.mdx` | RESTClient.deleteWebhookMessage |
| Implemented | `GET` | `/channels/{channel.id}/webhooks` | `developers/resources/webhook.mdx` | RESTClient.getChannelWebhooks |
| Implemented | `GET` | `/guilds/{guild.id}/webhooks` | `developers/resources/webhook.mdx` | RESTClient.getGuildWebhooks |
| Implemented | `GET` | `/webhooks/{webhook.id}` | `developers/resources/webhook.mdx` | RESTClient.getWebhook(webhookId:) |
| Implemented | `GET` | `/webhooks/{webhook.id}/{webhook.token}` | `developers/resources/webhook.mdx` | RESTClient.getWebhook(webhookId:token:) |
| Implemented | `GET` | `/webhooks/{webhook.id}/{webhook.token}/messages/{message.id}` | `developers/resources/webhook.mdx` | RESTClient.getWebhookMessage |
| Implemented | `PATCH` | `/webhooks/{webhook.id}` | `developers/resources/webhook.mdx` | RESTClient.modifyWebhook(webhookId:modify:) |
| Implemented | `PATCH` | `/webhooks/{webhook.id}/{webhook.token}` | `developers/resources/webhook.mdx` | RESTClient.modifyWebhook(webhookId:token:modify:) |
| Implemented | `PATCH` | `/webhooks/{webhook.id}/{webhook.token}/messages/{message.id}` | `developers/resources/webhook.mdx` | RESTClient.editWebhookMessage |
| Implemented | `POST` | `/channels/{channel.id}/webhooks` | `developers/resources/webhook.mdx` | RESTClient.createWebhook |
| Implemented | `POST` | `/webhooks/{webhook.id}/{webhook.token}` | `developers/resources/webhook.mdx` | RESTClient.executeWebhook |
| Implemented | `POST` | `/webhooks/{webhook.id}/{webhook.token}/github` | `developers/resources/webhook.mdx` | RESTClient.executeGitHubWebhook |
| Implemented | `POST` | `/webhooks/{webhook.id}/{webhook.token}/slack` | `developers/resources/webhook.mdx` | RESTClient.executeSlackWebhook |
| Implemented | `GET` | `/oauth2/@me` | `developers/topics/oauth2.mdx` | RESTClient.getOAuth2CurrentAuthorization |
| Implemented | `GET` | `/oauth2/applications/@me` | `developers/topics/oauth2.mdx` | RESTClient.getOAuth2CurrentApplication |
