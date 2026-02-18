import Foundation


public typealias MessageHandler     = @Sendable (Message) async throws -> Void
public typealias ReadyHandler       = @Sendable (ReadyData) async throws -> Void
public typealias InteractionHandler = @Sendable (Interaction) async throws -> Void
public typealias VoiceStateUpdateHandler = @Sendable (VoiceState) async throws -> Void
public typealias VoiceServerUpdateHandler = @Sendable (VoiceServerUpdateEvent) async throws -> Void

public enum CommandSyncMode: Sendable {
    case global
    case none
}


public final class DiscordBot: Sendable {


    private let token: String
    private let intents: GatewayIntents
    private let commandSyncMode: CommandSyncMode


    let rest: RESTClient
    private let gateway: GatewayClient
    private let commandRegistry: CommandRegistry


    private let eventState = EventState()


    private let botState = BotState()


    public init(
        token: String,
        intents: GatewayIntents = .default,
        commandSyncMode: CommandSyncMode = .global
    ) {
        self.token = token
        self.intents = intents
        self.commandSyncMode = commandSyncMode
        self.rest = RESTClient(token: token)
        self.gateway = GatewayClient(token: token, intents: intents)
        self.commandRegistry = CommandRegistry()
    }


    public func onMessage(_ handler: @escaping MessageHandler) {
        Task { await eventState.setMessageHandler(handler) }
    }

    public func onReady(_ handler: @escaping ReadyHandler) {
        Task { await eventState.setReadyHandler(handler) }
    }

    public func onInteraction(_ handler: @escaping InteractionHandler) {
        Task { await eventState.setInteractionHandler(handler) }
    }

    public func onVoiceStateUpdate(_ handler: @escaping VoiceStateUpdateHandler) {
        Task { await eventState.setVoiceStateUpdateHandler(handler) }
    }

    public func onVoiceServerUpdate(_ handler: @escaping VoiceServerUpdateHandler) {
        Task { await eventState.setVoiceServerUpdateHandler(handler) }
    }

    public func onGuildCreate(_ handler: @escaping GuildHandler) {
        Task { await eventState.setGuildCreateHandler(handler) }
    }

    public func onGuildUpdate(_ handler: @escaping GuildHandler) {
        Task { await eventState.setGuildUpdateHandler(handler) }
    }

    public func onGuildDelete(_ handler: @escaping GuildDeleteHandler) {
        Task { await eventState.setGuildDeleteHandler(handler) }
    }

    public func onChannelCreate(_ handler: @escaping ChannelHandler) {
        Task { await eventState.setChannelCreateHandler(handler) }
    }

    public func onChannelUpdate(_ handler: @escaping ChannelHandler) {
        Task { await eventState.setChannelUpdateHandler(handler) }
    }

    public func onChannelDelete(_ handler: @escaping ChannelHandler) {
        Task { await eventState.setChannelDeleteHandler(handler) }
    }

    public func onGuildMemberAdd(_ handler: @escaping GuildMemberAddHandler) {
        Task { await eventState.setGuildMemberAddHandler(handler) }
    }

    public func onGuildMemberRemove(_ handler: @escaping GuildMemberRemoveHandler) {
        Task { await eventState.setGuildMemberRemoveHandler(handler) }
    }

    public func onGuildMemberUpdate(_ handler: @escaping GuildMemberUpdateHandler) {
        Task { await eventState.setGuildMemberUpdateHandler(handler) }
    }

    public func onMessageUpdate(_ handler: @escaping MessageUpdateHandler) {
        Task { await eventState.setMessageUpdateHandler(handler) }
    }

    public func onMessageDelete(_ handler: @escaping MessageDeleteHandler) {
        Task { await eventState.setMessageDeleteHandler(handler) }
    }

    public func onMessageReactionAdd(_ handler: @escaping MessageReactionAddHandler) {
        Task { await eventState.setMessageReactionAddHandler(handler) }
    }

    public func onMessageReactionRemove(_ handler: @escaping MessageReactionRemoveHandler) {
        Task { await eventState.setMessageReactionRemoveHandler(handler) }
    }

    public func onTypingStart(_ handler: @escaping TypingStartHandler) {
        Task { await eventState.setTypingStartHandler(handler) }
    }

    public func onPresenceUpdate(_ handler: @escaping PresenceUpdateHandler) {
        Task { await eventState.setPresenceUpdateHandler(handler) }
    }


    public func slashCommand(
        _ name: String,
        description: String,
        options: [CommandOption] = [],
        handler: @escaping @Sendable (Interaction) async throws -> Void
    ) {
        let definition = SlashCommandDefinition(
            name: name,
            description: description,
            options: options.isEmpty ? nil : options
        )
        let commandHandler = SlashCommandHandler(definition: definition, handler: handler)
        Task { await commandRegistry.register(commandHandler) }
    }


    @discardableResult
    public func sendMessage(to channelId: String, content: String) async throws -> Message {
        try await rest.sendMessage(channelId: channelId, content: content)
    }

    @discardableResult
    public func sendMessage(to channelId: String, payload: SendMessagePayload) async throws -> Message {
        try await rest.sendMessage(channelId: channelId, payload: payload)
    }

    @discardableResult
    public func editMessage(channelId: String, messageId: String, content: String) async throws -> Message {
        try await rest.editMessage(channelId: channelId, messageId: messageId, content: content)
    }

    @discardableResult
    public func editMessage(channelId: String, messageId: String, payload: EditMessagePayload) async throws -> Message {
        try await rest.editMessage(channelId: channelId, messageId: messageId, payload: payload)
    }

    public func getCurrentUser() async throws -> DiscordUser {
        try await rest.getCurrentUser()
    }

    public func modifyCurrentUser(_ modify: ModifyCurrentUser) async throws -> DiscordUser {
        try await rest.modifyCurrentUser(modify)
    }

    @discardableResult
    public func sendComponentsV2Message(to channelId: String, components: [ComponentV2Node]) async throws -> Message {
        try await rest.sendComponentsV2Message(channelId: channelId, components: components)
    }

    @discardableResult
    public func sendComponentsV2Message(
        to channelId: String,
        components: [ComponentV2Node],
        attachments: [DiscordFileUpload]
    ) async throws -> Message {
        try await rest.sendComponentsV2Message(
            channelId: channelId,
            components: components,
            attachments: attachments
        )
    }

    public func getChannel(_ channelId: String) async throws -> Channel {
        try await rest.getChannel(channelId: channelId)
    }

    public func addChannelRecipient(channelId: String, userId: String, recipient: GroupDMAddRecipient) async throws {
        try await rest.addChannelRecipient(channelId: channelId, userId: userId, recipient: recipient)
    }

    public func deleteChannelRecipient(channelId: String, userId: String) async throws {
        try await rest.deleteChannelRecipient(channelId: channelId, userId: userId)
    }

    public func modifyChannel(
        channelId: String,
        modify: ModifyChannel,
        auditLogReason: String? = nil
    ) async throws -> Channel {
        try await rest.modifyChannel(
            channelId: channelId,
            modify: modify,
            auditLogReason: auditLogReason
        )
    }

    public func deleteChannel(channelId: String, auditLogReason: String? = nil) async throws -> Channel {
        try await rest.deleteChannel(channelId: channelId, auditLogReason: auditLogReason)
    }

    public func editChannelPermission(
        channelId: String,
        overwriteId: String,
        permission: EditChannelPermission,
        auditLogReason: String? = nil
    ) async throws {
        try await rest.editChannelPermission(
            channelId: channelId,
            overwriteId: overwriteId,
            permission: permission,
            auditLogReason: auditLogReason
        )
    }

