# Slash Commands

Slash commands are the modern, recommended way for users to interact with your bot. They provide a native UI in Discord, auto-completion, and better discoverability.

## Registering a Slash Command

Register commands directly on your `DiscordBot` instance. By default, SWDCK will sync these commands globally when the bot starts.

```swift
bot.slashCommand("ping", description: "Get a pong back!") { interaction in
    try await interaction.respond("Pong! 🏓")
}
```

### Command Options

You can define parameters (options) that users can fill out.

```swift
let options = [
    CommandOption(name: "name", description: "Who should I greet?", type: .string, required: true)
]

bot.slashCommand("greet", description: "Say hello to someone", options: options) { interaction in
    let name = interaction.option("name")?.stringValue ?? "there"
    try await interaction.respond("Hello, \(name)!")
}
```

## Handling Interactions

When a user runs a slash command, the `handler` closure is executed. The `Interaction` object provides everything you need to know about the command usage.

### Interaction Properties

| Property | Type | Description |
|----------|------|-------------|
| `user` | `DiscordUser?` | The user who ran the command (in DMs). |
| `member` | `GuildMember?` | The member who ran the command (in a guild). |
| `channelId` | `String?` | Where the command was run. |
| `token` | `String` | The interaction token (used for verification/follow-ups). |

---

## Responding to Interactions

You have several ways to respond to a slash command.

### Immediate Response
Sends a message that is visible to everyone (or just the user).
```swift
try await interaction.respond("Command received!")
```

### Ephemeral Responses
Only the user who ran the command can see these.
```swift
try await interaction.respond("Shh, this is a secret.", ephemeral: true)
```

### Deferring a Response
If your command takes longer than 3 seconds to process, you **must** defer the response. This shows a "Thinking..." state in Discord.
```swift
try await interaction.defer_()
// Perform long task...
try await interaction.editResponse("Finished processing!")
```

### Follow-up Messages
Send additional messages after the initial response.
```swift
try await interaction.respond("Success!")
try await interaction.followUp("And here is something else.")
```

---

## Global vs. Guild Commands

- **Global Commands**: Available in all servers the bot is in and in DMs. (Synced automatically if `commandSyncMode` is `.global`).
- **Guild Commands**: Available only in a specific server. These update instantly, making them great for development.

> 💡 **Tip:** To clear commands during development, use `try await bot.clearSlashCommands(guildId: "YOUR_GUILD_ID")`.

> **Next:** [Components](./components)
