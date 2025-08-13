import Foundation
import AVFoundation
import ScreenCaptureKit
import SwiftUI
import Combine

@MainActor
class PermissionManager: ObservableObject {
    // MARK: - Published Properties
    @Published var microphonePermission: PermissionStatus = .unknown
    @Published var screenCapturePermission: PermissionStatus = .unknown
    @Published var speechRecognitionPermission: PermissionStatus = .unknown
    @Published var fileAccessPermission: PermissionStatus = .unknown
    @Published var allPermissionsGranted = false
    @Published var showPermissionAlert = false
    @Published var permissionAlertMessage = ""
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Enums
    enum PermissionStatus {
        case unknown, granted, denied, restricted
        
        var description: String {
            switch self {
            case .unknown:
                return "Not determined"
            case .granted:
                return "Granted"
            case .denied:
                return "Denied"
            case .restricted:
                return "Restricted"
            }
        }
        
        var icon: String {
            switch self {
            case .unknown:
                return "questionmark.circle"
            case .granted:
                return "checkmark.circle.fill"
            case .denied:
                return "xmark.circle.fill"
            case .restricted:
                return "exclamationmark.triangle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .unknown:
                return .orange
            case .granted:
                return .green
            case .denied:
                return .red
            case .restricted:
                return .yellow
            }
        }
    }
    
    enum PermissionType {
        case microphone
        case screenCapture
        case speechRecognition
        case fileAccess
        
        var title: String {
            switch self {
            case .microphone:
                return "Microphone Access"
            case .screenCapture:
                return "Screen Recording"
            case .speechRecognition:
                return "Speech Recognition"
            case .fileAccess:
                return "File Access"
            }
        }
        
        var description: String {
            switch self {
            case .microphone:
                return "EchoScribe needs microphone access to record audio for transcription."
            case .screenCapture:
                return "EchoScribe needs screen recording access to capture system audio."
            case .speechRecognition:
                return "EchoScribe needs speech recognition to transcribe your audio in real-time."
            case .fileAccess:
                return "EchoScribe needs file access to save your recordings and notes."
            }
        }
        
        var icon: String {
            switch self {
            case .microphone:
                return "mic.fill"
            case .screenCapture:
                return "display"
            case .speechRecognition:
                return "waveform"
            case .fileAccess:
                return "folder"
            }
        }
    }
    
    // MARK: - Initialization
    init() {
        setupObservers()
        checkAllPermissions()
    }
    
    // MARK: - Setup Methods
    private func setupObservers() {
        // Observe permission changes and update allPermissionsGranted
        Publishers.CombineLatest4($microphonePermission, $screenCapturePermission, $speechRecognitionPermission, $fileAccessPermission)
            .map { mic, screen, speech, file in
                return mic == .granted && screen == .granted && speech == .granted && file == .granted
            }
            .assign(to: &$allPermissionsGranted)
    }
    
    // MARK: - Public Methods
    func checkAllPermissions() {
        checkMicrophonePermission()
        checkScreenCapturePermission()
        checkSpeechRecognitionPermission()
        checkFileAccessPermission()
    }
    
