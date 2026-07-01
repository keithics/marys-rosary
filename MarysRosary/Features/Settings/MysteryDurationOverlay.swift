import SwiftUI

struct MysteryDurationOverlay: View {
    let prayer: Prayer
    let theme: MysteryTheme
    let duration: Double
    let onStop: () -> Void

    @State private var remaining: Double = 0
    @State private var progress: Double = 0
    @State private var countTimer: Timer?

    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
                .onTapGesture { stop() }

            VStack(spacing: 0) {
                HStack {
                    Text(prayer.title)
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundStyle(theme.textPrimary)
                    Spacer()
                    Button(action: stop) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(theme.textSubtle.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

                Divider().foregroundStyle(theme.textSubtle.opacity(0.3))

                ScrollView(showsIndicators: false) {
                    Text(prayer.texts.first?.text ?? "")
                        .font(.system(size: 16, design: .serif))
                        .foregroundStyle(theme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                }

                Divider().foregroundStyle(theme.textSubtle.opacity(0.3))

                HStack(spacing: 8) {
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(theme.accent.opacity(0.15))
                            .frame(height: 4)
                        GeometryReader { geo in
                            Capsule()
                                .fill(theme.accent)
                                .frame(width: geo.size.width * progress, height: 4)
                                .animation(.linear(duration: 0.1), value: progress)
                        }
                        .frame(height: 4)
                    }
                    Text("\(Int(ceil(remaining)))s")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.accent)
                        .monospacedDigit()
                        .frame(minWidth: 32, alignment: .trailing)
                        .contentTransition(.numericText(countsDown: true))
                        .animation(.linear(duration: 0.1), value: remaining)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
            }
            .background(theme.cloud)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.2), radius: 30, y: 10)
            .padding(.horizontal, 20)
            .frame(maxHeight: UIScreen.main.bounds.height * 0.6)
        }
        .onAppear { start() }
        .onDisappear { countTimer?.invalidate() }
    }

    private func start() {
        remaining = duration
        progress = 0
        countTimer?.invalidate()
        countTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { t in
            remaining = max(0, remaining - 0.1)
            progress = duration > 0 ? (duration - remaining) / duration : 1
            if remaining <= 0 {
                t.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { onStop() }
            }
        }
    }

    private func stop() {
        countTimer?.invalidate()
        onStop()
    }
}
