import SwiftUI

@main
struct QuduratPlusApp: App {
    @StateObject private var store = Store()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environment(\.layoutDirection, .rightToLeft)
                .environment(\.locale, Locale(identifier: "ar@numbers=latn"))
                .tint(Theme.accent)
                .preferredColorScheme(store.appearance.scheme)
                .onAppear { store.refreshDaily() }
        }
    }
}
