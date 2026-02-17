import Foundation

public final class RESTClient: Sendable {

    private let token: String
    private let session: URLSession
    private let rateLimiter: RateLimiter
    private let maxRetries = 3

    init(token: String) {
        self.token = token
        self.rateLimiter = RateLimiter()
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "User-Agent": "DiscordBot (DiscordKit, 1.0.0)"
        ]
        self.session = URLSession(configuration: config)
    }


    @discardableResult
    func request<T: Decodable>(
        method: String,
        url: String,
        body: Encodable? = nil,
        headers: [String: String] = [:],
        decodeAs type: T.Type
    ) async throws -> T {
        let data = try await rawRequest(method: method, url: url, body: body, headers: headers)
        return try JSONCoder.decode(type, from: data)
    }

    func requestVoid(
        method: String,
        url: String,
        body: Encodable? = nil,
        headers: [String: String] = [:]
    ) async throws {
        _ = try await rawRequest(method: method, url: url, body: body, headers: headers)
    }

    private func rawRequest(
        method: String,
        url urlString: String,
        body: Encodable?,
        headers: [String: String]
    ) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw DiscordError.connectionFailed(reason: "Invalid URL: \(urlString)")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bot \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let body {
            request.httpBody = try JSONCoder.encode(body)
        }

        let routeKey = "\(method):\(url.path)"

        for attempt in 1...maxRetries {
            if attempt > 1 {
                logger.warning("Retrying \(method) \(url.path) (attempt \(attempt)/\(maxRetries))")
            }
            await rateLimiter.waitIfNeeded(for: routeKey)

            let (data, response): (Data, URLResponse)
            do {
                (data, response) = try await session.data(for: request)
            } catch {
                if attempt < maxRetries {
                    try? await Task.sleep(nanoseconds: UInt64(attempt) * 1_000_000_000)
                    continue
                }
                throw DiscordError.connectionFailed(reason: error.localizedDescription)
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                throw DiscordError.connectionFailed(reason: "Non-HTTP response")
            }

            await rateLimiter.update(route: routeKey, headers: httpResponse.allHeaderFields)

            switch httpResponse.statusCode {
            case 200...299:
                logger.debug("✓ \(method) \(url.path) → \(httpResponse.statusCode)")
                return data

            case 401:
                throw DiscordError.invalidToken

            case 403:
                throw DiscordError.missingPermissions(endpoint: url.path)

            case 404:
                throw DiscordError.resourceNotFound(endpoint: url.path)

            case 429:
                let retryResponse = try? JSONCoder.decode(RateLimitResponse.self, from: data)
                let retryAfter = retryResponse?.retryAfter
                    ?? headerDouble("Retry-After", from: httpResponse.allHeaderFields)
                    ?? 1.0
                let isGlobal = retryResponse?.global
                    ?? headerBool("X-RateLimit-Global", from: httpResponse.allHeaderFields)
                    ?? false

                logger.warning("Rate limited on \(method) \(url.path). Retry after \(retryAfter)s. Global=\(isGlobal)")

                if isGlobal {
                    await rateLimiter.handleGlobalRateLimit(retryAfter: retryAfter)
                } else {
                    try? await Task.sleep(nanoseconds: UInt64(retryAfter * 1_000_000_000))
                }

                if attempt < maxRetries { continue }
                throw DiscordError.rateLimited(retryAfter: retryAfter)

            case 400:
                let bodyStr = String(data: data, encoding: .utf8) ?? "<binary>"
                logger.error("HTTP 400 for \(method) \(url.path): \(bodyStr)")
                throw DiscordError.invalidRequest(message: apiErrorMessage(from: data) ?? bodyStr)

            case 422:
                let bodyStr = String(data: data, encoding: .utf8) ?? "<binary>"
                logger.error("HTTP 422 for \(method) \(url.path): \(bodyStr)")
                throw DiscordError.validationFailed(message: apiErrorMessage(from: data) ?? bodyStr)

            case 401...499:
                let bodyStr = String(data: data, encoding: .utf8) ?? "<binary>"
                logger.error("HTTP \(httpResponse.statusCode) for \(method) \(url.path): \(bodyStr)")
                throw DiscordError.httpError(statusCode: httpResponse.statusCode, body: bodyStr)

            case 500...599:
                logger.warning("Server error \(httpResponse.statusCode) on \(method) \(url.path), attempt \(attempt)/\(maxRetries)")
                if attempt < maxRetries {
                    try? await Task.sleep(nanoseconds: 1_000_000_000 * UInt64(attempt))
                    continue
                }
                let bodyStr = String(data: data, encoding: .utf8) ?? "<binary>"
                throw DiscordError.httpError(statusCode: httpResponse.statusCode, body: bodyStr)

            default:
                let bodyStr = String(data: data, encoding: .utf8) ?? "<binary>"
                throw DiscordError.httpError(statusCode: httpResponse.statusCode, body: bodyStr)
            }
        }

        throw DiscordError.connectionFailed(reason: "Max retries exceeded for \(method) \(urlString)")
    }


    func getCurrentUser() async throws -> DiscordUser {
        try await request(method: "GET", url: Routes.currentUser, decodeAs: DiscordUser.self)
    }

    func getGatewayBot() async throws -> GatewayBot {
        try await request(method: "GET", url: Routes.gatewayBot, decodeAs: GatewayBot.self)
    }

    func getUser(userId: String) async throws -> DiscordUser {
        try await request(method: "GET", url: Routes.user(userId), decodeAs: DiscordUser.self)
    }


    func getChannel(channelId: String) async throws -> Channel {
        try await request(method: "GET", url: Routes.channel(channelId), decodeAs: Channel.self)
    }

    func getGuild(guildId: String) async throws -> Guild {
        try await request(method: "GET", url: Routes.guild(guildId), decodeAs: Guild.self)
    }

    func getGuildChannels(guildId: String) async throws -> [Channel] {
        try await request(method: "GET", url: Routes.guildChannels(guildId), decodeAs: [Channel].self)
    }

    func getGuildMembers(guildId: String, query: GuildMembersQuery = GuildMembersQuery()) async throws -> [GuildMember] {
        let url = buildGuildMembersURL(guildId: guildId, query: query)
        return try await request(method: "GET", url: url, decodeAs: [GuildMember].self)
    }

    func searchGuildMembers(guildId: String, query: GuildMemberSearchQuery) async throws -> [GuildMember] {
        let url = buildGuildMemberSearchURL(guildId: guildId, query: query)
        return try await request(method: "GET", url: url, decodeAs: [GuildMember].self)
    }

    func getGuildMember(guildId: String, userId: String) async throws -> GuildMember {
        try await request(method: "GET", url: Routes.guildMember(guildId, userId: userId), decodeAs: GuildMember.self)
    }

    func modifyGuildMember(
        guildId: String,
        userId: String,
        modify: ModifyGuildMember,
        auditLogReason: String? = nil
    ) async throws -> GuildMember {
        try await request(
            method: "PATCH",
            url: Routes.guildMember(guildId, userId: userId),
            body: modify,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: GuildMember.self
        )
    }

    func addGuildMemberRole(
        guildId: String,
        userId: String,
        roleId: String,
        auditLogReason: String? = nil
    ) async throws {
        try await requestVoid(
            method: "PUT",
            url: Routes.guildMemberRole(guildId, userId: userId, roleId: roleId),
            headers: auditLogHeaders(reason: auditLogReason)
        )
    }

    func removeGuildMemberRole(
        guildId: String,
        userId: String,
        roleId: String,
        auditLogReason: String? = nil
    ) async throws {
        try await requestVoid(
            method: "DELETE",
            url: Routes.guildMemberRole(guildId, userId: userId, roleId: roleId),
            headers: auditLogHeaders(reason: auditLogReason)
        )
    }

    func getGuildRoles(guildId: String) async throws -> [GuildRole] {
        try await request(method: "GET", url: Routes.guildRoles(guildId), decodeAs: [GuildRole].self)
    }

    func getMessage(channelId: String, messageId: String) async throws -> Message {
        var message = try await request(
            method: "GET",
            url: Routes.message(channelId, messageId: messageId),
            decodeAs: Message.self
        )
        message._rest = self
        return message
    }

    func getMessages(channelId: String, query: MessageHistoryQuery = MessageHistoryQuery()) async throws -> [Message] {
        let url = buildMessageHistoryURL(channelId: channelId, query: query)
        var messages = try await request(method: "GET", url: url, decodeAs: [Message].self)
        for index in messages.indices {
            messages[index]._rest = self
        }
        return messages
    }


    @discardableResult
    func sendMessage(
        channelId: String,
        content: String,
        messageReference: MessageReference? = nil
    ) async throws -> Message {
        let body = SendMessageBody(content: content, messageReference: messageReference)
        var msg = try await request(method: "POST", url: Routes.messages(channelId), body: body, decodeAs: Message.self)
        msg._rest = self
        return msg
    }

    @discardableResult
    func editMessage(channelId: String, messageId: String, content: String) async throws -> Message {
        let body = EditMessageBody(content: content)
        var message = try await request(
            method: "PATCH",
            url: Routes.message(channelId, messageId: messageId),
            body: body,
            decodeAs: Message.self
        )
        message._rest = self
        return message
    }

    func bulkDeleteMessages(channelId: String, messageIds: [String]) async throws {
        guard !messageIds.isEmpty else { return }
        let body = BulkDeleteMessagesBody(messages: messageIds)
        try await requestVoid(method: "POST", url: Routes.bulkDeleteMessages(channelId), body: body)
    }

    @discardableResult
    func sendComponentsV2Message(
        channelId: String,
        components: [ComponentV2Node],
        messageReference: MessageReference? = nil
    ) async throws -> Message {
        let body = SendComponentsV2MessageBody(
            flags: DiscordMessageFlags.isComponentsV2,
            components: components,
            messageReference: messageReference,
            attachments: nil
        )
        var msg = try await request(
            method: "POST",
            url: Routes.messages(channelId),
            body: body,
            decodeAs: Message.self
        )
        msg._rest = self
        return msg
    }

    @discardableResult
    func sendComponentsV2Message(
        channelId: String,
        components: [ComponentV2Node],
        attachments: [DiscordFileUpload],
        messageReference: MessageReference? = nil
    ) async throws -> Message {
        guard let url = URL(string: Routes.messages(channelId)) else {
            throw DiscordError.connectionFailed(reason: "Invalid URL: \(Routes.messages(channelId))")
        }

        let attachmentMetadata = attachments.enumerated().map { index, file in
            UploadAttachmentMetadata(id: index, filename: file.filename, description: file.description)
        }

        let payload = SendComponentsV2MessageBody(
            flags: DiscordMessageFlags.isComponentsV2,
            components: components,
            messageReference: messageReference,
            attachments: attachmentMetadata
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bot \(token)", forHTTPHeaderField: "Authorization")

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = try buildMultipartBody(
            boundary: boundary,
            payload: payload,
            attachments: attachments
        )

        let routeKey = "POST:\(url.path)"

        for attempt in 1...maxRetries {
            await rateLimiter.waitIfNeeded(for: routeKey)

            let (data, response): (Data, URLResponse)
            do {
                (data, response) = try await session.data(for: request)
            } catch {
                if attempt < maxRetries {
                    try? await Task.sleep(nanoseconds: UInt64(attempt) * 1_000_000_000)
                    continue
                }
                throw DiscordError.connectionFailed(reason: error.localizedDescription)
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                throw DiscordError.connectionFailed(reason: "Non-HTTP response")
            }

            await rateLimiter.update(route: routeKey, headers: httpResponse.allHeaderFields)

            switch httpResponse.statusCode {
            case 200...299:
                var message = try JSONCoder.decode(Message.self, from: data)
                message._rest = self
                return message
            case 401:
                throw DiscordError.invalidToken
            case 429:
                let retryAfter = headerDouble("Retry-After", from: httpResponse.allHeaderFields) ?? 1.0
                try? await Task.sleep(nanoseconds: UInt64(retryAfter * 1_000_000_000))
                if attempt < maxRetries { continue }
                throw DiscordError.rateLimited(retryAfter: retryAfter)
            default:
                let body = String(data: data, encoding: .utf8) ?? "<binary>"
                throw DiscordError.httpError(statusCode: httpResponse.statusCode, body: body)
            }
        }

        throw DiscordError.connectionFailed(reason: "Max retries exceeded for multipart request")
    }

    func deleteMessage(channelId: String, messageId: String) async throws {
        try await requestVoid(method: "DELETE", url: Routes.message(channelId, messageId: messageId))
    }


    func getApplicationId() async throws -> String {
        let user = try await getCurrentUser()
        return user.id
    }

    @discardableResult
    func createGlobalCommand(
        applicationId: String,
        command: SlashCommandDefinition
    ) async throws -> ApplicationCommand {
        try await request(
            method: "POST",
            url: Routes.globalCommands(applicationId),
            body: command,
            decodeAs: ApplicationCommand.self
        )
    }

    func bulkOverwriteGlobalCommands(
        applicationId: String,
        commands: [SlashCommandDefinition]
    ) async throws -> [ApplicationCommand] {
        try await request(
            method: "PUT",
            url: Routes.globalCommands(applicationId),
            body: commands,
            decodeAs: [ApplicationCommand].self
        )
    }

    func createGuildCommand(
        applicationId: String,
        guildId: String,
        command: SlashCommandDefinition
    ) async throws -> ApplicationCommand {
        try await request(
            method: "POST",
            url: Routes.guildCommands(applicationId, guildId: guildId),
            body: command,
            decodeAs: ApplicationCommand.self
        )
    }

    func bulkOverwriteGuildCommands(
        applicationId: String,
        guildId: String,
        commands: [SlashCommandDefinition]
    ) async throws -> [ApplicationCommand] {
        try await request(
            method: "PUT",
            url: Routes.guildCommands(applicationId, guildId: guildId),
            body: commands,
            decodeAs: [ApplicationCommand].self
        )
    }

    func getGlobalCommands(applicationId: String) async throws -> [ApplicationCommand] {
        try await request(
            method: "GET",
            url: Routes.globalCommands(applicationId),
            decodeAs: [ApplicationCommand].self
        )
    }

    func getGuildCommands(applicationId: String, guildId: String) async throws -> [ApplicationCommand] {
        try await request(
            method: "GET",
            url: Routes.guildCommands(applicationId, guildId: guildId),
            decodeAs: [ApplicationCommand].self
        )
    }

    func editGlobalCommand(
        applicationId: String,
        commandId: String,
        command: EditApplicationCommand
    ) async throws -> ApplicationCommand {
        try await request(
            method: "PATCH",
            url: Routes.globalCommand(applicationId, commandId: commandId),
            body: command,
            decodeAs: ApplicationCommand.self
        )
    }

    func editGuildCommand(
        applicationId: String,
        guildId: String,
        commandId: String,
        command: EditApplicationCommand
    ) async throws -> ApplicationCommand {
        try await request(
            method: "PATCH",
            url: Routes.guildCommand(applicationId, guildId: guildId, commandId: commandId),
            body: command,
            decodeAs: ApplicationCommand.self
        )
    }

    func deleteGlobalCommand(applicationId: String, commandId: String) async throws {
        try await requestVoid(
            method: "DELETE",
            url: Routes.globalCommand(applicationId, commandId: commandId)
        )
    }

    func deleteGuildCommand(applicationId: String, guildId: String, commandId: String) async throws {
        try await requestVoid(
            method: "DELETE",
            url: Routes.guildCommand(applicationId, guildId: guildId, commandId: commandId)
        )
    }

    @discardableResult
    func createSlashCommand(
        applicationId: String,
        command: SlashCommandDefinition,
        guildId: String? = nil
    ) async throws -> ApplicationCommand {
        if let guildId {
            return try await createGuildCommand(
                applicationId: applicationId,
                guildId: guildId,
                command: command
            )
        }
        return try await createGlobalCommand(
            applicationId: applicationId,
            command: command
        )
    }


    func createInteractionResponse(
        interactionId: String,
        token: String,
        response: InteractionResponse
    ) async throws {
        try await requestVoid(
            method: "POST",
            url: Routes.interactionResponse(interactionId, token: token),
            body: response
        )
    }

    @discardableResult
    func editInteractionResponse(
        applicationId: String,
        token: String,
        content: String
    ) async throws -> Message {
        let body = EditInteractionBody(content: content)
        var msg = try await request(
            method: "PATCH",
            url: Routes.originalInteractionResponse(applicationId, token: token),
            body: body,
            decodeAs: Message.self
        )
        msg._rest = self
        return msg
    }

    @discardableResult
    func getOriginalInteractionResponse(
        applicationId: String,
        token: String
    ) async throws -> Message {
        var message = try await request(
            method: "GET",
            url: Routes.originalInteractionResponse(applicationId, token: token),
            decodeAs: Message.self
        )
        message._rest = self
        return message
    }

    func deleteOriginalInteractionResponse(
        applicationId: String,
        token: String
    ) async throws {
        try await requestVoid(
            method: "DELETE",
            url: Routes.originalInteractionResponse(applicationId, token: token)
        )
    }

    @discardableResult
    func createFollowup(
        applicationId: String,
        token: String,
        content: String,
        ephemeral: Bool = false
    ) async throws -> Message {
        let body = FollowupBody(content: content, flags: ephemeral ? 64 : nil)
        var msg = try await request(
            method: "POST",
            url: Routes.followupMessage(applicationId, token: token),
            body: body,
            decodeAs: Message.self
        )
        msg._rest = self
        return msg
    }

    @discardableResult
    func getFollowupMessage(
        applicationId: String,
        token: String,
        messageId: String
    ) async throws -> Message {
        var msg = try await request(
            method: "GET",
            url: Routes.followupMessage(applicationId, token: token, messageId: messageId),
            decodeAs: Message.self
        )
        msg._rest = self
        return msg
    }

    @discardableResult
    func editFollowupMessage(
        applicationId: String,
        token: String,
        messageId: String,
        content: String
    ) async throws -> Message {
        let body = EditMessageBody(content: content)
        var msg = try await request(
            method: "PATCH",
            url: Routes.followupMessage(applicationId, token: token, messageId: messageId),
            body: body,
            decodeAs: Message.self
        )
        msg._rest = self
        return msg
    }

    func deleteFollowupMessage(
        applicationId: String,
        token: String,
        messageId: String
    ) async throws {
        try await requestVoid(
            method: "DELETE",
            url: Routes.followupMessage(applicationId, token: token, messageId: messageId)
        )
    }
}

