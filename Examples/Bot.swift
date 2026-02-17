import Foundation
import DiscordKit

private enum LocalDefaults {
    static let token = "SET_BOT_TOKEN"
    static let guildId = "1469915389537550357"
    static let channelId = "1473037288656081027"
}

actor DemoState {
    private var lastBotMessage: Message?
    private var lastFollowupMessage: Message?
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

    func setLastFollowupMessage(_ message: Message) {
        lastFollowupMessage = message
    }

    func getLastFollowupMessage() -> Message? {
        lastFollowupMessage
    }

    func clearLastFollowupMessage() {
        lastFollowupMessage = nil
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
            fatalError("Set BOT_TOKEN environment variable or update LocalDefaults.token in Examples/Bot.swift")
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

            do {
                try await bot.setPresence(
                    status: .online,
                    activity: DiscordActivity(name: "SwiftDiscKit", type: .watching)
                )
            } catch {
                print("setPresence failed: \(error)")
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

            if interaction.type == .modalSubmit, interaction.data?.customId == "components_file_upload_modal" {
                let category = interaction.data?.submittedValues(customId: "demo_category")?.joined(separator: ", ") ?? "none"
                let note = interaction.data?.submittedValue(customId: "demo_note")?.stringValue ?? "none"
                let isPublic = interaction.data?.submittedValue(customId: "demo_public")?.boolValue ?? false
                let files = interaction.data?.submittedAttachments(customId: "demo_files") ?? []
                let fileList = files.map(\.filename).joined(separator: ", ")
                let fileSummary = fileList.isEmpty ? "none" : fileList

                let summary = """
                Modal submitted.
                Category: \(category)
                Public: \(isPublic)
                Note: \(note)
                Files: \(fileSummary)
                """
                do {
                    try await interaction.respond(summary, ephemeral: true)
                } catch {
                    print("Modal submit response failed: \(error)")
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
                !guild <guild_id>
                !roles <guild_id>
                !user <user_id>
                !member <guild_id> <user_id>
                !say <channel_id> <text>
                !msgget <channel_id> <message_id>
                !msghistory <channel_id> [limit]
                !msgedit <channel_id> <message_id> <text>
                !bulkdelete <channel_id> <id1,id2,...>
                !status <online|idle|dnd|invisible> [activity]
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
                    try await message.reply("getChannel failed: \(friendlyError(error))")
                }
                return
            }

            if content.hasPrefix("!guild ") {
                let guildId = String(content.dropFirst("!guild ".count)).trimmingCharacters(in: .whitespaces)
                guard !guildId.isEmpty else {
                    try await message.reply("Usage: !guild <guild_id>")
                    return
                }
                do {
                    let guild = try await bot.getGuild(guildId)
                    try await message.reply("Guild id=\(guild.id), name=\(guild.name), locale=\(guild.preferredLocale)")
                } catch {
                    try await message.reply("getGuild failed: \(friendlyError(error))")
                }
                return
            }

            if content.hasPrefix("!roles ") {
                let guildId = String(content.dropFirst("!roles ".count)).trimmingCharacters(in: .whitespaces)
                guard !guildId.isEmpty else {
                    try await message.reply("Usage: !roles <guild_id>")
                    return
                }
                do {
                    let roles = try await bot.getGuildRoles(guildId)
                    let preview = roles.prefix(10).map(\.name).joined(separator: ", ")
                    try await message.reply("Roles count=\(roles.count). Sample: \(preview)")
                } catch {
                    try await message.reply("getGuildRoles failed: \(friendlyError(error))")
                }
                return
            }

            if content.hasPrefix("!user ") {
                let userId = String(content.dropFirst("!user ".count)).trimmingCharacters(in: .whitespaces)
                guard !userId.isEmpty else {
                    try await message.reply("Usage: !user <user_id>")
                    return
                }
                do {
                    let user = try await bot.getUser(userId)
                    try await message.reply("User id=\(user.id), username=\(user.username), display=\(user.displayName)")
                } catch {
                    try await message.reply("getUser failed: \(friendlyError(error))")
                }
                return
            }

            if content.hasPrefix("!member ") {
                let parts = content.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
                guard parts.count == 3 else {
                    try await message.reply("Usage: !member <guild_id> <user_id>")
                    return
                }
                let guildId = String(parts[1])
                let userId = String(parts[2])
                do {
                    let member = try await bot.getGuildMember(guildId: guildId, userId: userId)
                    try await message.reply("Member display=\(member.displayName), roleCount=\(member.roles.count)")
                } catch {
                    try await message.reply("getGuildMember failed: \(friendlyError(error))")
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
                    try await message.reply("sendMessage failed: \(friendlyError(error))")
                }
                return
            }

            if content.hasPrefix("!msgget ") {
                let parts = content.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
                guard parts.count == 3 else {
                    try await message.reply("Usage: !msgget <channel_id> <message_id>")
                    return
                }
                let channelId = String(parts[1])
                let messageId = String(parts[2])
                do {
                    let fetched = try await bot.getMessage(channelId: channelId, messageId: messageId)
                    try await message.reply("Fetched message id=\(fetched.id), author=\(fetched.author.tag), content=\(fetched.content)")
                } catch {
                    try await message.reply("getMessage failed: \(friendlyError(error))")
                }
                return
            }

            if content.hasPrefix("!msghistory ") {
                let parts = content.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
                guard parts.count >= 2 else {
                    try await message.reply("Usage: !msghistory <channel_id> [limit]")
                    return
                }
                let channelId = String(parts[1])
                let limit = parts.count == 3 ? Int(parts[2]) ?? 10 : 10
                let safeLimit = min(max(limit, 1), 100)
                do {
                    let messages = try await bot.getMessages(
                        channelId: channelId,
                        query: MessageHistoryQuery(limit: safeLimit)
                    )
                    if let first = messages.first {
                        try await message.reply("Fetched \(messages.count) messages. Latest id=\(first.id), content=\(first.content)")
                    } else {
                        try await message.reply("No messages returned.")
                    }
                } catch {
                    try await message.reply("getMessages failed: \(friendlyError(error))")
                }
                return
            }

            if content.hasPrefix("!msgedit ") {
                let parts = content.split(separator: " ", maxSplits: 3, omittingEmptySubsequences: true)
                guard parts.count == 4 else {
                    try await message.reply("Usage: !msgedit <channel_id> <message_id> <new_text>")
                    return
                }
                let channelId = String(parts[1])
                let messageId = String(parts[2])
                let newText = String(parts[3])
                do {
                    let edited = try await bot.editMessage(channelId: channelId, messageId: messageId, content: newText)
                    try await message.reply("Edited message \(edited.id). New content: \(edited.content)")
                } catch {
                    try await message.reply("editMessage failed: \(friendlyError(error))")
                }
                return
            }

            if content.hasPrefix("!bulkdelete ") {
                let parts = content.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
                guard parts.count == 3 else {
                    try await message.reply("Usage: !bulkdelete <channel_id> <id1,id2,...>")
                    return
                }
                let channelId = String(parts[1])
                let ids = String(parts[2]).split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                guard !ids.isEmpty else {
                    try await message.reply("No message ids supplied.")
                    return
                }
                do {
                    try await bot.bulkDeleteMessages(channelId: channelId, messageIds: ids)
                    try await message.reply("Bulk delete requested for \(ids.count) message(s).")
                } catch {
                    try await message.reply("bulkDeleteMessages failed: \(friendlyError(error))")
                }
                return
            }

            if content.hasPrefix("!status ") {
                let parts = content.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
                guard parts.count >= 2 else {
                    try await message.reply("Usage: !status <online|idle|dnd|invisible> [activity]")
                    return
                }
                guard let status = parsePresenceStatus(String(parts[1])) else {
                    try await message.reply("Invalid status. Use online, idle, dnd, or invisible.")
                    return
                }
                let activity = parts.count == 3 ? DiscordActivity(name: String(parts[2]), type: .playing) : nil
                do {
                    try await bot.setPresence(status: status, activity: activity)
                    try await message.reply("Presence updated to \(status.rawValue).")
                } catch {
                    try await message.reply("setPresence failed: \(friendlyError(error))")
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
                    try await message.reply("deleteMessage failed: \(friendlyError(error))")
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
                    try await message.reply("sendComponentsV2Message failed: \(friendlyError(error))")
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
                    try await message.reply("createSlashCommand failed: \(friendlyError(error))")
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
            let followup = try await interaction.followUp("Follow-up message sent.")
            await state.setLastFollowupMessage(followup)
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
                try await interaction.respond("getChannel failed: \(friendlyError(error))", ephemeral: true)
            }
        }

        bot.slashCommand(
            "guildinfo",
            description: "Test getGuild REST endpoint",
            options: [
                .string("guild_id", description: "Guild ID", required: true)
            ]
        ) { interaction in
            guard let guildId = interaction.option("guild_id")?.stringValue else {
                try await interaction.respond("Missing guild_id", ephemeral: true)
                return
            }
            do {
                let guild = try await bot.getGuild(guildId)
                try await interaction.respond("Guild id=\(guild.id), name=\(guild.name), locale=\(guild.preferredLocale)")
            } catch {
                try await interaction.respond("getGuild failed: \(friendlyError(error))", ephemeral: true)
            }
        }

        bot.slashCommand(
            "roles",
            description: "Test getGuildRoles REST endpoint",
            options: [
                .string("guild_id", description: "Guild ID", required: true)
            ]
        ) { interaction in
            guard let guildId = interaction.option("guild_id")?.stringValue else {
                try await interaction.respond("Missing guild_id", ephemeral: true)
                return
            }
            do {
                let roles = try await bot.getGuildRoles(guildId)
                let preview = roles.prefix(10).map(\.name).joined(separator: ", ")
                try await interaction.respond("Roles count=\(roles.count). Sample: \(preview)")
            } catch {
                try await interaction.respond("getGuildRoles failed: \(friendlyError(error))", ephemeral: true)
            }
        }

        bot.slashCommand(
            "userinfo",
            description: "Test getUser REST endpoint",
            options: [
                .string("user_id", description: "User ID", required: true)
            ]
        ) { interaction in
            guard let userId = interaction.option("user_id")?.stringValue else {
                try await interaction.respond("Missing user_id", ephemeral: true)
                return
            }
            do {
                let user = try await bot.getUser(userId)
                try await interaction.respond("User id=\(user.id), username=\(user.username), display=\(user.displayName)")
            } catch {
                try await interaction.respond("getUser failed: \(friendlyError(error))", ephemeral: true)
            }
        }

        bot.slashCommand(
            "memberinfo",
            description: "Test getGuildMember REST endpoint",
            options: [
                .string("guild_id", description: "Guild ID", required: true),
                .string("user_id", description: "User ID", required: true)
            ]
        ) { interaction in
            guard let guildId = interaction.option("guild_id")?.stringValue,
                  let userId = interaction.option("user_id")?.stringValue else {
                try await interaction.respond("Missing arguments", ephemeral: true)
                return
            }
            do {
                let member = try await bot.getGuildMember(guildId: guildId, userId: userId)
                try await interaction.respond("Member display=\(member.displayName), roleCount=\(member.roles.count)")
            } catch {
                try await interaction.respond("getGuildMember failed: \(friendlyError(error))", ephemeral: true)
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
                try await interaction.respond("sendMessage failed: \(friendlyError(error))", ephemeral: true)
            }
        }

        bot.slashCommand(
            "message_get",
            description: "Test getMessage endpoint",
            options: [
                .string("channel_id", description: "Channel ID", required: true),
                .string("message_id", description: "Message ID", required: true)
            ]
        ) { interaction in
            guard let channelId = interaction.option("channel_id")?.stringValue,
                  let messageId = interaction.option("message_id")?.stringValue else {
                try await interaction.respond("Missing arguments", ephemeral: true)
                return
            }
            do {
                let fetched = try await bot.getMessage(channelId: channelId, messageId: messageId)
                try await interaction.respond("Fetched id=\(fetched.id), author=\(fetched.author.tag), content=\(fetched.content)")
            } catch {
                try await interaction.respond("getMessage failed: \(friendlyError(error))", ephemeral: true)
            }
        }

        bot.slashCommand(
            "message_history",
            description: "Test getMessages endpoint",
            options: [
                .string("channel_id", description: "Channel ID", required: true),
                .integer("limit", description: "1-100", required: false)
            ]
        ) { interaction in
            guard let channelId = interaction.option("channel_id")?.stringValue else {
                try await interaction.respond("Missing channel_id", ephemeral: true)
                return
            }
            let requestedLimit = interaction.option("limit")?.intValue ?? 10
            let safeLimit = min(max(requestedLimit, 1), 100)
            do {
                let messages = try await bot.getMessages(
                    channelId: channelId,
                    query: MessageHistoryQuery(limit: safeLimit)
                )
                if let first = messages.first {
                    try await interaction.respond("Fetched \(messages.count) messages. Latest id=\(first.id)")
                } else {
                    try await interaction.respond("No messages returned.")
                }
            } catch {
                try await interaction.respond("getMessages failed: \(friendlyError(error))", ephemeral: true)
            }
        }

        bot.slashCommand(
            "message_edit",
            description: "Test editMessage endpoint",
            options: [
                .string("channel_id", description: "Channel ID", required: true),
                .string("message_id", description: "Message ID", required: true),
                .string("text", description: "New content", required: true)
            ]
        ) { interaction in
            guard let channelId = interaction.option("channel_id")?.stringValue,
                  let messageId = interaction.option("message_id")?.stringValue,
                  let text = interaction.option("text")?.stringValue else {
                try await interaction.respond("Missing arguments", ephemeral: true)
                return
            }
            do {
                let edited = try await bot.editMessage(channelId: channelId, messageId: messageId, content: text)
                try await interaction.respond("Edited message \(edited.id).")
            } catch {
                try await interaction.respond("editMessage failed: \(friendlyError(error))", ephemeral: true)
            }
        }

        bot.slashCommand(
            "bulk_delete",
            description: "Test bulkDeleteMessages endpoint",
            options: [
                .string("channel_id", description: "Channel ID", required: true),
                .string("message_ids", description: "Comma separated IDs", required: true)
            ]
        ) { interaction in
            guard let channelId = interaction.option("channel_id")?.stringValue,
                  let messageIdsRaw = interaction.option("message_ids")?.stringValue else {
                try await interaction.respond("Missing arguments", ephemeral: true)
                return
            }
            let ids = messageIdsRaw
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            guard !ids.isEmpty else {
                try await interaction.respond("No valid message IDs provided.", ephemeral: true)
                return
            }
            do {
                try await bot.bulkDeleteMessages(channelId: channelId, messageIds: ids)
                try await interaction.respond("Bulk delete requested for \(ids.count) message(s).")
            } catch {
                try await interaction.respond("bulkDeleteMessages failed: \(friendlyError(error))", ephemeral: true)
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
                try await interaction.respond("deleteMessage failed: \(friendlyError(error))", ephemeral: true)
            }
        }

        bot.slashCommand("followup_flow", description: "Test get/edit/delete followup endpoints") { interaction in
            do {
                try await interaction.defer_(ephemeral: true)
                let followup = try await interaction.followUp("Created followup message for lifecycle test.")
                await state.setLastFollowupMessage(followup)
                let fetched = try await interaction.getFollowUp(messageId: followup.id)
                let edited = try await interaction.editFollowUp(
                    messageId: fetched.id,
                    content: "Followup edited successfully."
                )
                try await interaction.deleteFollowUp(messageId: edited.id)
                await state.clearLastFollowupMessage()
                try await interaction.editResponse("Followup lifecycle passed for message id \(edited.id).")
            } catch {
                _ = try? await interaction.editResponse("followup_flow failed: \(friendlyError(error))")
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

        bot.slashCommand("components_modal", description: "Open modal with File Upload component") { interaction in
            try await interaction.presentModal(
                customId: "components_file_upload_modal",
                title: "Components Modal Demo",
                components: componentModalDemoData()
            )
        }

        bot.slashCommand(
            "set_status",
            description: "Set bot presence status and activity",
            options: [
                .string(
                    "status",
                    description: "Presence status",
                    required: true,
                    choices: [
                        CommandChoice(name: "online", value: "online"),
                        CommandChoice(name: "idle", value: "idle"),
                        CommandChoice(name: "dnd", value: "dnd"),
                        CommandChoice(name: "invisible", value: "invisible"),
                    ]
                ),
                .string("activity", description: "Activity name", required: false)
            ]
        ) { interaction in
            guard let statusRaw = interaction.option("status")?.stringValue,
                  let status = parsePresenceStatus(statusRaw) else {
                try await interaction.respond("Invalid status value.", ephemeral: true)
                return
            }

            let activityName = interaction.option("activity")?.stringValue
            let activity = activityName.map { DiscordActivity(name: $0, type: .playing) }

            do {
                try await bot.setPresence(status: status, activity: activity)
                try await interaction.respond("Presence updated to \(status.rawValue).", ephemeral: true)
            } catch {
                try await interaction.respond("setPresence failed: \(friendlyError(error))", ephemeral: true)
            }
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

private func parsePresenceStatus(_ raw: String) -> DiscordPresenceStatus? {
    switch raw.lowercased() {
    case "online":
        return .online
    case "idle":
        return .idle
    case "dnd":
        return .dnd
    case "invisible":
        return .invisible
    default:
        return nil
    }
}

private func friendlyError(_ error: Error) -> String {
    if let localized = error as? LocalizedError, let message = localized.errorDescription, !message.isEmpty {
        return message
    }
    return String(describing: error)
}

private func componentV2DemoData() -> (components: [ComponentV2Node], attachments: [DiscordFileUpload]) {
    let attachmentName = "component-v2-demo.txt"
    let attachmentData = Data("DiscordKit Components V2 file component demo.".utf8)

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
                    .textDisplay(ComponentV2TextDisplay("DiscordKit Components V2 demo")),
                    .separator(ComponentV2Separator()),
                    .section(
                        ComponentV2Section(
                            components: [
                                .textDisplay(ComponentV2TextDisplay("Section + accessory button"))
                            ],
                            accessory: .button(
                                ComponentV2Button(
                                    style: .primary,
                                    label: "Press",
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
                                    )
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
                                .button(ComponentV2Button(style: .link, label: "Discord Docs", url: "https://docs.discord.com/developers/components/overview")),
                            ]
                        )
                    ),
                    .separator(ComponentV2Separator()),
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
                                        ]
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
                                        customId: "cv2_select_user"
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
                                        customId: "cv2_select_role"
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
                                        customId: "cv2_select_mentionable"
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
                                        channelTypes: [0, 2, 5, 15]
                                    )
                                )
                            ]
                        )
                    ),
                    .separator(ComponentV2Separator()),
                    .mediaGallery(
                        ComponentV2MediaGallery(
                            items: [
                                ComponentV2MediaGalleryItem(
                                    media: ComponentV2UnfurledMediaItem(
                                        url: "https://images.unsplash.com/photo-1515879218367-8466d910aaa4?w=1200"
                                    )
                                ),
                                ComponentV2MediaGalleryItem(
                                    media: ComponentV2UnfurledMediaItem(
                                        url: "https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=1200"
                                    )
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

private func componentModalDemoData() -> [ComponentV2Label] {
    [
        ComponentV2Label(
            label: "Issue summary",
            component: .textInput(
                ComponentV2TextInput(
                    customId: "demo_note",
                    style: .paragraph,
                    required: true
                )
            )
        ),
        ComponentV2Label(
            label: "Category",
            component: .stringSelect(
                ComponentV2StringSelect(
                    customId: "demo_category",
                    options: [
                        ComponentV2SelectOption(label: "Bug", value: "bug"),
                        ComponentV2SelectOption(label: "Feedback", value: "feedback"),
                        ComponentV2SelectOption(label: "Question", value: "question"),
                    ]
                )
            )
        ),
        ComponentV2Label(
            label: "Upload files",
            component: .fileUpload(
                ComponentV2FileUpload(
                    customId: "demo_files",
                    minValues: 0,
                    maxValues: 3,
                    required: false
                )
            )
        ),
        ComponentV2Label(
            label: "Visibility",
            component: .checkbox(
                ComponentV2Checkbox(
                    customId: "demo_public",
                    label: "Share this publicly",
                    value: false
                )
            )
        ),
    ]
}
