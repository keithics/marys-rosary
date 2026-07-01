import AVFoundation

@Observable
@MainActor
final class AudioPlayer: NSObject {
    var isPlaying = false
    var onTrackEnd: (() -> Void)?

    private var player: AVQueuePlayer?
    private var itemEndObserver: NSObjectProtocol?
    private var trackedItems: Set<ObjectIdentifier> = []

    override init() {
        super.init()
        configureSession()
    }

    // MARK: - Queue

    func loadQueue(fileNames: [String]) {
        stop()
        let items = fileNames.compactMap { bundleItem($0) }
        guard !items.isEmpty else { return }
        trackedItems = Set(items.map { ObjectIdentifier($0) })
        player = AVQueuePlayer(items: items)
        observeTrackEnd()
    }

    func advanceToNextItem() {
        player?.advanceToNextItem()
    }

    // MARK: - Playback

    func play()   { player?.play();  isPlaying = true  }
    func pause()  { player?.pause(); isPlaying = false }
    func resume() { player?.play();  isPlaying = true  }

    func stop() {
        removeObserver()
        player?.pause()
        player?.removeAllItems()
        player = nil
        isPlaying = false
        trackedItems = []
    }

    // MARK: - Progress

    var currentTime: Double {
        guard let t = player?.currentTime(), t.isValid, !t.seconds.isNaN else { return 0 }
        return t.seconds
    }

    var currentItemDuration: Double {
        guard let d = player?.currentItem?.duration,
              d.isValid, !d.seconds.isNaN, d.seconds > 0 else { return 0 }
        return d.seconds
    }

    // MARK: - Private

    private func bundleItem(_ name: String) -> AVPlayerItem? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "m4a") else { return nil }
        return AVPlayerItem(url: url)
    }

    private func observeTrackEnd() {
        let mine = trackedItems
        itemEndObserver = NotificationCenter.default.addObserver(
            forName: AVPlayerItem.didPlayToEndTimeNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let self,
                  let ended = note.object as? AVPlayerItem,
                  mine.contains(ObjectIdentifier(ended)) else { return }
            MainActor.assumeIsolated {
                guard self.isPlaying else { return }
                self.onTrackEnd?()
            }
        }
    }

    private func removeObserver() {
        if let obs = itemEndObserver {
            NotificationCenter.default.removeObserver(obs)
            itemEndObserver = nil
        }
    }

    private func configureSession() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
}