private extension RESTClient {
    func buildGuildMembersURL(guildId: String, query: GuildMembersQuery) -> String {
        guard var components = URLComponents(string: Routes.guildMembers(guildId)) else {
            return Routes.guildMembers(guildId)
        }

        var items: [URLQueryItem] = []
        if let limit = query.limit { items.append(URLQueryItem(name: "limit", value: String(limit))) }
        if let after = query.after { items.append(URLQueryItem(name: "after", value: after)) }

        components.queryItems = items.isEmpty ? nil : items
        return components.url?.absoluteString ?? Routes.guildMembers(guildId)
    }

    func buildGuildMemberSearchURL(guildId: String, query: GuildMemberSearchQuery) -> String {
        guard var components = URLComponents(string: Routes.guildMembersSearch(guildId)) else {
            return Routes.guildMembersSearch(guildId)
        }

        var items: [URLQueryItem] = [URLQueryItem(name: "query", value: query.query)]
        if let limit = query.limit { items.append(URLQueryItem(name: "limit", value: String(limit))) }

        components.queryItems = items
        return components.url?.absoluteString ?? Routes.guildMembersSearch(guildId)
    }

    func buildMessageHistoryURL(channelId: String, query: MessageHistoryQuery) -> String {
        guard var components = URLComponents(string: Routes.messages(channelId)) else {
            return Routes.messages(channelId)
        }

        var items: [URLQueryItem] = []
        if let around = query.around { items.append(URLQueryItem(name: "around", value: around)) }
        if let before = query.before { items.append(URLQueryItem(name: "before", value: before)) }
        if let after = query.after { items.append(URLQueryItem(name: "after", value: after)) }
        if let limit = query.limit { items.append(URLQueryItem(name: "limit", value: String(limit))) }

        components.queryItems = items.isEmpty ? nil : items
        return components.url?.absoluteString ?? Routes.messages(channelId)
    }

