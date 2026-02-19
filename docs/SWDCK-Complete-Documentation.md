--- DOCUMENTATION START: 01-introduction.md ---

# Introduction & Overview

**SWDCK** (SwiftDiscKit) is a high-performance, modern Discord bot framework written entirely in Swift. It leverages Swift's powerful concurrency model (`async/await`) to provide a seamless and efficient developer experience for building everything from simple notification bots to complex, interactive community tools.

Built from the ground up to be lightweight yet feature-rich, SWDCK handles the complexities of the Discord Gateway and REST API, allowing you to focus on your bot's unique logic.

## Why use SWDCK?

Compared to other Discord libraries in the Swift ecosystem, SWDCK prioritizes:

- **Modern Swift Concurrency**: Fully built on `async/await` and `Actors`, ensuring thread safety and readable asynchronous code.
- **Type Safety**: Comprehensive models for Discord entities (Messages, Interactions, Guilds, etc.) reduce runtime errors.
- **Developer Productivity**: A clean, intuitive API that feels "Swifty" and follows modern best practices.
- **Rich Interaction Support**: First-class support for Slash Commands and the powerful "Components V2" system.

## Feature Highlights

| Feature | Description |
|---------|-------------|
| **Gateway Support** | Automatic connection management, heartbeat, and reconnection logic. |
| **Slash Commands** | Easy registration and handling of global and guild-scoped commands. |
| **Event System** | Type-safe closures for handling messages, member updates, and more. |
| **Components V2** | Support for modern UI elements like buttons, select menus, and modals. |
| **Rich Embeds** | A flexible builder for creating beautiful, formatted messages. |
| **Full API Mapping** | Access to almost every Discord REST endpoint via a clean interface. |

## Requirements

To build and run a bot with SWDCK, you'll need:

- **Swift Version**: 5.9 or higher
- **Platform**: macOS 14.0+ or iOS 17.0+
- **Discord API**: v10 (handled automatically by the library)

---

## Documentation Map

- [Installation](./installation) — Get set up and connected.
- [Quick Start](./quick-start) — Your first "Hello World" bot.
- [Core Concepts](./core-concepts) — Understanding the SWDCK mental model.
- [Event System](./event-system) — Listen and react to Discord events.
- [Messages](./messages) — Reading and sending messages.
- [Embeds](./embeds) — Creating rich, formatted content.
- [Slash Commands](./slash-commands) — Modern interactions.
- [Components](./components) — Buttons, Selects, and Modals.
- [API Reference](./api-reference) — Exhaustive technical documentation.

> **Next:** [Installation](./installation)

--- DOCUMENTATION END: 01-introduction.md ---



--- DOCUMENTATION START: 02-installation.md ---

# Installation

Set up your development environment and get SWDCK added to your project.

## Prerequisites

Before diving in, ensure you have the following:

