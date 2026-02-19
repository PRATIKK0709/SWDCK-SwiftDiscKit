// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SWDCK",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "SWDCK",
            targets: ["SWDCK"]
        ),
        .executable(
            name: "SWDCKBot",
            targets: ["SWDCKBot"]
        ),
    ],
    targets: [
        .target(
            name: "SWDCK",
            path: "Sources/DiscordKit"
        ),
        .executableTarget(
            name: "SWDCKBot",
            dependencies: ["SWDCK"],
            path: "Examples",
            sources: ["Bot.swift"]
        ),
        .testTarget(
            name: "DiscordKitTests",
            dependencies: ["SWDCK"],
            path: "Tests/DiscordKitTests"
        ),
    ]
)
