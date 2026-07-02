import AppIntents
import CoreFoundation

private let kTogglePlay = "com.webninja.rosary.togglePlay"
private let kGoNext     = "com.webninja.rosary.goNext"

struct TogglePlayIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Rosary Play"

    func perform() async throws -> some IntentResult {
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(rawValue: kTogglePlay as CFString),
            nil, nil, true
        )
        return .result()
    }
}

struct GoNextIntent: AppIntent {
    static var title: LocalizedStringResource = "Next Prayer"

    func perform() async throws -> some IntentResult {
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(rawValue: kGoNext as CFString),
            nil, nil, true
        )
        return .result()
    }
}

private let kGoPrev = "com.webninja.rosary.goPrev"

struct GoPrevIntent: AppIntent {
    static var title: LocalizedStringResource = "Previous Prayer"

    func perform() async throws -> some IntentResult {
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(rawValue: kGoPrev as CFString),
            nil, nil, true
        )
        return .result()
    }
}
