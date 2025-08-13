import SwiftUI

@main
struct EchoScribeApp: App {
    @StateObject private var audioManager = AudioRecordingManager()
    @StateObject private var transcriptionManager = TranscriptionManager()
    @StateObject private var notesManager = NotesManager()
    @StateObject private var permissionManager = PermissionManager()
    @StateObject private var settingsManager = SettingsManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioManager)
                .environmentObject(transcriptionManager)
                .environmentObject(notesManager)
                .environmentObject(permissionManager)
                .environmentObject(settingsManager)
                .frame(minWidth: 1200, minHeight: 800)
                .background(Color(NSColor.windowBackgroundColor))
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Recording") {
                    audioManager.startRecording()
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            CommandGroup(after: .newItem) {
                Button("Start/Stop Recording") {
                    audioManager.toggleRecording()
                }
                .keyboardShortcut(.space, modifiers: [])
                
                Button("Pause/Resume Recording") {
                    audioManager.togglePause()
                }
                .keyboardShortcut(.space, modifiers: .command)
            }
            
            CommandGroup(after: .appInfo) {
                Button("Settings") {
                    // Open settings
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
        
        Settings {
            SettingsView()
                .environmentObject(settingsManager)
        }
    }
}
