import Foundation

struct PrayerDailyTotal: Codable, Identifiable {
    let date: String
    let timezoneIdentifier: String
    var totalSeconds: Int
    var completedRosaryCount: Int
    var partialSessionCount: Int
    var updatedAt: Date
    var lastUploadedAt: Date?
    var pendingUpload: Bool
    var pendingTotalSeconds: Int
    var pendingCompletedRosaryCount: Int
    var pendingPartialSessionCount: Int

    var id: String { Self.key(date: date, timezoneIdentifier: timezoneIdentifier) }

    static func key(date: String, timezoneIdentifier: String) -> String {
        "\(date)|\(timezoneIdentifier)"
    }

    static func currentDay(
        calendar: Calendar = .current,
        timeZone: TimeZone = .current,
        now: Date = .now
    ) -> (date: String, timezoneIdentifier: String) {
        var localCalendar = calendar
        localCalendar.timeZone = timeZone

        let components = localCalendar.dateComponents([.year, .month, .day], from: now)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        let date = "\(year)-\(Self.twoDigit(month))-\(Self.twoDigit(day))"

        return (date, timeZone.identifier)
    }

    private static func twoDigit(_ value: Int) -> String {
        value < 10 ? "0\(value)" : "\(value)"
    }
}
