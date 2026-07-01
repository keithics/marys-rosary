import SwiftUI
import WatchKit

struct WatchPrayView: View {
    @EnvironmentObject var session: WatchSessionManager
    @State private var crownValue: Double = 0.0

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text(session.prayerName.isEmpty ? "Praying…" : session.prayerName)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)

                Text("Bead \(session.bead + 1)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !session.isPhoneReachable {
                    Text("iPhone not reachable")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }

                HStack(spacing: 12) {
                    Button {
                        session.sendTogglePlay()
                    } label: {
                        Image(systemName: "playpause.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(session.mystery.accentColor)

                    Button {
                        session.sendNextBead()
                        WKInterfaceDevice.current().play(.click)
                    } label: {
                        Image(systemName: "forward.fill")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .focusable()
        .digitalCrownRotation(
            $crownValue,
            from: 0, through: 68, by: 1,
            sensitivity: .low,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .onChange(of: crownValue) { _, _ in
            session.sendNextBead()
            WKInterfaceDevice.current().play(.click)
        }
        .navigationTitle("Praying")
        .navigationBarTitleDisplayMode(.inline)
    }
}
