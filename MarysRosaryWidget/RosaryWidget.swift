import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct RosaryEntry: TimelineEntry {
    let date: Date
    let mystery: MysteryType
    let mysteryTitles: [String]
}

// MARK: - Provider

struct RosaryProvider: TimelineProvider {
    func placeholder(in context: Context) -> RosaryEntry {
        RosaryEntry(date: .now, mystery: .joyful, mysteryTitles: placeholderTitles)
    }

    func getSnapshot(in context: Context, completion: @escaping (RosaryEntry) -> Void) {
        completion(entry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RosaryEntry>) -> Void) {
        let e = entry()
        let midnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        completion(Timeline(entries: [e], policy: .after(midnight)))
    }

    private func entry() -> RosaryEntry {
        let mystery = MysteryType.forToday()
        let titles = Mystery.load(type: mystery).map(\.title)
        return RosaryEntry(date: .now, mystery: mystery, mysteryTitles: titles)
    }

    private var placeholderTitles: [String] {
        ["The Annunciation", "The Visitation", "The Nativity", "The Presentation", "Finding in the Temple"]
    }
}

// MARK: - Widget

struct RosaryWidget: Widget {
    let kind = "RosaryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RosaryProvider()) { entry in
            RosaryWidgetEntryView(entry: entry)
                .containerBackground(entry.mystery.theme.cloud, for: .widget)
        }
        .configurationDisplayName("Today's Mystery")
        .description("Shows today's Rosary mystery.")
        .supportedFamilies([
            .systemSmall, .systemMedium, .systemLarge,
            .accessoryCircular, .accessoryRectangular
        ])
    }
}

// MARK: - Entry View

struct RosaryWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: RosaryEntry

    var body: some View {
        switch family {
        case .systemSmall:      SmallView(entry: entry)
        case .systemMedium:     MediumView(entry: entry)
        case .systemLarge:      LargeView(entry: entry)
        case .accessoryCircular: CircularView(entry: entry)
        case .accessoryRectangular: RectangularView(entry: entry)
        default:                SmallView(entry: entry)
        }
    }
}

// MARK: - Small

private struct SmallView: View {
    let entry: RosaryEntry
    var body: some View {
        Link(destination: URL(string: "marysrosary://mystery/\(entry.mystery.rawValue)")!) {
            VStack(spacing: 6) {
                Image(entry.mystery.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                Text(entry.mystery.displayName)
                    .font(.custom("KaushanScript-Regular", size: 13))
                    .foregroundStyle(entry.mystery.theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(8)
        }
    }
}

// MARK: - Medium

private struct MediumView: View {
    let entry: RosaryEntry
    var body: some View {
        Link(destination: URL(string: "marysrosary://mystery/\(entry.mystery.rawValue)")!) {
            HStack(spacing: 12) {
                Image(entry.mystery.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Mystery")
                        .font(.caption2)
                        .foregroundStyle(entry.mystery.theme.textSubtle)
                    Text(entry.mystery.displayName)
                        .font(.custom("KaushanScript-Regular", size: 18))
                        .foregroundStyle(entry.mystery.theme.textPrimary)
                    Text(dayLabel)
                        .font(.caption)
                        .foregroundStyle(entry.mystery.theme.textSubtle)
                }
                Spacer()
            }
            .padding()
        }
    }

    private var dayLabel: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEE"
        return fmt.string(from: entry.date)
    }
}

// MARK: - Large

private struct LargeView: View {
    let entry: RosaryEntry
    var body: some View {
        Link(destination: URL(string: "marysrosary://mystery/\(entry.mystery.rawValue)")!) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Image(entry.mystery.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Today's Mystery")
                            .font(.caption2)
                            .foregroundStyle(entry.mystery.theme.textSubtle)
                        Text(entry.mystery.displayName)
                            .font(.custom("KaushanScript-Regular", size: 18))
                            .foregroundStyle(entry.mystery.theme.textPrimary)
                    }
                }
                Divider().opacity(0.3)
                ForEach(Array(entry.mysteryTitles.enumerated()), id: \.offset) { i, title in
                    HStack(spacing: 8) {
                        Text("\(i + 1).")
                            .font(.caption2.bold())
                            .foregroundStyle(entry.mystery.accentColor)
                            .frame(width: 16)
                        Text(title)
                            .font(.caption)
                            .foregroundStyle(entry.mystery.theme.textPrimary)
                        Spacer()
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Accessory Circular

private struct CircularView: View {
    let entry: RosaryEntry
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            Text(String(entry.mystery.displayName.prefix(1)))
                .font(.title2.bold())
        }
    }
}

// MARK: - Accessory Rectangular

private struct RectangularView: View {
    let entry: RosaryEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Mary's Rosary")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(entry.mystery.displayName)
                .font(.headline)
                .lineLimit(1)
        }
    }
}
