import Foundation

public struct WelcomeScreen: Codable, Sendable {
    public let description: String?
    public let welcomeChannels: [WelcomeScreenChannel]?
}

public struct WelcomeScreenChannel: Codable, Sendable {
    public let channelId: String
    public let description: String
    public let emojiId: String?
    public let emojiName: String?
}

public struct ModifyWelcomeScreen: Codable, Sendable {
    public let enabled: Bool?
    public let welcomeChannels: [WelcomeScreenChannel]?
    public let description: String?

    public init(
        enabled: Bool? = nil,
        welcomeChannels: [WelcomeScreenChannel]? = nil,
        description: String? = nil
    ) {
        self.enabled = enabled
        self.welcomeChannels = welcomeChannels
        self.description = description
    }
}
