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
