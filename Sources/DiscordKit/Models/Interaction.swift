import Foundation

public enum InteractionType: Int, Codable, Sendable {
    case ping = 1
    case applicationCommand = 2
    case messageComponent = 3
    case applicationCommandAutocomplete = 4
    case modalSubmit = 5
    case unknown = -1

    public init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(Int.self)
        self = InteractionType(rawValue: raw) ?? .unknown
    }
}

public struct Interaction: Codable, Sendable, Identifiable {
    public let id: String
    public let applicationId: String
    public let type: InteractionType
    public let data: InteractionData?
    public let guildId: String?
    public let channelId: String?
    public let member: GuildMember?
    public let user: DiscordUser?
    public let token: String
    public let version: Int

    public var invoker: DiscordUser? {
        user ?? member?.user
    }

    var _rest: RESTClient?

    enum CodingKeys: String, CodingKey {
        case id, applicationId, type, data, guildId, channelId, member, user, token, version
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeStringLossy(forKey: .id)
        self.applicationId = try container.decodeStringLossy(forKey: .applicationId)
        self.type = (try? container.decode(InteractionType.self, forKey: .type)) ?? .unknown
        self.data = try? container.decodeIfPresent(InteractionData.self, forKey: .data)
        self.guildId = container.decodeStringLossyIfPresent(forKey: .guildId)
        self.channelId = container.decodeStringLossyIfPresent(forKey: .channelId)
        self.member = try? container.decodeIfPresent(GuildMember.self, forKey: .member)
        self.user = try? container.decodeIfPresent(DiscordUser.self, forKey: .user)
        self.token = try container.decodeStringLossy(forKey: .token)
        self.version = container.decodeIntLossyIfPresent(forKey: .version) ?? 1
        self._rest = nil
    }
}

public struct InteractionData: Codable, Sendable {
    public let id: String?
    public let name: String?
    public let type: Int?
    public let options: [InteractionOption]?
    public let customId: String?
    public let componentType: Int?
    public let values: [String]?
    public let value: InteractionOptionValue?
    public let components: [InteractionSubmittedContainer]?
    public let resolved: InteractionResolvedData?

    enum CodingKeys: String, CodingKey {
        case id, name, type, options, customId, componentType, values, value, components, resolved
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = container.decodeStringLossyIfPresent(forKey: .id)
        self.name = try? container.decodeIfPresent(String.self, forKey: .name)
        self.type = container.decodeIntLossyIfPresent(forKey: .type)
        self.options = try? container.decodeIfPresent([InteractionOption].self, forKey: .options)
        self.customId = container.decodeStringLossyIfPresent(forKey: .customId)
        self.componentType = container.decodeIntLossyIfPresent(forKey: .componentType)
        self.values = container.decodeStringArrayLossyIfPresent(forKey: .values)
        self.value = try? container.decodeIfPresent(InteractionOptionValue.self, forKey: .value)
        self.components = try? container.decodeIfPresent([InteractionSubmittedContainer].self, forKey: .components)
        self.resolved = try? container.decodeIfPresent(InteractionResolvedData.self, forKey: .resolved)
    }

    public var submittedComponents: [InteractionSubmittedComponent] {
        components?.compactMap(\.component) ?? []
    }

    public func submittedComponent(customId: String) -> InteractionSubmittedComponent? {
        submittedComponents.first { $0.customId == customId }
    }

    public func submittedValues(customId: String) -> [String]? {
        if self.customId == customId {
            return values
        }
        return submittedComponent(customId: customId)?.values
    }

    public func submittedValue(customId: String) -> InteractionOptionValue? {
        if self.customId == customId {
            return value
        }
        return submittedComponent(customId: customId)?.value
    }

    public func submittedAttachments(customId: String) -> [InteractionResolvedAttachment] {
        guard let ids = submittedValues(customId: customId), let attachments = resolved?.attachments else {
            return []
        }
        return ids.compactMap { attachments[$0] }
    }
}

public struct InteractionSubmittedContainer: Codable, Sendable {
    public let id: Int?
    public let type: Int?
    public let component: InteractionSubmittedComponent?

    enum CodingKeys: String, CodingKey {
        case id, type, component
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = container.decodeIntLossyIfPresent(forKey: .id)
        self.type = container.decodeIntLossyIfPresent(forKey: .type)
        self.component = try? container.decodeIfPresent(InteractionSubmittedComponent.self, forKey: .component)
    }
}

public struct InteractionSubmittedComponent: Codable, Sendable {
    public let id: Int?
    public let type: Int?
    public let customId: String?
    public let values: [String]?
    public let value: InteractionOptionValue?

    enum CodingKeys: String, CodingKey {
        case id, type, customId, values, value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = container.decodeIntLossyIfPresent(forKey: .id)
        self.type = container.decodeIntLossyIfPresent(forKey: .type)
        self.customId = container.decodeStringLossyIfPresent(forKey: .customId)
        self.values = container.decodeStringArrayLossyIfPresent(forKey: .values)
        self.value = try? container.decodeIfPresent(InteractionOptionValue.self, forKey: .value)
    }
}

