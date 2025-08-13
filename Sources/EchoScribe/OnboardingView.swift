import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var permissionManager: PermissionManager
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep = 0
    @State private var showPermissionRequests = false
    
    private let totalSteps = 4
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header
                OnboardingHeader(currentStep: currentStep, totalSteps: totalSteps)
                
                // Content
                OnboardingContent(
                    currentStep: currentStep,
                    permissionManager: permissionManager,
                    settingsManager: settingsManager
                )
                
                // Footer
                OnboardingFooter(
                    currentStep: currentStep,
                    totalSteps: totalSteps,
                    permissionManager: permissionManager,
                    onNext: nextStep,
                    onPrevious: previousStep,
                    onComplete: completeOnboarding
                )
            }
            .frame(width: 600, height: 500)
            .background(Color(NSColor.controlBackgroundColor))
        }
        .onAppear {
            checkPermissions()
        }
    }
    
    private func nextStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if currentStep < totalSteps - 1 {
                currentStep += 1
            }
        }
    }
    
    private func previousStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if currentStep > 0 {
                currentStep -= 1
            }
        }
    }
    
    private func completeOnboarding() {
        // Save onboarding completion
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
        dismiss()
    }
    
    private func checkPermissions() {
        permissionManager.checkAllPermissions()
    }
}

// MARK: - Onboarding Header
struct OnboardingHeader: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        VStack(spacing: 20) {
            // App Icon and Title
            VStack(spacing: 16) {
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                
                VStack(spacing: 8) {
                    Text("Welcome to EchoScribe")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Premium Audio Recording & AI Transcription")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress Bar
            ProgressBar(currentStep: currentStep, totalSteps: totalSteps)
        }
        .padding(.top, 40)
        .padding(.horizontal, 40)
    }
}

