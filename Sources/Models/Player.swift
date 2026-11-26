import SwiftUI

enum Team: String, Codable { case ally, enemy }

/// Jugador del entorno de pruebas. Posición normalizada (0...1) en pantalla.
struct Player: Identifiable, Equatable {
    let id: UUID
    var name: String
    var team: Team
    var position: CGPoint      // centro del personaje, normalizado
    var depthScale: Double     // 0.35 (lejos) ... 1.0 (cerca)
    var distance: Double       // metros simulados
}

extension Player {
    /// Rectángulo del personaje en puntos para un canvas de tamaño `size`.
    func boxRect(in size: CGSize) -> CGRect {
        let h = size.height * 0.20 * depthScale
        let w = h * 0.45
        return CGRect(x: position.x * size.width - w / 2,
                      y: position.y * size.height - h / 2,
                      width: w, height: h)
    }
}