    public func deleteChannelPermission(
        channelId: String,
        overwriteId: String,
        auditLogReason: String? = nil
    ) async throws {
        try await rest.deleteChannelPermission(
            channelId: channelId,
            overwriteId: overwriteId,
            auditLogReason: auditLogReason
        )
    }

    public func createWebhook(
        channelId: String,
        webhook: CreateWebhook,
        auditLogReason: String? = nil
    ) async throws -> Webhook {
        try await rest.createWebhook(
            channelId: channelId,
            webhook: webhook,
            auditLogReason: auditLogReason
        )
    }

    public func getChannelWebhooks(_ channelId: String) async throws -> [Webhook] {
        try await rest.getChannelWebhooks(channelId: channelId)
    }

    public func getWebhook(_ webhookId: String) async throws -> Webhook {
        try await rest.getWebhook(webhookId: webhookId)
    }

    public func getWebhook(_ webhookId: String, token: String) async throws -> Webhook {
        try await rest.getWebhook(webhookId: webhookId, token: token)
    }

    public func modifyWebhook(
        webhookId: String,
        modify: ModifyWebhook,
        auditLogReason: String? = nil
    ) async throws -> Webhook {
        try await rest.modifyWebhook(
            webhookId: webhookId,
            modify: modify,
            auditLogReason: auditLogReason
        )
    }

    public func modifyWebhook(webhookId: String, token: String, modify: ModifyWebhook) async throws -> Webhook {
        try await rest.modifyWebhook(webhookId: webhookId, token: token, modify: modify)
    }

    public func deleteWebhook(webhookId: String, auditLogReason: String? = nil) async throws {
        try await rest.deleteWebhook(webhookId: webhookId, auditLogReason: auditLogReason)
    }

    public func deleteWebhook(webhookId: String, token: String) async throws {
        try await rest.deleteWebhook(webhookId: webhookId, token: token)
    }

    @discardableResult
    public func executeWebhook(
        webhookId: String,
        token: String,
        execute: ExecuteWebhook,
        query: ExecuteWebhookQuery = ExecuteWebhookQuery()
    ) async throws -> Message? {
        try await rest.executeWebhook(
            webhookId: webhookId,
            token: token,
            execute: execute,
            query: query
        )
    }

    @discardableResult
    public func executeGitHubWebhook(
        webhookId: String,
        token: String,
        payload: JSONValue,
        query: ExecuteWebhookQuery = ExecuteWebhookQuery()
    ) async throws -> Message? {
        try await rest.executeGitHubWebhook(
            webhookId: webhookId,
            token: token,
            payload: payload,
            query: query
        )
    }

    @discardableResult
    public func executeSlackWebhook(
        webhookId: String,
        token: String,
        payload: JSONValue,
        query: ExecuteWebhookQuery = ExecuteWebhookQuery()
    ) async throws -> Message? {
        try await rest.executeSlackWebhook(
            webhookId: webhookId,
            token: token,
            payload: payload,
            query: query
        )
    }

    public func getWebhookGitHub(webhookId: String, token: String) async throws -> Webhook {
        try await rest.getWebhookGitHub(webhookId: webhookId, token: token)
    }

    public func getWebhookMessage(
        webhookId: String,
        token: String,
        messageId: String,
        query: WebhookMessageQuery = WebhookMessageQuery()
    ) async throws -> Message {
        try await rest.getWebhookMessage(
            webhookId: webhookId,
            token: token,
            messageId: messageId,
            query: query
        )
    }

    public func editWebhookMessage(
        webhookId: String,
        token: String,
        messageId: String,
        edit: EditWebhookMessage,
        query: WebhookMessageQuery = WebhookMessageQuery()
    ) async throws -> Message {
        try await rest.editWebhookMessage(
            webhookId: webhookId,
            token: token,
            messageId: messageId,
            edit: edit,
            query: query
        )
    }

    public func deleteWebhookMessage(
        webhookId: String,
        token: String,
        messageId: String,
        query: WebhookMessageQuery = WebhookMessageQuery()
    ) async throws {
        try await rest.deleteWebhookMessage(
            webhookId: webhookId,
            token: token,
            messageId: messageId,
            query: query
        )
    }

    public func getGateway() async throws -> GatewayInfo {
        try await rest.getGateway()
    }

    public func getGatewayBot() async throws -> GatewayBot {
        try await rest.getGatewayBot()
    }

    public func getChannelInvites(_ channelId: String) async throws -> [Invite] {
        try await rest.getChannelInvites(channelId: channelId)
    }

    public func followAnnouncementChannel(channelId: String, webhookChannelId: String) async throws -> FollowedChannel {
        try await rest.followAnnouncementChannel(
            channelId: channelId,
            follow: FollowAnnouncementChannel(webhookChannelId: webhookChannelId)
        )
    }

    public func createChannelInvite(
        channelId: String,
        invite: CreateChannelInvite = CreateChannelInvite(),
        auditLogReason: String? = nil
    ) async throws -> Invite {
        try await rest.createChannelInvite(
            channelId: channelId,
            invite: invite,
            auditLogReason: auditLogReason
        )
    }

    public func triggerTyping(in channelId: String) async throws {
        try await rest.triggerTyping(channelId: channelId)
    }

    public func startThreadFromMessage(
        channelId: String,
        messageId: String,
        payload: StartThreadFromMessage,
        auditLogReason: String? = nil
    ) async throws -> Channel {
        try await rest.startThreadFromMessage(
            channelId: channelId,
            messageId: messageId,
            payload: payload,
            auditLogReason: auditLogReason
        )
    }

    public func startThreadWithoutMessage(
        channelId: String,
        payload: StartThreadWithoutMessage,
        auditLogReason: String? = nil
    ) async throws -> Channel {
        try await rest.startThreadWithoutMessage(
            channelId: channelId,
            payload: payload,
            auditLogReason: auditLogReason
        )
    }

    public func getPublicArchivedThreads(
        channelId: String,
        query: ArchivedThreadsQuery = ArchivedThreadsQuery()
    ) async throws -> ArchivedThreadsResponse {
        try await rest.getPublicArchivedThreads(channelId: channelId, query: query)
    }

    public func getPrivateArchivedThreads(
        channelId: String,
        query: ArchivedThreadsQuery = ArchivedThreadsQuery()
    ) async throws -> ArchivedThreadsResponse {
        try await rest.getPrivateArchivedThreads(channelId: channelId, query: query)
    }

    public func getJoinedPrivateArchivedThreads(
        channelId: String,
        query: ArchivedThreadsQuery = ArchivedThreadsQuery()
    ) async throws -> ArchivedThreadsResponse {
        try await rest.getJoinedPrivateArchivedThreads(channelId: channelId, query: query)
    }

    public func getThreadMembers(
        channelId: String,
        query: ThreadMembersQuery = ThreadMembersQuery()
    ) async throws -> [ChannelThreadMember] {
        try await rest.getThreadMembers(channelId: channelId, query: query)
    }

    public func getThreadMember(channelId: String, userId: String, withMember: Bool? = nil) async throws -> ChannelThreadMember {
        try await rest.getThreadMember(channelId: channelId, userId: userId, withMember: withMember)
    }

    public func addThreadMember(channelId: String, userId: String) async throws {
        try await rest.addThreadMember(channelId: channelId, userId: userId)
    }

    public func removeThreadMember(channelId: String, userId: String) async throws {
        try await rest.removeThreadMember(channelId: channelId, userId: userId)
    }

    public func joinThread(channelId: String) async throws {
        try await rest.joinThread(channelId: channelId)
    }

    public func leaveThread(channelId: String) async throws {
        try await rest.leaveThread(channelId: channelId)
    }

    public func getActiveGuildThreads(guildId: String) async throws -> ActiveGuildThreadsResponse {
        try await rest.getActiveGuildThreads(guildId: guildId)
    }

