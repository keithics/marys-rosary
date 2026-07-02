import SwiftUI

struct InfoView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var today: MysteryType = .forToday()
    @State private var selectedTab = 1  // Credits is default
    @Environment(\.scenePhase) private var scenePhase

    private let tabs = ["About", "Credits"]

    var body: some View {
        ZStack {
            today.theme.cloud.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                    tabPicker.padding(.horizontal, 16).padding(.bottom, 20)

                    if selectedTab == 0 {
                        aboutTab
                    } else {
                        creditsTab
                    }

                    Spacer().frame(height: 40)
                }
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { today = .forToday() }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Mary's Rosary")
                    .font(.kaushan(38))
                    .foregroundStyle(today.theme.textPrimary)
                Text("Version \(Bundle.main.appVersion)")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(today.theme.textSubtle)
            }
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(today.theme.textSubtle.opacity(0.5))
            }
            .buttonStyle(.plain)
            .padding(.top, 6)
        }
        .padding(.horizontal, 18)
        .padding(.top, 56)
        .padding(.bottom, 12)
    }

    // MARK: - Pill tab picker

    private var tabPicker: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { i in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedTab = i }
                } label: {
                    Text(tabs[i])
                        .font(.system(size: 13, weight: selectedTab == i ? .semibold : .regular))
                        .foregroundStyle(selectedTab == i ? today.theme.textPrimary : today.theme.textSubtle)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            selectedTab == i ? Color.white.opacity(0.9) : Color.clear,
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(.ultraThinMaterial, in: Capsule())
    }

    // MARK: - About tab

    private var aboutTab: some View {
        VStack(spacing: 20) {
            appLogo

            VStack(spacing: 1) {
                infoRow(
                    title: "Mary's Rosary",
                    body: "Made with love by Keith Levi Lumanog — a geek who happens to be a catechist. This app started as a personal project and grew into something he hopes helps others pray the Rosary more deeply."
                )
                Divider().opacity(0.25).padding(.horizontal, 14)
                infoRow(
                    title: "Open Source",
                    body: "This app is open source. See the project repository for license details."
                )
            }
            .background(Color.white.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
            .padding(.horizontal, 16)

            VStack(spacing: 1) {
                linkRow(label: "keithics.com", url: "https://keithics.com?utm_source=marys-rosary&utm_medium=app")
                Divider().opacity(0.25).padding(.horizontal, 14)
                linkRow(label: "webninjamobile.com", url: "https://webninjamobile.com?utm_source=marys-rosary&utm_medium=app")
                Divider().opacity(0.25).padding(.horizontal, 14)
                linkRow(label: "github.com/keithics/marys-rosary", url: "https://github.com/keithics/marys-rosary?utm_source=marys-rosary&utm_medium=app")
            }
            .background(Color.white.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
            .padding(.horizontal, 16)

            Text("© \(String(Calendar.current.component(.year, from: .now))) Web Ninja Technologies")
                .font(.system(size: 11))
                .foregroundStyle(today.theme.textSubtle.opacity(0.6))
        }
    }

    // MARK: - Credits tab

    private var creditsTab: some View {
        VStack(spacing: 32) {
            VStack(spacing: 6) {
                Text("Special Thanks")
                    .font(.kaushan(32))
                    .foregroundStyle(today.theme.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 8)

            VStack(spacing: 4) {
                Text("Isa")
                Text("Adrien")
                Text("Annika")
            }
            .font(.system(size: 18, design: .serif))
            .foregroundStyle(today.theme.textPrimary)
            .multilineTextAlignment(.center)

            VStack(spacing: 4) {
                Text("Our Blessed Mother Mary")
                Text("and to")
                    .font(.system(size: 14))
                    .foregroundStyle(today.theme.textSubtle)
                Text("Our Saviour Jesus Christ")
            }
            .font(.system(size: 16, design: .serif))
            .foregroundStyle(today.theme.textPrimary)
            .multilineTextAlignment(.center)
            .italic()

            VStack(spacing: 6) {
                Text("http://www.therosary.net/")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(today.theme.accent)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 32)
        .padding(.top, 8)
    }

    // MARK: - Shared components

    private var appLogo: some View {
        VStack(spacing: 6) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(today.theme.accent.opacity(0.3), lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
            Text("Mary's Rosary")
                .font(.kaushan(20))
                .foregroundStyle(today.theme.textPrimary)
        }
        .padding(.bottom, 4)
    }

    private func linkRow(label: String, url: String) -> some View {
        Link(destination: URL(string: url)!) {
            HStack {
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(today.theme.accent)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12))
                    .foregroundStyle(today.theme.accent.opacity(0.7))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
        }
    }

    private func infoRow(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(today.theme.accent)
            Text(body)
                .font(.system(size: 14, design: .serif))
                .foregroundStyle(today.theme.textPrimary.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }
}

#Preview {
    InfoView()
}
