import Foundation
import CoreFoundation

// Bridges Darwin cross-process notifications into NotificationCenter.default
// so SwiftUI views can observe them with .onReceive.

private func _darwinCallback(
    _ center: CFNotificationCenter?,
    _ observer: UnsafeMutableRawPointer?,
    _ name: CFNotificationName?,
    _ object: UnsafeRawPointer?,
    _ userInfo: CFDictionary?
) {
    guard let cfName = name else { return }
    let notifName = Notification.Name(cfName.rawValue as String)
    DispatchQueue.main.async {
        NotificationCenter.default.post(name: notifName, object: nil)
    }
}

enum DarwinNotifier {
    private static let names = [
        "com.webninja.rosary.togglePlay",
        "com.webninja.rosary.goNext",
        "com.webninja.rosary.goPrev",
    ]

    static func startListening() {
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        for name in names {
            CFNotificationCenterAddObserver(
                center, nil, _darwinCallback,
                name as CFString, nil, .deliverImmediately
            )
        }
    }
}

extension Notification.Name {
    static let rosaryTogglePlay = Notification.Name("com.webninja.rosary.togglePlay")
    static let rosaryGoNext     = Notification.Name("com.webninja.rosary.goNext")
    static let rosaryGoPrev     = Notification.Name("com.webninja.rosary.goPrev")
}
