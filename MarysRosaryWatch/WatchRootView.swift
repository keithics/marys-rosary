import SwiftUI

struct WatchRootView: View {
    @EnvironmentObject var session: WatchSessionManager
    @State private var today: MysteryType = .forToday()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    Image(today.backgroundImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())

                    Text(today.displayName)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(today.accentColor)

                    if session.prayerName.isEmpty {
                        Text("Open the app on your iPhone to begin")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    } else {
                        VStack(spacing: 4) {
                            Text(session.prayerName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                            Text("Bead \(session.bead + 1)")
                                .font(.caption2)
                                .foregroundStyle(today.accentColor)
                        }

                        NavigationLink("Control") {
                            WatchPrayView()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(today.accentColor)
                    }
                }
                .padding()
            }
            .navigationTitle("Rosary")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
