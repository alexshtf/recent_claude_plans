import Foundation

enum EditorLauncher {
    static func open(filePath: String) {
        let config = ConfigManager.shared.config
        let escaped = filePath.replacingOccurrences(of: "'", with: "'\\''")
        let command = "\(config.editor) '\(escaped)'"

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-lc", command]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice

        try? process.run()
    }
}
