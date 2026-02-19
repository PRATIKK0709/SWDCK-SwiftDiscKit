import XCTest
@testable import SWDCK


final class JSONCoderTests: XCTestCase {

    func testUserDecoding() throws {
        let json = """
        {
            "id": "123456789",
            "username": "TestUser",
            "discriminator": "0",
            "global_name": "Test",
            "avatar": null,
            "bot": true
        }
        """.data(using: .utf8)!

        let user = try JSONCoder.decode(DiscordUser.self, from: json)
        XCTAssertEqual(user.id, "123456789")
        XCTAssertEqual(user.username, "TestUser")
        XCTAssertEqual(user.displayName, "Test")
        XCTAssertEqual(user.bot, true)
        XCTAssertEqual(user.tag, "TestUser")    // discriminator == "0" → no suffix
    }

    func testExtendedUserDecoding() throws {
        let json = """
        {
            "id": "123456789",
            "username": "TestUser",
            "discriminator": "0",
            "global_name": "Test",
            "avatar": "avatar_hash",
            "banner": "banner_hash",
            "accent_color": 16711680,
            "locale": "en-US",
            "flags": 64,
            "public_flags": 128,
            "premium_type": 2,
            "avatar_decoration_data": {
                "asset": "asset_hash",
                "sku_id": "12345"
            }
        }
        """.data(using: .utf8)!

        let user = try JSONCoder.decode(DiscordUser.self, from: json)
        XCTAssertEqual(user.banner, "banner_hash")
        XCTAssertEqual(user.accentColor, 16711680)
        XCTAssertEqual(user.locale, "en-US")
        XCTAssertEqual(user.flags, 64)
        XCTAssertEqual(user.publicFlags, 128)
        XCTAssertEqual(user.premiumType, 2)
        XCTAssertEqual(user.avatarDecorationData?.skuId, "12345")
    }

    func testMessageDecoding() throws {
        let json = """
        {
            "id": "111",
            "channel_id": "222",
            "guild_id": "333",
            "author": {
                "id": "444",
                "username": "Author",
                "discriminator": "1234",
                "global_name": null,
                "avatar": null
            },
            "content": "Hello, world!",
            "timestamp": "2024-01-01T00:00:00.000Z",
            "edited_timestamp": null,
            "tts": false,
            "mention_everyone": false,
            "mentions": [],
            "attachments": [],
            "embeds": [],
            "pinned": false,
            "type": 0
        }
        """.data(using: .utf8)!

        let msg = try JSONCoder.decode(Message.self, from: json)
        XCTAssertEqual(msg.id, "111")
        XCTAssertEqual(msg.channelId, "222")
        XCTAssertEqual(msg.content, "Hello, world!")
        XCTAssertEqual(msg.type, .default)
    }

    func testExtendedMessageDecoding() throws {
        let json = """
        {
            "id": "111",
            "channel_id": "222",
            "guild_id": "333",
            "author": {
                "id": "444",
                "username": "Author",
                "discriminator": "1234",
                "global_name": null,
                "avatar": null
            },
            "content": "Hello, world!",
            "timestamp": "2024-01-01T00:00:00.000Z",
            "edited_timestamp": null,
            "tts": false,
            "mention_everyone": false,
            "mentions": [],
            "mention_roles": ["999"],
            "mention_channels": [
                { "id": "777", "guild_id": "333", "type": 0, "name": "general" }
            ],
            "attachments": [],
            "embeds": [],
            "reactions": [
                {
                    "count": 3,
                    "me": false,
                    "emoji": { "id": null, "name": "🔥", "animated": false }
                }
            ],
            "nonce": "n-1",
            "pinned": false,
            "webhook_id": "555",
            "type": 0,
            "application_id": "666",
            "message_reference": {
                "message_id": "110",
                "channel_id": "222",
                "guild_id": "333"
            },
            "flags": 64,
            "components": [
                { "type": 1 }
            ],
            "sticker_items": [
                { "id": "888", "name": "wave", "format_type": 1 }
            ],
            "position": 5
        }
        """.data(using: .utf8)!

        let msg = try JSONCoder.decode(Message.self, from: json)
        XCTAssertEqual(msg.mentionRoles, ["999"])
        XCTAssertEqual(msg.mentionChannels?.first?.id, "777")
        XCTAssertEqual(msg.reactions?.first?.count, 3)
        XCTAssertEqual(msg.webhookId, "555")
        XCTAssertEqual(msg.applicationId, "666")
        XCTAssertEqual(msg.messageReference?.messageId, "110")
        XCTAssertEqual(msg.flags, 64)
        XCTAssertEqual(msg.stickerItems?.first?.name, "wave")
        XCTAssertEqual(msg.position, 5)
    }

    func testGatewayPayloadDecoding() throws {
        let json = """
        {"op": 10, "d": {"heartbeat_interval": 41250}, "s": null, "t": null}
        """.data(using: .utf8)!

        let payload = try JSONCoder.decode(GatewayPayload.self, from: json)
        XCTAssertEqual(payload.op, 10)
        XCTAssertNil(payload.s)
        XCTAssertNil(payload.t)

        let hello = try payload.d?.decode(HelloData.self)
        XCTAssertEqual(hello?.heartbeatInterval, 41250)
    }

    func testReadyEventDecoding() throws {
        let json = """
        {
            "v": 10,
            "user": {
                "id": "789",
                "username": "MyBot",
                "discriminator": "0",
                "global_name": null,
                "avatar": null,
                "bot": true
            },
            "session_id": "abc123",
            "resume_gateway_url": "wss://gateway.discord.gg",
            "application": {
                "id": "789",
                "flags": 565248
            }
        }
        """.data(using: .utf8)!

        let ready = try JSONCoder.decode(ReadyData.self, from: json)
        XCTAssertEqual(ready.user.username, "MyBot")
        XCTAssertEqual(ready.sessionId, "abc123")
        XCTAssertEqual(ready.application.id, "789")
    }

    func testInteractionOptionValueFlexibility() throws {
        let strJSON = #""hello""#.data(using: .utf8)!
        let strVal = try JSONCoder.decode(InteractionOptionValue.self, from: strJSON)
        XCTAssertEqual(strVal.stringValue, "hello")

        let intJSON = "42".data(using: .utf8)!
        let intVal = try JSONCoder.decode(InteractionOptionValue.self, from: intJSON)
        XCTAssertEqual(intVal.intValue, 42)

        let boolJSON = "true".data(using: .utf8)!
        let boolVal = try JSONCoder.decode(InteractionOptionValue.self, from: boolJSON)
        XCTAssertEqual(boolVal.boolValue, true)
    }

    func testExtendedChannelDecoding() throws {
        let json = """
        {
            "id": "10",
            "type": 0,
            "guild_id": "99",
            "name": "general",
            "topic": "topic",
            "position": 1,
            "permission_overwrites": [
                { "id": "1", "type": 0, "allow": "0", "deny": "1024" }
            ],
            "rate_limit_per_user": 2,
            "flags": 16,
            "available_tags": [
                { "id": "100", "name": "news", "moderated": false }
            ]
        }
        """.data(using: .utf8)!

        let channel = try JSONCoder.decode(Channel.self, from: json)
        XCTAssertEqual(channel.guildId, "99")
        XCTAssertEqual(channel.permissionOverwrites?.count, 1)
        XCTAssertEqual(channel.flags, 16)
        XCTAssertEqual(channel.availableTags?.first?.name, "news")
    }

    func testExtendedGuildDecoding() throws {
        let json = """
        {
            "id": "200",
            "name": "My Guild",
            "icon": null,
            "owner_id": "1",
            "description": "Guild description",
            "preferred_locale": "en-US",
            "features": ["COMMUNITY"],
            "roles": [
                {
                    "id": "1",
                    "name": "@everyone",
                    "color": 0,
                    "hoist": false,
                    "position": 0,
                    "permissions": "104324161",
                    "managed": false,
                    "mentionable": false
                }
            ],
            "premium_tier": 2,
            "approximate_member_count": 120,
            "approximate_presence_count": 45
        }
        """.data(using: .utf8)!

        let guild = try JSONCoder.decode(Guild.self, from: json)
        XCTAssertEqual(guild.ownerId, "1")
        XCTAssertEqual(guild.preferredLocale, "en-US")
        XCTAssertEqual(guild.features, ["COMMUNITY"])
        XCTAssertEqual(guild.roles?.first?.id, "1")
        XCTAssertEqual(guild.premiumTier, 2)
        XCTAssertEqual(guild.approximateMemberCount, 120)
    }

    func testGuildAuditLogDecoding() throws {
        let json = """
        {
            "audit_log_entries": [
                {
                    "id": "1",
                    "target_id": "99",
                    "user_id": "42",
                    "action_type": 10,
                    "changes": [
                        { "key": "name", "old_value": "old", "new_value": "new" }
                    ],
                    "options": {
                        "count": "1",
                        "channel_id": "123"
                    },
                    "reason": "test"
                }
            ],
            "users": [
                {
                    "id": "42",
                    "username": "mod",
                    "discriminator": "0",
                    "global_name": null,
                    "avatar": null
                }
            ],
            "webhooks": []
        }
        """.data(using: .utf8)!

        let auditLog = try JSONCoder.decode(GuildAuditLog.self, from: json)
        XCTAssertEqual(auditLog.auditLogEntries.count, 1)
        XCTAssertEqual(auditLog.auditLogEntries.first?.actionType, 10)
        XCTAssertEqual(auditLog.auditLogEntries.first?.changes?.first?.key, "name")
        XCTAssertEqual(auditLog.users.first?.id, "42")
    }

    func testGuildBanDecoding() throws {
        let json = """
        {
            "reason": "rule violation",
            "user": {
                "id": "777",
                "username": "banned_user",
                "discriminator": "0",
                "global_name": null,
                "avatar": null
            }
        }
        """.data(using: .utf8)!

        let ban = try JSONCoder.decode(GuildBan.self, from: json)
        XCTAssertEqual(ban.reason, "rule violation")
        XCTAssertEqual(ban.user.id, "777")
    }

