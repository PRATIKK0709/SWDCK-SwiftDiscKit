# Core Concepts

Before building complex features, it's important to understand the mental model behind SWDCK and how it interacts with Discord.

## The `DiscordBot` Object

The `DiscordBot` class is the central hub of your application. It manages the connection to Discord, handles incoming events, and providing access to the REST API. You typically create one instance of this class and use it throughout your bot's lifecycle.

```swift
let bot = DiscordBot(token: "...", intents: .default)
```

## Token

A **Bot Token** is essentially your bot's password. SWDCK uses it to authenticate every request made to Discord. 
> ⚠️ **Warning:** Never hardcode your token in public repositories. Use environment variables or a configuration file instead.

## Intents

**Intents** are a way for your bot to tell Discord exactly which events it wants to receive. This reduces bandwidth and improves performance.
- `.default`: Includes common events like guild joins, channel updates, etc.
- `.messageContent`: Required to read the `content` of messages.
- `.guildMembers`: Required to receive member-related events (privileged).

```swift
// Example: Subscribing to default events + message content
let intents = GatewayIntents.default | .messageContent
```

## Gateway

The **Gateway** is a long-lived WebSocket connection that Discord uses to send real-time events to your bot. SWDCK manages this connection for you, including:
- **Handshaking**: Identifying your bot to Discord.
- **Heartbeating**: Periodically telling Discord the bot is still alive.
- **Resuming**: Automatically reconnecting if the connection drops.

## Async/Await

SWDCK is built from the ground up using modern Swift concurrency. Almost every method that interacts with Discord is `async` and capable of `throwing` errors. This ensures your bot remains responsive and handles network failures gracefully.

```swift
// Everything is async and thread-safe
try await bot.sendMessage(to: "channel_id", content: "Hello!")
```

## Event-Driven Architecture

Instead of constantly asking Discord "Is there a new message?", your bot registers **Handlers** for specific events. When an event occurs, Discord sends it to SWDCK, which then executes your code.

```swift
bot.onMessage { message in 
    print("Received: \(message.content)")
}
```

## Caching
> 🚫 **Not supported:** SWDCK does not currently implement built-in caching for guilds, members, or channels. Every piece of data is provided directly from the Discord event or requested via the REST API.

> **Next:** [Event System](./event-system)
