import SwiftUI

struct ContentView: View {
    @EnvironmentObject var audioManager: AudioRecordingManager
    @EnvironmentObject var transcriptionManager: TranscriptionManager
    @EnvironmentObject var notesManager: NotesManager
    @EnvironmentObject var permissionManager: PermissionManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    @State private var selectedTab = 0
    @State private var showSettings = false
    @State private var showSetup = false
    @State private var showOnboarding = false
    
    // MARK: - Design Constants
    private let sidebarWidth: CGFloat = 280
    private let keyPointsWidth: CGFloat = 320
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left Sidebar - Files & Navigation
                SidebarView(selectedTab: $selectedTab)
                    .frame(width: sidebarWidth)
                    .background(Color(NSColor.controlBackgroundColor))
                
                // Main Content Area - Recording & Transcription
                MainContentView(selectedTab: selectedTab)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(NSColor.controlBackgroundColor))
                
                // Right Sidebar - Key Points & Actions
                KeyPointsView()
                    .frame(width: keyPointsWidth)
                    .background(Color(NSColor.controlBackgroundColor))
            }
        }
        .navigationViewStyle(.automatic)
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(settingsManager)
        }
        .sheet(isPresented: $showSetup) {
            SetupView()
                .environmentObject(permissionManager)
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView()
                .environmentObject(permissionManager)
                .environmentObject(settingsManager)
        }
        .onAppear {
            checkFirstLaunch()
        }
        .alert("Permission Required", isPresented: $permissionManager.showPermissionAlert) {
            Button("Open Settings") {
                // Handle opening settings
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(permissionManager.permissionAlertMessage)
        }
    }
    
    private func checkFirstLaunch() {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if !hasLaunchedBefore {
            showOnboarding = true
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }
}

// MARK: - Sidebar View
struct SidebarView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var notesManager: NotesManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        VStack(spacing: 0) {
            // App Header
            AppHeaderView()
            
            // Tab Navigation
            TabNavigationView(selectedTab: $selectedTab)
            
            // Content based on selected tab
            TabContentView(selectedTab: selectedTab)
            
            Spacer()
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct AppHeaderView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var showSettings = false
    
    var body: some View {
        HStack {
            // App Icon and Title
            HStack(spacing: 12) {
                Image(systemName: "waveform.circle.fill")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("EchoScribe")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Premium Audio Recording")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Settings Button
            Button(action: { showSettings.toggle() }) {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(settingsManager)
                    .frame(width: 400, height: 600)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct TabNavigationView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<4) { index in
                TabButton(
                    title: tabTitle(for: index),
                    icon: tabIcon(for: index),
                    isSelected: selectedTab == index
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = index
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Recording"
        case 1: return "Notes"
        case 2: return "Files"
        case 3: return "Recent"
        default: return ""
        }
    }
    
    private func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "mic.fill"
        case 1: return "note.text"
        case 2: return "folder"
        case 3: return "clock"
        default: return ""
        }
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : .primary)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct TabContentView: View {
    let selectedTab: Int
    @EnvironmentObject var notesManager: NotesManager
    
    var body: some View {
        Group {
            switch selectedTab {
            case 0:
                RecordingTabView()
            case 1:
                NotesTabView()
            case 2:
                FilesTabView()
            case 3:
                RecentTabView()
            default:
                RecordingTabView()
            }
        }
        .padding(.horizontal)
    }
}

struct RecordingTabView: View {
    @EnvironmentObject var audioManager: AudioRecordingManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                QuickActionButton(
                    title: "Start Recording",
                    subtitle: "Begin new audio capture",
                    icon: "record.circle",
                    color: .red
                ) {
                    audioManager.startRecording()
                }
                
                QuickActionButton(
                    title: "Recent Recordings",
                    subtitle: "View your latest captures",
                    icon: "clock.arrow.circlepath",
                    color: .blue
                ) {
                    // Navigate to recent recordings
                }
            }
        }
    }
}

struct NotesTabView: View {
    @EnvironmentObject var notesManager: NotesManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Notes Overview")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                StatCard(
                    title: "Total Notes",
                    value: "\(notesManager.notes.count)",
                    icon: "doc.text",
                    color: .blue
                )
                
                StatCard(
                    title: "Starred",
                    value: "\(notesManager.starredNotes.count)",
                    icon: "star.fill",
                    color: .yellow
                )
                
                StatCard(
                    title: "Total Duration",
                    value: formatDuration(notesManager.totalDuration),
                    icon: "clock",
                    color: .green
                )
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        return "\(hours)h \(minutes)m"
    }
}

struct FilesTabView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("File Management")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                QuickActionButton(
                    title: "Export All",
                    subtitle: "Export all notes and recordings",
                    icon: "square.and.arrow.up",
                    color: .green
                ) {
                    // Export functionality
                }
                
                QuickActionButton(
                    title: "Backup Data",
                    subtitle: "Create backup of all data",
                    icon: "externaldrive.fill",
                    color: .orange
                ) {
                    // Backup functionality
                }
            }
        }
    }
}

struct RecentTabView: View {
    @EnvironmentObject var notesManager: NotesManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.headline)
                .fontWeight(.semibold)
            
            if notesManager.recentNotes.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("No recent activity")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(notesManager.recentNotes.prefix(5)) { note in
                            RecentNoteRow(note: note)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Main Content View
struct MainContentView: View {
    let selectedTab: Int
    @EnvironmentObject var audioManager: AudioRecordingManager
    @EnvironmentObject var transcriptionManager: TranscriptionManager
    
    var body: some View {
        Group {
            switch selectedTab {
            case 0:
                RecordingView()
            case 1:
                NotesView()
            case 2:
                FilesView()
            case 3:
                RecentView()
            default:
                RecordingView()
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
}

// MARK: - Key Points View
struct KeyPointsView: View {
    @EnvironmentObject var audioManager: AudioRecordingManager
    @EnvironmentObject var transcriptionManager: TranscriptionManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Key Points")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "eye")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if audioManager.isRecording {
                        LiveTranscriptionView()
                    } else {
                        KeyPointsContent()
                    }
                }
                .padding()
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct LiveTranscriptionView: View {
    @EnvironmentObject var audioManager: AudioRecordingManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "waveform")
                    .foregroundColor(.green)
                
                Text("Live Transcription")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(formatDuration(audioManager.recordingDuration))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(audioManager.currentTranscription.isEmpty ? "Listening..." : audioManager.currentTranscription)
                .font(.body)
                .foregroundColor(.primary)
                .animation(.easeInOut(duration: 0.3), value: audioManager.currentTranscription)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct KeyPointsContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("No active recording")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• Start recording to see live transcription")
                Text("• Key points will appear here")
                Text("• Export options will be available")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
}

// MARK: - Supporting Views
struct QuickActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct RecentNoteRow: View {
    let note: Note
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.text")
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(note.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(formatDate(note.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if note.isStarred {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Placeholder Views
// RecordingView and NotesView are now implemented in separate files

// FilesView is now implemented in a separate file

struct RecentView: View {
    var body: some View {
        VStack {
            Text("Recent View")
                .font(.title)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
        .environmentObject(AudioRecordingManager())
        .environmentObject(TranscriptionManager())
        .environmentObject(NotesManager())
        .environmentObject(PermissionManager())
        .environmentObject(SettingsManager())
}
