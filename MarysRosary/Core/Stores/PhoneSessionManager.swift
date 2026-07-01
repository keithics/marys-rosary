import WatchConnectivity

final class PhoneSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = PhoneSessionManager()

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func sendState(bead: Int, mystery: MysteryType, prayerName: String) {
        guard WCSession.default.isReachable else { return }
        WCSession.default.sendMessage([
            "bead": bead,
            "mystery": mystery.rawValue,
            "prayerName": prayerName
        ], replyHandler: nil, errorHandler: nil)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard let action = message["action"] as? String else { return }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("watchAction_\(action)"), object: nil)
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { WCSession.default.activate() }
}