public struct InteractionResolvedData: Codable, Sendable {
    public let users: [String: DiscordUser]?
    public let members: [String: GuildMember]?
    public let roles: [String: InteractionResolvedRole]?
    public let channels: [String: InteractionResolvedChannel]?
    public let attachments: [String: InteractionResolvedAttachment]?
}

public struct InteractionResolvedRole: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String?
}

public struct InteractionResolvedChannel: Codable, Sendable, Identifiable {
    public let id: String
    public let type: Int?
    public let name: String?
}

public struct InteractionResolvedAttachment: Codable, Sendable, Identifiable {
    public let id: String
    public let filename: String
    public let contentType: String?
    public let size: Int?
    public let url: String?
    public let proxyUrl: String?
    public let width: Int?
    public let height: Int?
    public let ephemeral: Bool?
}

public struct InteractionOption: Codable, Sendable {
    public let name: String
    public let type: Int
    public let value: InteractionOptionValue?
    public let options: [InteractionOption]?

    enum CodingKeys: String, CodingKey {
        case name, type, value, options
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = (try? container.decodeStringLossy(forKey: .name)) ?? "unknown"
        self.type = container.decodeIntLossyIfPresent(forKey: .type) ?? 0
        self.value = try? container.decodeIfPresent(InteractionOptionValue.self, forKey: .value)
        self.options = try? container.decodeIfPresent([InteractionOption].self, forKey: .options)
    }

    public var stringValue: String? { value?.stringValue }
    public var intValue: Int? { value?.intValue }
    public var boolValue: Bool? { value?.boolValue }
    public var doubleValue: Double? { value?.doubleValue }
}

private extension KeyedDecodingContainer {
    func decodeStringLossy(forKey key: Key) throws -> String {
        if let stringValue = try? decode(String.self, forKey: key) {
            return stringValue
        }
        if let intValue = try? decode(Int.self, forKey: key) {
            return String(intValue)
        }
        if let doubleValue = try? decode(Double.self, forKey: key) {
            return String(doubleValue)
        }
        if let boolValue = try? decode(Bool.self, forKey: key) {
            return boolValue ? "true" : "false"
        }
        throw DecodingError.dataCorruptedError(
            forKey: key,
            in: self,
            debugDescription: "Expected string-compatible value"
        )
    }

    func decodeStringLossyIfPresent(forKey key: Key) -> String? {
        guard contains(key) else { return nil }
        return try? decodeStringLossy(forKey: key)
    }

    func decodeIntLossyIfPresent(forKey key: Key) -> Int? {
        if let intValue = try? decodeIfPresent(Int.self, forKey: key) {
            return intValue
        }
        if let stringValue = try? decodeIfPresent(String.self, forKey: key) {
            return Int(stringValue)
        }
        if let doubleValue = try? decodeIfPresent(Double.self, forKey: key) {
            return Int(doubleValue)
        }
        return nil
    }

    func decodeStringArrayLossyIfPresent(forKey key: Key) -> [String]? {
        if let stringValues = try? decodeIfPresent([String].self, forKey: key) {
            return stringValues
        }
        if let intValues = try? decodeIfPresent([Int].self, forKey: key) {
            return intValues.map(String.init)
        }
        if let doubleValues = try? decodeIfPresent([Double].self, forKey: key) {
            return doubleValues.map { String($0) }
        }
        if let boolValues = try? decodeIfPresent([Bool].self, forKey: key) {
            return boolValues.map { $0 ? "true" : "false" }
        }
        return nil
    }
}

public enum InteractionOptionValue: Codable, Sendable {
    case string(String)
    case int(Int)
    case bool(Bool)
    case double(Double)

    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let b = try? c.decode(Bool.self) { self = .bool(b); return }
        if let i = try? c.decode(Int.self) { self = .int(i); return }
        if let d = try? c.decode(Double.self) { self = .double(d); return }
        if let s = try? c.decode(String.self) { self = .string(s); return }
        throw DecodingError.dataCorruptedError(in: c, debugDescription: "Unexpected option value type")
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .string(let v):
            try c.encode(v)
        case .int(let v):
            try c.encode(v)
        case .bool(let v):
            try c.encode(v)
        case .double(let v):
            try c.encode(v)
        }
    }

    public var stringValue: String? { if case .string(let v) = self { return v }; return nil }
    public var intValue: Int? { if case .int(let v) = self { return v }; return nil }
    public var boolValue: Bool? { if case .bool(let v) = self { return v }; return nil }
    public var doubleValue: Double? { if case .double(let v) = self { return v }; return nil }
}

public extension Interaction {
    func respond(_ content: String, ephemeral: Bool = false) async throws {
        guard let rest = _rest else {
            throw DiscordError.unknown("Interaction has no REST client.")
        }
        try await rest.createInteractionResponse(
            interactionId: id,
            token: token,
            response: InteractionResponse.channelMessage(content: content, ephemeral: ephemeral)
        )
    }

    func respondComponentsV2(_ components: [ComponentV2Node], ephemeral: Bool = false) async throws {
        guard let rest = _rest else {
            throw DiscordError.unknown("Interaction has no REST client.")
        }
        try await rest.createInteractionResponse(
            interactionId: id,
            token: token,
            response: InteractionResponse.componentsV2(components: components, ephemeral: ephemeral)
        )
    }

