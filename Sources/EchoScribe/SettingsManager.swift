import Foundation
import SwiftUI
import Combine

@MainActor
class SettingsManager: ObservableObject {
    // MARK: - Published Properties
    @Published var theme: AppTheme = .auto
    @Published var defaultRecordingSource: RecordingSource = .microphone
    @Published var defaultNoteFormat: NoteFormat = .detailed
    @Published var defaultExportFormat: ExportFormat = .markdown
    @Published var autoSaveInterval: TimeInterval = 30.0
    @Published var enableRealTimeTranscription = true
    @Published var enableAudioLevelMonitoring = true
    @Published var enableAutoBackup = true
    @Published var backupFrequency: BackupFrequency = .weekly
    @Published var maxRecordingDuration: TimeInterval = 3600.0 // 1 hour
    @Published var enableKeyboardShortcuts = true
    @Published var showRecordingTimer = true
    @Published var enableSoundEffects = true
    @Published var enableHapticFeedback = false
    @Published var storageLocation: StorageLocation = .documents
    @Published var customStoragePath: String = ""
    @Published var enableCloudSync = false
    @Published var enableAnalytics = false
    @Published var enableCrashReporting = false
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Enums
    enum AppTheme: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case auto = "Auto"
        
        var icon: String {
            switch self {
            case .light: return "sun.max.fill"
            case .dark: return "moon.fill"
            case .auto: return "gear"
            }
        }
        
