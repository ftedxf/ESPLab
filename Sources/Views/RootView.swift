import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: SettingsStore
    @StateObject private var scene = SceneModel()
    @Environment(\.scenePhase) private var phase
    @State private var menuOpen = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ArenaView(players: scene.players).ignoresSafeArea()
            ESPOverlayView(players: scene.players, config: store.config).ignoresSafeArea()

            if menuOpen {
                Color.black.opacity(0.35).ignoresSafeArea()
                    .onTapGesture { close() }
                    .transition(.opacity)
                ModMenuView(onClose: close)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.scale(scale: 0.88).combined(with: .opacity))
            }

            FloatingButton(isOpen: $menuOpen)
                .padding(.trailing, 16)
                .padding(.top, 8)
        }
        .onAppear { scene.start() }
        // Bajo consumo: se detiene la simulación fuera de primer plano.
        .onChange(of: phase) { newPhase in
            if newPhase == .active { scene.start() } else { scene.stop() }
        }
    }

    private func close() {
        withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) { menuOpen = false }
    }
}
