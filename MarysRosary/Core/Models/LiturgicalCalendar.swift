import Foundation

// MARK: - Liturgical season

enum LiturgicalSeason {
    case advent
    case christmas
    case lent
    case easterSeason
    case ordinary
}

// MARK: - Liturgical calendar

enum LiturgicalCalendar {

    // Gregorian Computus — returns Easter Sunday for the given year.
    static func easter(year: Int) -> DateComponents {
        let a = year % 19
        let b = year / 100
        let c = year % 100
        let d = b / 4
        let e = b % 4
        let f = (b + 8) / 25
        let g = (b - f + 1) / 3
        let h = (19 * a + b - d - g + 15) % 30
        let i = c / 4
        let k = c % 4
        let l = (32 + 2 * e + 2 * i - h - k) % 7
        let m = (a + 11 * h + 22 * l) / 451
        let month = (h + l - 7 * m + 114) / 31
        let day = ((h + l - 7 * m + 114) % 31) + 1
        return DateComponents(year: year, month: month, day: day)
    }

    // Returns Easter Sunday as a Date for the given year.
    static func easterDate(year: Int, calendar: Calendar = .current) -> Date? {
        calendar.date(from: easter(year: year))
    }

    // Returns the liturgical season for a given date.
    static func season(for date: Date = Date(), calendar: Calendar = .current) -> LiturgicalSeason {
        let year = calendar.component(.year, from: date)

        // --- Easter-based seasons ---
        guard let easter = easterDate(year: year, calendar: calendar) else { return .ordinary }

        let ashWednesday = calendar.date(byAdding: .day, value: -46, to: easter)!
        let pentecost    = calendar.date(byAdding: .day, value:  49, to: easter)!

        if date >= ashWednesday && date < easter {
            return .lent
        }
        if date >= easter && date <= pentecost {
            return .easterSeason
        }

        // --- Christmas / Epiphany ---
        // Christmas season: Dec 25 – Jan 6 (Epiphany)
        let month = calendar.component(.month, from: date)
        let day   = calendar.component(.day,   from: date)

        if month == 12 && day >= 25 { return .christmas }
        if month == 1  && day <= 6  { return .christmas }

        // --- Advent ---
        // Advent begins on the 4th Sunday before Dec 25.
        let christmasComponents = DateComponents(year: year, month: 12, day: 25)
        guard let christmas = calendar.date(from: christmasComponents) else { return .ordinary }

        // Find the Sunday on or before Dec 25, then go back 3 more Sundays.
        let christmasWeekday = calendar.component(.weekday, from: christmas) // 1=Sun
        let daysToSunday = (christmasWeekday - 1) % 7   // days from previous Sunday
        let fourthSunday = calendar.date(byAdding: .day, value: -(daysToSunday + 21), to: christmas)!

        if date >= fourthSunday && date < christmas {
            return .advent
        }

        return .ordinary
    }

    // Returns the rosary mystery appropriate for a given date,
    // respecting the liturgical season for Sunday overrides.
    static func mystery(for date: Date = Date(), calendar: Calendar = .current) -> MysteryType {
        let weekday = calendar.component(.weekday, from: date)

        switch weekday {
        case 2: return .joyful      // Monday
        case 3: return .sorrowful   // Tuesday
        case 4: return .glorious    // Wednesday
        case 5: return .luminous    // Thursday
        case 6: return .sorrowful   // Friday
        case 7: return .joyful      // Saturday
        default: break              // Sunday — fall through to season check
        }

        // Sunday: season determines the mystery
        switch season(for: date, calendar: calendar) {
        case .advent:               return .joyful
        case .lent:                 return .sorrowful
        case .christmas, .ordinary, .easterSeason:
                                    return .glorious
        }
    }
}

// MARK: - MysteryType convenience

extension MysteryType {
    // Force a specific mystery (overrides date logic). Set nil before shipping.
    static var debugOverride: MysteryType? = nil

    // Force a specific date for testing midnight transitions. Set nil before shipping.
    // Example: Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: Date())
    static var debugDate: Date? = nil

    // Returns today's mystery using the full Catholic liturgical calendar.
    static func forToday(calendar: Calendar = .current) -> MysteryType {
        if let override = debugOverride { return override }
        return LiturgicalCalendar.mystery(for: debugDate ?? Date(), calendar: calendar)
    }

    // The liturgical season for today.
    static var liturgicalSeason: LiturgicalSeason {
        LiturgicalCalendar.season()
    }
}