    public func getMessagePins(channelId: String, query: MessagePinsQuery = MessagePinsQuery()) async throws -> MessagePinsPage {
        try await rest.getMessagePins(channelId: channelId, query: query)
    }

    public func getPins(_ channelId: String) async throws -> [Message] {
        try await rest.getPins(channelId: channelId)
    }

    public func pinMessage(channelId: String, messageId: String, auditLogReason: String? = nil) async throws {
        try await rest.pinMessage(channelId: channelId, messageId: messageId, auditLogReason: auditLogReason)
    }

    public func pin(channelId: String, messageId: String, auditLogReason: String? = nil) async throws {
        try await rest.pin(channelId: channelId, messageId: messageId, auditLogReason: auditLogReason)
    }

    public func unpinMessage(channelId: String, messageId: String, auditLogReason: String? = nil) async throws {
        try await rest.unpinMessage(channelId: channelId, messageId: messageId, auditLogReason: auditLogReason)
    }

    public func unpin(channelId: String, messageId: String, auditLogReason: String? = nil) async throws {
        try await rest.unpin(channelId: channelId, messageId: messageId, auditLogReason: auditLogReason)
    }

    public func createReaction(channelId: String, messageId: String, emoji: String) async throws {
        try await rest.createReaction(channelId: channelId, messageId: messageId, emoji: emoji)
    }

    public func deleteOwnReaction(channelId: String, messageId: String, emoji: String) async throws {
        try await rest.deleteOwnReaction(channelId: channelId, messageId: messageId, emoji: emoji)
    }

    public func getReactions(
        channelId: String,
        messageId: String,
        emoji: String,
        query: ReactionUsersQuery = ReactionUsersQuery()
    ) async throws -> [DiscordUser] {
        try await rest.getReactions(channelId: channelId, messageId: messageId, emoji: emoji, query: query)
    }

    public func deleteUserReaction(channelId: String, messageId: String, emoji: String, userId: String) async throws {
        try await rest.deleteUserReaction(channelId: channelId, messageId: messageId, emoji: emoji, userId: userId)
    }

    public func deleteAllReactionsForEmoji(channelId: String, messageId: String, emoji: String) async throws {
        try await rest.deleteAllReactionsForEmoji(channelId: channelId, messageId: messageId, emoji: emoji)
    }

    public func deleteAllReactions(channelId: String, messageId: String) async throws {
        try await rest.deleteAllReactions(channelId: channelId, messageId: messageId)
    }

    public func getGuild(_ guildId: String) async throws -> Guild {
        try await rest.getGuild(guildId: guildId)
    }

    public func getGuildAutoModerationRules(_ guildId: String) async throws -> [AutoModerationRule] {
        try await rest.getGuildAutoModerationRules(guildId: guildId)
    }

    public func getGuildAutoModerationRule(guildId: String, ruleId: String) async throws -> AutoModerationRule {
        try await rest.getGuildAutoModerationRule(guildId: guildId, ruleId: ruleId)
    }

    public func createGuildAutoModerationRule(
        guildId: String,
        rule: CreateAutoModerationRule,
        auditLogReason: String? = nil
    ) async throws -> AutoModerationRule {
        try await rest.createGuildAutoModerationRule(
            guildId: guildId,
            rule: rule,
            auditLogReason: auditLogReason
        )
    }

    public func modifyGuildAutoModerationRule(
        guildId: String,
        ruleId: String,
        modify: ModifyAutoModerationRule,
        auditLogReason: String? = nil
    ) async throws -> AutoModerationRule {
        try await rest.modifyGuildAutoModerationRule(
            guildId: guildId,
            ruleId: ruleId,
            modify: modify,
            auditLogReason: auditLogReason
        )
    }

    public func deleteGuildAutoModerationRule(
        guildId: String,
        ruleId: String,
        auditLogReason: String? = nil
    ) async throws {
        try await rest.deleteGuildAutoModerationRule(
            guildId: guildId,
            ruleId: ruleId,
            auditLogReason: auditLogReason
        )
    }

    public func modifyGuild(
        guildId: String,
        modify: ModifyGuild,
        auditLogReason: String? = nil
    ) async throws -> Guild {
        try await rest.modifyGuild(guildId: guildId, modify: modify, auditLogReason: auditLogReason)
    }

    public func getGuildAuditLog(
        _ guildId: String,
        query: GuildAuditLogQuery = GuildAuditLogQuery()
    ) async throws -> GuildAuditLog {
        try await rest.getGuildAuditLog(guildId: guildId, query: query)
    }

    public func getGuildBans(
        _ guildId: String,
        query: GuildBansQuery = GuildBansQuery()
    ) async throws -> [GuildBan] {
        try await rest.getGuildBans(guildId: guildId, query: query)
    }

    public func getGuildBan(guildId: String, userId: String) async throws -> GuildBan {
        try await rest.getGuildBan(guildId: guildId, userId: userId)
    }

    public func createGuildBan(
        guildId: String,
        userId: String,
        ban: CreateGuildBan = CreateGuildBan(),
        auditLogReason: String? = nil
    ) async throws {
        try await rest.createGuildBan(
            guildId: guildId,
            userId: userId,
            ban: ban,
            auditLogReason: auditLogReason
        )
    }

    public func deleteGuildBan(
        guildId: String,
        userId: String,
        auditLogReason: String? = nil
    ) async throws {
        try await rest.deleteGuildBan(
            guildId: guildId,
            userId: userId,
            auditLogReason: auditLogReason
        )
    }

    public func getGuildPruneCount(
        _ guildId: String,
        query: GuildPruneCountQuery = GuildPruneCountQuery()
    ) async throws -> GuildPruneResult {
        try await rest.getGuildPruneCount(guildId: guildId, query: query)
    }

    public func beginGuildPrune(
        _ guildId: String,
        prune: BeginGuildPrune = BeginGuildPrune(),
        auditLogReason: String? = nil
    ) async throws -> GuildPruneResult {
        try await rest.beginGuildPrune(
            guildId: guildId,
            prune: prune,
            auditLogReason: auditLogReason
        )
    }

    public func createGuildChannel(
        guildId: String,
        channel: CreateGuildChannel,
        auditLogReason: String? = nil
    ) async throws -> Channel {
        try await rest.createGuildChannel(
            guildId: guildId,
            channel: channel,
            auditLogReason: auditLogReason
        )
    }

    public func modifyGuildChannelPositions(
        guildId: String,
        positions: [ModifyGuildChannelPosition],
        auditLogReason: String? = nil
    ) async throws {
        try await rest.modifyGuildChannelPositions(
            guildId: guildId,
            positions: positions,
            auditLogReason: auditLogReason
        )
    }

    public func getGuildWebhooks(_ guildId: String) async throws -> [Webhook] {
        try await rest.getGuildWebhooks(guildId: guildId)
    }

    public func getGuildInvites(_ guildId: String) async throws -> [Invite] {
        try await rest.getGuildInvites(guildId: guildId)
    }

    public func getGuildEmojis(_ guildId: String) async throws -> [GuildEmoji] {
        try await rest.getGuildEmojis(guildId: guildId)
    }

    public func getGuildEmoji(guildId: String, emojiId: String) async throws -> GuildEmoji {
        try await rest.getGuildEmoji(guildId: guildId, emojiId: emojiId)
    }

    public func createGuildEmoji(
        guildId: String,
        emoji: CreateGuildEmoji,
        auditLogReason: String? = nil
    ) async throws -> GuildEmoji {
        try await rest.createGuildEmoji(
            guildId: guildId,
            emoji: emoji,
            auditLogReason: auditLogReason
        )
    }

