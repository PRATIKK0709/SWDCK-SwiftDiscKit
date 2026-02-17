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

    public func getGatewayBot() async throws -> GatewayBot {
        try await rest.getGatewayBot()
    }

    public func getGuild(_ guildId: String) async throws -> Guild {
        try await rest.getGuild(guildId: guildId)
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
        guard var interaction = try? rawJSON.decode(Interaction.self) else {
            logger.warning("Failed to decode INTERACTION_CREATE")
            return
        }
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
