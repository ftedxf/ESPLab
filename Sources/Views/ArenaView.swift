import SwiftUI

/// Escenario de pruebas: rejilla + siluetas simples para los jugadores simulados.
struct ArenaView: View {
    let players: [Player]

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.05, green: 0.05, blue: 0.10),
                                    Color(red: 0.09, green: 0.07, blue: 0.16)],
                           startPoint: .top, endPoint: .bottom)
            Canvas { ctx, size in
                var grid = Path()
                let step: CGFloat = 36
                var x: CGFloat = 0
                while x <= size.width { grid.move(to: CGPoint(x: x, y: 0)); grid.addLine(to: CGPoint(x: x, y: size.height)); x += step }
                var y: CGFloat = 0
                while y <= size.height { grid.move(to: CGPoint(x: 0, y: y)); grid.addLine(to: CGPoint(x: size.width, y: y)); y += step }
                ctx.stroke(grid, with: .color(.white.opacity(0.04)), lineWidth: 0.5)

                for p in players {
                    let r = p.boxRect(in: size)
                    let body = Path(roundedRect: CGRect(x: r.minX + r.width * 0.1, y: r.minY + r.height * 0.22,
                                                        width: r.width * 0.8, height: r.height * 0.78),
                                    cornerRadius: r.width * 0.3)
                    let head = Path(ellipseIn: CGRect(x: r.midX - r.width * 0.2, y: r.minY,
                                                      width: r.width * 0.4, height: r.width * 0.4))
                    ctx.fill(body, with: .color(.white.opacity(0.10)))
                    ctx.fill(head, with: .color(.white.opacity(0.14)))
                }
            }
        }
        .overlay(alignment: .bottom) {
            Text("ENTORNO DE PRUEBAS · DATOS SIMULADOS")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.25))
                .padding(.bottom, 8)
        }
    }
}
