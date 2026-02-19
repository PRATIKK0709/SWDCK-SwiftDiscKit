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