    func testGuildPruneAndModifyPayloadEncoding() throws {
        let prune = BeginGuildPrune(days: 30, computePruneCount: true, includeRoles: ["1", "2"])
        let pruneData = try JSONCoder.encode(prune)
        let pruneJSON = try JSONSerialization.jsonObject(with: pruneData) as? [String: Any]
        XCTAssertEqual(pruneJSON?["days"] as? Int, 30)
        XCTAssertEqual(pruneJSON?["compute_prune_count"] as? Bool, true)
        XCTAssertEqual((pruneJSON?["include_roles"] as? [String])?.count, 2)

        let modify = ModifyGuild(name: "Guild A", description: "Updated description")
        let modifyData = try JSONCoder.encode(modify)
        let modifyJSON = try JSONSerialization.jsonObject(with: modifyData) as? [String: Any]
        XCTAssertEqual(modifyJSON?["name"] as? String, "Guild A")
        XCTAssertEqual(modifyJSON?["description"] as? String, "Updated description")
    }

    func testExtendedGuildMemberDecoding() throws {
        let json = """
        {
            "user": {
                "id": "444",
                "username": "Author",
                "discriminator": "1234",
                "global_name": null,
                "avatar": null
            },
            "nick": "Nick",
            "roles": ["11", "22"],
            "joined_at": "2024-01-01T00:00:00.000Z",
            "premium_since": "2024-01-02T00:00:00.000Z",
            "deaf": false,
            "mute": true,
            "flags": 4,
            "pending": false,
            "permissions": "274877906944",
            "unusual_dm_activity_until": null,
            "avatar_decoration_data": {
                "asset": "asset_hash",
                "sku_id": "12345"
            }
        }
        """.data(using: .utf8)!

        let member = try JSONCoder.decode(GuildMember.self, from: json)
        XCTAssertEqual(member.nick, "Nick")
        XCTAssertEqual(member.roles.count, 2)
        XCTAssertEqual(member.premiumSince, "2024-01-02T00:00:00.000Z")
        XCTAssertEqual(member.flags, 4)
        XCTAssertEqual(member.permissions, "274877906944")
        XCTAssertEqual(member.avatarDecorationData?.skuId, "12345")
    }

    func testGatewayInfoDecoding() throws {
        let json = """
        {
            "url": "wss://gateway.discord.gg"
        }
        """.data(using: .utf8)!

        let gateway = try JSONCoder.decode(GatewayInfo.self, from: json)
        XCTAssertEqual(gateway.url, "wss://gateway.discord.gg")
    }

    func testInviteDecoding() throws {
        let json = """
        {
            "type": 0,
            "code": "abc123",
            "guild": {
                "id": "1",
                "name": "Test Guild",
                "features": ["COMMUNITY"]
            },
            "channel": {
                "id": "2",
                "name": "general",
                "type": 0
            },
            "inviter": {
                "id": "3",
                "username": "Tester",
                "discriminator": "0",
                "global_name": "Tester",
                "avatar": null
            },
            "target_type": 1,
            "uses": 2,
            "max_uses": 5,
            "max_age": 3600,
            "temporary": false,
            "created_at": "2024-01-01T00:00:00.000Z",
            "expires_at": "2024-01-01T01:00:00.000Z",
            "approximate_member_count": 10,
            "approximate_presence_count": 4
        }
        """.data(using: .utf8)!

        let invite = try JSONCoder.decode(Invite.self, from: json)
        XCTAssertEqual(invite.code, "abc123")
        XCTAssertEqual(invite.guild?.id, "1")
        XCTAssertEqual(invite.channel?.id, "2")
        XCTAssertEqual(invite.inviter?.id, "3")
        XCTAssertEqual(invite.uses, 2)
        XCTAssertEqual(invite.maxUses, 5)
        XCTAssertEqual(invite.maxAge, 3600)
        XCTAssertEqual(invite.approximateMemberCount, 10)
    }

    func testMessagePinsPageDecoding() throws {
        let json = """
        {
            "items": [
                {
                    "pinned_at": "2024-01-01T00:01:00.000Z",
                    "message": {
                        "id": "100",
                        "channel_id": "200",
                        "guild_id": "300",
                        "author": {
                            "id": "400",
                            "username": "Author",
                            "discriminator": "0",
                            "global_name": null,
                            "avatar": null
                        },
                        "content": "Pinned message",
                        "timestamp": "2024-01-01T00:00:00.000Z",
                        "edited_timestamp": null,
                        "tts": false,
                        "mention_everyone": false,
                        "mentions": [],
                        "attachments": [],
                        "embeds": [],
                        "pinned": true,
                        "type": 0
                    }
                }
            ],
            "has_more": false
        }
        """.data(using: .utf8)!

        let pins = try JSONCoder.decode(MessagePinsPage.self, from: json)
        XCTAssertEqual(pins.items.count, 1)
        XCTAssertEqual(pins.items.first?.message.id, "100")
        XCTAssertEqual(pins.items.first?.pinnedAt, "2024-01-01T00:01:00.000Z")
        XCTAssertEqual(pins.hasMore, false)
    }

    func testArchivedThreadsResponseDecoding() throws {
        let json = """
        {
            "threads": [
                {
                    "id": "10",
                    "type": 11,
                    "guild_id": "300",
                    "name": "thread-a",
                    "owner_id": "500"
                }
            ],
            "members": [
                {
                    "id": "10",
                    "user_id": "500",
                    "join_timestamp": "2024-01-01T00:00:00.000Z",
                    "flags": 0
                }
            ],
            "has_more": true
        }
        """.data(using: .utf8)!

        let archived = try JSONCoder.decode(ArchivedThreadsResponse.self, from: json)
        XCTAssertEqual(archived.threads.count, 1)
        XCTAssertEqual(archived.members.count, 1)
        XCTAssertEqual(archived.threads.first?.id, "10")
        XCTAssertEqual(archived.members.first?.userId, "500")
        XCTAssertEqual(archived.hasMore, true)
    }

    func testActiveGuildThreadsResponseDecoding() throws {
        let json = """
        {
            "threads": [
                { "id": "11", "type": 11, "guild_id": "300", "name": "active-thread" }
            ],
            "members": [
                {
                    "id": "11",
                    "user_id": "500",
                    "join_timestamp": "2024-01-01T00:00:00.000Z",
                    "flags": 0
                }
            ]
        }
        """.data(using: .utf8)!

        let response = try JSONCoder.decode(ActiveGuildThreadsResponse.self, from: json)
        XCTAssertEqual(response.threads.count, 1)
        XCTAssertEqual(response.members.count, 1)
        XCTAssertEqual(response.threads.first?.id, "11")
    }

    func testThreadMemberDecodingWithGuildMember() throws {
        let json = """
        {
            "id": "10",
            "user_id": "500",
            "join_timestamp": "2024-01-01T00:00:00.000Z",
            "flags": 1,
            "member": {
                "roles": ["1"],
                "joined_at": "2024-01-01T00:00:00.000Z"
            }
        }
        """.data(using: .utf8)!

        let member = try JSONCoder.decode(ChannelThreadMember.self, from: json)
        XCTAssertEqual(member.id, "10")
        XCTAssertEqual(member.userId, "500")
        XCTAssertEqual(member.flags, 1)
        XCTAssertEqual(member.member?.roles, ["1"])
    }

    func testWebhookDecoding() throws {
        let json = """
        {
            "id": "1000",
            "type": 1,
            "guild_id": "2000",
            "channel_id": "3000",
            "user": {
                "id": "4000",
                "username": "WebhookOwner",
                "discriminator": "0",
                "global_name": "WebhookOwner",
                "avatar": null
            },
            "name": "Test Hook",
            "avatar": null,
            "token": "webhook_token",
            "application_id": null,
            "url": "https://discord.com/api/webhooks/1000/webhook_token"
        }
        """.data(using: .utf8)!

        let webhook = try JSONCoder.decode(Webhook.self, from: json)
        XCTAssertEqual(webhook.id, "1000")
        XCTAssertEqual(webhook.type, .incoming)
        XCTAssertEqual(webhook.guildId, "2000")
        XCTAssertEqual(webhook.channelId, "3000")
        XCTAssertEqual(webhook.user?.id, "4000")
        XCTAssertEqual(webhook.name, "Test Hook")
        XCTAssertEqual(webhook.token, "webhook_token")
    }

    func testRolePayloadEncoding() throws {
        let create = CreateGuildRole(
            name: "RoleA",
            permissions: "8",
            color: 0xFF0000,
            hoist: true,
            mentionable: true
        )
        let createData = try JSONCoder.encode(create)
        let createJSON = try JSONSerialization.jsonObject(with: createData) as? [String: Any]
        XCTAssertEqual(createJSON?["name"] as? String, "RoleA")
        XCTAssertEqual(createJSON?["permissions"] as? String, "8")
        XCTAssertEqual(createJSON?["hoist"] as? Bool, true)

        let modify = ModifyGuildRole(name: "RoleB", mentionable: false)
        let modifyData = try JSONCoder.encode(modify)
        let modifyJSON = try JSONSerialization.jsonObject(with: modifyData) as? [String: Any]
        XCTAssertEqual(modifyJSON?["name"] as? String, "RoleB")
        XCTAssertEqual(modifyJSON?["mentionable"] as? Bool, false)
    }
}


final class DiscordErrorTests: XCTestCase {

    func testErrorDescriptions() {
        XCTAssertTrue(DiscordError.invalidToken.errorDescription!.contains("token"))
        XCTAssertTrue(DiscordError.rateLimited(retryAfter: 5.0).errorDescription!.contains("5.0"))
        XCTAssertTrue(DiscordError.gatewayDisconnected(code: 4004, reason: "Authentication failed").errorDescription!.contains("4004"))
        XCTAssertTrue(DiscordError.httpError(statusCode: 404, body: "Not Found").errorDescription!.contains("404"))
        XCTAssertTrue(DiscordError.missingPermissions(endpoint: "/channels/1/messages").errorDescription!.contains("Missing permissions"))
        XCTAssertTrue(DiscordError.resourceNotFound(endpoint: "/channels/1/messages/2").errorDescription!.contains("not found"))
        XCTAssertTrue(DiscordError.validationFailed(message: "invalid form body").errorDescription!.contains("rejected"))
        XCTAssertTrue(DiscordError.invalidRequest(message: "bad request").errorDescription!.contains("Invalid"))
    }
}


