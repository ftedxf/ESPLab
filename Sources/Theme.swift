import SwiftUI
import UIKit

enum Theme {
    static let accent  = Color(red: 0.55, green: 0.36, blue: 1.0)
    static let accent2 = Color(red: 0.20, green: 0.80, blue: 1.0)
    static var gradient: LinearGradient {
        LinearGradient(colors: [accent, accent2], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    static let card = Color.white.opacity(0.06)
}

enum Haptics {
    static func tap() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
}
