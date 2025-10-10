import SwiftUI

@main
struct MindfulWatchApp: App {
    @StateObject private var voiceManager = VoiceQueryManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(voiceManager)
        }
        .handlesShellCommands()
    }
}