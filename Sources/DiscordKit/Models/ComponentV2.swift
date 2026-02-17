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
    case contentInventoryEntry = 16
    case container = 17
    case label = 18
    case fileUpload = 19
    case radioGroup = 21
    case checkboxGroup = 22
    case checkbox = 23
}

public enum DiscordButtonStyle: Int, Codable, Sendable {
    case primary = 1
    case secondary = 2
    case success = 3
    case danger = 4
    case link = 5
    case premium = 6
}

public enum DiscordTextInputStyle: Int, Codable, Sendable {
    case short = 1
    case paragraph = 2
}

public enum DiscordSelectDefaultValueType: String, Codable, Sendable {
    case user
    case role
    case channel
}

public struct ComponentV2Emoji: Encodable, Sendable {
    public let id: String?
    public let name: String?
    public let animated: Bool?

    public init(id: String? = nil, name: String? = nil, animated: Bool? = nil) {
        self.id = id
        self.name = name
        self.animated = animated
    }
}

public struct ComponentV2SelectDefaultValue: Encodable, Sendable {
    public let id: String
    public let type: DiscordSelectDefaultValueType

    public init(id: String, type: DiscordSelectDefaultValueType) {
        self.id = id
        self.type = type
    }
}

public struct ComponentV2UnfurledMediaItem: Encodable, Sendable {
    public let url: String

    public init(url: String) {
        self.url = url
    }
}

public struct ComponentV2Media: Encodable, Sendable {
    public let url: String

    public init(url: String) {
        self.url = url
    }
}

public struct ComponentV2TextDisplay: Encodable, Sendable {
    public let type: Int = DiscordComponentType.textDisplay.rawValue
    public let id: Int?
    public let content: String

    public init(id: Int? = nil, _ content: String) {
        self.id = id
        self.content = content
    }
}

public struct ComponentV2Thumbnail: Encodable, Sendable {
    public let type: Int = DiscordComponentType.thumbnail.rawValue
    public let id: Int?
    public let media: ComponentV2Media
    public let description: String?
    public let spoiler: Bool?

    public init(
        id: Int? = nil,
        media: ComponentV2Media,
        description: String? = nil,
        spoiler: Bool? = nil
    ) {
        self.id = id
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
    public let id: Int?
    public let items: [ComponentV2MediaGalleryItem]

    public init(id: Int? = nil, items: [ComponentV2MediaGalleryItem]) {
        self.id = id
        self.items = items
    }
}

public struct ComponentV2File: Encodable, Sendable {
    public let type: Int = DiscordComponentType.file.rawValue
    public let id: Int?
    public let file: ComponentV2UnfurledMediaItem
    public let spoiler: Bool?

    public init(id: Int? = nil, file: ComponentV2UnfurledMediaItem, spoiler: Bool? = nil) {
        self.id = id
        self.file = file
        self.spoiler = spoiler
    }
}

public struct ComponentV2Separator: Encodable, Sendable {
    public let type: Int = DiscordComponentType.separator.rawValue
    public let id: Int?
    public let divider: Bool?
    public let spacing: Int?

    public init(id: Int? = nil, divider: Bool? = nil, spacing: Int? = nil) {
        self.id = id
        self.divider = divider
        self.spacing = spacing
    }
}

public struct ComponentV2Button: Encodable, Sendable {
    public let type: Int = DiscordComponentType.button.rawValue
    public let id: Int?
    public let style: Int
    public let label: String?
    public let emoji: ComponentV2Emoji?
    public let customId: String?
    public let skuId: String?
    public let url: String?
    public let disabled: Bool?

    public init(
        id: Int? = nil,
        style: DiscordButtonStyle,
        label: String? = nil,
        emoji: ComponentV2Emoji? = nil,
        customId: String? = nil,
        skuId: String? = nil,
        url: String? = nil,
        disabled: Bool? = nil
    ) {
        self.id = id
        self.style = style.rawValue
        self.label = label
        self.emoji = emoji
        self.customId = customId
        self.skuId = skuId
        self.url = url
        self.disabled = disabled
    }
}

public struct ComponentV2SelectOption: Encodable, Sendable {
    public let label: String
    public let value: String
    public let description: String?
    public let emoji: ComponentV2Emoji?
    public let `default`: Bool?

