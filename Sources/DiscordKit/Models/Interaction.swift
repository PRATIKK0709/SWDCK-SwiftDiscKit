import Foundation

public enum InteractionType: Int, Codable, Sendable {
    case ping                            = 1
    case applicationCommand              = 2
    case messageComponent                = 3
    case applicationCommandAutocomplete  = 4
    case modalSubmit                     = 5
    case unknown                         = -1

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
}

public struct InteractionData: Codable, Sendable {
    public let id: String?
    public let name: String?
    public let type: Int?
    public let options: [InteractionOption]?
    public let customId: String?
    public let componentType: Int?
    public let values: [String]?
}

public struct InteractionOption: Codable, Sendable {
    public let name: String
    public let type: Int
    public let value: InteractionOptionValue?
    public let options: [InteractionOption]?

    public var stringValue: String? { value?.stringValue }
    public var intValue: Int?       { value?.intValue }
    public var boolValue: Bool?     { value?.boolValue }
    public var doubleValue: Double? { value?.doubleValue }
}

public enum InteractionOptionValue: Codable, Sendable {
    case string(String)
    case int(Int)
    case bool(Bool)
    case double(Double)

    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let b = try? c.decode(Bool.self)   { self = .bool(b);   return }
        if let i = try? c.decode(Int.self)    { self = .int(i);    return }
        if let d = try? c.decode(Double.self) { self = .double(d); return }
        if let s = try? c.decode(String.self) { self = .string(s); return }
        throw DecodingError.dataCorruptedError(in: c, debugDescription: "Unexpected option value type")
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .string(let v): try c.encode(v)
        case .int(let v):    try c.encode(v)
        case .bool(let v):   try c.encode(v)
        case .double(let v): try c.encode(v)
        }
    }

    public var stringValue: String?  { if case .string(let v) = self { return v }; return nil }
    public var intValue: Int?        { if case .int(let v) = self { return v }; return nil }
    public var boolValue: Bool?      { if case .bool(let v) = self { return v }; return nil }
    public var doubleValue: Double?  { if case .double(let v) = self { return v }; return nil }
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

    func option(_ name: String) -> InteractionOption? {
        data?.options?.first { $0.name == name }
    }
}


struct InteractionResponse: Encodable {
    let type: Int
    let data: InteractionCallbackData?

    static func channelMessage(content: String, ephemeral: Bool) -> InteractionResponse {
        InteractionResponse(
            type: 4,
            data: InteractionCallbackData(
                content: content,
                flags: ephemeral ? 64 : nil,
                embeds: nil,
                components: nil
            )
        )
    }

    static func deferred(ephemeral: Bool) -> InteractionResponse {
        InteractionResponse(
            type: 5,
            data: ephemeral ? InteractionCallbackData(content: nil, flags: 64, embeds: nil, components: nil) : nil
        )
    }

    static func componentsV2(components: [ComponentV2Node], ephemeral: Bool) -> InteractionResponse {
        let flags = DiscordMessageFlags.isComponentsV2 | (ephemeral ? DiscordMessageFlags.ephemeral : 0)
        return InteractionResponse(
            type: 4,
            data: InteractionCallbackData(
                content: nil,
                flags: flags,
                embeds: nil,
                components: components
            )
        )
    }
}

struct InteractionCallbackData: Encodable {
    let content: String?
    let flags: Int?
    let embeds: [Embed]?
    let components: [ComponentV2Node]?
}
