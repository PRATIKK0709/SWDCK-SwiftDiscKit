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

    func modifyCurrentUser(_ modify: ModifyCurrentUser) async throws -> DiscordUser {
        try await request(method: "PATCH", url: Routes.currentUser, body: modify, decodeAs: DiscordUser.self)
    }

    func getGateway() async throws -> GatewayInfo {
        try await request(method: "GET", url: Routes.gateway, decodeAs: GatewayInfo.self)
    }

    func getGatewayBot() async throws -> GatewayBot {
        try await request(method: "GET", url: Routes.gatewayBot, decodeAs: GatewayBot.self)
    }

    func getVoiceRegions() async throws -> [VoiceRegion] {
        try await request(method: "GET", url: Routes.voiceRegions(), decodeAs: [VoiceRegion].self)
    }

    func getCurrentUserVoiceState(guildId: String) async throws -> VoiceState {
        try await request(method: "GET", url: Routes.guildVoiceStateMe(guildId), decodeAs: VoiceState.self)
    }

    func getVoiceState(guildId: String, userId: String) async throws -> VoiceState {
        try await request(
            method: "GET",
            url: Routes.guildVoiceState(guildId, userId: userId),
            decodeAs: VoiceState.self
        )
    }

    func modifyCurrentUserVoiceState(guildId: String, state: ModifyCurrentUserVoiceState) async throws {
        try await requestVoid(method: "PATCH", url: Routes.guildVoiceStateMe(guildId), body: state)
    }

    func modifyUserVoiceState(guildId: String, userId: String, state: ModifyUserVoiceState) async throws {
        try await requestVoid(
            method: "PATCH",
            url: Routes.guildVoiceState(guildId, userId: userId),
            body: state
        )
    }

    func createStageInstance(
        stage: CreateStageInstance,
        auditLogReason: String? = nil
    ) async throws -> StageInstance {
        try await request(
            method: "POST",
            url: Routes.stageInstances(),
            body: stage,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: StageInstance.self
        )
    }

    func getStageInstance(channelId: String) async throws -> StageInstance {
        try await request(method: "GET", url: Routes.stageInstance(channelId), decodeAs: StageInstance.self)
    }

    func modifyStageInstance(
        channelId: String,
        modify: ModifyStageInstance,
        auditLogReason: String? = nil
    ) async throws -> StageInstance {
        try await request(
            method: "PATCH",
            url: Routes.stageInstance(channelId),
            body: modify,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: StageInstance.self
        )
    }

    func deleteStageInstance(channelId: String, auditLogReason: String? = nil) async throws {
        try await requestVoid(
            method: "DELETE",
            url: Routes.stageInstance(channelId),
            headers: auditLogHeaders(reason: auditLogReason)
        )
    }

    func getUser(userId: String) async throws -> DiscordUser {
        try await request(method: "GET", url: Routes.user(userId), decodeAs: DiscordUser.self)
    }

    func getCurrentUserGuilds(query: CurrentUserGuildsQuery = CurrentUserGuildsQuery()) async throws -> [UserGuild] {
        let url = buildCurrentUserGuildsURL(query: query)
        return try await request(method: "GET", url: url, decodeAs: [UserGuild].self)
    }

    func leaveGuild(guildId: String) async throws {
        try await requestVoid(method: "DELETE", url: Routes.currentUserGuild(guildId))
    }

    func createDM(_ create: CreateDM) async throws -> Channel {
        try await request(
            method: "POST",
            url: Routes.currentUserChannels(),
            body: create,
            decodeAs: Channel.self
        )
    }

    func getCurrentUserConnections() async throws -> [UserConnection] {
        try await request(method: "GET", url: Routes.currentUserConnections(), decodeAs: [UserConnection].self)
    }

    func getCurrentUserGuildMember(guildId: String) async throws -> GuildMember {
        try await request(method: "GET", url: Routes.currentUserGuildMember(guildId), decodeAs: GuildMember.self)
    }

    func getCurrentUserApplicationRoleConnection(applicationId: String) async throws -> ApplicationRoleConnection {
        try await request(
            method: "GET",
            url: Routes.currentUserApplicationRoleConnection(applicationId),
            decodeAs: ApplicationRoleConnection.self
        )
    }

    func updateCurrentUserApplicationRoleConnection(
        applicationId: String,
        connection: PutApplicationRoleConnection
    ) async throws -> ApplicationRoleConnection {
        try await request(
            method: "PUT",
            url: Routes.currentUserApplicationRoleConnection(applicationId),
            body: connection,
            decodeAs: ApplicationRoleConnection.self
        )
    }

    func getCurrentApplication() async throws -> DiscordApplication {
        try await request(method: "GET", url: Routes.currentApplication(), decodeAs: DiscordApplication.self)
    }

    func modifyCurrentApplication(_ modify: ModifyApplication) async throws -> DiscordApplication {
        try await request(
            method: "PATCH",
            url: Routes.currentApplication(),
            body: modify,
            decodeAs: DiscordApplication.self
        )
    }

    func getApplication(applicationId: String) async throws -> DiscordApplication {
        try await request(method: "GET", url: Routes.application(applicationId), decodeAs: DiscordApplication.self)
    }

    func modifyApplication(applicationId: String, modify: ModifyApplication) async throws -> DiscordApplication {
        try await request(
            method: "PATCH",
            url: Routes.application(applicationId),
            body: modify,
            decodeAs: DiscordApplication.self
        )
    }

    func getApplicationActivityInstance(applicationId: String, instanceId: String) async throws -> JSONValue {
        try await request(
            method: "GET",
            url: Routes.applicationActivityInstance(applicationId, instanceId: instanceId),
            decodeAs: JSONValue.self
        )
    }

    func getApplicationRoleConnectionMetadata(applicationId: String) async throws -> [ApplicationRoleConnectionMetadataRecord] {
        try await request(
            method: "GET",
            url: Routes.applicationRoleConnectionMetadata(applicationId),
            decodeAs: [ApplicationRoleConnectionMetadataRecord].self
        )
    }

    func getApplicationSKUs(applicationId: String) async throws -> [SKU] {
        try await request(
            method: "GET",
            url: Routes.applicationSkus(applicationId),
            decodeAs: [SKU].self
        )
    }

    func getApplicationEntitlements(
        applicationId: String,
        query: EntitlementsQuery = EntitlementsQuery()
    ) async throws -> [Entitlement] {
        let url = buildApplicationEntitlementsURL(applicationId: applicationId, query: query)
        return try await request(method: "GET", url: url, decodeAs: [Entitlement].self)
    }

    func consumeEntitlement(applicationId: String, entitlementId: String) async throws {
        try await requestVoid(
            method: "POST",
            url: Routes.applicationEntitlementConsume(applicationId, entitlementId: entitlementId)
        )
    }

    func updateApplicationRoleConnectionMetadata(
        applicationId: String,
        records: [ApplicationRoleConnectionMetadataRecord]
    ) async throws -> [ApplicationRoleConnectionMetadataRecord] {
        try await request(
            method: "PUT",
            url: Routes.applicationRoleConnectionMetadata(applicationId),
            body: records,
            decodeAs: [ApplicationRoleConnectionMetadataRecord].self
        )
    }

    func getOAuth2CurrentAuthorization() async throws -> OAuth2Authorization {
        try await request(
            method: "GET",
            url: Routes.oauth2CurrentAuthorization(),
            decodeAs: OAuth2Authorization.self
        )
    }

    func getOAuth2CurrentApplication() async throws -> DiscordApplication {
        try await request(
            method: "GET",
            url: Routes.oauth2CurrentApplication(),
            decodeAs: DiscordApplication.self
        )
    }


    func getChannel(channelId: String) async throws -> Channel {
        try await request(method: "GET", url: Routes.channel(channelId), decodeAs: Channel.self)
    }

    func modifyChannel(
        channelId: String,
        modify: ModifyChannel,
        auditLogReason: String? = nil
    ) async throws -> Channel {
        try await request(
            method: "PATCH",
            url: Routes.channel(channelId),
            body: modify,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: Channel.self
        )
    }

    func deleteChannel(channelId: String, auditLogReason: String? = nil) async throws -> Channel {
        try await request(
            method: "DELETE",
            url: Routes.channel(channelId),
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: Channel.self
        )
    }

    func addChannelRecipient(channelId: String, userId: String, recipient: GroupDMAddRecipient) async throws {
        try await requestVoid(
            method: "PUT",
            url: Routes.channelRecipient(channelId, userId: userId),
            body: recipient
        )
    }

    func deleteChannelRecipient(channelId: String, userId: String) async throws {
        try await requestVoid(
            method: "DELETE",
            url: Routes.channelRecipient(channelId, userId: userId)
        )
    }

    func editChannelPermission(
        channelId: String,
        overwriteId: String,
        permission: EditChannelPermission,
        auditLogReason: String? = nil
    ) async throws {
        try await requestVoid(
            method: "PUT",
            url: Routes.channelPermission(channelId, overwriteId: overwriteId),
            body: permission,
            headers: auditLogHeaders(reason: auditLogReason)
        )
    }

    func deleteChannelPermission(
        channelId: String,
        overwriteId: String,
        auditLogReason: String? = nil
    ) async throws {
        try await requestVoid(
            method: "DELETE",
            url: Routes.channelPermission(channelId, overwriteId: overwriteId),
            headers: auditLogHeaders(reason: auditLogReason)
        )
    }

    func createWebhook(
        channelId: String,
        webhook: CreateWebhook,
        auditLogReason: String? = nil
    ) async throws -> Webhook {
        try await request(
            method: "POST",
            url: Routes.channelWebhooks(channelId),
            body: webhook,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: Webhook.self
        )
    }

    func getChannelWebhooks(channelId: String) async throws -> [Webhook] {
        try await request(
            method: "GET",
            url: Routes.channelWebhooks(channelId),
            decodeAs: [Webhook].self
        )
    }

    func getWebhook(webhookId: String) async throws -> Webhook {
        try await request(method: "GET", url: Routes.webhook(webhookId), decodeAs: Webhook.self)
    }

    func getWebhook(webhookId: String, token: String) async throws -> Webhook {
        try await request(method: "GET", url: Routes.webhook(webhookId, token: token), decodeAs: Webhook.self)
    }

    func modifyWebhook(
        webhookId: String,
        modify: ModifyWebhook,
        auditLogReason: String? = nil
    ) async throws -> Webhook {
        try await request(
            method: "PATCH",
            url: Routes.webhook(webhookId),
            body: modify,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: Webhook.self
        )
    }

    func modifyWebhook(
        webhookId: String,
        token: String,
        modify: ModifyWebhook
    ) async throws -> Webhook {
        try await request(
            method: "PATCH",
            url: Routes.webhook(webhookId, token: token),
            body: modify,
            decodeAs: Webhook.self
        )
    }

    func deleteWebhook(webhookId: String, auditLogReason: String? = nil) async throws {
        try await requestVoid(
            method: "DELETE",
            url: Routes.webhook(webhookId),
            headers: auditLogHeaders(reason: auditLogReason)
        )
    }

    func deleteWebhook(webhookId: String, token: String) async throws {
        try await requestVoid(
            method: "DELETE",
            url: Routes.webhook(webhookId, token: token)
        )
    }

    @discardableResult
    func executeWebhook(
        webhookId: String,
        token: String,
        execute: ExecuteWebhook,
        query: ExecuteWebhookQuery = ExecuteWebhookQuery()
    ) async throws -> Message? {
        let url = buildExecuteWebhookURL(webhookId: webhookId, token: token, query: query)
        let data = try await rawRequest(method: "POST", url: url, body: execute, headers: [:])
        guard query.wait == true, !data.isEmpty else { return nil }
        var message = try JSONCoder.decode(Message.self, from: data)
        message._rest = self
        return message
    }

    @discardableResult
    func getWebhookMessage(
        webhookId: String,
        token: String,
        messageId: String,
        query: WebhookMessageQuery = WebhookMessageQuery()
    ) async throws -> Message {
        let url = buildWebhookMessageURL(webhookId: webhookId, token: token, messageId: messageId, query: query)
        var message = try await request(method: "GET", url: url, decodeAs: Message.self)
        message._rest = self
        return message
    }

    @discardableResult
    func editWebhookMessage(
        webhookId: String,
        token: String,
        messageId: String,
        edit: EditWebhookMessage,
        query: WebhookMessageQuery = WebhookMessageQuery()
    ) async throws -> Message {
        let url = buildWebhookMessageURL(webhookId: webhookId, token: token, messageId: messageId, query: query)
        var message = try await request(method: "PATCH", url: url, body: edit, decodeAs: Message.self)
        message._rest = self
        return message
    }

    func deleteWebhookMessage(
        webhookId: String,
        token: String,
        messageId: String,
        query: WebhookMessageQuery = WebhookMessageQuery()
    ) async throws {
        let url = buildWebhookMessageURL(webhookId: webhookId, token: token, messageId: messageId, query: query)
        try await requestVoid(method: "DELETE", url: url)
    }

    func getChannelInvites(channelId: String) async throws -> [Invite] {
        try await request(method: "GET", url: Routes.channelInvites(channelId), decodeAs: [Invite].self)
    }

    func createChannelInvite(
        channelId: String,
        invite: CreateChannelInvite = CreateChannelInvite(),
        auditLogReason: String? = nil
    ) async throws -> Invite {
        let payload = CreateChannelInvitePayload(
            maxAge: invite.maxAge,
            maxUses: invite.maxUses,
            temporary: invite.temporary,
            unique: invite.unique,
            targetType: invite.targetType,
            targetUserId: invite.targetUserId,
            targetApplicationId: invite.targetApplicationId,
            targetEventId: invite.targetEventId,
            flags: invite.flags,
            roleIds: invite.roleIds
        )

        let headers = auditLogHeaders(reason: auditLogReason)
        if let targetUsersFileData = invite.targetUsersFileData {
            return try await createChannelInviteMultipart(
                channelId: channelId,
                payload: payload,
                targetUsersFileData: targetUsersFileData,
                targetUsersFilename: invite.targetUsersFileName,
                headers: headers
            )
        }

        return try await request(
            method: "POST",
            url: Routes.channelInvites(channelId),
            body: payload,
            headers: headers,
            decodeAs: Invite.self
        )
    }

    func followAnnouncementChannel(
        channelId: String,
        follow: FollowAnnouncementChannel
    ) async throws -> FollowedChannel {
        try await request(
            method: "POST",
            url: Routes.channelFollowers(channelId),
            body: follow,
            decodeAs: FollowedChannel.self
        )
    }

    func triggerTyping(channelId: String) async throws {
        try await requestVoid(method: "POST", url: Routes.typing(channelId))
    }

    func startThreadFromMessage(
        channelId: String,
        messageId: String,
        payload: StartThreadFromMessage,
        auditLogReason: String? = nil
    ) async throws -> Channel {
        try await request(
            method: "POST",
            url: Routes.messageThread(channelId, messageId: messageId),
            body: payload,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: Channel.self
        )
    }

    func startThreadWithoutMessage(
        channelId: String,
        payload: StartThreadWithoutMessage,
        auditLogReason: String? = nil
    ) async throws -> Channel {
        try await request(
            method: "POST",
            url: Routes.channelThreads(channelId),
            body: payload,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: Channel.self
        )
    }

    func getPublicArchivedThreads(channelId: String, query: ArchivedThreadsQuery = ArchivedThreadsQuery()) async throws -> ArchivedThreadsResponse {
        let url = buildArchivedThreadsURL(baseURL: Routes.channelArchivedPublicThreads(channelId), query: query)
        return try await request(method: "GET", url: url, decodeAs: ArchivedThreadsResponse.self)
    }

    func getPrivateArchivedThreads(channelId: String, query: ArchivedThreadsQuery = ArchivedThreadsQuery()) async throws -> ArchivedThreadsResponse {
        let url = buildArchivedThreadsURL(baseURL: Routes.channelArchivedPrivateThreads(channelId), query: query)
        return try await request(method: "GET", url: url, decodeAs: ArchivedThreadsResponse.self)
    }

    func getJoinedPrivateArchivedThreads(channelId: String, query: ArchivedThreadsQuery = ArchivedThreadsQuery()) async throws -> ArchivedThreadsResponse {
        let url = buildArchivedThreadsURL(baseURL: Routes.channelJoinedPrivateArchivedThreads(channelId), query: query)
        return try await request(method: "GET", url: url, decodeAs: ArchivedThreadsResponse.self)
    }

    func getThreadMembers(channelId: String, query: ThreadMembersQuery = ThreadMembersQuery()) async throws -> [ChannelThreadMember] {
        let url = buildThreadMembersURL(channelId: channelId, query: query)
        return try await request(method: "GET", url: url, decodeAs: [ChannelThreadMember].self)
    }

    func getThreadMember(channelId: String, userId: String, withMember: Bool? = nil) async throws -> ChannelThreadMember {
        var url = Routes.threadMember(channelId, userId: userId)
        if let withMember {
            guard var components = URLComponents(string: url) else {
                return try await request(method: "GET", url: url, decodeAs: ChannelThreadMember.self)
            }
            components.queryItems = [URLQueryItem(name: "with_member", value: withMember ? "true" : "false")]
            url = components.url?.absoluteString ?? url
        }
        return try await request(method: "GET", url: url, decodeAs: ChannelThreadMember.self)
    }

    func addThreadMember(channelId: String, userId: String) async throws {
        try await requestVoid(method: "PUT", url: Routes.threadMember(channelId, userId: userId))
    }

    func removeThreadMember(channelId: String, userId: String) async throws {
        try await requestVoid(method: "DELETE", url: Routes.threadMember(channelId, userId: userId))
    }

    func joinThread(channelId: String) async throws {
        try await requestVoid(method: "PUT", url: Routes.threadMemberMe(channelId))
    }

    func leaveThread(channelId: String) async throws {
        try await requestVoid(method: "DELETE", url: Routes.threadMemberMe(channelId))
    }

    func getActiveGuildThreads(guildId: String) async throws -> ActiveGuildThreadsResponse {
        try await request(
            method: "GET",
            url: Routes.guildActiveThreads(guildId),
            decodeAs: ActiveGuildThreadsResponse.self
        )
    }

    func getMessagePins(channelId: String, query: MessagePinsQuery = MessagePinsQuery()) async throws -> MessagePinsPage {
        let url = buildMessagePinsURL(channelId: channelId, query: query)
        var page = try await request(method: "GET", url: url, decodeAs: MessagePinsPage.self)
        for index in page.items.indices {
            page.items[index].message._rest = self
        }
        return page
    }

    func getPins(channelId: String) async throws -> [Message] {
        var messages = try await request(
            method: "GET",
            url: Routes.pins(channelId),
            decodeAs: [Message].self
        )
        for index in messages.indices {
            messages[index]._rest = self
        }
        return messages
    }

    func pinMessage(channelId: String, messageId: String, auditLogReason: String? = nil) async throws {
        try await requestVoid(
            method: "PUT",
            url: Routes.messagePin(channelId, messageId: messageId),
            headers: auditLogHeaders(reason: auditLogReason)
        )
    }

    func pin(channelId: String, messageId: String, auditLogReason: String? = nil) async throws {
        try await requestVoid(
            method: "PUT",
            url: Routes.pin(channelId, messageId: messageId),
            headers: auditLogHeaders(reason: auditLogReason)
        )
    }

    func unpinMessage(channelId: String, messageId: String, auditLogReason: String? = nil) async throws {
        try await requestVoid(
            method: "DELETE",
            url: Routes.messagePin(channelId, messageId: messageId),
            headers: auditLogHeaders(reason: auditLogReason)
        )
    }

    func unpin(channelId: String, messageId: String, auditLogReason: String? = nil) async throws {
        try await requestVoid(
            method: "DELETE",
            url: Routes.pin(channelId, messageId: messageId),
            headers: auditLogHeaders(reason: auditLogReason)
        )
    }

    func createReaction(channelId: String, messageId: String, emoji: String) async throws {
        let encodedEmoji = encodeEmojiForPath(emoji)
        try await requestVoid(
            method: "PUT",
            url: Routes.messageReactionMe(channelId, messageId: messageId, emoji: encodedEmoji)
        )
    }

    func deleteOwnReaction(channelId: String, messageId: String, emoji: String) async throws {
        let encodedEmoji = encodeEmojiForPath(emoji)
        try await requestVoid(
            method: "DELETE",
            url: Routes.messageReactionMe(channelId, messageId: messageId, emoji: encodedEmoji)
        )
    }

    func getReactions(
        channelId: String,
        messageId: String,
        emoji: String,
        query: ReactionUsersQuery = ReactionUsersQuery()
    ) async throws -> [DiscordUser] {
        let encodedEmoji = encodeEmojiForPath(emoji)
        let url = buildReactionUsersURL(channelId: channelId, messageId: messageId, emoji: encodedEmoji, query: query)
        return try await request(method: "GET", url: url, decodeAs: [DiscordUser].self)
    }

    func deleteUserReaction(channelId: String, messageId: String, emoji: String, userId: String) async throws {
        let encodedEmoji = encodeEmojiForPath(emoji)
        try await requestVoid(
            method: "DELETE",
            url: Routes.messageReactionUser(channelId, messageId: messageId, emoji: encodedEmoji, userId: userId)
        )
    }

    func deleteAllReactionsForEmoji(channelId: String, messageId: String, emoji: String) async throws {
        let encodedEmoji = encodeEmojiForPath(emoji)
        try await requestVoid(
            method: "DELETE",
            url: Routes.messageReactions(channelId, messageId: messageId, emoji: encodedEmoji)
        )
    }

    func deleteAllReactions(channelId: String, messageId: String) async throws {
        try await requestVoid(
            method: "DELETE",
            url: Routes.messageReactions(channelId, messageId: messageId)
        )
    }

    func getGuild(guildId: String) async throws -> Guild {
        try await request(method: "GET", url: Routes.guild(guildId), decodeAs: Guild.self)
    }

    func getGuildAutoModerationRules(guildId: String) async throws -> [AutoModerationRule] {
        try await request(
            method: "GET",
            url: Routes.guildAutoModerationRules(guildId),
            decodeAs: [AutoModerationRule].self
        )
    }

    func getGuildAutoModerationRule(guildId: String, ruleId: String) async throws -> AutoModerationRule {
        try await request(
            method: "GET",
            url: Routes.guildAutoModerationRule(guildId, ruleId: ruleId),
            decodeAs: AutoModerationRule.self
        )
    }

    func createGuildAutoModerationRule(
        guildId: String,
        rule: CreateAutoModerationRule,
        auditLogReason: String? = nil
    ) async throws -> AutoModerationRule {
        try await request(
            method: "POST",
            url: Routes.guildAutoModerationRules(guildId),
            body: rule,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: AutoModerationRule.self
        )
    }

    func modifyGuildAutoModerationRule(
        guildId: String,
        ruleId: String,
        modify: ModifyAutoModerationRule,
        auditLogReason: String? = nil
    ) async throws -> AutoModerationRule {
        try await request(
            method: "PATCH",
            url: Routes.guildAutoModerationRule(guildId, ruleId: ruleId),
            body: modify,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: AutoModerationRule.self
        )
    }

    func deleteGuildAutoModerationRule(
        guildId: String,
        ruleId: String,
        auditLogReason: String? = nil
    ) async throws {
        try await requestVoid(
            method: "DELETE",
            url: Routes.guildAutoModerationRule(guildId, ruleId: ruleId),
            headers: auditLogHeaders(reason: auditLogReason)
        )
    }

    func getGuildPreview(guildId: String) async throws -> JSONValue {
        try await request(method: "GET", url: Routes.guildPreview(guildId), decodeAs: JSONValue.self)
    }

    func modifyGuild(
        guildId: String,
        modify: ModifyGuild,
        auditLogReason: String? = nil
    ) async throws -> Guild {
        try await request(
            method: "PATCH",
            url: Routes.guild(guildId),
            body: modify,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: Guild.self
        )
    }

    func getGuildAuditLog(
        guildId: String,
        query: GuildAuditLogQuery = GuildAuditLogQuery()
    ) async throws -> GuildAuditLog {
        let url = buildGuildAuditLogURL(guildId: guildId, query: query)
        return try await request(method: "GET", url: url, decodeAs: GuildAuditLog.self)
    }

    func getGuildIntegrations(guildId: String) async throws -> [GuildIntegration] {
        try await request(method: "GET", url: Routes.guildIntegrations(guildId), decodeAs: [GuildIntegration].self)
    }

    func deleteGuildIntegration(guildId: String, integrationId: String, auditLogReason: String? = nil) async throws {
        try await requestVoid(
            method: "DELETE",
            url: Routes.guildIntegration(guildId, integrationId: integrationId),
            headers: auditLogHeaders(reason: auditLogReason)
        )
    }

    func getGuildOnboarding(guildId: String) async throws -> JSONValue {
        try await request(method: "GET", url: Routes.guildOnboarding(guildId), decodeAs: JSONValue.self)
    }

    func modifyGuildOnboarding(
        guildId: String,
        payload: JSONValue,
        auditLogReason: String? = nil
    ) async throws -> JSONValue {
        try await request(
            method: "PUT",
            url: Routes.guildOnboarding(guildId),
            body: payload,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: JSONValue.self
        )
    }

    func getGuildRegions(guildId: String) async throws -> [VoiceRegion] {
        try await request(method: "GET", url: Routes.guildRegions(guildId), decodeAs: [VoiceRegion].self)
    }

    func getGuildRoleMemberCounts(guildId: String) async throws -> [String: Int] {
        try await request(method: "GET", url: Routes.guildRoleMemberCounts(guildId), decodeAs: [String: Int].self)
    }

    func getGuildVanityURL(guildId: String) async throws -> JSONValue {
        try await request(method: "GET", url: Routes.guildVanityURL(guildId), decodeAs: JSONValue.self)
    }

    func getGuildWelcomeScreen(guildId: String) async throws -> JSONValue {
        try await request(method: "GET", url: Routes.guildWelcomeScreen(guildId), decodeAs: JSONValue.self)
    }

    func modifyGuildWelcomeScreen(
        guildId: String,
        payload: JSONValue,
        auditLogReason: String? = nil
    ) async throws -> JSONValue {
        try await request(
            method: "PATCH",
            url: Routes.guildWelcomeScreen(guildId),
            body: payload,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: JSONValue.self
        )
    }

    func getGuildWidgetSettings(guildId: String) async throws -> JSONValue {
        try await request(method: "GET", url: Routes.guildWidget(guildId), decodeAs: JSONValue.self)
    }

    func modifyGuildWidget(
        guildId: String,
        payload: JSONValue,
        auditLogReason: String? = nil
    ) async throws -> JSONValue {
        try await request(
            method: "PATCH",
            url: Routes.guildWidget(guildId),
            body: payload,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: JSONValue.self
        )
    }

    func getGuildWidget(guildId: String) async throws -> JSONValue {
        try await request(method: "GET", url: Routes.guildWidgetJSON(guildId), decodeAs: JSONValue.self)
    }

    func getGuildWidgetImage(guildId: String, style: String? = nil) async throws -> Data {
        guard
            let style,
            !style.isEmpty,
            var components = URLComponents(string: Routes.guildWidgetPNG(guildId))
        else {
            return try await rawRequest(method: "GET", url: Routes.guildWidgetPNG(guildId), body: nil, headers: [:])
        }

        components.queryItems = [URLQueryItem(name: "style", value: style)]
        let url = components.url?.absoluteString ?? Routes.guildWidgetPNG(guildId)
        return try await rawRequest(method: "GET", url: url, body: nil, headers: [:])
    }

    func getGuildBans(
        guildId: String,
        query: GuildBansQuery = GuildBansQuery()
    ) async throws -> [GuildBan] {
        let url = buildGuildBansURL(guildId: guildId, query: query)
        return try await request(method: "GET", url: url, decodeAs: [GuildBan].self)
    }

    func getGuildBan(guildId: String, userId: String) async throws -> GuildBan {
        try await request(
            method: "GET",
            url: Routes.guildBan(guildId, userId: userId),
            decodeAs: GuildBan.self
        )
    }

    func createGuildBan(
        guildId: String,
        userId: String,
        ban: CreateGuildBan = CreateGuildBan(),
        auditLogReason: String? = nil
    ) async throws {
        try await requestVoid(
            method: "PUT",
            url: Routes.guildBan(guildId, userId: userId),
            body: ban,
            headers: auditLogHeaders(reason: auditLogReason)
        )
    }

    func deleteGuildBan(
        guildId: String,
        userId: String,
        auditLogReason: String? = nil
    ) async throws {
        try await requestVoid(
            method: "DELETE",
            url: Routes.guildBan(guildId, userId: userId),
            headers: auditLogHeaders(reason: auditLogReason)
        )
    }

    func getGuildPruneCount(
        guildId: String,
        query: GuildPruneCountQuery = GuildPruneCountQuery()
    ) async throws -> GuildPruneResult {
        let url = buildGuildPruneURL(guildId: guildId, query: query)
        return try await request(method: "GET", url: url, decodeAs: GuildPruneResult.self)
    }

    func beginGuildPrune(
        guildId: String,
        prune: BeginGuildPrune = BeginGuildPrune(),
        auditLogReason: String? = nil
    ) async throws -> GuildPruneResult {
        try await request(
            method: "POST",
            url: Routes.guildPrune(guildId),
            body: prune,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: GuildPruneResult.self
        )
    }

    func createGuildChannel(
        guildId: String,
        channel: CreateGuildChannel,
        auditLogReason: String? = nil
    ) async throws -> Channel {
        try await request(
            method: "POST",
            url: Routes.guildChannels(guildId),
            body: channel,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: Channel.self
        )
    }

    func modifyGuildChannelPositions(
        guildId: String,
        positions: [ModifyGuildChannelPosition],
        auditLogReason: String? = nil
    ) async throws {
        try await requestVoid(
            method: "PATCH",
            url: Routes.guildChannels(guildId),
            body: positions,
            headers: auditLogHeaders(reason: auditLogReason)
        )
    }

    func getGuildWebhooks(guildId: String) async throws -> [Webhook] {
        try await request(
            method: "GET",
            url: Routes.guildWebhooks(guildId),
            decodeAs: [Webhook].self
        )
    }

    func getGuildInvites(guildId: String) async throws -> [Invite] {
        try await request(method: "GET", url: Routes.guildInvites(guildId), decodeAs: [Invite].self)
    }

    func getGuildEmojis(guildId: String) async throws -> [GuildEmoji] {
        try await request(method: "GET", url: Routes.guildEmojis(guildId), decodeAs: [GuildEmoji].self)
    }

    func getGuildEmoji(guildId: String, emojiId: String) async throws -> GuildEmoji {
        try await request(
            method: "GET",
            url: Routes.guildEmoji(guildId, emojiId: emojiId),
            decodeAs: GuildEmoji.self
        )
    }

    func createGuildEmoji(
        guildId: String,
        emoji: CreateGuildEmoji,
        auditLogReason: String? = nil
    ) async throws -> GuildEmoji {
        try await request(
            method: "POST",
            url: Routes.guildEmojis(guildId),
            body: emoji,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: GuildEmoji.self
        )
    }

    func modifyGuildEmoji(
        guildId: String,
        emojiId: String,
        modify: ModifyGuildEmoji,
        auditLogReason: String? = nil
    ) async throws -> GuildEmoji {
        try await request(
            method: "PATCH",
            url: Routes.guildEmoji(guildId, emojiId: emojiId),
            body: modify,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: GuildEmoji.self
        )
    }

    func deleteGuildEmoji(guildId: String, emojiId: String, auditLogReason: String? = nil) async throws {
        try await requestVoid(
            method: "DELETE",
            url: Routes.guildEmoji(guildId, emojiId: emojiId),
            headers: auditLogHeaders(reason: auditLogReason)
        )
    }

    func getGuildTemplate(code: String) async throws -> GuildTemplate {
        try await request(method: "GET", url: Routes.guildTemplate(code: code), decodeAs: GuildTemplate.self)
    }

    func createGuildFromTemplate(code: String, guild: CreateGuildFromTemplate) async throws -> Guild {
        try await request(
            method: "POST",
            url: Routes.guildTemplate(code: code),
            body: guild,
            decodeAs: Guild.self
        )
    }

    func getGuildTemplates(guildId: String) async throws -> [GuildTemplate] {
        try await request(method: "GET", url: Routes.guildTemplates(guildId), decodeAs: [GuildTemplate].self)
    }

    func createGuildTemplate(
        guildId: String,
        template: CreateGuildTemplate,
        auditLogReason: String? = nil
    ) async throws -> GuildTemplate {
        try await request(
            method: "POST",
            url: Routes.guildTemplates(guildId),
            body: template,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: GuildTemplate.self
        )
    }

    func syncGuildTemplate(
        guildId: String,
        code: String,
        auditLogReason: String? = nil
    ) async throws -> GuildTemplate {
        try await request(
            method: "PUT",
            url: Routes.guildTemplate(guildId, code: code),
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: GuildTemplate.self
        )
    }

    func modifyGuildTemplate(
        guildId: String,
        code: String,
        modify: ModifyGuildTemplate,
        auditLogReason: String? = nil
    ) async throws -> GuildTemplate {
        try await request(
            method: "PATCH",
            url: Routes.guildTemplate(guildId, code: code),
            body: modify,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: GuildTemplate.self
        )
    }

    func deleteGuildTemplate(
        guildId: String,
        code: String,
        auditLogReason: String? = nil
    ) async throws -> GuildTemplate {
        try await request(
            method: "DELETE",
            url: Routes.guildTemplate(guildId, code: code),
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: GuildTemplate.self
        )
    }

    func getGuildScheduledEvents(
        guildId: String,
        query: GuildScheduledEventsQuery = GuildScheduledEventsQuery()
    ) async throws -> [GuildScheduledEvent] {
        let url = buildGuildScheduledEventsURL(guildId: guildId, query: query)
        return try await request(method: "GET", url: url, decodeAs: [GuildScheduledEvent].self)
    }

    func createGuildScheduledEvent(
        guildId: String,
        event: CreateGuildScheduledEvent,
        auditLogReason: String? = nil
    ) async throws -> GuildScheduledEvent {
        try await request(
            method: "POST",
            url: Routes.guildScheduledEvents(guildId),
            body: event,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: GuildScheduledEvent.self
        )
    }

    func getGuildScheduledEvent(
        guildId: String,
        eventId: String,
        withUserCount: Bool? = nil
    ) async throws -> GuildScheduledEvent {
        let url = buildGuildScheduledEventURL(guildId: guildId, eventId: eventId, withUserCount: withUserCount)
        return try await request(method: "GET", url: url, decodeAs: GuildScheduledEvent.self)
    }

    func modifyGuildScheduledEvent(
        guildId: String,
        eventId: String,
        modify: ModifyGuildScheduledEvent,
        auditLogReason: String? = nil
    ) async throws -> GuildScheduledEvent {
        try await request(
            method: "PATCH",
            url: Routes.guildScheduledEvent(guildId, eventId: eventId),
            body: modify,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: GuildScheduledEvent.self
        )
    }

    func deleteGuildScheduledEvent(
        guildId: String,
        eventId: String,
        auditLogReason: String? = nil
    ) async throws {
        try await requestVoid(
            method: "DELETE",
            url: Routes.guildScheduledEvent(guildId, eventId: eventId),
            headers: auditLogHeaders(reason: auditLogReason)
        )
    }

    func getGuildScheduledEventUsers(
        guildId: String,
        eventId: String,
        query: GuildScheduledEventUsersQuery = GuildScheduledEventUsersQuery()
    ) async throws -> [GuildScheduledEventUser] {
        let url = buildGuildScheduledEventUsersURL(guildId: guildId, eventId: eventId, query: query)
        return try await request(method: "GET", url: url, decodeAs: [GuildScheduledEventUser].self)
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

    func modifyCurrentGuildMember(
        guildId: String,
        modify: ModifyCurrentGuildMember,
        auditLogReason: String? = nil
    ) async throws -> GuildMember {
        try await request(
            method: "PATCH",
            url: Routes.guildMemberMe(guildId),
            body: modify,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: GuildMember.self
        )
    }

    func modifyCurrentGuildNick(
        guildId: String,
        modify: ModifyCurrentGuildNick,
        auditLogReason: String? = nil
    ) async throws -> GuildMember {
        try await request(
            method: "PATCH",
            url: Routes.guildMemberNickMe(guildId),
            body: modify,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: GuildMember.self
        )
    }

    func addGuildMember(
        guildId: String,
        userId: String,
        add: AddGuildMember
    ) async throws -> GuildMember {
        try await request(
            method: "PUT",
            url: Routes.guildMember(guildId, userId: userId),
            body: add,
            decodeAs: GuildMember.self
        )
    }

    func removeGuildMember(
        guildId: String,
        userId: String,
        auditLogReason: String? = nil
    ) async throws {
        try await requestVoid(
            method: "DELETE",
            url: Routes.guildMember(guildId, userId: userId),
            headers: auditLogHeaders(reason: auditLogReason)
        )
    }

    func bulkBanGuildMembers(
        guildId: String,
        ban: BulkBan,
        auditLogReason: String? = nil
    ) async throws -> BulkBanResult {
        try await request(
            method: "POST",
            url: Routes.guildBulkBan(guildId),
            body: ban,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: BulkBanResult.self
        )
    }

    func setGuildIncidentActions(
        guildId: String,
        actions: GuildIncidentActions,
        auditLogReason: String? = nil
    ) async throws {
        try await requestVoid(
            method: "PUT",
            url: Routes.guildIncidentActions(guildId),
            body: actions,
            headers: auditLogHeaders(reason: auditLogReason)
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

    func modifyGuildRolePositions(
        guildId: String,
        positions: [ModifyGuildRolePosition],
        auditLogReason: String? = nil
    ) async throws -> [GuildRole] {
        try await request(
            method: "PATCH",
            url: Routes.guildRoles(guildId),
            body: positions,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: [GuildRole].self
        )
    }

    func createGuildRole(
        guildId: String,
        role: CreateGuildRole,
        auditLogReason: String? = nil
    ) async throws -> GuildRole {
        try await request(
            method: "POST",
            url: Routes.guildRoles(guildId),
            body: role,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: GuildRole.self
        )
    }

    func getGuildRole(guildId: String, roleId: String) async throws -> GuildRole {
        try await request(
            method: "GET",
            url: Routes.guildRole(guildId, roleId: roleId),
            decodeAs: GuildRole.self
        )
    }

    func modifyGuildRole(
        guildId: String,
        roleId: String,
        modify: ModifyGuildRole,
        auditLogReason: String? = nil
    ) async throws -> GuildRole {
        try await request(
            method: "PATCH",
            url: Routes.guildRole(guildId, roleId: roleId),
            body: modify,
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: GuildRole.self
        )
    }

    func deleteGuildRole(guildId: String, roleId: String, auditLogReason: String? = nil) async throws {
        try await requestVoid(
            method: "DELETE",
            url: Routes.guildRole(guildId, roleId: roleId),
            headers: auditLogHeaders(reason: auditLogReason)
        )
    }

    func getInvite(code: String, query: GetInviteQuery = GetInviteQuery()) async throws -> Invite {
        let url = buildInviteURL(code: code, query: query)
        return try await request(method: "GET", url: url, decodeAs: Invite.self)
    }

    func getPollAnswerVoters(
        channelId: String,
        messageId: String,
        answerId: String,
        query: PollAnswerVotersQuery = PollAnswerVotersQuery()
    ) async throws -> PollAnswerVotersResponse {
        let url = buildPollAnswerVotersURL(
            channelId: channelId,
            messageId: messageId,
            answerId: answerId,
            query: query
        )
        return try await request(method: "GET", url: url, decodeAs: PollAnswerVotersResponse.self)
    }

    func expirePoll(channelId: String, messageId: String) async throws -> Message {
        var message = try await request(
            method: "POST",
            url: Routes.expirePoll(channelId, messageId: messageId),
            decodeAs: Message.self
        )
        message._rest = self
        return message
    }

    func getInviteTargetUsers(code: String) async throws -> InviteTargetUsersResult {
        try await request(
            method: "GET",
            url: Routes.inviteTargetUsers(code),
            decodeAs: InviteTargetUsersResult.self
        )
    }

    func getInviteTargetUsersJobStatus(code: String) async throws -> InviteTargetUsersJobStatus {
        try await request(
            method: "GET",
            url: Routes.inviteTargetUsersJobStatus(code),
            decodeAs: InviteTargetUsersJobStatus.self
        )
    }

    func updateInviteTargetUsers(code: String, users: InviteTargetUsersUpdate) async throws -> InviteTargetUsersJobStatus {
        try await request(
            method: "PUT",
            url: Routes.inviteTargetUsers(code),
            body: users,
            decodeAs: InviteTargetUsersJobStatus.self
        )
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

    func crosspostMessage(channelId: String, messageId: String) async throws -> Message {
        var message = try await request(
            method: "POST",
            url: Routes.messageCrosspost(channelId, messageId: messageId),
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
    func executeGitHubWebhook(
        webhookId: String,
        token: String,
        payload: JSONValue,
        query: ExecuteWebhookQuery = ExecuteWebhookQuery()
    ) async throws -> Message? {
        let url = buildExecuteWebhookURL(baseURL: Routes.webhookGithub(webhookId, token: token), query: query)
        let data = try await rawRequest(method: "POST", url: url, body: payload, headers: [:])
        guard query.wait == true, !data.isEmpty else { return nil }
        var message = try JSONCoder.decode(Message.self, from: data)
        message._rest = self
        return message
    }

    @discardableResult
    func executeSlackWebhook(
        webhookId: String,
        token: String,
        payload: JSONValue,
        query: ExecuteWebhookQuery = ExecuteWebhookQuery()
    ) async throws -> Message? {
        let url = buildExecuteWebhookURL(baseURL: Routes.webhookSlack(webhookId, token: token), query: query)
        let data = try await rawRequest(method: "POST", url: url, body: payload, headers: [:])
        guard query.wait == true, !data.isEmpty else { return nil }
        var message = try JSONCoder.decode(Message.self, from: data)
        message._rest = self
        return message
    }

    func getWebhookGitHub(webhookId: String, token: String) async throws -> Webhook {
        try await request(method: "GET", url: Routes.webhookGithub(webhookId, token: token), decodeAs: Webhook.self)
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
        try validateComponentLimit(components)
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
        try validateComponentLimit(components)
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

    @discardableResult
    private func createChannelInviteMultipart(
        channelId: String,
        payload: CreateChannelInvitePayload,
        targetUsersFileData: Data,
        targetUsersFilename: String,
        headers: [String: String]
    ) async throws -> Invite {
        guard let url = URL(string: Routes.channelInvites(channelId)) else {
            throw DiscordError.connectionFailed(reason: "Invalid URL: \(Routes.channelInvites(channelId))")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bot \(token)", forHTTPHeaderField: "Authorization")
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = try buildInviteMultipartBody(
            boundary: boundary,
            payload: payload,
            targetUsersFileData: targetUsersFileData,
            targetUsersFilename: targetUsersFilename
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
                return try JSONCoder.decode(Invite.self, from: data)
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

        throw DiscordError.connectionFailed(reason: "Max retries exceeded for multipart invite request")
    }

    func deleteMessage(channelId: String, messageId: String) async throws {
        try await requestVoid(method: "DELETE", url: Routes.message(channelId, messageId: messageId))
    }


    func getApplicationId() async throws -> String {
        let user = try await getCurrentUser()
        return user.id
    }

    func deleteInvite(code: String, auditLogReason: String? = nil) async throws -> Invite {
        try await request(
            method: "DELETE",
            url: Routes.invite(code),
            headers: auditLogHeaders(reason: auditLogReason),
            decodeAs: Invite.self
        )
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

    func getGlobalCommand(applicationId: String, commandId: String) async throws -> ApplicationCommand {
        try await request(
            method: "GET",
            url: Routes.globalCommand(applicationId, commandId: commandId),
            decodeAs: ApplicationCommand.self
        )
    }

    func getGuildCommands(applicationId: String, guildId: String) async throws -> [ApplicationCommand] {
        try await request(
            method: "GET",
            url: Routes.guildCommands(applicationId, guildId: guildId),
            decodeAs: [ApplicationCommand].self
        )
    }

    func getGuildCommandPermissions(
        applicationId: String,
        guildId: String
    ) async throws -> [GuildApplicationCommandPermissions] {
        try await request(
            method: "GET",
            url: Routes.guildCommandPermissions(applicationId, guildId: guildId),
            decodeAs: [GuildApplicationCommandPermissions].self
        )
    }

    func getCommandPermissions(
        applicationId: String,
        guildId: String,
        commandId: String
    ) async throws -> GuildApplicationCommandPermissions {
        try await request(
            method: "GET",
            url: Routes.guildCommandPermissions(applicationId, guildId: guildId, commandId: commandId),
            decodeAs: GuildApplicationCommandPermissions.self
        )
    }

    func getGuildCommand(applicationId: String, guildId: String, commandId: String) async throws -> ApplicationCommand {
        try await request(
            method: "GET",
            url: Routes.guildCommand(applicationId, guildId: guildId, commandId: commandId),
            decodeAs: ApplicationCommand.self
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

    func bulkOverwriteGuildCommandPermissions(
        applicationId: String,
        guildId: String,
        permissions: [GuildApplicationCommandPermissions]
    ) async throws -> [GuildApplicationCommandPermissions] {
        try await request(
            method: "PUT",
            url: Routes.guildCommandPermissions(applicationId, guildId: guildId),
            body: permissions,
            decodeAs: [GuildApplicationCommandPermissions].self
        )
    }

    func setGuildCommandPermissions(
        applicationId: String,
        guildId: String,
        commandId: String,
        permissions: EditGuildApplicationCommandPermissions
    ) async throws -> GuildApplicationCommandPermissions {
        try await request(
            method: "PUT",
            url: Routes.guildCommandPermissions(applicationId, guildId: guildId, commandId: commandId),
            body: permissions,
            decodeAs: GuildApplicationCommandPermissions.self
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
    func buildGuildAuditLogURL(guildId: String, query: GuildAuditLogQuery) -> String {
        guard var components = URLComponents(string: Routes.guildAuditLogs(guildId)) else {
            return Routes.guildAuditLogs(guildId)
        }

        var items: [URLQueryItem] = []
        if let userId = query.userId { items.append(URLQueryItem(name: "user_id", value: userId)) }
        if let actionType = query.actionType { items.append(URLQueryItem(name: "action_type", value: String(actionType))) }
        if let before = query.before { items.append(URLQueryItem(name: "before", value: before)) }
        if let after = query.after { items.append(URLQueryItem(name: "after", value: after)) }
        if let limit = query.limit { items.append(URLQueryItem(name: "limit", value: String(limit))) }

        components.queryItems = items.isEmpty ? nil : items
        return components.url?.absoluteString ?? Routes.guildAuditLogs(guildId)
    }

    func buildGuildBansURL(guildId: String, query: GuildBansQuery) -> String {
        guard var components = URLComponents(string: Routes.guildBans(guildId)) else {
            return Routes.guildBans(guildId)
        }

        var items: [URLQueryItem] = []
        if let limit = query.limit { items.append(URLQueryItem(name: "limit", value: String(limit))) }
        if let before = query.before { items.append(URLQueryItem(name: "before", value: before)) }
        if let after = query.after { items.append(URLQueryItem(name: "after", value: after)) }

        components.queryItems = items.isEmpty ? nil : items
        return components.url?.absoluteString ?? Routes.guildBans(guildId)
    }

    func buildGuildPruneURL(guildId: String, query: GuildPruneCountQuery) -> String {
        guard var components = URLComponents(string: Routes.guildPrune(guildId)) else {
            return Routes.guildPrune(guildId)
        }

        var items: [URLQueryItem] = []
        if let days = query.days { items.append(URLQueryItem(name: "days", value: String(days))) }
        if let includeRoles = query.includeRoles, !includeRoles.isEmpty {
            items.append(URLQueryItem(name: "include_roles", value: includeRoles.joined(separator: ",")))
        }

        components.queryItems = items.isEmpty ? nil : items
        return components.url?.absoluteString ?? Routes.guildPrune(guildId)
    }

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

    func buildCurrentUserGuildsURL(query: CurrentUserGuildsQuery) -> String {
        guard var components = URLComponents(string: Routes.currentUserGuilds()) else {
            return Routes.currentUserGuilds()
        }

        var items: [URLQueryItem] = []
        if let before = query.before { items.append(URLQueryItem(name: "before", value: before)) }
        if let after = query.after { items.append(URLQueryItem(name: "after", value: after)) }
        if let limit = query.limit { items.append(URLQueryItem(name: "limit", value: String(limit))) }
        if let withCounts = query.withCounts {
            items.append(URLQueryItem(name: "with_counts", value: withCounts ? "true" : "false"))
        }

        components.queryItems = items.isEmpty ? nil : items
        return components.url?.absoluteString ?? Routes.currentUserGuilds()
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

    func buildGuildScheduledEventsURL(guildId: String, query: GuildScheduledEventsQuery) -> String {
        guard var components = URLComponents(string: Routes.guildScheduledEvents(guildId)) else {
            return Routes.guildScheduledEvents(guildId)
        }

        var items: [URLQueryItem] = []
        if let withUserCount = query.withUserCount {
            items.append(URLQueryItem(name: "with_user_count", value: withUserCount ? "true" : "false"))
        }
        components.queryItems = items.isEmpty ? nil : items
        return components.url?.absoluteString ?? Routes.guildScheduledEvents(guildId)
    }

    func buildGuildScheduledEventURL(guildId: String, eventId: String, withUserCount: Bool?) -> String {
        guard
            let withUserCount,
            var components = URLComponents(string: Routes.guildScheduledEvent(guildId, eventId: eventId))
        else {
            return Routes.guildScheduledEvent(guildId, eventId: eventId)
        }

        components.queryItems = [URLQueryItem(name: "with_user_count", value: withUserCount ? "true" : "false")]
        return components.url?.absoluteString ?? Routes.guildScheduledEvent(guildId, eventId: eventId)
    }

    func buildGuildScheduledEventUsersURL(
        guildId: String,
        eventId: String,
        query: GuildScheduledEventUsersQuery
    ) -> String {
        guard var components = URLComponents(string: Routes.guildScheduledEventUsers(guildId, eventId: eventId)) else {
            return Routes.guildScheduledEventUsers(guildId, eventId: eventId)
        }

        var items: [URLQueryItem] = []
        if let limit = query.limit { items.append(URLQueryItem(name: "limit", value: String(limit))) }
        if let withMember = query.withMember {
            items.append(URLQueryItem(name: "with_member", value: withMember ? "true" : "false"))
        }
        if let before = query.before { items.append(URLQueryItem(name: "before", value: before)) }
        if let after = query.after { items.append(URLQueryItem(name: "after", value: after)) }

        components.queryItems = items.isEmpty ? nil : items
        return components.url?.absoluteString ?? Routes.guildScheduledEventUsers(guildId, eventId: eventId)
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

    func buildMessagePinsURL(channelId: String, query: MessagePinsQuery) -> String {
        guard var components = URLComponents(string: Routes.messagePins(channelId)) else {
            return Routes.messagePins(channelId)
        }

        var items: [URLQueryItem] = []
        if let before = query.before { items.append(URLQueryItem(name: "before", value: before)) }
        if let limit = query.limit { items.append(URLQueryItem(name: "limit", value: String(limit))) }

        components.queryItems = items.isEmpty ? nil : items
        return components.url?.absoluteString ?? Routes.messagePins(channelId)
    }

    func buildReactionUsersURL(channelId: String, messageId: String, emoji: String, query: ReactionUsersQuery) -> String {
        guard var components = URLComponents(string: Routes.messageReactions(channelId, messageId: messageId, emoji: emoji)) else {
            return Routes.messageReactions(channelId, messageId: messageId, emoji: emoji)
        }

        var items: [URLQueryItem] = []
        if let after = query.after { items.append(URLQueryItem(name: "after", value: after)) }
        if let limit = query.limit { items.append(URLQueryItem(name: "limit", value: String(limit))) }
        if let type = query.type { items.append(URLQueryItem(name: "type", value: String(type.rawValue))) }

        components.queryItems = items.isEmpty ? nil : items
        return components.url?.absoluteString ?? Routes.messageReactions(channelId, messageId: messageId, emoji: emoji)
    }

    func buildArchivedThreadsURL(baseURL: String, query: ArchivedThreadsQuery) -> String {
        guard var components = URLComponents(string: baseURL) else {
            return baseURL
        }

        var items: [URLQueryItem] = []
        if let before = query.before { items.append(URLQueryItem(name: "before", value: before)) }
        if let limit = query.limit { items.append(URLQueryItem(name: "limit", value: String(limit))) }

        components.queryItems = items.isEmpty ? nil : items
        return components.url?.absoluteString ?? baseURL
    }

    func buildThreadMembersURL(channelId: String, query: ThreadMembersQuery) -> String {
        guard var components = URLComponents(string: Routes.threadMembers(channelId)) else {
            return Routes.threadMembers(channelId)
        }

        var items: [URLQueryItem] = []
        if let withMember = query.withMember { items.append(URLQueryItem(name: "with_member", value: withMember ? "true" : "false")) }
        if let after = query.after { items.append(URLQueryItem(name: "after", value: after)) }
        if let limit = query.limit { items.append(URLQueryItem(name: "limit", value: String(limit))) }

        components.queryItems = items.isEmpty ? nil : items
        return components.url?.absoluteString ?? Routes.threadMembers(channelId)
    }

    func buildInviteURL(code: String, query: GetInviteQuery) -> String {
        guard var components = URLComponents(string: Routes.invite(code)) else {
            return Routes.invite(code)
        }

        var items: [URLQueryItem] = []
        if let withCounts = query.withCounts { items.append(URLQueryItem(name: "with_counts", value: withCounts ? "true" : "false")) }
        if let withExpiration = query.withExpiration { items.append(URLQueryItem(name: "with_expiration", value: withExpiration ? "true" : "false")) }
        if let guildScheduledEventId = query.guildScheduledEventId { items.append(URLQueryItem(name: "guild_scheduled_event_id", value: guildScheduledEventId)) }

        components.queryItems = items.isEmpty ? nil : items
        return components.url?.absoluteString ?? Routes.invite(code)
    }

    func buildPollAnswerVotersURL(
        channelId: String,
        messageId: String,
        answerId: String,
        query: PollAnswerVotersQuery
    ) -> String {
        guard var components = URLComponents(string: Routes.pollAnswerVoters(channelId, messageId: messageId, answerId: answerId)) else {
            return Routes.pollAnswerVoters(channelId, messageId: messageId, answerId: answerId)
        }

        var items: [URLQueryItem] = []
        if let after = query.after { items.append(URLQueryItem(name: "after", value: after)) }
        if let limit = query.limit { items.append(URLQueryItem(name: "limit", value: String(limit))) }
        components.queryItems = items.isEmpty ? nil : items
        return components.url?.absoluteString ?? Routes.pollAnswerVoters(channelId, messageId: messageId, answerId: answerId)
    }

    func buildApplicationEntitlementsURL(applicationId: String, query: EntitlementsQuery) -> String {
        guard var components = URLComponents(string: Routes.applicationEntitlements(applicationId)) else {
            return Routes.applicationEntitlements(applicationId)
        }

        var items: [URLQueryItem] = []
        if let userId = query.userId { items.append(URLQueryItem(name: "user_id", value: userId)) }
        if let skuIds = query.skuIds, !skuIds.isEmpty {
            items.append(URLQueryItem(name: "sku_ids", value: skuIds.joined(separator: ",")))
        }
        if let before = query.before { items.append(URLQueryItem(name: "before", value: before)) }
        if let after = query.after { items.append(URLQueryItem(name: "after", value: after)) }
        if let limit = query.limit { items.append(URLQueryItem(name: "limit", value: String(limit))) }
        if let guildId = query.guildId { items.append(URLQueryItem(name: "guild_id", value: guildId)) }
        if let excludeEnded = query.excludeEnded {
            items.append(URLQueryItem(name: "exclude_ended", value: excludeEnded ? "true" : "false"))
        }

        components.queryItems = items.isEmpty ? nil : items
        return components.url?.absoluteString ?? Routes.applicationEntitlements(applicationId)
    }

    func buildExecuteWebhookURL(webhookId: String, token: String, query: ExecuteWebhookQuery) -> String {
        buildExecuteWebhookURL(baseURL: Routes.webhook(webhookId, token: token), query: query)
    }

    func buildExecuteWebhookURL(baseURL: String, query: ExecuteWebhookQuery) -> String {
        guard var components = URLComponents(string: baseURL) else {
            return baseURL
        }

        var items: [URLQueryItem] = []
        if let wait = query.wait { items.append(URLQueryItem(name: "wait", value: wait ? "true" : "false")) }
        if let threadId = query.threadId { items.append(URLQueryItem(name: "thread_id", value: threadId)) }

        components.queryItems = items.isEmpty ? nil : items
        return components.url?.absoluteString ?? baseURL
    }

    func buildWebhookMessageURL(webhookId: String, token: String, messageId: String, query: WebhookMessageQuery) -> String {
        guard var components = URLComponents(string: Routes.webhookMessage(webhookId, token: token, messageId: messageId)) else {
            return Routes.webhookMessage(webhookId, token: token, messageId: messageId)
        }

        var items: [URLQueryItem] = []
        if let threadId = query.threadId { items.append(URLQueryItem(name: "thread_id", value: threadId)) }

        components.queryItems = items.isEmpty ? nil : items
        return components.url?.absoluteString ?? Routes.webhookMessage(webhookId, token: token, messageId: messageId)
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

    func buildInviteMultipartBody(
        boundary: String,
        payload: CreateChannelInvitePayload,
        targetUsersFileData: Data,
        targetUsersFilename: String
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

        append("--\(boundary)\(lineBreak)")
        append("Content-Disposition: form-data; name=\"target_users_file\"; filename=\"\(targetUsersFilename)\"\(lineBreak)")
        append("Content-Type: text/csv\(lineBreak)\(lineBreak)")
        body.append(targetUsersFileData)
        append(lineBreak)

        append("--\(boundary)--\(lineBreak)")
        return body
    }

    func encodeEmojiForPath(_ emoji: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-._~"))
        return emoji.addingPercentEncoding(withAllowedCharacters: allowed) ?? emoji
    }

    func validateComponentLimit(_ components: [ComponentV2Node]) throws {
        let total = components.reduce(into: 0) { partial, node in
            partial += componentCount(node)
        }
        guard total <= 40 else {
            throw DiscordError.invalidRequest(
                message: "Components V2 payload has \(total) components. Discord limit is 40. Reduce panel elements or split into multiple messages."
            )
        }
    }

    func componentCount(_ node: ComponentV2Node) -> Int {
        switch node {
        case .textDisplay:
            return 1
        case .actionRow(let row):
            return 1 + row.components.reduce(into: 0) { partial, component in
                partial += componentCount(component)
            }
        case .section(let section):
            var total = 1 + section.components.reduce(into: 0) { partial, nested in
                partial += componentCount(nested)
            }
            if let accessory = section.accessory {
                total += componentCount(accessory)
            }
            return total
        case .thumbnail:
            return 1
        case .mediaGallery:
            return 1
        case .file:
            return 1
        case .separator:
            return 1
        case .container(let container):
            return 1 + container.components.reduce(into: 0) { partial, nested in
                partial += componentCount(nested)
            }
        }
    }

    func componentCount(_ component: ComponentV2ActionRowComponent) -> Int {
        switch component {
        case .button, .stringSelect, .userSelect, .roleSelect, .mentionableSelect, .channelSelect:
            return 1
        }
    }

    func componentCount(_ accessory: ComponentV2Accessory) -> Int {
        switch accessory {
        case .button, .thumbnail:
            return 1
        }
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
    public let nameLocalized: String?
    public let description: String
    public let descriptionLocalizations: [String: String]?
    public let descriptionLocalized: String?
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
    public let nameLocalized: String?
    public let description: String
    public let descriptionLocalizations: [String: String]?
    public let descriptionLocalized: String?
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