    public init(
        label: String,
        value: String,
        description: String? = nil,
        emoji: ComponentV2Emoji? = nil,
        default: Bool? = nil
    ) {
        self.label = label
        self.value = value
        self.description = description
        self.emoji = emoji
        self.default = `default`
    }
}

public struct ComponentV2StringSelect: Encodable, Sendable {
    public let type: Int = DiscordComponentType.stringSelect.rawValue
    public let id: Int?
    public let customId: String
    public let options: [ComponentV2SelectOption]
    public let placeholder: String?
    public let minValues: Int?
    public let maxValues: Int?
    public let disabled: Bool?
    public let required: Bool?

    public init(
        id: Int? = nil,
        customId: String,
        options: [ComponentV2SelectOption],
        placeholder: String? = nil,
        minValues: Int? = nil,
        maxValues: Int? = nil,
        disabled: Bool? = nil,
        required: Bool? = nil
    ) {
        self.id = id
        self.customId = customId
        self.options = options
        self.placeholder = placeholder
        self.minValues = minValues
        self.maxValues = maxValues
        self.disabled = disabled
        self.required = required
    }
}

public struct ComponentV2UserSelect: Encodable, Sendable {
    public let type: Int = DiscordComponentType.userSelect.rawValue
    public let id: Int?
    public let customId: String
    public let placeholder: String?
    public let minValues: Int?
    public let maxValues: Int?
    public let defaultValues: [ComponentV2SelectDefaultValue]?
    public let disabled: Bool?
    public let required: Bool?

    public init(
        id: Int? = nil,
        customId: String,
        placeholder: String? = nil,
        minValues: Int? = nil,
        maxValues: Int? = nil,
        defaultValues: [ComponentV2SelectDefaultValue]? = nil,
        disabled: Bool? = nil,
        required: Bool? = nil
    ) {
        self.id = id
        self.customId = customId
        self.placeholder = placeholder
        self.minValues = minValues
        self.maxValues = maxValues
        self.defaultValues = defaultValues
        self.disabled = disabled
        self.required = required
    }
}

public struct ComponentV2RoleSelect: Encodable, Sendable {
    public let type: Int = DiscordComponentType.roleSelect.rawValue
    public let id: Int?
    public let customId: String
    public let placeholder: String?
    public let minValues: Int?
    public let maxValues: Int?
    public let defaultValues: [ComponentV2SelectDefaultValue]?
    public let disabled: Bool?
    public let required: Bool?

    public init(
        id: Int? = nil,
        customId: String,
        placeholder: String? = nil,
        minValues: Int? = nil,
        maxValues: Int? = nil,
        defaultValues: [ComponentV2SelectDefaultValue]? = nil,
        disabled: Bool? = nil,
        required: Bool? = nil
    ) {
        self.id = id
        self.customId = customId
        self.placeholder = placeholder
        self.minValues = minValues
        self.maxValues = maxValues
        self.defaultValues = defaultValues
        self.disabled = disabled
        self.required = required
    }
}

public struct ComponentV2MentionableSelect: Encodable, Sendable {
    public let type: Int = DiscordComponentType.mentionableSelect.rawValue
    public let id: Int?
    public let customId: String
    public let placeholder: String?
    public let minValues: Int?
    public let maxValues: Int?
    public let defaultValues: [ComponentV2SelectDefaultValue]?
    public let disabled: Bool?
    public let required: Bool?

