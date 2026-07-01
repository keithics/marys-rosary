import SwiftUI

struct ContentView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var session: RosarySessionStore
    @EnvironmentObject var delayStore: PrayerDelayStore
    @EnvironmentObject var bgMusic: BackgroundMusicPlayer
    @AppStorage("rosaryZoom") var rosaryZoom: Double = 1.45
    @AppStorage("showPrayerProgress") var showPrayerProgress = true

    @State var vm: PrayerViewModel
    let isResuming: Bool

    init(mysteryType: MysteryType = .forToday(), initialBead: Int = 0, initialPrayer: Int = 0, isResuming: Bool = false) {
        _vm = State(initialValue: PrayerViewModel(mysteryType: mysteryType, initialBead: initialBead, initialPrayer: initialPrayer))
        self.isResuming = isResuming
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                vm.theme.cloud.ignoresSafeArea()

                RosaryView(rosary: vm.rosary, current: $vm.currentBead, zoomLevel: $rosaryZoom, learningMode: $vm.learningMode)
                    .mask(alignment: .top) {
                        VStack(spacing: 0) {
                            LinearGradient(
                                stops: [
                                    .init(color: .clear, location: 0),
                                    .init(color: .black, location: 1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 90)
                            Rectangle()
                        }
                        .ignoresSafeArea()
                    }

                VStack(spacing: 0) {
                    Spacer().frame(height: geo.size.height * 0.33)
                    focusedCard
                        .frame(maxHeight: geo.size.height * 0.52)
                        .padding(.horizontal, 20)
                    Spacer()
                }

                VStack {
                    HStack {
                        closeButton
                        Spacer()
                        zoomToggle
                    }
                    Spacer()
                }
                .padding(.top, 60)
                .padding(.horizontal, 20)

                if !vm.hasStarted {
                    if isResuming {
                        ResumeView(
                            mysteryType: vm.rosary.mysteryType,
                            prayerName: vm.prayer?.title ?? ""
                        ) {
                            withAnimation(.easeInOut(duration: 0.5)) { vm.hasStarted = true }
                        } onStartOver: {
                            session.bead = 0
                            session.prayerName = ""
                            vm.currentBead = 0
                            withAnimation(.easeInOut(duration: 0.5)) { vm.hasStarted = true }
                        } onDismiss: {
                            dismiss()
                        }
                        .transition(.opacity)
                        .zIndex(10)
                    } else {
                        WelcomeView(mysteryType: vm.rosary.mysteryType) {
                            withAnimation(.easeInOut(duration: 0.5)) { vm.hasStarted = true }
                        } onDismiss: {
                            dismiss()
                        }
                        .transition(.opacity)
                        .zIndex(10)
                    }
                }
            }
        }
        .ignoresSafeArea()
        .onChange(of: vm.hasStarted) { _, started in
            guard started else { return }
            session.mystery = vm.rosary.mysteryType
            bgMusic.play()
            vm.startPlayback(delayStore: delayStore)
        }
        .onChange(of: vm.showCompletion) { _, showing in
            if showing {
                vm.audio.stop()
                bgMusic.stop()
            }
        }
        .onChange(of: vm.currentBead) {
            session.bead = vm.currentBead
            session.mystery = vm.rosary.mysteryType
            session.prayerName = vm.currentBead > 0 ? (vm.prayer?.title ?? "") : ""
        }
        .onDisappear {
            vm.audio.stop()
            bgMusic.stop()
        }
        .fullScreenCover(isPresented: $vm.showCompletion) {
            CompletionView(mysteryType: vm.rosary.mysteryType) {
                dismiss()
            }
            .ignoresSafeArea()
        }
        .safeAreaInset(edge: .bottom) {
            if vm.hasStarted {
                controlBar.padding(.bottom, 16)
            }
        }
    }
}

#Preview {
    ContentView(mysteryType: .joyful)
}
