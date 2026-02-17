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
}


final class DiscordErrorTests: XCTestCase {

    func testErrorDescriptions() {
        XCTAssertTrue(DiscordError.invalidToken.errorDescription!.contains("token"))
        XCTAssertTrue(DiscordError.rateLimited(retryAfter: 5.0).errorDescription!.contains("5.0"))
        XCTAssertTrue(DiscordError.gatewayDisconnected(code: 4004, reason: "Authentication failed").errorDescription!.contains("4004"))
        XCTAssertTrue(DiscordError.httpError(statusCode: 404, body: "Not Found").errorDescription!.contains("404"))
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
}