    func headerValue(_ name: String, from headers: [AnyHashable: Any]) -> String? {
        let lowercasedName = name.lowercased()
        for (key, value) in headers where String(describing: key).lowercased() == lowercasedName {
            return String(describing: value)
        }
        return nil
    }

    func apiErrorMessage(from data: Data) -> String? {
        let payload = try? JSONCoder.decode(DiscordAPIErrorPayload.self, from: data)
        return payload?.message
    }

    func headerDouble(_ name: String, from headers: [AnyHashable: Any]) -> Double? {
        guard let raw = headerValue(name, from: headers) else { return nil }
        return Double(raw)
    }

    func headerBool(_ name: String, from headers: [AnyHashable: Any]) -> Bool? {
        guard let raw = headerValue(name, from: headers)?.lowercased() else { return nil }
        switch raw {
        case "1", "true":
            return true
        case "0", "false":
            return false
        default:
            return nil
        }
    }

    func auditLogHeaders(reason: String?) -> [String: String] {
        guard let reason, !reason.isEmpty else { return [:] }
        let encoded = reason.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? reason
        return ["X-Audit-Log-Reason": encoded]
    }

    func buildMultipartBody(
        boundary: String,
        payload: SendComponentsV2MessageBody,
        attachments: [DiscordFileUpload]
    ) throws -> Data {
        var body = Data()
        let lineBreak = "\r\n"

        func append(_ string: String) {
            body.append(Data(string.utf8))
        }

        append("--\(boundary)\(lineBreak)")
        append("Content-Disposition: form-data; name=\"payload_json\"\(lineBreak)")
        append("Content-Type: application/json\(lineBreak)\(lineBreak)")
        let payloadData = try JSONCoder.encode(payload)
        body.append(payloadData)
        append(lineBreak)

        for (index, file) in attachments.enumerated() {
            append("--\(boundary)\(lineBreak)")
            append("Content-Disposition: form-data; name=\"files[\(index)]\"; filename=\"\(file.filename)\"\(lineBreak)")
            append("Content-Type: \(file.contentType)\(lineBreak)\(lineBreak)")
            body.append(file.data)
            append(lineBreak)
        }

        append("--\(boundary)--\(lineBreak)")
        return body
    }
}


