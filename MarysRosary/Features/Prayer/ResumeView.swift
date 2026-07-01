import SwiftUI

struct ResumeView: View {
    let mysteryType: MysteryType
    let prayerName: String
    let onResume: () -> Void
    let onStartOver: () -> Void
    let onDismiss: () -> Void

    @State private var appeared = false

    private var theme: MysteryTheme { mysteryType.theme }

    var body: some View {
        ZStack {
            theme.cloud.ignoresSafeArea()

            VStack(spacing: 0) {
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

                VStack(spacing: 8) {
                    Text("Continue where you left off")
                        .font(.kefa(13))
                        .foregroundStyle(theme.textSubtle)
                        .tracking(0.5)
                        .textCase(.uppercase)

                    Text(mysteryType.displayName)
                        .font(.kaushan(36))
                        .foregroundStyle(theme.textPrimary)
                        .multilineTextAlignment(.center)

                    HStack(spacing: 6) {
                        Image(systemName: "bookmark.fill")
                            .font(.system(size: 11))
                        Text(prayerName)
                            .font(.kefa(14))
                    }
                    .foregroundStyle(theme.accent)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(theme.accent.opacity(0.12)))
                    .padding(.top, 4)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
                .padding(.horizontal, 32)

                Spacer()

                VStack(spacing: 12) {
                    Button(action: onResume) {
                        Text("Resume Prayer")
                            .font(.kefa(17))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Capsule().fill(theme.accent))
                            .shadow(color: theme.accent.opacity(0.4), radius: 12, y: 6)
                    }

                    Button(action: onStartOver) {
                        Text("Start Over")
                            .font(.kefa(15))
                            .foregroundStyle(theme.textSubtle)
                    }
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
