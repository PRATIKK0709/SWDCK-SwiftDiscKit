import Foundation

public struct AllowedMentions: Codable, Sendable {
    public let parse: [AllowedMentionType]?
    public let roles: [String]?
    public let users: [String]?
    public let repliedUser: Bool?

    public init(
        parse: [AllowedMentionType]? = nil,
        roles: [String]? = nil,
        users: [String]? = nil,
        repliedUser: Bool? = nil
    ) {
        self.parse = parse
        self.roles = roles
        self.users = users
        self.repliedUser = repliedUser
    }

    public static let none = AllowedMentions(parse: [])
}

public enum AllowedMentionType: String, Codable, Sendable {
    case roles
    case users
    case everyone
}
