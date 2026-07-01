import Foundation

// MARK: - JSON-backed models

struct PrayerText: Codable {
    let text: String
    let type: PrayerTextType
    let audio: String?              // bundled m4a filename (no extension); nil for response segments
    let defaultResponseSeconds: Int // only meaningful for response segments

    enum PrayerTextType: String, Codable {
        case normal
        case response
    }

    init(text: String, type: PrayerTextType = .normal, audio: String? = nil, defaultResponseSeconds: Int = 5) {
        self.text = text
        self.type = type
        self.audio = audio
        self.defaultResponseSeconds = defaultResponseSeconds
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        text = try c.decode(String.self, forKey: .text)
        type = try c.decodeIfPresent(PrayerTextType.self, forKey: .type) ?? .normal
        audio = try c.decodeIfPresent(String.self, forKey: .audio)
        defaultResponseSeconds = try c.decodeIfPresent(Int.self, forKey: .defaultResponseSeconds) ?? 5
    }

    private enum CodingKeys: String, CodingKey { case text, type, audio, defaultResponseSeconds }
}

struct Prayer: Codable {
    let id: String
    let title: String
    let texts: [PrayerText]

    init(id: String, title: String, texts: [PrayerText]) {
        self.id = id
        self.title = title
        self.texts = texts
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        texts = try c.decode([PrayerText].self, forKey: .text)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(title, forKey: .title)
        try c.encode(texts, forKey: .text)
    }

    var defaultResponseSeconds: Int {
        texts.first(where: { $0.type == .response })?.defaultResponseSeconds ?? 5
    }

    private enum CodingKeys: String, CodingKey { case id, title, text }
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

extension Mystery {
    static func load(type: MysteryType) -> [Mystery] {
        guard
            let url    = Bundle.main.url(forResource: "mysteries", withExtension: "json"),
            let data   = try? Data(contentsOf: url),
            let result = try? JSONDecoder().decode(MysteriesData.self, from: data)
        else { return [] }
        switch type {
        case .joyful:    return result.joyful
        case .sorrowful: return result.sorrowful
        case .glorious:  return result.glorious
        case .luminous:  return result.luminous
        }
    }

    func asPrayer(type: MysteryType, index: Int) -> Prayer {
        Prayer(id: "mystery_\(type.rawValue)_\(index)",
               title: title,
               texts: [
                PrayerText(text: text, type: .normal, audio: mp3),
                PrayerText(text: "", type: .response, defaultResponseSeconds: 2)
               ])
    }
}

// MARK: - Mystery type (traditional weekly schedule)

enum MysteryType: String, CaseIterable {
    case joyful, sorrowful, glorious, luminous

    var displayName: String { rawValue.capitalized + " Mysteries" }

    // forToday() is defined in LiturgicalCalendar.swift
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
    let decadeStep: Int?        // 1-based position within a numbered group (e.g. 1, 2, 3)
    let totalSteps: Int?        // total beads in that group (e.g. 3 for opening, 10 for decades)
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
                    return m.asPrayer(type: mysteryType, index: mysteryIndex)
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
                    Bead(kind: kind, prayers: resolved, decadeStep: nil, totalSteps: nil, isVisualOnly: i > 0)
                }
            }

            let isNumberedGroup = kind == .gold && repeatCount > 1
            var beads: [Bead] = []
            for i in 0..<repeatCount {
                let step: Int?  = isNumberedGroup ? (i + 1)      : nil
                let total: Int? = isNumberedGroup ? repeatCount   : nil
                let resolvedPrayers = resolve(desc.prayers, decadeStep: step)
                beads.append(Bead(kind: kind, prayers: resolvedPrayers, decadeStep: step, totalSteps: total, isVisualOnly: false))
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
