import Foundation

final class RosarySessionStore: ObservableObject {
    @Published var bead: Int = 0
    @Published var mystery: MysteryType = .forToday()
    @Published var prayerName: String = ""
}
