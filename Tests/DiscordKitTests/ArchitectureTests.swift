import Foundation
import XCTest
@testable import SWDCK

private final class MockURLProtocol: URLProtocol {
    struct StubResponse {
        let statusCode: Int
        let headers: [String: String]
        let body: Data
    }

    private static let lock = NSLock()
    private static var responses: [StubResponse] = []
    private static var capturedRequests: [URLRequest] = []

    static func configure(responses: [StubResponse]) {
        lock.lock()
        self.responses = responses
        capturedRequests = []
        lock.unlock()
    }

    static func requests() -> [URLRequest] {
        lock.lock()
        defer { lock.unlock() }
        return capturedRequests
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        Self.lock.lock()
        let request = self.request
        Self.capturedRequests.append(request)
        guard !Self.responses.isEmpty else {
            Self.lock.unlock()
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        let stub = Self.responses.removeFirst()
        Self.lock.unlock()

        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: stub.statusCode,
            httpVersion: nil,
            headerFields: stub.headers
        )!

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: stub.body)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

final class ArchitectureTests: XCTestCase {

    private func makeClient(token: String = "token", authPrefix: String = "Bot") -> RESTClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        return RESTClient(
            token: token,
            authPrefix: authPrefix,
            session: session,
            rateLimiter: RateLimiter()
        )
    }

    private func data(_ string: String) -> Data {
        Data(string.utf8)
    }

    func testAuthPrefixIsAppliedToOutgoingRequests() async throws {
        MockURLProtocol.configure(responses: [
            .init(
                statusCode: 200,
                headers: [:],
                body: data(#"{"url":"wss://gateway.discord.gg"}"#)
            )
        ])

        let client = makeClient(token: "oauth-token", authPrefix: "Bearer")
        _ = try await client.getGateway()

        let authHeader = MockURLProtocol.requests().first?.value(forHTTPHeaderField: "Authorization")
        XCTAssertEqual(authHeader, "Bearer oauth-token")
    }

    func testRetriesAfter429WithRetryAfterPayload() async throws {
        MockURLProtocol.configure(responses: [
            .init(
                statusCode: 429,
                headers: [:],
                body: data(#"{"message":"rate limited","retry_after":0.001,"global":false}"#)
            ),
            .init(
                statusCode: 200,
                headers: [:],
                body: data(#"{"url":"wss://gateway.discord.gg"}"#)
            )
        ])

        let client = makeClient()
        let gateway = try await client.getGateway()
        XCTAssertEqual(gateway.url, "wss://gateway.discord.gg")
        XCTAssertEqual(MockURLProtocol.requests().count, 2)
    }

    func testMajorParameterAwareRouteNormalization() {
        let client = makeClient()

        XCTAssertEqual(
            client.normalizedRateLimitPath(from: "/channels/123456789/messages/987654321"),
            "/channels/123456789/messages/:id"
        )
        XCTAssertEqual(
            client.normalizedRateLimitPath(from: "/guilds/555/members/777"),
            "/guilds/555/members/:id"
        )
        XCTAssertEqual(
            client.normalizedRateLimitPath(from: "/guilds/@me/channels"),
            "/guilds/@me/channels"
        )
        XCTAssertEqual(
            client.normalizedRateLimitPath(from: "/applications/123/commands/456"),
            "/applications/:id/commands/:id"
        )
        XCTAssertEqual(
            client.normalizedRateLimitPath(from: "/webhooks/123/token/messages/456"),
            "/webhooks/123/token/messages/:id"
        )
        XCTAssertEqual(
            client.normalizedRateLimitPath(from: "/webhooks/123/456/messages/789"),
            "/webhooks/123/456/messages/:id"
        )
    }

    func testGatewayReconnectURLSelection() {
        XCTAssertEqual(
            GatewayClient.resolvedReconnectURL(
                canResume: true,
                resumeGatewayURL: "wss://resume.example",
                initialGatewayURL: "wss://initial.example"
            ),
            "wss://resume.example"
        )

        XCTAssertEqual(
            GatewayClient.resolvedReconnectURL(
                canResume: false,
                resumeGatewayURL: "wss://resume.example",
                initialGatewayURL: "wss://initial.example"
            ),
            "wss://initial.example"
        )

        XCTAssertEqual(
            GatewayClient.resolvedReconnectURL(
                canResume: false,
                resumeGatewayURL: nil,
                initialGatewayURL: nil
            ),
            "wss://gateway.discord.gg/?v=10&encoding=json"
        )
    }

    func testNewQueryBuildersIncludeExpectedParameters() async throws {
        let client = makeClient()

        MockURLProtocol.configure(responses: [
            .init(statusCode: 200, headers: [:], body: data("[]")),
            .init(statusCode: 200, headers: [:], body: data("[]"))
        ])

        _ = try await client.getSKUSubscriptions(
            skuId: "sku_1",
            query: SkuSubscriptionsQuery(
                before: "b",
                after: "a",
                limit: 25,
                userId: "user_1"
            )
        )
        _ = try await client.getApplicationEntitlements(
            applicationId: "app_1",
            query: EntitlementsQuery(
                excludeEnded: true,
                excludeDeleted: true
            )
        )

        let requests = MockURLProtocol.requests()
        let subscriptionsItems = URLComponents(string: requests[0].url?.absoluteString ?? "")?.queryItems ?? []
        XCTAssertTrue(subscriptionsItems.contains(URLQueryItem(name: "before", value: "b")))
        XCTAssertTrue(subscriptionsItems.contains(URLQueryItem(name: "after", value: "a")))
        XCTAssertTrue(subscriptionsItems.contains(URLQueryItem(name: "limit", value: "25")))
        XCTAssertTrue(subscriptionsItems.contains(URLQueryItem(name: "user_id", value: "user_1")))

        let entitlementItems = URLComponents(string: requests[1].url?.absoluteString ?? "")?.queryItems ?? []
        XCTAssertTrue(entitlementItems.contains(URLQueryItem(name: "exclude_ended", value: "true")))
        XCTAssertTrue(entitlementItems.contains(URLQueryItem(name: "exclude_deleted", value: "true")))
    }
}
