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