private struct SendMessageBody: Encodable {
    let content: String
    let messageReference: MessageReference?
}

private struct SendComponentsV2MessageBody: Encodable {
    let flags: Int
    let components: [ComponentV2Node]
    let messageReference: MessageReference?
    let attachments: [UploadAttachmentMetadata]?
}

private struct UploadAttachmentMetadata: Encodable {
    let id: Int
    let filename: String
    let description: String?
}

private struct EditInteractionBody: Encodable {
    let content: String
}

private struct EditMessageBody: Encodable {
    let content: String
}

private struct BulkDeleteMessagesBody: Encodable {
    let messages: [String]
}

private struct FollowupBody: Encodable {
    let content: String
    let flags: Int?
}

private struct RateLimitResponse: Decodable {
    let message: String
    let retryAfter: Double
    let global: Bool
}

private struct DiscordAPIErrorPayload: Decodable {
    let message: String?
}


public struct ApplicationCommand: Codable, Sendable, Identifiable {
    public let id: String
    public let applicationId: String
    public let guildId: String?
    public let name: String
    public let nameLocalizations: [String: String]?
    public let description: String
    public let descriptionLocalizations: [String: String]?
    public let type: Int?
    public let options: [ApplicationCommandOption]?
    public let defaultMemberPermissions: String?
    public let defaultPermission: Bool?
    public let dmPermission: Bool?
    public let nsfw: Bool?
    public let integrationTypes: [Int]?
    public let contexts: [Int]?
    public let handler: Int?
    public let version: String
}

