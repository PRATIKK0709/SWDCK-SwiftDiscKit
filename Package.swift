// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DiscordKit",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "DiscordKit",
            targets: ["DiscordKit"]
        ),
        .executable(
            name: "DiscordKitBot",
            targets: ["DiscordKitBot"]
        ),
    ],
    targets: [
        .target(
            name: "DiscordKit",
            path: "Sources/DiscordKit"
        ),
        .executableTarget(
            name: "DiscordKitBot",
            dependencies: ["DiscordKit"],
            path: "Examples",
            sources: ["Bot.swift"]
        ),
        .testTarget(
            name: "DiscordKitTests",
            dependencies: ["DiscordKit"],
            path: "Tests/DiscordKitTests"
        ),
    ]
)
