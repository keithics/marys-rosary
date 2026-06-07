import Foundation

// MARK: - JSON-backed models

struct Prayer: Codable {
    let id: String
    let title: String
    let text: String
    let mp3: String?
}

struct Mystery: Codable {
    let title: String
    let text: String
    let mp3: String?
}

// Layout descriptors — define bead structure in layout.json
struct BeadDescriptor: Codable {
    let kind: String        // "crucifix" | "pearl" | "gold" | "medal"
    let count: Int?         // repeat count (e.g. 10 for a decade, 3 for opening Hail Marys)
    let prayers: [String]   // plural: one prayer per bead (each is a navigation step)
    let prayer: String?     // singular: one prayer shared across all `count` beads (only first bead navigates)

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        kind    = try c.decode(String.self, forKey: .kind)
        count   = try c.decodeIfPresent(Int.self, forKey: .count)
        prayers = try c.decodeIfPresent([String].self, forKey: .prayers) ?? []
        prayer  = try c.decodeIfPresent(String.self, forKey: .prayer)
    }

    enum CodingKeys: String, CodingKey { case kind, count, prayers, prayer }
}

struct RosaryLayout: Codable {
    let opening: [BeadDescriptor]
    let decadeTemplate: [BeadDescriptor]
    let finalDecade: [BeadDescriptor]
    let closing: [BeadDescriptor]

    enum CodingKeys: String, CodingKey {
        case opening
        case decadeTemplate = "decade_template"
        case finalDecade    = "final_decade"
        case closing
    }
}

private struct MysteriesData: Codable {
    let joyful: [Mystery]
    let sorrowful: [Mystery]
    let glorious: [Mystery]
    let luminous: [Mystery]
}

// MARK: - Mystery type (traditional weekly schedule)

enum MysteryType: String, CaseIterable {
    case joyful, sorrowful, glorious, luminous

    var displayName: String { rawValue.capitalized + " Mysteries" }

    static func forToday() -> MysteryType {
        switch Calendar.current.component(.weekday, from: Date()) {
        case 1: return .glorious   // Sunday
        case 2: return .joyful     // Monday
        case 3: return .sorrowful  // Tuesday
        case 4: return .glorious   // Wednesday
        case 5: return .luminous   // Thursday
        case 6: return .sorrowful  // Friday
        default: return .joyful    // Saturday
        }
    }
}

// MARK: - Bead

enum BeadKind {
    case crystal   // pearl beads (Our Father, Glory Be, etc.)
    case gold      // Hail Mary beads
    case crucifix  // The crucifix
    case medal     // The Madonna centerpiece
}

struct Bead: Identifiable {
    let id = UUID()
    let kind: BeadKind
    let prayers: [Prayer]
    let decadeStep: Int?        // 1-10 for Hail Mary beads within a decade
    var isVisualOnly: Bool      // true for extra beads from singular `prayer` — shown but skipped in navigation

    var primaryPrayer: Prayer? { prayers.first }
}

// MARK: - Rosary

struct Rosary {
    /// Full prayer sequence: 69 steps including double traversal of the tail.
    let sequence: [Bead]
    /// Number of physical tail positions (6), used by the layout engine.
    let tailCount: Int
    /// Number of physical loop positions (55), used by the layout engine.
    let loopCount: Int
    /// The mystery set prayed today.
    let mysteryType: MysteryType

    static let standard: Rosary = load()

