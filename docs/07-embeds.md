# Embeds

Embeds allow you to send rich, formatted content that looks more professional than plain text. They are perfect for status reports, help menus, and server logs.

## Using `EmbedBuilder`

SWDCK provides a convenient `EmbedBuilder` to construct complex embeds step by step.

```swift
var builder = EmbedBuilder()
builder.setTitle("Server Statistics")
builder.setDescription("Current performance metrics for the bot.")
builder.setColor(0x00ff00) // Green
builder.addField(name: "Uptime", value: "3 days, 4 hours", inline: true)
builder.addField(name: "Guilds", value: "150", inline: true)
builder.setFooter("Last updated at 12:00 PM")

let embed = builder.build()
```

## Field Reference Table

| Property | Method in Builder | Description | Limit |
|----------|-------------------|-------------|-------|
| `title` | `setTitle()` | The bold title at the top. | 256 chars |
| `description` | `setDescription()` | The main body text. | 4096 chars |
| `url` | `setURL()` | Makes the title a clickable link. | - |
| `color` | `setColor()` | The colored strip on the left (Integer hex). | - |
| `fields` | `addField()` | Key-value pairs of data. | 25 fields |
| `footer` | `setFooter()` | Small text at the bottom. | 2048 chars |
| `author` | `setAuthor()` | Small header with name and icon. | 256 chars |
| `image` | `setImage()` | A large image at the bottom. | - |
| `thumbnail` | `setThumbnail()` | A small image in the top-right. | - |
| `timestamp` | `setTimestamp()` | An ISO8601 timestamp in the footer. | - |

---

## Sending an Embed

You can send an embed as part of a message payload.

### In a new message
```swift
let embed = EmbedBuilder()
    .setTitle("Hello!")
    .build()

let payload = SendMessagePayload(content: "Check this out:", embeds: [embed])
try await bot.sendMessage(to: channelId, payload: payload)
```

### In a reply
```swift
bot.onMessage { message in
    if message.content == "!stats" {
        let embed = EmbedBuilder()
            .setTitle("Stats")
            .setDescription("Looking good!")
            .build()
        
        // You can pass an array of embeds to the payload
        let payload = SendMessagePayload(embeds: [embed])
        try await bot.rest.sendMessage(channelId: message.channelId, payload: payload)
    }
}
```

---

## Common Mistakes

- **Invalid Colors**: Colors must be integers. Use hex literals like `0xFF0000` for red.
- **Empty Fields**: Fields must have both a `name` and a `value` that are non-empty strings.
- **Character Limits**: Discord strictly enforces character limits. If you exceed them, the message will fail to send.

> **Next:** [Slash Commands](./slash-commands)
