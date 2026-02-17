import Foundation
import DiscordKit

private enum LocalDefaults {
    static let token = "SET_BOT_TOKEN"
    static let guildId = "SET_TEST_GUILD_ID"
    static let channelId = "SET_TEST_CHANNEL_ID"
    static let roleId = "SET_TEST_ROLE_ID"
}

private enum DemoImageURLs {
    static let swift25 = "https://img.icons8.com/?size=512&id=24465&format=png&color=53B848"
    static let swiftOrange = "https://img.icons8.com/?size=512&id=24465&format=png&color=53B848"
    static let swiftGreen = "https://img.icons8.com/?size=512&id=24465&format=png&color=53B848"
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

private enum DotEnv {
    static func load(from path: String = ".env") -> [String: String] {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            return [:]
        }

        var values: [String: String] = [:]
        for rawLine in content.components(separatedBy: .newlines) {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty, !line.hasPrefix("#") else { continue }
            guard let separatorIndex = line.firstIndex(of: "=") else { continue }

            let key = line[..<separatorIndex].trimmingCharacters(in: .whitespaces)
            var value = line[line.index(after: separatorIndex)...].trimmingCharacters(in: .whitespaces)
            if value.hasPrefix("\""), value.hasSuffix("\""), value.count >= 2 {
                value.removeFirst()
                value.removeLast()
            }
            values[key] = value
        }
        return values
    }
}

@main
struct DiscordKitBotMain {
    static func main() async throws {
        let dotenv = DotEnv.load()
        let token = ProcessInfo.processInfo.environment["BOT_TOKEN"]?.nonEmpty
            ?? dotenv["BOT_TOKEN"]?.nonEmpty
            ?? LocalDefaults.token
        guard token != LocalDefaults.token else {
            fatalError("Set BOT_TOKEN in shell environment or .env")
        }
        let testChannelId = ProcessInfo.processInfo.environment["TEST_CHANNEL_ID"]?.nonEmpty
            ?? dotenv["TEST_CHANNEL_ID"]?.nonEmpty
            ?? LocalDefaults.channelId
        let testGuildId = ProcessInfo.processInfo.environment["TEST_GUILD_ID"]?.nonEmpty
            ?? dotenv["TEST_GUILD_ID"]?.nonEmpty
            ?? LocalDefaults.guildId
        let testRoleId = ProcessInfo.processInfo.environment["TEST_ROLE_ID"]?.nonEmpty
            ?? dotenv["TEST_ROLE_ID"]?.nonEmpty
            ?? (LocalDefaults.roleId == "SET_TEST_ROLE_ID" ? nil : LocalDefaults.roleId)

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
                    if customId == "api_test_select" {
                        guard let selected = interaction.data?.values?.first else {
                            try await interaction.respond("No test selected.", ephemeral: true)
                            return
                        }
                        try await interaction.defer_(ephemeral: true)
                        try await runPanelTest(
                            selected,
                            bot: bot,
                            interaction: interaction,
                            testGuildId: testGuildId,
                            testChannelId: testChannelId,
                            testRoleId: testRoleId
                        )
                    } else if customId.hasPrefix("cv2_btn_") {
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
                !panel
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

            if content == "!panel" {
                let panel = apiTestPanelData()
                let sent = try await bot.sendComponentsV2Message(
                    to: message.channelId,
                    components: panel
                )
                await state.setLastBotMessage(sent)
                try await message.reply("API test panel sent. Use the select menu to run endpoint tests.")
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
                    try await sendMessageDump(message, title: "getChannel", value: channel)
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
                    try await sendMessageDump(message, title: "getGuild", value: guild)
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
                    try await sendMessageDump(
                        message,
                        title: "getGuildRoles",
                        value: EndpointCollectionDump(count: roles.count, items: roles)
                    )
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
                    try await sendMessageDump(message, title: "getUser", value: user)
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
                    try await sendMessageDump(message, title: "getGuildMember", value: member)
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
                    try await sendMessageDump(message, title: "sendMessage", value: sent)
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
                    try await sendMessageDump(message, title: "getMessage", value: fetched)
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
                    try await sendMessageDump(
                        message,
                        title: "getMessages",
                        value: EndpointCollectionDump(count: messages.count, items: messages)
                    )
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
                    try await sendMessageDump(message, title: "editMessage", value: edited)
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
                    try await sendMessageDump(
                        message,
                        title: "bulkDeleteMessages",
                        value: BulkDeleteResult(channelId: channelId, messageIds: ids)
                    )
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
                    try await sendMessageDump(
                        message,
                        title: "setPresence",
                        value: PresenceUpdateResult(status: status.rawValue, activityName: activity?.name)
                    )
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
                    try await sendMessageDump(
                        message,
                        title: "deleteMessage",
                        value: DeleteMessageResult(channelId: last.channelId, messageId: last.id)
                    )
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
                    try await sendMessageDump(message, title: "createSlashCommand", value: command)
                } catch {
                    try await message.reply("createSlashCommand failed: \(friendlyError(error))")
                }
            }
        }

