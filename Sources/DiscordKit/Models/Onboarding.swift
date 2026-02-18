import Foundation

public struct GuildOnboarding: Codable, Sendable {
    public let guildId: String
    public let prompts: [OnboardingPrompt]?
    public let defaultChannelIds: [String]?
    public let enabled: Bool?
    public let mode: Int?
}

public struct OnboardingPrompt: Codable, Sendable {
    public let id: String
    public let type: Int?
    public let options: [OnboardingPromptOption]?
    public let title: String
    public let singleSelect: Bool?
    public let required: Bool?
    public let inOnboarding: Bool?
}

public struct OnboardingPromptOption: Codable, Sendable {
    public let id: String
    public let channelIds: [String]?
    public let roleIds: [String]?
    public let title: String?
    public let description: String?
    public let emojiId: String?
    public let emojiName: String?
    public let emojiAnimated: Bool?
}

public struct ModifyGuildOnboarding: Codable, Sendable {
    public let prompts: [OnboardingPrompt]?
    public let defaultChannelIds: [String]?
    public let enabled: Bool?
    public let mode: Int?

    public init(
        prompts: [OnboardingPrompt]? = nil,
        defaultChannelIds: [String]? = nil,
        enabled: Bool? = nil,
        mode: Int? = nil
    ) {
        self.prompts = prompts
        self.defaultChannelIds = defaultChannelIds
        self.enabled = enabled
        self.mode = mode
    }
}

public struct GuildPreview: Codable, Sendable {
    public let id: String
    public let name: String
    public let icon: String?
    public let splash: String?
    public let discoverySplash: String?
    public let emojis: [GuildEmoji]?
    public let features: [String]?
    public let approximateMemberCount: Int?
    public let approximatePresenceCount: Int?
    public let description: String?
}

public struct GuildVanityURL: Codable, Sendable {
    public let code: String?
    public let uses: Int?
}
