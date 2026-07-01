import SwiftUI

struct RosarySession: Identifiable {
    let id = UUID()
    let mysteryType: MysteryType
    let initialBead: Int
    var isResuming: Bool = false
}

struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var session: RosarySessionStore
    @State private var today: MysteryType = .forToday()
    @State private var activeSession: RosarySession? = nil

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                HomeView()
            }
            Tab("Prayers", systemImage: "book.fill") {
                PrayersView()
            }
            Tab("Settings", systemImage: "gearshape.fill") {
                SettingsView()
            }
        }
        .tint(today.theme.accent)
        .toolbarColorScheme(.dark, for: .tabBar)
        .tabBarMinimizeBehaviorIfAvailable()
        .miniMysteryAccessory(mystery: session.prayerName.isEmpty ? today : session.mystery) {
            let isResuming = !session.prayerName.isEmpty
            let bead = isResuming ? session.bead : 0
            let mystery = isResuming ? session.mystery : today
            activeSession = RosarySession(mysteryType: mystery, initialBead: bead, isResuming: isResuming)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                let newToday = MysteryType.forToday()
                if newToday != today {
                    session.bead = 0
                    session.prayerName = ""
                    session.mystery = newToday
                }
                today = newToday
            }
        }
        .fullScreenCover(item: $activeSession) { s in
            ContentView(mysteryType: s.mysteryType, initialBead: s.initialBead, isResuming: s.isResuming)
                .ignoresSafeArea()
        }
    }
}

private struct MiniMysteryBar: View {
    let mystery: MysteryType
    let onPray: () -> Void

    var body: some View {
        if #available(iOS 26, *) {
            PlacementAwareMiniBar(mystery: mystery, onPray: onPray)
        } else {
            MiniMysteryExpanded(mystery: mystery, onPray: onPray)
        }
    }
}

@available(iOS 26, *)
private struct PlacementAwareMiniBar: View {
    let mystery: MysteryType
    let onPray: () -> Void

    @Environment(\.tabViewBottomAccessoryPlacement) private var placement

    var body: some View {
        if placement == .inline {
            MiniMysteryInline(mystery: mystery, onPray: onPray)
        } else {
            MiniMysteryExpanded(mystery: mystery, onPray: onPray)
        }
    }
}

private struct MiniMysteryInline: View {
    let mystery: MysteryType
    let onPray: () -> Void
    @EnvironmentObject private var session: RosarySessionStore

    var body: some View {
        HStack(spacing: 8) {
            MysteryIcon(kind: mystery.icon)
                .foregroundStyle(mystery.accentColor)
                .frame(width: 24, height: 16)

            Text(mystery.displayName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(mystery.theme.textPrimary)
                .lineLimit(1)

            if !session.prayerName.isEmpty {
                Text("·")
                    .font(.system(size: 13))
                    .foregroundStyle(mystery.theme.textSubtle.opacity(0.5))
                Text(session.prayerName)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(mystery.theme.textSubtle)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Button(action: onPray) {
                Image(systemName: "play.fill")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(mystery.theme.textPrimary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .contentShape(Rectangle())
        .onTapGesture { onPray() }
    }
}

private struct MiniMysteryExpanded: View {
    let mystery: MysteryType
    let onPray: () -> Void
    @EnvironmentObject private var session: RosarySessionStore

    var body: some View {
        HStack(spacing: 12) {
            MysteryIcon(kind: mystery.icon)
                .foregroundStyle(mystery.accentColor)
                .frame(width: 22, height: 22)

            VStack(alignment: .leading, spacing: 1) {
                Text(session.prayerName.isEmpty ? "Today" : "Continue")
                    .font(.system(size: 11))
                    .foregroundStyle(mystery.theme.textSubtle)
                HStack(spacing: 4) {
                    Text(mystery.displayName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(mystery.theme.textPrimary)
                    if !session.prayerName.isEmpty {
                        Text("· \(session.prayerName)")
                            .font(.system(size: 12))
                            .foregroundStyle(mystery.theme.textSubtle)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            Button(action: onPray) {
                Image(systemName: "play.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(mystery.theme.textPrimary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onTapGesture { onPray() }
    }
}

// MARK: - Bottom accessory availability shim

private extension View {
    @ViewBuilder
    func miniMysteryAccessory(mystery: MysteryType, onPray: @escaping () -> Void) -> some View {
        if #available(iOS 26, *) {
            self.tabViewBottomAccessory {
                MiniMysteryBar(mystery: mystery, onPray: onPray)
            }
        } else {
            self
        }
    }

    @ViewBuilder
    func tabBarMinimizeBehaviorIfAvailable() -> some View {
        if #available(iOS 26, *) {
            self.tabBarMinimizeBehavior(.onScrollDown)
        } else {
            self
        }
    }
}

// MARK: - Themed Tab Bar

private struct ThemedTabBar: View {
    @Binding var selectedTab: Int
    let theme: MysteryTheme

    private struct TabItem {
        let label: String
        let icon: Icon
        enum Icon { case sf(String); case asset(String) }
    }

    private let items: [TabItem] = [
        TabItem(label: "Home",       icon: .sf("house.fill")),
        TabItem(label: "Mysteries",  icon: .asset("icon-rosary")),
        TabItem(label: "Prayers",    icon: .sf("book.fill")),
        TabItem(label: "More",       icon: .sf("ellipsis.circle")),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items.indices, id: \.self) { idx in
                tabButton(item: items[idx], index: idx)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.13), radius: 20, y: 6)
        )
        .padding(.horizontal, 20)
    }

    private func tabButton(item: TabItem, index: Int) -> some View {
        let isSelected = index == selectedTab
        let fgColor: Color = isSelected ? theme.accent : theme.textSubtle.opacity(0.55)

        return Button {
            selectedTab = index
        } label: {
            VStack(spacing: 3) {
                iconView(item.icon, color: fgColor)
                    .frame(width: 22, height: 22)
                Text(item.label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(fgColor)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.18), value: isSelected)
    }

    @ViewBuilder
    private func iconView(_ icon: TabItem.Icon, color: Color) -> some View {
        switch icon {
        case .sf(let name):
            Image(systemName: name)
                .resizable()
                .scaledToFit()
                .foregroundStyle(color)
        case .asset(let name):
            Image(name)
                .resizable()
                .scaledToFit()
                .foregroundStyle(color)
        }
    }
}

#Preview {
    RootView()
}