    public init(
        id: Int? = nil,
        customId: String,
        placeholder: String? = nil,
        minValues: Int? = nil,
        maxValues: Int? = nil,
        defaultValues: [ComponentV2SelectDefaultValue]? = nil,
        disabled: Bool? = nil,
        required: Bool? = nil
    ) {
        self.id = id
        self.customId = customId
        self.placeholder = placeholder
        self.minValues = minValues
        self.maxValues = maxValues
        self.defaultValues = defaultValues
        self.disabled = disabled
        self.required = required
    }
}

public struct ComponentV2ChannelSelect: Encodable, Sendable {
    public let type: Int = DiscordComponentType.channelSelect.rawValue
    public let id: Int?
    public let customId: String
    public let channelTypes: [Int]?
    public let placeholder: String?
    public let minValues: Int?
    public let maxValues: Int?
    public let defaultValues: [ComponentV2SelectDefaultValue]?
    public let disabled: Bool?
    public let required: Bool?

    public init(
        id: Int? = nil,
        customId: String,
        channelTypes: [Int]? = nil,
        placeholder: String? = nil,
        minValues: Int? = nil,
        maxValues: Int? = nil,
        defaultValues: [ComponentV2SelectDefaultValue]? = nil,
        disabled: Bool? = nil,
        required: Bool? = nil
    ) {
        self.id = id
        self.customId = customId
        self.channelTypes = channelTypes
        self.placeholder = placeholder
        self.minValues = minValues
        self.maxValues = maxValues
        self.defaultValues = defaultValues
        self.disabled = disabled
        self.required = required
    }
}

public struct ComponentV2TextInput: Encodable, Sendable {
    public let type: Int = DiscordComponentType.textInput.rawValue
    public let id: Int?
    public let customId: String
    public let style: Int?
    public let minLength: Int?
    public let maxLength: Int?
    public let required: Bool?
    public let value: String?
    public let placeholder: String?

    public init(
        id: Int? = nil,
        customId: String,
        style: DiscordTextInputStyle? = nil,
        minLength: Int? = nil,
        maxLength: Int? = nil,
        required: Bool? = nil,
        value: String? = nil,
        placeholder: String? = nil
    ) {
        self.id = id
        self.customId = customId
        self.style = style?.rawValue
        self.minLength = minLength
        self.maxLength = maxLength
        self.required = required
        self.value = value
        self.placeholder = placeholder
    }
}

public struct ComponentV2FileUpload: Encodable, Sendable {
    public let type: Int = DiscordComponentType.fileUpload.rawValue
    public let id: Int?
    public let customId: String
    public let minValues: Int?
    public let maxValues: Int?
    public let required: Bool?

    public init(
        id: Int? = nil,
        customId: String,
        minValues: Int? = nil,
        maxValues: Int? = nil,
        required: Bool? = nil
    ) {
        self.id = id
        self.customId = customId
        self.minValues = minValues
        self.maxValues = maxValues
        self.required = required
    }
}

public struct ComponentV2RadioGroupOption: Encodable, Sendable {
    public let label: String
    public let value: String
    public let description: String?
    public let defaultValue: Bool?

    enum CodingKeys: String, CodingKey {
        case label
        case value
        case description
        case defaultValue = "default"
    }

    public init(label: String, value: String, description: String? = nil, defaultValue: Bool? = nil) {
        self.label = label
        self.value = value
        self.description = description
        self.defaultValue = defaultValue
    }
}

public struct ComponentV2RadioGroup: Encodable, Sendable {
    public let type: Int = DiscordComponentType.radioGroup.rawValue
    public let id: Int?
    public let customId: String
    public let options: [ComponentV2RadioGroupOption]
    public let required: Bool?

    public init(id: Int? = nil, customId: String, options: [ComponentV2RadioGroupOption], required: Bool? = nil) {
        self.id = id
        self.customId = customId
        self.options = options
        self.required = required
    }
}

public struct ComponentV2CheckboxOption: Encodable, Sendable {
    public let label: String
    public let value: String
    public let description: String?
    public let defaultValue: Bool?

    enum CodingKeys: String, CodingKey {
        case label
        case value
        case description
        case defaultValue = "default"
    }