    public func modifyGuildEmoji(
        guildId: String,
        emojiId: String,
        modify: ModifyGuildEmoji,
        auditLogReason: String? = nil
    ) async throws -> GuildEmoji {
        try await rest.modifyGuildEmoji(
            guildId: guildId,
            emojiId: emojiId,
            modify: modify,
            auditLogReason: auditLogReason
        )
    }

    public func deleteGuildEmoji(guildId: String, emojiId: String, auditLogReason: String? = nil) async throws {
        try await rest.deleteGuildEmoji(guildId: guildId, emojiId: emojiId, auditLogReason: auditLogReason)
    }

    public func getGuildTemplate(code: String) async throws -> GuildTemplate {
        try await rest.getGuildTemplate(code: code)
    }

    public func createGuildFromTemplate(code: String, guild: CreateGuildFromTemplate) async throws -> Guild {
        try await rest.createGuildFromTemplate(code: code, guild: guild)
    }

    public func getGuildTemplates(_ guildId: String) async throws -> [GuildTemplate] {
        try await rest.getGuildTemplates(guildId: guildId)
    }

    public func createGuildTemplate(
        guildId: String,
        template: CreateGuildTemplate,
        auditLogReason: String? = nil
    ) async throws -> GuildTemplate {
        try await rest.createGuildTemplate(
            guildId: guildId,
            template: template,
            auditLogReason: auditLogReason
        )
    }

    public func syncGuildTemplate(
        guildId: String,
        code: String,
        auditLogReason: String? = nil
    ) async throws -> GuildTemplate {
        try await rest.syncGuildTemplate(
            guildId: guildId,
            code: code,
            auditLogReason: auditLogReason
        )
    }

    public func modifyGuildTemplate(
        guildId: String,
        code: String,
        modify: ModifyGuildTemplate,
        auditLogReason: String? = nil
    ) async throws -> GuildTemplate {
        try await rest.modifyGuildTemplate(
            guildId: guildId,
            code: code,
            modify: modify,
            auditLogReason: auditLogReason
        )
    }

    public func deleteGuildTemplate(
        guildId: String,
        code: String,
        auditLogReason: String? = nil
    ) async throws -> GuildTemplate {
        try await rest.deleteGuildTemplate(
            guildId: guildId,
            code: code,
            auditLogReason: auditLogReason
        )
    }

    public func getGuildScheduledEvents(
        guildId: String,
        query: GuildScheduledEventsQuery = GuildScheduledEventsQuery()
    ) async throws -> [GuildScheduledEvent] {
        try await rest.getGuildScheduledEvents(guildId: guildId, query: query)
    }

    public func createGuildScheduledEvent(
        guildId: String,
        event: CreateGuildScheduledEvent,
        auditLogReason: String? = nil
    ) async throws -> GuildScheduledEvent {
        try await rest.createGuildScheduledEvent(
            guildId: guildId,
            event: event,
            auditLogReason: auditLogReason
        )
    }

    public func getGuildScheduledEvent(
        guildId: String,
        eventId: String,
        withUserCount: Bool? = nil
    ) async throws -> GuildScheduledEvent {
        try await rest.getGuildScheduledEvent(guildId: guildId, eventId: eventId, withUserCount: withUserCount)
    }

    public func modifyGuildScheduledEvent(
        guildId: String,
        eventId: String,
        modify: ModifyGuildScheduledEvent,
        auditLogReason: String? = nil
    ) async throws -> GuildScheduledEvent {
        try await rest.modifyGuildScheduledEvent(
            guildId: guildId,
            eventId: eventId,
            modify: modify,
            auditLogReason: auditLogReason
        )
    }

    public func deleteGuildScheduledEvent(
        guildId: String,
        eventId: String,
        auditLogReason: String? = nil
    ) async throws {
        try await rest.deleteGuildScheduledEvent(
            guildId: guildId,
            eventId: eventId,
            auditLogReason: auditLogReason
        )
    }

    public func getGuildScheduledEventUsers(
        guildId: String,
        eventId: String,
        query: GuildScheduledEventUsersQuery = GuildScheduledEventUsersQuery()
    ) async throws -> [GuildScheduledEventUser] {
        try await rest.getGuildScheduledEventUsers(guildId: guildId, eventId: eventId, query: query)
    }

    public func getGuildPreview(_ guildId: String) async throws -> GuildPreview {
        try await rest.getGuildPreview(guildId: guildId)
    }

    public func getGuildIntegrations(_ guildId: String) async throws -> [GuildIntegration] {
        try await rest.getGuildIntegrations(guildId: guildId)
    }

    public func deleteGuildIntegration(guildId: String, integrationId: String, auditLogReason: String? = nil) async throws {
        try await rest.deleteGuildIntegration(
            guildId: guildId,
            integrationId: integrationId,
            auditLogReason: auditLogReason
        )
    }

    public func getGuildOnboarding(_ guildId: String) async throws -> GuildOnboarding {
        try await rest.getGuildOnboarding(guildId: guildId)
    }

    public func modifyGuildOnboarding(
        guildId: String,
        onboarding: ModifyGuildOnboarding,
        auditLogReason: String? = nil
    ) async throws -> GuildOnboarding {
        try await rest.modifyGuildOnboarding(
            guildId: guildId,
            payload: onboarding,
            auditLogReason: auditLogReason
        )
    }

    public func getGuildRegions(_ guildId: String) async throws -> [VoiceRegion] {
        try await rest.getGuildRegions(guildId: guildId)
    }

    public func getGuildRoleMemberCounts(_ guildId: String) async throws -> [String: Int] {
        try await rest.getGuildRoleMemberCounts(guildId: guildId)
    }

    public func getGuildVanityURL(_ guildId: String) async throws -> GuildVanityURL {
        try await rest.getGuildVanityURL(guildId: guildId)
    }

    public func getGuildWelcomeScreen(_ guildId: String) async throws -> WelcomeScreen {
        try await rest.getGuildWelcomeScreen(guildId: guildId)
    }

    public func modifyGuildWelcomeScreen(
        guildId: String,
        welcomeScreen: ModifyWelcomeScreen,
        auditLogReason: String? = nil
    ) async throws -> WelcomeScreen {
        try await rest.modifyGuildWelcomeScreen(
            guildId: guildId,
            payload: welcomeScreen,
            auditLogReason: auditLogReason
        )
    }

    public func getGuildWidgetSettings(_ guildId: String) async throws -> GuildWidgetSettings {
        try await rest.getGuildWidgetSettings(guildId: guildId)
    }

    public func modifyGuildWidget(guildId: String, widget: ModifyGuildWidget, auditLogReason: String? = nil) async throws -> GuildWidgetSettings {
        try await rest.modifyGuildWidget(guildId: guildId, payload: widget, auditLogReason: auditLogReason)
    }

    public func getGuildWidget(_ guildId: String) async throws -> GuildWidget {
        try await rest.getGuildWidget(guildId: guildId)
    }

    public func getGuildWidgetImage(_ guildId: String, style: String? = nil) async throws -> Data {
        try await rest.getGuildWidgetImage(guildId: guildId, style: style)
    }

    public func getGuildChannels(_ guildId: String) async throws -> [Channel] {
        try await rest.getGuildChannels(guildId: guildId)
    }

    public func getGuildMembers(_ guildId: String, query: GuildMembersQuery = GuildMembersQuery()) async throws -> [GuildMember] {
        try await rest.getGuildMembers(guildId: guildId, query: query)
    }

    public func searchGuildMembers(_ guildId: String, query: GuildMemberSearchQuery) async throws -> [GuildMember] {
        try await rest.searchGuildMembers(guildId: guildId, query: query)
    }

    public func getGuildMember(guildId: String, userId: String) async throws -> GuildMember {
        try await rest.getGuildMember(guildId: guildId, userId: userId)
    }