final class IntentsTests: XCTestCase {

    func testIntentCombination() {
        let combined: GatewayIntents = [.guilds, .guildMessages]
        XCTAssertTrue(combined.contains(.guilds))
        XCTAssertTrue(combined.contains(.guildMessages))
        XCTAssertFalse(combined.contains(.guildMembers))
    }

    func testDefaultIntents() {
        let defaults = GatewayIntents.default
        XCTAssertTrue(defaults.contains(.guilds))
        XCTAssertTrue(defaults.contains(.guildMessages))
        XCTAssertTrue(defaults.contains(.messageContent))
    }

    func testIntentRawValues() {
        XCTAssertEqual(GatewayIntents.guilds.rawValue, 1)
        XCTAssertEqual(GatewayIntents.guildMessages.rawValue, 512)
        XCTAssertEqual(GatewayIntents.messageContent.rawValue, 32768)
    }
}


final class CommandRegistryTests: XCTestCase {

    func testCommandRegistration() async {
        let registry = CommandRegistry()

        let handler = SlashCommandHandler(
            definition: SlashCommandDefinition(name: "ping", description: "Ping!"),
            handler: { _ in }
        )
        await registry.register(handler)

        let definitions = await registry.allDefinitions()
        XCTAssertEqual(definitions.count, 1)
        XCTAssertEqual(definitions[0].name, "ping")
    }

    func testMultipleCommandRegistration() async {
        let registry = CommandRegistry()

        for name in ["ping", "pong", "help"] {
            await registry.register(SlashCommandHandler(
                definition: SlashCommandDefinition(name: name, description: "\(name) command"),
                handler: { _ in }
            ))
        }

        let definitions = await registry.allDefinitions()
        XCTAssertEqual(definitions.count, 3)
    }

    func testCommandOverwrite() async {
        let registry = CommandRegistry()

        await registry.register(SlashCommandHandler(
            definition: SlashCommandDefinition(name: "ping", description: "First"),
            handler: { _ in }
        ))
        await registry.register(SlashCommandHandler(
            definition: SlashCommandDefinition(name: "ping", description: "Second"),
            handler: { _ in }
        ))

        let definitions = await registry.allDefinitions()
        XCTAssertEqual(definitions.count, 1)
        XCTAssertEqual(definitions[0].description, "Second")
    }
}


final class SlashCommandDefinitionTests: XCTestCase {

    func testCommandEncoding() throws {
        let cmd = SlashCommandDefinition(
            name: "greet",
            description: "Greet someone",
            options: [
                .string("name", description: "Who to greet", required: true)
            ]
        )

        let data = try JSONCoder.encode(cmd)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        XCTAssertEqual(json?["name"] as? String, "greet")
        XCTAssertEqual(json?["description"] as? String, "Greet someone")
        XCTAssertEqual(json?["type"] as? Int, 1)

        let options = json?["options"] as? [[String: Any]]
        XCTAssertEqual(options?.count, 1)
        XCTAssertEqual(options?[0]["name"] as? String, "name")
        XCTAssertEqual(options?[0]["type"] as? Int, 3)  // STRING
        XCTAssertEqual(options?[0]["required"] as? Bool, true)
    }
}

final class ApplicationCommandModelTests: XCTestCase {

    func testApplicationCommandDecoding() throws {
        let json = """
        {
            "id": "1000",
            "application_id": "2000",
            "guild_id": "3000",
            "name": "ping",
            "name_localized": "Ping",
            "description": "Ping command",
            "description_localized": "Ping description",
            "type": 1,
            "default_member_permissions": "0",
            "dm_permission": true,
            "nsfw": false,
            "integration_types": [0],
            "contexts": [0, 1],
            "version": "4000",
            "options": [
                {
                    "type": 3,
                    "name": "text",
                    "name_localized": "Text",
                    "description": "Text option",
                    "description_localized": "Text option localized",
                    "required": false,
                    "autocomplete": true,
                    "min_length": 1,
                    "max_length": 100
                }
            ]
        }
        """.data(using: .utf8)!

        let command = try JSONCoder.decode(ApplicationCommand.self, from: json)
        XCTAssertEqual(command.id, "1000")
        XCTAssertEqual(command.guildId, "3000")
        XCTAssertEqual(command.nameLocalized, "Ping")
        XCTAssertEqual(command.descriptionLocalized, "Ping description")
        XCTAssertEqual(command.options?.first?.name, "text")
        XCTAssertEqual(command.options?.first?.nameLocalized, "Text")
        XCTAssertEqual(command.options?.first?.descriptionLocalized, "Text option localized")
        XCTAssertEqual(command.options?.first?.autocomplete, true)
        XCTAssertEqual(command.options?.first?.minLength, 1)
        XCTAssertEqual(command.contexts, [0, 1])
    }

    func testEditApplicationCommandEncoding() throws {
        let edit = EditApplicationCommand(
            description: "Updated",
            dmPermission: false,
            nsfw: true
        )
        let data = try JSONCoder.encode(edit)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertEqual(json?["description"] as? String, "Updated")
        XCTAssertEqual(json?["dm_permission"] as? Bool, false)
        XCTAssertEqual(json?["nsfw"] as? Bool, true)
    }
}


final class ChannelModelTests: XCTestCase {

    func testTextChannelIsTextBased() throws {
        let json = """
        {"id": "1", "type": 0, "name": "general"}
        """.data(using: .utf8)!

        let channel = try JSONCoder.decode(Channel.self, from: json)
        XCTAssertTrue(channel.isTextBased)
    }

    func testVoiceChannelIsNotTextBased() throws {
        let json = """
        {"id": "2", "type": 2, "name": "voice"}
        """.data(using: .utf8)!

        let channel = try JSONCoder.decode(Channel.self, from: json)
        XCTAssertFalse(channel.isTextBased)
    }

    func testUnknownChannelType() throws {
        let json = """
        {"id": "3", "type": 999, "name": "future-type"}
        """.data(using: .utf8)!

        let channel = try JSONCoder.decode(Channel.self, from: json)
        XCTAssertEqual(channel.type, .unknown)
    }
}


final class ComponentV2Tests: XCTestCase {

    func testComponentV2ResponseEncoding() throws {
        let response = InteractionResponse.componentsV2(
            components: [
                .textDisplay(ComponentV2TextDisplay("Hello from V2"))
            ],
            ephemeral: false
        )

        let data = try JSONCoder.encode(response)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertEqual(json?["type"] as? Int, 4)

        let payload = json?["data"] as? [String: Any]
        XCTAssertEqual(payload?["flags"] as? Int, DiscordMessageFlags.isComponentsV2)

        let components = payload?["components"] as? [[String: Any]]
        XCTAssertEqual(components?.count, 1)
        XCTAssertEqual(components?.first?["type"] as? Int, DiscordComponentType.textDisplay.rawValue)
        XCTAssertEqual(components?.first?["content"] as? String, "Hello from V2")
    }

    func testComponentV2ButtonEncoding() throws {
        let button = ComponentV2Button(style: .primary, label: "Click", customId: "btn_1")
        let data = try JSONCoder.encode(button)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        XCTAssertEqual(json?["type"] as? Int, DiscordComponentType.button.rawValue)
        XCTAssertEqual(json?["style"] as? Int, DiscordButtonStyle.primary.rawValue)
        XCTAssertEqual(json?["label"] as? String, "Click")
        XCTAssertEqual(json?["custom_id"] as? String, "btn_1")
    }

    func testComponentV2SelectEncoding() throws {
        let select = ComponentV2StringSelect(
            customId: "select_1",
            options: [
                ComponentV2SelectOption(label: "One", value: "1"),
                ComponentV2SelectOption(label: "Two", value: "2"),
            ],
            placeholder: "Choose",
            minValues: 1,
            maxValues: 2
        )
        let row = ComponentV2ActionRow(components: [.stringSelect(select)])

        let data = try JSONCoder.encode(row)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        XCTAssertEqual(json?["type"] as? Int, DiscordComponentType.actionRow.rawValue)
        let components = json?["components"] as? [[String: Any]]
        XCTAssertEqual(components?.count, 1)
        XCTAssertEqual(components?.first?["type"] as? Int, DiscordComponentType.stringSelect.rawValue)
        XCTAssertEqual(components?.first?["custom_id"] as? String, "select_1")
    }

    func testComponentV2ContainerWithFileEncoding() throws {
        let payload: [ComponentV2Node] = [
            .container(
                ComponentV2Container(
                    accentColor: 0x112233,
                    components: [
                        .textDisplay(ComponentV2TextDisplay("Hello")),
                        .file(ComponentV2File(file: ComponentV2UnfurledMediaItem(url: "attachment://demo.txt"))),
                    ]
                )
            ),
        ]

        let data = try JSONCoder.encode(payload)
        let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]