    public init(label: String, value: String, description: String? = nil, defaultValue: Bool? = nil) {
        self.label = label
        self.value = value
        self.description = description
        self.defaultValue = defaultValue
    }
}

public struct ComponentV2CheckboxGroup: Encodable, Sendable {
    public let type: Int = DiscordComponentType.checkboxGroup.rawValue
    public let id: Int?
    public let customId: String
    public let options: [ComponentV2CheckboxOption]
    public let minValues: Int?
    public let maxValues: Int?
    public let required: Bool?

    public init(
        id: Int? = nil,
        customId: String,
        options: [ComponentV2CheckboxOption],
        minValues: Int? = nil,
        maxValues: Int? = nil,
        required: Bool? = nil
    ) {
        self.id = id
        self.customId = customId
        self.options = options
        self.minValues = minValues
        self.maxValues = maxValues
        self.required = required
    }
}

public struct ComponentV2Checkbox: Encodable, Sendable {
    public let type: Int = DiscordComponentType.checkbox.rawValue
    public let id: Int?
    public let customId: String
    public let label: String
    public let description: String?
    public let value: Bool?
    public let required: Bool?
    public let disabled: Bool?

    public init(
        id: Int? = nil,
        customId: String,
        label: String,
        description: String? = nil,
        value: Bool? = nil,
        required: Bool? = nil,
        disabled: Bool? = nil
    ) {
        self.id = id
        self.customId = customId
        self.label = label
        self.description = description
        self.value = value
        self.required = required
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
    public let id: Int?
    public let components: [ComponentV2ActionRowComponent]

    public init(id: Int? = nil, components: [ComponentV2ActionRowComponent]) {
        self.id = id
        self.components = components
    }
}

public struct ComponentV2Section: Encodable, Sendable {
    public let type: Int = DiscordComponentType.section.rawValue
    public let id: Int?
    public let components: [ComponentV2Node]
    public let accessory: ComponentV2Accessory?

    public init(id: Int? = nil, components: [ComponentV2Node], accessory: ComponentV2Accessory? = nil) {
        self.id = id
        self.components = components
        self.accessory = accessory
    }
}

public struct ComponentV2Container: Encodable, Sendable {
    public let type: Int = DiscordComponentType.container.rawValue
    public let id: Int?
    public let accentColor: Int?
    public let spoiler: Bool?
    public let components: [ComponentV2Node]

    public init(id: Int? = nil, accentColor: Int? = nil, spoiler: Bool? = nil, components: [ComponentV2Node]) {
        self.id = id
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

public enum ComponentV2LabelComponent: Encodable, Sendable {
    case textInput(ComponentV2TextInput)
    case stringSelect(ComponentV2StringSelect)
    case userSelect(ComponentV2UserSelect)
    case roleSelect(ComponentV2RoleSelect)
    case mentionableSelect(ComponentV2MentionableSelect)
    case channelSelect(ComponentV2ChannelSelect)
    case fileUpload(ComponentV2FileUpload)
    case radioGroup(ComponentV2RadioGroup)
    case checkboxGroup(ComponentV2CheckboxGroup)
    case checkbox(ComponentV2Checkbox)

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .textInput(let component):
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
        case .fileUpload(let component):
            try component.encode(to: encoder)
        case .radioGroup(let component):
            try component.encode(to: encoder)
        case .checkboxGroup(let component):
            try component.encode(to: encoder)
        case .checkbox(let component):
            try component.encode(to: encoder)
        }
    }
}

public struct ComponentV2Label: Encodable, Sendable {
    public let type: Int = DiscordComponentType.label.rawValue
    public let id: Int?
    public let label: String
    public let description: String?
    public let component: ComponentV2LabelComponent

    public init(
        id: Int? = nil,
        label: String,
        description: String? = nil,
        component: ComponentV2LabelComponent
    ) {
        self.id = id
        self.label = label
        self.description = description
        self.component = component
    }
}
