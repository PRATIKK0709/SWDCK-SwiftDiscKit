# SWDCK

`SWDCK` is a Swift-first Discord API v10 library for building bots with typed models, async/await, and production-focused reliability.

Built and maintained by a solo Swift developer.

## Why SWDCK

- Active and modern Swift Discord coverage is limited.
- I wanted REST + Gateway support in one package.
- I wanted to keep the whole bot stack in Swift.

## Features

- Gateway client: identify, heartbeat, reconnect, resume
- REST client with retry and rate-limit handling
- Event API: `onReady`, `onMessage`, `onInteraction`, voice updates
- Slash command lifecycle: register/sync/edit/delete
- Interaction lifecycle: immediate/deferred/edit/followups
- Components V2: message components + modal helpers
- Broad typed endpoint surface: channels, messages, guilds, members, roles, webhooks, users, voice/stage, assets, monetization

## Requirements

- Swift 5.9+
- macOS 14+ / iOS 17+

## Installation

Add `SWDCK` in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/MistilteinnDevs/SWDCK-SwiftDiscKit.git", branch: "main")
]
```

Then add it to your target dependencies:

```swift
.target(
    name: "YourBot",
    dependencies: ["SWDCK"]
)
```

## Quick Start

```swift
import SWDCK

let token = ProcessInfo.processInfo.environment["BOT_TOKEN"] ?? ""

let bot = DiscordBot(
    token: token,
    intents: [.guilds, .guildMessages, .directMessages, .messageContent],
    commandSyncMode: .none
)

bot.onMessage { message in
    guard message.author.bot != true else { return }

    switch message.content {
    case "!ping":
        try await message.reply("Pong!")
    case "!hello":
        try await message.reply("Hello, world!")
    default:
        break
    }
}

try await bot.start()
```

## Example Bot

Runnable single-file demo:

- `Examples/Bot.swift`

Run locally:

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
export BOT_TOKEN="..."
swift run SWDCKBot
```

## Endpoint Coverage

Coverage audit doc:

- `docs/discord-api-endpoint-coverage.md`

## Development

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
swift build
swift test
```

## Community

- Discord: https://discord.gg/RtumtDhqqF

## Security

Please report security issues via the security policy instead of public exploit posts.
