import MediaPlayer
import UIKit

// Manages the system Now Playing card on the lock screen and Control Center.
// MPNowPlayingInfoCenter updates are rendered immediately by the OS — no budget
// or throttling issues unlike ActivityKit local updates from background apps.
// MPRemoteCommandCenter handles the lock screen play/pause/next/prev buttons.

@MainActor
final class NowPlayingManager {
    static let shared = NowPlayingManager()

    private let infoCenter = MPNowPlayingInfoCenter.default()
    private let commandCenter = MPRemoteCommandCenter.shared()
    private var registered = false

    private init() {}

    // Call once when playback starts.
    func register() {
        guard !registered else { return }
        registered = true

        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.isEnabled = false

        // Post to the same NotificationCenter names that ContentView already observes,
        // so MPRemoteCommandCenter and the Live Activity buttons share one handler.
        commandCenter.playCommand.addTarget { _ in
            NotificationCenter.default.post(name: .rosaryTogglePlay, object: nil)
            return .success
        }
        commandCenter.pauseCommand.addTarget { _ in
            NotificationCenter.default.post(name: .rosaryTogglePlay, object: nil)
            return .success
        }
        commandCenter.togglePlayPauseCommand.addTarget { _ in
            NotificationCenter.default.post(name: .rosaryTogglePlay, object: nil)
            return .success
        }
        commandCenter.nextTrackCommand.addTarget { _ in
            NotificationCenter.default.post(name: .rosaryGoNext, object: nil)
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { _ in
            NotificationCenter.default.post(name: .rosaryGoPrev, object: nil)
            return .success
        }
    }

    func update(title: String, artist: String, mysteryType: MysteryType, isPlaying: Bool) {
        register()

        var info: [String: Any] = [
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyArtist: artist,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0,
            MPNowPlayingInfoPropertyDefaultPlaybackRate: 1.0,
        ]

        if let image = UIImage(named: mysteryType.rawValue) {
            let artwork = MPMediaItemArtwork(boundsSize: CGSize(width: 300, height: 300)) { _ in image }
            info[MPMediaItemPropertyArtwork] = artwork
        }

        infoCenter.nowPlayingInfo = info
    }

    func clear() {
        infoCenter.nowPlayingInfo = nil
    }
}
