# Guilds, Channels & Members

Understanding how Discord structures servers (Guilds) and the entities within them is key to building advanced bots.

## Guilds (Servers)

A `Guild` represents a Discord server. It is the top-level container for channels, members, and roles.

```swift
bot.onGuildCreate { guild in
    print("Available in guild: \(guild.name) (\(guild.id))")
    print("Member count: \(guild.memberCount ?? 0)")
}
```

### Common Guild Operations
- **Fetch a Guild**: `try await bot.getGuild(id: "...")`
- **Leave a Guild**: `try await bot.leaveGuild(id: "...")`
- **Get Audit Logs**: `try await bot.getGuildAuditLog(guildId: "...")`

---

## Channels

Channels are where the action happens. They can be text-based, voice-based, or categories.

### Channel Types
| Type | Description |
|------|-------------|
| `.guildText` | Standard text channel. |
| `.guildVoice` | Standard voice channel. |
| `.guildCategory` | A folder-like container for other channels. |
| `.guildAnnouncement` | News channel. |
| `.publicThread` / `.privateThread` | Threads within a text channel. |

### Channel Operations
- **Fetch a Channel**: `try await bot.getChannel(id: "...")`
- **Modify a Channel**: `try await bot.modifyChannel(id: "...", name: "new-name")`
- **Delete a Channel**: `try await bot.deleteChannel(id: "...")`

---

## Members vs. Users

In SWDCK (and Discord), there is a distinction between a **User** and a **Member**.

- **`DiscordUser`**: Represents a global Discord user (ID, username, avatar).
- **`GuildMember`**: Represents a user *specific to a server* (nickname, joined date, roles).

```swift
bot.onMessage { message in
    let user = message.author       // Global user info
    let member = message.member    // Server-specific info (roles, nick)
    
    print("\(user.username) is also known as \(member?.nick ?? "none") here.")
}
```

### Member Operations
- **Fetch a Member**: `try await bot.getGuildMember(guildId: "...", userId: "...")`
- **Modify a Member**: `try await bot.modifyGuildMember(guildId: "...", userId: "...", nick: "New Nick")`
- **Kick a Member**: `try await bot.removeGuildMember(guildId: "...", userId: "...")`
- **Ban a Member**: `try await bot.createGuildBan(guildId: "...", userId: "...")`

---

## Hierarchy Recap

1. **Guild**: The server container.
2. **Channel**: A specific place for messaging or talking.
3. **Role**: A set of permissions.
4. **Member**: A user within a guild, assigned one or more roles.

> **Next:** [Error Handling](./error-handling)