    func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            Task { @MainActor in
                self?.microphonePermission = granted ? .granted : .denied
                self?.updatePermissionStatus()
            }
        }
    }
    
    func requestScreenCapturePermission() {
        Task {
            do {
                let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
                screenCapturePermission = !content.displays.isEmpty ? .granted : .denied
            } catch {
                screenCapturePermission = .denied
            }
            updatePermissionStatus()
        }
    }
    
    func requestSpeechRecognitionPermission() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            Task { @MainActor in
                switch status {
                case .authorized:
                    self?.speechRecognitionPermission = .granted
                case .denied:
                    self?.speechRecognitionPermission = .denied
                case .restricted:
                    self?.speechRecognitionPermission = .restricted
                case .notDetermined:
                    self?.speechRecognitionPermission = .unknown
                @unknown default:
                    self?.speechRecognitionPermission = .unknown
                }
                self?.updatePermissionStatus()
            }
        }
    }
    
    func requestFileAccessPermission() {
        // For macOS, file access is typically granted through entitlements
        // We'll check if we can access the Documents directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let testFile = documentsPath.appendingPathComponent("test_permission.txt")
        
        do {
            try "test".write(to: testFile, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(at: testFile)
            fileAccessPermission = .granted
        } catch {
            fileAccessPermission = .denied
        }
        updatePermissionStatus()
    }
    
    func requestAllPermissions() {
        requestMicrophonePermission()
        requestScreenCapturePermission()
        requestSpeechRecognitionPermission()
        requestFileAccessPermission()
    }
    
    func openSystemPreferences(for permissionType: PermissionType) {
        switch permissionType {
        case .microphone:
            openSystemPreferencesMicrophone()
        case .screenCapture:
            openSystemPreferencesScreenCapture()
        case .speechRecognition:
            openSystemPreferencesSpeechRecognition()
        case .fileAccess:
            openSystemPreferencesFileAccess()
        }
    }
    
    func showPermissionAlert(for permissionType: PermissionType) {
        permissionAlertMessage = """
        \(permissionType.title) Required
        
        \(permissionType.description)
        
        Please grant this permission in System Preferences to continue using EchoScribe.
        """
        showPermissionAlert = true
    }
    
    // MARK: - Private Methods
    private func checkMicrophonePermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            microphonePermission = .granted
        case .denied:
            microphonePermission = .denied
        case .undetermined:
            microphonePermission = .unknown
        @unknown default:
            microphonePermission = .unknown
        }
    }
    
    private func checkScreenCapturePermission() {
        Task {
            do {
                let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
                screenCapturePermission = !content.displays.isEmpty ? .granted : .denied
            } catch {
                screenCapturePermission = .denied
            }
        }
    }
    
    private func checkSpeechRecognitionPermission() {
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized:
            speechRecognitionPermission = .granted
        case .denied:
            speechRecognitionPermission = .denied
        case .restricted:
            speechRecognitionPermission = .restricted
        case .notDetermined:
            speechRecognitionPermission = .unknown
        @unknown default:
            speechRecognitionPermission = .unknown
        }
    }
    
    private func checkFileAccessPermission() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let testFile = documentsPath.appendingPathComponent("test_permission.txt")
        
        do {
            try "test".write(to: testFile, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(at: testFile)
            fileAccessPermission = .granted
        } catch {
            fileAccessPermission = .denied
        }
    }
    
    private func updatePermissionStatus() {
        // This method can be used to perform any additional logic when permissions change
        print("Permissions updated - Microphone: \(microphonePermission), Screen: \(screenCapturePermission), Speech: \(speechRecognitionPermission), File: \(fileAccessPermission)")
    }
    
    private func openSystemPreferencesMicrophone() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func openSystemPreferencesScreenCapture() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func openSystemPreferencesSpeechRecognition() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_SpeechRecognition") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func openSystemPreferencesFileAccess() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_FullDiskAccess") {
            NSWorkspace.shared.open(url)
        }
    }
    
    // MARK: - Public Getters
    var missingPermissions: [PermissionType] {
        var missing: [PermissionType] = []
        
        if microphonePermission != .granted {
            missing.append(.microphone)
        }
        if screenCapturePermission != .granted {
            missing.append(.screenCapture)
        }
        if speechRecognitionPermission != .granted {
            missing.append(.speechRecognition)
        }
        if fileAccessPermission != .granted {
            missing.append(.fileAccess)
        }
        
        return missing
    }
    
    var permissionStatuses: [PermissionType: PermissionStatus] {
        return [
            .microphone: microphonePermission,
            .screenCapture: screenCapturePermission,
            .speechRecognition: speechRecognitionPermission,
            .fileAccess: fileAccessPermission
        ]
    }
    
    var canRecordAudio: Bool {
        return microphonePermission == .granted
    }
    
    var canCaptureSystemAudio: Bool {
        return screenCapturePermission == .granted
    }
    
    var canTranscribe: Bool {
        return speechRecognitionPermission == .granted
    }
    
    var canSaveFiles: Bool {
        return fileAccessPermission == .granted
    }
}