        XCTAssertEqual(json?.first?["type"] as? Int, DiscordComponentType.container.rawValue)
        let children = json?.first?["components"] as? [[String: Any]]
        XCTAssertEqual(children?.count, 2)
        XCTAssertEqual(children?.last?["type"] as? Int, DiscordComponentType.file.rawValue)
    }

    func testModalResponseWithFileUploadEncoding() throws {
        let response = InteractionResponse.modal(
            customId: "components_file_upload_modal",
            title: "Upload Demo",
            components: [
                ComponentV2Label(
                    label: "Upload",
                    component: .fileUpload(
                        ComponentV2FileUpload(
                            customId: "demo_files",
                            minValues: 0,
                            maxValues: 3,
                            required: false
                        )
                    )
                ),
            ]
        )

        let data = try JSONCoder.encode(response)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        XCTAssertEqual(json?["type"] as? Int, 9)

        let payload = json?["data"] as? [String: Any]
        XCTAssertEqual(payload?["custom_id"] as? String, "components_file_upload_modal")
        XCTAssertEqual(payload?["title"] as? String, "Upload Demo")

        let labels = payload?["components"] as? [[String: Any]]
        XCTAssertEqual(labels?.first?["type"] as? Int, DiscordComponentType.label.rawValue)

        let nested = labels?.first?["component"] as? [String: Any]
        XCTAssertEqual(nested?["type"] as? Int, DiscordComponentType.fileUpload.rawValue)
        XCTAssertEqual(nested?["custom_id"] as? String, "demo_files")
    }

    func testModalSubmitDecodingWithFileUpload() throws {
        let json = """
        {
          "id": "123",
          "application_id": "456",
          "type": 5,
          "token": "tok",
          "version": 1,
          "data": {
            "custom_id": "components_file_upload_modal",
            "components": [
              {
                "id": 1,
                "type": 18,
                "component": {
                  "custom_id": "demo_files",
                  "id": 2,
                  "type": 19,
                  "values": ["111111111111111111111"]
                }
              },
              {
                "id": 2,
                "type": 18,
                "component": {
                  "custom_id": "demo_public",
                  "id": 3,
                  "type": 23,
                  "value": true
                }
              }
            ],
            "resolved": {
              "attachments": {
                "111111111111111111111": {
                  "id": "111111111111111111111",
                  "filename": "bug.png",
                  "content_type": "image/png"
                }
              }
            }
          }
        }
        """.data(using: .utf8)!

        let interaction = try JSONCoder.decode(Interaction.self, from: json)
        XCTAssertEqual(interaction.type, .modalSubmit)
        XCTAssertEqual(interaction.data?.customId, "components_file_upload_modal")
        XCTAssertEqual(interaction.data?.submittedValues(customId: "demo_files")?.first, "111111111111111111111")
        XCTAssertEqual(interaction.data?.submittedValue(customId: "demo_public")?.boolValue, true)

        let attachments = interaction.data?.submittedAttachments(customId: "demo_files")
        XCTAssertEqual(attachments?.count, 1)
        XCTAssertEqual(attachments?.first?.filename, "bug.png")
    }

    func testModalInputComponentsEncoding() throws {
        let labels: [ComponentV2Label] = [
            ComponentV2Label(
                label: "Category",
                component: .radioGroup(
                    ComponentV2RadioGroup(
                        customId: "demo_radio",
                        options: [
                            ComponentV2RadioGroupOption(label: "Bug", value: "bug"),
                            ComponentV2RadioGroupOption(label: "Feedback", value: "feedback"),
                        ],
                        required: true
                    )
                )
            ),
            ComponentV2Label(
                label: "Features",
                component: .checkboxGroup(
                    ComponentV2CheckboxGroup(
                        customId: "demo_checks",
                        options: [
                            ComponentV2CheckboxOption(label: "API", value: "api"),
                            ComponentV2CheckboxOption(label: "Gateway", value: "gateway"),
                        ],
                        minValues: 0,
                        maxValues: 2
                    )
                )
            ),
            ComponentV2Label(
                label: "Public",
                component: .checkbox(
                    ComponentV2Checkbox(
                        customId: "demo_public",
                        label: "Visible to team",
                        value: false
                    )
                )
            ),
        ]

        let data = try JSONCoder.encode(labels)
        let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]

        XCTAssertEqual(json?.count, 3)
        let radio = json?.first?["component"] as? [String: Any]
        XCTAssertEqual(radio?["type"] as? Int, DiscordComponentType.radioGroup.rawValue)

        let checkboxGroup = json?[1]["component"] as? [String: Any]
        XCTAssertEqual(checkboxGroup?["type"] as? Int, DiscordComponentType.checkboxGroup.rawValue)

        let checkbox = json?.last?["component"] as? [String: Any]
        XCTAssertEqual(checkbox?["type"] as? Int, DiscordComponentType.checkbox.rawValue)
    }
}

final class GatewayPresenceTests: XCTestCase {

    func testPresencePayloadEncoding() throws {
        let payload = PresenceUpdatePayload(
            d: DiscordPresenceUpdate(
                activities: [DiscordActivity(name: "Testing", type: .playing)],
                status: .online,
                afk: false
            )
        )

        let data = try JSONCoder.encode(payload)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertEqual(json?["op"] as? Int, 3)

        let d = json?["d"] as? [String: Any]
        XCTAssertEqual(d?["status"] as? String, "online")
        XCTAssertEqual(d?["afk"] as? Bool, false)
        let activities = d?["activities"] as? [[String: Any]]
        XCTAssertEqual(activities?.first?["name"] as? String, "Testing")
        XCTAssertEqual(activities?.first?["type"] as? Int, 0)
    }

    func testGatewayBotDecoding() throws {
        let json = """
        {
          "url": "wss://gateway.discord.gg",
          "shards": 2,
          "session_start_limit": {
            "total": 1000,
            "remaining": 999,
            "reset_after": 14400000,
            "max_concurrency": 1
          }
        }
        """.data(using: .utf8)!

        let gateway = try JSONCoder.decode(GatewayBot.self, from: json)
        XCTAssertEqual(gateway.url, "wss://gateway.discord.gg")
        XCTAssertEqual(gateway.shards, 2)
        XCTAssertEqual(gateway.sessionStartLimit.total, 1000)
        XCTAssertEqual(gateway.sessionStartLimit.maxConcurrency, 1)
    }
}

final class RouteCoverageTests: XCTestCase {
    func testNewRoutes() {
        XCTAssertEqual(
            Routes.gatewayBot,
            "\(Routes.baseURL)/gateway/bot"
        )
        XCTAssertEqual(
            Routes.bulkDeleteMessages("123"),
            "\(Routes.baseURL)/channels/123/messages/bulk-delete"
        )
        XCTAssertEqual(
            Routes.guildRoles("456"),
            "\(Routes.baseURL)/guilds/456/roles"
        )
        XCTAssertEqual(
            Routes.followupMessage("app", token: "tok", messageId: "msg"),
            "\(Routes.baseURL)/webhooks/app/tok/messages/msg"
        )
        XCTAssertEqual(
            Routes.guildChannels("456"),
            "\(Routes.baseURL)/guilds/456/channels"
        )
        XCTAssertEqual(
            Routes.guildMembers("456"),
            "\(Routes.baseURL)/guilds/456/members"
        )
        XCTAssertEqual(
            Routes.guildMembersSearch("456"),
            "\(Routes.baseURL)/guilds/456/members/search"
        )
        XCTAssertEqual(
            Routes.guildMemberRole("456", userId: "u1", roleId: "r1"),
            "\(Routes.baseURL)/guilds/456/members/u1/roles/r1"
        )
        XCTAssertEqual(
            Routes.guildCommand("app", guildId: "g1", commandId: "c1"),
            "\(Routes.baseURL)/applications/app/guilds/g1/commands/c1"
        )
        XCTAssertEqual(
            Routes.gateway,
            "\(Routes.baseURL)/gateway"
        )
        XCTAssertEqual(
            Routes.channelInvites("123"),
            "\(Routes.baseURL)/channels/123/invites"
        )
        XCTAssertEqual(
            Routes.typing("123"),
            "\(Routes.baseURL)/channels/123/typing"
        )
        XCTAssertEqual(
            Routes.messagePins("123"),
            "\(Routes.baseURL)/channels/123/messages/pins"
        )
        XCTAssertEqual(
            Routes.messagePin("123", messageId: "m1"),
            "\(Routes.baseURL)/channels/123/messages/pins/m1"
        )
        XCTAssertEqual(
            Routes.messageThread("123", messageId: "m1"),
            "\(Routes.baseURL)/channels/123/messages/m1/threads"
        )
        XCTAssertEqual(
            Routes.channelThreads("123"),
            "\(Routes.baseURL)/channels/123/threads"
        )
        XCTAssertEqual(
            Routes.channelArchivedPublicThreads("123"),
            "\(Routes.baseURL)/channels/123/threads/archived/public"
        )
        XCTAssertEqual(
            Routes.channelArchivedPrivateThreads("123"),
            "\(Routes.baseURL)/channels/123/threads/archived/private"
        )
        XCTAssertEqual(
            Routes.channelJoinedPrivateArchivedThreads("123"),
            "\(Routes.baseURL)/channels/123/users/@me/threads/archived/private"
        )
        XCTAssertEqual(
            Routes.threadMembers("123"),
            "\(Routes.baseURL)/channels/123/thread-members"
        )
        XCTAssertEqual(
            Routes.threadMember("123", userId: "u1"),
            "\(Routes.baseURL)/channels/123/thread-members/u1"
        )
        XCTAssertEqual(
            Routes.threadMemberMe("123"),
            "\(Routes.baseURL)/channels/123/thread-members/@me"
        )
        XCTAssertEqual(
            Routes.guildInvites("456"),
            "\(Routes.baseURL)/guilds/456/invites"
        )
        XCTAssertEqual(
            Routes.invite("abc"),
            "\(Routes.baseURL)/invites/abc"
        )
        XCTAssertEqual(
            Routes.channelWebhooks("123"),
            "\(Routes.baseURL)/channels/123/webhooks"
        )
        XCTAssertEqual(
            Routes.guildWebhooks("456"),
            "\(Routes.baseURL)/guilds/456/webhooks"
        )
        XCTAssertEqual(
            Routes.webhook("w1"),
            "\(Routes.baseURL)/webhooks/w1"
        )
        XCTAssertEqual(
            Routes.webhook("w1", token: "tok"),
            "\(Routes.baseURL)/webhooks/w1/tok"
        )
        XCTAssertEqual(
            Routes.webhookMessage("w1", token: "tok", messageId: "m1"),
            "\(Routes.baseURL)/webhooks/w1/tok/messages/m1"
        )
        XCTAssertEqual(
            Routes.guildRole("456", roleId: "r1"),
            "\(Routes.baseURL)/guilds/456/roles/r1"
        )
        XCTAssertEqual(
            Routes.pins("123"),
            "\(Routes.baseURL)/channels/123/pins"
        )
        XCTAssertEqual(
            Routes.pin("123", messageId: "m1"),
            "\(Routes.baseURL)/channels/123/pins/m1"
        )
        XCTAssertEqual(
            Routes.channelPermission("123", overwriteId: "ov1"),
            "\(Routes.baseURL)/channels/123/permissions/ov1"
        )
        XCTAssertEqual(
            Routes.messageCrosspost("123", messageId: "m1"),
            "\(Routes.baseURL)/channels/123/messages/m1/crosspost"
        )
        XCTAssertEqual(
            Routes.guildAuditLogs("456"),
            "\(Routes.baseURL)/guilds/456/audit-logs"
        )
        XCTAssertEqual(
            Routes.guildBans("456"),
            "\(Routes.baseURL)/guilds/456/bans"
        )
        XCTAssertEqual(
            Routes.guildBan("456", userId: "u1"),
            "\(Routes.baseURL)/guilds/456/bans/u1"
        )
        XCTAssertEqual(
            Routes.guildPrune("456"),
            "\(Routes.baseURL)/guilds/456/prune"
        )
        XCTAssertEqual(
            Routes.guildActiveThreads("456"),
            "\(Routes.baseURL)/guilds/456/threads/active"
        )
    }
}