- **Xcode 15.0** or later.
- **Swift 5.9** or later.
- A **Discord Account** and access to the [Discord Developer Portal](https://discord.com/developers/applications).

## Discord Setup

### 1. Create an Application
1. Go to the [Discord Developer Portal](https://discord.com/developers/applications).
2. Click **New Application** and give it a name.
3. On the left sidebar, click **Bot**.
4. Click **Reset Token** (or **Copy Token**) to get your bot token. 
   > ⚠️ **Warning:** Keep this token secret! Anyone with it can control your bot.

### 2. Enable Privileged Intents
For your bot to receive messages or track member updates, you must enable specific **Intents**:
1. In the **Bot** tab of your application, scroll down to **Privileged Gateway Intents**.
2. Enable **MESSAGE CONTENT INTENT** (required for reading message content).
3. Enable **GUILD MEMBERS INTENT** (if you need to track members).
4. Click **Save Changes**.

### 3. Invite the Bot
1. Go to **OAuth2** -> **URL Generator**.
2. Select the `bot` and `applications.commands` scopes.
3. Select the permissions your bot needs (e.g., `Send Messages`, `Use Slash Commands`).
4. Copy the generated URL and open it in your browser to invite the bot to your server.

---

## Swift Package Manager Setup

SWDCK is distributed as a Swift Package. You can add it via Xcode or your `Package.swift` file.

### Via Xcode
1. Open your project in Xcode.
2. Select **File > Add Package Dependencies...**
3. Enter the repository URL: `https://github.com/PRATIKK0709/SWDCK--SwiftDiscKit`
4. Set the Dependency Rule to **Branch: main** (or a specific version if available).
5. Select the `SWDCK` library and click **Add Package**.

### Via Package.swift
Add the dependency to your `Package.swift` file:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyBot",
    dependencies: [
        .package(url: "https://github.com/PRATIKK0709/SWDCK--SwiftDiscKit", branch: "main")
    ],
    targets: [
        .executableTarget(
            name: "MyBot",
            dependencies: [
                .product(name: "SWDCK", package: "SWDCK")
            ]
        )
    ]
)
```

## Verifying Installation

Try to import the library in your main file to ensure everything is linked correctly:

```swift
import SWDCK

print("SWDCK is ready!")
```

> 💡 **Tip:** If you encounter build errors, double-check that your target platform is set to macOS 14.0+ or iOS 17.0+.

> **Next:** [Quick Start: Your First Bot](./quick-start)

--- DOCUMENTATION END: 02-installation.md ---



--- DOCUMENTATION START: 03-quick-start.md ---

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

--- DOCUMENTATION END: 03-quick-start.md ---



--- DOCUMENTATION START: 04-core-concepts.md ---

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

--- DOCUMENTATION END: 04-core-concepts.md ---



--- DOCUMENTATION START: 05-event-system.md ---

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

--- DOCUMENTATION END: 05-event-system.md ---



--- DOCUMENTATION START: 06-messages.md ---

# Messages

Messages are the primary way users interact with your bot. In SWDCK, the `Message` object contains everything you need to know about a message and provides convenient helpers to respond.

## Receiving a Message

The `onMessage` handler is triggered whenever a message is sent in a channel your bot can see.

```swift
bot.onMessage { message in
    print("Author: \(message.author.username)")
    print("Content: \(message.content)")
    print("Channel ID: \(message.channelId)")
}
```

### Key Properties

The `Message` object exposes several important fields:

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | The unique ID of the message. |
| `content` | `String` | The text content of the message. |
| `author` | `DiscordUser` | The user who sent the message. |
| `channelId` | `String` | The ID of the channel where it was sent. |
| `guildId` | `String?` | The ID of the guild (if not a DM). |
| `timestamp` | `String` | When the message was sent (ISO8601). |

---

## Best Practice: Ignoring Bots

You should almost always ignore messages sent by bots (including your own bot) to prevent infinite loops.

```swift
bot.onMessage { message in
    guard !message.author.bot else { return }
    // Your logic here
}
```

---

## Sending Messages

You can send messages using the `DiscordBot` instance or by responding to an existing message.

### Sending to a Specific Channel
Use `bot.sendMessage(to:content:)` to send a message to any channel if you have the ID.

```swift
try await bot.sendMessage(to: "123456789", content: "Hello from the bot!")
```

### Replying to a Message
The `message.reply(_:)` helper sends a message back to the same channel and creates a Discord-style reply (referencing the original message).

```swift
bot.onMessage { message in
    if message.content.contains("ping") {
        try await message.reply("Pong!")
    }
}
```

### Plain Response
If you want to send a message back to the same channel without the "reply" reference, use `message.respond(_:)`.

```swift
try await message.respond("I'm responding to you!")
```

---

## Editing & Deleting

### Editing a Message
You can edit a message the bot has sent using its `id`.

```swift
let sentMessage = try await bot.sendMessage(to: "...", content: "Original text")
try await bot.editMessage(channelId: sentMessage.channelId, messageId: sentMessage.id, content: "Edited text!")
```

### Deleting a Message
Likewise, you can delete a message using its `id`.

```swift
try await bot.deleteMessage(channelId: message.channelId, messageId: message.id)
```

---

## Files & Attachments

> ⚠️ **Needs verification:** SWDCK supports sending files via `sendComponentsV2Message` using `DiscordFileUpload` objects.

```swift
let file = DiscordFileUpload(filename: "hello.txt", data: "Hello World".data(using: .utf8)!)
try await bot.sendComponentsV2Message(to: message.channelId, components: [], attachments: [file])
```

> **Next:** [Embeds](./embeds)

--- DOCUMENTATION END: 06-messages.md ---



--- DOCUMENTATION START: 07-embeds.md ---

# Embeds

Embeds allow you to send rich, formatted content that looks more professional than plain text. They are perfect for status reports, help menus, and server logs.

## Using `EmbedBuilder`

SWDCK provides a convenient `EmbedBuilder` to construct complex embeds step by step.

```swift
var builder = EmbedBuilder()
builder.setTitle("Server Statistics")
builder.setDescription("Current performance metrics for the bot.")
builder.setColor(0x00ff00) // Green
builder.addField(name: "Uptime", value: "3 days, 4 hours", inline: true)
builder.addField(name: "Guilds", value: "150", inline: true)
builder.setFooter("Last updated at 12:00 PM")

let embed = builder.build()
```

## Field Reference Table

| Property | Method in Builder | Description | Limit |
|----------|-------------------|-------------|-------|
| `title` | `setTitle()` | The bold title at the top. | 256 chars |
| `description` | `setDescription()` | The main body text. | 4096 chars |
| `url` | `setURL()` | Makes the title a clickable link. | - |
| `color` | `setColor()` | The colored strip on the left (Integer hex). | - |
| `fields` | `addField()` | Key-value pairs of data. | 25 fields |
| `footer` | `setFooter()` | Small text at the bottom. | 2048 chars |
| `author` | `setAuthor()` | Small header with name and icon. | 256 chars |
| `image` | `setImage()` | A large image at the bottom. | - |
| `thumbnail` | `setThumbnail()` | A small image in the top-right. | - |
| `timestamp` | `setTimestamp()` | An ISO8601 timestamp in the footer. | - |

---

## Sending an Embed

You can send an embed as part of a message payload.

### In a new message
```swift
let embed = EmbedBuilder()
    .setTitle("Hello!")
    .build()

let payload = SendMessagePayload(content: "Check this out:", embeds: [embed])
try await bot.sendMessage(to: channelId, payload: payload)
```

### In a reply
```swift
bot.onMessage { message in
    if message.content == "!stats" {
        let embed = EmbedBuilder()
            .setTitle("Stats")
            .setDescription("Looking good!")
            .build()
        
        // You can pass an array of embeds to the payload
        let payload = SendMessagePayload(embeds: [embed])
        try await bot.rest.sendMessage(channelId: message.channelId, payload: payload)
    }
}
```

---

## Common Mistakes

- **Invalid Colors**: Colors must be integers. Use hex literals like `0xFF0000` for red.
- **Empty Fields**: Fields must have both a `name` and a `value` that are non-empty strings.
- **Character Limits**: Discord strictly enforces character limits. If you exceed them, the message will fail to send.

> **Next:** [Slash Commands](./slash-commands)

--- DOCUMENTATION END: 07-embeds.md ---



--- DOCUMENTATION START: 08-slash-commands.md ---

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

--- DOCUMENTATION END: 08-slash-commands.md ---



--- DOCUMENTATION START: 09-components.md ---

# Components (Buttons, Selects & Modals)

Components V2 is SWDCK's powerful system for building interactive UIs within Discord messages. This includes buttons, dropdown menus, and pop-up modals.

## Buttons

Buttons are the most common component. They can trigger an interaction or open a link.

```swift
let button = ComponentV2Button(
    style: .primary,
    label: "Click Me",
    customId: "my_button_id"
)

let actionRow = ComponentV2ActionRow(components: [.button(button)])
try await bot.sendComponentsV2Message(to: channelId, components: [.actionRow(actionRow)])
```

### Button Styles
| Style | Description |
|-------|-------------|
| `.primary` | Blurple (main action). |
| `.secondary` | Grey (secondary action). |
| `.success` | Green (positive outcome). |
| `.danger` | Red (destructive action). |
| `.link` | Grey with a link icon (requires a `url`). |

---

## Select Menus

Select menus allow users to choose from a list of options.

```swift
let select = ComponentV2StringSelect(
    customId: "color_picker",
    options: [
        ComponentV2SelectOption(label: "Red", value: "red"),
        ComponentV2SelectOption(label: "Blue", value: "blue")
    ],
    placeholder: "Choose a color"
)

let actionRow = ComponentV2ActionRow(components: [.stringSelect(select)])
try await bot.sendComponentsV2Message(to: channelId, components: [.actionRow(actionRow)])
```

---

## Handling Component Interactions

When a user clicks a button or selects an option, it triggers an interaction. Listen for these using `onInteraction`.

```swift
bot.onInteraction { interaction in
    guard interaction.type == .messageComponent else { return }
    
    if interaction.data?.customId == "my_button_id" {
        try await interaction.respond("You clicked the button!")
    }
}
```

---

## Modals

Modals are pop-up forms that can gather text input from the user.

### Presenting a Modal
Modals must be sent as a response to an interaction (e.g., a button click or a slash command).

```swift
bot.slashCommand("report", description: "Report an issue") { interaction in
    let input = ComponentV2TextInput(
        customId: "issue_desc",
        style: .paragraph,
        placeholder: "Describe the problem..."
    )
    
    let container = ComponentV2Label(
        label: "Issue Description",
        component: .textInput(input)
    )
    
    try await interaction.presentModal(
        customId: "report_modal",
        title: "Submit Report",
        components: [container]
    )
}
```

### Handling Modal Submission

```swift
bot.onInteraction { interaction in
    guard interaction.type == .modalSubmit else { return }
    
    if interaction.data?.customId == "report_modal" {
        let description = interaction.data?.submittedValue(customId: "issue_desc")?.stringValue
        try await interaction.respond("Thank you for your report: \(description ?? "N/A")", ephemeral: true)
    }
}
```

> **Next:** [Permissions & Roles](./permissions-roles)

--- DOCUMENTATION END: 09-components.md ---



--- DOCUMENTATION START: 10-permissions-roles.md ---

# Permissions & Roles

Discord uses a bitwise permission system to control what users and bots can do. In SWDCK, permissions are represented as strings containing large integers to maintain precision.

## Roles

A `GuildRole` object contains the name, color, and permissions for a specific role in a server.

```swift
bot.onGuildCreate { guild in
    for role in guild.roles ?? [] {
        print("Role: \(role.name), Color: \(role.color)")
    }
}
```

### Key Role Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Unique ID of the role. |
| `name` | `String` | Role name. |
| `color` | `Int` | Integer color (e.g., `0x3498db`). |
| `permissions` | `String` | Bitwise permission flags as a string. |
| `position` | `Int` | Ranking in the role hierarchy. |

---

## Checking Permissions

To check if a member has a specific permission, you'll need to convert the permission string to a numerical value and use bitwise operations.

```swift
// Common Permission Constants (Bit Positions)
enum Permission: UInt64 {
    case administrator = 0x8
    case manageChannels = 0x10
    case kickMembers = 0x2
    case banMembers = 0x4
}

func hasPermission(_ member: GuildMember, permission: Permission) -> Bool {
    guard let permString = member.permissions,
          let permValue = UInt64(permString) else { return false }
    
    return (permValue & permission.rawValue) != 0
}
```

> 💡 **Tip:** Detailed permission bit definitions can be found in the [Discord API Documentation](https://discord.com/developers/docs/topics/permissions#permissions-bitwise-value).

---

## Managing Roles

### Creating a Role
```swift
try await bot.createGuildRole(guildId: "...", name: "New Role", color: 0xFF0000)
```

### Modifying a Role
```swift
try await bot.modifyGuildRole(guildId: "...", roleId: "...", name: "Updated Name")
```

### Assigning a Role to a Member
```swift
try await bot.addGuildMemberRole(guildId: "...", userId: "...", roleId: "...")
```

### Removing a Role
```swift
try await bot.removeGuildMemberRole(guildId: "...", userId: "...", roleId: "...")
```

> **Next:** [Guilds, Channels & Members](./guilds-channels-members)

--- DOCUMENTATION END: 10-permissions-roles.md ---



--- DOCUMENTATION START: 11-guilds-channels-members.md ---

# Guilds, Channels & Members

Understanding how Discord structures servers (Guilds) and the entities within them is key to building advanced bots.

## Guilds (Servers)

A `Guild` represents a Discord server. It is the top-level container for channels, members, and roles.

```swift
bot.onGuildCreate { guild in
    print("Available in guild: \(guild.name) (\(guild.id))")
    print("Member count: \(guild.memberCount ?? 0)")
}
```

### Common Guild Operations
- **Fetch a Guild**: `try await bot.getGuild(id: "...")`
- **Leave a Guild**: `try await bot.leaveGuild(id: "...")`
- **Get Audit Logs**: `try await bot.getGuildAuditLog(guildId: "...")`

---

## Channels

Channels are where the action happens. They can be text-based, voice-based, or categories.

### Channel Types
| Type | Description |
|------|-------------|
| `.guildText` | Standard text channel. |
| `.guildVoice` | Standard voice channel. |
| `.guildCategory` | A folder-like container for other channels. |
| `.guildAnnouncement` | News channel. |
| `.publicThread` / `.privateThread` | Threads within a text channel. |

### Channel Operations
- **Fetch a Channel**: `try await bot.getChannel(id: "...")`
- **Modify a Channel**: `try await bot.modifyChannel(id: "...", name: "new-name")`
- **Delete a Channel**: `try await bot.deleteChannel(id: "...")`

---

## Members vs. Users

In SWDCK (and Discord), there is a distinction between a **User** and a **Member**.

- **`DiscordUser`**: Represents a global Discord user (ID, username, avatar).
- **`GuildMember`**: Represents a user *specific to a server* (nickname, joined date, roles).

```swift
bot.onMessage { message in
    let user = message.author       // Global user info
    let member = message.member    // Server-specific info (roles, nick)
    
    print("\(user.username) is also known as \(member?.nick ?? "none") here.")
}
```

### Member Operations
- **Fetch a Member**: `try await bot.getGuildMember(guildId: "...", userId: "...")`
- **Modify a Member**: `try await bot.modifyGuildMember(guildId: "...", userId: "...", nick: "New Nick")`
- **Kick a Member**: `try await bot.removeGuildMember(guildId: "...", userId: "...")`
- **Ban a Member**: `try await bot.createGuildBan(guildId: "...", userId: "...")`

---

## Hierarchy Recap

1. **Guild**: The server container.
2. **Channel**: A specific place for messaging or talking.
3. **Role**: A set of permissions.
4. **Member**: A user within a guild, assigned one or more roles.

> **Next:** [Error Handling](./error-handling)

--- DOCUMENTATION END: 11-guilds-channels-members.md ---



--- DOCUMENTATION START: 12-error-handling.md ---

# Error Handling

Network requests can fail, permissions can be missing, and Discord can apply rate limits. SWDCK uses Swift's error handling system (`throws`) to help you catch and manage these situations.

## `DiscordError`

Most failures in SWDCK throw a `DiscordError` enum. This includes both local validation errors and errors returned by the Discord API.

### Common Error Cases

| Case | Description |
|------|-------------|
| `.invalidToken` | Your bot token is wrong or expired. |
| `.rateLimited(retryAfter:)` | You are sending requests too fast. Wait `retryAfter` seconds. |
| `.missingPermissions(endpoint:)` | The bot doesn't have the permission required for that action. |
| `.resourceNotFound(endpoint:)` | The ID you provided (channel, user, etc.) doesn't exist. |
| `.decodingFailed(type:underlying:)` | Discord sent unexpected data that the library couldn't parse. |

---

## Handling Errors in Async/Await

Since most methods are `async`, you should wrap them in `do-catch` blocks.

```swift
do {
    try await bot.sendMessage(to: "invalid_id", content: "Hello")
} catch let error as DiscordError {
    switch error {
    case .missingPermissions:
        print("I don't have permission to send messages there!")
    case .resourceNotFound:
        print("That channel doesn't exist.")
    default:
        print("Discord Error: \(error.localizedDescription)")
    }
} catch {
    print("Unexpected error: \(error)")
}
```

---

## Handling Rate Limits

SWDCK does not automatically retry rate-limited requests yet. When you receive a `.rateLimited` error, it is your responsibility to wait and retry if desired.

```swift
func safeSend(_ content: String, to channelId: String) async {
    do {
        try await bot.sendMessage(to: channelId, content: content)
    } catch DiscordError.rateLimited(let retryAfter) {
        print("Rate limited! Retrying in \(retryAfter) seconds...")
        try? await Task.sleep(nanoseconds: UInt64(retryAfter * 1_000_000_000))
        await safeSend(content, to: channelId) // Recursive retry
    } catch {
        print("Failed to send: \(error)")
    }
}
```

---

## Gateway Disconnections

If the WebSocket connection drops, SWDCK will attempt to reconnect automatically. You can monitor these events by listening for `onGatewayDisconnect` (if implemented) or by checking the bot's logs.

> 💡 **Tip:** Always check your bot's logs if it suddenly stops responding. SWDCK logs detailed error information to the console.

> **Next:** [Configuration & Best Practices](./configuration-best-practices)

--- DOCUMENTATION END: 12-error-handling.md ---



--- DOCUMENTATION START: 13-configuration-best-practices.md ---

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

--- DOCUMENTATION END: 13-configuration-best-practices.md ---



--- DOCUMENTATION START: 14-example-bot.md ---

# Full Example Bot

This comprehensive example combines everything we've learned: events, slash commands, embeds, and components.

```swift
import SWDCK
import Foundation

@main
struct MyBot {
    static func main() async throws {
        // 1. Setup
        let bot = DiscordBot(
            token: "YOUR_TOKEN",
            intents: .default | .messageContent | .guildMembers
        )

        // 2. Logging On Ready
        bot.onReady { ready in
            print("🚀 \(ready.user.username) is online!")
        }

        // 3. Simple Message Response
        bot.onMessage { message in
            guard !message.author.bot else { return }
            
            if message.content == "!hello" {
                try await message.reply("Hello from the full example!")
            }
        }

        // 4. Slash Command with Embed & Button
        let welcomeOptions = [
            CommandOption(name: "user", description: "The user to welcome", type: .user, required: true)
        ]
        
        bot.slashCommand("welcome", description: "Send a fancy welcome message", options: welcomeOptions) { interaction in
            let targetUser = interaction.option("user")?.userValue
            let username = targetUser?.username ?? "unknown"
            
            // Build a fancy embed
            let embed = EmbedBuilder()
                .setTitle("Welcome to the Server!")
                .setDescription("We are glad to have you here, \(username)!")
                .setColor(0x5865F2) // Blurple
                .setThumbnail(targetUser?.avatarURL?.absoluteString ?? "")
                .build()
            
            // Add a button
            let button = ComponentV2Button(style: .link, label: "View Rules", url: "https://example.com/rules")
            let row = ComponentV2ActionRow(components: [.button(button)])
            
            // Respond
            try await interaction.respond(
                SendMessagePayload(embeds: [embed], components: [.actionRow(row)])
            )
        }

        // 5. Moderation Command (Kick)
        let kickOptions = [
            CommandOption(name: "user", description: "Member to kick", type: .user, required: true),
            CommandOption(name: "reason", description: "Why?", type: .string, required: false)
        ]
        
        bot.slashCommand("kick", description: "Kick a member", options: kickOptions) { interaction in
            guard let guildId = interaction.guildId,
                  let userId = interaction.option("user")?.userValue?.id else { return }
            
            let reason = interaction.option("reason")?.stringValue
            
            do {
                try await bot.removeGuildMember(guildId: guildId, userId: userId, reason: reason)
                try await interaction.respond("Successfully kicked the user.", ephemeral: true)
            } catch {
                try await interaction.respond("Failed to kick: \(error.localizedDescription)", ephemeral: true)
            }
        }

        // 6. Connect
        try await bot.start()
    }
}
```

## What this bot does:
1. **Identifies itself**: Logs to your console when it successfully connects.
2. **Responds to `!hello`**: A classic text-based command.
3. **`/welcome`**: Uses a **Slash Command**, creates a high-quality **Embed**, and attaches an **Action Row** with a **Button**.
4. **`/kick`**: Shows how to use interaction options to perform **Moderation** actions and handle errors specifically for that user.

---

## Running the Example
1. Add SWDCK to your project using SPM.
2. Ensure `MESSAGE_CONTENT` and `GUILD_MEMBERS` intents are enabled in the portal.
3. Replace `"YOUR_TOKEN"` with your actual token.
4. Build and Run! 

> **Next:** [API Reference](./api-reference)

--- DOCUMENTATION END: 14-example-bot.md ---



--- DOCUMENTATION START: 15-api-reference.md ---

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

--- DOCUMENTATION END: 15-api-reference.md ---



--- DOCUMENTATION START: 16-faq-troubleshooting.md ---

# FAQ & Troubleshooting

Encountering issues? Check here first for solutions to common problems.

## Frequently Asked Questions

### ❓ My bot is online, but `onMessage` never fires.
**Solution:** You likely haven't enabled the **Message Content Intent**.
1. Go to the [Discord Developer Portal](https://discord.com/developers/applications).
2. Select your app -> **Bot**.
3. Enable **Message Content Intent**.
4. In your code, ensure you include `.messageContent` in your `intents`:
   ```swift
   let bot = DiscordBot(token: "...", intents: .default | .messageContent)
   ```

### ❓ I registered a slash command, but it's not showing up in Discord.
**Solution:** Global slash commands can take up to **one hour** to propagate to all servers. For instant testing, use **Guild Commands**:
```swift
// This updates instantly for the specific guild
try await bot.syncCommands(to: "your_guild_id")
```
Also, ensure the bot was invited with the `applications.commands` scope.

### ❓ I get the error: "Interaction already acknowledged".
**Solution:** You are trying to respond to an interaction that has already been responded to or deferred. You can only send one "initial" response. Use `followUp()` or `editResponse()` for subsequent updates.

---

## Troubleshooting Tools

### Enable Detailed Logging
SWDCK logs important events to the console by default. If you are having connection issues, look for lines starting with `[SWDCK][Gateway]`.

### Common Gateway Close Codes
| Code | Meaning | Action |
|------|---------|--------|
| 4004 | Authentication failed. | Your token is invalid. Reset it in the portal. |
| 4014 | Disallowed intent. | You requested an intent (like `guildMembers`) that isn't enabled in the portal. |
| 4010 | Invalid Shard. | You are trying to use more shards than allowed. (Usually handled automatically by SWDCK). |

---

## Still having trouble?

If your issue isn't listed here:
1. Check the [Samples](./example-bot) to see if your setup matches.
2. Open an issue on the [GitHub Repository](https://github.com/PRATIKK0709/SWDCK--SwiftDiscKit/issues).
3. Provide your Swift version, platform (macOS/iOS), and any error logs from the console.

--- DOCUMENTATION END: 16-faq-troubleshooting.md ---



--- DOCUMENTATION START: 17-changelog.md ---

# Changelog

All notable changes to the SWDCK library will be documented here.

## [1.0.0] - 2024-02-19

This is the initial documentation release, focusing on providing a comprehensive guide for all core features.

### Added
- **Core Engine**: Stable Gateway and REST API implementation.
- **Modern Concurrency**: Full `async/await` support throughout the library.
- **Components V2**: Support for buttons, select menus, and modals.
- **Slash Commands**: Automated registration and easy interaction handling.
- **Type Safety**: Comprehensive models for most Discord API v10 entities.
- **Embed Builder**: A convenient DSL-like builder for rich message content.

### Fixed
- Fixed heartbeat jitter on high-latency connections.
- Improved decoding reliability for optional fields in `Guild` and `Member` models.

---

> 💡 **Note:** Future updates will follow [Semantic Versioning](https://semver.org/).

--- DOCUMENTATION END: 17-changelog.md ---



--- DOCUMENTATION START: 18-contributing-license.md ---

# Contributing & License

SWDCK is an open-source project, and we welcome contributions from the community!

## License

SWDCK is released under the **MIT License**.

```text
Copyright (c) 2024 PRATIKK0709

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
...
```

You are free to use, modify, and distribute the library in both personal and commercial projects.

---

## Contributing

### How to Help
- **Reporting Bugs**: Open an issue on GitHub with steps to reproduce the bug.
- **Feature Requests**: Have an idea for a new feature? Open an issue to discuss it.
- **Code Contributions**: 
    1. Fork the repo.
    2. Create a feature branch.
    3. Ensure your code follows Swift API Design Guidelines.
    4. Submit a Pull Request.

### Code Style
We follow standard Swift formatting. Please ensure your code is readable and includes basic DocC comments for public methods.

---

## Security

If you discover a security vulnerability, please do NOT open a public issue. Instead, contact the developer directly or use the "Report security vulnerability" feature on GitHub.

---

**Thank you for using SWDCK!**

--- DOCUMENTATION END: 18-contributing-license.md ---