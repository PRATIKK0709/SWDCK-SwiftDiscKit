# Event System

SWDCK uses an event-driven model. Your bot waits for "Dispatch" events from Discord (like a new message, a user joining, or a reaction) and reacts to them using registered handlers.

## Registering Event Handlers

You register handlers using specific methods on the `DiscordBot` object. Each method takes a closure that is executed when the event occurs.

```swift
bot.onReady { readyData in
    print("Bot is online as \(readyData.user.username)")
}

bot.onMessage { message in
    print("New message: \(message.content)")
}
```

## Async Event Handlers

All event handlers in SWDCK are **asynchronous**. This means you can perform network requests or other async operations directly inside the handler without blocking the rest of the bot.

```swift
bot.onMessage { message in
    // You can call async methods here
    try await message.reply("I received your message!")
}
```

## How Multiple Handlers Work

> ⚠️ **Needs verification:** Currently, calling an event registration method multiple times (e.g., calling `onMessage` twice) will **overwrite** the previous handler. It is recommended to have a single entry point for each event type and delegate the logic internally if needed.

## Event Reference Table

| Event Method | When It Fires | Payload Type | Key Fields |
|--------------|--------------|--------------|------------|
| `onReady` | Bot successfully connected and identified. | `ReadyData` | `user`, `guilds`, `sessionId` |
| `onMessage` | A new message is created. | `Message` | `content`, `author`, `channelId` |
| `onMessageUpdate` | A message is edited. | `Message` | `id`, `content`, `channelId` |
| `onMessageDelete` | A message is deleted. | `MessageDelete` | `id`, `channelId`, `guildId` |
| `onInteraction` | A slash command or component is used. | `Interaction` | `type`, `data`, `token` |
| `onGuildCreate` | Bot joins a guild or guild becomes available. | `Guild` | `id`, `name`, `roles` |
| `onMemberAdd` | A user joins a guild. | `GuildMemberAdd` | `user`, `guildId` |
| `onReactionAdd` | A reaction is added to a message. | `MessageReaction` | `userId`, `messageId`, `emoji` |

## Example: Handling Multiple Events

```swift
let bot = DiscordBot(token: "...", intents: .default | .messageContent)

bot.onReady { ready in
    print("Logged in as \(ready.user.username)")
}

bot.onMessage { message in
    if message.content == "!hello" {
        try await message.reply("Hello there!")
    }
}

try await bot.start()
```

> **Next:** [Messages](./messages)
