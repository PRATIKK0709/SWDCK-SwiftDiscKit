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

    public func deleteMessage(channelId: String, messageId: String) async throws {
        try await rest.deleteMessage(channelId: channelId, messageId: messageId)
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