    public func modifyCurrentGuildMember(
        guildId: String,
        modify: ModifyCurrentGuildMember,
        reason: String? = nil
    ) async throws -> GuildMember {
        try await rest.modifyCurrentGuildMember(guildId: guildId, modify: modify, auditLogReason: reason)
    }

    public func modifyCurrentGuildNick(guildId: String, nick: String, reason: String? = nil) async throws -> GuildMember {
        try await rest.modifyCurrentGuildNick(
            guildId: guildId,
            modify: ModifyCurrentGuildNick(nick: nick),
            auditLogReason: reason
        )
    }

    public func addGuildMember(guildId: String, userId: String, member: AddGuildMember) async throws -> GuildMember {
        try await rest.addGuildMember(guildId: guildId, userId: userId, add: member)
    }

    public func removeGuildMember(guildId: String, userId: String, reason: String? = nil) async throws {
        try await rest.removeGuildMember(guildId: guildId, userId: userId, auditLogReason: reason)
    }

    public func bulkBanGuildMembers(
        guildId: String,
        userIds: [String],
        deleteMessageSeconds: Int? = nil,
        reason: String? = nil
    ) async throws -> BulkBanResult {
        try await rest.bulkBanGuildMembers(
            guildId: guildId,
            ban: BulkBan(userIds: userIds, deleteMessageSeconds: deleteMessageSeconds),
            auditLogReason: reason
        )
    }

    public func setGuildIncidentActions(
        guildId: String,
        actions: GuildIncidentActions,
        reason: String? = nil
    ) async throws {
        try await rest.setGuildIncidentActions(guildId: guildId, actions: actions, auditLogReason: reason)
    }

    public func modifyGuildMember(
        guildId: String,
        userId: String,
        modify: ModifyGuildMember,
        auditLogReason: String? = nil
    ) async throws -> GuildMember {
        try await rest.modifyGuildMember(
            guildId: guildId,
            userId: userId,
            modify: modify,
            auditLogReason: auditLogReason
        )
    }

    public func addGuildMemberRole(
        guildId: String,
        userId: String,
        roleId: String,
        auditLogReason: String? = nil
    ) async throws {
        try await rest.addGuildMemberRole(
            guildId: guildId,
            userId: userId,
            roleId: roleId,
            auditLogReason: auditLogReason
        )
    }

    public func removeGuildMemberRole(
        guildId: String,
        userId: String,
        roleId: String,
        auditLogReason: String? = nil
    ) async throws {
        try await rest.removeGuildMemberRole(
            guildId: guildId,
            userId: userId,
            roleId: roleId,
            auditLogReason: auditLogReason
        )
    }

    public func getGuildRoles(_ guildId: String) async throws -> [GuildRole] {
        try await rest.getGuildRoles(guildId: guildId)
    }

    public func modifyGuildRolePositions(
        guildId: String,
        positions: [ModifyGuildRolePosition],
        auditLogReason: String? = nil
    ) async throws -> [GuildRole] {
        try await rest.modifyGuildRolePositions(
            guildId: guildId,
            positions: positions,
            auditLogReason: auditLogReason
        )
    }

    public func createGuildRole(
        guildId: String,
        role: CreateGuildRole,
        auditLogReason: String? = nil
    ) async throws -> GuildRole {
        try await rest.createGuildRole(guildId: guildId, role: role, auditLogReason: auditLogReason)
    }

    public func getGuildRole(guildId: String, roleId: String) async throws -> GuildRole {
        try await rest.getGuildRole(guildId: guildId, roleId: roleId)
    }

    public func modifyGuildRole(
        guildId: String,
        roleId: String,
        modify: ModifyGuildRole,
        auditLogReason: String? = nil
    ) async throws -> GuildRole {
        try await rest.modifyGuildRole(
            guildId: guildId,
            roleId: roleId,
            modify: modify,
            auditLogReason: auditLogReason
        )
    }

    public func deleteGuildRole(guildId: String, roleId: String, auditLogReason: String? = nil) async throws {
        try await rest.deleteGuildRole(guildId: guildId, roleId: roleId, auditLogReason: auditLogReason)
    }

    public func deleteInvite(code: String, auditLogReason: String? = nil) async throws -> Invite {
        try await rest.deleteInvite(code: code, auditLogReason: auditLogReason)
    }

    public func getInvite(code: String, query: GetInviteQuery = GetInviteQuery()) async throws -> Invite {
        try await rest.getInvite(code: code, query: query)
    }

    public func getPollAnswerVoters(
        channelId: String,
        messageId: String,
        answerId: String,
        query: PollAnswerVotersQuery = PollAnswerVotersQuery()
    ) async throws -> PollAnswerVotersResponse {
        try await rest.getPollAnswerVoters(
            channelId: channelId,
            messageId: messageId,
            answerId: answerId,
            query: query
        )
    }

    public func expirePoll(channelId: String, messageId: String) async throws -> Message {
        try await rest.expirePoll(channelId: channelId, messageId: messageId)
    }

    public func getInviteTargetUsers(code: String) async throws -> InviteTargetUsersResult {
        try await rest.getInviteTargetUsers(code: code)
    }

    public func getInviteTargetUsersJobStatus(code: String) async throws -> InviteTargetUsersJobStatus {
        try await rest.getInviteTargetUsersJobStatus(code: code)
    }

    public func updateInviteTargetUsers(code: String, users: [String]) async throws -> InviteTargetUsersJobStatus {
        try await rest.updateInviteTargetUsers(code: code, users: InviteTargetUsersUpdate(users: users))
    }

    public func getUser(_ userId: String) async throws -> DiscordUser {
        try await rest.getUser(userId: userId)
    }

    public func getCurrentUserGuilds(query: CurrentUserGuildsQuery = CurrentUserGuildsQuery()) async throws -> [UserGuild] {
        try await rest.getCurrentUserGuilds(query: query)
    }

    public func leaveGuild(_ guildId: String) async throws {
        try await rest.leaveGuild(guildId: guildId)
    }

    public func createDM(recipientId: String) async throws -> Channel {
        try await rest.createDM(CreateDM(recipientId: recipientId))
    }

    public func getCurrentUserConnections() async throws -> [UserConnection] {
        try await rest.getCurrentUserConnections()
    }

    public func getCurrentUserGuildMember(_ guildId: String) async throws -> GuildMember {
        try await rest.getCurrentUserGuildMember(guildId: guildId)
    }

    public func getCurrentUserApplicationRoleConnection(applicationId: String) async throws -> ApplicationRoleConnection {
        try await rest.getCurrentUserApplicationRoleConnection(applicationId: applicationId)
    }

    public func updateCurrentUserApplicationRoleConnection(
        applicationId: String,
        connection: PutApplicationRoleConnection
    ) async throws -> ApplicationRoleConnection {
        try await rest.updateCurrentUserApplicationRoleConnection(applicationId: applicationId, connection: connection)
    }

    public func getCurrentApplication() async throws -> DiscordApplication {
        try await rest.getCurrentApplication()
    }

    public func modifyCurrentApplication(_ modify: ModifyApplication) async throws -> DiscordApplication {
        try await rest.modifyCurrentApplication(modify)
    }

    public func getApplication(_ applicationId: String) async throws -> DiscordApplication {
        try await rest.getApplication(applicationId: applicationId)
    }

    public func modifyApplication(
        _ applicationId: String,
        modify: ModifyApplication
    ) async throws -> DiscordApplication {
        try await rest.modifyApplication(applicationId: applicationId, modify: modify)
    }

    public func getApplicationActivityInstance(
        applicationId: String,
        instanceId: String
    ) async throws -> JSONValue {
        try await rest.getApplicationActivityInstance(applicationId: applicationId, instanceId: instanceId)
    }

