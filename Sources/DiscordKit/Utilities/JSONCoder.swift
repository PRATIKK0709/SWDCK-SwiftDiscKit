import Foundation

enum JSONCoder {

    static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)
            let isoFull = ISO8601DateFormatter()
            isoFull.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFull.date(from: str) { return date }
            let isoBasic = ISO8601DateFormatter()
            if let date = isoBasic.date(from: str) { return date }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date: \(str)"
            )
        }
        return d
    }()

    static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    static func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw DiscordError.decodingFailed(type: String(describing: type), underlying: error)
        }
    }

    static func encode<T: Encodable>(_ value: T) throws -> Data {
        try encoder.encode(value)
    }
}
