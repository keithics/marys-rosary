import WatchConnectivity
import SwiftUI

final class WatchSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    @Published var bead: Int = 0
    @Published var mystery: MysteryType = .forToday()
    @Published var prayerName: String = ""
    @Published var isPhoneReachable: Bool = false

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func sendTogglePlay() {
        send(["action": "togglePlay"])
    }

    func sendNextBead() {
        send(["action": "nextBead"])
    }

    private func send(_ message: [String: Any]) {
        guard WCSession.default.isReachable else { return }
        WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: nil)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            if let b = message["bead"] as? Int { self.bead = b }
            if let m = message["mystery"] as? String { self.mystery = MysteryType(rawValue: m) ?? self.mystery }
            if let p = message["prayerName"] as? String { self.prayerName = p }
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async { self.isPhoneReachable = session.isReachable }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async { self.isPhoneReachable = session.isReachable }
    }
}
