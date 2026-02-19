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
