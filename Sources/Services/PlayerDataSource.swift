import SwiftUI

/// Origen de datos del overlay. La app solo trae la implementación simulada;
/// cualquier otra fuente debe ser un entorno propio o autorizado.
protocol PlayerDataSource: AnyObject {
    func start(onUpdate: @escaping @MainActor ([Player]) -> Void)
    func stop()
}

/// Genera jugadores ficticios que se mueven por una arena de prueba (30 FPS).
final class SimulatedPlayerSource: PlayerDataSource {
    private struct Agent {
        var player: Player
        var velocity: CGVector
    }

    private let count: Int
    private var task: Task<Void, Never>?

    init(count: Int = 8) { self.count = count }

    func start(onUpdate: @escaping @MainActor ([Player]) -> Void) {
        stop()
        let count = self.count
        task = Task.detached(priority: .utility) {
            var agents = (0..<count).map { i -> Agent in
                let team: Team = i % 3 == 0 ? .ally : .enemy
                let p = Player(
                    id: UUID(),
                    name: team == .ally ? "Aliado \(i + 1)" : "Enemigo \(i + 1)",
                    team: team,
                    position: CGPoint(x: .random(in: 0.15...0.85), y: .random(in: 0.3...0.85)),
                    depthScale: 0.7, distance: 50)
                let v = CGVector(dx: .random(in: -0.06...0.06), dy: .random(in: -0.04...0.04))
                return Agent(player: p, velocity: v)
            }
            var last = Date()
            while !Task.isCancelled {
                let now = Date()
                let dt = now.timeIntervalSince(last)
                last = now
                for i in agents.indices {
                    var a = agents[i]
                    a.player.position.x += a.velocity.dx * dt
                    a.player.position.y += a.velocity.dy * dt
                    if a.player.position.x < 0.08 || a.player.position.x > 0.92 { a.velocity.dx *= -1 }
                    if a.player.position.y < 0.22 || a.player.position.y > 0.88 { a.velocity.dy *= -1 }
                    a.player.position.x = min(max(a.player.position.x, 0.08), 0.92)
                    a.player.position.y = min(max(a.player.position.y, 0.22), 0.88)
                    let t = (a.player.position.y - 0.22) / 0.66      // 0 lejos ... 1 cerca
                    a.player.depthScale = 0.35 + 0.65 * t
                    a.player.distance = 120 - 112 * t
                    agents[i] = a
                }
                let snapshot = agents.map(\.player)
                await onUpdate(snapshot)
                try? await Task.sleep(nanoseconds: 33_000_000)
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
    }
}

@MainActor
final class SceneModel: ObservableObject {
    @Published private(set) var players: [Player] = []
    private let source: PlayerDataSource

    init(source: PlayerDataSource = SimulatedPlayerSource()) { self.source = source }

    func start() { source.start { [weak self] in self?.players = $0 } }
    func stop() { source.stop() }
}
