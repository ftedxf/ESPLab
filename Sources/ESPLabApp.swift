import SwiftUI

@main
struct ESPLabApp: App {
    @StateObject private var store = SettingsStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