    func presentModal(customId: String, title: String, components: [ComponentV2Label]) async throws {
        guard let rest = _rest else {
            throw DiscordError.unknown("Interaction has no REST client.")
        }
        try await rest.createInteractionResponse(
            interactionId: id,
            token: token,
            response: InteractionResponse.modal(customId: customId, title: title, components: components)
        )
    }

    func defer_(ephemeral: Bool = false) async throws {
        guard let rest = _rest else {
            throw DiscordError.unknown("Interaction has no REST client.")
        }
        try await rest.createInteractionResponse(
            interactionId: id,
            token: token,
            response: InteractionResponse.deferred(ephemeral: ephemeral)
        )
    }

    @discardableResult
    func editResponse(_ content: String) async throws -> Message {
        guard let rest = _rest else {
            throw DiscordError.unknown("Interaction has no REST client.")
        }
        return try await rest.editInteractionResponse(
            applicationId: applicationId,
            token: token,
            content: content
        )
    }

    @discardableResult
    func getOriginalResponse() async throws -> Message {
        guard let rest = _rest else {
            throw DiscordError.unknown("Interaction has no REST client.")
        }
        return try await rest.getOriginalInteractionResponse(
            applicationId: applicationId,
            token: token
        )
    }

    func deleteOriginalResponse() async throws {
        guard let rest = _rest else {
            throw DiscordError.unknown("Interaction has no REST client.")
        }
        try await rest.deleteOriginalInteractionResponse(
            applicationId: applicationId,
            token: token
        )
    }

    @discardableResult
    func followUp(_ content: String, ephemeral: Bool = false) async throws -> Message {
        guard let rest = _rest else {
            throw DiscordError.unknown("Interaction has no REST client.")
        }
        return try await rest.createFollowup(
            applicationId: applicationId,
            token: token,
            content: content,
            ephemeral: ephemeral
        )
    }

    @discardableResult
    func getFollowUp(messageId: String) async throws -> Message {
        guard let rest = _rest else {
            throw DiscordError.unknown("Interaction has no REST client.")
        }
        return try await rest.getFollowupMessage(
            applicationId: applicationId,
            token: token,
            messageId: messageId
        )
    }

    @discardableResult
    func editFollowUp(messageId: String, content: String) async throws -> Message {
        guard let rest = _rest else {
            throw DiscordError.unknown("Interaction has no REST client.")
        }
        return try await rest.editFollowupMessage(
            applicationId: applicationId,
            token: token,
            messageId: messageId,
            content: content
        )
    }

    func deleteFollowUp(messageId: String) async throws {
        guard let rest = _rest else {
            throw DiscordError.unknown("Interaction has no REST client.")
        }
        try await rest.deleteFollowupMessage(
            applicationId: applicationId,
            token: token,
            messageId: messageId
        )
    }

    func option(_ name: String) -> InteractionOption? {
        data?.options?.first { $0.name == name }
    }
}

struct InteractionResponse: Encodable {
    let type: Int
    let data: InteractionResponseData?

    static func channelMessage(content: String, ephemeral: Bool) -> InteractionResponse {
        InteractionResponse(
            type: 4,
            data: .message(
                InteractionMessageCallbackData(
                    content: content,
                    flags: ephemeral ? 64 : nil,
                    embeds: nil,
                    components: nil
                )
            )
        )
    }

    static func deferred(ephemeral: Bool) -> InteractionResponse {
        InteractionResponse(
            type: 5,
            data: ephemeral ? .message(InteractionMessageCallbackData(content: nil, flags: 64, embeds: nil, components: nil)) : nil
        )
    }

    static func componentsV2(components: [ComponentV2Node], ephemeral: Bool) -> InteractionResponse {
        let flags = DiscordMessageFlags.isComponentsV2 | (ephemeral ? DiscordMessageFlags.ephemeral : 0)
        return InteractionResponse(
            type: 4,
            data: .message(
                InteractionMessageCallbackData(
                    content: nil,
                    flags: flags,
                    embeds: nil,
                    components: components
                )
            )
        )
    }

    static func modal(customId: String, title: String, components: [ComponentV2Label]) -> InteractionResponse {
        InteractionResponse(
            type: 9,
            data: .modal(
                InteractionModalCallbackData(
                    customId: customId,
                    title: title,
                    components: components
                )
            )
        )
    }
}

enum InteractionResponseData: Encodable {
    case message(InteractionMessageCallbackData)
    case modal(InteractionModalCallbackData)

    func encode(to encoder: Encoder) throws {
        switch self {
        case .message(let payload):
            try payload.encode(to: encoder)
        case .modal(let payload):
            try payload.encode(to: encoder)
        }
    }
}

struct InteractionMessageCallbackData: Encodable {
    let content: String?
    let flags: Int?
    let embeds: [Embed]?
    let components: [ComponentV2Node]?
}

struct InteractionModalCallbackData: Encodable {
    let customId: String
    let title: String
    let components: [ComponentV2Label]
}
