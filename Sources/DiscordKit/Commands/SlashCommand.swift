import Foundation

public enum CommandOptionType: Int, Encodable, Sendable {
    case subCommand      = 1
    case subCommandGroup = 2
    case string          = 3
    case integer         = 4
    case boolean         = 5
    case user            = 6
    case channel         = 7
    case role            = 8
    case mentionable     = 9
    case number          = 10
    case attachment      = 11
}

public struct CommandOption: Encodable, Sendable {
    public let type: Int
    public let name: String
    public let description: String
    public let required: Bool
    public let choices: [CommandChoice]?

    public init(
        type: CommandOptionType,
        name: String,
        description: String,
        required: Bool = false,
        choices: [CommandChoice]? = nil
    ) {
        self.type = type.rawValue
        self.name = name
        self.description = description
        self.required = required
        self.choices = choices
    }


    public static func string(
        _ name: String,
        description: String,
        required: Bool = false,
        choices: [CommandChoice]? = nil
    ) -> CommandOption {
        CommandOption(type: .string, name: name, description: description, required: required, choices: choices)
    }

    public static func integer(
        _ name: String,
        description: String,
        required: Bool = false
    ) -> CommandOption {
        CommandOption(type: .integer, name: name, description: description, required: required)
    }

    public static func boolean(
        _ name: String,
        description: String,
        required: Bool = false
    ) -> CommandOption {
        CommandOption(type: .boolean, name: name, description: description, required: required)
    }

    public static func user(
        _ name: String,
        description: String,
        required: Bool = false
    ) -> CommandOption {
        CommandOption(type: .user, name: name, description: description, required: required)
    }

    public static func channel(
        _ name: String,
        description: String,
        required: Bool = false
    ) -> CommandOption {
        CommandOption(type: .channel, name: name, description: description, required: required)
    }

    public static func role(
        _ name: String,
        description: String,
        required: Bool = false
    ) -> CommandOption {
        CommandOption(type: .role, name: name, description: description, required: required)
    }

    public static func mentionable(
        _ name: String,
        description: String,
        required: Bool = false
    ) -> CommandOption {
        CommandOption(type: .mentionable, name: name, description: description, required: required)
    }

    public static func number(
        _ name: String,
        description: String,
        required: Bool = false
    ) -> CommandOption {
        CommandOption(type: .number, name: name, description: description, required: required)
    }

    public static func attachment(
        _ name: String,
        description: String,
        required: Bool = false
    ) -> CommandOption {
        CommandOption(type: .attachment, name: name, description: description, required: required)
    }
}

public struct CommandChoice: Encodable, Sendable {
    public let name: String
    public let value: CommandChoiceValue

    public init(name: String, value: String) {
        self.name = name
        self.value = .string(value)
    }

    public init(name: String, value: Int) {
        self.name = name
        self.value = .int(value)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        switch value {
        case .string(let v): try container.encode(v, forKey: .value)
        case .int(let v):    try container.encode(v, forKey: .value)
        }
    }

    private enum CodingKeys: String, CodingKey { case name, value }
}

public enum CommandChoiceValue: Sendable {
    case string(String)
    case int(Int)
}

public struct SlashCommandDefinition: Encodable, Sendable {
    public let name: String
    public let description: String
    public let options: [CommandOption]?
    public let type: Int = 1  // CHAT_INPUT

    public init(name: String, description: String, options: [CommandOption]? = nil) {
        self.name = name
        self.description = description
        self.options = options
    }
}

struct SlashCommandHandler: Sendable {
    let definition: SlashCommandDefinition
    let handler: @Sendable (Interaction) async throws -> Void
}