struct ProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Circle()
                        .fill(step <= currentStep ? Color.accentColor : Color.secondary.opacity(0.3))
                        .frame(width: 12, height: 12)
                        .scaleEffect(step == currentStep ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: currentStep)
                }
            }
            
            Text("Step \(currentStep + 1) of \(totalSteps)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Onboarding Content
struct OnboardingContent: View {
    let currentStep: Int
    let permissionManager: PermissionManager
    let settingsManager: SettingsManager
    
    var body: some View {
        VStack(spacing: 30) {
            switch currentStep {
            case 0:
                WelcomeStep()
            case 1:
                PermissionsStep(permissionManager: permissionManager)
            case 2:
                PreferencesStep(settingsManager: settingsManager)
            case 3:
                CompletionStep()
            default:
                WelcomeStep()
            }
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Text("Transform Your Audio into Intelligent Notes")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("EchoScribe combines powerful audio recording with AI-powered transcription to help you capture, organize, and extract insights from your conversations, meetings, and ideas.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            
            VStack(spacing: 16) {
                FeatureRow(
                    icon: "mic.fill",
                    title: "High-Quality Recording",
                    description: "Record from microphone, system audio, or both simultaneously"
                )
                
                FeatureRow(
                    icon: "brain.head.profile",
                    title: "AI Transcription",
                    description: "Real-time transcription with multiple note format options"
                )
                
                FeatureRow(
                    icon: "lock.shield",
                    title: "Privacy First",
                    description: "All processing happens locally on your device"
                )
                
                FeatureRow(
                    icon: "square.and.arrow.up",
                    title: "Export & Share",
                    description: "Export in multiple formats and share seamlessly"
                )
            }
        }
    }
}

struct PermissionsStep: View {
    let permissionManager: PermissionManager
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Text("Required Permissions")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("EchoScribe needs access to certain system features to provide the best recording and transcription experience.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                PermissionRow(
                    type: .microphone,
                    status: permissionManager.microphonePermission,
                    onRequest: { permissionManager.requestMicrophonePermission() }
                )
                
                PermissionRow(
                    type: .screenCapture,
                    status: permissionManager.screenCapturePermission,
                    onRequest: { permissionManager.requestScreenCapturePermission() }
                )
                
                PermissionRow(
                    type: .speechRecognition,
                    status: permissionManager.speechRecognitionPermission,
                    onRequest: { permissionManager.requestSpeechRecognitionPermission() }
                )
                
                PermissionRow(
                    type: .fileAccess,
                    status: permissionManager.fileAccessPermission,
                    onRequest: { permissionManager.requestFileAccessPermission() }
                )
            }
            
            if !permissionManager.allPermissionsGranted {
                VStack(spacing: 8) {
                    Text("Some permissions are required for full functionality")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Button("Request All Permissions") {
                        permissionManager.requestAllPermissions()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

struct PreferencesStep: View {
    let settingsManager: SettingsManager
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Text("Initial Preferences")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Customize EchoScribe to match your workflow and preferences.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 20) {
                PreferenceRow(
                    title: "Default Recording Source",
                    options: SettingsManager.RecordingSource.allCases,
                    selectedOption: settingsManager.defaultRecordingSource
                ) { newValue in
                    settingsManager.defaultRecordingSource = newValue
                }
                
                PreferenceRow(
                    title: "Default Note Format",
                    options: SettingsManager.NoteFormat.allCases,
                    selectedOption: settingsManager.defaultNoteFormat
                ) { newValue in
                    settingsManager.defaultNoteFormat = newValue
                }
                
                PreferenceRow(
                    title: "App Theme",
                    options: SettingsManager.AppTheme.allCases,
                    selectedOption: settingsManager.theme
                ) { newValue in
                    settingsManager.theme = newValue
                }
            }
        }
    }
}

struct CompletionStep: View {
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("You're All Set!")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("EchoScribe is ready to help you capture and organize your audio content. Start recording to experience the power of AI-powered transcription.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                Text("Quick Start Tips:")
                    .font(.headline)
                    .fontWeight(.medium)
                
                VStack(alignment: .leading, spacing: 8) {
                    TipRow(text: "Press Space to start/stop recording")
                    TipRow(text: "Use Cmd+N for new recording")
                    TipRow(text: "Export notes in multiple formats")
                    TipRow(text: "Customize settings anytime")
                }
            }
        }
    }
}

// MARK: - Onboarding Footer
struct OnboardingFooter: View {
    let currentStep: Int
    let totalSteps: Int
    let permissionManager: PermissionManager
    let onNext: () -> Void
    let onPrevious: () -> Void
    let onComplete: () -> Void
    
    var body: some View {
        HStack {
            // Previous Button
            if currentStep > 0 {
                Button("Previous") {
                    onPrevious()
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
            
            // Next/Complete Button
            if currentStep == totalSteps - 1 {
                Button("Get Started") {
                    onComplete()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!permissionManager.allPermissionsGranted)
            } else {
                Button("Next") {
                    onNext()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 40)
    }
}

// MARK: - Supporting Views
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct PermissionRow: View {
    let type: PermissionManager.PermissionType
    let status: PermissionManager.PermissionStatus
    let onRequest: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: type.icon)
                .font(.title3)
                .foregroundColor(status.color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(type.title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(type.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Image(systemName: status.icon)
                    .font(.caption)
                    .foregroundColor(status.color)
                
                Text(status.description)
                    .font(.caption)
                    .foregroundColor(status.color)
            }
            
            if status != .granted {
                Button("Grant") {
                    onRequest()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(status.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct PreferenceRow<T: CaseIterable & RawRepresentable>: View where T.RawValue == String {
    let title: String
    let options: T.AllCases
    let selectedOption: T
    let onSelection: (T) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
            
            Picker(title, selection: Binding(
                get: { selectedOption },
                set: { onSelection($0) }
            )) {
                ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

struct TipRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .font(.caption)
                .foregroundColor(.yellow)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(PermissionManager())
        .environmentObject(SettingsManager())
}
