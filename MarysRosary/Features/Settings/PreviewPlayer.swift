import AVFoundation
import SwiftUI

@Observable
@MainActor
final class PreviewPlayer: NSObject, AVAudioPlayerDelegate {
    var isPlaying = false
    var duration: Double = 0
    var onStop: (() -> Void)?

    private var player: AVAudioPlayer?
    private var displayTask: Task<Void, Never>?

    func play(url: URL, displayDuration: Double? = nil) {
        player?.stop()
        displayTask?.cancel()
        guard let p = try? AVAudioPlayer(contentsOf: url) else { return }
        player = p
        p.delegate = self
        p.prepareToPlay()
        p.play()
        let total = displayDuration ?? p.duration
        duration = total
        isPlaying = true
        displayTask = Task {
            try? await Task.sleep(for: .seconds(total))
            guard !Task.isCancelled else { return }
            isPlaying = false
            try? await Task.sleep(for: .seconds(0.75))
            guard !Task.isCancelled else { return }
            onStop?()
        }
    }

    func stop() {
        displayTask?.cancel()
        displayTask = nil
        player?.stop()
        player = nil
        isPlaying = false
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Audio ends naturally — display timer controls the modal lifetime
    }
}