    public func getApplicationRoleConnectionMetadata(
        _ applicationId: String
    ) async throws -> [ApplicationRoleConnectionMetadataRecord] {
        try await rest.getApplicationRoleConnectionMetadata(applicationId: applicationId)
    }

    public func getApplicationSKUs(_ applicationId: String) async throws -> [SKU] {
        try await rest.getApplicationSKUs(applicationId: applicationId)
    }

    public func getApplicationEntitlements(
        _ applicationId: String,
        query: EntitlementsQuery = EntitlementsQuery()
    ) async throws -> [Entitlement] {
        try await rest.getApplicationEntitlements(applicationId: applicationId, query: query)
    }

    public func consumeEntitlement(applicationId: String, entitlementId: String) async throws {
        try await rest.consumeEntitlement(applicationId: applicationId, entitlementId: entitlementId)
    }

    public func updateApplicationRoleConnectionMetadata(
        _ applicationId: String,
        records: [ApplicationRoleConnectionMetadataRecord]
    ) async throws -> [ApplicationRoleConnectionMetadataRecord] {
        try await rest.updateApplicationRoleConnectionMetadata(applicationId: applicationId, records: records)
    }

    public func getOAuth2CurrentAuthorization() async throws -> OAuth2Authorization {
        try await rest.getOAuth2CurrentAuthorization()
    }

    public func getOAuth2CurrentApplication() async throws -> DiscordApplication {
        try await rest.getOAuth2CurrentApplication()
    }

    public func getVoiceRegions() async throws -> [VoiceRegion] {
        try await rest.getVoiceRegions()
    }

    public func getCurrentUserVoiceState(guildId: String) async throws -> VoiceState {
        try await rest.getCurrentUserVoiceState(guildId: guildId)
    }

    public func getVoiceState(guildId: String, userId: String) async throws -> VoiceState {
        try await rest.getVoiceState(guildId: guildId, userId: userId)
    }

    public func modifyCurrentUserVoiceState(guildId: String, state: ModifyCurrentUserVoiceState) async throws {
        try await rest.modifyCurrentUserVoiceState(guildId: guildId, state: state)
    }

    public func modifyUserVoiceState(guildId: String, userId: String, state: ModifyUserVoiceState) async throws {
        try await rest.modifyUserVoiceState(guildId: guildId, userId: userId, state: state)
    }

    public func createStageInstance(
        stage: CreateStageInstance,
        auditLogReason: String? = nil
    ) async throws -> StageInstance {
        try await rest.createStageInstance(stage: stage, auditLogReason: auditLogReason)
    }

    public func getStageInstance(channelId: String) async throws -> StageInstance {
        try await rest.getStageInstance(channelId: channelId)
    }

    public func modifyStageInstance(
        channelId: String,
        modify: ModifyStageInstance,
        auditLogReason: String? = nil
    ) async throws -> StageInstance {
        try await rest.modifyStageInstance(
            channelId: channelId,
            modify: modify,
            auditLogReason: auditLogReason
        )
    }

    public func deleteStageInstance(channelId: String, auditLogReason: String? = nil) async throws {
        try await rest.deleteStageInstance(channelId: channelId, auditLogReason: auditLogReason)
    }

    public func getMessage(channelId: String, messageId: String) async throws -> Message {
        try await rest.getMessage(channelId: channelId, messageId: messageId)
    }

    public func crosspostMessage(channelId: String, messageId: String) async throws -> Message {
        try await rest.crosspostMessage(channelId: channelId, messageId: messageId)
    }

    public func getMessages(channelId: String, query: MessageHistoryQuery = MessageHistoryQuery()) async throws -> [Message] {
        try await rest.getMessages(channelId: channelId, query: query)
    }

    public func deleteMessage(channelId: String, messageId: String) async throws {
        try await rest.deleteMessage(channelId: channelId, messageId: messageId)
    }

    public func bulkDeleteMessages(channelId: String, messageIds: [String]) async throws {
        try await rest.bulkDeleteMessages(channelId: channelId, messageIds: messageIds)
    }

    @discardableResult
    public func createSlashCommand(
        _ name: String,
        description: String,
        options: [CommandOption] = [],
        guildId: String? = nil
    ) async throws -> ApplicationCommand {
        let definition = SlashCommandDefinition(
            name: name,
            description: description,
            options: options.isEmpty ? nil : options
        )

        let applicationId = try await resolveApplicationId()
        return try await rest.createSlashCommand(
            applicationId: applicationId,
            command: definition,
            guildId: guildId
        )
    }

    public func syncSlashCommands(guildId: String? = nil) async throws {
        let applicationId = try await resolveApplicationId()
        let definitions = await commandRegistry.allDefinitions()

        if let guildId {
            _ = try await rest.bulkOverwriteGuildCommands(
                applicationId: applicationId,
                guildId: guildId,
                commands: definitions
            )
        } else {
            _ = try await rest.bulkOverwriteGlobalCommands(
                applicationId: applicationId,
                commands: definitions
            )
        }
    }

    public func clearSlashCommands(guildId: String? = nil) async throws {
        let applicationId = try await resolveApplicationId()

        if let guildId {
            _ = try await rest.bulkOverwriteGuildCommands(
                applicationId: applicationId,
                guildId: guildId,
                commands: []
            )
        } else {
            _ = try await rest.bulkOverwriteGlobalCommands(
                applicationId: applicationId,
                commands: []
            )
        }
    }

    public func getSlashCommands(guildId: String? = nil) async throws -> [ApplicationCommand] {
        let applicationId = try await resolveApplicationId()
        if let guildId {
            return try await rest.getGuildCommands(applicationId: applicationId, guildId: guildId)
        }
        return try await rest.getGlobalCommands(applicationId: applicationId)
    }

    public func getSlashCommand(commandId: String, guildId: String? = nil) async throws -> ApplicationCommand {
        let applicationId = try await resolveApplicationId()
        if let guildId {
            return try await rest.getGuildCommand(applicationId: applicationId, guildId: guildId, commandId: commandId)
        }
        return try await rest.getGlobalCommand(applicationId: applicationId, commandId: commandId)
    }

    public func editSlashCommand(
        commandId: String,
        guildId: String? = nil,
        edit: EditApplicationCommand
    ) async throws -> ApplicationCommand {
        let applicationId = try await resolveApplicationId()
        if let guildId {
            return try await rest.editGuildCommand(
                applicationId: applicationId,
                guildId: guildId,
                commandId: commandId,
                command: edit
            )
        }
        return try await rest.editGlobalCommand(
            applicationId: applicationId,
            commandId: commandId,
            command: edit
        )
    }

    public func deleteSlashCommand(commandId: String, guildId: String? = nil) async throws {
        let applicationId = try await resolveApplicationId()
        if let guildId {
            try await rest.deleteGuildCommand(
                applicationId: applicationId,
                guildId: guildId,
                commandId: commandId
            )
            return
        }
        try await rest.deleteGlobalCommand(applicationId: applicationId, commandId: commandId)
    }

    public func getGuildCommandPermissions(guildId: String) async throws -> [GuildApplicationCommandPermissions] {
        let applicationId = try await resolveApplicationId()
        return try await rest.getGuildCommandPermissions(applicationId: applicationId, guildId: guildId)
    }

    public func getCommandPermissions(guildId: String, commandId: String) async throws -> GuildApplicationCommandPermissions {
        let applicationId = try await resolveApplicationId()
        return try await rest.getCommandPermissions(applicationId: applicationId, guildId: guildId, commandId: commandId)
    }

    public func bulkOverwriteGuildCommandPermissions(
        guildId: String,
        permissions: [GuildApplicationCommandPermissions]
    ) async throws -> [GuildApplicationCommandPermissions] {
        let applicationId = try await resolveApplicationId()
        return try await rest.bulkOverwriteGuildCommandPermissions(
            applicationId: applicationId,
            guildId: guildId,
            permissions: permissions
        )
    }

