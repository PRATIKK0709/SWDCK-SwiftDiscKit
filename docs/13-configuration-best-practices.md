# Configuration & Best Practices

Building a reliable bot requires more than just knowing the API. Following these best practices will help you create a stable and secure application.

## Storing Your Token Safely

**Never hardcode your bot token.** If you push your code to GitHub, anyone can see it.

### Recommended: Environment Variables
Use a library like `SwiftDotenv` or simply read from `ProcessInfo`.

```swift
let env = ProcessInfo.processInfo.environment
guard let token = env["DISCORD_TOKEN"] else {
    fatalError("Missing DISCORD_TOKEN in environment")
}
let bot = DiscordBot(token: token, ...)
```

---

## Command Sync Mode

SWDCK offers two modes for syncing slash commands:
- `.global` (Default): Syncs all registered `slashCommand`s to Discord globally. Note that global updates can take up to an hour to propagate.
- `.manual`: You manually control when and where commands are synced using `syncCommandsIfNeeded` or `syncCommands`.

---

## Sharding

Sharding is a way to split your bot's connection across multiple WebSocket connections. This is required by Discord for bots in 2,500+ servers.
**SWDCK handles sharding automatically.** When you call `bot.start()`, the library requests the recommended number of shards from Discord and scales accordingly.

---

## Performance & Concurrency

### Use Actors for State
If your bot needs to keep track of data (like a simple leveling system or a game state), use Swift **Actors** to ensure thread safety.

```swift
actor BotStats {
    var messagesSeen = 0
    func increment() { messagesSeen += 1 }
}
```

### Don't Block the Gateway
The gateway connection is sensitive. Avoid running long-running, CPU-intensive tasks directly in an event handler. Instead, use a background `Task`.

```swift
bot.onMessage { message in
    Task.detached(priority: .background) {
        // Perform heavy work here
    }
}
```

---

## Logging

SWDCK uses a built-in logging system. You can see detailed information about the Gateway connection and REST requests in your console. 

> 💡 **Tip:** Pay attention to logs starting with `[SWDCK]` as they often contain clues about why a connection failed or why a command wasn't registered.

---

## Summary Checklist

- [ ] Token is stored in a secure environment variable.
- [ ] Required Gateway Intents are enabled in the Developer Portal.
- [ ] Message handlers ignore other bots (`!message.author.bot`).
- [ ] Long-running tasks are moved to background tasks.
- [ ] Errors are properly handled with `do-catch` blocks.

> **Next:** [Full Example Bot](./example-bot)