final class GuildRoleModelTests: XCTestCase {
    func testGuildRoleDecoding() throws {
        let json = """
        {
          "id": "1",
          "name": "Admin",
          "color": 16711680,
          "hoist": true,
          "icon": null,
          "unicode_emoji": null,
          "position": 3,
          "permissions": "8",
          "managed": false,
          "mentionable": true
        }
        """.data(using: .utf8)!

        let role = try JSONCoder.decode(GuildRole.self, from: json)
        XCTAssertEqual(role.id, "1")
        XCTAssertEqual(role.name, "Admin")
        XCTAssertEqual(role.permissions, "8")
        XCTAssertEqual(role.position, 3)
    }
}

final class AdditionalAPIModelsTests: XCTestCase {
    func testGuildApplicationCommandPermissionsDecoding() throws {
        let json = """
        {
          "id": "123",
          "application_id": "app_1",
          "guild_id": "guild_1",
          "permissions": [
            { "id": "role_1", "type": 1, "permission": true },
            { "id": "user_1", "type": 2, "permission": false }
          ]
        }
        """.data(using: .utf8)!

        let permissions = try JSONCoder.decode(GuildApplicationCommandPermissions.self, from: json)
        XCTAssertEqual(permissions.id, "123")
        XCTAssertEqual(permissions.applicationId, "app_1")
        XCTAssertEqual(permissions.guildId, "guild_1")
        XCTAssertEqual(permissions.permissions.count, 2)
        XCTAssertEqual(permissions.permissions[0].permission, true)
    }

    func testVoiceStateDecoding() throws {
        let json = """
        {
          "guild_id": "1",
          "channel_id": "2",
          "user_id": "3",
          "session_id": "session",
          "deaf": false,
          "mute": true,
          "self_deaf": false,
          "self_mute": true,
          "self_stream": null,
          "self_video": false,
          "suppress": false,
          "request_to_speak_timestamp": null
        }
        """.data(using: .utf8)!

        let voiceState = try JSONCoder.decode(VoiceState.self, from: json)
        XCTAssertEqual(voiceState.guildId, "1")
        XCTAssertEqual(voiceState.channelId, "2")
        XCTAssertEqual(voiceState.userId, "3")
        XCTAssertEqual(voiceState.sessionId, "session")
        XCTAssertEqual(voiceState.mute, true)
    }

    func testCurrentUserGuildDecoding() throws {
        let json = """
        {
          "id": "10",
          "name": "Guild Name",
          "icon": null,
          "banner": null,
          "owner": false,
          "permissions": "1234",
          "features": ["COMMUNITY"],
          "approximate_member_count": 120,
          "approximate_presence_count": 42
        }
        """.data(using: .utf8)!

        let guild = try JSONCoder.decode(UserGuild.self, from: json)
        XCTAssertEqual(guild.id, "10")
        XCTAssertEqual(guild.name, "Guild Name")
        XCTAssertEqual(guild.approximateMemberCount, 120)
        XCTAssertEqual(guild.approximatePresenceCount, 42)
    }

    func testGuildTemplateDecoding() throws {
        let json = """
        {
          "code": "abc123",
          "name": "Community Template",
          "description": "Template description",
          "usage_count": 7,
          "creator_id": "11",
          "created_at": "2026-02-18T00:00:00.000Z",
          "updated_at": "2026-02-18T00:30:00.000Z",
          "source_guild_id": "99",
          "is_dirty": false
        }
        """.data(using: .utf8)!

        let template = try JSONCoder.decode(GuildTemplate.self, from: json)
        XCTAssertEqual(template.code, "abc123")
        XCTAssertEqual(template.name, "Community Template")
        XCTAssertEqual(template.usageCount, 7)
        XCTAssertEqual(template.sourceGuildId, "99")
        XCTAssertEqual(template.isDirty, false)
    }

    func testGuildScheduledEventDecoding() throws {
        let json = """
        {
          "id": "event_1",
          "guild_id": "guild_1",
          "channel_id": "chan_1",
          "name": "Townhall",
          "description": "Monthly sync",
          "scheduled_start_time": "2026-02-20T10:00:00.000Z",
          "scheduled_end_time": "2026-02-20T11:00:00.000Z",
          "privacy_level": 2,
          "status": 1,
          "entity_type": 1,
          "entity_id": null,
          "entity_metadata": { "location": null },
          "user_count": 42
        }
        """.data(using: .utf8)!

        let event = try JSONCoder.decode(GuildScheduledEvent.self, from: json)
        XCTAssertEqual(event.id, "event_1")
        XCTAssertEqual(event.guildId, "guild_1")
        XCTAssertEqual(event.name, "Townhall")
        XCTAssertEqual(event.privacyLevel, 2)
        XCTAssertEqual(event.userCount, 42)
    }

    func testStageInstanceDecoding() throws {
        let json = """
        {
          "id": "stage_1",
          "guild_id": "guild_1",
          "channel_id": "chan_1",
          "topic": "Sprint Review",
          "privacy_level": 2,
          "discoverable_disabled": false,
          "guild_scheduled_event_id": "event_1"
        }
        """.data(using: .utf8)!

        let stage = try JSONCoder.decode(StageInstance.self, from: json)
        XCTAssertEqual(stage.id, "stage_1")
        XCTAssertEqual(stage.guildId, "guild_1")
        XCTAssertEqual(stage.channelId, "chan_1")
        XCTAssertEqual(stage.topic, "Sprint Review")
        XCTAssertEqual(stage.privacyLevel, 2)
        XCTAssertEqual(stage.guildScheduledEventId, "event_1")
    }

    func testAutoModerationRuleDecoding() throws {
        let json = """
        {
          "id": "rule_1",
          "guild_id": "guild_1",
          "name": "Spam Filter",
          "creator_id": "user_1",
          "event_type": 1,
          "trigger_type": 1,
          "trigger_metadata": {
            "keyword_filter": ["buy now"],
            "allow_list": ["trusted phrase"],
            "mention_total_limit": 5
          },
          "actions": [
            { "type": 1, "metadata": { "channel_id": "log_1" } },
            { "type": 2, "metadata": { "duration_seconds": 300 } }
          ],
          "enabled": true,
          "exempt_roles": ["role_1"],
          "exempt_channels": ["channel_1"]
        }
        """.data(using: .utf8)!

        let rule = try JSONCoder.decode(AutoModerationRule.self, from: json)
        XCTAssertEqual(rule.id, "rule_1")
        XCTAssertEqual(rule.name, "Spam Filter")
        XCTAssertEqual(rule.triggerMetadata?.keywordFilter?.first, "buy now")
        XCTAssertEqual(rule.actions.count, 2)
        XCTAssertEqual(rule.exemptRoles.first, "role_1")
    }

    func testGuildEmojiDecoding() throws {
        let json = """
        {
          "id": "emoji_1",
          "name": "party",
          "roles": ["role_1"],
          "user": {
            "id": "u1",
            "username": "owner",
            "discriminator": "0",
            "global_name": null,
            "avatar": null
          },
          "require_colons": true,
          "managed": false,
          "animated": true,
          "available": true
        }
        """.data(using: .utf8)!

        let emoji = try JSONCoder.decode(GuildEmoji.self, from: json)
        XCTAssertEqual(emoji.id, "emoji_1")
        XCTAssertEqual(emoji.name, "party")
        XCTAssertEqual(emoji.roles?.first, "role_1")
        XCTAssertEqual(emoji.animated, true)
    }

    func testSKUAndEntitlementDecoding() throws {
        let skuJSON = """
        {
          "id": "sku_1",
          "type": 5,
          "application_id": "app_1",
          "name": "Premium",
          "slug": "premium",
          "flags": 0
        }
        """.data(using: .utf8)!
        let entitlementJSON = """
        {
          "id": "ent_1",
          "sku_id": "sku_1",
          "application_id": "app_1",
          "user_id": "u1",
          "type": 8,
          "deleted": false,
          "starts_at": "2026-02-18T00:00:00.000Z",
          "ends_at": null,
          "guild_id": null,
          "consumed": false
        }
        """.data(using: .utf8)!

        let sku = try JSONCoder.decode(SKU.self, from: skuJSON)
        let entitlement = try JSONCoder.decode(Entitlement.self, from: entitlementJSON)
        XCTAssertEqual(sku.id, "sku_1")
        XCTAssertEqual(sku.applicationId, "app_1")
        XCTAssertEqual(entitlement.id, "ent_1")
        XCTAssertEqual(entitlement.skuId, "sku_1")
        XCTAssertEqual(entitlement.consumed, false)
    }

    func testApplicationEmojiAndLobbyDecoding() throws {
        let emojisJSON = """
        {
          "items": [
            {
              "id": "emoji_1",
              "name": "party",
              "roles": [],
              "require_colons": true,
              "managed": false,
              "animated": false,
              "available": true
            }
          ]
        }
        """.data(using: .utf8)!
        let lobbyJSON = """
        {
          "id": "lobby_1",
          "application_id": "app_1",
          "capacity": 16,
          "locked": false,
          "metadata": { "mode": "ranked" },
          "members": [
            { "id": "user_1", "metadata": { "team": "red" } }
          ],
          "linked_channel_ids": ["chan_1"],
          "secret": "secret"
        }
        """.data(using: .utf8)!

        let emojis = try JSONCoder.decode(ApplicationEmojisResponse.self, from: emojisJSON)
        let lobby = try JSONCoder.decode(Lobby.self, from: lobbyJSON)
        XCTAssertEqual(emojis.items.count, 1)
        XCTAssertEqual(emojis.items.first?.id, "emoji_1")
        XCTAssertEqual(lobby.id, "lobby_1")
        XCTAssertEqual(lobby.capacity, 16)
        XCTAssertEqual(lobby.members?.first?.id, "user_1")
        XCTAssertEqual(lobby.linkedChannelIds?.first, "chan_1")
    }

