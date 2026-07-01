import SwiftUI

struct PrayView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var showPrayer = false
    @State private var selectedMystery: MysteryType = .forToday()
    @State private var today: MysteryType = .forToday()

    private let mysteryOrder: [MysteryType] = [.joyful, .luminous, .sorrowful, .glorious]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(mysteryOrder, id: \.self) { type in
                        PrayMysteryRow(type: type, isToday: type == today) {
                            selectedMystery = type
                            showPrayer = true
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 16)
            }
            .navigationTitle("Pray")
            .navigationBarTitleDisplayMode(.large)
        }
        .fullScreenCover(isPresented: $showPrayer) {
            ContentView(mysteryType: selectedMystery)
                .ignoresSafeArea()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { today = .forToday() }
        }
    }
}
