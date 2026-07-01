import SwiftUI

struct MysteryCard: View {
    let type: MysteryType
    let isToday: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                Image(type.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, minHeight: 190, maxHeight: 190, alignment: .top)
                    .clipped()

                LinearGradient(
                    stops: [
                        .init(color: type.theme.cloud.opacity(0.98), location: 0.00),
                        .init(color: type.theme.cloud.opacity(0.92), location: 0.30),
                        .init(color: type.theme.cloud.opacity(0.55), location: 0.52),
                        .init(color: type.theme.cloud.opacity(0.10), location: 0.72),
                        .init(color: .clear,                         location: 1.00)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )

                VStack {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(type.accentColor)
                                .frame(width: 40, height: 40)
                            MysteryIcon(kind: type.icon)
                                .foregroundStyle(.white)
                                .frame(width: 22, height: 22)
                        }
                        .padding(.leading, 16)
                        .padding(.top, 16)
                        Spacer()
                    }
                    Spacer()
                }

                VStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 0) {
                        Text(type.firstName)
                            .font(.system(size: 28, weight: .regular, design: .serif))
                            .foregroundStyle(type.theme.textPrimary)
                        Text("Mysteries")
                            .font(.system(size: 28, weight: .regular, design: .serif))
                            .foregroundStyle(type.theme.textPrimary)

                        Rectangle()
                            .fill(type.accentColor)
                            .frame(width: 28, height: 2.5)
                            .padding(.top, 6)
                            .padding(.bottom, 8)

                        Text(type.dayDescription)
                            .font(.kefa(12))
                            .foregroundStyle(type.theme.textSubtle)
                            .lineSpacing(3)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                    .padding(.bottom, 16)
                }

                HStack {
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial.opacity(0.5))
                            .frame(width: 40, height: 40)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(type.accentColor)
                    }
                    .padding(.trailing, 16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .contentShape(Rectangle())
            .shadow(color: .black.opacity(0.09), radius: 10, y: 4)
            .overlay(
                isToday
                    ? RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(type.accentColor.opacity(0.5), lineWidth: 1.5)
                    : nil
            )
        }
        .buttonStyle(.plain)
    }
}