    func testSoundboardAndSubscriptionDecoding() throws {
        let soundboardJSON = """
        {
          "items": [
            {
              "sound_id": "snd_1",
              "name": "airhorn",
              "volume": 0.8,
              "emoji_id": null,
              "emoji_name": "📣",
              "available": true
            }
          ]
        }
        """.data(using: .utf8)!
        let subscriptionJSON = """
        {
          "id": "sub_1",
          "user_id": "user_1",
          "sku_ids": ["sku_1"],
          "entitlement_ids": ["ent_1"],
          "current_period_start": "2026-02-18T00:00:00.000Z",
          "current_period_end": "2026-03-18T00:00:00.000Z",
          "status": 1,
          "country": "US",
          "renewal_sku_ids": ["sku_1"]
        }
        """.data(using: .utf8)!

        let response = try JSONCoder.decode(SoundboardSoundsResponse.self, from: soundboardJSON)
        let subscription = try JSONCoder.decode(Subscription.self, from: subscriptionJSON)
        XCTAssertEqual(response.items.count, 1)
        XCTAssertEqual(response.items.first?.id, "snd_1")
        XCTAssertEqual(response.items.first?.emojiName, "📣")
        XCTAssertEqual(subscription.id, "sub_1")
        XCTAssertEqual(subscription.userId, "user_1")
        XCTAssertEqual(subscription.skuIds?.first, "sku_1")
        XCTAssertEqual(subscription.renewalSkuIds?.first, "sku_1")
    }

    func testPollAnswerVotersDecoding() throws {
        let json = """
        {
          "users": [
            {
              "id": "u1",
              "username": "voter",
              "discriminator": "0",
              "global_name": null,
              "avatar": null
            }
          ]
        }
        """.data(using: .utf8)!

        let voters = try JSONCoder.decode(PollAnswerVotersResponse.self, from: json)
        XCTAssertEqual(voters.users.count, 1)
        XCTAssertEqual(voters.users[0].id, "u1")
    }

    func testAdditionalRoutes() {
        XCTAssertEqual(
            Routes.guildCommandPermissions("app", guildId: "guild"),
            "\(Routes.baseURL)/applications/app/guilds/guild/commands/permissions"
        )
        XCTAssertEqual(
            Routes.guildCommandPermissions("app", guildId: "guild", commandId: "command"),
            "\(Routes.baseURL)/applications/app/guilds/guild/commands/command/permissions"
        )
        XCTAssertEqual(
            Routes.channelRecipient("chan", userId: "user"),
            "\(Routes.baseURL)/channels/chan/recipients/user"
        )
        XCTAssertEqual(
            Routes.inviteTargetUsers("abc"),
            "\(Routes.baseURL)/invites/abc/target-users"
        )
        XCTAssertEqual(
            Routes.oauth2CurrentAuthorization(),
            "\(Routes.baseURL)/oauth2/@me"
        )
        XCTAssertEqual(
            Routes.guildScheduledEvents("guild"),
            "\(Routes.baseURL)/guilds/guild/scheduled-events"
        )
        XCTAssertEqual(
            Routes.guildScheduledEvent("guild", eventId: "event"),
            "\(Routes.baseURL)/guilds/guild/scheduled-events/event"
        )
        XCTAssertEqual(
            Routes.guildScheduledEventUsers("guild", eventId: "event"),
            "\(Routes.baseURL)/guilds/guild/scheduled-events/event/users"
        )
        XCTAssertEqual(
            Routes.guildTemplates("guild"),
            "\(Routes.baseURL)/guilds/guild/templates"
        )
        XCTAssertEqual(
            Routes.guildTemplate("guild", code: "code"),
            "\(Routes.baseURL)/guilds/guild/templates/code"
        )
        XCTAssertEqual(
            Routes.guildTemplate(code: "code"),
            "\(Routes.baseURL)/guilds/templates/code"
        )
        XCTAssertEqual(
            Routes.stageInstances(),
            "\(Routes.baseURL)/stage-instances"
        )
        XCTAssertEqual(
            Routes.stageInstance("channel"),
            "\(Routes.baseURL)/stage-instances/channel"
        )
        XCTAssertEqual(
            Routes.guildEmojis("guild"),
            "\(Routes.baseURL)/guilds/guild/emojis"
        )
        XCTAssertEqual(
            Routes.guildEmoji("guild", emojiId: "emoji"),
            "\(Routes.baseURL)/guilds/guild/emojis/emoji"
        )
        XCTAssertEqual(
            Routes.pollAnswerVoters("channel", messageId: "message", answerId: "answer"),
            "\(Routes.baseURL)/channels/channel/polls/message/answers/answer"
        )
        XCTAssertEqual(
            Routes.expirePoll("channel", messageId: "message"),
            "\(Routes.baseURL)/channels/channel/polls/message/expire"
        )
        XCTAssertEqual(
            Routes.applicationSkus("app"),
            "\(Routes.baseURL)/applications/app/skus"
        )
        XCTAssertEqual(
            Routes.skuSubscriptions("sku"),
            "\(Routes.baseURL)/skus/sku/subscriptions"
        )
        XCTAssertEqual(
            Routes.skuSubscription("sku", subscriptionId: "sub"),
            "\(Routes.baseURL)/skus/sku/subscriptions/sub"
        )
        XCTAssertEqual(
            Routes.applicationEmojis("app"),
            "\(Routes.baseURL)/applications/app/emojis"
        )
        XCTAssertEqual(
            Routes.applicationEmoji("app", emojiId: "emoji"),
            "\(Routes.baseURL)/applications/app/emojis/emoji"
        )
        XCTAssertEqual(
            Routes.applicationEntitlements("app"),
            "\(Routes.baseURL)/applications/app/entitlements"
        )
        XCTAssertEqual(
            Routes.applicationEntitlement("app", entitlementId: "ent"),
            "\(Routes.baseURL)/applications/app/entitlements/ent"
        )
        XCTAssertEqual(
            Routes.applicationEntitlementConsume("app", entitlementId: "ent"),
            "\(Routes.baseURL)/applications/app/entitlements/ent/consume"
        )
        XCTAssertEqual(
            Routes.lobbies(),
            "\(Routes.baseURL)/lobbies"
        )
        XCTAssertEqual(
            Routes.lobby("lobby"),
            "\(Routes.baseURL)/lobbies/lobby"
        )
        XCTAssertEqual(
            Routes.lobbyMember("lobby", userId: "user"),
            "\(Routes.baseURL)/lobbies/lobby/members/user"
        )
        XCTAssertEqual(
            Routes.lobbyMemberMe("lobby"),
            "\(Routes.baseURL)/lobbies/lobby/members/@me"
        )
        XCTAssertEqual(
            Routes.lobbyChannelLinking("lobby"),
            "\(Routes.baseURL)/lobbies/lobby/channel-linking"
        )
        XCTAssertEqual(
            Routes.soundboardDefaultSounds(),
            "\(Routes.baseURL)/soundboard-default-sounds"
        )
        XCTAssertEqual(
            Routes.guildSoundboardSounds("guild"),
            "\(Routes.baseURL)/guilds/guild/soundboard-sounds"
        )
        XCTAssertEqual(
            Routes.guildSoundboardSound("guild", soundId: "sound"),
            "\(Routes.baseURL)/guilds/guild/soundboard-sounds/sound"
        )
        XCTAssertEqual(
            Routes.channelSendSoundboardSound("channel"),
            "\(Routes.baseURL)/channels/channel/send-soundboard-sound"
        )
    }

    func testStickerRoutes() {
        XCTAssertEqual(
            Routes.guildStickers("guild1"),
            "\(Routes.baseURL)/guilds/guild1/stickers"
        )
        XCTAssertEqual(
            Routes.guildSticker("guild1", stickerId: "sticker1"),
            "\(Routes.baseURL)/guilds/guild1/stickers/sticker1"
        )
        XCTAssertEqual(
            Routes.sticker("sticker1"),
            "\(Routes.baseURL)/stickers/sticker1"
        )
        XCTAssertEqual(
            Routes.stickerPacks,
            "\(Routes.baseURL)/sticker-packs"
        )
        XCTAssertEqual(
            Routes.stickerPack("pack1"),
            "\(Routes.baseURL)/sticker-packs/pack1"
        )
    }
}


// MARK: - Branch 3: Missing Endpoints & Features Tests

final class StickerModelTests: XCTestCase {
    func testStickerDecoding() throws {
        let json = """
        {
            "id": "123456",
            "name": "test_sticker",
            "description": "A test sticker",
            "tags": "happy",
            "type": 2,
            "format_type": 1,
            "available": true,
            "guild_id": "guild1",
            "sort_value": 5
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let sticker = try decoder.decode(Sticker.self, from: json)
        XCTAssertEqual(sticker.id, "123456")
        XCTAssertEqual(sticker.name, "test_sticker")
        XCTAssertEqual(sticker.type, .guild)
        XCTAssertEqual(sticker.formatType, .png)
        XCTAssertEqual(sticker.available, true)
        XCTAssertEqual(sticker.guildId, "guild1")
    }

    func testStickerFormatTypes() throws {
        for (raw, expected) in [(1, StickerFormatType.png), (2, .apng), (3, .lottie), (4, .gif)] {
            let json = "\(raw)".data(using: .utf8)!
            let decoded = try JSONDecoder().decode(StickerFormatType.self, from: json)
            XCTAssertEqual(decoded, expected)
        }
    }

    func testStickerItemDecoding() throws {
        let json = """
        {"id": "789", "name": "Item", "format_type": 3}
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let item = try decoder.decode(StickerItem.self, from: json)
        XCTAssertEqual(item.id, "789")
        XCTAssertEqual(item.formatType, .lottie)
    }

    func testCreateGuildStickerEncoding() throws {
        let sticker = CreateGuildSticker(name: "new_sticker", description: "Fun sticker", tags: "cool")
        let data = try JSONEncoder().encode(sticker)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(dict["name"] as? String, "new_sticker")
        XCTAssertEqual(dict["description"] as? String, "Fun sticker")
        XCTAssertEqual(dict["tags"] as? String, "cool")
    }
}

