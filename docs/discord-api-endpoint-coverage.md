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
- Implemented in SwiftDiscKit: **102**
- Remaining: **117**

## Implemented Endpoints

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
| Remaining | `GET` | `/applications/{application.id}/guilds/{guild.id}/commands/permissions` | `developers/interactions/application-commands.mdx` | - |
| Implemented | `GET` | `/applications/{application.id}/guilds/{guild.id}/commands/{command.id}` | `developers/interactions/application-commands.mdx` | RESTClient.getGuildCommand |
| Remaining | `GET` | `/applications/{application.id}/guilds/{guild.id}/commands/{command.id}/permissions` | `developers/interactions/application-commands.mdx` | - |
| Implemented | `PATCH` | `/applications/{application.id}/commands/{command.id}` | `developers/interactions/application-commands.mdx` | RESTClient.editGlobalCommand |
| Implemented | `PATCH` | `/applications/{application.id}/guilds/{guild.id}/commands/{command.id}` | `developers/interactions/application-commands.mdx` | RESTClient.editGuildCommand |
| Implemented | `POST` | `/applications/{application.id}/commands` | `developers/interactions/application-commands.mdx` | RESTClient.createGlobalCommand / createSlashCommand |
| Implemented | `POST` | `/applications/{application.id}/guilds/{guild.id}/commands` | `developers/interactions/application-commands.mdx` | RESTClient.createGuildCommand |
| Implemented | `PUT` | `/applications/{application.id}/commands` | `developers/interactions/application-commands.mdx` | RESTClient.bulkOverwriteGlobalCommands |
| Implemented | `PUT` | `/applications/{application.id}/guilds/{guild.id}/commands` | `developers/interactions/application-commands.mdx` | RESTClient.bulkOverwriteGuildCommands |
| Remaining | `PUT` | `/applications/{application.id}/guilds/{guild.id}/commands/permissions` | `developers/interactions/application-commands.mdx` | - |
| Remaining | `PUT` | `/applications/{application.id}/guilds/{guild.id}/commands/{command.id}/permissions` | `developers/interactions/application-commands.mdx` | - |
| Implemented | `DELETE` | `/webhooks/{application.id}/{interaction.token}/messages/@original` | `developers/interactions/receiving-and-responding.mdx` | RESTClient.deleteOriginalInteractionResponse |
| Implemented | `DELETE` | `/webhooks/{application.id}/{interaction.token}/messages/{message.id}` | `developers/interactions/receiving-and-responding.mdx` | RESTClient.deleteFollowupMessage |
| Implemented | `GET` | `/webhooks/{application.id}/{interaction.token}/messages/@original` | `developers/interactions/receiving-and-responding.mdx` | RESTClient.getOriginalInteractionResponse |
| Implemented | `GET` | `/webhooks/{application.id}/{interaction.token}/messages/{message.id}` | `developers/interactions/receiving-and-responding.mdx` | RESTClient.getFollowupMessage |
| Implemented | `PATCH` | `/webhooks/{application.id}/{interaction.token}/messages/@original` | `developers/interactions/receiving-and-responding.mdx` | RESTClient.editInteractionResponse |
| Implemented | `PATCH` | `/webhooks/{application.id}/{interaction.token}/messages/{message.id}` | `developers/interactions/receiving-and-responding.mdx` | RESTClient.editFollowupMessage |
| Implemented | `POST` | `/interactions/{interaction.id}/{interaction.token}/callback` | `developers/interactions/receiving-and-responding.mdx` | RESTClient.createInteractionResponse |
| Implemented | `POST` | `/webhooks/{application.id}/{interaction.token}` | `developers/interactions/receiving-and-responding.mdx` | RESTClient.createFollowup |
| Remaining | `GET` | `/applications/{application.id}/role-connections/metadata` | `developers/resources/application-role-connection-metadata.mdx` | - |
| Remaining | `PUT` | `/applications/{application.id}/role-connections/metadata` | `developers/resources/application-role-connection-metadata.mdx` | - |
| Remaining | `GET` | `/applications/@me` | `developers/resources/application.mdx` | - |
| Remaining | `GET` | `/applications/{application.id}/activity-instances/{instance_id}` | `developers/resources/application.mdx` | - |
| Remaining | `PATCH` | `/applications/@me` | `developers/resources/application.mdx` | - |
| Implemented | `GET` | `/guilds/{guild.id}/audit-logs` | `developers/resources/audit-log.mdx` | RESTClient.getGuildAuditLog |
| Remaining | `DELETE` | `/guilds/{guild.id}/auto-moderation/rules/{auto_moderation_rule.id}` | `developers/resources/auto-moderation.mdx` | - |
| Remaining | `GET` | `/guilds/{guild.id}/auto-moderation/rules` | `developers/resources/auto-moderation.mdx` | - |
| Remaining | `GET` | `/guilds/{guild.id}/auto-moderation/rules/{auto_moderation_rule.id}` | `developers/resources/auto-moderation.mdx` | - |
| Remaining | `PATCH` | `/guilds/{guild.id}/auto-moderation/rules/{auto_moderation_rule.id}` | `developers/resources/auto-moderation.mdx` | - |
| Remaining | `POST` | `/guilds/{guild.id}/auto-moderation/rules` | `developers/resources/auto-moderation.mdx` | - |
| Implemented | `DELETE` | `/channels/{channel.id}` | `developers/resources/channel.mdx` | RESTClient.deleteChannel |
| Implemented | `DELETE` | `/channels/{channel.id}/permissions/{overwrite.id}` | `developers/resources/channel.mdx` | RESTClient.deleteChannelPermission |
| Remaining | `DELETE` | `/channels/{channel.id}/recipients/{user.id}` | `developers/resources/channel.mdx` | - |
| Implemented | `DELETE` | `/channels/{channel.id}/thread-members/@me` | `developers/resources/channel.mdx` | RESTClient.leaveThread |
| Remaining | `DELETE` | `/channels/{channel.id}/thread-members/{user.id}` | `developers/resources/channel.mdx` | - |
| Implemented | `GET` | `/channels/{channel.id}` | `developers/resources/channel.mdx` | RESTClient.getChannel |
| Implemented | `GET` | `/channels/{channel.id}/invites` | `developers/resources/channel.mdx` | RESTClient.getChannelInvites |
| Implemented | `GET` | `/channels/{channel.id}/thread-members` | `developers/resources/channel.mdx` | RESTClient.getThreadMembers |
| Implemented | `GET` | `/channels/{channel.id}/thread-members/{user.id}` | `developers/resources/channel.mdx` | RESTClient.getThreadMember |
| Implemented | `GET` | `/channels/{channel.id}/threads/archived/private` | `developers/resources/channel.mdx` | RESTClient.getPrivateArchivedThreads |
| Implemented | `GET` | `/channels/{channel.id}/threads/archived/public` | `developers/resources/channel.mdx` | RESTClient.getPublicArchivedThreads |
| Implemented | `GET` | `/channels/{channel.id}/users/@me/threads/archived/private` | `developers/resources/channel.mdx` | RESTClient.getJoinedPrivateArchivedThreads |
| Implemented | `PATCH` | `/channels/{channel.id}` | `developers/resources/channel.mdx` | RESTClient.modifyChannel |
| Remaining | `POST` | `/channels/{channel.id}/followers` | `developers/resources/channel.mdx` | - |
| Implemented | `POST` | `/channels/{channel.id}/invites` | `developers/resources/channel.mdx` | RESTClient.createChannelInvite |
| Implemented | `POST` | `/channels/{channel.id}/messages/{message.id}/threads` | `developers/resources/channel.mdx` | RESTClient.startThreadFromMessage |
| Implemented | `POST` | `/channels/{channel.id}/threads` | `developers/resources/channel.mdx` | RESTClient.startThreadWithoutMessage |
| Implemented | `POST` | `/channels/{channel.id}/typing` | `developers/resources/channel.mdx` | RESTClient.triggerTyping |
| Implemented | `PUT` | `/channels/{channel.id}/permissions/{overwrite.id}` | `developers/resources/channel.mdx` | RESTClient.editChannelPermission |
| Remaining | `PUT` | `/channels/{channel.id}/recipients/{user.id}` | `developers/resources/channel.mdx` | - |
| Implemented | `PUT` | `/channels/{channel.id}/thread-members/@me` | `developers/resources/channel.mdx` | RESTClient.joinThread |
| Implemented | `PUT` | `/channels/{channel.id}/thread-members/{user.id}` | `developers/resources/channel.mdx` | RESTClient.addThreadMember |
| Remaining | `DELETE` | `/applications/{application.id}/emojis/{emoji.id}` | `developers/resources/emoji.mdx` | - |
| Remaining | `DELETE` | `/guilds/{guild.id}/emojis/{emoji.id}` | `developers/resources/emoji.mdx` | - |
| Remaining | `GET` | `/applications/{application.id}/emojis` | `developers/resources/emoji.mdx` | - |
| Remaining | `GET` | `/applications/{application.id}/emojis/{emoji.id}` | `developers/resources/emoji.mdx` | - |
| Remaining | `GET` | `/guilds/{guild.id}/emojis` | `developers/resources/emoji.mdx` | - |
| Remaining | `GET` | `/guilds/{guild.id}/emojis/{emoji.id}` | `developers/resources/emoji.mdx` | - |
| Remaining | `PATCH` | `/applications/{application.id}/emojis/{emoji.id}` | `developers/resources/emoji.mdx` | - |
| Remaining | `PATCH` | `/guilds/{guild.id}/emojis/{emoji.id}` | `developers/resources/emoji.mdx` | - |
| Remaining | `POST` | `/applications/{application.id}/emojis` | `developers/resources/emoji.mdx` | - |
| Remaining | `POST` | `/guilds/{guild.id}/emojis` | `developers/resources/emoji.mdx` | - |
| Remaining | `DELETE` | `/applications/{application.id}/entitlements/{entitlement.id}` | `developers/resources/entitlement.mdx` | - |
| Remaining | `GET` | `/applications/{application.id}/entitlements` | `developers/resources/entitlement.mdx` | - |
| Remaining | `GET` | `/applications/{application.id}/entitlements/{entitlement.id}` | `developers/resources/entitlement.mdx` | - |
| Remaining | `POST` | `/applications/{application.id}/entitlements` | `developers/resources/entitlement.mdx` | - |
| Remaining | `POST` | `/applications/{application.id}/entitlements/{entitlement.id}/consume` | `developers/resources/entitlement.mdx` | - |
| Remaining | `DELETE` | `/guilds/{guild.id}/scheduled-events/{guild_scheduled_event.id}` | `developers/resources/guild-scheduled-event.mdx` | - |
| Remaining | `GET` | `/guilds/{guild.id}/scheduled-events` | `developers/resources/guild-scheduled-event.mdx` | - |
| Remaining | `GET` | `/guilds/{guild.id}/scheduled-events/{guild_scheduled_event.id}` | `developers/resources/guild-scheduled-event.mdx` | - |
| Remaining | `GET` | `/guilds/{guild.id}/scheduled-events/{guild_scheduled_event.id}/users` | `developers/resources/guild-scheduled-event.mdx` | - |
| Remaining | `PATCH` | `/guilds/{guild.id}/scheduled-events/{guild_scheduled_event.id}` | `developers/resources/guild-scheduled-event.mdx` | - |
| Remaining | `POST` | `/guilds/{guild.id}/scheduled-events` | `developers/resources/guild-scheduled-event.mdx` | - |
| Remaining | `DELETE` | `/guilds/{guild.id}/templates/{template.code}` | `developers/resources/guild-template.mdx` | - |
| Remaining | `GET` | `/guilds/templates/{template.code}` | `developers/resources/guild-template.mdx` | - |
| Remaining | `GET` | `/guilds/{guild.id}/templates` | `developers/resources/guild-template.mdx` | - |
| Remaining | `PATCH` | `/guilds/{guild.id}/templates/{template.code}` | `developers/resources/guild-template.mdx` | - |
| Remaining | `POST` | `/guilds/{guild.id}/templates` | `developers/resources/guild-template.mdx` | - |
| Remaining | `PUT` | `/guilds/{guild.id}/templates/{template.code}` | `developers/resources/guild-template.mdx` | - |
| Implemented | `DELETE` | `/guilds/{guild.id}/bans/{user.id}` | `developers/resources/guild.mdx` | RESTClient.deleteGuildBan |
| Remaining | `DELETE` | `/guilds/{guild.id}/integrations/{integration.id}` | `developers/resources/guild.mdx` | - |
| Remaining | `DELETE` | `/guilds/{guild.id}/members/{user.id}` | `developers/resources/guild.mdx` | - |
| Implemented | `DELETE` | `/guilds/{guild.id}/members/{user.id}/roles/{role.id}` | `developers/resources/guild.mdx` | RESTClient.removeGuildMemberRole |
| Implemented | `DELETE` | `/guilds/{guild.id}/roles/{role.id}` | `developers/resources/guild.mdx` | RESTClient.deleteGuildRole |
| Implemented | `GET` | `/guilds/{guild.id}` | `developers/resources/guild.mdx` | RESTClient.getGuild |
| Implemented | `GET` | `/guilds/{guild.id}/bans` | `developers/resources/guild.mdx` | RESTClient.getGuildBans |
| Implemented | `GET` | `/guilds/{guild.id}/bans/{user.id}` | `developers/resources/guild.mdx` | RESTClient.getGuildBan |
| Implemented | `GET` | `/guilds/{guild.id}/channels` | `developers/resources/guild.mdx` | RESTClient.getGuildChannels |
| Remaining | `GET` | `/guilds/{guild.id}/integrations` | `developers/resources/guild.mdx` | - |
| Implemented | `GET` | `/guilds/{guild.id}/invites` | `developers/resources/guild.mdx` | RESTClient.getGuildInvites |
| Implemented | `GET` | `/guilds/{guild.id}/members` | `developers/resources/guild.mdx` | RESTClient.getGuildMembers |
| Implemented | `GET` | `/guilds/{guild.id}/members/search` | `developers/resources/guild.mdx` | RESTClient.searchGuildMembers |
| Implemented | `GET` | `/guilds/{guild.id}/members/{user.id}` | `developers/resources/guild.mdx` | RESTClient.getGuildMember |
| Remaining | `GET` | `/guilds/{guild.id}/onboarding` | `developers/resources/guild.mdx` | - |
| Remaining | `GET` | `/guilds/{guild.id}/preview` | `developers/resources/guild.mdx` | - |
| Implemented | `GET` | `/guilds/{guild.id}/prune` | `developers/resources/guild.mdx` | RESTClient.getGuildPruneCount |
| Remaining | `GET` | `/guilds/{guild.id}/regions` | `developers/resources/guild.mdx` | - |
| Implemented | `GET` | `/guilds/{guild.id}/roles` | `developers/resources/guild.mdx` | RESTClient.getGuildRoles |
| Remaining | `GET` | `/guilds/{guild.id}/roles/member-counts` | `developers/resources/guild.mdx` | - |
| Implemented | `GET` | `/guilds/{guild.id}/roles/{role.id}` | `developers/resources/guild.mdx` | RESTClient.getGuildRole |
| Implemented | `GET` | `/guilds/{guild.id}/threads/active` | `developers/resources/guild.mdx` | RESTClient.getActiveGuildThreads |
| Remaining | `GET` | `/guilds/{guild.id}/vanity-url` | `developers/resources/guild.mdx` | - |
| Remaining | `GET` | `/guilds/{guild.id}/welcome-screen` | `developers/resources/guild.mdx` | - |
| Remaining | `GET` | `/guilds/{guild.id}/widget` | `developers/resources/guild.mdx` | - |
| Remaining | `GET` | `/guilds/{guild.id}/widget.json` | `developers/resources/guild.mdx` | - |
| Remaining | `GET` | `/guilds/{guild.id}/widget.png` | `developers/resources/guild.mdx` | - |
| Implemented | `PATCH` | `/guilds/{guild.id}` | `developers/resources/guild.mdx` | RESTClient.modifyGuild |
| Implemented | `PATCH` | `/guilds/{guild.id}/channels` | `developers/resources/guild.mdx` | RESTClient.modifyGuildChannelPositions |
| Remaining | `PATCH` | `/guilds/{guild.id}/members/@me` | `developers/resources/guild.mdx` | - |
| Remaining | `PATCH` | `/guilds/{guild.id}/members/@me/nick` | `developers/resources/guild.mdx` | - |
| Implemented | `PATCH` | `/guilds/{guild.id}/members/{user.id}` | `developers/resources/guild.mdx` | RESTClient.modifyGuildMember |
| Implemented | `PATCH` | `/guilds/{guild.id}/roles` | `developers/resources/guild.mdx` | RESTClient.modifyGuildRolePositions |
| Implemented | `PATCH` | `/guilds/{guild.id}/roles/{role.id}` | `developers/resources/guild.mdx` | RESTClient.modifyGuildRole |
| Remaining | `PATCH` | `/guilds/{guild.id}/welcome-screen` | `developers/resources/guild.mdx` | - |
| Remaining | `PATCH` | `/guilds/{guild.id}/widget` | `developers/resources/guild.mdx` | - |
| Remaining | `POST` | `/guilds/{guild.id}/bulk-ban` | `developers/resources/guild.mdx` | - |
| Implemented | `POST` | `/guilds/{guild.id}/channels` | `developers/resources/guild.mdx` | RESTClient.createGuildChannel |
| Implemented | `POST` | `/guilds/{guild.id}/prune` | `developers/resources/guild.mdx` | RESTClient.beginGuildPrune |
| Implemented | `POST` | `/guilds/{guild.id}/roles` | `developers/resources/guild.mdx` | RESTClient.createGuildRole |
| Implemented | `PUT` | `/guilds/{guild.id}/bans/{user.id}` | `developers/resources/guild.mdx` | RESTClient.createGuildBan |
| Remaining | `PUT` | `/guilds/{guild.id}/incident-actions` | `developers/resources/guild.mdx` | - |
| Remaining | `PUT` | `/guilds/{guild.id}/members/{user.id}` | `developers/resources/guild.mdx` | - |
| Implemented | `PUT` | `/guilds/{guild.id}/members/{user.id}/roles/{role.id}` | `developers/resources/guild.mdx` | RESTClient.addGuildMemberRole |
| Remaining | `PUT` | `/guilds/{guild.id}/onboarding` | `developers/resources/guild.mdx` | - |
| Implemented | `DELETE` | `/invites/{invite.code}` | `developers/resources/invite.mdx` | RESTClient.deleteInvite |
| Implemented | `GET` | `/invites/{invite.code}` | `developers/resources/invite.mdx` | RESTClient.getInvite |
| Remaining | `GET` | `/invites/{invite.code}/target-users` | `developers/resources/invite.mdx` | - |
| Remaining | `GET` | `/invites/{invite.code}/target-users/job-status` | `developers/resources/invite.mdx` | - |
| Remaining | `PUT` | `/invites/{invite.code}/target-users` | `developers/resources/invite.mdx` | - |
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
| Remaining | `GET` | `/channels/{channel.id}/polls/{message.id}/answers/{answer_id}` | `developers/resources/poll.mdx` | - |
| Remaining | `POST` | `/channels/{channel.id}/polls/{message.id}/expire` | `developers/resources/poll.mdx` | - |
| Remaining | `GET` | `/applications/{application.id}/skus` | `developers/resources/sku.mdx` | - |
| Remaining | `DELETE` | `/guilds/{guild.id}/soundboard-sounds/{sound.id}` | `developers/resources/soundboard.mdx` | - |
| Remaining | `GET` | `/guilds/{guild.id}/soundboard-sounds` | `developers/resources/soundboard.mdx` | - |
| Remaining | `GET` | `/guilds/{guild.id}/soundboard-sounds/{sound.id}` | `developers/resources/soundboard.mdx` | - |
| Remaining | `GET` | `/soundboard-default-sounds` | `developers/resources/soundboard.mdx` | - |
| Remaining | `PATCH` | `/guilds/{guild.id}/soundboard-sounds/{sound.id}` | `developers/resources/soundboard.mdx` | - |
| Remaining | `POST` | `/channels/{channel.id}/send-soundboard-sound` | `developers/resources/soundboard.mdx` | - |
| Remaining | `POST` | `/guilds/{guild.id}/soundboard-sounds` | `developers/resources/soundboard.mdx` | - |
| Remaining | `DELETE` | `/stage-instances/{channel.id}` | `developers/resources/stage-instance.mdx` | - |
| Remaining | `GET` | `/stage-instances/{channel.id}` | `developers/resources/stage-instance.mdx` | - |
| Remaining | `PATCH` | `/stage-instances/{channel.id}` | `developers/resources/stage-instance.mdx` | - |
| Remaining | `POST` | `/stage-instances` | `developers/resources/stage-instance.mdx` | - |
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
| Remaining | `DELETE` | `/users/@me/guilds/{guild.id}` | `developers/resources/user.mdx` | - |
| Implemented | `GET` | `/users/@me` | `developers/resources/user.mdx` | RESTClient.getCurrentUser |
| Remaining | `GET` | `/users/@me/applications/{application.id}/role-connection` | `developers/resources/user.mdx` | - |
| Remaining | `GET` | `/users/@me/connections` | `developers/resources/user.mdx` | - |
| Remaining | `GET` | `/users/@me/guilds` | `developers/resources/user.mdx` | - |
| Remaining | `GET` | `/users/@me/guilds/{guild.id}/member` | `developers/resources/user.mdx` | - |
| Implemented | `GET` | `/users/{user.id}` | `developers/resources/user.mdx` | RESTClient.getUser |
| Remaining | `PATCH` | `/users/@me` | `developers/resources/user.mdx` | - |
| Remaining | `POST` | `/users/@me/channels` | `developers/resources/user.mdx` | - |
| Remaining | `PUT` | `/users/@me/applications/{application.id}/role-connection` | `developers/resources/user.mdx` | - |
| Remaining | `GET` | `/guilds/{guild.id}/voice-states/@me` | `developers/resources/voice.mdx` | - |
| Remaining | `GET` | `/guilds/{guild.id}/voice-states/{user.id}` | `developers/resources/voice.mdx` | - |
| Remaining | `GET` | `/voice/regions` | `developers/resources/voice.mdx` | - |
| Remaining | `PATCH` | `/guilds/{guild.id}/voice-states/@me` | `developers/resources/voice.mdx` | - |
| Remaining | `PATCH` | `/guilds/{guild.id}/voice-states/{user.id}` | `developers/resources/voice.mdx` | - |
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
| Remaining | `POST` | `/webhooks/{webhook.id}/{webhook.token}/github` | `developers/resources/webhook.mdx` | - |
| Remaining | `POST` | `/webhooks/{webhook.id}/{webhook.token}/slack` | `developers/resources/webhook.mdx` | - |
| Remaining | `GET` | `/oauth2/@me` | `developers/topics/oauth2.mdx` | - |
| Remaining | `GET` | `/oauth2/applications/@me` | `developers/topics/oauth2.mdx` | - |
