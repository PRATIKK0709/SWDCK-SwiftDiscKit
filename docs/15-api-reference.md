# API Reference

This page provides a technical overview of the primary classes and methods available in SWDCK.

---

## `DiscordBot`

The main entry point and orchestrator.

### Initializer
- `init(token: String, intents: GatewayIntents = .default, commandSyncMode: CommandSyncMode = .global)`: Creates a new bot instance.

### Methods
- `start() async throws`: Initializes the Gateway connection and starts the bot.
- `onReady(handler: @escaping (ReadyData) -> Void)`: Registers a handler for when the bot comes online.
- `onMessage(handler: @escaping (Message) -> Void)`: Registers a handler for new messages.
- `onInteraction(handler: @escaping (Interaction) -> Void)`: Registers a generic interaction handler.
- `slashCommand(_ name: String, description: String, options: [CommandOption] = [], handler: @escaping (Interaction) -> Void)`: Registers a slash command.

---

## `Message`

Represents a Discord message.

### Properties
- `id: String`: Unique ID.
- `content: String`: Text content.
- `author: DiscordUser`: User who sent the message.
- `channelId: String`: ID of the channel.
- `member: GuildMember?`: Member info (if in a guild).

### Methods
- `reply(_ content: String) async throws -> Message`: Sends a reply referencing this message.
- `respond(_ content: String) async throws -> Message`: Sends a message back to the same channel.

---

## `Interaction`

Represents an interaction (slash command or component).

### Properties
- `id: String`: Unique ID.
- `type: InteractionType`: `.applicationCommand`, `.messageComponent`, etc.
- `data: InteractionData?`: Payload containing command name, options, or custom ID.

### Methods
- `respond(_ content: String, ephemeral: Bool = false) async throws`: Sends an immediate response.
- `defer_() async throws`: Defers the response (shows "Thinking...").
- `editResponse(_ content: String) async throws`: Updates the deferred or original response.
- `presentModal(customId: String, title: String, components: [ComponentV2Node]) async throws`: Shows a pop-up modal.

---

## `EmbedBuilder`

Helpful builder for creating rich embeds.

### Methods
- `setTitle(_ title: String) -> EmbedBuilder`
- `setDescription(_ description: String) -> EmbedBuilder`
- `setColor(_ color: Int) -> EmbedBuilder`
- `addField(name: String, value: String, inline: Bool = false) -> EmbedBuilder`
- `build() -> Embed`: Returns the final `Embed` object.

---

> 💡 **Notice:** For a complete list of all models and REST methods, please refer to the source code or use Xcode's **Quick Help (Opt+Click)** feature.
