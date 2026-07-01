import SwiftUI

private let blessings: [String] = [
    "May the grace of the Rosary draw you ever closer to the Heart of Jesus through Mary.",
    "The Rosary is the weapon for these times. Pray it daily and place yourself under her mantle.\n— Our Lady of Fatima",
    "Never will anyone who says the Rosary every day become a formal heretic or be led astray by the devil.\n— St. Louis de Montfort",
    "To Jesus through Mary — may this Rosary be your offering today.",
    "She is the Queen of the Rosary. May she carry your intentions to her Son."
]

struct CompletionView: View {
    let mysteryType: MysteryType
    let onPrayAgain: () -> Void

    @State private var appeared = false
    private let blessing = blessings[Int.random(in: 0..<blessings.count)]
    private var theme: MysteryTheme { mysteryType.theme }

    var body: some View {
        ZStack {
            theme.cloud.ignoresSafeArea()

            VStack(spacing: 0) {
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
                    Text("Rosary Complete")
                        .font(.kefa(14))
                        .foregroundStyle(theme.textSubtle)
                        .tracking(1.5)
                        .textCase(.uppercase)

                    Text(mysteryType.displayName)
                        .font(.kaushan(36))
                        .foregroundStyle(theme.textPrimary)
                        .multilineTextAlignment(.center)

                    Spacer().frame(height: 16)

                    Text(blessing)
                        .font(.kefa(14))
                        .foregroundStyle(theme.textSubtle)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .padding(.horizontal, 32)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
                .padding(.horizontal, 32)

                Spacer()

                // Pray Again button
                Button(action: onPrayAgain) {
                    Text("Pray Again")
                        .font(.kefa(17))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Capsule().fill(theme.accent))
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
