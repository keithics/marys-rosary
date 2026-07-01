import SwiftUI

struct HomeView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var session: RosarySessionStore
    @State private var vm = HomeViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                header
                if !session.prayerName.isEmpty {
                    sessionBar
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                }
                mysteryList
                    .padding(.top, 16)
                    .padding(.bottom, 24)
            }
        }
        .background(vm.today.theme.cloud.ignoresSafeArea())
        .ignoresSafeArea(edges: .top)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { vm.updateToday() }
        }
        .fullScreenCover(item: $vm.activeSession) { s in
            ContentView(mysteryType: s.mysteryType, initialBead: s.initialBead, isResuming: s.isResuming)
                .ignoresSafeArea()
        }
    }

    // MARK: - Header

    private var header: some View {
        Text("The Holy Rosary")
            .font(.kaushan(38))
            .foregroundStyle(vm.today.theme.textPrimary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 18)
            .padding(.top, 56)
            .padding(.bottom, 10)
    }

    // MARK: - Session bar

    private var sessionBar: some View {
        let hasSession = !session.prayerName.isEmpty && session.mystery == vm.today
        let label = hasSession ? "Continue" : "Today"

        return Button {
            let resumeBead = hasSession ? session.bead : 0
            vm.startSession(type: vm.today, initialBead: resumeBead, isResuming: hasSession)
        } label: {
            HStack(spacing: 12) {
                MysteryIcon(kind: vm.today.icon)
                    .foregroundStyle(vm.today.accentColor)
                    .frame(width: 22, height: 22)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(vm.today.theme.textSubtle)
                    Text(vm.today.displayName)
                        .font(.system(size: 15, weight: .semibold, design: .serif))
                        .foregroundStyle(vm.today.theme.textPrimary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(vm.today.theme.accent)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.6), in: RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Mystery list

    private var mysteryList: some View {
        VStack(spacing: 16) {
            ForEach(vm.mysteryOrder, id: \.self) { type in
                MysteryCard(type: type, isToday: type == vm.today) {
                    let resumeBead = (type == session.mystery) ? session.bead : 0
                    let isResuming = !session.prayerName.isEmpty && type == session.mystery
                    vm.startSession(type: type, initialBead: resumeBead, isResuming: isResuming)
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

#Preview {
    HomeView()
}