public struct EditApplicationCommand: Encodable, Sendable {
    public let name: String?
    public let nameLocalizations: [String: String]?
    public let description: String?
    public let descriptionLocalizations: [String: String]?
    public let options: [CommandOption]?
    public let defaultMemberPermissions: String?
    public let dmPermission: Bool?
    public let defaultPermission: Bool?
    public let nsfw: Bool?
    public let integrationTypes: [Int]?
    public let contexts: [Int]?

    public init(
        name: String? = nil,
        nameLocalizations: [String: String]? = nil,
        description: String? = nil,
        descriptionLocalizations: [String: String]? = nil,
        options: [CommandOption]? = nil,
        defaultMemberPermissions: String? = nil,
        dmPermission: Bool? = nil,
        defaultPermission: Bool? = nil,
        nsfw: Bool? = nil,
        integrationTypes: [Int]? = nil,
        contexts: [Int]? = nil
    ) {
        self.name = name
        self.nameLocalizations = nameLocalizations
        self.description = description
        self.descriptionLocalizations = descriptionLocalizations
        self.options = options
        self.defaultMemberPermissions = defaultMemberPermissions
        self.dmPermission = dmPermission
        self.defaultPermission = defaultPermission
        self.nsfw = nsfw
        self.integrationTypes = integrationTypes
        self.contexts = contexts
    }
}

public struct ApplicationCommandOption: Codable, Sendable {
    public let type: Int
    public let name: String
    public let nameLocalizations: [String: String]?
    public let description: String
    public let descriptionLocalizations: [String: String]?
    public let required: Bool?
    public let choices: [ApplicationCommandChoice]?
    public let options: [ApplicationCommandOption]?
    public let channelTypes: [Int]?
    public let minValue: Double?
    public let maxValue: Double?
    public let minLength: Int?
    public let maxLength: Int?
    public let autocomplete: Bool?
}

public struct ApplicationCommandChoice: Codable, Sendable {
    public let name: String
    public let value: ApplicationCommandChoiceValue
}

public enum ApplicationCommandChoiceValue: Codable, Sendable {
    case string(String)
    case int(Int)
    case double(Double)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .string(string)
            return
        }
        if let int = try? container.decode(Int.self) {
            self = .int(int)
            return
        }
        self = .double(try container.decode(Double.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        }
    }
}
