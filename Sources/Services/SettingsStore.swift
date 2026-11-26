import SwiftUI

@MainActor
final class SettingsStore: ObservableObject {
    @Published var config: ESPConfig { didSet { scheduleSave() } }
    @Published private(set) var profiles: [ESPProfile] { didSet { scheduleSave() } }
    @Published private(set) var activeProfileID: UUID? { didSet { scheduleSave() } }

    private enum Key {
        static let config = "esp.config.v1"
        static let profiles = "esp.profiles.v1"
        static let active = "esp.active.v1"
    }

    private var saveTask: Task<Void, Never>?

    init() {
        let d = UserDefaults.standard
        let dec = JSONDecoder()
        config = d.data(forKey: Key.config).flatMap { try? dec.decode(ESPConfig.self, from: $0) } ?? ESPConfig()
        let saved = d.data(forKey: Key.profiles).flatMap { try? dec.decode([ESPProfile].self, from: $0) } ?? []
        profiles = saved.isEmpty
            ? [ESPProfile(name: "Minimalista", config: .minimal),
               ESPProfile(name: "Alto contraste", config: .highContrast)]
            : saved
        activeProfileID = d.string(forKey: Key.active).flatMap(UUID.init(uuidString:))
    }

    // MARK: Perfiles

    func saveCurrentAsProfile(named name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let profile = ESPProfile(name: trimmed, config: config)
        profiles.append(profile)
        activeProfileID = profile.id
    }

    func apply(_ profile: ESPProfile) {
        config = profile.config
        activeProfileID = profile.id
    }

    func updateActiveProfile() {
        guard let id = activeProfileID, let i = profiles.firstIndex(where: { $0.id == id }) else { return }
        profiles[i].config = config
    }

    func delete(_ profile: ESPProfile) {
        profiles.removeAll { $0.id == profile.id }
        if activeProfileID == profile.id { activeProfileID = nil }
    }

    func resetConfig() {
        config = ESPConfig()
        activeProfileID = nil
    }

    // MARK: Persistencia (con debounce para reducir escrituras)

    private func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }
            self?.persist()
        }
    }

    private func persist() {
        let d = UserDefaults.standard
        let enc = JSONEncoder()
        d.set(try? enc.encode(config), forKey: Key.config)
        d.set(try? enc.encode(profiles), forKey: Key.profiles)
        d.set(activeProfileID?.uuidString, forKey: Key.active)
    }
}
