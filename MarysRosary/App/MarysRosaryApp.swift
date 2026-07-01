import SwiftUI
import CoreText

@main
struct MarysRosaryApp: App {
    @StateObject private var delayStore = PrayerDelayStore()
    @StateObject private var session = RosarySessionStore()
    @StateObject private var bgMusic = BackgroundMusicPlayer()

    init() {
        registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(delayStore)
                .environmentObject(session)
                .environmentObject(bgMusic)
                .preferredColorScheme(.light)
        }
    }

    private func registerFonts() {
        [("KaushanScript-Regular", "ttf"),
         ("Kefa-Regular", "otf"),
         ("fa-solid-900", "ttf")].forEach { name, ext in
            guard let url = Bundle.main.url(forResource: name, withExtension: ext) else { return }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
