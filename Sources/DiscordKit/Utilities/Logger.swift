import Foundation

public final class DiscordLogger: @unchecked Sendable {

    public enum Level: Int, Comparable {
        case debug = 0, info = 1, warning = 2, error = 3, none = 4

        public static func < (lhs: Level, rhs: Level) -> Bool {
            lhs.rawValue < rhs.rawValue
        }

        var prefix: String {
            switch self {
            case .debug:   return "🔍 [DEBUG]"
            case .info:    return "ℹ️  [INFO] "
            case .warning: return "⚠️  [WARN] "
            case .error:   return "❌ [ERROR]"
            case .none:    return ""
            }
        }
    }

    public var minimumLevel: Level = .info

    public static let shared = DiscordLogger()

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss.SSS"
        return f
    }()

    public func log(_ level: Level, _ message: @autoclosure () -> String, file: String = #file, line: Int = #line) {
        guard level >= minimumLevel else { return }
        let timestamp = dateFormatter.string(from: Date())
        let filename = (file as NSString).lastPathComponent
        print("\(timestamp) \(level.prefix) [\(filename):\(line)] \(message())")
    }

    public func debug(_ msg: @autoclosure () -> String, file: String = #file, line: Int = #line) {
        log(.debug, msg(), file: file, line: line)
    }

    public func info(_ msg: @autoclosure () -> String, file: String = #file, line: Int = #line) {
        log(.info, msg(), file: file, line: line)
    }

    public func warning(_ msg: @autoclosure () -> String, file: String = #file, line: Int = #line) {
        log(.warning, msg(), file: file, line: line)
    }

    public func error(_ msg: @autoclosure () -> String, file: String = #file, line: Int = #line) {
        log(.error, msg(), file: file, line: line)
    }
}

let logger = DiscordLogger.shared
