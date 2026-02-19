# SwiftDiscKit

SwiftDiscKit is an async Swift package for building Discord bots on API v10.

It includes:
- Gateway client (identify, heartbeat, reconnect, resume)
- REST client with retry + rate-limit handling
- Event API (`onReady`, `onMessage`, `onInteraction`)
- Slash commands (register, sync, edit, delete)
- Interaction responses (immediate, deferred, edit, followup)
- Components V2 support (messages + modals, including file upload)

## Requirements

- Swift 5.9+
- macOS 14+ / iOS 17+

## Installation

Add SwiftDiscKit as a dependency in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/PRATIKK0709/SWDCK-SwiftDiscKit.git", branch: "main")
]
```

## Quick Start

```swift
import SWDCK

let bot = DiscordBot(
    token: ProcessInfo.processInfo.environment["BOT_TOKEN"] ?? "",
    intents: [.guilds, .guildMessages, .directMessages, .messageContent],
    commandSyncMode: .none
)

bot.onMessage { message in
    if message.content == "!ping" {
        try await message.reply("Pong!")
    }
}

try await bot.start()
```

## Public API Surface

`DiscordBot` currently exposes:

- Lifecycle: `start()`, `stop()`, `setPresence(...)`
- Events: `onReady`, `onMessage`, `onInteraction`
- Messaging: send/get/edit/delete, history, bulk delete, pins, reactions
- Channels: get/modify/delete, typing, invites, webhooks
- Threads: create/join/leave/list archived/list members
- Guilds: get guild/channels/members/roles, modify member, role assignment
- Users/Invites: get user, get/delete invite
- Commands: create/list/get/edit/delete global + guild commands, bulk overwrite, sync/clear helpers
- Interactions: respond/defer/edit/get/delete original response + followups
- Components V2: send component messages, multipart attachments, modal submit helpers
- Stickers: get/list/create/modify/delete guild stickers, list sticker packs

## Components V2

Implemented component primitives include:

- Layout/content: `container`, `section`, `text_display`, `separator`, `action_row`
- Buttons/selects: button + all select variants (`string`, `user`, `role`, `mentionable`, `channel`)
- Modal inputs: `label`, `text_input`, `file_upload`, `radio_group`, `checkbox_group`, `checkbox`
- Media: `thumbnail`, `media_gallery`, `file`

`RESTClient` validates outgoing Components V2 payload size to avoid Discord’s 40-component limit errors.

## Reliability and Error Handling

- Async/await across Gateway and REST
- Route-aware and global rate-limit handling
- Retry behavior for transient failures
- Structured `DiscordError` values for invalid token, invalid request, rate limit, gateway disconnect, decode issues, and HTTP failures
- Centralized JSON coding strategy and logging utilities

## Example Bot

The repo contains a single-file runnable demo bot:

- `Examples/Bot.swift`
- https://github.com/PRATIKK0709/SWDCK-SwiftDiscKit/blob/main/Examples/Bot.swift

It includes:

- message commands for endpoint testing
- slash command registration/sync checks
- `/testpanel` categorized endpoint dashboard
- Components V2 message and modal/file-upload demos

Run it with:

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
export BOT_TOKEN="..."
export TEST_GUILD_ID="..."
export TEST_CHANNEL_ID="..."
export TEST_ROLE_ID="..."
swift run SWDCKBot
```

## Endpoint Coverage

Current documented coverage is tracked in:

- `docs/discord-api-endpoint-coverage.md`
- https://github.com/PRATIKK0709/SWDCK-SwiftDiscKit/blob/main/docs/discord-api-endpoint-coverage.md

Latest audit in repo currently reports:
- Documented endpoints in scope: `219`
- Implemented: `193`
- Remaining: `26`

## Development

Build and test:

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
swift build
swift test
```

## Security

Please report vulnerabilities through the project security policy and avoid opening public exploit issues.
