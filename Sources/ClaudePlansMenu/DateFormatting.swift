import Foundation

enum DateFormatting {
    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()

    private static let dateTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, h:mm a"
        return f
    }()

    private static let dateTimeYearFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy, h:mm a"
        return f
    }()

    static func format(_ date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "Today, \(timeFormatter.string(from: date))"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday, \(timeFormatter.string(from: date))"
        } else if calendar.component(.year, from: date) == calendar.component(.year, from: Date()) {
            return dateTimeFormatter.string(from: date)
        } else {
            return dateTimeYearFormatter.string(from: date)
        }
    }
}
