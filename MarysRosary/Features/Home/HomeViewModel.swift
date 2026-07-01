import SwiftUI

@Observable
final class HomeViewModel {
    var activeSession: RosarySession? = nil
    var today: MysteryType = .forToday()

    var mysteryOrder: [MysteryType] {
        let all: [MysteryType] = [.joyful, .luminous, .sorrowful, .glorious]
        return [today] + all.filter { $0 != today }
    }

    func updateToday() {
        today = .forToday()
    }

    func startSession(type: MysteryType, initialBead: Int, isResuming: Bool = false) {
        activeSession = RosarySession(mysteryType: type, initialBead: initialBead, isResuming: isResuming)
    }
}
