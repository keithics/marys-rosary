import SwiftUI

struct ContentView: View {
    private let rosary = Rosary.standard
    @State private var currentBead = 0
    @State private var currentPrayer = 0
    @State private var mode: ZoomMode = .focused
    @State private var isPlaying = false
    @State private var hasStarted = false

    // Learning mode: when on, tapping a bead jumps directly to it.
    // Off by default — reserved for future implementation.
    @State private var learningMode: Bool = false
    @State private var showCompletion = false

    private let navy = Color(red: 0.16, green: 0.20, blue: 0.34)
    private var bead: Bead { rosary.sequence[min(currentBead, rosary.sequence.count - 1)] }
    private var prayer: Prayer? { bead.prayers.indices.contains(currentPrayer) ? bead.prayers[currentPrayer] : bead.prayers.first }

    var body: some View {
        ZStack {
            SkyBackground()

            RosaryView(rosary: rosary, current: $currentBead, mode: $mode, learningMode: $learningMode)

            prayerLabel

            VStack {
                Spacer()
                if hasStarted {
                    controlBar
                        .padding(.bottom, 36)
                } else {
                    startButton
                        .padding(.bottom, 48)
                }
            }

            // Zoom toggle — top-right
            VStack {
                HStack {
                    Spacer()
                    zoomToggle
                }
                Spacer()
            }
            .padding(.top, 60)
            .padding(.trailing, 20)
        }
        .ignoresSafeArea()
        .fullScreenCover(isPresented: $showCompletion) {
            CompletionView(mysteryType: rosary.mysteryType) {
                showCompletion = false
                currentBead = 0
                currentPrayer = 0
                hasStarted = false
                isPlaying = false
                mode = .focused
            }
        }
    }

    // MARK: - Start button

    private var startButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.4)) {
                hasStarted = true
                isPlaying = true
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "hands.sparkles.fill")
                    .font(.system(size: 16))
                Text("Begin Prayer")
                    .font(.system(size: 18, weight: .medium, design: .serif))
            }
            .foregroundStyle(navy)
            .padding(.horizontal, 32)
            .padding(.vertical, 14)
            .background(Capsule().fill(.white.opacity(0.90)))
            .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
        }
    }

    // MARK: - Playback controls

    private var controlBar: some View {
        VStack(spacing: 12) {
            // Step indicator
            Text(pillText)
                .font(.system(size: 13, weight: .medium, design: .serif))
                .foregroundStyle(navy.opacity(0.6))

            // Back | Play-Pause | Next
            HStack(spacing: 40) {
                Button { goBack() } label: {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(navy)
                        .frame(width: 44, height: 44)
                }

                Button { togglePlay() } label: {
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 60, height: 60)
                            .shadow(color: .black.opacity(0.14), radius: 8, y: 3)
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 26, weight: .medium))
                            .foregroundStyle(navy)
                            .offset(x: isPlaying ? 0 : 2)
                    }
                }

                Button { goNext() } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(navy)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 14)
            .background(Capsule().fill(.white.opacity(0.85)))
            .shadow(color: .black.opacity(0.10), radius: 10, y: 4)
        }
    }

    // MARK: - Zoom toggle

    private var zoomToggle: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.6)) {
                mode = (mode == .full) ? .focused : .full
            }
        } label: {
            Image(systemName: mode == .full ? "plus.magnifyingglass" : "minus.magnifyingglass")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(navy)
                .frame(width: 44, height: 44)
                .background(Circle().fill(.white.opacity(0.85)))
                .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
        }
    }

    // MARK: - Prayer label

    private var prayerLabel: some View {
        VStack(spacing: 10) {
            Text((prayer?.title ?? "") + "…")
                .font(.system(size: 30, weight: .regular, design: .serif))
                .foregroundStyle(navy)

            HStack(spacing: 12) {
                divider
                Image(systemName: "sparkle")
                    .font(.system(size: 11))
                    .foregroundStyle(Color(red: 0.78, green: 0.62, blue: 0.28))
                divider
            }
            .frame(width: 150)
        }
        .id("\(currentBead)-\(currentPrayer)")
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: currentPrayer)
        .animation(.easeInOut(duration: 0.3), value: currentBead)
    }

    private var divider: some View {
        Rectangle()
            .fill(navy.opacity(0.35))
            .frame(height: 1)
    }

    // MARK: - Helpers

    private var pillText: String {
        if let step = bead.decadeStep { return "\(step) / 10" }
        if bead.prayers.count > 1 {
            return "\(currentPrayer + 1) / \(bead.prayers.count)"
        }
        return "✦"
    }

    private func goNext() {
        withAnimation(.easeInOut(duration: 0.5)) {
            if currentPrayer < bead.prayers.count - 1 {
                currentPrayer += 1
            } else {
                var next = (currentBead + 1) % rosary.sequence.count
                while rosary.sequence[next].isVisualOnly {
                    next = (next + 1) % rosary.sequence.count
                }
                if next == 0 {
                    showCompletion = true
                } else {
                    currentBead = next
                    currentPrayer = 0
                    mode = .focused
                }
            }
        }
    }

    private func goBack() {
        withAnimation(.easeInOut(duration: 0.5)) {
            if currentPrayer > 0 {
                currentPrayer -= 1
            } else {
                var prev = (currentBead - 1 + rosary.sequence.count) % rosary.sequence.count
                while rosary.sequence[prev].isVisualOnly {
                    prev = (prev - 1 + rosary.sequence.count) % rosary.sequence.count
                }
                currentBead = prev
                currentPrayer = rosary.sequence[currentBead].prayers.count - 1
                mode = .focused
            }
        }
    }

    private func togglePlay() {
        isPlaying.toggle()
    }
}

/// Soft, ethereal cloudy-sky backdrop.
struct SkyBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.80, green: 0.87, blue: 0.95),
                    Color(red: 0.93, green: 0.95, blue: 0.98),
                    Color(red: 0.99, green: 0.99, blue: 1.00)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            cloud(width: 320, height: 120).offset(x: -60, y: -220).opacity(0.9)
            cloud(width: 260, height: 100).offset(x: 110, y: -40).opacity(0.7)
            cloud(width: 300, height: 110).offset(x: -90, y: 230).opacity(0.8)
            cloud(width: 240, height: 90).offset(x: 120, y: 320).opacity(0.7)
        }
    }

    private func cloud(width: CGFloat, height: CGFloat) -> some View {
        Ellipse()
            .fill(.white)
            .frame(width: width, height: height)
            .blur(radius: 40)
    }
}

#Preview {
    ContentView()
}
