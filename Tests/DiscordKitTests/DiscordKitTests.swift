import XCTest
@testable import DiscordKit


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