final class GatewayEventDecodingTests: XCTestCase {
    func testGuildDeleteEvent() throws {
        let json = """
        {"id": "guild123", "unavailable": true}
        """.data(using: .utf8)!
        let event = try JSONDecoder().decode(GuildDeleteEvent.self, from: json)
        XCTAssertEqual(event.id, "guild123")
        XCTAssertEqual(event.unavailable, true)
    }

    func testGuildMemberAddEvent() throws {
        let json = """
        {"guild_id": "g1", "user": {"id": "u1", "username": "test"}, "nick": "tester", "roles": ["r1"], "deaf": false, "mute": false}
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let event = try decoder.decode(GuildMemberAddEvent.self, from: json)
        XCTAssertEqual(event.guildId, "g1")
        XCTAssertEqual(event.user?.id, "u1")
        XCTAssertEqual(event.nick, "tester")
    }

    func testGuildMemberRemoveEvent() throws {
        let json = """
        {"guild_id": "g1", "user": {"id": "u1", "username": "leaver"}}
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let event = try decoder.decode(GuildMemberRemoveEvent.self, from: json)
        XCTAssertEqual(event.guildId, "g1")
        XCTAssertEqual(event.user.username, "leaver")
    }

    func testMessageDeleteEvent() throws {
        let json = """
        {"id": "msg1", "channel_id": "ch1", "guild_id": "g1"}
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let event = try decoder.decode(MessageDeleteEvent.self, from: json)
        XCTAssertEqual(event.id, "msg1")
        XCTAssertEqual(event.channelId, "ch1")
        XCTAssertEqual(event.guildId, "g1")
    }

    func testMessageReactionAddEvent() throws {
        let json = """
        {"user_id": "u1", "channel_id": "ch1", "message_id": "msg1", "guild_id": "g1", "emoji": {"id": null, "name": "🎉", "animated": false}}
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let event = try decoder.decode(MessageReactionAddEvent.self, from: json)
        XCTAssertEqual(event.userId, "u1")
        XCTAssertEqual(event.emoji.name, "🎉")
        XCTAssertNil(event.emoji.id)
    }

    func testTypingStartEvent() throws {
        let json = """
        {"channel_id": "ch1", "guild_id": "g1", "user_id": "u1", "timestamp": 1625000000}
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let event = try decoder.decode(TypingStartEvent.self, from: json)
        XCTAssertEqual(event.channelId, "ch1")
        XCTAssertEqual(event.userId, "u1")
        XCTAssertEqual(event.timestamp, 1625000000)
    }

    func testPresenceUpdateEvent() throws {
        let json = """
        {"user": {"id": "u1"}, "guild_id": "g1", "status": "online"}
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let event = try decoder.decode(PresenceUpdateEvent.self, from: json)
        XCTAssertEqual(event.user.id, "u1")
        XCTAssertEqual(event.status, "online")
    }

    func testReactionEmoji() throws {
        let json = """
        {"id": "emoji1", "name": "custom_emoji", "animated": true}
        """.data(using: .utf8)!
        let emoji = try JSONDecoder().decode(ReactionEmoji.self, from: json)
        XCTAssertEqual(emoji.id, "emoji1")
        XCTAssertEqual(emoji.name, "custom_emoji")
        XCTAssertEqual(emoji.animated, true)
    }
}


// MARK: - Branch 4: Type Improvements Tests

final class TypeImprovementsTests: XCTestCase {
    func testWelcomeScreenDecoding() throws {
        let json = """
        {
            "description": "Welcome to the server!",
            "welcome_channels": [
                {
                    "channel_id": "123",
                    "description": "Read the rules",
                    "emoji_id": null,
                    "emoji_name": "📜"
                }
            ]
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let screen = try decoder.decode(WelcomeScreen.self, from: json)
        XCTAssertEqual(screen.description, "Welcome to the server!")
        XCTAssertEqual(screen.welcomeChannels?.first?.channelId, "123")
        XCTAssertEqual(screen.welcomeChannels?.first?.emojiName, "📜")
    }

    func testWelcomeScreenEncoding() throws {
        let channel = WelcomeScreenChannel(channelId: "123", description: "Rules", emojiId: nil, emojiName: "📜")
        let screen = ModifyWelcomeScreen(enabled: true, welcomeChannels: [channel], description: "Hello")
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(screen)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(dict["enabled"] as? Bool, true)
        XCTAssertEqual(dict["description"] as? String, "Hello")
        let channels = dict["welcome_channels"] as? [[String: Any]]
        XCTAssertEqual(channels?.first?["emoji_name"] as? String, "📜")
    }

    func testGuildWidgetSettingsDecoding() throws {
        let json = """
        {"enabled": true, "channel_id": "999"}
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let settings = try decoder.decode(GuildWidgetSettings.self, from: json)
        XCTAssertEqual(settings.enabled, true)
        XCTAssertEqual(settings.channelId, "999")
    }

    func testModifyGuildWidgetEncoding() throws {
        let modify = ModifyGuildWidget(enabled: false, channelId: nil)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(modify)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(dict["enabled"] as? Bool, false)
        // channel_id might be missing or null depending on implementation, here optional nil usually omits key unless explicit null support
        // Swift's JSONEncoder omits nil optionals by default unless configured otherwise
    }
}



// MARK: - Branch 1: Core API Improvements Tests

final class MessageTypeExpandedTests: XCTestCase {
    func testAllMessageTypeValues() throws {
        let cases: [(Int, MessageType)] = [
            (0, .default), (1, .recipientAdd), (2, .recipientRemove),
            (3, .call), (4, .channelNameChange), (5, .channelIconChange),
            (6, .channelPinnedMessage), (7, .userJoin), (8, .guildBoost),
            (9, .guildBoostTier1), (10, .guildBoostTier2), (11, .guildBoostTier3),
            (12, .channelFollowAdd), (14, .guildDiscoveryDisqualified),
            (15, .guildDiscoveryRequalified),
            (16, .guildDiscoveryGracePeriodInitialWarning),
            (17, .guildDiscoveryGracePeriodFinalWarning),
            (18, .threadCreated), (19, .reply), (20, .chatInputCommand),
            (21, .threadStarterMessage), (22, .guildInviteReminder),
            (23, .contextMenuCommand), (24, .autoModerationAction),
            (25, .roleSubscriptionPurchase), (26, .interactionPremiumUpsell),
            (27, .stageStart), (28, .stageEnd), (29, .stageSpeaker),
            (31, .stageTopic), (32, .guildApplicationPremiumSubscription),
            (36, .guildIncidentAlertModeEnabled),
            (37, .guildIncidentAlertModeDisabled),
            (38, .guildIncidentReportRaid),
            (39, .guildIncidentReportFalseAlarm),
            (44, .purchaseNotification), (46, .pollResult),
        ]

        for (rawValue, expected) in cases {
            let json = "\(rawValue)".data(using: .utf8)!
            let decoded = try JSONDecoder().decode(MessageType.self, from: json)
            XCTAssertEqual(decoded, expected, "Failed for raw value \(rawValue)")
        }
    }

    func testUnknownMessageTypeFallback() throws {
        let json = "999".data(using: .utf8)!
        let decoded = try JSONDecoder().decode(MessageType.self, from: json)
        XCTAssertEqual(decoded, .unknown)
    }
}

final class EmbedBuilderExpandedTests: XCTestCase {
    func testSetAuthor() {
        var builder = EmbedBuilder()
        builder.setAuthor(name: "Test Author", url: "https://example.com", iconUrl: "https://example.com/icon.png")
        let embed = builder.build()
        XCTAssertEqual(embed.author?.name, "Test Author")
        XCTAssertEqual(embed.author?.url, "https://example.com")
        XCTAssertEqual(embed.author?.iconUrl, "https://example.com/icon.png")
    }

    func testSetImage() {
        var builder = EmbedBuilder()
        builder.setImage(url: "https://example.com/image.png")
        let embed = builder.build()
        XCTAssertEqual(embed.image?.url, "https://example.com/image.png")
    }

    func testSetThumbnail() {
        var builder = EmbedBuilder()
        builder.setThumbnail(url: "https://example.com/thumb.png")
        let embed = builder.build()
        XCTAssertEqual(embed.thumbnail?.url, "https://example.com/thumb.png")
    }

    func testSetTimestamp() {
        var builder = EmbedBuilder()
        builder.setTimestamp("2025-01-01T00:00:00Z")
        let embed = builder.build()
        XCTAssertEqual(embed.timestamp, "2025-01-01T00:00:00Z")
    }

    func testSetURL() {
        var builder = EmbedBuilder()
        builder.setURL("https://example.com")
        let embed = builder.build()
        XCTAssertEqual(embed.url, "https://example.com")
    }

    func testSetFooterWithIconUrl() {
        var builder = EmbedBuilder()
        builder.setFooter("Footer text", iconUrl: "https://example.com/footer.png")
        let embed = builder.build()
        XCTAssertEqual(embed.footer?.text, "Footer text")
        XCTAssertEqual(embed.footer?.iconUrl, "https://example.com/footer.png")
    }

    func testFullEmbedBuild() throws {
        var builder = EmbedBuilder()
        builder.setTitle("Test Title")
        builder.setDescription("Test Description")
        builder.setURL("https://example.com")
        builder.setColor(0xFF5733)
        builder.setTimestamp("2025-06-01T12:00:00Z")
        builder.setFooter("Footer", iconUrl: "https://example.com/f.png")
        builder.setAuthor(name: "Author")
        builder.setImage(url: "https://example.com/img.png")
        builder.setThumbnail(url: "https://example.com/thumb.png")
        builder.addField(name: "Field1", value: "Value1", inline: true)

        let embed = builder.build()
        XCTAssertEqual(embed.title, "Test Title")
        XCTAssertEqual(embed.type, "rich")
        XCTAssertEqual(embed.description, "Test Description")
        XCTAssertEqual(embed.url, "https://example.com")
        XCTAssertEqual(embed.color, 0xFF5733)
        XCTAssertEqual(embed.timestamp, "2025-06-01T12:00:00Z")
        XCTAssertEqual(embed.image?.url, "https://example.com/img.png")
        XCTAssertEqual(embed.thumbnail?.url, "https://example.com/thumb.png")
        XCTAssertEqual(embed.author?.name, "Author")
        XCTAssertEqual(embed.footer?.text, "Footer")
        XCTAssertEqual(embed.fields?.count, 1)
        XCTAssertEqual(embed.fields?.first?.name, "Field1")

        let data = try JSONEncoder().encode(embed)
        let decoded = try JSONDecoder().decode(Embed.self, from: data)
        XCTAssertEqual(decoded.title, "Test Title")
        XCTAssertEqual(decoded.timestamp, "2025-06-01T12:00:00Z")
    }
}

