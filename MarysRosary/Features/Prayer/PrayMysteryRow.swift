import SwiftUI

struct PrayMysteryRow: View {
    let type: MysteryType
    let isToday: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(type.accentColor)
                        .frame(width: 46, height: 46)
                    MysteryIcon(kind: type.icon)
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(type.displayName)
                            .font(.kefa(16))
                            .fontWeight(.semibold)
                            .foregroundStyle(type.theme.textPrimary)
                        if isToday {
                            Text("Today")
                                .font(.kefa(11))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(type.accentColor))
                        }
                    }
                    Text(type.dayDescription.replacingOccurrences(of: "\n", with: " "))
                        .font(.kefa(12))
                        .foregroundStyle(type.theme.textSubtle)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(.systemGray3))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.07), radius: 8, y: 3)
            )
            .overlay(
                isToday
                    ? RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(type.accentColor.opacity(0.4), lineWidth: 1.5)
                    : nil
            )
        }
        .buttonStyle(.plain)
    }
}
