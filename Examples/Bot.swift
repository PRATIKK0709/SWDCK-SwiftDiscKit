import Foundation
import SWDCK

private enum LocalDefaults {
    static let token = "SET_BOT_TOKEN"
    static let guildId = "SET_TEST_GUILD_ID"
    static let channelId = "SET_TEST_CHANNEL_ID"
    static let roleId = "SET_TEST_ROLE_ID"
    static let banUserId = "SET_TEST_BAN_USER_ID"
    static let destructivePanelTests = "false"
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
struct SWDCKBotMain {
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
        let testBanUserId = ProcessInfo.processInfo.environment["TEST_BAN_USER_ID"]?.nonEmpty
            ?? dotenv["TEST_BAN_USER_ID"]?.nonEmpty
            ?? (LocalDefaults.banUserId == "SET_TEST_BAN_USER_ID" ? nil : LocalDefaults.banUserId)
        let destructivePanelTestsEnabled = (
            ProcessInfo.processInfo.environment["ENABLE_DESTRUCTIVE_PANEL_TESTS"]?.nonEmpty
            ?? dotenv["ENABLE_DESTRUCTIVE_PANEL_TESTS"]?.nonEmpty
            ?? LocalDefaults.destructivePanelTests
        ).lowercased() == "true"

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
                    content: "SWDCKBot is online. Use `!help` for text commands."
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
                do {
                    try await handleMessageComponentInteraction(
                        interaction: interaction,
                        bot: bot,
                        state: state,
                        testGuildId: testGuildId,
                        testChannelId: testChannelId,
                        testRoleId: testRoleId,
                        testBanUserId: testBanUserId,
                        destructivePanelTestsEnabled: destructivePanelTestsEnabled
                    )
                } catch {
                    print("Component interaction response failed: \(error)")
                    try? await interaction.respond("Component handling failed: \(friendlyError(error))", ephemeral: true)
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
                try await message.reply("Categorized endpoint dashboard sent. Use category selectors or quick buttons.")
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
            description: "Open categorized endpoint dashboard"
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

        print("Starting SWDCKBot...")
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

private struct InviteLifecycleResult: Encodable {
    let created: Invite
    let deleted: Invite?
    let channelInvitesCount: Int?
    let guildInvitesCount: Int?
}

private struct TypingResult: Encodable {
    let channelId: String
    let triggered: Bool
}

private struct PinMutationResult: Encodable {
    let channelId: String
    let messageId: String
    let action: String
    let pins: MessagePinsPage
}

private struct ReactionMutationResult: Encodable {
    let channelId: String
    let messageId: String
    let emoji: String
    let action: String
    let users: [DiscordUser]?
    let message: Message
}

private struct ChannelLifecycleResult: Encodable {
    let created: Channel
    let modified: Channel?
    let deleted: Channel?
}

private struct ThreadLifecycleResult: Encodable {
    let parentChannelId: String
    let thread: Channel
    let archivedSnapshot: ArchivedThreadsResponse?
    let members: [ChannelThreadMember]?
}

private struct GuildBanLifecycleResult: Encodable {
    let guildId: String
    let userId: String
    let createdBan: Bool
    let fetchedBan: GuildBan?
    let deletedBan: Bool
}

private struct GuildChannelPositionsResult: Encodable {
    let guildId: String
    let updatedChannelIds: [String]
}

private struct GuildRolePositionsResult: Encodable {
    let guildId: String
    let updatedRoles: [GuildRole]
}

private struct ChannelPermissionMutationResult: Encodable {
    let channelId: String
    let overwriteId: String
    let action: String
    let success: Bool
}

private struct WebhookLifecycleResult: Encodable {
    let created: Webhook
    let fetched: Webhook?
    let modified: Webhook?
    let channelWebhooksCount: Int?
    let guildWebhooksCount: Int?
    let deleted: Bool
}

private struct WebhookMessageLifecycleResult: Encodable {
    let webhookId: String
    let message: Message
    let fetched: Message?
    let edited: Message?
    let deleted: Bool
}

private struct GuildRoleLifecycleResult: Encodable {
    let created: GuildRole
    let fetched: GuildRole?
    let modified: GuildRole?
    let deleted: Bool
}

private struct LegacyPinsResult: Encodable {
    let channelId: String
    let messageId: String
    let action: String
    let pinsCount: Int
}

private struct PanelEndpointDefinition: Sendable {
    let id: String
    let label: String
    let libraryMethod: String
    let route: String
    let category: String
}

private struct PanelSmokeCheck: Encodable {
    let endpoint: String
    let success: Bool
    let details: String
}

private struct PanelSmokeSuiteResult: Encodable {
    let total: Int
    let passed: Int
    let failed: Int
    let checks: [PanelSmokeCheck]
}

private func panelGatewayEndpoints() -> [PanelEndpointDefinition] {
    [
        PanelEndpointDefinition(
            id: "gateway_url",
            label: "Gateway URL",
            libraryMethod: "bot.getGateway()",
            route: "GET /gateway",
            category: "Gateway"
        ),
        PanelEndpointDefinition(
            id: "gateway_bot",
            label: "Gateway Bot Metadata",
            libraryMethod: "bot.getGatewayBot()",
            route: "GET /gateway/bot",
            category: "Gateway"
        ),
    ]
}

private func panelCommandEndpoints() -> [PanelEndpointDefinition] {
    [
        PanelEndpointDefinition(
            id: "get_global_commands",
            label: "List Global Commands",
            libraryMethod: "bot.getSlashCommands()",
            route: "GET /applications/{application.id}/commands",
            category: "Application Commands"
        ),
        PanelEndpointDefinition(
            id: "get_guild_commands",
            label: "List Guild Commands",
            libraryMethod: "bot.getSlashCommands(guildId:)",
            route: "GET /applications/{application.id}/guilds/{guild.id}/commands",
            category: "Application Commands"
        ),
        PanelEndpointDefinition(
            id: "get_global_command_by_id",
            label: "Get Global Command By ID",
            libraryMethod: "bot.getSlashCommand(commandId:)",
            route: "GET /applications/{application.id}/commands/{command.id}",
            category: "Application Commands"
        ),
        PanelEndpointDefinition(
            id: "get_guild_command_by_id",
            label: "Get Guild Command By ID",
            libraryMethod: "bot.getSlashCommand(commandId:guildId:)",
            route: "GET /applications/{application.id}/guilds/{guild.id}/commands/{command.id}",
            category: "Application Commands"
        ),
        PanelEndpointDefinition(
            id: "edit_global_command",
            label: "Edit Global Command",
            libraryMethod: "bot.editSlashCommand(commandId:edit:)",
            route: "PATCH /applications/{application.id}/commands/{command.id}",
            category: "Application Commands"
        ),
        PanelEndpointDefinition(
            id: "edit_guild_command",
            label: "Edit Guild Command",
            libraryMethod: "bot.editSlashCommand(commandId:guildId:edit:)",
            route: "PATCH /applications/{application.id}/guilds/{guild.id}/commands/{command.id}",
            category: "Application Commands"
        ),
        PanelEndpointDefinition(
            id: "delete_global_command",
            label: "Delete Global Command",
            libraryMethod: "bot.deleteSlashCommand(commandId:)",
            route: "DELETE /applications/{application.id}/commands/{command.id}",
            category: "Application Commands"
        ),
        PanelEndpointDefinition(
            id: "delete_guild_command",
            label: "Delete Guild Command",
            libraryMethod: "bot.deleteSlashCommand(commandId:guildId:)",
            route: "DELETE /applications/{application.id}/guilds/{guild.id}/commands/{command.id}",
            category: "Application Commands"
        ),
    ]
}

private func panelInteractionEndpoints() -> [PanelEndpointDefinition] {
    [
        PanelEndpointDefinition(
            id: "get_original_response",
            label: "Fetch Original Interaction Response",
            libraryMethod: "interaction.getOriginalResponse()",
            route: "GET /webhooks/{application.id}/{interaction.token}/messages/@original",
            category: "Interaction Webhook"
        ),
        PanelEndpointDefinition(
            id: "delete_original_response",
            label: "Delete Original Interaction Response",
            libraryMethod: "interaction.deleteOriginalResponse()",
            route: "DELETE /webhooks/{application.id}/{interaction.token}/messages/@original",
            category: "Interaction Webhook"
        ),
    ]
}

private func panelGuildEndpoints() -> [PanelEndpointDefinition] {
    [
        PanelEndpointDefinition(
            id: "get_guild_channels",
            label: "List Guild Channels",
            libraryMethod: "bot.getGuildChannels(_:)",
            route: "GET /guilds/{guild.id}/channels",
            category: "Guild Resources"
        ),
        PanelEndpointDefinition(
            id: "get_guild_members",
            label: "List Guild Members",
            libraryMethod: "bot.getGuildMembers(_:query:)",
            route: "GET /guilds/{guild.id}/members",
            category: "Guild Resources"
        ),
        PanelEndpointDefinition(
            id: "search_guild_members",
            label: "Search Guild Members",
            libraryMethod: "bot.searchGuildMembers(_:query:)",
            route: "GET /guilds/{guild.id}/members/search",
            category: "Guild Resources"
        ),
        PanelEndpointDefinition(
            id: "modify_guild_member",
            label: "Modify Guild Member",
            libraryMethod: "bot.modifyGuildMember(...)",
            route: "PATCH /guilds/{guild.id}/members/{user.id}",
            category: "Guild Resources"
        ),
        PanelEndpointDefinition(
            id: "add_member_role",
            label: "Add Guild Member Role",
            libraryMethod: "bot.addGuildMemberRole(...)",
            route: "PUT /guilds/{guild.id}/members/{user.id}/roles/{role.id}",
            category: "Guild Resources"
        ),
        PanelEndpointDefinition(
            id: "remove_member_role",
            label: "Remove Guild Member Role",
            libraryMethod: "bot.removeGuildMemberRole(...)",
            route: "DELETE /guilds/{guild.id}/members/{user.id}/roles/{role.id}",
            category: "Guild Resources"
        ),
        PanelEndpointDefinition(
            id: "modify_guild",
            label: "Modify Guild",
            libraryMethod: "bot.modifyGuild(...)",
            route: "PATCH /guilds/{guild.id}",
            category: "Guild Resources"
        ),
        PanelEndpointDefinition(
            id: "get_guild_audit_log",
            label: "Get Guild Audit Log",
            libraryMethod: "bot.getGuildAuditLog(_:query:)",
            route: "GET /guilds/{guild.id}/audit-logs",
            category: "Guild Resources"
        ),
        PanelEndpointDefinition(
            id: "get_guild_bans",
            label: "Get Guild Bans",
            libraryMethod: "bot.getGuildBans(_:query:)",
            route: "GET /guilds/{guild.id}/bans",
            category: "Guild Resources"
        ),
        PanelEndpointDefinition(
            id: "get_guild_ban",
            label: "Get Guild Ban",
            libraryMethod: "bot.getGuildBan(guildId:userId:)",
            route: "GET /guilds/{guild.id}/bans/{user.id}",
            category: "Guild Resources"
        ),
        PanelEndpointDefinition(
            id: "create_guild_ban",
            label: "Create Guild Ban",
            libraryMethod: "bot.createGuildBan(guildId:userId:ban:)",
            route: "PUT /guilds/{guild.id}/bans/{user.id}",
            category: "Guild Resources"
        ),
        PanelEndpointDefinition(
            id: "delete_guild_ban",
            label: "Delete Guild Ban",
            libraryMethod: "bot.deleteGuildBan(guildId:userId:)",
            route: "DELETE /guilds/{guild.id}/bans/{user.id}",
            category: "Guild Resources"
        ),
        PanelEndpointDefinition(
            id: "get_guild_prune_count",
            label: "Get Guild Prune Count",
            libraryMethod: "bot.getGuildPruneCount(_:query:)",
            route: "GET /guilds/{guild.id}/prune",
            category: "Guild Resources"
        ),
        PanelEndpointDefinition(
            id: "begin_guild_prune",
            label: "Begin Guild Prune",
            libraryMethod: "bot.beginGuildPrune(_:prune:)",
            route: "POST /guilds/{guild.id}/prune",
            category: "Guild Resources"
        ),
        PanelEndpointDefinition(
            id: "modify_guild_channel_positions",
            label: "Modify Guild Channel Positions",
            libraryMethod: "bot.modifyGuildChannelPositions(...)",
            route: "PATCH /guilds/{guild.id}/channels",
            category: "Guild Resources"
        ),
        PanelEndpointDefinition(
            id: "modify_guild_role_positions",
            label: "Modify Guild Role Positions",
            libraryMethod: "bot.modifyGuildRolePositions(...)",
            route: "PATCH /guilds/{guild.id}/roles",
            category: "Guild Resources"
        ),
    ]
}

private func panelChannelMessageEndpoints() -> [PanelEndpointDefinition] {
    [
        PanelEndpointDefinition(
            id: "get_channel_invites",
            label: "List Channel Invites",
            libraryMethod: "bot.getChannelInvites(_:)",
            route: "GET /channels/{channel.id}/invites",
            category: "Channel + Message"
        ),
        PanelEndpointDefinition(
            id: "create_channel_invite",
            label: "Create Channel Invite",
            libraryMethod: "bot.createChannelInvite(...)",
            route: "POST /channels/{channel.id}/invites",
            category: "Channel + Message"
        ),
        PanelEndpointDefinition(
            id: "get_guild_invites",
            label: "List Guild Invites",
            libraryMethod: "bot.getGuildInvites(_:)",
            route: "GET /guilds/{guild.id}/invites",
            category: "Channel + Message"
        ),
        PanelEndpointDefinition(
            id: "delete_invite",
            label: "Delete Invite",
            libraryMethod: "bot.deleteInvite(code:)",
            route: "DELETE /invites/{invite.code}",
            category: "Channel + Message"
        ),
        PanelEndpointDefinition(
            id: "get_invite",
            label: "Get Invite By Code",
            libraryMethod: "bot.getInvite(code:query:)",
            route: "GET /invites/{invite.code}",
            category: "Channel + Message"
        ),
        PanelEndpointDefinition(
            id: "trigger_typing",
            label: "Trigger Typing Indicator",
            libraryMethod: "bot.triggerTyping(in:)",
            route: "POST /channels/{channel.id}/typing",
            category: "Channel + Message"
        ),
        PanelEndpointDefinition(
            id: "get_message_pins",
            label: "List Message Pins",
            libraryMethod: "bot.getMessagePins(channelId:query:)",
            route: "GET /channels/{channel.id}/messages/pins",
            category: "Channel + Message"
        ),
        PanelEndpointDefinition(
            id: "get_pins_legacy",
            label: "List Pins (Legacy Route)",
            libraryMethod: "bot.getPins(_:)",
            route: "GET /channels/{channel.id}/pins",
            category: "Channel + Message"
        ),
        PanelEndpointDefinition(
            id: "pin_message",
            label: "Pin Message",
            libraryMethod: "bot.pinMessage(channelId:messageId:)",
            route: "PUT /channels/{channel.id}/messages/pins/{message.id}",
            category: "Channel + Message"
        ),
        PanelEndpointDefinition(
            id: "pin_legacy",
            label: "Pin Message (Legacy Route)",
            libraryMethod: "bot.pin(channelId:messageId:)",
            route: "PUT /channels/{channel.id}/pins/{message.id}",
            category: "Channel + Message"
        ),
        PanelEndpointDefinition(
            id: "unpin_message",
            label: "Unpin Message",
            libraryMethod: "bot.unpinMessage(channelId:messageId:)",
            route: "DELETE /channels/{channel.id}/messages/pins/{message.id}",
            category: "Channel + Message"
        ),
        PanelEndpointDefinition(
            id: "unpin_legacy",
            label: "Unpin Message (Legacy Route)",
            libraryMethod: "bot.unpin(channelId:messageId:)",
            route: "DELETE /channels/{channel.id}/pins/{message.id}",
            category: "Channel + Message"
        ),
        PanelEndpointDefinition(
            id: "create_reaction",
            label: "Create Reaction (@me)",
            libraryMethod: "bot.createReaction(channelId:messageId:emoji:)",
            route: "PUT /channels/{channel.id}/messages/{message.id}/reactions/{emoji}/@me",
            category: "Channel + Message"
        ),
        PanelEndpointDefinition(
            id: "delete_own_reaction",
            label: "Delete Own Reaction",
            libraryMethod: "bot.deleteOwnReaction(channelId:messageId:emoji:)",
            route: "DELETE /channels/{channel.id}/messages/{message.id}/reactions/{emoji}/@me",
            category: "Channel + Message"
        ),
        PanelEndpointDefinition(
            id: "get_reactions",
            label: "List Reactions for Emoji",
            libraryMethod: "bot.getReactions(channelId:messageId:emoji:query:)",
            route: "GET /channels/{channel.id}/messages/{message.id}/reactions/{emoji}",
            category: "Channel + Message"
        ),
        PanelEndpointDefinition(
            id: "delete_user_reaction",
            label: "Delete User Reaction",
            libraryMethod: "bot.deleteUserReaction(channelId:messageId:emoji:userId:)",
            route: "DELETE /channels/{channel.id}/messages/{message.id}/reactions/{emoji}/{user.id}",
            category: "Channel + Message"
        ),
        PanelEndpointDefinition(
            id: "delete_all_reactions_for_emoji",
            label: "Delete All for Emoji",
            libraryMethod: "bot.deleteAllReactionsForEmoji(channelId:messageId:emoji:)",
            route: "DELETE /channels/{channel.id}/messages/{message.id}/reactions/{emoji}",
            category: "Channel + Message"
        ),
        PanelEndpointDefinition(
            id: "delete_all_reactions",
            label: "Delete All Reactions",
            libraryMethod: "bot.deleteAllReactions(channelId:messageId:)",
            route: "DELETE /channels/{channel.id}/messages/{message.id}/reactions",
            category: "Channel + Message"
        ),
        PanelEndpointDefinition(
            id: "edit_channel_permission",
            label: "Edit Channel Permission",
            libraryMethod: "bot.editChannelPermission(...)",
            route: "PUT /channels/{channel.id}/permissions/{overwrite.id}",
            category: "Channel + Message"
        ),
        PanelEndpointDefinition(
            id: "delete_channel_permission",
            label: "Delete Channel Permission",
            libraryMethod: "bot.deleteChannelPermission(...)",
            route: "DELETE /channels/{channel.id}/permissions/{overwrite.id}",
            category: "Channel + Message"
        ),
        PanelEndpointDefinition(
            id: "crosspost_message",
            label: "Crosspost Message",
            libraryMethod: "bot.crosspostMessage(channelId:messageId:)",
            route: "POST /channels/{channel.id}/messages/{message.id}/crosspost",
            category: "Channel + Message"
        ),
    ]
}

private func panelThreadLifecycleEndpoints() -> [PanelEndpointDefinition] {
    [
        PanelEndpointDefinition(
            id: "create_guild_channel",
            label: "Create Guild Channel",
            libraryMethod: "bot.createGuildChannel(guildId:channel:)",
            route: "POST /guilds/{guild.id}/channels",
            category: "Threads + Channel Lifecycle"
        ),
        PanelEndpointDefinition(
            id: "modify_channel",
            label: "Modify Channel",
            libraryMethod: "bot.modifyChannel(channelId:modify:)",
            route: "PATCH /channels/{channel.id}",
            category: "Threads + Channel Lifecycle"
        ),
        PanelEndpointDefinition(
            id: "delete_channel",
            label: "Delete Channel",
            libraryMethod: "bot.deleteChannel(channelId:)",
            route: "DELETE /channels/{channel.id}",
            category: "Threads + Channel Lifecycle"
        ),
        PanelEndpointDefinition(
            id: "start_thread_without_message",
            label: "Start Thread Without Message",
            libraryMethod: "bot.startThreadWithoutMessage(...)",
            route: "POST /channels/{channel.id}/threads",
            category: "Threads + Channel Lifecycle"
        ),
        PanelEndpointDefinition(
            id: "start_thread_from_message",
            label: "Start Thread From Message",
            libraryMethod: "bot.startThreadFromMessage(...)",
            route: "POST /channels/{channel.id}/messages/{message.id}/threads",
            category: "Threads + Channel Lifecycle"
        ),
        PanelEndpointDefinition(
            id: "get_public_archived_threads",
            label: "List Public Archived Threads",
            libraryMethod: "bot.getPublicArchivedThreads(...)",
            route: "GET /channels/{channel.id}/threads/archived/public",
            category: "Threads + Channel Lifecycle"
        ),
        PanelEndpointDefinition(
            id: "get_private_archived_threads",
            label: "List Private Archived Threads",
            libraryMethod: "bot.getPrivateArchivedThreads(...)",
            route: "GET /channels/{channel.id}/threads/archived/private",
            category: "Threads + Channel Lifecycle"
        ),
        PanelEndpointDefinition(
            id: "get_joined_private_archived_threads",
            label: "List Joined Private Archived",
            libraryMethod: "bot.getJoinedPrivateArchivedThreads(...)",
            route: "GET /channels/{channel.id}/users/@me/threads/archived/private",
            category: "Threads + Channel Lifecycle"
        ),
        PanelEndpointDefinition(
            id: "get_thread_members",
            label: "List Thread Members",
            libraryMethod: "bot.getThreadMembers(...)",
            route: "GET /channels/{channel.id}/thread-members",
            category: "Threads + Channel Lifecycle"
        ),
        PanelEndpointDefinition(
            id: "get_thread_member",
            label: "Get Thread Member",
            libraryMethod: "bot.getThreadMember(...)",
            route: "GET /channels/{channel.id}/thread-members/{user.id}",
            category: "Threads + Channel Lifecycle"
        ),
        PanelEndpointDefinition(
            id: "join_thread",
            label: "Join Thread (@me)",
            libraryMethod: "bot.joinThread(channelId:)",
            route: "PUT /channels/{channel.id}/thread-members/@me",
            category: "Threads + Channel Lifecycle"
        ),
        PanelEndpointDefinition(
            id: "leave_thread",
            label: "Leave Thread (@me)",
            libraryMethod: "bot.leaveThread(channelId:)",
            route: "DELETE /channels/{channel.id}/thread-members/@me",
            category: "Threads + Channel Lifecycle"
        ),
        PanelEndpointDefinition(
            id: "add_thread_member",
            label: "Add Thread Member",
            libraryMethod: "bot.addThreadMember(channelId:userId:)",
            route: "PUT /channels/{channel.id}/thread-members/{user.id}",
            category: "Threads + Channel Lifecycle"
        ),
        PanelEndpointDefinition(
            id: "get_active_guild_threads",
            label: "Get Active Guild Threads",
            libraryMethod: "bot.getActiveGuildThreads(guildId:)",
            route: "GET /guilds/{guild.id}/threads/active",
            category: "Threads + Channel Lifecycle"
        ),
    ]
}

private func panelWebhookRoleEndpoints() -> [PanelEndpointDefinition] {
    [
        PanelEndpointDefinition(
            id: "create_webhook",
            label: "Create Webhook",
            libraryMethod: "bot.createWebhook(...)",
            route: "POST /channels/{channel.id}/webhooks",
            category: "Webhooks + Roles"
        ),
        PanelEndpointDefinition(
            id: "get_channel_webhooks",
            label: "List Channel Webhooks",
            libraryMethod: "bot.getChannelWebhooks(_:)",
            route: "GET /channels/{channel.id}/webhooks",
            category: "Webhooks + Roles"
        ),
        PanelEndpointDefinition(
            id: "get_guild_webhooks",
            label: "List Guild Webhooks",
            libraryMethod: "bot.getGuildWebhooks(_:)",
            route: "GET /guilds/{guild.id}/webhooks",
            category: "Webhooks + Roles"
        ),
        PanelEndpointDefinition(
            id: "get_webhook",
            label: "Get Webhook",
            libraryMethod: "bot.getWebhook(_:)",
            route: "GET /webhooks/{webhook.id}",
            category: "Webhooks + Roles"
        ),
        PanelEndpointDefinition(
            id: "get_webhook_token",
            label: "Get Webhook With Token",
            libraryMethod: "bot.getWebhook(_:token:)",
            route: "GET /webhooks/{webhook.id}/{webhook.token}",
            category: "Webhooks + Roles"
        ),
        PanelEndpointDefinition(
            id: "modify_webhook",
            label: "Modify Webhook",
            libraryMethod: "bot.modifyWebhook(webhookId:modify:)",
            route: "PATCH /webhooks/{webhook.id}",
            category: "Webhooks + Roles"
        ),
        PanelEndpointDefinition(
            id: "modify_webhook_token",
            label: "Modify Webhook With Token",
            libraryMethod: "bot.modifyWebhook(webhookId:token:modify:)",
            route: "PATCH /webhooks/{webhook.id}/{webhook.token}",
            category: "Webhooks + Roles"
        ),
        PanelEndpointDefinition(
            id: "delete_webhook",
            label: "Delete Webhook",
            libraryMethod: "bot.deleteWebhook(webhookId:)",
            route: "DELETE /webhooks/{webhook.id}",
            category: "Webhooks + Roles"
        ),
        PanelEndpointDefinition(
            id: "delete_webhook_token",
            label: "Delete Webhook With Token",
            libraryMethod: "bot.deleteWebhook(webhookId:token:)",
            route: "DELETE /webhooks/{webhook.id}/{webhook.token}",
            category: "Webhooks + Roles"
        ),
        PanelEndpointDefinition(
            id: "execute_webhook",
            label: "Execute Webhook",
            libraryMethod: "bot.executeWebhook(...)",
            route: "POST /webhooks/{webhook.id}/{webhook.token}",
            category: "Webhooks + Roles"
        ),
        PanelEndpointDefinition(
            id: "get_webhook_message",
            label: "Get Webhook Message",
            libraryMethod: "bot.getWebhookMessage(...)",
            route: "GET /webhooks/{webhook.id}/{webhook.token}/messages/{message.id}",
            category: "Webhooks + Roles"
        ),
        PanelEndpointDefinition(
            id: "edit_webhook_message",
            label: "Edit Webhook Message",
            libraryMethod: "bot.editWebhookMessage(...)",
            route: "PATCH /webhooks/{webhook.id}/{webhook.token}/messages/{message.id}",
            category: "Webhooks + Roles"
        ),
        PanelEndpointDefinition(
            id: "delete_webhook_message",
            label: "Delete Webhook Message",
            libraryMethod: "bot.deleteWebhookMessage(...)",
            route: "DELETE /webhooks/{webhook.id}/{webhook.token}/messages/{message.id}",
            category: "Webhooks + Roles"
        ),
        PanelEndpointDefinition(
            id: "create_guild_role",
            label: "Create Guild Role",
            libraryMethod: "bot.createGuildRole(...)",
            route: "POST /guilds/{guild.id}/roles",
            category: "Webhooks + Roles"
        ),
        PanelEndpointDefinition(
            id: "get_guild_role",
            label: "Get Guild Role",
            libraryMethod: "bot.getGuildRole(guildId:roleId:)",
            route: "GET /guilds/{guild.id}/roles/{role.id}",
            category: "Webhooks + Roles"
        ),
        PanelEndpointDefinition(
            id: "modify_guild_role",
            label: "Modify Guild Role",
            libraryMethod: "bot.modifyGuildRole(...)",
            route: "PATCH /guilds/{guild.id}/roles/{role.id}",
            category: "Webhooks + Roles"
        ),
        PanelEndpointDefinition(
            id: "delete_guild_role",
            label: "Delete Guild Role",
            libraryMethod: "bot.deleteGuildRole(...)",
            route: "DELETE /guilds/{guild.id}/roles/{role.id}",
            category: "Webhooks + Roles"
        ),
    ]
}

private func panelEndpointCatalog() -> [PanelEndpointDefinition] {
    panelGatewayEndpoints()
        + panelCommandEndpoints()
        + panelInteractionEndpoints()
        + panelGuildEndpoints()
        + panelChannelMessageEndpoints()
        + panelThreadLifecycleEndpoints()
        + panelWebhookRoleEndpoints()
}

private func panelEndpoint(by id: String) -> PanelEndpointDefinition? {
    panelEndpointCatalog().first { $0.id == id }
}

private func panelEndpointTitle(_ id: String) -> String {
    guard let endpoint = panelEndpoint(by: id) else {
        return "Endpoint Test"
    }
    return "\(endpoint.category) · \(endpoint.libraryMethod) · \(endpoint.route)"
}

private func panelOptions(from endpoints: [PanelEndpointDefinition]) -> [ComponentV2SelectOption] {
    endpoints.map {
        ComponentV2SelectOption(
            label: $0.label,
            value: $0.id,
            description: $0.libraryMethod
        )
    }
}

private func panelSelect(customId: String, placeholder: String, endpoints: [PanelEndpointDefinition]) -> ComponentV2Node {
    .actionRow(
        ComponentV2ActionRow(
            components: [
                .stringSelect(
                    ComponentV2StringSelect(
                        customId: customId,
                        options: panelOptions(from: endpoints),
                        placeholder: placeholder,
                        minValues: 1,
                        maxValues: 1
                    )
                )
            ]
        )
    )
}

private func apiTestPanelData() -> [ComponentV2Node] {
    [
        .textDisplay(ComponentV2TextDisplay("## SwiftDiscKit Endpoint Test Dashboard")),
        .textDisplay(
            ComponentV2TextDisplay(
                """
                Use the category menus below to run endpoint tests.
                Results are returned as ephemeral JSON dumps so you can verify payload shape quickly.
                """
            )
        ),
        .actionRow(
            ComponentV2ActionRow(
                components: [
                    .button(ComponentV2Button(style: .primary, label: "Run Smoke Suite", customId: "api_quick_smoke")),
                    .button(ComponentV2Button(style: .secondary, label: "Usage Guide", customId: "api_quick_guide")),
                    .button(ComponentV2Button(style: .success, label: "Refresh Panel", customId: "api_quick_refresh")),
                ]
            )
        ),
        .separator(ComponentV2Separator(divider: true, spacing: 1)),
        .textDisplay(ComponentV2TextDisplay("### Gateway")),
        .textDisplay(ComponentV2TextDisplay("Session and sharding metadata endpoints.")),
        panelSelect(
            customId: "api_select_gateway",
            placeholder: "Run gateway endpoint test",
            endpoints: panelGatewayEndpoints()
        ),
        .separator(ComponentV2Separator(divider: true, spacing: 1)),
        .textDisplay(ComponentV2TextDisplay("### Application Commands")),
        .textDisplay(ComponentV2TextDisplay("Create, list, edit, and delete command endpoint validation.")),
        panelSelect(
            customId: "api_select_commands",
            placeholder: "Run application command endpoint test",
            endpoints: panelCommandEndpoints()
        ),
        .separator(ComponentV2Separator(divider: true, spacing: 1)),
        .textDisplay(ComponentV2TextDisplay("### Interaction Webhook")),
        .textDisplay(ComponentV2TextDisplay("Validate original interaction response fetch/delete operations.")),
        panelSelect(
            customId: "api_select_interactions",
            placeholder: "Run interaction webhook endpoint test",
            endpoints: panelInteractionEndpoints()
        ),
        .separator(ComponentV2Separator(divider: true, spacing: 1)),
        .textDisplay(ComponentV2TextDisplay("### Guild Resources")),
        .textDisplay(ComponentV2TextDisplay("Guild metadata, audit logs, bans, prune, members, and role/channel position mutation endpoints.")),
        panelSelect(
            customId: "api_select_guild",
            placeholder: "Run guild resource endpoint test",
            endpoints: panelGuildEndpoints()
        ),
        .separator(ComponentV2Separator(divider: true, spacing: 1)),
        .textDisplay(ComponentV2TextDisplay("### Channel + Message")),
        .textDisplay(ComponentV2TextDisplay("Invites, typing, pins, and reaction lifecycle endpoints.")),
        panelSelect(
            customId: "api_select_channel_message",
            placeholder: "Run channel + message endpoint test",
            endpoints: panelChannelMessageEndpoints()
        ),
        .separator(ComponentV2Separator(divider: true, spacing: 1)),
        .textDisplay(ComponentV2TextDisplay("### Threads + Channel Lifecycle")),
        .textDisplay(ComponentV2TextDisplay("Channel create/update/delete, active thread discovery, and thread membership lifecycle endpoints.")),
        panelSelect(
            customId: "api_select_thread_lifecycle",
            placeholder: "Run thread + channel lifecycle test",
            endpoints: panelThreadLifecycleEndpoints()
        ),
        .textDisplay(ComponentV2TextDisplay("### Webhooks + Roles")),
        .textDisplay(ComponentV2TextDisplay("Webhook lifecycle, webhook messages, and guild role lifecycle endpoints.")),
        panelSelect(
            customId: "api_select_webhook_role",
            placeholder: "Run webhook + role endpoint test",
            endpoints: panelWebhookRoleEndpoints()
        ),
    ]
}

private func selectedPanelEndpointId(customId: String, values: [String]?) -> String? {
    let panelSelectIds: Set<String> = [
        "api_test_select",
        "api_select_gateway",
        "api_select_commands",
        "api_select_interactions",
        "api_select_guild",
        "api_select_channel_message",
        "api_select_thread_lifecycle",
        "api_select_webhook_role",
    ]
    guard panelSelectIds.contains(customId) else { return nil }
    return values?.first
}

private func handleMessageComponentInteraction(
    interaction: Interaction,
    bot: DiscordBot,
    state: DemoState,
    testGuildId: String,
    testChannelId: String,
    testRoleId: String?,
    testBanUserId: String?,
    destructivePanelTestsEnabled: Bool
) async throws {
    let customId = interaction.data?.customId ?? ""
    let selectedValues = interaction.data?.values
    let selectedValuesText = selectedValues?.joined(separator: ", ") ?? "none"

    if let selected = selectedPanelEndpointId(customId: customId, values: selectedValues) {
        try await interaction.defer_(ephemeral: true)
        do {
            try await runPanelTest(
                selected,
                bot: bot,
                interaction: interaction,
                testGuildId: testGuildId,
                testChannelId: testChannelId,
                testRoleId: testRoleId,
                testBanUserId: testBanUserId,
                destructivePanelTestsEnabled: destructivePanelTestsEnabled
            )
        } catch {
            _ = try? await interaction.editResponse("Endpoint test failed: \(friendlyError(error))")
        }
        return
    }

    switch customId {
    case "api_quick_smoke":
        try await interaction.defer_(ephemeral: true)
        do {
            try await runPanelSmokeSuite(
                bot: bot,
                interaction: interaction,
                testGuildId: testGuildId,
                testChannelId: testChannelId
            )
        } catch {
            _ = try? await interaction.editResponse("Smoke suite failed: \(friendlyError(error))")
        }

    case "api_quick_guide":
        try await interaction.respond(
            """
            Dashboard usage:
            - Pick one endpoint from a category menu
            - Wait for the ephemeral JSON result
            - Use Run Smoke Suite for fast sanity checks
            - Set ENABLE_DESTRUCTIVE_PANEL_TESTS=true to run ban/prune mutation tests
            """,
            ephemeral: true
        )

    case "api_quick_refresh":
        guard let channelId = interaction.channelId else {
            try await interaction.respond("No channel available to post refreshed dashboard.", ephemeral: true)
            return
        }
        try await interaction.defer_(ephemeral: true)
        let sent = try await bot.sendComponentsV2Message(to: channelId, components: apiTestPanelData())
        await state.setLastBotMessage(sent)
        _ = try await interaction.editResponse("Dashboard refreshed. New panel message id: \(sent.id)")

    case let value where value.hasPrefix("cv2_btn_"):
        try await interaction.respond("Button interaction: \(value)", ephemeral: true)

    case let value where value.hasPrefix("cv2_select_"):
        try await interaction.respond("Selection for \(value): \(selectedValuesText)", ephemeral: true)

    default:
        try await interaction.respond("Unsupported component action `\(customId)`.", ephemeral: true)
    }
}

private func runPanelSmokeSuite(
    bot: DiscordBot,
    interaction: Interaction,
    testGuildId: String,
    testChannelId: String
) async throws {
    var checks: [PanelSmokeCheck] = []

    do {
        let gateway = try await bot.getGateway()
        checks.append(PanelSmokeCheck(endpoint: "bot.getGateway()", success: true, details: "url=\(gateway.url)"))
    } catch {
        checks.append(PanelSmokeCheck(endpoint: "bot.getGateway()", success: false, details: friendlyError(error)))
    }

    do {
        let gateway = try await bot.getGatewayBot()
        let shardInfo = gateway.shards.map(String.init) ?? "unknown"
        checks.append(PanelSmokeCheck(endpoint: "bot.getGatewayBot()", success: true, details: "shards=\(shardInfo)"))
    } catch {
        checks.append(PanelSmokeCheck(endpoint: "bot.getGatewayBot()", success: false, details: friendlyError(error)))
    }

    do {
        let channels = try await bot.getGuildChannels(testGuildId)
        checks.append(PanelSmokeCheck(endpoint: "bot.getGuildChannels(_:)", success: true, details: "count=\(channels.count)"))
    } catch {
        checks.append(PanelSmokeCheck(endpoint: "bot.getGuildChannels(_:)", success: false, details: friendlyError(error)))
    }

    do {
        let commands = try await bot.getSlashCommands(guildId: testGuildId)
        checks.append(PanelSmokeCheck(endpoint: "bot.getSlashCommands(guildId:)", success: true, details: "count=\(commands.count)"))
    } catch {
        checks.append(PanelSmokeCheck(endpoint: "bot.getSlashCommands(guildId:)", success: false, details: friendlyError(error)))
    }

    do {
        let sent = try await bot.sendMessage(to: testChannelId, content: "Smoke suite message endpoint check.")
        checks.append(PanelSmokeCheck(endpoint: "bot.sendMessage(to:content:)", success: true, details: "message_id=\(sent.id)"))
    } catch {
        checks.append(PanelSmokeCheck(endpoint: "bot.sendMessage(to:content:)", success: false, details: friendlyError(error)))
    }

    let passed = checks.filter(\.success).count
    let result = PanelSmokeSuiteResult(
        total: checks.count,
        passed: passed,
        failed: checks.count - passed,
        checks: checks
    )
    try await sendDeferredInteractionDump(
        interaction,
        title: "Smoke Suite · SwiftDiscKit",
        value: result,
        ephemeral: true
    )
}

private func runPanelTest(
    _ selected: String,
    bot: DiscordBot,
    interaction: Interaction,
    testGuildId: String,
    testChannelId: String,
    testRoleId: String?,
    testBanUserId: String?,
    destructivePanelTestsEnabled: Bool
) async throws {
    let title = panelEndpointTitle(selected)

    switch selected {
    case "gateway_url":
        let gateway = try await bot.getGateway()
        try await sendDeferredInteractionDump(interaction, title: title, value: gateway, ephemeral: true)

    case "gateway_bot":
        let gateway = try await bot.getGatewayBot()
        try await sendDeferredInteractionDump(interaction, title: title, value: gateway, ephemeral: true)

    case "get_global_commands":
        let commands = try await bot.getSlashCommands()
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: EndpointCollectionDump(count: commands.count, items: commands),
            ephemeral: true
        )

    case "get_guild_commands":
        let commands = try await bot.getSlashCommands(guildId: testGuildId)
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: EndpointCollectionDump(count: commands.count, items: commands),
            ephemeral: true
        )

    case "get_global_command_by_id":
        let name = tempCommandName(prefix: "gcid")
        let created = try await bot.createSlashCommand(name, description: "temp get global command")
        let fetched = try await bot.getSlashCommand(commandId: created.id)
        try await bot.deleteSlashCommand(commandId: created.id)
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: CommandLifecycleResult(created: fetched, edited: nil, deleted: true),
            ephemeral: true
        )

