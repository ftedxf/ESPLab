import SwiftUI

struct RGBAColor: Codable, Equatable {
    var r: Double
    var g: Double
    var b: Double
    var a: Double = 1

    var color: Color { Color(.sRGB, red: r, green: g, blue: b, opacity: a) }

    static let enemyDefault = RGBAColor(r: 1.0, g: 0.25, b: 0.30)
    static let allyDefault  = RGBAColor(r: 0.20, g: 0.85, b: 0.50)
}

enum SnaplineOrigin: String, Codable, CaseIterable, Identifiable {
    case top, center, bottom
    var id: String { rawValue }
    var title: String {
        switch self {
        case .top: return "Arriba"
        case .center: return "Centro"
        case .bottom: return "Abajo"
        }
    }
}

struct ESPConfig: Codable, Equatable {
    // Funciones
    var masterEnabled = true
    var showBoxes = true
    var showSnaplines = true
    var showDistance = true
    var showNames = false
    var showEnemies = true
    var showAllies = true

    // Colores
    var enemyColor = RGBAColor.enemyDefault
    var allyColor = RGBAColor.allyDefault

    // Estilo
    var boxLineWidth = 1.5
    var snaplineWidth = 1.0
    var indicatorSize = 11.0
    var boxCornerRadius = 4.0
    var snaplineOrigin = SnaplineOrigin.bottom
    var overlayOpacity = 1.0
}

struct ESPProfile: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var config: ESPConfig
}

extension ESPConfig {
    static var minimal: ESPConfig {
        var c = ESPConfig()
        c.showSnaplines = false
        c.showNames = false
        c.boxLineWidth = 1
        c.indicatorSize = 10
        return c
    }

    static var highContrast: ESPConfig {
        var c = ESPConfig()
        c.enemyColor = RGBAColor(r: 1, g: 0.9, b: 0)
        c.allyColor = RGBAColor(r: 0, g: 0.9, b: 1)
        c.boxLineWidth = 2.5
        c.snaplineWidth = 1.5
        c.indicatorSize = 14
        c.showNames = true
        return c
    }
}
