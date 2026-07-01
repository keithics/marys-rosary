import SwiftUI

// MARK: - Models

struct PrayerItem: Codable, Identifiable {
    let id: String
    let title: String
    let texts: [String]
}

struct PrayerGroup: Codable, Identifiable {
    let id: String
    let group: String
    let icon: String
    let prayers: [PrayerItem]
}

// MARK: - Main view

struct PrayersView: View {
    @State private var groups: [PrayerGroup] = []
    @State private var selected: PrayerItem? = nil
    @State private var today: MysteryType = .forToday()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                header
                groupList
                    .padding(.top, 16)
                    .padding(.bottom, 32)
            }
        }
        .background(today.theme.cloud.ignoresSafeArea())
        .ignoresSafeArea(edges: .top)
        .onAppear { loadGroups() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { today = .forToday() }
        }
        .sheet(item: $selected) { prayer in
            PrayerDetailSheet(prayer: prayer, theme: today.theme)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center) {
            Text("Prayers")
                .font(.kaushan(38))
                .foregroundStyle(today.theme.textPrimary)
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.top, 56)
        .padding(.bottom, 10)
    }

    // MARK: - Group list

    private var groupList: some View {
        VStack(spacing: 28) {
            ForEach(groups) { group in
                PrayerGroupSection(group: group, theme: today.theme) { prayer in
                    selected = prayer
                }
            }
        }
    }

    // MARK: - Data

    private func loadGroups() {
        guard let url = Bundle.main.url(forResource: "standalone-prayers", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([PrayerGroup].self, from: data)
        else { return }
        groups = decoded
    }
}

// MARK: - Group section

private struct PrayerGroupSection: View {
    let group: PrayerGroup
    let theme: MysteryTheme
    let onSelect: (PrayerItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Section header
            HStack(spacing: 8) {
                Image(systemName: group.icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(theme.accent)
                Text(group.group.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(theme.textSubtle)
            }
            .padding(.horizontal, 20)

            // Prayer cards
            VStack(spacing: 1) {
                ForEach(Array(group.prayers.enumerated()), id: \.element.id) { index, prayer in
                    PrayerRow(
                        prayer: prayer,
                        theme: theme,
                        isFirst: index == 0,
                        isLast: index == group.prayers.count - 1
                    ) {
                        onSelect(prayer)
                    }
                }
            }
            .background(Color.white.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Prayer row

private struct PrayerRow: View {
    let prayer: PrayerItem
    let theme: MysteryTheme
    let isFirst: Bool
    let isLast: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Text(prayer.title)
                    .font(.system(size: 15, weight: .medium, design: .serif))
                    .foregroundStyle(theme.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(theme.accent.opacity(0.45))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .overlay(alignment: .bottom) {
                if !isLast {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 0.5)
                        .padding(.leading, 18)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Detail sheet

struct PrayerDetailSheet: View {
    let prayer: PrayerItem
    let theme: MysteryTheme
    @Environment(\.dismiss) private var dismiss

    private let navy = Color(red: 0.16, green: 0.20, blue: 0.34)

    var body: some View {
        ZStack(alignment: .top) {
            Color(red: 0.99, green: 0.97, blue: 0.94).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Text(prayer.title)
                        .font(.system(size: 26, weight: .semibold, design: .serif))
                        .foregroundStyle(navy)
                        .multilineTextAlignment(.center)
                        .padding(.top, 52)
                        .padding(.horizontal, 28)

                    HStack(spacing: 6) {
                        Rectangle().fill(theme.accent.opacity(0.30)).frame(height: 0.5)
                        Rectangle()
                            .fill(theme.accent.opacity(0.80))
                            .frame(width: 5, height: 5)
                            .rotationEffect(.degrees(45))
                        Rectangle().fill(theme.accent.opacity(0.30)).frame(height: 0.5)
                    }
                    .padding(.horizontal, 36)
                    .padding(.vertical, 20)

                    VStack(spacing: 18) {
                        ForEach(Array(prayer.texts.enumerated()), id: \.offset) { _, text in
                            Text(text)
                                .font(.system(size: 18, weight: .regular, design: .serif))
                                .foregroundStyle(navy.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .lineSpacing(7)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 60)
                }
            }

            VStack {
                Capsule()
                    .fill(Color(.systemGray4))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)
                Spacer()
            }
        }
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(navy.opacity(0.5))
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(Color(.systemGray6)))
            }
            .padding(.top, 14)
            .padding(.trailing, 20)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(28)
    }
}

#Preview {
    PrayersView()
}
