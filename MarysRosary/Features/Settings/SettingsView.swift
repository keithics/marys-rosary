import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var delayStore: PrayerDelayStore
    @EnvironmentObject private var bgMusic: BackgroundMusicPlayer
    @AppStorage("showMagicEffect") private var showMagicEffect = false
    @AppStorage("showPrayerProgress") private var showPrayerProgress = true
    @State private var vm = SettingsViewModel()
    @State private var showInfo = false
    @State private var showFeedback = false
    @Environment(\.scenePhase) private var scenePhase

    private let tabs = ["Audio", "Mysteries", "Display"]

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                    tabPicker.padding(.horizontal, 16).padding(.bottom, 16)
                    VStack(spacing: 28) {
                        switch vm.selectedTab {
                        case 0:
                            backgroundMusicSection
                            audioTimingSection
                        case 1:
                            mysteriesSection
                        default:
                            displaySection
                        }
                    }
                    Spacer().frame(height: 40)
                }
            }
            .background(vm.today.theme.cloud.ignoresSafeArea())
            .ignoresSafeArea(edges: .top)

            if let (prayer, theme) = vm.previewingMystery {
                MysteryDurationOverlay(
                    prayer: prayer,
                    theme: theme,
                    duration: Double(delayStore.responseSeconds(for: prayer)),
                    onStop: { vm.previewingMystery = nil }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.92)))
            }

            if let id = vm.playingId, let prayer = vm.prayers.first(where: { $0.id == id }) {
                let responseTotal = Double(delayStore.responseSeconds(for: prayer))
                AudioPreviewOverlay(
                    prayer: prayer,
                    theme: vm.today.theme,
                    player: vm.preview,
                    responseTotal: responseTotal,
                    onStop: { vm.preview.stop(); vm.playingId = nil }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.92)))
            }
        }
        .animation(.spring(duration: 0.3), value: vm.playingId)
        .onAppear { vm.loadPrayers() }
        .onDisappear { vm.preview.stop() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { vm.updateToday() }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Settings")
                .font(.kaushan(38))
                .foregroundStyle(vm.today.theme.textPrimary)
            Spacer()
            HStack(spacing: 16) {
                Button { showFeedback = true } label: {
                    Image(systemName: "envelope")
                        .font(.system(size: 20))
                        .foregroundStyle(vm.today.theme.textPrimary.opacity(0.7))
                }
                .buttonStyle(.plain)
                Button { showInfo = true } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 22))
                        .foregroundStyle(vm.today.theme.textPrimary.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 56)
        .padding(.bottom, 12)
        .sheet(isPresented: $showInfo) { InfoView() }
        .sheet(isPresented: $showFeedback) { FeedbackView() }
    }

    // MARK: - Pill tab picker

    private var tabPicker: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { i in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { vm.selectedTab = i }
                } label: {
                    Text(tabs[i])
                        .font(.system(size: 13, weight: vm.selectedTab == i ? .semibold : .regular))
                        .foregroundStyle(vm.selectedTab == i ? vm.today.theme.textPrimary : vm.today.theme.textSubtle)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            vm.selectedTab == i
                                ? Color.white.opacity(0.9)
                                : Color.clear,
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(.ultraThinMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }

    // MARK: - Audio Timing

    private var audioTimingSection: some View {
        let prayersWithDelays = vm.prayers.filter { $0.texts.contains(where: { $0.type == .response }) }
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "timer.circle")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(vm.today.theme.accent)
                Text("AUDIO TIMING")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(vm.today.theme.textSubtle)
                Spacer()
                if !delayStore.overrides.isEmpty {
                    Button("Reset All") {
                        withAnimation { delayStore.resetAll() }
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(vm.today.theme.accent)
                }
            }
            .padding(.horizontal, 20)

            VStack(spacing: 1) {
                ForEach(Array(prayersWithDelays.enumerated()), id: \.element.id) { idx, prayer in
                    PrayerDelayRow(
                        prayer: prayer,
                        theme: vm.today.theme,
                        delayStore: delayStore,
                        isPlayingPreview: vm.playingId == prayer.id,
                        isLast: idx == prayersWithDelays.count - 1,
                        onPreview: { vm.togglePreview(prayer, delayStore: delayStore) }
                    )
                }
            }
            .background(Color.white.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Background Music

    private var backgroundMusicSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "music.note")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(vm.today.theme.accent)
                Text("BACKGROUND MUSIC")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(vm.today.theme.textSubtle)
            }
            .padding(.horizontal, 20)

            VStack(spacing: 0) {
                Toggle(isOn: $bgMusic.isMuted) {
                    Text("Mute")
                        .font(.system(size: 15, weight: .medium, design: .serif))
                        .foregroundStyle(vm.today.theme.textPrimary)
                }
                .tint(vm.today.theme.accent)
                .padding(.horizontal, 18)
                .padding(.vertical, 14)

                Divider().opacity(0.3).padding(.horizontal, 14)

                HStack(spacing: 12) {
                    Image(systemName: "speaker.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(vm.today.theme.textSubtle)
                        .frame(width: 18)
                    Slider(value: $bgMusic.volume, in: 0...1)
                        .tint(vm.today.theme.accent)
                        .disabled(bgMusic.isMuted)
                        .opacity(bgMusic.isMuted ? 0.4 : 1)
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(vm.today.theme.textSubtle)
                        .frame(width: 18)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
            }
            .background(Color.white.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Mysteries

    private var mysteriesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(MysteryType.allCases, id: \.self) { type in
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        MysteryIcon(kind: type.icon)
                            .foregroundStyle(type.accentColor)
                            .frame(width: 20, height: 20)
                        Text(type.displayName.uppercased())
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(1.2)
                            .foregroundStyle(vm.today.theme.textSubtle)
                    }
                    .padding(.horizontal, 20)

                    let mysteries = Mystery.load(type: type)
                    VStack(spacing: 1) {
                        ForEach(Array(mysteries.enumerated()), id: \.offset) { idx, mystery in
                            let prayer = mystery.asPrayer(type: type, index: idx)
                            MysteryDelayRow(
                                prayer: prayer,
                                theme: vm.today.theme,
                                delayStore: delayStore,
                                isPlayingPreview: vm.previewingMystery?.0.id == prayer.id,
                                isLast: idx == mysteries.count - 1,
                                onPreview: {
                                    if vm.previewingMystery?.0.id == prayer.id {
                                        vm.previewingMystery = nil
                                    } else {
                                        vm.previewingMystery = (prayer, type.theme)
                                    }
                                }
                            )
                        }
                    }
                    .background(Color.white.opacity(0.72))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
                    .padding(.horizontal, 16)
                }
            }
        }
    }

    // MARK: - Display

    private var displaySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(vm.today.theme.accent)
                Text("DISPLAY")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(vm.today.theme.textSubtle)
            }
            .padding(.horizontal, 20)

            VStack(spacing: 0) {
                Toggle(isOn: $showPrayerProgress) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Prayer Progress")
                            .font(.system(size: 15, weight: .medium, design: .serif))
                            .foregroundStyle(vm.today.theme.textPrimary)
                        Text("Animated border on prayer card")
                            .font(.system(size: 11))
                            .foregroundStyle(vm.today.theme.textSubtle)
                    }
                }
                .tint(vm.today.theme.accent)
                .padding(.horizontal, 18)
                .padding(.vertical, 14)

                Divider().opacity(0.25).padding(.horizontal, 14)

                Toggle(isOn: $showMagicEffect) {
                    Text("Particle Effects")
                        .font(.system(size: 15, weight: .medium, design: .serif))
                        .foregroundStyle(vm.today.theme.textPrimary)
                }
                .tint(vm.today.theme.accent)
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
            }
            .background(Color.white.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(PrayerDelayStore())
}