        var description: String {
            switch self {
            case .light: return "Always use light appearance"
            case .dark: return "Always use dark appearance"
            case .auto: return "Follow system appearance"
            }
        }
    }
    
    enum RecordingSource: String, CaseIterable {
        case microphone = "Microphone"
        case systemAudio = "System Audio"
        case both = "Both"
        
        var icon: String {
            switch self {
            case .microphone: return "mic.fill"
            case .systemAudio: return "speaker.wave.3.fill"
            case .both: return "mic.and.signal.meter.fill"
            }
        }
        
        var description: String {
            switch self {
            case .microphone: return "Record from microphone only"
            case .systemAudio: return "Record system audio only"
            case .both: return "Record both microphone and system audio"
            }
        }
    }
    
    enum NoteFormat: String, CaseIterable {
        case detailed = "Detailed Notes"
        case summary = "Summary Only"
        case bullet = "Bullet Points"
        case outline = "Outline Format"
        case qa = "Q&A Format"
        case timeline = "Timeline Format"
        case actionItems = "Action Items"
        case keyPoints = "Key Points"
        
        var icon: String {
            switch self {
            case .detailed: return "doc.text"
            case .summary: return "text.quote"
            case .bullet: return "list.bullet"
            case .outline: return "list.number"
            case .qa: return "questionmark.bubble"
            case .timeline: return "clock"
            case .actionItems: return "checklist"
            case .keyPoints: return "star"
            }
        }
    }
    
    enum ExportFormat: String, CaseIterable {
        case markdown = "Markdown"
        case plainText = "Plain Text"
        case richText = "Rich Text"
        case json = "JSON"
        case csv = "CSV"
        
        var icon: String {
            switch self {
            case .markdown: return "doc.text"
            case .plainText: return "doc.plaintext"
            case .richText: return "doc.richtext"
            case .json: return "curlybraces"
            case .csv: return "tablecells"
            }
        }
    }
    
    enum BackupFrequency: String, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case never = "Never"
        
        var icon: String {
            switch self {
            case .daily: return "calendar.day.timeline.left"
            case .weekly: return "calendar.badge.clock"
            case .monthly: return "calendar"
            case .never: return "xmark.circle"
            }
        }
        
        var timeInterval: TimeInterval {
            switch self {
            case .daily: return 86400 // 24 hours
            case .weekly: return 604800 // 7 days
            case .monthly: return 2592000 // 30 days
            case .never: return 0
            }
        }
    }
    
    enum StorageLocation: String, CaseIterable {
        case documents = "Documents"
        case downloads = "Downloads"
        case desktop = "Desktop"
        case custom = "Custom Location"
        
        var icon: String {
            switch self {
            case .documents: return "doc.on.doc"
            case .downloads: return "arrow.down.circle"
            case .desktop: return "display"
            case .custom: return "folder.badge.gearshape"
            }
        }
        
        var path: String {
            switch self {
            case .documents:
                return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path
            case .downloads:
                return FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0].path
            case .desktop:
                return FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0].path
            case .custom:
                return customStoragePath
            }
        }
    }
    
    // MARK: - Initialization
    init() {
        loadSettings()
        setupObservers()
    }
    
    // MARK: - Setup Methods
    private func setupObservers() {
        // Observe all published properties and save them to UserDefaults
        Publishers.CombineLatest(
            $theme,
            $defaultRecordingSource,
            $defaultNoteFormat,
            $defaultExportFormat,
            $autoSaveInterval,
            $enableRealTimeTranscription,
            $enableAudioLevelMonitoring,
            $enableAutoBackup,
            $backupFrequency,
            $maxRecordingDuration,
            $enableKeyboardShortcuts,
            $showRecordingTimer,
            $enableSoundEffects,
            $enableHapticFeedback,
            $storageLocation,
            $customStoragePath,
            $enableCloudSync,
            $enableAnalytics,
            $enableCrashReporting
        )
        .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
        .sink { [weak self] _ in
            self?.saveSettings()
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func resetToDefaults() {
        theme = .auto
        defaultRecordingSource = .microphone
        defaultNoteFormat = .detailed
        defaultExportFormat = .markdown
        autoSaveInterval = 30.0
        enableRealTimeTranscription = true
        enableAudioLevelMonitoring = true
        enableAutoBackup = true
        backupFrequency = .weekly
        maxRecordingDuration = 3600.0
        enableKeyboardShortcuts = true
        showRecordingTimer = true
        enableSoundEffects = true
        enableHapticFeedback = false
        storageLocation = .documents
        customStoragePath = ""
        enableCloudSync = false
        enableAnalytics = false
        enableCrashReporting = false
        
        saveSettings()
    }
    
    func exportSettings() -> URL? {
        let settings = createSettingsDictionary()
        
        do {
            let data = try JSONSerialization.data(withJSONObject: settings, options: .prettyPrinted)
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let settingsURL = documentsPath.appendingPathComponent("EchoScribe_Settings.json")
            try data.write(to: settingsURL)
            return settingsURL
        } catch {
            print("Failed to export settings: \(error)")
            return nil
        }
    }
    
    func importSettings(from url: URL) -> Bool {
        do {
            let data = try Data(contentsOf: url)
            let settings = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            if let settings = settings {
                applySettings(settings)
                saveSettings()
                return true
            }
        } catch {
            print("Failed to import settings: \(error)")
        }
        
        return false
    }
    
    // MARK: - Private Methods
    private func loadSettings() {
        theme = AppTheme(rawValue: userDefaults.string(forKey: "theme") ?? "auto") ?? .auto
        defaultRecordingSource = RecordingSource(rawValue: userDefaults.string(forKey: "defaultRecordingSource") ?? "microphone") ?? .microphone
        defaultNoteFormat = NoteFormat(rawValue: userDefaults.string(forKey: "defaultNoteFormat") ?? "detailed") ?? .detailed
        defaultExportFormat = ExportFormat(rawValue: userDefaults.string(forKey: "defaultExportFormat") ?? "markdown") ?? .markdown
        autoSaveInterval = userDefaults.double(forKey: "autoSaveInterval")
        if autoSaveInterval == 0 { autoSaveInterval = 30.0 }
        
        enableRealTimeTranscription = userDefaults.bool(forKey: "enableRealTimeTranscription")
        enableAudioLevelMonitoring = userDefaults.bool(forKey: "enableAudioLevelMonitoring")
        enableAutoBackup = userDefaults.bool(forKey: "enableAutoBackup")
        backupFrequency = BackupFrequency(rawValue: userDefaults.string(forKey: "backupFrequency") ?? "weekly") ?? .weekly
        maxRecordingDuration = userDefaults.double(forKey: "maxRecordingDuration")
        if maxRecordingDuration == 0 { maxRecordingDuration = 3600.0 }
        
        enableKeyboardShortcuts = userDefaults.bool(forKey: "enableKeyboardShortcuts")
        showRecordingTimer = userDefaults.bool(forKey: "showRecordingTimer")
        enableSoundEffects = userDefaults.bool(forKey: "enableSoundEffects")
        enableHapticFeedback = userDefaults.bool(forKey: "enableHapticFeedback")
        storageLocation = StorageLocation(rawValue: userDefaults.string(forKey: "storageLocation") ?? "documents") ?? .documents
        customStoragePath = userDefaults.string(forKey: "customStoragePath") ?? ""
        enableCloudSync = userDefaults.bool(forKey: "enableCloudSync")
        enableAnalytics = userDefaults.bool(forKey: "enableAnalytics")
        enableCrashReporting = userDefaults.bool(forKey: "enableCrashReporting")
    }
    
    private func saveSettings() {
        userDefaults.set(theme.rawValue, forKey: "theme")
        userDefaults.set(defaultRecordingSource.rawValue, forKey: "defaultRecordingSource")
        userDefaults.set(defaultNoteFormat.rawValue, forKey: "defaultNoteFormat")
        userDefaults.set(defaultExportFormat.rawValue, forKey: "defaultExportFormat")
        userDefaults.set(autoSaveInterval, forKey: "autoSaveInterval")
        userDefaults.set(enableRealTimeTranscription, forKey: "enableRealTimeTranscription")
        userDefaults.set(enableAudioLevelMonitoring, forKey: "enableAudioLevelMonitoring")
        userDefaults.set(enableAutoBackup, forKey: "enableAutoBackup")
        userDefaults.set(backupFrequency.rawValue, forKey: "backupFrequency")
        userDefaults.set(maxRecordingDuration, forKey: "maxRecordingDuration")
        userDefaults.set(enableKeyboardShortcuts, forKey: "enableKeyboardShortcuts")
        userDefaults.set(showRecordingTimer, forKey: "showRecordingTimer")
        userDefaults.set(enableSoundEffects, forKey: "enableSoundEffects")
        userDefaults.set(enableHapticFeedback, forKey: "enableHapticFeedback")
        userDefaults.set(storageLocation.rawValue, forKey: "storageLocation")
        userDefaults.set(customStoragePath, forKey: "customStoragePath")
        userDefaults.set(enableCloudSync, forKey: "enableCloudSync")
        userDefaults.set(enableAnalytics, forKey: "enableAnalytics")
        userDefaults.set(enableCrashReporting, forKey: "enableCrashReporting")
    }
    
    private func createSettingsDictionary() -> [String: Any] {
        return [
            "theme": theme.rawValue,
            "defaultRecordingSource": defaultRecordingSource.rawValue,
            "defaultNoteFormat": defaultNoteFormat.rawValue,
            "defaultExportFormat": defaultExportFormat.rawValue,
            "autoSaveInterval": autoSaveInterval,
            "enableRealTimeTranscription": enableRealTimeTranscription,
            "enableAudioLevelMonitoring": enableAudioLevelMonitoring,
            "enableAutoBackup": enableAutoBackup,
            "backupFrequency": backupFrequency.rawValue,
            "maxRecordingDuration": maxRecordingDuration,
            "enableKeyboardShortcuts": enableKeyboardShortcuts,
            "showRecordingTimer": showRecordingTimer,
            "enableSoundEffects": enableSoundEffects,
            "enableHapticFeedback": enableHapticFeedback,
            "storageLocation": storageLocation.rawValue,
            "customStoragePath": customStoragePath,
            "enableCloudSync": enableCloudSync,
            "enableAnalytics": enableAnalytics,
            "enableCrashReporting": enableCrashReporting,
            "exportDate": ISO8601DateFormatter().string(from: Date())
        ]
    }
    
    private func applySettings(_ settings: [String: Any]) {
        if let themeValue = settings["theme"] as? String {
            theme = AppTheme(rawValue: themeValue) ?? .auto
        }
        if let sourceValue = settings["defaultRecordingSource"] as? String {
            defaultRecordingSource = RecordingSource(rawValue: sourceValue) ?? .microphone
        }
        if let formatValue = settings["defaultNoteFormat"] as? String {
            defaultNoteFormat = NoteFormat(rawValue: formatValue) ?? .detailed
        }
        if let exportValue = settings["defaultExportFormat"] as? String {
            defaultExportFormat = ExportFormat(rawValue: exportValue) ?? .markdown
        }
        if let interval = settings["autoSaveInterval"] as? TimeInterval {
            autoSaveInterval = interval
        }
        if let realTime = settings["enableRealTimeTranscription"] as? Bool {
            enableRealTimeTranscription = realTime
        }
        if let audioLevel = settings["enableAudioLevelMonitoring"] as? Bool {
            enableAudioLevelMonitoring = audioLevel
        }
        if let backup = settings["enableAutoBackup"] as? Bool {
            enableAutoBackup = backup
        }
        if let frequency = settings["backupFrequency"] as? String {
            backupFrequency = BackupFrequency(rawValue: frequency) ?? .weekly
        }
        if let duration = settings["maxRecordingDuration"] as? TimeInterval {
            maxRecordingDuration = duration
        }
        if let shortcuts = settings["enableKeyboardShortcuts"] as? Bool {
            enableKeyboardShortcuts = shortcuts
        }
        if let timer = settings["showRecordingTimer"] as? Bool {
            showRecordingTimer = timer
        }
        if let sound = settings["enableSoundEffects"] as? Bool {
            enableSoundEffects = sound
        }
        if let haptic = settings["enableHapticFeedback"] as? Bool {
            enableHapticFeedback = haptic
        }
        if let location = settings["storageLocation"] as? String {
            storageLocation = StorageLocation(rawValue: location) ?? .documents
        }
        if let path = settings["customStoragePath"] as? String {
            customStoragePath = path
        }
        if let cloud = settings["enableCloudSync"] as? Bool {
            enableCloudSync = cloud
        }
        if let analytics = settings["enableAnalytics"] as? Bool {
            enableAnalytics = analytics
        }
        if let crash = settings["enableCrashReporting"] as? Bool {
            enableCrashReporting = crash
        }
    }
    
    // MARK: - Public Getters
    var storagePath: String {
        return storageLocation.path
    }
    
    var shouldAutoSave: Bool {
        return autoSaveInterval > 0
    }
    
    var shouldBackup: Bool {
        return enableAutoBackup && backupFrequency != .never
    }
    
    var backupTimeInterval: TimeInterval {
        return backupFrequency.timeInterval
    }
    
    var isDarkMode: Bool {
        switch theme {
        case .light:
            return false
        case .dark:
            return true
        case .auto:
            return NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        }
    }
}
