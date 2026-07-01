import Foundation

final class PrayerDelayStore: ObservableObject {
    @Published private(set) var overrides: [String: Int] = [:]

    private let key = "prayerResponseSeconds"

    init() {
        load()
        clearLegacyData()
    }

    // MARK: - Public

    func responseSeconds(for prayer: Prayer) -> Int {
        overrides[prayer.id] ?? prayer.defaultResponseSeconds
    }

    func responseSeconds(forId id: String, default defaultVal: Int) -> Int {
        overrides[id] ?? defaultVal
    }

    func setResponseSeconds(_ value: Int, for prayer: Prayer) {
        overrides[prayer.id] = max(1, min(90, value))
        save()
    }

    func setResponseSeconds(_ value: Int, forId id: String) {
        overrides[id] = max(1, min(90, value))
        save()
    }

    func reset(for prayer: Prayer) {
        overrides.removeValue(forKey: prayer.id)
        save()
    }

    func resetAll() {
        overrides.removeAll()
        UserDefaults.standard.removeObject(forKey: key)
    }

    // MARK: - Private

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String: Int].self, from: data)
        else { return }
        overrides = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(overrides) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private func clearLegacyData() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let files = (try? FileManager.default.contentsOfDirectory(at: docs, includingPropertiesForKeys: nil)) ?? []
        files.filter { $0.pathExtension == "m4a" }.forEach { try? FileManager.default.removeItem(at: $0) }
        UserDefaults.standard.removeObject(forKey: "prayerDelays")
    }
}
