import Foundation
import DiscordKit

private enum LocalDefaults {
    static let token = "SET_BOT_TOKEN"
    static let guildId = "1469915389537550357"
    static let channelId = "1473037288656081027"
}

actor DemoState {
    private var lastBotMessage: Message?
    private var didInitialReadySetup = false

    func setLastBotMessage(_ message: Message) {
        lastBotMessage = message
    }

    func getLastBotMessage() -> Message? {
        lastBotMessage
    }

    func clearLastBotMessage() {
        lastBotMessage = nil
    }

    func consumeInitialReadySetup() -> Bool {
        if didInitialReadySetup { return false }
        didInitialReadySetup = true
        return true
    }
}

@main
struct DiscordKitBotMain {
    static func main() async throws {
        let token = ProcessInfo.processInfo.environment["BOT_TOKEN"]?.nonEmpty ?? LocalDefaults.token
        guard token != LocalDefaults.token else {
            fatalError("Set BOT_TOKEN in your environment before running.")
        }
        let testChannelId = ProcessInfo.processInfo.environment["TEST_CHANNEL_ID"]?.nonEmpty ?? LocalDefaults.channelId
        let testGuildId = ProcessInfo.processInfo.environment["TEST_GUILD_ID"]?.nonEmpty ?? LocalDefaults.guildId

        let bot = DiscordBot(
            token: token,
            intents: [.guilds, .guildMessages, .directMessages, .messageContent, .guildMessageReactions],
            commandSyncMode: .none
        )

        let state = DemoState()

        bot.onReady { ready in
            print("READY -> \(ready.user.tag)")

            let shouldSetup = await state.consumeInitialReadySetup()
            guard shouldSetup else { return }

            do {
                try await bot.clearSlashCommands()
                try await bot.clearSlashCommands(guildId: testGuildId)
                try await bot.syncSlashCommands(guildId: testGuildId)
                print("Synced guild slash commands without duplicates.")
            } catch {
                print("Guild command sync failed: \(error)")
            }

            do {
                let startup = try await bot.sendMessage(
                    to: testChannelId,
                    content: "DiscordKitBot is online. Use `!help` for text commands."
                )
                await state.setLastBotMessage(startup)
            } catch {
                print("Startup sendMessage failed: \(error)")
            }
        }

        bot.onInteraction { interaction in
            print("INTERACTION -> type=\(interaction.type.rawValue) name=\(interaction.data?.name ?? "-")")

            if interaction.type == .applicationCommand, interaction.data?.name == "singlecreate" {
                do {
                    try await interaction.respond("`createSlashCommand` endpoint test command works.", ephemeral: true)
                } catch {
                    print("singlecreate response failed: \(error)")
                }
                return
            }

            if interaction.type == .messageComponent {
                let customId = interaction.data?.customId ?? ""
                let selectedValues = interaction.data?.values?.joined(separator: ", ") ?? "none"

                do {
                    if customId.hasPrefix("cv2_btn_") {
                        try await interaction.respond("Button interaction: \(customId)", ephemeral: true)
                    } else if customId.hasPrefix("cv2_select_") {
                        try await interaction.respond("Selection for \(customId): \(selectedValues)", ephemeral: true)
                    }
                } catch {
                    print("Component interaction response failed: \(error)")
                }
            }
        }

        bot.onMessage { message in
            guard message.author.bot != true else { return }
            let content = message.content.trimmingCharacters(in: .whitespacesAndNewlines)

            if content == "!ping" {
                try await message.reply("Pong!")
                return
            }

            if content == "!help" {
                let help = """
                Text commands:
                !ping
                !channel <channel_id>
                !say <channel_id> <text>
                !componentsv2
                !delete-last
                !register-single
                """
                try await message.respond(help)
                return
            }

            if content.hasPrefix("!channel ") {
                let channelId = String(content.dropFirst("!channel ".count)).trimmingCharacters(in: .whitespaces)
                guard !channelId.isEmpty else {
                    try await message.reply("Usage: !channel <channel_id>")
                    return
                }
                do {
                    let channel = try await bot.getChannel(channelId)
                    try await message.reply("Channel id=\(channel.id), type=\(channel.type.rawValue), name=\(channel.name ?? "nil")")
                } catch {
                    try await message.reply("getChannel failed: \(error)")
                }
                return
            }

            if content.hasPrefix("!say ") {
                let parts = content.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
                guard parts.count == 3 else {
                    try await message.reply("Usage: !say <channel_id> <text>")
                    return
                }
                let targetChannelId = String(parts[1])
                let text = String(parts[2])
                do {
                    let sent = try await bot.sendMessage(to: targetChannelId, content: text)
                    await state.setLastBotMessage(sent)
                    try await message.reply("Sent message id \(sent.id) to \(targetChannelId)")
                } catch {
                    try await message.reply("sendMessage failed: \(error)")
                }
                return
            }

            if content == "!delete-last" {
                guard let last = await state.getLastBotMessage() else {
                    try await message.reply("No tracked message to delete.")
                    return
                }
                do {
                    try await bot.deleteMessage(channelId: last.channelId, messageId: last.id)
                    await state.clearLastBotMessage()
                    try await message.reply("Deleted message \(last.id).")
                } catch {
                    try await message.reply("deleteMessage failed: \(error)")
                }
                return
            }

            if content == "!componentsv2" {
                do {
                    let demo = componentV2DemoData()
                    let sent = try await bot.sendComponentsV2Message(
                        to: message.channelId,
                        components: demo.components,
                        attachments: demo.attachments
                    )
                    await state.setLastBotMessage(sent)
                    try await message.reply("Sent Components V2 test message \(sent.id)")
                } catch {
                    try await message.reply("sendComponentsV2Message failed: \(error)")
                }
                return
            }

            if content == "!register-single" {
                do {
                    let command = try await bot.createSlashCommand(
                        "singlecreate",
                        description: "Single create-command endpoint test",
                        guildId: testGuildId
                    )
                    try await message.reply("Created /\(command.name) with id \(command.id)")
                } catch {
                    try await message.reply("createSlashCommand failed: \(error)")
                }
            }
        }

        bot.slashCommand("ping", description: "Test interaction respond endpoint") { interaction in
            try await interaction.respond("Pong!")
        }

        bot.slashCommand("singleping", description: "Direct ping handler for single command test") { interaction in
            try await interaction.respond("singleping works.")
        }

        bot.slashCommand("deferdemo", description: "Test deferred + edit + followup endpoints") { interaction in
            try await interaction.defer_()
            try await Task.sleep(nanoseconds: 1_000_000_000)
            try await interaction.editResponse("Deferred response edited successfully.")
            _ = try await interaction.followUp("Follow-up message sent.")
        }

        bot.slashCommand(
            "channelinfo",
            description: "Test getChannel REST endpoint",
            options: [
                .string("channel_id", description: "Channel ID", required: true)
            ]
        ) { interaction in
            guard let channelId = interaction.option("channel_id")?.stringValue else {
                try await interaction.respond("Missing channel_id", ephemeral: true)
                return
            }

            do {
                let channel = try await bot.getChannel(channelId)
                try await interaction.respond("Channel id=\(channel.id), type=\(channel.type.rawValue), name=\(channel.name ?? "nil")")
            } catch {
                try await interaction.respond("getChannel failed: \(error)", ephemeral: true)
            }
        }

        bot.slashCommand(
            "say",
            description: "Test sendMessage REST endpoint",
            options: [
                .string("channel_id", description: "Target channel ID", required: true),
                .string("text", description: "Message text", required: true)
            ]
        ) { interaction in
            guard let channelId = interaction.option("channel_id")?.stringValue,
                  let text = interaction.option("text")?.stringValue else {
                try await interaction.respond("Missing arguments", ephemeral: true)
                return
            }

            do {
                let sent = try await bot.sendMessage(to: channelId, content: text)
                await state.setLastBotMessage(sent)
                try await interaction.respond("Sent message id \(sent.id)")
            } catch {
                try await interaction.respond("sendMessage failed: \(error)", ephemeral: true)
            }
        }

        bot.slashCommand("delete_last", description: "Test deleteMessage REST endpoint") { interaction in
            guard let last = await state.getLastBotMessage() else {
                try await interaction.respond("No tracked message to delete.", ephemeral: true)
                return
            }
            do {
                try await bot.deleteMessage(channelId: last.channelId, messageId: last.id)
                await state.clearLastBotMessage()
                try await interaction.respond("Deleted message \(last.id).", ephemeral: true)
            } catch {
                try await interaction.respond("deleteMessage failed: \(error)", ephemeral: true)
            }
        }

        bot.slashCommand("componentsv2", description: "Send Components V2 interactive message") { interaction in
            guard let channelId = interaction.channelId else {
                try await interaction.respond("No channel available for demo.", ephemeral: true)
                return
            }

            let demo = componentV2DemoData()
            let sent = try await bot.sendComponentsV2Message(
                to: channelId,
                components: demo.components,
                attachments: demo.attachments
            )
            await state.setLastBotMessage(sent)
            try await interaction.respond("Sent full Components V2 demo message \(sent.id)", ephemeral: true)
        }

        print("Starting DiscordKitBot...")
        try await bot.start()
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}

private func componentV2DemoData() -> (components: [ComponentV2Node], attachments: [DiscordFileUpload]) {
    let attachmentName = "component-v2-demo.txt"
    let attachmentData = Data(
        """
        DiscordKit Components V2 attachment demo.
        - Buttons
        - Select menus
        - Sections/Container
        - Media gallery
        """.utf8
    )

    let attachment = DiscordFileUpload(
        filename: attachmentName,
        data: attachmentData,
        contentType: "text/plain"
    )

    let components: [ComponentV2Node] = [
        .container(
            ComponentV2Container(
                accentColor: 0x5865F2,
                components: [
                    .textDisplay(ComponentV2TextDisplay("## DiscordKit Components V2 Demo")),
                    .textDisplay(ComponentV2TextDisplay("This message demonstrates a broad set of V2 components in one layout.")),
                    .separator(ComponentV2Separator(divider: true, spacing: 2)),
                    .section(
                        ComponentV2Section(
                            components: [
                                .textDisplay(ComponentV2TextDisplay("### Buttons + Accessories")),
                                .textDisplay(ComponentV2TextDisplay("Use the action row below or the accessory button."))
                            ],
                            accessory: .button(
                                ComponentV2Button(
                                    style: .primary,
                                    label: "Accessory",
                                    customId: "cv2_btn_accessory"
                                )
                            )
                        )
                    ),
                    .section(
                        ComponentV2Section(
                            components: [
                                .textDisplay(ComponentV2TextDisplay("Thumbnail accessory with external media URL."))
                            ],
                            accessory: .thumbnail(
                                ComponentV2Thumbnail(
                                    media: ComponentV2Media(
                                        url: "https://images.unsplash.com/photo-1518770660439-4636190af475?w=512"
                                    ),
                                    description: "Demo thumbnail"
                                )
                            )
                        )
                    ),
                    .actionRow(
                        ComponentV2ActionRow(
                            components: [
                                .button(ComponentV2Button(style: .primary, label: "Primary", customId: "cv2_btn_primary")),
                                .button(ComponentV2Button(style: .secondary, label: "Secondary", customId: "cv2_btn_secondary")),
                                .button(ComponentV2Button(style: .success, label: "Success", customId: "cv2_btn_success")),
                                .button(ComponentV2Button(style: .danger, label: "Danger", customId: "cv2_btn_danger")),
                                .button(ComponentV2Button(style: .link, label: "Discord Docs", url: "https://docs.discord.com/developers/docs/components/overview")),
                            ]
                        )
                    ),
                    .separator(ComponentV2Separator(divider: true, spacing: 1)),
                    .textDisplay(ComponentV2TextDisplay("### Select Menus")),
                    .actionRow(
                        ComponentV2ActionRow(
                            components: [
                                .stringSelect(
                                    ComponentV2StringSelect(
                                        customId: "cv2_select_string",
                                        options: [
                                            ComponentV2SelectOption(label: "Alpha", value: "alpha"),
                                            ComponentV2SelectOption(label: "Beta", value: "beta"),
                                            ComponentV2SelectOption(label: "Gamma", value: "gamma"),
                                        ],
                                        placeholder: "Pick a string option",
                                        minValues: 1,
                                        maxValues: 2
                                    )
                                )
                            ]
                        )
                    ),
                    .actionRow(
                        ComponentV2ActionRow(
                            components: [
                                .userSelect(
                                    ComponentV2UserSelect(
                                        customId: "cv2_select_user",
                                        placeholder: "Pick a user"
                                    )
                                )
                            ]
                        )
                    ),
                    .actionRow(
                        ComponentV2ActionRow(
                            components: [
                                .roleSelect(
                                    ComponentV2RoleSelect(
                                        customId: "cv2_select_role",
                                        placeholder: "Pick a role"
                                    )
                                )
                            ]
                        )
                    ),
                    .actionRow(
                        ComponentV2ActionRow(
                            components: [
                                .mentionableSelect(
                                    ComponentV2MentionableSelect(
                                        customId: "cv2_select_mentionable",
                                        placeholder: "Pick a mentionable"
                                    )
                                )
                            ]
                        )
                    ),
                    .actionRow(
                        ComponentV2ActionRow(
                            components: [
                                .channelSelect(
                                    ComponentV2ChannelSelect(
                                        customId: "cv2_select_channel",
                                        channelTypes: [0, 2, 5, 15],
                                        placeholder: "Pick a channel"
                                    )
                                )
                            ]
                        )
                    ),
                    .separator(ComponentV2Separator(divider: true, spacing: 2)),
                    .textDisplay(ComponentV2TextDisplay("### Media Gallery + File")),
                    .mediaGallery(
                        ComponentV2MediaGallery(
                            items: [
                                ComponentV2MediaGalleryItem(
                                    media: ComponentV2UnfurledMediaItem(
                                        url: "https://images.unsplash.com/photo-1515879218367-8466d910aaa4?w=1200"
                                    ),
                                    description: "Code setup"
                                ),
                                ComponentV2MediaGalleryItem(
                                    media: ComponentV2UnfurledMediaItem(
                                        url: "https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=1200"
                                    ),
                                    description: "Team board"
                                ),
                            ]
                        )
                    ),
                    .file(
                        ComponentV2File(
                            file: ComponentV2UnfurledMediaItem(url: "attachment://\(attachmentName)")
                        )
                    ),
                ]
            )
        ),
    ]

    return (components, [attachment])
}
