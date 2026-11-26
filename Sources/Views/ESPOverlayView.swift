import SwiftUI

/// Capa de dibujo ESP. Un único Canvas (GPU) y sin hit-testing para minimizar coste.
struct ESPOverlayView: View {
    let players: [Player]
    let config: ESPConfig

    var body: some View {
        Canvas { ctx, size in
            guard config.masterEnabled else { return }
            let origin = snapOrigin(in: size)

            for p in players {
                if p.team == .enemy && !config.showEnemies { continue }
                if p.team == .ally && !config.showAllies { continue }

                let rgba = p.team == .enemy ? config.enemyColor : config.allyColor
                let color = rgba.color
                let rect = p.boxRect(in: size)

                if config.showSnaplines {
                    var line = Path()
                    line.move(to: origin)
                    line.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
                    ctx.stroke(line, with: .color(color.opacity(0.8)),
                               style: StrokeStyle(lineWidth: config.snaplineWidth, lineCap: .round))
                }
                if config.showBoxes {
                    ctx.stroke(Path(roundedRect: rect, cornerRadius: config.boxCornerRadius),
                               with: .color(color), lineWidth: config.boxLineWidth)
                }
                if config.showNames {
                    let t = Text(p.name)
                        .font(.system(size: config.indicatorSize, weight: .bold, design: .rounded))
                        .foregroundColor(color)
                    ctx.draw(t, at: CGPoint(x: rect.midX, y: rect.minY - 8), anchor: .bottom)
                }
                if config.showDistance {
                    let t = Text("\(Int(p.distance)) m")
                        .font(.system(size: config.indicatorSize, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    ctx.draw(t, at: CGPoint(x: rect.midX, y: rect.maxY + 8), anchor: .top)
                }
            }
        }
        .opacity(config.overlayOpacity)
        .allowsHitTesting(false)
    }

    private func snapOrigin(in size: CGSize) -> CGPoint {
        switch config.snaplineOrigin {
        case .top: return CGPoint(x: size.width / 2, y: 0)
        case .center: return CGPoint(x: size.width / 2, y: size.height / 2)
        case .bottom: return CGPoint(x: size.width / 2, y: size.height)
        }
    }
}
