import Foundation

enum PlanScanner {
    private static let plansDirectory: URL = {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude/plans")
    }()

    static func scan(max: Int) -> [PlanItem] {
        let fm = FileManager.default
        guard let urls = try? fm.contentsOfDirectory(
            at: plansDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var plans: [PlanItem] = []

        for url in urls where url.pathExtension == "md" {
            let values = try? url.resourceValues(forKeys: [.contentModificationDateKey])
            let modDate = values?.contentModificationDate ?? Date.distantPast

            let fileName = url.deletingPathExtension().lastPathComponent
            let title = extractTitle(from: url)

            plans.append(PlanItem(
                fileName: fileName,
                title: title,
                filePath: url.path,
                modificationDate: modDate
            ))
        }

        plans.sort { $0.modificationDate > $1.modificationDate }
        return Array(plans.prefix(max))
    }

    private static func extractTitle(from url: URL) -> String {
        guard let handle = try? FileHandle(forReadingFrom: url) else {
            return "Untitled"
        }
        defer { handle.closeFile() }

        guard let data = try? handle.read(upToCount: 1024),
              let text = String(data: data, encoding: .utf8) else {
            return "Untitled"
        }

        for line in text.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("# ") {
                var title = String(trimmed.dropFirst(2))
                if title.hasPrefix("Plan:") {
                    title = String(title.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                }
                return title.isEmpty ? "Untitled" : title
            }
        }

        return "Untitled"
    }
}