final class AllowedMentionsTests: XCTestCase {
    func testEncoding() throws {
        let mentions = AllowedMentions(
            parse: [.roles, .users],
            roles: ["111", "222"],
            users: ["333"],
            repliedUser: true
        )
        let data = try JSONEncoder().encode(mentions)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let parse = dict["parse"] as! [String]
        XCTAssertEqual(Set(parse), Set(["roles", "users"]))
        XCTAssertEqual(dict["roles"] as! [String], ["111", "222"])
        XCTAssertEqual(dict["users"] as! [String], ["333"])
        XCTAssertEqual(dict["repliedUser"] as? Bool, true)
    }

    func testNoneMentions() throws {
        let data = try JSONEncoder().encode(AllowedMentions.none)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let parse = dict["parse"] as! [String]
        XCTAssertTrue(parse.isEmpty)
    }

    func testDecoding() throws {
        let json = """
        {"parse": ["everyone"], "replied_user": false}
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let mentions = try decoder.decode(AllowedMentions.self, from: json)
        XCTAssertEqual(mentions.parse, [.everyone])
        XCTAssertEqual(mentions.repliedUser, false)
    }
}

final class MessagePayloadTests: XCTestCase {
    func testSendMessagePayloadDefaults() {
        let payload = SendMessagePayload(content: "hello")
        XCTAssertEqual(payload.content, "hello")
        XCTAssertNil(payload.embeds)
        XCTAssertNil(payload.allowedMentions)
        XCTAssertNil(payload.messageReference)
        XCTAssertNil(payload.stickerIds)
        XCTAssertNil(payload.flags)
    }

    func testSendMessagePayloadWithEmbeds() {
        let embed = Embed(title: "Test", description: "Desc", color: 0xFF0000)
        let payload = SendMessagePayload(
            content: "check this out",
            embeds: [embed],
            allowedMentions: AllowedMentions(parse: [.users])
        )
        XCTAssertEqual(payload.embeds?.count, 1)
        XCTAssertEqual(payload.embeds?.first?.title, "Test")
        XCTAssertEqual(payload.allowedMentions?.parse, [.users])
    }

    func testEditMessagePayloadDefaults() {
        let payload = EditMessagePayload(content: "edited")
        XCTAssertEqual(payload.content, "edited")
        XCTAssertNil(payload.embeds)
        XCTAssertNil(payload.flags)
    }

    func testEditMessagePayloadWithEmbeds() {
        let embed = Embed(title: "Updated", color: 0x00FF00)
        let payload = EditMessagePayload(
            embeds: [embed],
            allowedMentions: AllowedMentions.none,
            flags: 4
        )
        XCTAssertNil(payload.content)
        XCTAssertEqual(payload.embeds?.count, 1)
        XCTAssertEqual(payload.embeds?.first?.title, "Updated")
        XCTAssertEqual(payload.flags, 4)
    }

    func testEmbedTimestampRoundtrip() throws {
        let embed = Embed(title: "TS Test", timestamp: "2025-12-25T00:00:00Z")
        let data = try JSONEncoder().encode(embed)
        let decoded = try JSONDecoder().decode(Embed.self, from: data)
        XCTAssertEqual(decoded.timestamp, "2025-12-25T00:00:00Z")
    }
}

// MARK: - Branch 2: Rate Limiting & Retries Tests

final class RateLimiterTests: XCTestCase {
    private func elapsedWait(for route: String, limiter: RateLimiter) async -> TimeInterval {
        let start = Date()
        await limiter.waitIfNeeded(for: route)
        return Date().timeIntervalSince(start)
    }

    func testWaitIfNeededNoExistingBucket() async {
        let limiter = RateLimiter()
        await limiter.waitIfNeeded(for: "GET:/test/route")
    }

    func testUpdateCreatesBucket() async {
        let limiter = RateLimiter()
        let resetTime = String(Date().timeIntervalSince1970 + 10)
        let headers: [AnyHashable: Any] = [
            "X-RateLimit-Remaining": "4",
            "X-RateLimit-Limit": "5",
            "X-RateLimit-Reset": resetTime,
            "X-RateLimit-Bucket": "test-bucket"
        ]
        await limiter.update(route: "GET:/test", headers: headers)
        await limiter.waitIfNeeded(for: "GET:/test")
    }

    func testGlobalRateLimit() async {
        let limiter = RateLimiter()
        let headers: [AnyHashable: Any] = [
            "X-RateLimit-Global": "true",
            "Retry-After": "0.01"
        ]
        await limiter.update(route: "GET:/global-test", headers: headers)
        await limiter.waitIfNeeded(for: "GET:/other-route")
    }

    func testSharedBucketIdDoesNotCollideAcrossDifferentMajors() async {
        let limiter = RateLimiter()
        let exhaustedBucketHeaders: [AnyHashable: Any] = [
            "X-RateLimit-Remaining": "0",
            "X-RateLimit-Limit": "5",
            "X-RateLimit-Reset-After": "0.08",
            "X-RateLimit-Bucket": "shared-bucket"
        ]
        let healthyBucketHeaders: [AnyHashable: Any] = [
            "X-RateLimit-Remaining": "5",
            "X-RateLimit-Limit": "5",
            "X-RateLimit-Reset-After": "0.08",
            "X-RateLimit-Bucket": "shared-bucket"
        ]

        await limiter.update(
            route: "GET:/channels/111/messages/:id",
            headers: exhaustedBucketHeaders
        )
        await limiter.update(
            route: "GET:/channels/222/messages/:id",
            headers: healthyBucketHeaders
        )

        let blockedElapsed = await elapsedWait(for: "GET:/channels/111/messages/:id", limiter: limiter)
        let freeElapsed = await elapsedWait(for: "GET:/channels/222/messages/:id", limiter: limiter)

        XCTAssertGreaterThanOrEqual(blockedElapsed, 0.05)
        XCTAssertLessThan(freeElapsed, 0.03)
    }

    func testConcurrentWaitsRespectMajorRouteIsolationWithSameBucketId() async {
        let limiter = RateLimiter()
        let exhaustedBucketHeaders: [AnyHashable: Any] = [
            "X-RateLimit-Remaining": "0",
            "X-RateLimit-Limit": "5",
            "X-RateLimit-Reset-After": "0.08",
            "X-RateLimit-Bucket": "shared-bucket"
        ]
        let healthyBucketHeaders: [AnyHashable: Any] = [
            "X-RateLimit-Remaining": "5",
            "X-RateLimit-Limit": "5",
            "X-RateLimit-Reset-After": "0.08",
            "X-RateLimit-Bucket": "shared-bucket"
        ]

        await limiter.update(
            route: "GET:/guilds/555/members/:id",
            headers: exhaustedBucketHeaders
        )
        await limiter.update(
            route: "GET:/guilds/777/members/:id",
            headers: healthyBucketHeaders
        )

        async let blockedElapsed = elapsedWait(for: "GET:/guilds/555/members/:id", limiter: limiter)
        async let freeElapsed = elapsedWait(for: "GET:/guilds/777/members/:id", limiter: limiter)

        let blocked = await blockedElapsed
        let free = await freeElapsed

        XCTAssertGreaterThanOrEqual(blocked, 0.05)
        XCTAssertLessThan(free, 0.03)
    }
}

final class MultipartBodyBuildingTests: XCTestCase {
    func testMultipartBoundaryFormat() {
        let boundary = "Boundary-\(UUID().uuidString)"
        XCTAssertTrue(boundary.starts(with: "Boundary-"))
        XCTAssertTrue(boundary.count > 10)
    }

    func testMultipartBodyStructure() throws {
        let boundary = "Boundary-TEST123"
        let lineBreak = "\r\n"
        var body = Data()

        func append(_ string: String) {
            body.append(Data(string.utf8))
        }

        append("--\(boundary)\(lineBreak)")
        append("Content-Disposition: form-data; name=\"payload_json\"\(lineBreak)")
        append("Content-Type: application/json\(lineBreak)\(lineBreak)")
        append("{\"test\":true}")
        append(lineBreak)
        append("--\(boundary)--\(lineBreak)")

        let bodyString = String(data: body, encoding: .utf8)!
        XCTAssertTrue(bodyString.contains("--Boundary-TEST123\r\n"))
        XCTAssertTrue(bodyString.contains("Content-Disposition: form-data; name=\"payload_json\""))
        XCTAssertTrue(bodyString.contains("Content-Type: application/json"))
        XCTAssertTrue(bodyString.contains("{\"test\":true}"))
        XCTAssertTrue(bodyString.contains("--Boundary-TEST123--"))
    }

    func testMultipartBodyWithAttachment() throws {
        let boundary = "Boundary-ATTACH"
        let lineBreak = "\r\n"
        var body = Data()

        func append(_ string: String) {
            body.append(Data(string.utf8))
        }

        append("--\(boundary)\(lineBreak)")
        append("Content-Disposition: form-data; name=\"payload_json\"\(lineBreak)")
        append("Content-Type: application/json\(lineBreak)\(lineBreak)")
        append("{}")
        append(lineBreak)

        let fileData = "hello world".data(using: .utf8)!
        append("--\(boundary)\(lineBreak)")
        append("Content-Disposition: form-data; name=\"files[0]\"; filename=\"test.txt\"\(lineBreak)")
        append("Content-Type: text/plain\(lineBreak)\(lineBreak)")
        body.append(fileData)
        append(lineBreak)
        append("--\(boundary)--\(lineBreak)")

        let bodyString = String(data: body, encoding: .utf8)!
        XCTAssertTrue(bodyString.contains("files[0]"))
        XCTAssertTrue(bodyString.contains("filename=\"test.txt\""))
        XCTAssertTrue(bodyString.contains("hello world"))

    }
}