    public func setGuildCommandPermissions(
        guildId: String,
        commandId: String,
        permissions: [ApplicationCommandPermission]
    ) async throws -> GuildApplicationCommandPermissions {
        let applicationId = try await resolveApplicationId()
        let edit = EditGuildApplicationCommandPermissions(permissions: permissions)
        return try await rest.setGuildCommandPermissions(
            applicationId: applicationId,
            guildId: guildId,
            commandId: commandId,
            permissions: edit
        )
    }


    public func start() async throws {
        logger.info("DiscordKit starting up...")

        await gateway.setEventHandlers(
            onReady: { [weak self] ready in
                guard let self else { return }
                await self.botState.set(user: ready.user, applicationId: ready.application.id)
                if self.commandSyncMode == .global {
                    await self.syncCommandsIfNeeded(applicationId: ready.application.id)
                }
                if let handler = await self.eventState.readyHandler {
                    try? await handler(ready)
                }
            },
            onDispatch: { [weak self] eventName, rawJSON in
                guard let self else { return }
                await self.handleDispatch(eventName: eventName, rawJSON: rawJSON)
            }
        )

        let gatewayBot = try await rest.getGatewayBot()
        let shardInfo = gatewayBot.shards.map(String.init) ?? "unspecified"
        logger.info("Gateway recommendation: \(shardInfo) shards, url: \(gatewayBot.url)")

        var components = URLComponents(string: gatewayBot.url)
        var queryItems = components?.queryItems ?? []
        if !queryItems.contains(where: { $0.name == "v" }) {
            queryItems.append(URLQueryItem(name: "v", value: "10"))
        }
        if !queryItems.contains(where: { $0.name == "encoding" }) {
            queryItems.append(URLQueryItem(name: "encoding", value: "json"))
        }
        components?.queryItems = queryItems.isEmpty ? nil : queryItems
        let url = components?.url?.absoluteString ?? "\(gatewayBot.url)?v=10&encoding=json"

        try await gateway.connect(with: url)
    }

    public func stop() async {
        logger.info("DiscordKit shutting down...")
        await gateway.disconnect()
    }

    public func setPresence(
        status: DiscordPresenceStatus,
        activity: DiscordActivity? = nil,
        afk: Bool = false
    ) async throws {
        let update = DiscordPresenceUpdate(
            since: nil,
            activities: activity.map { [$0] } ?? [],
            status: status,
            afk: afk
        )
        try await gateway.updatePresence(update)
    }


    public var currentUser: DiscordUser? {
        get async { await botState.user }
    }

    public var applicationId: String? {
        get async { await botState.applicationId }
    }


    private func handleDispatch(eventName: String, rawJSON: RawJSON) async {
        switch eventName {
        case "MESSAGE_CREATE":
            await handleMessageCreate(rawJSON)
        case "INTERACTION_CREATE":
            await handleInteractionCreate(rawJSON)
        case "VOICE_STATE_UPDATE":
            await handleVoiceStateUpdate(rawJSON)
        case "VOICE_SERVER_UPDATE":
            await handleVoiceServerUpdate(rawJSON)
        case "GUILD_CREATE":
            await handleEvent(rawJSON, type: Guild.self, handler: { await self.eventState.guildCreateHandler }, name: "GUILD_CREATE")
        case "GUILD_UPDATE":
            await handleEvent(rawJSON, type: Guild.self, handler: { await self.eventState.guildUpdateHandler }, name: "GUILD_UPDATE")
        case "GUILD_DELETE":
            await handleEvent(rawJSON, type: GuildDeleteEvent.self, handler: { await self.eventState.guildDeleteHandler }, name: "GUILD_DELETE")
        case "CHANNEL_CREATE":
            await handleEvent(rawJSON, type: Channel.self, handler: { await self.eventState.channelCreateHandler }, name: "CHANNEL_CREATE")
        case "CHANNEL_UPDATE":
            await handleEvent(rawJSON, type: Channel.self, handler: { await self.eventState.channelUpdateHandler }, name: "CHANNEL_UPDATE")
        case "CHANNEL_DELETE":
            await handleEvent(rawJSON, type: Channel.self, handler: { await self.eventState.channelDeleteHandler }, name: "CHANNEL_DELETE")
        case "GUILD_MEMBER_ADD":
            await handleEvent(rawJSON, type: GuildMemberAddEvent.self, handler: { await self.eventState.guildMemberAddHandler }, name: "GUILD_MEMBER_ADD")
        case "GUILD_MEMBER_REMOVE":
            await handleEvent(rawJSON, type: GuildMemberRemoveEvent.self, handler: { await self.eventState.guildMemberRemoveHandler }, name: "GUILD_MEMBER_REMOVE")
        case "GUILD_MEMBER_UPDATE":
            await handleEvent(rawJSON, type: GuildMemberUpdateEvent.self, handler: { await self.eventState.guildMemberUpdateHandler }, name: "GUILD_MEMBER_UPDATE")
        case "MESSAGE_UPDATE":
            await handleMessageUpdate(rawJSON)
        case "MESSAGE_DELETE":
            await handleEvent(rawJSON, type: MessageDeleteEvent.self, handler: { await self.eventState.messageDeleteHandler }, name: "MESSAGE_DELETE")
        case "MESSAGE_REACTION_ADD":
            await handleEvent(rawJSON, type: MessageReactionAddEvent.self, handler: { await self.eventState.messageReactionAddHandler }, name: "MESSAGE_REACTION_ADD")
        case "MESSAGE_REACTION_REMOVE":
            await handleEvent(rawJSON, type: MessageReactionRemoveEvent.self, handler: { await self.eventState.messageReactionRemoveHandler }, name: "MESSAGE_REACTION_REMOVE")
        case "TYPING_START":
            await handleEvent(rawJSON, type: TypingStartEvent.self, handler: { await self.eventState.typingStartHandler }, name: "TYPING_START")
        case "PRESENCE_UPDATE":
            await handleEvent(rawJSON, type: PresenceUpdateEvent.self, handler: { await self.eventState.presenceUpdateHandler }, name: "PRESENCE_UPDATE")
        default:
            logger.debug("Unhandled dispatch: \(eventName)")
        }
    }

    private func handleMessageCreate(_ rawJSON: RawJSON) async {
        guard let handler = await eventState.messageHandler else { return }
        guard var message = try? rawJSON.decode(Message.self) else {
            logger.warning("Failed to decode MESSAGE_CREATE")
            return
        }
        message._rest = rest
        do {
            try await handler(message)
        } catch {
            logger.error("onMessage handler threw: \(error)")
        }
    }

    private func handleInteractionCreate(_ rawJSON: RawJSON) async {
        let decodedInteraction: Interaction
        do {
            decodedInteraction = try rawJSON.decode(Interaction.self)
        } catch {
            let payload = String(data: rawJSON.data, encoding: .utf8) ?? "<unprintable>"
            let preview = payload.count > 1200 ? String(payload.prefix(1200)) + "…" : payload
            logger.warning("Failed to decode INTERACTION_CREATE: \(error). payload=\(preview)")
            return
        }

        var interaction = decodedInteraction
        interaction._rest = rest

        if interaction.type == .applicationCommand {
            await commandRegistry.dispatch(interaction: interaction)
        }

        if let handler = await eventState.interactionHandler {
            do {
                try await handler(interaction)
            } catch {
                logger.error("onInteraction handler threw: \(error)")
            }
        }
    }

