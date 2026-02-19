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
