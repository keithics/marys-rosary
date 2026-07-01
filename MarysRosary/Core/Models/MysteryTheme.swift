import SwiftUI

// MARK: - Font helpers

extension Font {
    static func kaushan(_ size: CGFloat) -> Font {
        .custom("KaushanScript-Regular", size: size)
    }
    static func kefa(_ size: CGFloat) -> Font {
        .custom("Kefa-Regular", size: size)
    }
}

// MARK: - Bundle helpers

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    var fullVersion: String { "\(appVersion) (\(buildNumber))" }
}

// MARK: - Mystery theme

struct MysteryTheme {
    let accent: Color
    let cloud: Color
    let textPrimary: Color   // dark, hue-matched — for titles and body text
    let textSubtle: Color    // mid-tone — for subtitles and secondary labels
}

// MARK: - Mystery metadata

extension MysteryType {
    var theme: MysteryTheme {
        switch self {
        case .joyful:
            return MysteryTheme(
                accent:      Color(red: 0.92, green: 0.50, blue: 0.68),
                cloud:       Color(red: 1.00, green: 0.90, blue: 0.94),
                textPrimary: Color(red: 0.42, green: 0.10, blue: 0.26),
                textSubtle:  Color(red: 0.65, green: 0.32, blue: 0.46)
            )
        case .luminous:
            return MysteryTheme(
                accent:      Color(red: 0.44, green: 0.60, blue: 0.44),
                cloud:       Color(red: 0.88, green: 0.96, blue: 0.88),
                textPrimary: Color(red: 0.12, green: 0.28, blue: 0.14),
                textSubtle:  Color(red: 0.26, green: 0.44, blue: 0.28)
            )
        case .sorrowful:
            return MysteryTheme(
                accent:      Color(red: 0.52, green: 0.44, blue: 0.66),
                cloud:       Color(red: 0.93, green: 0.90, blue: 0.98),
                textPrimary: Color(red: 0.20, green: 0.14, blue: 0.36),
                textSubtle:  Color(red: 0.38, green: 0.30, blue: 0.54)
            )
        case .glorious:
            return MysteryTheme(
                accent:      Color(red: 0.78, green: 0.62, blue: 0.28),
                cloud:       Color(red: 1.00, green: 0.95, blue: 0.80),
                textPrimary: Color(red: 0.32, green: 0.22, blue: 0.04),
                textSubtle:  Color(red: 0.52, green: 0.40, blue: 0.14)
            )
        }
    }

    var accentColor: Color { theme.accent }

    var imageName: String {
        switch self {
        case .joyful:    return "joyful"
        case .luminous:  return "luminous"
        case .sorrowful: return "sorrowful"
        case .glorious:  return "glorious"
        }
    }

    enum IconKind { case svg(String), fa6(String), sf(String) }

    var icon: IconKind {
        switch self {
        case .joyful:    return .svg("icon-rosary")
        case .luminous:  return .fa6("\u{f4e3}")
        case .sorrowful: return .svg("icon-three-crosses")
        case .glorious:  return .fa6("\u{f521}")
        }
    }

    var dayDescription: String {
        switch self {
        case .joyful:
            return "Mondays, Saturdays, Sundays of\nAdvent, and Sundays after Epiphany"
        case .luminous:
            return "Every Thursday\n "
        case .sorrowful:
            return "Tuesdays, Fridays,\nand Sundays of Lent"
        case .glorious:
            return "Sundays and Wednesdays\n "
        }
    }

    var firstName: String {
        switch self {
        case .joyful:    return "Joyful"
        case .luminous:  return "Luminous"
        case .sorrowful: return "Sorrowful"
        case .glorious:  return "Glorious"
        }
    }

    var reflection: String {
        switch self {
        case .joyful:
            return "Contemplate the joyful events in the lives of Jesus and Mary — from the Annunciation to the finding of the Child Jesus in the Temple. Let these mysteries open your heart to God's will and fill you with wonder and gratitude."
        case .luminous:
            return "Walk with Jesus through the mysteries of His public ministry — from His Baptism in the Jordan to the institution of the Eucharist. Let the light of Christ illuminate your heart and draw you deeper into His love."
        case .sorrowful:
            return "Meditate on the passion and suffering of Our Lord. In His agony and sacrifice, discover the depth of God's love for you, and find strength to carry your own crosses with faith and trust."
        case .glorious:
            return "Rejoice in the triumph of Christ over sin and death. From the Resurrection to the Coronation of Mary, let these mysteries strengthen your hope in eternal life and inspire you to live for the glory of God."
        }
    }
}
