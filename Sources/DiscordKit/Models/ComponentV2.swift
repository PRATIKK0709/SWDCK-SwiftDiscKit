import Foundation

public enum DiscordMessageFlags {
    public static let ephemeral = 1 << 6
    public static let isComponentsV2 = 1 << 15
}

public struct DiscordFileUpload: Sendable {
    public let filename: String
    public let data: Data
    public let contentType: String
    public let description: String?

    public init(
        filename: String,
        data: Data,
        contentType: String = "application/octet-stream",
        description: String? = nil
    ) {
        self.filename = filename
        self.data = data
        self.contentType = contentType
        self.description = description
    }
}

public enum DiscordComponentType: Int, Codable, Sendable {
    case actionRow = 1
    case button = 2
    case stringSelect = 3
    case textInput = 4
    case userSelect = 5
    case roleSelect = 6
    case mentionableSelect = 7
    case channelSelect = 8
    case section = 9
    case textDisplay = 10
    case thumbnail = 11
    case mediaGallery = 12
    case file = 13
    case separator = 14
    case container = 17
    case label = 18
}

public enum DiscordButtonStyle: Int, Codable, Sendable {
    case primary = 1
    case secondary = 2
    case success = 3
    case danger = 4
    case link = 5
    case premium = 6
}

public struct ComponentV2UnfurledMediaItem: Encodable, Sendable {
    public let url: String

    public init(url: String) {
        self.url = url
    }
}

public struct ComponentV2TextDisplay: Encodable, Sendable {
    public let type: Int = DiscordComponentType.textDisplay.rawValue
    public let content: String

    public init(_ content: String) {
        self.content = content
    }
}

public struct ComponentV2Media: Encodable, Sendable {
    public let url: String

    public init(url: String) {
        self.url = url
    }
}

public struct ComponentV2Thumbnail: Encodable, Sendable {
    public let type: Int = DiscordComponentType.thumbnail.rawValue
    public let media: ComponentV2Media
    public let description: String?
    public let spoiler: Bool?

    public init(media: ComponentV2Media, description: String? = nil, spoiler: Bool? = nil) {
        self.media = media
        self.description = description
        self.spoiler = spoiler
    }
}

public struct ComponentV2MediaGalleryItem: Encodable, Sendable {
    public let media: ComponentV2UnfurledMediaItem
    public let description: String?
    public let spoiler: Bool?

    public init(media: ComponentV2UnfurledMediaItem, description: String? = nil, spoiler: Bool? = nil) {
        self.media = media
        self.description = description
        self.spoiler = spoiler
    }
}

public struct ComponentV2MediaGallery: Encodable, Sendable {
    public let type: Int = DiscordComponentType.mediaGallery.rawValue
    public let items: [ComponentV2MediaGalleryItem]

    public init(items: [ComponentV2MediaGalleryItem]) {
        self.items = items
    }
}

public struct ComponentV2File: Encodable, Sendable {
    public let type: Int = DiscordComponentType.file.rawValue
    public let file: ComponentV2UnfurledMediaItem
    public let spoiler: Bool?

    public init(file: ComponentV2UnfurledMediaItem, spoiler: Bool? = nil) {
        self.file = file
        self.spoiler = spoiler
    }
}

public struct ComponentV2Separator: Encodable, Sendable {
    public let type: Int = DiscordComponentType.separator.rawValue
    public let divider: Bool?
    public let spacing: Int?

    public init(divider: Bool? = nil, spacing: Int? = nil) {
        self.divider = divider
        self.spacing = spacing
    }
}

public struct ComponentV2Button: Encodable, Sendable {
    public let type: Int = DiscordComponentType.button.rawValue
    public let style: Int
    public let label: String?
    public let customId: String?
    public let url: String?
    public let disabled: Bool?

    public init(
        style: DiscordButtonStyle,
        label: String? = nil,
        customId: String? = nil,
        url: String? = nil,
        disabled: Bool? = nil
    ) {
        self.style = style.rawValue
        self.label = label
        self.customId = customId
        self.url = url
        self.disabled = disabled
    }
}

public struct ComponentV2SelectOption: Encodable, Sendable {
    public let label: String
    public let value: String
    public let description: String?
    public let `default`: Bool?

    public init(label: String, value: String, description: String? = nil, default: Bool? = nil) {
        self.label = label
        self.value = value
        self.description = description
        self.default = `default`
    }
}

public struct ComponentV2StringSelect: Encodable, Sendable {
    public let type: Int = DiscordComponentType.stringSelect.rawValue
    public let customId: String
    public let options: [ComponentV2SelectOption]
    public let placeholder: String?
    public let minValues: Int?
    public let maxValues: Int?
    public let disabled: Bool?

    public init(
        customId: String,
        options: [ComponentV2SelectOption],
        placeholder: String? = nil,
        minValues: Int? = nil,
        maxValues: Int? = nil,
        disabled: Bool? = nil
    ) {
        self.customId = customId
        self.options = options
        self.placeholder = placeholder
        self.minValues = minValues
        self.maxValues = maxValues
        self.disabled = disabled
    }
}

public struct ComponentV2UserSelect: Encodable, Sendable {
    public let type: Int = DiscordComponentType.userSelect.rawValue
    public let customId: String
    public let placeholder: String?
    public let minValues: Int?
    public let maxValues: Int?
    public let disabled: Bool?

