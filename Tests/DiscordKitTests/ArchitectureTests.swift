import XCTest
@testable import DiscordKit

final class ArchitectureTests: XCTestCase {

    func testAuthPrefix() {
        let client = RESTClient(token: "my-token", authPrefix: "Bearer")
        _ = client
    }

    func testBucketNormalizationRegex() {
        let client = RESTClient(token: "test")

        XCTAssertEqual(
            client.normalizedRateLimitPath(from: "/channels/123456789/messages/987654321"),
            "/channels/:id/messages/:id"
        )
        XCTAssertEqual(
            client.normalizedRateLimitPath(from: "/guilds/555/roles"),
            "/guilds/:id/roles"
        )
        XCTAssertEqual(
            client.normalizedRateLimitPath(from: "/guilds/@me/channels"),
            "/guilds/@me/channels"
        )
        XCTAssertEqual(
            client.normalizedRateLimitPath(from: "/applications/123/commands/permissions"),
            "/applications/:id/commands/permissions"
        )
    }
}
