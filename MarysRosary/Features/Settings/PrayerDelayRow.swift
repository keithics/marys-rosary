import SwiftUI

struct PrayerDelayRow: View {
    let prayer: Prayer
    let theme: MysteryTheme
    @ObservedObject var delayStore: PrayerDelayStore
    let isPlayingPreview: Bool
    let isLast: Bool
    let onPreview: () -> Void

    private var hasResponse: Bool { prayer.texts.contains(where: { $0.type == .response }) }
    private var responseSeconds: Int { delayStore.responseSeconds(for: prayer) }
    private var isModified: Bool { delayStore.overrides[prayer.id] != nil }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button(action: onPreview) {
                    ZStack {
                        Circle()
                            .strokeBorder(theme.accent, lineWidth: 1.5)
                            .frame(width: 36, height: 36)
                        Image(systemName: isPlayingPreview ? "stop.fill" : "play.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(theme.accent)
                            .offset(x: isPlayingPreview ? 0 : 1)
                    }
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 2) {
                    Text(prayer.title)
                        .font(.system(size: 15, weight: .medium, design: .serif))
                        .foregroundStyle(theme.textPrimary)
                    if hasResponse {
                        Text("Response: \(responseSeconds)s")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.accent)
                    }
                }

                Spacer()

                if isModified {
                    Button("Reset") {
                        withAnimation { delayStore.reset(for: prayer) }
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(theme.accent)
                    .buttonStyle(.plain)
                }

                if hasResponse {
                    HStack(spacing: 0) {
                        Button { delayStore.setResponseSeconds(responseSeconds - 1, for: prayer) } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 13, weight: .semibold))
                                .frame(width: 36, height: 36)
                                .foregroundStyle(responseSeconds > 1 ? theme.accent : theme.textSubtle.opacity(0.3))
                        }
                        .buttonStyle(.plain)
                        .disabled(responseSeconds <= 1)

                        Button { delayStore.setResponseSeconds(responseSeconds + 1, for: prayer) } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 13, weight: .semibold))
                                .frame(width: 36, height: 36)
                                .foregroundStyle(responseSeconds < 90 ? theme.accent : theme.textSubtle.opacity(0.3))
                        }
                        .buttonStyle(.plain)
                        .disabled(responseSeconds >= 90)
                    }
                    .background(Capsule().fill(theme.accent.opacity(0.08)))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            if !isLast {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 0.5)
                    .padding(.leading, 62)
            }
        }
    }
}