        bot.slashCommand("ping", description: "Ping command") { interaction in
            try await interaction.respond("Pong!")
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
            "testpanel",
            description: "Open master endpoint + component test panel"
        ) { interaction in
            guard let channelId = interaction.channelId else {
                try await interaction.respond("No channel available for panel.", ephemeral: true)
                return
            }
            let panel = apiTestPanelData()
            let sent = try await bot.sendComponentsV2Message(to: channelId, components: panel)
            await state.setLastBotMessage(sent)
            try await interaction.respond("Master API test panel sent as message \(sent.id).", ephemeral: true)
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

private struct EndpointCollectionDump<Item: Encodable>: Encodable {
    let count: Int
    let items: [Item]
}

private struct BulkDeleteResult: Encodable {
    let channelId: String
    let messageIds: [String]
}

private struct DeleteMessageResult: Encodable {
    let channelId: String
    let messageId: String
}

private struct PresenceUpdateResult: Encodable {
    let status: String
    let activityName: String?
}

private struct FollowupLifecycleResult: Encodable {
    let created: Message
    let fetched: Message
    let edited: Message
    let deletedMessageId: String
}

private func sendMessageDump<T: Encodable>(_ message: Message, title: String, value: T) async throws {
    let chunks = renderEndpointDumpChunks(title: title, value: value)
    for (index, chunk) in chunks.enumerated() {
        if index == 0 {
            _ = try await message.reply(chunk)
        } else {
            _ = try await message.respond(chunk)
        }
    }
}

private func sendInteractionDump<T: Encodable>(
    _ interaction: Interaction,
    title: String,
    value: T,
    ephemeral: Bool
) async throws {
    let chunks = renderEndpointDumpChunks(title: title, value: value)
    guard let first = chunks.first else { return }
    try await interaction.respond(first, ephemeral: ephemeral)
    for chunk in chunks.dropFirst() {
        _ = try await interaction.followUp(chunk, ephemeral: ephemeral)
    }
}

private func sendDeferredInteractionDump<T: Encodable>(
    _ interaction: Interaction,
    title: String,
    value: T,
    ephemeral: Bool
) async throws {
    let chunks = renderEndpointDumpChunks(title: title, value: value)
    guard let first = chunks.first else { return }
    _ = try await interaction.editResponse(first)
    for chunk in chunks.dropFirst() {
        _ = try await interaction.followUp(chunk, ephemeral: ephemeral)
    }
}

private func renderEndpointDumpChunks<T: Encodable>(title: String, value: T) -> [String] {
    let json = encodePrettyJSON(value) ?? #"{"error":"failed to encode payload"}"#
    let parts = splitForDiscord(json, limit: 1500)
    if parts.count == 1 {
        return ["\(title)\n```json\n\(json)\n```"]
    }
    return parts.enumerated().map { index, part in
        "\(title) (\(index + 1)/\(parts.count))\n```json\n\(part)\n```"
    }
}

private func encodePrettyJSON<T: Encodable>(_ value: T) -> String? {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.keyEncodingStrategy = .convertToSnakeCase
    guard let data = try? encoder.encode(value) else { return nil }
    return String(data: data, encoding: .utf8)
}

private func splitForDiscord(_ text: String, limit: Int = 1900) -> [String] {
    guard text.count > limit else { return [text] }

    var chunks: [String] = []
    var current = ""

    for line in text.split(separator: "\n", omittingEmptySubsequences: false) {
        let lineWithBreak = line + "\n"
        if current.count + lineWithBreak.count > limit, !current.isEmpty {
            chunks.append(current)
            current = ""
        }

        if lineWithBreak.count > limit {
            let raw = String(lineWithBreak)
            var start = raw.startIndex
            while start < raw.endIndex {
                let end = raw.index(start, offsetBy: limit, limitedBy: raw.endIndex) ?? raw.endIndex
                chunks.append(String(raw[start..<end]))
                start = end
            }
            continue
        }

        current += lineWithBreak
    }

    if !current.isEmpty {
        chunks.append(current)
    }

    return chunks
}

private struct EndpointActionResult: Encodable {
    let endpoint: String
    let success: Bool
    let details: JSONValue?
}

private struct CommandLifecycleResult: Encodable {
    let created: ApplicationCommand
    let edited: ApplicationCommand?
    let deleted: Bool
}

private struct RoleMutationResult: Encodable {
    let guildId: String
    let userId: String
    let roleId: String
    let action: String
    let success: Bool
}

private func apiTestPanelData() -> [ComponentV2Node] {
    let options: [ComponentV2SelectOption] = [
        ComponentV2SelectOption(label: "GET /gateway/bot", value: "gateway_bot"),
        ComponentV2SelectOption(label: "GET global commands", value: "get_global_commands"),
        ComponentV2SelectOption(label: "GET guild commands", value: "get_guild_commands"),
        ComponentV2SelectOption(label: "PATCH global command", value: "edit_global_command"),
        ComponentV2SelectOption(label: "PATCH guild command", value: "edit_guild_command"),
        ComponentV2SelectOption(label: "DELETE global command", value: "delete_global_command"),
        ComponentV2SelectOption(label: "DELETE guild command", value: "delete_guild_command"),
        ComponentV2SelectOption(label: "GET @original interaction response", value: "get_original_response"),
        ComponentV2SelectOption(label: "DELETE @original interaction response", value: "delete_original_response"),
        ComponentV2SelectOption(label: "GET guild channels", value: "get_guild_channels"),
        ComponentV2SelectOption(label: "GET guild members", value: "get_guild_members"),
        ComponentV2SelectOption(label: "GET guild members search", value: "search_guild_members"),
        ComponentV2SelectOption(label: "PATCH guild member", value: "modify_guild_member"),
        ComponentV2SelectOption(label: "PUT add member role", value: "add_member_role"),
        ComponentV2SelectOption(label: "DELETE remove member role", value: "remove_member_role"),
    ]

    return [
        .container(
            ComponentV2Container(
                accentColor: 0x5865F2,
                components: [
                    .textDisplay(ComponentV2TextDisplay("DiscordKit Master Endpoint Test Panel")),
                    .textDisplay(ComponentV2TextDisplay("Pick one endpoint from the menu below to run a full API test.")),
                    .actionRow(
                        ComponentV2ActionRow(
                            components: [
                                .stringSelect(
                                    ComponentV2StringSelect(
                                        customId: "api_test_select",
                                        options: options,
                                        placeholder: "Choose endpoint test",
                                        minValues: 1,
                                        maxValues: 1
                                    )
                                )
                            ]
                        )
                    ),
                ]
            )
        ),
    ]
}

private func runPanelTest(
    _ selected: String,
    bot: DiscordBot,
    interaction: Interaction,
    testGuildId: String,
    testChannelId: String,
    testRoleId: String?
) async throws {
    switch selected {
    case "gateway_bot":
        let gateway = try await bot.getGatewayBot()
        try await sendDeferredInteractionDump(interaction, title: "GET /gateway/bot", value: gateway, ephemeral: true)

    case "get_global_commands":
        let commands = try await bot.getSlashCommands()
        try await sendDeferredInteractionDump(
            interaction,
            title: "GET /applications/{application.id}/commands",
            value: EndpointCollectionDump(count: commands.count, items: commands),
            ephemeral: true
        )

    case "get_guild_commands":
        let commands = try await bot.getSlashCommands(guildId: testGuildId)
        try await sendDeferredInteractionDump(
            interaction,
            title: "GET /applications/{application.id}/guilds/{guild.id}/commands",
            value: EndpointCollectionDump(count: commands.count, items: commands),
            ephemeral: true
        )

    case "edit_global_command":
        let name = tempCommandName(prefix: "edg")
        let created = try await bot.createSlashCommand(name, description: "temp edit global")
        let edited = try await bot.editSlashCommand(
            commandId: created.id,
            edit: EditApplicationCommand(description: "edited \(name)")
        )
        try await bot.deleteSlashCommand(commandId: created.id)
        try await sendDeferredInteractionDump(
            interaction,
            title: "PATCH /applications/{application.id}/commands/{command.id}",
            value: CommandLifecycleResult(created: created, edited: edited, deleted: true),
            ephemeral: true
        )

    case "edit_guild_command":
        let name = tempCommandName(prefix: "edl")
        let created = try await bot.createSlashCommand(name, description: "temp edit guild", guildId: testGuildId)
        let edited = try await bot.editSlashCommand(
            commandId: created.id,
            guildId: testGuildId,
            edit: EditApplicationCommand(description: "edited \(name)")
        )
        try await bot.deleteSlashCommand(commandId: created.id, guildId: testGuildId)
        try await sendDeferredInteractionDump(
            interaction,
            title: "PATCH /applications/{application.id}/guilds/{guild.id}/commands/{command.id}",
            value: CommandLifecycleResult(created: created, edited: edited, deleted: true),
            ephemeral: true
        )

    case "delete_global_command":
        let name = tempCommandName(prefix: "delg")
        let created = try await bot.createSlashCommand(name, description: "temp delete global")
        try await bot.deleteSlashCommand(commandId: created.id)
        try await sendDeferredInteractionDump(
            interaction,
            title: "DELETE /applications/{application.id}/commands/{command.id}",
            value: CommandLifecycleResult(created: created, edited: nil, deleted: true),
            ephemeral: true
        )

    case "delete_guild_command":
        let name = tempCommandName(prefix: "dell")
        let created = try await bot.createSlashCommand(name, description: "temp delete guild", guildId: testGuildId)
        try await bot.deleteSlashCommand(commandId: created.id, guildId: testGuildId)
        try await sendDeferredInteractionDump(
            interaction,
            title: "DELETE /applications/{application.id}/guilds/{guild.id}/commands/{command.id}",
            value: CommandLifecycleResult(created: created, edited: nil, deleted: true),
            ephemeral: true
        )

    case "get_original_response":
        let original = try await interaction.getOriginalResponse()
        try await sendDeferredInteractionDump(
            interaction,
            title: "GET /webhooks/{application.id}/{interaction.token}/messages/@original",
            value: original,
            ephemeral: true
        )

    case "delete_original_response":
        let original = try await interaction.getOriginalResponse()
        try await interaction.deleteOriginalResponse()
        let chunks = renderEndpointDumpChunks(
            title: "DELETE /webhooks/{application.id}/{interaction.token}/messages/@original",
            value: DeleteMessageResult(channelId: original.channelId, messageId: original.id)
        )
        for chunk in chunks {
            _ = try await interaction.followUp(chunk, ephemeral: true)
        }

    case "get_guild_channels":
        let channels = try await bot.getGuildChannels(testGuildId)
        try await sendDeferredInteractionDump(
            interaction,
            title: "GET /guilds/{guild.id}/channels",
            value: EndpointCollectionDump(count: channels.count, items: channels),
            ephemeral: true
        )

    case "get_guild_members":
        let members = try await bot.getGuildMembers(testGuildId, query: GuildMembersQuery(limit: 25))
        try await sendDeferredInteractionDump(
            interaction,
            title: "GET /guilds/{guild.id}/members",
            value: EndpointCollectionDump(count: members.count, items: members),
            ephemeral: true
        )

    case "search_guild_members":
        let lookup = interaction.invoker?.username ?? "a"
        let members = try await bot.searchGuildMembers(
            testGuildId,
            query: GuildMemberSearchQuery(query: lookup, limit: 10)
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: "GET /guilds/{guild.id}/members/search",
            value: EndpointCollectionDump(count: members.count, items: members),
            ephemeral: true
        )

    case "modify_guild_member":
        guard let targetUserId = interaction.invoker?.id else {
            throw DiscordError.invalidRequest(message: "Unable to resolve target user for member patch test.")
        }
        let current = try await bot.getGuildMember(guildId: testGuildId, userId: targetUserId)
        let payload: ModifyGuildMember
        if let nick = current.nick {
            payload = ModifyGuildMember(nick: nick)
        } else if let deaf = current.deaf {
            payload = ModifyGuildMember(deaf: deaf)
        } else if let mute = current.mute {
            payload = ModifyGuildMember(mute: mute)
        } else {
            payload = ModifyGuildMember(roles: current.roles)
        }
        let patched = try await bot.modifyGuildMember(
            guildId: testGuildId,
            userId: targetUserId,
            modify: payload,
            auditLogReason: "DiscordKit PATCH guild member endpoint test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: "PATCH /guilds/{guild.id}/members/{user.id}",
            value: patched,
            ephemeral: true
        )

    case "add_member_role":
        guard let targetUserId = interaction.invoker?.id else {
            throw DiscordError.invalidRequest(message: "Unable to resolve target user for role add test.")
        }
        let roleId = try await resolvePanelRoleId(bot: bot, guildId: testGuildId, preferredRoleId: testRoleId)
        try await bot.addGuildMemberRole(
            guildId: testGuildId,
            userId: targetUserId,
            roleId: roleId,
            auditLogReason: "DiscordKit add role endpoint test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: "PUT /guilds/{guild.id}/members/{user.id}/roles/{role.id}",
            value: RoleMutationResult(guildId: testGuildId, userId: targetUserId, roleId: roleId, action: "add", success: true),
            ephemeral: true
        )

    case "remove_member_role":
        guard let targetUserId = interaction.invoker?.id else {
            throw DiscordError.invalidRequest(message: "Unable to resolve target user for role remove test.")
        }
        let roleId = try await resolvePanelRoleId(bot: bot, guildId: testGuildId, preferredRoleId: testRoleId)
        try await bot.removeGuildMemberRole(
            guildId: testGuildId,
            userId: targetUserId,
            roleId: roleId,
            auditLogReason: "DiscordKit remove role endpoint test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: "DELETE /guilds/{guild.id}/members/{user.id}/roles/{role.id}",
            value: RoleMutationResult(guildId: testGuildId, userId: targetUserId, roleId: roleId, action: "remove", success: true),
            ephemeral: true
        )

    default:
        throw DiscordError.invalidRequest(message: "Unknown panel test id '\(selected)'")
    }
}

private func resolvePanelRoleId(bot: DiscordBot, guildId: String, preferredRoleId: String?) async throws -> String {
    if let preferredRoleId, !preferredRoleId.isEmpty {
        return preferredRoleId
    }
    let roles = try await bot.getGuildRoles(guildId)
    guard let role = roles.first(where: { !$0.managed && $0.name != "@everyone" }) else {
        throw DiscordError.resourceNotFound(endpoint: "No assignable role found for role mutation tests")
    }
    return role.id
}

private func tempCommandName(prefix: String) -> String {
    let timestamp = Int(Date().timeIntervalSince1970)
    return "\(prefix)\(timestamp)"
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
                                        url: DemoImageURLs.swiftOrange
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
                                        url: DemoImageURLs.swift25
                                    )
                                ),
                                ComponentV2MediaGalleryItem(
                                    media: ComponentV2UnfurledMediaItem(
                                        url: DemoImageURLs.swiftGreen
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
