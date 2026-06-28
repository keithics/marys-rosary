import SwiftUI

struct ContentView: View {
    private let rosary = Rosary.standard
    @State private var currentBead = 0
    @State private var currentPrayer = 0
    @State private var currentText = 0
    @AppStorage("zoomMode") private var modeRaw: String = ZoomMode.focused.rawValue
    @State private var mode: ZoomMode = .focused
    private func setMode(_ m: ZoomMode) { mode = m; modeRaw = m.rawValue }
    @State private var isPlaying = false
    @State private var hasStarted = false

    // Learning mode: when on, tapping a bead jumps directly to it.
    // Off by default — reserved for future implementation.
    @State private var learningMode: Bool = false
    @State private var showCompletion = false
    @State private var showQueue = false

    private let navy = Color(red: 0.16, green: 0.20, blue: 0.34)
    private var bead: Bead { rosary.sequence[min(currentBead, rosary.sequence.count - 1)] }
    private var prayer: Prayer? { bead.prayers.indices.contains(currentPrayer) ? bead.prayers[currentPrayer] : bead.prayers.first }
    private var prayerText: String {
        guard let prayer else { return "" }
        return prayer.texts.indices.contains(currentText) ? prayer.texts[currentText] : ""
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                SkyBackground()

                RosaryView(rosary: rosary, current: $currentBead, mode: $mode, learningMode: $learningMode)

                if hasStarted {
                    if mode == .full {
                        // In full view: card floats inside the rosary oval
                        VStack(spacing: 0) {
                            Spacer().frame(height: geo.size.height * 0.14)
                            prayerCard(glass: false)
                                .frame(maxWidth: geo.size.width * 0.52, maxHeight: geo.size.height * 0.38)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        // In focused view: card anchored below the active bead
                        VStack(spacing: 0) {
                            Spacer().frame(height: geo.size.height * 0.33)
                            prayerCard()
                                .frame(maxHeight: geo.size.height * 0.45)
                                .padding(.horizontal, 20)
                            Spacer()
                        }
                    }

                    // Controls pinned to bottom
                    VStack {
                        Spacer()
                        controlBar.padding(.bottom, 36)
                    }
                } else {
                    VStack {
                        Spacer()
                        startButton.padding(.bottom, 48)
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
        }
        .ignoresSafeArea()
        .onAppear { mode = ZoomMode(rawValue: modeRaw) ?? .focused }
        .fullScreenCover(isPresented: $showCompletion) {
            CompletionView(mysteryType: rosary.mysteryType) {
                showCompletion = false
                currentBead = 0
                currentPrayer = 0
                currentText = 0
                hasStarted = false
                isPlaying = false
            }
            .ignoresSafeArea()
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
        VStack(spacing: 10) {
            HStack {
                Spacer()
                Button { showQueue = true } label: {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(navy.opacity(0.7))
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(.white.opacity(0.85)))
                        .shadow(color: .black.opacity(0.08), radius: 5, y: 2)
                }
            }
            .padding(.horizontal, 24)

            // Centered ⏮ ⏸/▶ ⏭ pill
            HStack(spacing: 28) {
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
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(Capsule().fill(.white.opacity(0.85)))
            .shadow(color: .black.opacity(0.10), radius: 10, y: 4)
        }
        .sheet(isPresented: $showQueue) {
            QueueSheet(
                rosary: rosary,
                currentBead: currentBead,
                onSelect: { beadIndex in
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentBead = beadIndex
                        currentPrayer = 0
                        currentText = 0
                    }
                    showQueue = false
                },
                onStop: {
                    showQueue = false
                    resetPrayer()
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Zoom toggle

    private var zoomToggle: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.6)) {
                setMode(mode == .full ? .focused : .full)
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

    // MARK: - Prayer card (liquid glass)

    private func prayerCard(glass: Bool = true) -> some View {
        VStack(alignment: .center, spacing: 0) {
            // Title + step badge
            HStack(alignment: .center, spacing: 8) {
                Text(prayer?.title ?? "")
                    .font(.system(size: 17, weight: .semibold, design: .serif))
                    .foregroundStyle(navy)

                if let step = bead.decadeStep, let total = bead.decadeTotal {
                    Text("\(step)/\(total)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(navy.opacity(0.50))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(navy.opacity(0.08)))
                } else if let prayer, prayer.texts.count > 1 {
                    Text("\(currentText + 1)/\(prayer.texts.count)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(navy.opacity(0.50))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(navy.opacity(0.08)))
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider().opacity(0.25).padding(.horizontal, 16)

            // Prayer text is top-aligned and constrained so long prayers do not
            // spill into the rosary artwork in expanded mode.
            ScrollView(showsIndicators: false) {
                Text(prayerText)
                    .font(.system(size: 14, weight: .regular, design: .serif))
                    .foregroundStyle(navy.opacity(0.78))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .background(glass ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(.clear),
                    in: RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(.white.opacity(glass ? 0.45 : 0), lineWidth: 1)
        )
        .shadow(color: .black.opacity(glass ? 0.08 : 0), radius: 12, y: 4)
        .id("\(currentBead)-\(currentPrayer)-\(currentText)")
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: currentText)
        .animation(.easeInOut(duration: 0.3), value: currentPrayer)
        .animation(.easeInOut(duration: 0.3), value: currentBead)
    }

    // MARK: - Helpers

    private func goNext() {
        withAnimation(.easeInOut(duration: 0.5)) {
            let texts = prayer?.texts ?? []
            if currentText < texts.count - 1 {
                currentText += 1
            } else if currentPrayer < bead.prayers.count - 1 {
                currentPrayer += 1
                currentText = 0
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
                    currentText = 0
                }
            }
        }
    }

    private func goBack() {
        withAnimation(.easeInOut(duration: 0.5)) {
            if currentText > 0 {
                currentText -= 1
            } else if currentPrayer > 0 {
                currentPrayer -= 1
                currentText = max(bead.prayers[currentPrayer].texts.count - 1, 0)
            } else if currentBead > 0 {
                var prev = currentBead - 1
                while prev > 0 && rosary.sequence[prev].isVisualOnly {
                    prev -= 1
                }
                currentBead = prev
                currentPrayer = rosary.sequence[currentBead].prayers.count - 1
                currentText = max(rosary.sequence[currentBead].prayers[currentPrayer].texts.count - 1, 0)
            }
            // at bead 0, prayer 0 — do nothing
        }
    }

    private func togglePlay() {
        isPlaying.toggle()
    }

    private func resetPrayer() {
        withAnimation(.easeInOut(duration: 0.4)) {
            currentBead = 0
            currentPrayer = 0
            currentText = 0
            hasStarted = false
            isPlaying = false
        }
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