    /// Build the rosary sequence from JSON assets.
    static func load(mysteryType: MysteryType = .forToday()) -> Rosary {
        let prayers   = loadPrayers()
        let mysteries = loadMysteryList(type: mysteryType)
        let layout    = loadLayout()

        var mysteryIndex = 0

        /// Resolves a list of prayer IDs (and the special "mystery" token) into Prayer objects.
        func resolve(_ ids: [String], decadeStep: Int? = nil) -> [Prayer] {
            ids.compactMap { id in
                if id == "mystery" {
                    guard mysteryIndex < mysteries.count else { return nil }
                    let m = mysteries[mysteryIndex]
                    // Wrap mystery in a Prayer so the UI can display it uniformly.
                    return Prayer(id: "mystery_\(mysteryIndex)",
                                  title: m.title,
                                  text: m.text,
                                  mp3: m.mp3)
                }
                return prayers[id]
            }
        }

        /// Expand one BeadDescriptor into one or more Beads.
        func expand(_ desc: BeadDescriptor, consumeMystery: Bool = false) -> [Bead] {
            let repeatCount = desc.count ?? 1
            let kind: BeadKind = switch desc.kind {
                case "crucifix": .crucifix
                case "medal":    .medal
                case "gold":     .gold
                default:         .crystal
            }

            // Singular `prayer`: one prayer for all beads; only first bead is a navigation step.
            if let singularId = desc.prayer {
                let resolved = resolve([singularId])
                return (0..<repeatCount).map { i in
                    Bead(kind: kind, prayers: resolved, decadeStep: nil, isVisualOnly: i > 0)
                }
            }

            var beads: [Bead] = []
            for i in 0..<repeatCount {
                let step: Int? = (kind == .gold && repeatCount > 1) ? (i + 1) : nil
                let resolvedPrayers = resolve(desc.prayers, decadeStep: step)
                beads.append(Bead(kind: kind, prayers: resolvedPrayers, decadeStep: step, isVisualOnly: false))
            }
            return beads
        }

        var sequence: [Bead] = []

        // --- Opening: crucifix → pearl → gold×3 → pearl → medal (7 steps) ---
        for desc in layout.opening {
            let hasMystery = desc.prayers.contains("mystery")
            sequence += expand(desc)
            if hasMystery { mysteryIndex += 1 }
        }

        // --- Loop: 4 × (decade_template) + final_decade = 55 beads ---
        for _ in 0..<4 {
            for desc in layout.decadeTemplate {
                let hasMystery = desc.prayers.contains("mystery")
                sequence += expand(desc)
                if hasMystery { mysteryIndex += 1 }
            }
        }
        for desc in layout.finalDecade {
            sequence += expand(desc)
        }

        // --- Closing: medal + pearl + gold×3 + pearl + crucifix (7 steps) ---
        for desc in layout.closing {
            sequence += expand(desc)
        }

        // tailCount = opening tail beads (exclude the medal at end of opening)
        let tailCount = layout.opening.dropLast().reduce(0) { $0 + ($1.count ?? 1) }
        // loopCount = decade_template × 4 + final_decade
        let loopCount = (layout.decadeTemplate.reduce(0) { $0 + ($1.count ?? 1) } * 4)
                      + layout.finalDecade.reduce(0) { $0 + ($1.count ?? 1) }

        return Rosary(sequence: sequence, tailCount: tailCount, loopCount: loopCount, mysteryType: mysteryType)
    }

    // MARK: - JSON loading

    private static func loadPrayers() -> [String: Prayer] {
        guard
            let url  = Bundle.main.url(forResource: "prayers", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let list = try? JSONDecoder().decode([Prayer].self, from: data)
        else { fatalError("Could not load prayers.json") }
        return Dictionary(uniqueKeysWithValues: list.map { ($0.id, $0) })
    }

    private static func loadMysteryList(type: MysteryType) -> [Mystery] {
        guard
            let url    = Bundle.main.url(forResource: "mysteries", withExtension: "json"),
            let data   = try? Data(contentsOf: url),
            let result = try? JSONDecoder().decode(MysteriesData.self, from: data)
        else { fatalError("Could not load mysteries.json") }
        switch type {
        case .joyful:    return result.joyful
        case .sorrowful: return result.sorrowful
        case .glorious:  return result.glorious
        case .luminous:  return result.luminous
        }
    }

    private static func loadLayout() -> RosaryLayout {
        guard
            let url    = Bundle.main.url(forResource: "layout", withExtension: "json"),
            let data   = try? Data(contentsOf: url),
            let result = try? JSONDecoder().decode(RosaryLayout.self, from: data)
        else { fatalError("Could not load layout.json") }
        return result
    }
}
