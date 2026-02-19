# Permissions & Roles

Discord uses a bitwise permission system to control what users and bots can do. In SWDCK, permissions are represented as strings containing large integers to maintain precision.

## Roles

A `GuildRole` object contains the name, color, and permissions for a specific role in a server.

```swift
bot.onGuildCreate { guild in
    for role in guild.roles ?? [] {
        print("Role: \(role.name), Color: \(role.color)")
    }
}
```

### Key Role Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Unique ID of the role. |
| `name` | `String` | Role name. |
| `color` | `Int` | Integer color (e.g., `0x3498db`). |
| `permissions` | `String` | Bitwise permission flags as a string. |
| `position` | `Int` | Ranking in the role hierarchy. |

---

## Checking Permissions

To check if a member has a specific permission, you'll need to convert the permission string to a numerical value and use bitwise operations.

```swift
// Common Permission Constants (Bit Positions)
enum Permission: UInt64 {
    case administrator = 0x8
    case manageChannels = 0x10
    case kickMembers = 0x2
    case banMembers = 0x4
}

func hasPermission(_ member: GuildMember, permission: Permission) -> Bool {
    guard let permString = member.permissions,
          let permValue = UInt64(permString) else { return false }
    
    return (permValue & permission.rawValue) != 0
}
```

> 💡 **Tip:** Detailed permission bit definitions can be found in the [Discord API Documentation](https://discord.com/developers/docs/topics/permissions#permissions-bitwise-value).

---

## Managing Roles

### Creating a Role
```swift
try await bot.createGuildRole(guildId: "...", name: "New Role", color: 0xFF0000)
```

### Modifying a Role
```swift
try await bot.modifyGuildRole(guildId: "...", roleId: "...", name: "Updated Name")
```

### Assigning a Role to a Member
```swift
try await bot.addGuildMemberRole(guildId: "...", userId: "...", roleId: "...")
```

### Removing a Role
```swift
try await bot.removeGuildMemberRole(guildId: "...", userId: "...", roleId: "...")
```

> **Next:** [Guilds, Channels & Members](./guilds-channels-members)
