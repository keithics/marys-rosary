import SwiftUI

@Observable
@MainActor
final class SettingsViewModel {
    var prayers: [Prayer] = []
    var today: MysteryType = .forToday()
    var playingId: String? = nil
    var previewingMystery: (Prayer, MysteryTheme)? = nil
    var selectedTab = 0

    let preview = PreviewPlayer()

    func loadPrayers() {
        guard let url = Bundle.main.url(forResource: "prayers", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let list = try? JSONDecoder().decode([Prayer].self, from: data)
        else { return }
        prayers = list
    }

    func togglePreview(_ prayer: Prayer, delayStore: PrayerDelayStore) {
        if playingId == prayer.id {
            preview.stop()
            playingId = nil
        } else if let audioName = prayer.texts.first(where: { $0.type == .normal })?.audio,
                  let url = Bundle.main.url(forResource: audioName, withExtension: "m4a") {
            preview.onStop = { [weak self] in self?.playingId = nil }
            preview.play(url: url, displayDuration: nil)
            playingId = prayer.id
        }
    }

    func updateToday() {
        today = .forToday()
    }
}