    case "get_guild_command_by_id":
        let name = tempCommandName(prefix: "gcidg")
        let created = try await bot.createSlashCommand(name, description: "temp get guild command", guildId: testGuildId)
        let fetched = try await bot.getSlashCommand(commandId: created.id, guildId: testGuildId)
        try await bot.deleteSlashCommand(commandId: created.id, guildId: testGuildId)
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: CommandLifecycleResult(created: fetched, edited: nil, deleted: true),
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
            title: title,
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
            title: title,
            value: CommandLifecycleResult(created: created, edited: edited, deleted: true),
            ephemeral: true
        )

    case "delete_global_command":
        let name = tempCommandName(prefix: "delg")
        let created = try await bot.createSlashCommand(name, description: "temp delete global")
        try await bot.deleteSlashCommand(commandId: created.id)
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: CommandLifecycleResult(created: created, edited: nil, deleted: true),
            ephemeral: true
        )

    case "delete_guild_command":
        let name = tempCommandName(prefix: "dell")
        let created = try await bot.createSlashCommand(name, description: "temp delete guild", guildId: testGuildId)
        try await bot.deleteSlashCommand(commandId: created.id, guildId: testGuildId)
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: CommandLifecycleResult(created: created, edited: nil, deleted: true),
            ephemeral: true
        )

    case "get_original_response":
        let original = try await interaction.getOriginalResponse()
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: original,
            ephemeral: true
        )

    case "delete_original_response":
        let original = try await interaction.getOriginalResponse()
        try await interaction.deleteOriginalResponse()
        let chunks = renderEndpointDumpChunks(
            title: title,
            value: DeleteMessageResult(channelId: original.channelId, messageId: original.id)
        )
        for chunk in chunks {
            _ = try await interaction.followUp(chunk, ephemeral: true)
        }

    case "get_guild_channels":
        let channels = try await bot.getGuildChannels(testGuildId)
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: EndpointCollectionDump(count: channels.count, items: channels),
            ephemeral: true
        )

    case "get_guild_members":
        let members = try await bot.getGuildMembers(testGuildId, query: GuildMembersQuery(limit: 25))
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
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
            title: title,
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
            auditLogReason: "SWDCK PATCH guild member endpoint test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
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
            auditLogReason: "SWDCK add role endpoint test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
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
            auditLogReason: "SWDCK remove role endpoint test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: RoleMutationResult(guildId: testGuildId, userId: targetUserId, roleId: roleId, action: "remove", success: true),
            ephemeral: true
        )

    case "modify_guild":
        let guild = try await bot.getGuild(testGuildId)
        let modified = try await bot.modifyGuild(
            guildId: testGuildId,
            modify: ModifyGuild(
                name: guild.name,
                preferredLocale: guild.preferredLocale,
                description: guild.description
            ),
            auditLogReason: "SWDCK modify guild endpoint test"
        )
        try await sendDeferredInteractionDump(interaction, title: title, value: modified, ephemeral: true)

    case "get_guild_audit_log":
        let auditLog = try await bot.getGuildAuditLog(testGuildId, query: GuildAuditLogQuery(limit: 10))
        try await sendDeferredInteractionDump(interaction, title: title, value: auditLog, ephemeral: true)

    case "get_guild_bans":
        let bans = try await bot.getGuildBans(testGuildId, query: GuildBansQuery(limit: 25))
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: EndpointCollectionDump(count: bans.count, items: bans),
            ephemeral: true
        )

    case "get_guild_ban":
        guard let targetUserId = testBanUserId else {
            throw DiscordError.invalidRequest(
                message: "Set TEST_BAN_USER_ID in your environment or .env for get_guild_ban."
            )
        }
        let ban = try await bot.getGuildBan(guildId: testGuildId, userId: targetUserId)
        try await sendDeferredInteractionDump(interaction, title: title, value: ban, ephemeral: true)

    case "create_guild_ban":
        guard destructivePanelTestsEnabled else {
            throw DiscordError.invalidRequest(
                message: "Enable destructive tests with ENABLE_DESTRUCTIVE_PANEL_TESTS=true before running create_guild_ban."
            )
        }
        guard let targetUserId = testBanUserId else {
            throw DiscordError.invalidRequest(
                message: "Set TEST_BAN_USER_ID in your environment or .env for create_guild_ban."
            )
        }
        try await bot.createGuildBan(
            guildId: testGuildId,
            userId: targetUserId,
            ban: CreateGuildBan(deleteMessageSeconds: 0),
            auditLogReason: "SWDCK create guild ban endpoint test"
        )
        let fetched = try? await bot.getGuildBan(guildId: testGuildId, userId: targetUserId)
        try? await bot.deleteGuildBan(
            guildId: testGuildId,
            userId: targetUserId,
            auditLogReason: "SWDCK cleanup create guild ban endpoint test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: GuildBanLifecycleResult(
                guildId: testGuildId,
                userId: targetUserId,
                createdBan: true,
                fetchedBan: fetched,
                deletedBan: true
            ),
            ephemeral: true
        )

    case "delete_guild_ban":
        guard destructivePanelTestsEnabled else {
            throw DiscordError.invalidRequest(
                message: "Enable destructive tests with ENABLE_DESTRUCTIVE_PANEL_TESTS=true before running delete_guild_ban."
            )
        }
        guard let targetUserId = testBanUserId else {
            throw DiscordError.invalidRequest(
                message: "Set TEST_BAN_USER_ID in your environment or .env for delete_guild_ban."
            )
        }
        try await bot.createGuildBan(
            guildId: testGuildId,
            userId: targetUserId,
            ban: CreateGuildBan(deleteMessageSeconds: 0),
            auditLogReason: "SWDCK setup delete guild ban endpoint test"
        )
        try await bot.deleteGuildBan(
            guildId: testGuildId,
            userId: targetUserId,
            auditLogReason: "SWDCK delete guild ban endpoint test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: GuildBanLifecycleResult(
                guildId: testGuildId,
                userId: targetUserId,
                createdBan: true,
                fetchedBan: nil,
                deletedBan: true
            ),
            ephemeral: true
        )

    case "get_guild_prune_count":
        let prune = try await bot.getGuildPruneCount(
            testGuildId,
            query: GuildPruneCountQuery(days: 3650)
        )
        try await sendDeferredInteractionDump(interaction, title: title, value: prune, ephemeral: true)

    case "begin_guild_prune":
        guard destructivePanelTestsEnabled else {
            throw DiscordError.invalidRequest(
                message: "Enable destructive tests with ENABLE_DESTRUCTIVE_PANEL_TESTS=true before running begin_guild_prune."
            )
        }
        let prune = try await bot.beginGuildPrune(
            testGuildId,
            prune: BeginGuildPrune(days: 3650, computePruneCount: true),
            auditLogReason: "SWDCK begin guild prune endpoint test"
        )
        try await sendDeferredInteractionDump(interaction, title: title, value: prune, ephemeral: true)

    case "modify_guild_channel_positions":
        let channels = try await bot.getGuildChannels(testGuildId)
        guard let channel = channels.first(where: { $0.position != nil }) else {
            throw DiscordError.resourceNotFound(endpoint: "No guild channel with position available for reorder test.")
        }
        let payload = [ModifyGuildChannelPosition(id: channel.id, position: channel.position, parentId: channel.parentId)]
        try await bot.modifyGuildChannelPositions(
            guildId: testGuildId,
            positions: payload,
            auditLogReason: "SWDCK modify guild channel positions endpoint test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: GuildChannelPositionsResult(guildId: testGuildId, updatedChannelIds: payload.map(\.id)),
            ephemeral: true
        )

    case "modify_guild_role_positions":
        let roles = try await bot.getGuildRoles(testGuildId)
        guard let targetRole = roles.first(where: { $0.name != "@everyone" }) else {
            throw DiscordError.resourceNotFound(endpoint: "No guild role available for role position test.")
        }
        let updated = try await bot.modifyGuildRolePositions(
            guildId: testGuildId,
            positions: [ModifyGuildRolePosition(id: targetRole.id, position: targetRole.position)],
            auditLogReason: "SWDCK modify guild role positions endpoint test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: GuildRolePositionsResult(guildId: testGuildId, updatedRoles: updated),
            ephemeral: true
        )

    case "get_channel_invites":
        let invites = try await bot.getChannelInvites(testChannelId)
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: EndpointCollectionDump(count: invites.count, items: invites),
            ephemeral: true
        )

    case "create_channel_invite":
        let invite = try await bot.createChannelInvite(
            channelId: testChannelId,
            invite: CreateChannelInvite(
                maxAge: 3600,
                maxUses: 5,
                temporary: false,
                unique: true
            ),
            auditLogReason: "SWDCK create invite endpoint test"
        )
        let channelInvites = try await bot.getChannelInvites(testChannelId)
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: InviteLifecycleResult(
                created: invite,
                deleted: nil,
                channelInvitesCount: channelInvites.count,
                guildInvitesCount: nil
            ),
            ephemeral: true
        )

    case "get_guild_invites":
        let invites = try await bot.getGuildInvites(testGuildId)
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: EndpointCollectionDump(count: invites.count, items: invites),
            ephemeral: true
        )

    case "delete_invite":
        let invite = try await bot.createChannelInvite(
            channelId: testChannelId,
            invite: CreateChannelInvite(maxAge: 600, maxUses: 1, unique: true),
            auditLogReason: "SWDCK create invite for delete test"
        )
        let deleted = try await bot.deleteInvite(
            code: invite.code,
            auditLogReason: "SWDCK delete invite endpoint test"
        )
        let guildInvites = try await bot.getGuildInvites(testGuildId)
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: InviteLifecycleResult(
                created: invite,
                deleted: deleted,
                channelInvitesCount: nil,
                guildInvitesCount: guildInvites.count
            ),
            ephemeral: true
        )

    case "get_invite":
        let invite = try await bot.createChannelInvite(
            channelId: testChannelId,
            invite: CreateChannelInvite(maxAge: 3600, maxUses: 5, unique: true),
            auditLogReason: "SWDCK create invite for get test"
        )
        let fetched = try await bot.getInvite(
            code: invite.code,
            query: GetInviteQuery(withCounts: true, withExpiration: true)
        )
        _ = try? await bot.deleteInvite(code: invite.code, auditLogReason: "SWDCK cleanup invite after get test")
        try await sendDeferredInteractionDump(interaction, title: title, value: fetched, ephemeral: true)

    case "trigger_typing":
        try await bot.triggerTyping(in: testChannelId)
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: TypingResult(channelId: testChannelId, triggered: true),
            ephemeral: true
        )

    case "get_message_pins":
        let pins = try await bot.getMessagePins(
            channelId: testChannelId,
            query: MessagePinsQuery(limit: 25)
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: pins,
            ephemeral: true
        )

    case "get_pins_legacy":
        let pins = try await bot.getPins(testChannelId)
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: EndpointCollectionDump(count: pins.count, items: pins),
            ephemeral: true
        )

    case "pin_message":
        let testMessage = try await bot.sendMessage(
            to: testChannelId,
            content: "Pin endpoint test \(Int(Date().timeIntervalSince1970))"
        )
        try await bot.pinMessage(
            channelId: testMessage.channelId,
            messageId: testMessage.id,
            auditLogReason: "SWDCK pin message endpoint test"
        )
        let pins = try await bot.getMessagePins(channelId: testMessage.channelId, query: MessagePinsQuery(limit: 25))
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: PinMutationResult(
                channelId: testMessage.channelId,
                messageId: testMessage.id,
                action: "pin",
                pins: pins
            ),
            ephemeral: true
        )

    case "pin_legacy":
        let testMessage = try await bot.sendMessage(
            to: testChannelId,
            content: "Legacy pin endpoint test \(Int(Date().timeIntervalSince1970))"
        )
        try await bot.pin(
            channelId: testMessage.channelId,
            messageId: testMessage.id,
            auditLogReason: "SWDCK legacy pin endpoint test"
        )
        let pins = try await bot.getPins(testMessage.channelId)
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: LegacyPinsResult(
                channelId: testMessage.channelId,
                messageId: testMessage.id,
                action: "pin_legacy",
                pinsCount: pins.count
            ),
            ephemeral: true
        )

    case "unpin_message":
        let testMessage = try await bot.sendMessage(
            to: testChannelId,
            content: "Unpin endpoint test \(Int(Date().timeIntervalSince1970))"
        )
        try await bot.pinMessage(
            channelId: testMessage.channelId,
            messageId: testMessage.id,
            auditLogReason: "SWDCK pre-pin for unpin endpoint test"
        )
        try await bot.unpinMessage(
            channelId: testMessage.channelId,
            messageId: testMessage.id,
            auditLogReason: "SWDCK unpin message endpoint test"
        )
        let pins = try await bot.getMessagePins(channelId: testMessage.channelId, query: MessagePinsQuery(limit: 25))
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: PinMutationResult(
                channelId: testMessage.channelId,
                messageId: testMessage.id,
                action: "unpin",
                pins: pins
            ),
            ephemeral: true
        )

    case "unpin_legacy":
        let testMessage = try await bot.sendMessage(
            to: testChannelId,
            content: "Legacy unpin endpoint test \(Int(Date().timeIntervalSince1970))"
        )
        try await bot.pin(
            channelId: testMessage.channelId,
            messageId: testMessage.id,
            auditLogReason: "SWDCK setup legacy unpin endpoint test"
        )
        try await bot.unpin(
            channelId: testMessage.channelId,
            messageId: testMessage.id,
            auditLogReason: "SWDCK legacy unpin endpoint test"
        )
        let pins = try await bot.getPins(testMessage.channelId)
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: LegacyPinsResult(
                channelId: testMessage.channelId,
                messageId: testMessage.id,
                action: "unpin_legacy",
                pinsCount: pins.count
            ),
            ephemeral: true
        )

    case "create_reaction":
        let emoji = "🔥"
        let testMessage = try await bot.sendMessage(
            to: testChannelId,
            content: "Create reaction endpoint test \(Int(Date().timeIntervalSince1970))"
        )
        try await bot.createReaction(channelId: testMessage.channelId, messageId: testMessage.id, emoji: emoji)
        let users = try await bot.getReactions(
            channelId: testMessage.channelId,
            messageId: testMessage.id,
            emoji: emoji,
            query: ReactionUsersQuery(limit: 25)
        )
        let updatedMessage = try await bot.getMessage(channelId: testMessage.channelId, messageId: testMessage.id)
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: ReactionMutationResult(
                channelId: testMessage.channelId,
                messageId: testMessage.id,
                emoji: emoji,
                action: "create",
                users: users,
                message: updatedMessage
            ),
            ephemeral: true
        )

    case "delete_own_reaction":
        let emoji = "🔥"
        let testMessage = try await bot.sendMessage(
            to: testChannelId,
            content: "Delete own reaction endpoint test \(Int(Date().timeIntervalSince1970))"
        )
        try await bot.createReaction(channelId: testMessage.channelId, messageId: testMessage.id, emoji: emoji)
        try await bot.deleteOwnReaction(channelId: testMessage.channelId, messageId: testMessage.id, emoji: emoji)
        let updatedMessage = try await bot.getMessage(channelId: testMessage.channelId, messageId: testMessage.id)
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: ReactionMutationResult(
                channelId: testMessage.channelId,
                messageId: testMessage.id,
                emoji: emoji,
                action: "delete_own",
                users: nil,
                message: updatedMessage
            ),
            ephemeral: true
        )

    case "get_reactions":
        let emoji = "🔥"
        let testMessage = try await bot.sendMessage(
            to: testChannelId,
            content: "Get reactions endpoint test \(Int(Date().timeIntervalSince1970))"
        )
        try await bot.createReaction(channelId: testMessage.channelId, messageId: testMessage.id, emoji: emoji)
        let users = try await bot.getReactions(
            channelId: testMessage.channelId,
            messageId: testMessage.id,
            emoji: emoji,
            query: ReactionUsersQuery(limit: 100, type: .normal)
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: EndpointCollectionDump(count: users.count, items: users),
            ephemeral: true
        )

    case "delete_user_reaction":
        let emoji = "🔥"
        let testMessage = try await bot.sendMessage(
            to: testChannelId,
            content: "Delete user reaction endpoint test \(Int(Date().timeIntervalSince1970))"
        )
        try await bot.createReaction(channelId: testMessage.channelId, messageId: testMessage.id, emoji: emoji)
        guard let botUserId = await bot.currentUser?.id else {
            throw DiscordError.invalidRequest(message: "Bot user ID not available yet.")
        }
        try await bot.deleteUserReaction(
            channelId: testMessage.channelId,
            messageId: testMessage.id,
            emoji: emoji,
            userId: botUserId
        )
        let updatedMessage = try await bot.getMessage(channelId: testMessage.channelId, messageId: testMessage.id)
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: ReactionMutationResult(
                channelId: testMessage.channelId,
                messageId: testMessage.id,
                emoji: emoji,
                action: "delete_user",
                users: nil,
                message: updatedMessage
            ),
            ephemeral: true
        )

    case "delete_all_reactions_for_emoji":
        let emoji = "🔥"
        let testMessage = try await bot.sendMessage(
            to: testChannelId,
            content: "Delete reactions for emoji endpoint test \(Int(Date().timeIntervalSince1970))"
        )
        try await bot.createReaction(channelId: testMessage.channelId, messageId: testMessage.id, emoji: emoji)
        try await bot.deleteAllReactionsForEmoji(channelId: testMessage.channelId, messageId: testMessage.id, emoji: emoji)
        let updatedMessage = try await bot.getMessage(channelId: testMessage.channelId, messageId: testMessage.id)
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: ReactionMutationResult(
                channelId: testMessage.channelId,
                messageId: testMessage.id,
                emoji: emoji,
                action: "delete_all_for_emoji",
                users: nil,
                message: updatedMessage
            ),
            ephemeral: true
        )

    case "delete_all_reactions":
        let testMessage = try await bot.sendMessage(
            to: testChannelId,
            content: "Delete all reactions endpoint test \(Int(Date().timeIntervalSince1970))"
        )
        try await bot.createReaction(channelId: testMessage.channelId, messageId: testMessage.id, emoji: "🔥")
        try await bot.createReaction(channelId: testMessage.channelId, messageId: testMessage.id, emoji: "✅")
        try await bot.deleteAllReactions(channelId: testMessage.channelId, messageId: testMessage.id)
        let updatedMessage = try await bot.getMessage(channelId: testMessage.channelId, messageId: testMessage.id)
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: ReactionMutationResult(
                channelId: testMessage.channelId,
                messageId: testMessage.id,
                emoji: "*",
                action: "delete_all",
                users: nil,
                message: updatedMessage
            ),
            ephemeral: true
        )

    case "edit_channel_permission":
        let role = try await bot.createGuildRole(
            guildId: testGuildId,
            role: CreateGuildRole(name: tempRoleName(prefix: "api-perm-edit"), mentionable: false),
            auditLogReason: "SWDCK setup channel permission edit endpoint test"
        )
        do {
            try await bot.editChannelPermission(
                channelId: testChannelId,
                overwriteId: role.id,
                permission: EditChannelPermission(allow: "1024", deny: "0", type: 0),
                auditLogReason: "SWDCK edit channel permission endpoint test"
            )
        } catch {
            try? await bot.deleteGuildRole(
                guildId: testGuildId,
                roleId: role.id,
                auditLogReason: "SWDCK cleanup role after failed permission edit test"
            )
            throw error
        }
        try? await bot.deleteGuildRole(
            guildId: testGuildId,
            roleId: role.id,
            auditLogReason: "SWDCK cleanup role after permission edit test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: ChannelPermissionMutationResult(
                channelId: testChannelId,
                overwriteId: role.id,
                action: "edit",
                success: true
            ),
            ephemeral: true
        )

    case "delete_channel_permission":
        let role = try await bot.createGuildRole(
            guildId: testGuildId,
            role: CreateGuildRole(name: tempRoleName(prefix: "api-perm-delete"), mentionable: false),
            auditLogReason: "SWDCK setup channel permission delete endpoint test"
        )
        try await bot.editChannelPermission(
            channelId: testChannelId,
            overwriteId: role.id,
            permission: EditChannelPermission(allow: "1024", deny: "0", type: 0),
            auditLogReason: "SWDCK setup overwrite for permission delete endpoint test"
        )
        try await bot.deleteChannelPermission(
            channelId: testChannelId,
            overwriteId: role.id,
            auditLogReason: "SWDCK delete channel permission endpoint test"
        )
        try? await bot.deleteGuildRole(
            guildId: testGuildId,
            roleId: role.id,
            auditLogReason: "SWDCK cleanup role after permission delete test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: ChannelPermissionMutationResult(
                channelId: testChannelId,
                overwriteId: role.id,
                action: "delete",
                success: true
            ),
            ephemeral: true
        )

    case "crosspost_message":
        let announcement = try await bot.createGuildChannel(
            guildId: testGuildId,
            channel: CreateGuildChannel(
                name: tempChannelName(prefix: "api-crosspost"),
                type: ChannelType.guildAnnouncement.rawValue,
                topic: "Crosspost endpoint test channel"
            ),
            auditLogReason: "SWDCK setup announcement channel for crosspost endpoint test"
        )
        do {
            let message = try await bot.sendMessage(
                to: announcement.id,
                content: "Crosspost endpoint test \(Int(Date().timeIntervalSince1970))"
            )
            let crossposted = try await bot.crosspostMessage(channelId: announcement.id, messageId: message.id)
            try await sendDeferredInteractionDump(interaction, title: title, value: crossposted, ephemeral: true)
        } catch {
            _ = try? await bot.deleteChannel(
                channelId: announcement.id,
                auditLogReason: "SWDCK cleanup announcement channel after failed crosspost test"
            )
            throw error
        }
        _ = try? await bot.deleteChannel(
            channelId: announcement.id,
            auditLogReason: "SWDCK cleanup announcement channel after crosspost test"
        )

    case "create_guild_channel":
        let created = try await bot.createGuildChannel(
            guildId: testGuildId,
            channel: CreateGuildChannel(
                name: tempChannelName(prefix: "api-create"),
                type: ChannelType.guildText.rawValue,
                topic: "Create guild channel endpoint test"
            ),
            auditLogReason: "SWDCK create guild channel endpoint test"
        )
        let deleted = try await bot.deleteChannel(
            channelId: created.id,
            auditLogReason: "SWDCK cleanup created guild channel endpoint test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: ChannelLifecycleResult(created: created, modified: nil, deleted: deleted),
            ephemeral: true
        )

    case "modify_channel":
        let created = try await bot.createGuildChannel(
            guildId: testGuildId,
            channel: CreateGuildChannel(
                name: tempChannelName(prefix: "api-modify"),
                type: ChannelType.guildText.rawValue,
                topic: "Before modify"
            ),
            auditLogReason: "SWDCK setup channel for modify endpoint test"
        )
        let modified = try await bot.modifyChannel(
            channelId: created.id,
            modify: ModifyChannel(name: "\(created.name ?? "modified")-updated", topic: "After modify"),
            auditLogReason: "SWDCK modify channel endpoint test"
        )
        let deleted = try await bot.deleteChannel(
            channelId: created.id,
            auditLogReason: "SWDCK cleanup channel after modify endpoint test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: ChannelLifecycleResult(created: created, modified: modified, deleted: deleted),
            ephemeral: true
        )

    case "delete_channel":
        let created = try await bot.createGuildChannel(
            guildId: testGuildId,
            channel: CreateGuildChannel(
                name: tempChannelName(prefix: "api-delete"),
                type: ChannelType.guildText.rawValue,
                topic: "Delete channel endpoint test"
            ),
            auditLogReason: "SWDCK setup channel for delete endpoint test"
        )
        let deleted = try await bot.deleteChannel(
            channelId: created.id,
            auditLogReason: "SWDCK delete channel endpoint test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: ChannelLifecycleResult(created: created, modified: nil, deleted: deleted),
            ephemeral: true
        )

    case "start_thread_without_message":
        let thread = try await bot.startThreadWithoutMessage(
            channelId: testChannelId,
            payload: StartThreadWithoutMessage(
                name: tempThreadName(prefix: "api-thread"),
                autoArchiveDuration: 60,
                type: ChannelType.publicThread.rawValue,
                invitable: false
            ),
            auditLogReason: "SWDCK start thread without message endpoint test"
        )
        let members = try await bot.getThreadMembers(channelId: thread.id, query: ThreadMembersQuery(withMember: true, limit: 100))
        _ = try? await bot.deleteChannel(channelId: thread.id, auditLogReason: "SWDCK cleanup thread without message endpoint test")
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: ThreadLifecycleResult(parentChannelId: testChannelId, thread: thread, archivedSnapshot: nil, members: members),
            ephemeral: true
        )

    case "start_thread_from_message":
        let baseMessage = try await bot.sendMessage(
            to: testChannelId,
            content: "Start thread from message endpoint test \(Int(Date().timeIntervalSince1970))"
        )
        let thread = try await bot.startThreadFromMessage(
            channelId: testChannelId,
            messageId: baseMessage.id,
            payload: StartThreadFromMessage(
                name: tempThreadName(prefix: "api-msg-thread"),
                autoArchiveDuration: 60
            ),
            auditLogReason: "SWDCK start thread from message endpoint test"
        )
        let members = try await bot.getThreadMembers(channelId: thread.id, query: ThreadMembersQuery(withMember: true, limit: 100))
        _ = try? await bot.deleteChannel(channelId: thread.id, auditLogReason: "SWDCK cleanup thread from message endpoint test")
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: ThreadLifecycleResult(parentChannelId: testChannelId, thread: thread, archivedSnapshot: nil, members: members),
            ephemeral: true
        )

    case "get_public_archived_threads":
        let thread = try await bot.startThreadWithoutMessage(
            channelId: testChannelId,
            payload: StartThreadWithoutMessage(
                name: tempThreadName(prefix: "api-arch-pub"),
                autoArchiveDuration: 60,
                type: ChannelType.publicThread.rawValue
            ),
            auditLogReason: "SWDCK setup public archived threads endpoint test"
        )
        _ = try await bot.modifyChannel(
            channelId: thread.id,
            modify: ModifyChannel(archived: true),
            auditLogReason: "SWDCK archive thread for public archived list endpoint test"
        )
        let archive = try await bot.getPublicArchivedThreads(channelId: testChannelId, query: ArchivedThreadsQuery(limit: 50))
        _ = try? await bot.deleteChannel(channelId: thread.id, auditLogReason: "SWDCK cleanup archived public thread endpoint test")
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: archive,
            ephemeral: true
        )

    case "get_private_archived_threads":
        let thread = try await bot.startThreadWithoutMessage(
            channelId: testChannelId,
            payload: StartThreadWithoutMessage(
                name: tempThreadName(prefix: "api-arch-prv"),
                autoArchiveDuration: 60,
                type: ChannelType.privateThread.rawValue,
                invitable: false
            ),
            auditLogReason: "SWDCK setup private archived threads endpoint test"
        )
        _ = try await bot.modifyChannel(
            channelId: thread.id,
            modify: ModifyChannel(archived: true),
            auditLogReason: "SWDCK archive thread for private archived list endpoint test"
        )
        let archive = try await bot.getPrivateArchivedThreads(channelId: testChannelId, query: ArchivedThreadsQuery(limit: 50))
        _ = try? await bot.deleteChannel(channelId: thread.id, auditLogReason: "SWDCK cleanup archived private thread endpoint test")
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: archive,
            ephemeral: true
        )

    case "get_joined_private_archived_threads":
        let thread = try await bot.startThreadWithoutMessage(
            channelId: testChannelId,
            payload: StartThreadWithoutMessage(
                name: tempThreadName(prefix: "api-arch-join"),
                autoArchiveDuration: 60,
                type: ChannelType.privateThread.rawValue,
                invitable: false
            ),
            auditLogReason: "SWDCK setup joined private archived endpoint test"
        )
        _ = try await bot.modifyChannel(
            channelId: thread.id,
            modify: ModifyChannel(archived: true),
            auditLogReason: "SWDCK archive thread for joined private archived endpoint test"
        )
        let archive = try await bot.getJoinedPrivateArchivedThreads(channelId: testChannelId, query: ArchivedThreadsQuery(limit: 50))
        _ = try? await bot.deleteChannel(channelId: thread.id, auditLogReason: "SWDCK cleanup joined private archived thread endpoint test")
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: archive,
            ephemeral: true
        )

    case "get_thread_members":
        let thread = try await bot.startThreadWithoutMessage(
            channelId: testChannelId,
            payload: StartThreadWithoutMessage(
                name: tempThreadName(prefix: "api-members"),
                autoArchiveDuration: 60,
                type: ChannelType.publicThread.rawValue
            ),
            auditLogReason: "SWDCK setup thread members endpoint test"
        )
        let members = try await bot.getThreadMembers(
            channelId: thread.id,
            query: ThreadMembersQuery(withMember: true, limit: 100)
        )
        _ = try? await bot.deleteChannel(channelId: thread.id, auditLogReason: "SWDCK cleanup thread members endpoint test")
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: EndpointCollectionDump(count: members.count, items: members),
            ephemeral: true
        )

    case "get_thread_member":
        let thread = try await bot.startThreadWithoutMessage(
            channelId: testChannelId,
            payload: StartThreadWithoutMessage(
                name: tempThreadName(prefix: "api-member"),
                autoArchiveDuration: 60,
                type: ChannelType.publicThread.rawValue
            ),
            auditLogReason: "SWDCK setup thread member endpoint test"
        )
        guard let botUserId = await bot.currentUser?.id else {
            throw DiscordError.invalidRequest(message: "Bot user ID not available yet.")
        }
        let member = try await bot.getThreadMember(channelId: thread.id, userId: botUserId, withMember: true)
        _ = try? await bot.deleteChannel(channelId: thread.id, auditLogReason: "SWDCK cleanup thread member endpoint test")
        try await sendDeferredInteractionDump(interaction, title: title, value: member, ephemeral: true)

    case "join_thread":
        let thread = try await bot.startThreadWithoutMessage(
            channelId: testChannelId,
            payload: StartThreadWithoutMessage(
                name: tempThreadName(prefix: "api-join"),
                autoArchiveDuration: 60,
                type: ChannelType.publicThread.rawValue
            ),
            auditLogReason: "SWDCK setup join thread endpoint test"
        )
        try await bot.leaveThread(channelId: thread.id)
        try await bot.joinThread(channelId: thread.id)
        let members = try await bot.getThreadMembers(channelId: thread.id, query: ThreadMembersQuery(withMember: true, limit: 100))
        _ = try? await bot.deleteChannel(channelId: thread.id, auditLogReason: "SWDCK cleanup join thread endpoint test")
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: ThreadLifecycleResult(parentChannelId: testChannelId, thread: thread, archivedSnapshot: nil, members: members),
            ephemeral: true
        )

    case "leave_thread":
        let thread = try await bot.startThreadWithoutMessage(
            channelId: testChannelId,
            payload: StartThreadWithoutMessage(
                name: tempThreadName(prefix: "api-leave"),
                autoArchiveDuration: 60,
                type: ChannelType.publicThread.rawValue
            ),
            auditLogReason: "SWDCK setup leave thread endpoint test"
        )
        try await bot.leaveThread(channelId: thread.id)
        let members = try await bot.getThreadMembers(channelId: thread.id, query: ThreadMembersQuery(withMember: true, limit: 100))
        _ = try? await bot.deleteChannel(channelId: thread.id, auditLogReason: "SWDCK cleanup leave thread endpoint test")
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: ThreadLifecycleResult(parentChannelId: testChannelId, thread: thread, archivedSnapshot: nil, members: members),
            ephemeral: true
        )

    case "add_thread_member":
        let thread = try await bot.startThreadWithoutMessage(
            channelId: testChannelId,
            payload: StartThreadWithoutMessage(
                name: tempThreadName(prefix: "api-add-member"),
                autoArchiveDuration: 60,
                type: ChannelType.privateThread.rawValue,
                invitable: true
            ),
            auditLogReason: "SWDCK setup add thread member endpoint test"
        )
        guard let targetUserId = interaction.invoker?.id else {
            throw DiscordError.invalidRequest(message: "Unable to resolve target user for add thread member test.")
        }
        do {
            try await bot.addThreadMember(channelId: thread.id, userId: targetUserId)
            let member = try await bot.getThreadMember(channelId: thread.id, userId: targetUserId, withMember: true)
            try await sendDeferredInteractionDump(interaction, title: title, value: member, ephemeral: true)
        } catch {
            _ = try? await bot.deleteChannel(
                channelId: thread.id,
                auditLogReason: "SWDCK cleanup thread after failed add thread member endpoint test"
            )
            throw error
        }
        _ = try? await bot.deleteChannel(
            channelId: thread.id,
            auditLogReason: "SWDCK cleanup thread after add thread member endpoint test"
        )

    case "get_active_guild_threads":
        let active = try await bot.getActiveGuildThreads(guildId: testGuildId)
        try await sendDeferredInteractionDump(interaction, title: title, value: active, ephemeral: true)

    case "create_webhook":
        let webhook = try await bot.createWebhook(
            channelId: testChannelId,
            webhook: CreateWebhook(name: tempWebhookName(prefix: "api-create")),
            auditLogReason: "SWDCK create webhook endpoint test"
        )
        try? await bot.deleteWebhook(
            webhookId: webhook.id,
            auditLogReason: "SWDCK cleanup create webhook endpoint test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: WebhookLifecycleResult(
                created: webhook,
                fetched: nil,
                modified: nil,
                channelWebhooksCount: nil,
                guildWebhooksCount: nil,
                deleted: true
            ),
            ephemeral: true
        )

    case "get_channel_webhooks":
        let webhook = try await bot.createWebhook(
            channelId: testChannelId,
            webhook: CreateWebhook(name: tempWebhookName(prefix: "api-list-channel")),
            auditLogReason: "SWDCK setup channel webhooks endpoint test"
        )
        let webhooks = try await bot.getChannelWebhooks(testChannelId)
        try? await bot.deleteWebhook(
            webhookId: webhook.id,
            auditLogReason: "SWDCK cleanup channel webhooks endpoint test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: EndpointCollectionDump(count: webhooks.count, items: webhooks),
            ephemeral: true
        )

    case "get_guild_webhooks":
        let webhook = try await bot.createWebhook(
            channelId: testChannelId,
            webhook: CreateWebhook(name: tempWebhookName(prefix: "api-list-guild")),
            auditLogReason: "SWDCK setup guild webhooks endpoint test"
        )
        let webhooks = try await bot.getGuildWebhooks(testGuildId)
        try? await bot.deleteWebhook(
            webhookId: webhook.id,
            auditLogReason: "SWDCK cleanup guild webhooks endpoint test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: EndpointCollectionDump(count: webhooks.count, items: webhooks),
            ephemeral: true
        )

    case "get_webhook":
        let webhook = try await bot.createWebhook(
            channelId: testChannelId,
            webhook: CreateWebhook(name: tempWebhookName(prefix: "api-get")),
            auditLogReason: "SWDCK setup get webhook endpoint test"
        )
        let fetched = try await bot.getWebhook(webhook.id)
        try? await bot.deleteWebhook(
            webhookId: webhook.id,
            auditLogReason: "SWDCK cleanup get webhook endpoint test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: WebhookLifecycleResult(
                created: webhook,
                fetched: fetched,
                modified: nil,
                channelWebhooksCount: nil,
                guildWebhooksCount: nil,
                deleted: true
            ),
            ephemeral: true
        )

    case "get_webhook_token":
        let webhook = try await bot.createWebhook(
            channelId: testChannelId,
            webhook: CreateWebhook(name: tempWebhookName(prefix: "api-get-token")),
            auditLogReason: "SWDCK setup get webhook token endpoint test"
        )
        guard let token = webhook.token else {
            throw DiscordError.invalidRequest(message: "Webhook token missing in create webhook response.")
        }
        let fetched = try await bot.getWebhook(webhook.id, token: token)
        try? await bot.deleteWebhook(
            webhookId: webhook.id,
            auditLogReason: "SWDCK cleanup get webhook token endpoint test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: WebhookLifecycleResult(
                created: webhook,
                fetched: fetched,
                modified: nil,
                channelWebhooksCount: nil,
                guildWebhooksCount: nil,
                deleted: true
            ),
            ephemeral: true
        )

    case "modify_webhook":
        let webhook = try await bot.createWebhook(
            channelId: testChannelId,
            webhook: CreateWebhook(name: tempWebhookName(prefix: "api-modify")),
            auditLogReason: "SWDCK setup modify webhook endpoint test"
        )
        let modified = try await bot.modifyWebhook(
            webhookId: webhook.id,
            modify: ModifyWebhook(name: "\(webhook.name ?? "webhook")-updated"),
            auditLogReason: "SWDCK modify webhook endpoint test"
        )
        try? await bot.deleteWebhook(
            webhookId: webhook.id,
            auditLogReason: "SWDCK cleanup modify webhook endpoint test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: WebhookLifecycleResult(
                created: webhook,
                fetched: nil,
                modified: modified,
                channelWebhooksCount: nil,
                guildWebhooksCount: nil,
                deleted: true
            ),
            ephemeral: true
        )

    case "modify_webhook_token":
        let webhook = try await bot.createWebhook(
            channelId: testChannelId,
            webhook: CreateWebhook(name: tempWebhookName(prefix: "api-modify-token")),
            auditLogReason: "SWDCK setup modify webhook token endpoint test"
        )
        guard let token = webhook.token else {
            throw DiscordError.invalidRequest(message: "Webhook token missing in create webhook response.")
        }
        let modified = try await bot.modifyWebhook(
            webhookId: webhook.id,
            token: token,
            modify: ModifyWebhook(name: "\(webhook.name ?? "webhook")-token-updated")
        )
        try? await bot.deleteWebhook(
            webhookId: webhook.id,
            auditLogReason: "SWDCK cleanup modify webhook token endpoint test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: WebhookLifecycleResult(
                created: webhook,
                fetched: nil,
                modified: modified,
                channelWebhooksCount: nil,
                guildWebhooksCount: nil,
                deleted: true
            ),
            ephemeral: true
        )

    case "delete_webhook":
        let webhook = try await bot.createWebhook(
            channelId: testChannelId,
            webhook: CreateWebhook(name: tempWebhookName(prefix: "api-delete")),
            auditLogReason: "SWDCK setup delete webhook endpoint test"
        )
        try await bot.deleteWebhook(
            webhookId: webhook.id,
            auditLogReason: "SWDCK delete webhook endpoint test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: WebhookLifecycleResult(
                created: webhook,
                fetched: nil,
                modified: nil,
                channelWebhooksCount: nil,
                guildWebhooksCount: nil,
                deleted: true
            ),
            ephemeral: true
        )

    case "delete_webhook_token":
        let webhook = try await bot.createWebhook(
            channelId: testChannelId,
            webhook: CreateWebhook(name: tempWebhookName(prefix: "api-delete-token")),
            auditLogReason: "SWDCK setup delete webhook token endpoint test"
        )
        guard let token = webhook.token else {
            throw DiscordError.invalidRequest(message: "Webhook token missing in create webhook response.")
        }
        try await bot.deleteWebhook(webhookId: webhook.id, token: token)
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: WebhookLifecycleResult(
                created: webhook,
                fetched: nil,
                modified: nil,
                channelWebhooksCount: nil,
                guildWebhooksCount: nil,
                deleted: true
            ),
            ephemeral: true
        )

    case "execute_webhook":
        let webhook = try await bot.createWebhook(
            channelId: testChannelId,
            webhook: CreateWebhook(name: tempWebhookName(prefix: "api-exec")),
            auditLogReason: "SWDCK setup execute webhook endpoint test"
        )
        guard let token = webhook.token else {
            throw DiscordError.invalidRequest(message: "Webhook token missing in create webhook response.")
        }
        let executed = try await bot.executeWebhook(
            webhookId: webhook.id,
            token: token,
            execute: ExecuteWebhook(content: "Execute webhook endpoint test"),
            query: ExecuteWebhookQuery(wait: true)
        )
        guard let message = executed else {
            throw DiscordError.invalidRequest(message: "Webhook execute with wait=true returned no message.")
        }
        try? await bot.deleteWebhookMessage(webhookId: webhook.id, token: token, messageId: message.id)
        try? await bot.deleteWebhook(webhookId: webhook.id, auditLogReason: "SWDCK cleanup execute webhook endpoint test")
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: WebhookMessageLifecycleResult(
                webhookId: webhook.id,
                message: message,
                fetched: nil,
                edited: nil,
                deleted: true
            ),
            ephemeral: true
        )

    case "get_webhook_message":
        let webhook = try await bot.createWebhook(
            channelId: testChannelId,
            webhook: CreateWebhook(name: tempWebhookName(prefix: "api-get-msg")),
            auditLogReason: "SWDCK setup get webhook message endpoint test"
        )
        guard let token = webhook.token else {
            throw DiscordError.invalidRequest(message: "Webhook token missing in create webhook response.")
        }
        guard let message = try await bot.executeWebhook(
            webhookId: webhook.id,
            token: token,
            execute: ExecuteWebhook(content: "Get webhook message endpoint test"),
            query: ExecuteWebhookQuery(wait: true)
        ) else {
            throw DiscordError.invalidRequest(message: "Webhook execute with wait=true returned no message.")
        }
        let fetched = try await bot.getWebhookMessage(
            webhookId: webhook.id,
            token: token,
            messageId: message.id
        )
        try? await bot.deleteWebhookMessage(webhookId: webhook.id, token: token, messageId: message.id)
        try? await bot.deleteWebhook(webhookId: webhook.id, auditLogReason: "SWDCK cleanup get webhook message endpoint test")
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: WebhookMessageLifecycleResult(
                webhookId: webhook.id,
                message: message,
                fetched: fetched,
                edited: nil,
                deleted: true
            ),
            ephemeral: true
        )

    case "edit_webhook_message":
        let webhook = try await bot.createWebhook(
            channelId: testChannelId,
            webhook: CreateWebhook(name: tempWebhookName(prefix: "api-edit-msg")),
            auditLogReason: "SWDCK setup edit webhook message endpoint test"
        )
        guard let token = webhook.token else {
            throw DiscordError.invalidRequest(message: "Webhook token missing in create webhook response.")
        }
        guard let message = try await bot.executeWebhook(
            webhookId: webhook.id,
            token: token,
            execute: ExecuteWebhook(content: "Edit webhook message endpoint test"),
            query: ExecuteWebhookQuery(wait: true)
        ) else {
            throw DiscordError.invalidRequest(message: "Webhook execute with wait=true returned no message.")
        }
        let edited = try await bot.editWebhookMessage(
            webhookId: webhook.id,
            token: token,
            messageId: message.id,
            edit: EditWebhookMessage(content: "Edited webhook message endpoint test")
        )
        try? await bot.deleteWebhookMessage(webhookId: webhook.id, token: token, messageId: message.id)
        try? await bot.deleteWebhook(webhookId: webhook.id, auditLogReason: "SWDCK cleanup edit webhook message endpoint test")
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: WebhookMessageLifecycleResult(
                webhookId: webhook.id,
                message: message,
                fetched: nil,
                edited: edited,
                deleted: true
            ),
            ephemeral: true
        )

    case "delete_webhook_message":
        let webhook = try await bot.createWebhook(
            channelId: testChannelId,
            webhook: CreateWebhook(name: tempWebhookName(prefix: "api-del-msg")),
            auditLogReason: "SWDCK setup delete webhook message endpoint test"
        )
        guard let token = webhook.token else {
            throw DiscordError.invalidRequest(message: "Webhook token missing in create webhook response.")
        }
        guard let message = try await bot.executeWebhook(
            webhookId: webhook.id,
            token: token,
            execute: ExecuteWebhook(content: "Delete webhook message endpoint test"),
            query: ExecuteWebhookQuery(wait: true)
        ) else {
            throw DiscordError.invalidRequest(message: "Webhook execute with wait=true returned no message.")
        }
        try await bot.deleteWebhookMessage(webhookId: webhook.id, token: token, messageId: message.id)
        try? await bot.deleteWebhook(webhookId: webhook.id, auditLogReason: "SWDCK cleanup delete webhook message endpoint test")
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: WebhookMessageLifecycleResult(
                webhookId: webhook.id,
                message: message,
                fetched: nil,
                edited: nil,
                deleted: true
            ),
            ephemeral: true
        )

    case "create_guild_role":
        let created = try await bot.createGuildRole(
            guildId: testGuildId,
            role: CreateGuildRole(name: tempRoleName(prefix: "api-create-role"), mentionable: true),
            auditLogReason: "SWDCK create guild role endpoint test"
        )
        try? await bot.deleteGuildRole(
            guildId: testGuildId,
            roleId: created.id,
            auditLogReason: "SWDCK cleanup create guild role endpoint test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: GuildRoleLifecycleResult(created: created, fetched: nil, modified: nil, deleted: true),
            ephemeral: true
        )

    case "get_guild_role":
        let created = try await bot.createGuildRole(
            guildId: testGuildId,
            role: CreateGuildRole(name: tempRoleName(prefix: "api-get-role"), mentionable: false),
            auditLogReason: "SWDCK setup get guild role endpoint test"
        )
        let fetched = try await bot.getGuildRole(guildId: testGuildId, roleId: created.id)
        try? await bot.deleteGuildRole(
            guildId: testGuildId,
            roleId: created.id,
            auditLogReason: "SWDCK cleanup get guild role endpoint test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: GuildRoleLifecycleResult(created: created, fetched: fetched, modified: nil, deleted: true),
            ephemeral: true
        )

    case "modify_guild_role":
        let created = try await bot.createGuildRole(
            guildId: testGuildId,
            role: CreateGuildRole(name: tempRoleName(prefix: "api-mod-role"), mentionable: false),
            auditLogReason: "SWDCK setup modify guild role endpoint test"
        )
        let modified = try await bot.modifyGuildRole(
            guildId: testGuildId,
            roleId: created.id,
            modify: ModifyGuildRole(name: "\(created.name)-updated", mentionable: true),
            auditLogReason: "SWDCK modify guild role endpoint test"
        )
        try? await bot.deleteGuildRole(
            guildId: testGuildId,
            roleId: created.id,
            auditLogReason: "SWDCK cleanup modify guild role endpoint test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: GuildRoleLifecycleResult(created: created, fetched: nil, modified: modified, deleted: true),
            ephemeral: true
        )

    case "delete_guild_role":
        let created = try await bot.createGuildRole(
            guildId: testGuildId,
            role: CreateGuildRole(name: tempRoleName(prefix: "api-del-role"), mentionable: false),
            auditLogReason: "SWDCK setup delete guild role endpoint test"
        )
        try await bot.deleteGuildRole(
            guildId: testGuildId,
            roleId: created.id,
            auditLogReason: "SWDCK delete guild role endpoint test"
        )
        try await sendDeferredInteractionDump(
            interaction,
            title: title,
            value: GuildRoleLifecycleResult(created: created, fetched: nil, modified: nil, deleted: true),
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

private func tempChannelName(prefix: String) -> String {
    let timestamp = Int(Date().timeIntervalSince1970)
    return "\(prefix)-\(timestamp)"
}

private func tempThreadName(prefix: String) -> String {
    let timestamp = Int(Date().timeIntervalSince1970)
    return "\(prefix)-\(timestamp)"
}

private func tempWebhookName(prefix: String) -> String {
    let timestamp = Int(Date().timeIntervalSince1970)
    return "\(prefix)-\(timestamp)"
}

private func tempRoleName(prefix: String) -> String {
    let timestamp = Int(Date().timeIntervalSince1970)
    return "\(prefix)-\(timestamp)"
}

private func componentV2DemoData() -> (components: [ComponentV2Node], attachments: [DiscordFileUpload]) {
    let attachmentName = "component-v2-demo.txt"
    let attachmentData = Data("SWDCK Components V2 file component demo.".utf8)

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
                    .textDisplay(ComponentV2TextDisplay("SWDCK Components V2 demo")),
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
