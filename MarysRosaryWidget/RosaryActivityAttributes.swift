import ActivityKit

struct RosaryActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var prayerName: String
        var isPlaying: Bool
        var beadIndex: Int
        var totalBeads: Int
        var textSegment: Int
        var totalSegments: Int
        var showMystery: Bool
    }

    let mysteryName: String
    let mysteryType: String  // MysteryType.rawValue
}