    private func handleVoiceStateUpdate(_ rawJSON: RawJSON) async {
        guard let handler = await eventState.voiceStateUpdateHandler else { return }
        let state: VoiceState
        do {
            state = try rawJSON.decode(VoiceState.self)
        } catch {
            logger.warning("Failed to decode VOICE_STATE_UPDATE: \(error)")
            return
        }
        do {
            try await handler(state)
        } catch {
            logger.error("onVoiceStateUpdate handler threw: \(error)")
        }
    }

    private func handleVoiceServerUpdate(_ rawJSON: RawJSON) async {
        guard let handler = await eventState.voiceServerUpdateHandler else { return }
        let event: VoiceServerUpdateEvent
        do {
            event = try rawJSON.decode(VoiceServerUpdateEvent.self)
        } catch {
            logger.warning("Failed to decode VOICE_SERVER_UPDATE: \(error)")
            return
        }
        do {
            try await handler(event)
        } catch {
            logger.error("onVoiceServerUpdate handler threw: \(error)")
        }
    }


    private func syncCommandsIfNeeded(applicationId: String) async {
        let definitions = await commandRegistry.allDefinitions()
        guard !definitions.isEmpty else { return }

        logger.info("Syncing \(definitions.count) slash command(s) to Discord...")
        do {
            let registered = try await rest.bulkOverwriteGlobalCommands(
                applicationId: applicationId,
                commands: definitions
            )
            logger.info("Synced \(registered.count) command(s) globally.")
        } catch {
            logger.error("Failed to sync slash commands: \(error)")
        }
    }

    private func resolveApplicationId() async throws -> String {
        if let readyApplicationId = await botState.applicationId {
            return readyApplicationId
        }
        return try await rest.getApplicationId()
    }

    // MARK: - Generic Event Handler

    private func handleEvent<T: Decodable & Sendable>(
        _ rawJSON: RawJSON,
        type: T.Type,
        handler getHandler: @Sendable () async -> (@Sendable (T) async throws -> Void)?,
        name: String
    ) async {
        guard let handler = await getHandler() else { return }
        let event: T
        do {
            event = try rawJSON.decode(T.self)
        } catch {
            logger.warning("Failed to decode \(name): \(error)")
            return
        }
        do {
            try await handler(event)
        } catch {
            logger.error("on\(name) handler threw: \(error)")
        }
    }

    private func handleMessageUpdate(_ rawJSON: RawJSON) async {
        guard let handler = await eventState.messageUpdateHandler else { return }
        guard var message = try? rawJSON.decode(Message.self) else {
            logger.warning("Failed to decode MESSAGE_UPDATE")
            return
        }
        message._rest = rest
        do {
            try await handler(message)
        } catch {
            logger.error("onMessageUpdate handler threw: \(error)")
        }
    }

    // MARK: - Public Sticker API

    public func getGuildStickers(guildId: String) async throws -> [Sticker] {
        try await rest.getGuildStickers(guildId: guildId)
    }

    public func getGuildSticker(guildId: String, stickerId: String) async throws -> Sticker {
        try await rest.getGuildSticker(guildId: guildId, stickerId: stickerId)
    }

    @discardableResult
    public func createGuildSticker(
        guildId: String,
        sticker: CreateGuildSticker,
        auditLogReason: String? = nil
    ) async throws -> Sticker {
        try await rest.createGuildSticker(guildId: guildId, sticker: sticker, auditLogReason: auditLogReason)
    }

    @discardableResult
    public func modifyGuildSticker(
        guildId: String,
        stickerId: String,
        modify: ModifyGuildSticker,
        auditLogReason: String? = nil
    ) async throws -> Sticker {
        try await rest.modifyGuildSticker(guildId: guildId, stickerId: stickerId, modify: modify, auditLogReason: auditLogReason)
    }

    public func deleteGuildSticker(guildId: String, stickerId: String, auditLogReason: String? = nil) async throws {
        try await rest.deleteGuildSticker(guildId: guildId, stickerId: stickerId, auditLogReason: auditLogReason)
    }

    public func getSticker(stickerId: String) async throws -> Sticker {
        try await rest.getSticker(stickerId: stickerId)
    }

    public func listStickerPacks() async throws -> StickerPacksResponse {
        try await rest.listStickerPacks()
    }
}


private actor EventState {
    var messageHandler: MessageHandler?
    var readyHandler: ReadyHandler?
    var interactionHandler: InteractionHandler?
    var voiceStateUpdateHandler: VoiceStateUpdateHandler?
    var voiceServerUpdateHandler: VoiceServerUpdateHandler?
    var guildCreateHandler: GuildHandler?
    var guildUpdateHandler: GuildHandler?
    var guildDeleteHandler: GuildDeleteHandler?
    var channelCreateHandler: ChannelHandler?
    var channelUpdateHandler: ChannelHandler?
    var channelDeleteHandler: ChannelHandler?
    var guildMemberAddHandler: GuildMemberAddHandler?
    var guildMemberRemoveHandler: GuildMemberRemoveHandler?
    var guildMemberUpdateHandler: GuildMemberUpdateHandler?
    var messageUpdateHandler: MessageUpdateHandler?
    var messageDeleteHandler: MessageDeleteHandler?
    var messageReactionAddHandler: MessageReactionAddHandler?
    var messageReactionRemoveHandler: MessageReactionRemoveHandler?
    var typingStartHandler: TypingStartHandler?
    var presenceUpdateHandler: PresenceUpdateHandler?

    func setMessageHandler(_ h: @escaping MessageHandler)     { messageHandler = h }
    func setReadyHandler(_ h: @escaping ReadyHandler)         { readyHandler = h }
    func setInteractionHandler(_ h: @escaping InteractionHandler) { interactionHandler = h }
    func setVoiceStateUpdateHandler(_ h: @escaping VoiceStateUpdateHandler) { voiceStateUpdateHandler = h }
    func setVoiceServerUpdateHandler(_ h: @escaping VoiceServerUpdateHandler) { voiceServerUpdateHandler = h }
    func setGuildCreateHandler(_ h: @escaping GuildHandler) { guildCreateHandler = h }
    func setGuildUpdateHandler(_ h: @escaping GuildHandler) { guildUpdateHandler = h }
    func setGuildDeleteHandler(_ h: @escaping GuildDeleteHandler) { guildDeleteHandler = h }
    func setChannelCreateHandler(_ h: @escaping ChannelHandler) { channelCreateHandler = h }
    func setChannelUpdateHandler(_ h: @escaping ChannelHandler) { channelUpdateHandler = h }
    func setChannelDeleteHandler(_ h: @escaping ChannelHandler) { channelDeleteHandler = h }
    func setGuildMemberAddHandler(_ h: @escaping GuildMemberAddHandler) { guildMemberAddHandler = h }
    func setGuildMemberRemoveHandler(_ h: @escaping GuildMemberRemoveHandler) { guildMemberRemoveHandler = h }
    func setGuildMemberUpdateHandler(_ h: @escaping GuildMemberUpdateHandler) { guildMemberUpdateHandler = h }
    func setMessageUpdateHandler(_ h: @escaping MessageUpdateHandler) { messageUpdateHandler = h }
    func setMessageDeleteHandler(_ h: @escaping MessageDeleteHandler) { messageDeleteHandler = h }
    func setMessageReactionAddHandler(_ h: @escaping MessageReactionAddHandler) { messageReactionAddHandler = h }
    func setMessageReactionRemoveHandler(_ h: @escaping MessageReactionRemoveHandler) { messageReactionRemoveHandler = h }
    func setTypingStartHandler(_ h: @escaping TypingStartHandler) { typingStartHandler = h }
    func setPresenceUpdateHandler(_ h: @escaping PresenceUpdateHandler) { presenceUpdateHandler = h }
}

private actor BotState {
    var user: DiscordUser?
    var applicationId: String?

    func set(user: DiscordUser, applicationId: String) {
        self.user = user
        self.applicationId = applicationId
    }
}
