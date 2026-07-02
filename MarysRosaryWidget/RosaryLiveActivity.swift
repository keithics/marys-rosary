import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Accent color from mystery type raw value

private extension String {
    var mysteryAccent: Color {
        switch self {
        case "joyful":    return Color(red: 0.20, green: 0.55, blue: 0.85)
        case "sorrowful": return Color(red: 0.65, green: 0.15, blue: 0.20)
        case "glorious":  return Color(red: 0.80, green: 0.60, blue: 0.10)
        case "luminous":  return Color(red: 0.15, green: 0.60, blue: 0.50)
        default:          return Color(red: 0.40, green: 0.35, blue: 0.60)
        }
    }
}

// MARK: - Lock Screen / Banner
// Minimal — MPNowPlayingInfoCenter owns the lock screen media controls.
// This banner shows mystery context only.

private struct LockScreenView: View {
    let context: ActivityViewContext<RosaryActivityAttributes>

    var body: some View {
        let accent = context.attributes.mysteryType.mysteryAccent
        HStack(spacing: 12) {
            Image(context.attributes.mysteryType)
                .resizable()
                .scaledToFill()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(context.attributes.mysteryName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text("Rosary Prayer")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            ProgressView(
                value: Double(context.state.beadIndex),
                total: Double(max(context.state.totalBeads, 1))
            )
            .tint(accent)
            .frame(width: 56)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Widget

struct RosaryLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RosaryActivityAttributes.self) { context in
            LockScreenView(context: context)
        } dynamicIsland: { context in
            let accent = context.attributes.mysteryType.mysteryAccent

            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(context.attributes.mysteryType)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .padding(.leading, 6)
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.attributes.mysteryName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(context.state.prayerName)
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Image(systemName: context.state.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(accent)
                        Text("\(context.state.beadIndex)/\(context.state.totalBeads)")
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                    .padding(.trailing, 6)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(
                        value: Double(context.state.beadIndex),
                        total: Double(max(context.state.totalBeads, 1))
                    )
                    .tint(accent)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 4)
                }
            } compactLeading: {
                Image(context.attributes.mysteryType)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 20, height: 20)
                    .clipShape(Circle())
                    .padding(.leading, 2)
            } compactTrailing: {
                Text("\(context.state.textSegment)/\(context.state.totalSegments)")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                    .padding(.trailing, 2)
            } minimal: {
                Image(context.attributes.mysteryType)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 20, height: 20)
                    .clipShape(Circle())
            }
            .keylineTint(accent)
        }
    }
}
