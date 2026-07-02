import ActivityKit
import Foundation
import os

// Keeps the Live Activity in sync by polling the ViewModel state every second.
// Calling Activity.update() from a Task alone is silently throttled by iOS when
// the app is backgrounded with audio mode. A repeating Timer on the active
// main run loop (kept alive by AVAudioSession.playback) is the only reliable
// local approach without push notifications.

private let log = Logger(subsystem: "com.webninja.rosary", category: "LiveActivity")

@MainActor
final class LiveActivityManager {
    private var activity: Activity<RosaryActivityAttributes>?
    private var refreshTimer: Timer?
    private var stateProvider: (() -> RosaryActivityAttributes.ContentState)?

    func start(mystery: MysteryType, stateProvider: @escaping () -> RosaryActivityAttributes.ContentState) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        end()
        self.stateProvider = stateProvider
        let attributes = RosaryActivityAttributes(
            mysteryName: mystery.displayName,
            mysteryType: mystery.rawValue
        )
        let initialState = stateProvider()
        activity = try? Activity.request(
            attributes: attributes,
            content: .init(state: initialState, staleDate: nil),
            pushType: nil
        )
        startTimer()
    }

    func push() {
        guard let activity else {
            log.warning("push: no activity")
            return
        }
        let state2 = activity.activityState
        guard state2 == .active else {
            log.warning("push: activityState=\(String(describing: state2)) — skipping")
            return
        }
        guard let state = stateProvider?() else {
            log.warning("push: no stateProvider")
            return
        }
        log.debug("push: updating — prayer='\(state.prayerName)' bead=\(state.beadIndex) seg=\(state.textSegment)/\(state.totalSegments)")
        Task {
            await activity.update(.init(state: state, staleDate: Date().addingTimeInterval(10)))
            log.debug("push: update sent")
        }
    }

    func end() {
        stopTimer()
        stateProvider = nil
        guard let activity else { return }
        let a = activity
        self.activity = nil
        Task.detached { await a.end(nil, dismissalPolicy: .immediate) }
    }

    // MARK: - Timer

    private func startTimer() {
        stopTimer()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.push() }
        }
    }

    private func stopTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
}
