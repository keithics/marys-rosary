import AVFoundation

@MainActor final class BackgroundMusicPlayer: ObservableObject {
    @Published var volume: Double {
        didSet {
            UserDefaults.standard.set(volume, forKey: "bgMusicVolume")
            applyVolume()
        }
    }
    @Published var isMuted: Bool {
        didSet {
            UserDefaults.standard.set(isMuted, forKey: "bgMusicMuted")
            applyVolume()
        }
    }

    private var player: AVAudioPlayer?

    init() {
        let saved = UserDefaults.standard.object(forKey: "bgMusicVolume") as? Double
        volume = saved ?? 0.18
        isMuted = UserDefaults.standard.bool(forKey: "bgMusicMuted")
    }

    func play() {
        guard player == nil,
              let url = Bundle.main.url(forResource: "avemaria", withExtension: "m4a") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            applyVolume()
            player?.play()
        } catch {}
    }

    func pause() { player?.pause() }
    func resume() { if !isMuted { player?.play() } }

    func stop() {
        player?.stop()
        player = nil
    }

    private func applyVolume() {
        player?.volume = isMuted ? 0 : Float(volume)
    }
}
