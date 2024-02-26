import SwiftUI

@main
struct MyApp: App {
    @StateObject var soundManager: SoundManager = SoundManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
            }
            .environmentObject(soundManager)
            .preferredColorScheme(.light)
            .onDisappear {
                soundManager.stop()
            }
        }
    }
}
