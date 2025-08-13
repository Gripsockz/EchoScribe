import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                SettingsHeader()
                
                // Content
                HStack(spacing: 0) {
                    // Sidebar
                    SettingsSidebar(selectedTab: $selectedTab)
                    
                    // Main Content
                    SettingsContent(selectedTab: selectedTab)
                }
            }
        }
        .navigationViewStyle(.automatic)
        .frame(width: 800, height: 600)
    }
}

struct SettingsHeader: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack {
            Text("Settings")
                .font(.title)
                .fontWeight(.bold)
            
            Spacer()
            
            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct SettingsSidebar: View {
    @Binding var selectedTab: Int
    
    private let tabs = [
        ("General", "gear"),
        ("Recording", "mic"),
        ("AI & Transcription", "brain.head.profile"),
        ("Export", "square.and.arrow.up"),
        ("Storage", "externaldrive"),
        ("Advanced", "slider.horizontal.3")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                SettingsTabButton(
                    title: tab.0,
                    icon: tab.1,
                    isSelected: selectedTab == index
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = index
                    }
                }
            }
            
            Spacer()
        }
        .frame(width: 200)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct SettingsTabButton: View {
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
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
    }
}

struct SettingsContent: View {
    let selectedTab: Int
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                switch selectedTab {
                case 0:
                    GeneralSettingsView()
                case 1:
                    RecordingSettingsView()
                case 2:
                    AISettingsView()
                case 3:
                    ExportSettingsView()
                case 4:
                    StorageSettingsView()
                case 5:
                    AdvancedSettingsView()
                default:
                    GeneralSettingsView()
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

// MARK: - General Settings
struct GeneralSettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SettingsSection(title: "Appearance") {
                VStack(alignment: .leading, spacing: 16) {
                    SettingsRow(
                        title: "Theme",
                        subtitle: "Choose your preferred appearance",
                        content: {
                            Picker("Theme", selection: $settingsManager.theme) {
                                ForEach(SettingsManager.AppTheme.allCases, id: \.self) { theme in
                                    HStack {
                                        Image(systemName: theme.icon)
                                        Text(theme.rawValue)
                                    }
                                    .tag(theme)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    )
                }
            }
            
            SettingsSection(title: "Interface") {
                VStack(alignment: .leading, spacing: 16) {
                    SettingsToggle(
                        title: "Show Recording Timer",
                        subtitle: "Display recording duration during capture",
                        isOn: $settingsManager.showRecordingTimer
                    )
                    
                    SettingsToggle(
                        title: "Enable Sound Effects",
                        subtitle: "Play sounds for recording start/stop",
                        isOn: $settingsManager.enableSoundEffects
                    )
                    
                    SettingsToggle(
                        title: "Enable Haptic Feedback",
                        subtitle: "Provide tactile feedback for actions",
                        isOn: $settingsManager.enableHapticFeedback
                    )
                    
                    SettingsToggle(
                        title: "Enable Keyboard Shortcuts",
                        subtitle: "Allow keyboard shortcuts for quick actions",
                        isOn: $settingsManager.enableKeyboardShortcuts
                    )
                }
            }
            
            SettingsSection(title: "Privacy") {
                VStack(alignment: .leading, spacing: 16) {
                    SettingsToggle(
                        title: "Enable Analytics",
                        subtitle: "Help improve EchoScribe with anonymous usage data",
                        isOn: $settingsManager.enableAnalytics
                    )
                    
                    SettingsToggle(
                        title: "Enable Crash Reporting",
                        subtitle: "Send crash reports to help fix issues",
                        isOn: $settingsManager.enableCrashReporting
                    )
                }
            }
        }
    }
}

// MARK: - Recording Settings
struct RecordingSettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SettingsSection(title: "Default Settings") {
                VStack(alignment: .leading, spacing: 16) {
                    SettingsRow(
                        title: "Default Recording Source",
                        subtitle: "Choose the default audio source for new recordings",
                        content: {
                            Picker("Recording Source", selection: $settingsManager.defaultRecordingSource) {
                                ForEach(SettingsManager.RecordingSource.allCases, id: \.self) { source in
                                    HStack {
                                        Image(systemName: source.icon)
                                        Text(source.rawValue)
                                    }
                                    .tag(source)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    )
                    
                    SettingsRow(
                        title: "Maximum Recording Duration",
                        subtitle: "Set the maximum length for recordings (in minutes)",
                        content: {
                            HStack {
                                Slider(
                                    value: Binding(
                                        get: { settingsManager.maxRecordingDuration / 60 },
                                        set: { settingsManager.maxRecordingDuration = $0 * 60 }
                                    ),
                                    in: 1...120,
                                    step: 1
                                )
                                Text("\(Int(settingsManager.maxRecordingDuration / 60)) min")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    )
                }
            }
            
            SettingsSection(title: "Audio Quality") {
                VStack(alignment: .leading, spacing: 16) {
                    SettingsToggle(
                        title: "Enable Audio Level Monitoring",
                        subtitle: "Show real-time audio levels during recording",
                        isOn: $settingsManager.enableAudioLevelMonitoring
                    )
                    
                    SettingsToggle(
                        title: "Enable Real-time Transcription",
                        subtitle: "Show live transcription as you record",
                        isOn: $settingsManager.enableRealTimeTranscription
                    )
                }
            }
            
            SettingsSection(title: "Auto-save") {
                VStack(alignment: .leading, spacing: 16) {
                    SettingsToggle(
                        title: "Enable Auto-save",
                        subtitle: "Automatically save recordings at regular intervals",
                        isOn: Binding(
                            get: { settingsManager.autoSaveInterval > 0 },
                            set: { if !$0 { settingsManager.autoSaveInterval = 0 } }
                        )
                    )
                    
                    if settingsManager.autoSaveInterval > 0 {
                        SettingsRow(
                            title: "Auto-save Interval",
                            subtitle: "How often to auto-save recordings (in seconds)",
                            content: {
                                HStack {
                                    Slider(
                                        value: $settingsManager.autoSaveInterval,
                                        in: 10...300,
                                        step: 10
                                    )
                                    Text("\(Int(settingsManager.autoSaveInterval))s")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        )
                    }
                }
            }
        }
    }
}

// MARK: - AI Settings
struct AISettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SettingsSection(title: "Note Formatting") {
                VStack(alignment: .leading, spacing: 16) {
                    SettingsRow(
                        title: "Default Note Format",
                        subtitle: "Choose the default format for AI-generated notes",
                        content: {
                            Picker("Note Format", selection: $settingsManager.defaultNoteFormat) {
                                ForEach(SettingsManager.NoteFormat.allCases, id: \.self) { format in
                                    HStack {
                                        Image(systemName: format.icon)
                                        Text(format.rawValue)
                                    }
                                    .tag(format)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    )
                }
            }
            
            SettingsSection(title: "AI Processing") {
                VStack(alignment: .leading, spacing: 16) {
                    SettingsToggle(
                        title: "Enable AI Enhancement",
                        subtitle: "Use AI to improve transcription quality and formatting",
                        isOn: .constant(true)
                    )
                    
                    SettingsToggle(
                        title: "Language Detection",
                        subtitle: "Automatically detect and transcribe in multiple languages",
                        isOn: .constant(true)
                    )
                }
            }
            
            SettingsSection(title: "Privacy") {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "lock.shield")
                            .foregroundColor(.green)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Local Processing")
                                .font(.body)
                                .fontWeight(.medium)
                            
                            Text("All AI processing happens locally on your device. No audio or transcription data is sent to external servers.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }
}

// MARK: - Export Settings
struct ExportSettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SettingsSection(title: "Default Export Format") {
                VStack(alignment: .leading, spacing: 16) {
                    SettingsRow(
                        title: "Default Export Format",
                        subtitle: "Choose the default format for exported notes",
                        content: {
                            Picker("Export Format", selection: $settingsManager.defaultExportFormat) {
                                ForEach(SettingsManager.ExportFormat.allCases, id: \.self) { format in
                                    HStack {
                                        Image(systemName: format.icon)
                                        Text(format.rawValue)
                                    }
                                    .tag(format)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    )
                }
            }
            
            SettingsSection(title: "Export Options") {
                VStack(alignment: .leading, spacing: 16) {
                    SettingsToggle(
                        title: "Include Audio Files",
                        subtitle: "Include original audio files in exports",
                        isOn: .constant(true)
                    )
                    
                    SettingsToggle(
                        title: "Include Metadata",
                        subtitle: "Include recording metadata in exports",
                        isOn: .constant(true)
                    )
                    
                    SettingsToggle(
                        title: "Compress Exports",
                        subtitle: "Compress exported files to save space",
                        isOn: .constant(true)
                    )
                }
            }
            
            SettingsSection(title: "Cloud Integration") {
                VStack(alignment: .leading, spacing: 16) {
                    SettingsToggle(
                        title: "Enable Cloud Sync",
                        subtitle: "Sync your notes and recordings across devices",
                        isOn: $settingsManager.enableCloudSync
                    )
                }
            }
        }
    }
}

// MARK: - Storage Settings
struct StorageSettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SettingsSection(title: "Storage Location") {
                VStack(alignment: .leading, spacing: 16) {
                    SettingsRow(
                        title: "Default Storage Location",
                        subtitle: "Choose where to store your recordings and notes",
                        content: {
                            Picker("Storage Location", selection: $settingsManager.storageLocation) {
                                ForEach(SettingsManager.StorageLocation.allCases, id: \.self) { location in
                                    HStack {
                                        Image(systemName: location.icon)
                                        Text(location.rawValue)
                                    }
                                    .tag(location)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    )
                    
                    if settingsManager.storageLocation == .custom {
                        SettingsRow(
                            title: "Custom Path",
                            subtitle: "Enter the custom storage path",
                            content: {
                                TextField("Path", text: $settingsManager.customStoragePath)
                                    .textFieldStyle(.roundedBorder)
                            }
                        )
                    }
                }
            }
            
            SettingsSection(title: "Backup") {
                VStack(alignment: .leading, spacing: 16) {
                    SettingsToggle(
                        title: "Enable Auto Backup",
                        subtitle: "Automatically backup your data",
                        isOn: $settingsManager.enableAutoBackup
                    )
                    
                    if settingsManager.enableAutoBackup {
                        SettingsRow(
                            title: "Backup Frequency",
                            subtitle: "How often to create backups",
                            content: {
                                Picker("Backup Frequency", selection: $settingsManager.backupFrequency) {
                                    ForEach(SettingsManager.BackupFrequency.allCases, id: \.self) { frequency in
                                        HStack {
                                            Image(systemName: frequency.icon)
                                            Text(frequency.rawValue)
                                        }
                                        .tag(frequency)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                        )
                    }
                }
            }
            
            SettingsSection(title: "Storage Management") {
                VStack(alignment: .leading, spacing: 16) {
                    Button("View Storage Usage") {
                        // Show storage usage
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Clean Up Old Files") {
                        // Clean up functionality
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Export All Data") {
                        // Export functionality
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

// MARK: - Advanced Settings
struct AdvancedSettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SettingsSection(title: "Performance") {
                VStack(alignment: .leading, spacing: 16) {
                    SettingsToggle(
                        title: "Enable Hardware Acceleration",
                        subtitle: "Use hardware acceleration for better performance",
                        isOn: .constant(true)
                    )
                    
                    SettingsToggle(
                        title: "Optimize for Battery Life",
                        subtitle: "Reduce power consumption during recording",
                        isOn: .constant(false)
                    )
                }
            }
            
            SettingsSection(title: "Debugging") {
                VStack(alignment: .leading, spacing: 16) {
                    Button("Export Settings") {
                        if let url = settingsManager.exportSettings() {
                            print("Settings exported to: \(url)")
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Import Settings") {
                        // Import functionality
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Reset to Defaults") {
                        settingsManager.resetToDefaults()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
            }
            
            SettingsSection(title: "About") {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Version")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("1")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            content
        }
    }
}

struct SettingsRow<Content: View>: View {
    let title: String
    let subtitle: String
    let content: Content
    
    init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            content
        }
    }
}

struct SettingsToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsManager())
}
