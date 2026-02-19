# Quick Start: Your First Bot

Get your first bot online in minutes. This "Hello World" example creates a bot that responds to a `!ping` command with `Pong!`.

## The "Hello World" Bot

Create a new Swift file (e.g., `main.swift`) and paste the following code:

```swift
import SWDCK
import Foundation

// 1. Initialize the bot with your secret token
// Ensure you have enabled the MESSAGE_CONTENT intent in the developer portal!
let bot = DiscordBot(
    token: "YOUR_BOT_TOKEN_HERE",
    intents: .default | .messageContent // Include required intents
)

// 2. Register a handler for the 'messageCreate' event
bot.onMessage { message in
    // 3. Ignore messages from other bots (and yourself!)
    guard !message.author.bot else { return }
    
    // 4. Check if the message content is "!ping"
    if message.content.lowercased() == "!ping" {
        // 5. Send a reply back to the same channel
        try await message.reply("Pong! 🏓")
        print("Responded to ping from \(message.author.username)")
    }
}

// 6. Connect to the Discord Gateway
try await bot.start()
```

## Explaining the Code

- **`DiscordBot(token:intents:)`**: The heart of your bot. It takes your token and a set of **Intents** (permissions to receive certain data from Discord).
- **`onMessage`**: A high-level event listener that fires whenever a new message is sent in a channel the bot can see.
- **`guard !message.author.bot`**: Crucial best practice! This prevents infinite loops where your bot reacts to its own messages or other bots.
- **`message.reply(_:)`**: A convenient helper that sends a message back to the same channel, referencing the original message.
- **`bot.start()`**: Connects to Discord and keeps the process running to listen for events.

## How to Run It

1. **Replace** `"YOUR_BOT_TOKEN_HERE"` with your actual token from the Developer Portal.
2. **Terminal**: If using the command line, run `swift run`.
3. **Xcode**: Simply click the **Play** button.

### What to expect
Once running, you should see a log message saying `Gateway IDENTIFY` and eventually `Bot ready!`. Go to your Discord server and type `!ping` — your bot should instantly respond with `Pong!`.

## Common First-Run Errors

#### ❓ The bot comes online but doesn't respond
**Likely Cause:** You forgot to enable the **Message Content Intent** in the Discord Developer Portal or forgot to include `.messageContent` in your `GatewayIntents`.

#### ❓ `Invalid Token` error
**Likely Cause:** Your token is incorrect or has been reset. Double-check it in the portal.

> **Next:** [Core Concepts](./core-concepts)
