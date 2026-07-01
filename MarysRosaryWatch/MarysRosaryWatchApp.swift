import SwiftUI

@main
struct MarysRosaryWatchApp: App {
    @StateObject private var session = WatchSessionManager()

    var body: some Scene {
        WindowGroup {
            WatchRootView()
                .environmentObject(session)
        }
    }
}
