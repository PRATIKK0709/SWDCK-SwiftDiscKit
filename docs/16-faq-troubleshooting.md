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
