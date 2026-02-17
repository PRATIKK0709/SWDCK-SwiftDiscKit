import Foundation


public typealias MessageHandler     = @Sendable (Message) async throws -> Void
public typealias ReadyHandler       = @Sendable (ReadyData) async throws -> Void
public typealias InteractionHandler = @Sendable (Interaction) async throws -> Void

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

    public func joinThread(channelId: String) async throws {
        try await rest.joinThread(channelId: channelId)
    }

    public func leaveThread(channelId: String) async throws {
        try await rest.leaveThread(channelId: channelId)
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

    public func getGuildWebhooks(_ guildId: String) async throws -> [Webhook] {
        try await rest.getGuildWebhooks(guildId: guildId)
    }

    public func getGuildInvites(_ guildId: String) async throws -> [Invite] {
        try await rest.getGuildInvites(guildId: guildId)
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

    public func getUser(_ userId: String) async throws -> DiscordUser {
        try await rest.getUser(userId: userId)
    }

    public func getMessage(channelId: String, messageId: String) async throws -> Message {
        try await rest.getMessage(channelId: channelId, messageId: messageId)
    }

    public func getMessages(channelId: String, query: MessageHistoryQuery = MessageHistoryQuery()) async throws -> [Message] {
        try await rest.getMessages(channelId: channelId, query: query)
    }

    @discardableResult
    public func editMessage(channelId: String, messageId: String, content: String) async throws -> Message {
        try await rest.editMessage(channelId: channelId, messageId: messageId, content: content)
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

        try await gateway.connect()
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
}


private actor EventState {
    var messageHandler: MessageHandler?
    var readyHandler: ReadyHandler?
    var interactionHandler: InteractionHandler?

    func setMessageHandler(_ h: @escaping MessageHandler)     { messageHandler = h }
    func setReadyHandler(_ h: @escaping ReadyHandler)         { readyHandler = h }
    func setInteractionHandler(_ h: @escaping InteractionHandler) { interactionHandler = h }
}

private actor BotState {
    var user: DiscordUser?
    var applicationId: String?

    func set(user: DiscordUser, applicationId: String) {
        self.user = user
        self.applicationId = applicationId
    }
}
