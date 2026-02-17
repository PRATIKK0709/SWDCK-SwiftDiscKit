import Foundation

actor CommandRegistry {

    private var handlers: [String: SlashCommandHandler] = [:]


    func register(_ handler: SlashCommandHandler) {
        handlers[handler.definition.name] = handler
        logger.info("Registered slash command: /\(handler.definition.name)")
    }

    func allDefinitions() -> [SlashCommandDefinition] {
        handlers.values.map { $0.definition }
    }


    func dispatch(interaction: Interaction) async {
        guard let commandName = interaction.data?.name else {
            logger.warning("Interaction has no command name, ignoring")
            return
        }

        guard let handler = handlers[commandName] else {
            logger.debug("No registered slash handler for /\(commandName)")
            return
        }

        do {
            try await handler.handler(interaction)
        } catch {
            logger.error("Slash command /\(commandName) handler threw: \(error)")
        }
    }
}