    public init(
        customId: String,
        placeholder: String? = nil,
        minValues: Int? = nil,
        maxValues: Int? = nil,
        disabled: Bool? = nil
    ) {
        self.customId = customId
        self.placeholder = placeholder
        self.minValues = minValues
        self.maxValues = maxValues
        self.disabled = disabled
    }
}

public struct ComponentV2RoleSelect: Encodable, Sendable {
    public let type: Int = DiscordComponentType.roleSelect.rawValue
    public let customId: String
    public let placeholder: String?
    public let minValues: Int?
    public let maxValues: Int?
    public let disabled: Bool?

    public init(
        customId: String,
        placeholder: String? = nil,
        minValues: Int? = nil,
        maxValues: Int? = nil,
        disabled: Bool? = nil
    ) {
        self.customId = customId
        self.placeholder = placeholder
        self.minValues = minValues
        self.maxValues = maxValues
        self.disabled = disabled
    }
}

public struct ComponentV2MentionableSelect: Encodable, Sendable {
    public let type: Int = DiscordComponentType.mentionableSelect.rawValue
    public let customId: String
    public let placeholder: String?
    public let minValues: Int?
    public let maxValues: Int?
    public let disabled: Bool?

    public init(
        customId: String,
        placeholder: String? = nil,
        minValues: Int? = nil,
        maxValues: Int? = nil,
        disabled: Bool? = nil
    ) {
        self.customId = customId
        self.placeholder = placeholder
        self.minValues = minValues
        self.maxValues = maxValues
        self.disabled = disabled
    }
}

public struct ComponentV2ChannelSelect: Encodable, Sendable {
    public let type: Int = DiscordComponentType.channelSelect.rawValue
    public let customId: String
    public let channelTypes: [Int]?
    public let placeholder: String?
    public let minValues: Int?
    public let maxValues: Int?
    public let disabled: Bool?

    public init(
        customId: String,
        channelTypes: [Int]? = nil,
        placeholder: String? = nil,
        minValues: Int? = nil,
        maxValues: Int? = nil,
        disabled: Bool? = nil
    ) {
        self.customId = customId
        self.channelTypes = channelTypes
        self.placeholder = placeholder
        self.minValues = minValues
        self.maxValues = maxValues
        self.disabled = disabled
    }
}

public enum ComponentV2Accessory: Encodable, Sendable {
    case button(ComponentV2Button)
    case thumbnail(ComponentV2Thumbnail)

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .button(let button):
            try button.encode(to: encoder)
        case .thumbnail(let thumbnail):
            try thumbnail.encode(to: encoder)
        }
    }
}

public enum ComponentV2ActionRowComponent: Encodable, Sendable {
    case button(ComponentV2Button)
    case stringSelect(ComponentV2StringSelect)
    case userSelect(ComponentV2UserSelect)
    case roleSelect(ComponentV2RoleSelect)
    case mentionableSelect(ComponentV2MentionableSelect)
    case channelSelect(ComponentV2ChannelSelect)

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .button(let component):
            try component.encode(to: encoder)
        case .stringSelect(let component):
            try component.encode(to: encoder)
        case .userSelect(let component):
            try component.encode(to: encoder)
        case .roleSelect(let component):
            try component.encode(to: encoder)
        case .mentionableSelect(let component):
            try component.encode(to: encoder)
        case .channelSelect(let component):
            try component.encode(to: encoder)
        }
    }
}

public struct ComponentV2ActionRow: Encodable, Sendable {
    public let type: Int = DiscordComponentType.actionRow.rawValue
    public let components: [ComponentV2ActionRowComponent]

    public init(components: [ComponentV2ActionRowComponent]) {
        self.components = components
    }
}

public struct ComponentV2Section: Encodable, Sendable {
    public let type: Int = DiscordComponentType.section.rawValue
    public let components: [ComponentV2Node]
    public let accessory: ComponentV2Accessory?

    public init(components: [ComponentV2Node], accessory: ComponentV2Accessory? = nil) {
        self.components = components
        self.accessory = accessory
    }
}

public struct ComponentV2Container: Encodable, Sendable {
    public let type: Int = DiscordComponentType.container.rawValue
    public let accentColor: Int?
    public let spoiler: Bool?
    public let components: [ComponentV2Node]

    public init(accentColor: Int? = nil, spoiler: Bool? = nil, components: [ComponentV2Node]) {
        self.accentColor = accentColor
        self.spoiler = spoiler
        self.components = components
    }
}

public enum ComponentV2Node: Encodable, Sendable {
    case textDisplay(ComponentV2TextDisplay)
    case actionRow(ComponentV2ActionRow)
    case section(ComponentV2Section)
    case thumbnail(ComponentV2Thumbnail)
    case mediaGallery(ComponentV2MediaGallery)
    case file(ComponentV2File)
    case separator(ComponentV2Separator)
    case container(ComponentV2Container)

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .textDisplay(let component):
            try component.encode(to: encoder)
        case .actionRow(let component):
            try component.encode(to: encoder)
        case .section(let component):
            try component.encode(to: encoder)
        case .thumbnail(let component):
            try component.encode(to: encoder)
        case .mediaGallery(let component):
            try component.encode(to: encoder)
        case .file(let component):
            try component.encode(to: encoder)
        case .separator(let component):
            try component.encode(to: encoder)
        case .container(let component):
            try component.encode(to: encoder)
        }
    }
}
