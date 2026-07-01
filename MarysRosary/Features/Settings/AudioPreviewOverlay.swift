import SwiftUI

struct AudioPreviewOverlay: View {
    let prayer: Prayer
    let theme: MysteryTheme
    let player: PreviewPlayer
    var responseTotal: Double = 0
    let onStop: () -> Void

    @State private var progress: Double = 0
    @State private var remaining: Double = 0
    @State private var ringTimer: Timer?

    private var isInResponse: Bool { responseTotal > 0 && remaining <= responseTotal && remaining > 0 }
    private var leaderFraction: Double {
        guard responseTotal > 0, player.duration > 0 else { return 1 }
        return (player.duration - responseTotal) / player.duration
    }
    private let gap: Double = 0.018

    private var countdownText: String {
        String(format: "%.2fs", max(0, remaining))
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
                .onTapGesture { onStop() }

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .trim(from: 0, to: responseTotal > 0 ? leaderFraction - gap / 2 : 1)
                        .stroke(Color.white.opacity(0.18), style: StrokeStyle(lineWidth: 6, lineCap: .butt))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))

                    if responseTotal > 0 {
                        Circle()
                            .trim(from: leaderFraction + gap / 2, to: 1)
                            .stroke(theme.accent.opacity(0.25), style: StrokeStyle(lineWidth: 6, lineCap: .butt))
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                    }

                    Circle()
                        .trim(from: 0, to: min(progress, responseTotal > 0 ? leaderFraction - gap / 2 : 1))
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.1), value: progress)

                    if responseTotal > 0 && progress > leaderFraction + gap / 2 {
                        Circle()
                            .trim(from: leaderFraction + gap / 2, to: progress)
                            .stroke(theme.accent, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.1), value: progress)
                    }

                    Circle()
                        .fill(.white)
                        .frame(width: 88, height: 88)
                        .shadow(color: .black.opacity(0.15), radius: 12, y: 4)

                    Button(action: onStop) {
                        Image(systemName: player.isPlaying ? "stop.fill" : "play.fill")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(theme.accent)
                    }
                    .buttonStyle(.plain)
                }

                VStack(spacing: 6) {
                    Text(prayer.title)
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundStyle(.white)
                    Text(countdownText)
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        .foregroundStyle(isInResponse ? theme.accent : .white.opacity(0.75))
                        .contentTransition(.numericText(countsDown: true))
                        .animation(.linear(duration: 0.1), value: remaining)
                    if responseTotal > 0 {
                        Text("Response")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(0.8)
                            .foregroundStyle(isInResponse ? theme.accent : .white.opacity(0.35))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                (isInResponse ? theme.accent.opacity(0.25) : Color.white.opacity(0.12)),
                                in: Capsule()
                            )
                            .animation(.easeInOut(duration: 0.3), value: isInResponse)
                    }
                }
            }
            .padding(40)
            .background(Color(red: 0.13, green: 0.13, blue: 0.15).opacity(0.95), in: RoundedRectangle(cornerRadius: 28))
            .padding(.horizontal, 48)
        }
        .onAppear { startRing() }
        .onDisappear { ringTimer?.invalidate() }
        .onChange(of: player.isPlaying) { _, playing in if !playing { progress = 1; remaining = 0 } }
    }

    private func startRing() {
        progress = 0
        let dur = max(1, player.duration)
        remaining = dur
        let step = 0.1 / dur
        ringTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                guard player.isPlaying else { ringTimer?.invalidate(); return }
                progress = min(progress + step, 1.0)
                remaining = max(0, remaining - 0.1)
            }
        }
    }
}
