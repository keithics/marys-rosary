import SwiftUI

struct WelcomeView: View {
    let mysteryType: MysteryType
    let onBegin: () -> Void
    let onDismiss: () -> Void

    @State private var appeared = false

    private var theme: MysteryTheme { mysteryType.theme }

    var body: some View {
        ZStack {
            theme.cloud.ignoresSafeArea()

            VStack(spacing: 0) {
                // Dismiss
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(theme.textSubtle)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(.white.opacity(0.6)))
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)

                Spacer()

                // Icon
                ZStack {
                    Circle()
                        .fill(theme.accent.opacity(0.18))
                        .frame(width: 110, height: 110)
                    Circle()
                        .fill(theme.accent.opacity(0.32))
                        .frame(width: 80, height: 80)
                    MysteryIcon(kind: mysteryType.icon)
                        .foregroundStyle(theme.accent)
                        .frame(width: 40, height: 40)
                }
                .scaleEffect(appeared ? 1 : 0.7)
                .opacity(appeared ? 1 : 0)

                Spacer().frame(height: 32)

                // Title
                VStack(spacing: 8) {
                    Text("The Holy Rosary")
                        .font(.kefa(14))
                        .foregroundStyle(theme.textSubtle)
                        .tracking(1.5)
                        .textCase(.uppercase)

                    Text(mysteryType.displayName)
                        .font(.kaushan(36))
                        .foregroundStyle(theme.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(mysteryType.dayDescription
                            .replacingOccurrences(of: "\n ", with: "")
                            .replacingOccurrences(of: "\n", with: " · "))
                        .font(.kefa(13))
                        .foregroundStyle(theme.textSubtle)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.top, 4)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
                .padding(.horizontal, 32)

                Spacer().frame(height: 24)

                Text(mysteryType.reflection)
                    .font(.system(size: 14, weight: .regular, design: .serif))
                    .foregroundStyle(theme.textPrimary.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 36)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)

                Spacer()

                // Begin button
                Button(action: onBegin) {
                    Text("Begin Prayer")
                        .font(.kefa(17))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            Capsule().fill(theme.accent)
                        )
                        .shadow(color: theme.accent.opacity(0.4), radius: 12, y: 6)
                }
                .padding(.horizontal, 32)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

                Spacer().frame(height: 60)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.78).delay(0.1)) {
                appeared = true
            }
        }
    }
}
