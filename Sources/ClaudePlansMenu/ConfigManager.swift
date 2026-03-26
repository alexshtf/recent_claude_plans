import Foundation

struct AppConfig: Codable {
    var maxPlans: Int = 10
    var editor: String = "code"

    enum CodingKeys: String, CodingKey {
        case maxPlans = "max_plans"
        case editor
    }
}

class ConfigManager {
    static let shared = ConfigManager()

    private let configURL: URL = {
        let dir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".config/claude-plans-menu")
        return dir.appendingPathComponent("config.json")
    }()

    private(set) var config: AppConfig

    private init() {
        config = Self.load(from: configURL)
    }

    private static func load(from url: URL) -> AppConfig {
        guard let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(AppConfig.self, from: data) else {
            return AppConfig()
        }
        return decoded
    }

    func save(_ newConfig: AppConfig) {
        config = newConfig

        let dir = configURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(config) else { return }
        try? data.write(to: configURL)
    }
}
