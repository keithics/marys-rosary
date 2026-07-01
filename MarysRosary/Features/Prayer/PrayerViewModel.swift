import AVFoundation
import SwiftUI

struct PrayerTrack {
    let fileName: String
    let beadIndex: Int
    let prayerIndex: Int
    let textIndex: Int
    let duration: Double   // preloaded from AVAsset; avoids waiting on AVQueuePlayer lazy metadata load
}

@Observable
@MainActor
final class PrayerViewModel {
    let rosary: Rosary
    var currentBead: Int = 0
    var currentPrayer: Int = 0
    var currentText: Int = 0
    var isPlaying = true
    var hasStarted = false
    var showCompletion = false
    var showQueue = false
    var learningMode = false
    var textProgress: Double = 0

    let audio = AudioPlayer()
    private var playlist: [PrayerTrack] = []
    private var currentTrackIndex: Int = 0
    private var progressTimer: Timer?

    init(mysteryType: MysteryType = .forToday(), initialBead: Int = 0, initialPrayer: Int = 0) {
        rosary = Rosary.load(mysteryType: mysteryType)
        currentBead = initialBead
        currentPrayer = initialPrayer
    }

    var theme: MysteryTheme { rosary.mysteryType.theme }
    var bead: Bead { rosary.sequence[min(currentBead, rosary.sequence.count - 1)] }
    var prayer: Prayer? {
        bead.prayers.indices.contains(currentPrayer) ? bead.prayers[currentPrayer] : bead.prayers.first
    }
    var isResponseSegment: Bool {
        guard let prayer else { return false }
        guard prayer.texts.indices.contains(currentText) else { return false }
        guard !prayer.id.hasPrefix("mystery_") else { return false }
        return prayer.texts[currentText].type == .response
    }

    var prayerText: String {
        guard let prayer else { return "" }
        guard prayer.texts.indices.contains(currentText) else { return "" }
        let segment = prayer.texts[currentText]
        return segment.text.isEmpty ? (prayer.texts.first?.text ?? "") : segment.text
    }

    // MARK: - Playback

    func startPlayback(delayStore: PrayerDelayStore) {
        playlist = buildPlaylist(delayStore: delayStore)
        let startIndex = playlist.firstIndex(where: { $0.beadIndex >= currentBead }) ?? 0
        currentTrackIndex = startIndex
        updateUIFromTrack()
        guard !playlist.isEmpty else { return }
        audio.onTrackEnd = { [weak self] in self?.onTrackEnd() }
        let fileNames = Array(playlist[startIndex...].map { $0.fileName })
        audio.loadQueue(fileNames: fileNames)
        audio.play()
        startProgressTimer()
    }

    func togglePlay(bgMusic: BackgroundMusicPlayer) {
        isPlaying.toggle()
        if isPlaying {
            audio.resume()
            bgMusic.resume()
            startProgressTimer()
        } else {
            audio.pause()
            bgMusic.pause()
            stopProgressTimer()
        }
    }

    // MARK: - Navigation

    func goNext() {
        guard currentTrackIndex < playlist.count - 1 else {
            showCompletion = true
            return
        }
        audio.advanceToNextItem()
        currentTrackIndex += 1
        updateUIFromTrack()
    }

    func goBack() {
        let target = max(currentTrackIndex - 1, 0)
        currentTrackIndex = target
        updateUIFromTrack()
        // Rebuild queue from the target track so audio syncs with UI
        let remaining = Array(playlist[target...].map { $0.fileName })
        audio.loadQueue(fileNames: remaining)
        if isPlaying { audio.play() }
        startProgressTimer()
    }

    // MARK: - Private

    private func onTrackEnd() {
        if currentTrackIndex < playlist.count - 1 {
            currentTrackIndex += 1
            updateUIFromTrack()
            // AVQueuePlayer already advanced to next item automatically
        } else {
            stopProgressTimer()
            showCompletion = true
        }
    }

    private func updateUIFromTrack() {
        guard playlist.indices.contains(currentTrackIndex) else { return }
        let track = playlist[currentTrackIndex]
        withAnimation(.easeInOut(duration: 0.3)) {
            currentBead = track.beadIndex
        }
        currentPrayer = track.prayerIndex
        currentText = track.textIndex
        textProgress = 0
    }

    private func buildPlaylist(delayStore: PrayerDelayStore) -> [PrayerTrack] {
        var tracks: [PrayerTrack] = []
        for (beadIdx, bead) in rosary.sequence.enumerated() {
            guard !bead.isVisualOnly else { continue }
            for (prayerIdx, prayer) in bead.prayers.enumerated() {
                let responseSecs = delayStore.responseSeconds(for: prayer)
                for (textIdx, text) in prayer.texts.enumerated() {
                    let fileName: String
                    if text.type == .response {
                        fileName = "silence_\(responseSecs)s"
                    } else if let audio = text.audio {
                        fileName = audio
                    } else {
                        continue
                    }
                    tracks.append(PrayerTrack(
                        fileName: fileName,
                        beadIndex: beadIdx,
                        prayerIndex: prayerIdx,
                        textIndex: textIdx,
                        duration: assetDuration(fileName)
                    ))
                }
            }
        }
        return tracks
    }

    private func assetDuration(_ name: String) -> Double {
        guard let url = Bundle.main.url(forResource: name, withExtension: "m4a") else { return 0 }
        let d = AVURLAsset(url: url).duration
        return d.isValid && !d.seconds.isNaN ? d.seconds : 0
    }

    // MARK: - Progress

    private func startProgressTimer() {
        stopProgressTimer()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.updateProgress() }
        }
    }

    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    private func updateProgress() {
        guard playlist.indices.contains(currentTrackIndex) else { return }
        let duration = playlist[currentTrackIndex].duration
        let time = audio.currentTime
        guard duration > 0 else { return }
        textProgress = min(time / duration, 1.0)
    }
}
