import SwiftUI

struct SetupView: View {
    @EnvironmentObject var permissionManager: PermissionManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep = 0
    @State private var showPermissionRequests = false
    
    private let totalSteps = 3
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header
                SetupHeader(currentStep: currentStep, totalSteps: totalSteps)
                
                // Content
                SetupContent(
                    currentStep: currentStep,
                    permissionManager: permissionManager
                )
                
                // Footer
                SetupFooter(
                    currentStep: currentStep,
                    totalSteps: totalSteps,
                    permissionManager: permissionManager,
                    onNext: nextStep,
                    onPrevious: previousStep,
                    onComplete: completeSetup
                )
            }
            .frame(width: 500, height: 400)
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
    
    private func completeSetup() {
        dismiss()
    }
    
    private func checkPermissions() {
        permissionManager.checkAllPermissions()
    }
}

// MARK: - Setup Header
struct SetupHeader: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        VStack(spacing: 20) {
            // App Icon and Title
            VStack(spacing: 16) {
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.accentColor)
                
                VStack(spacing: 8) {
                    Text("EchoScribe Setup")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Configure permissions and preferences")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress Bar
            SetupProgressBar(currentStep: currentStep, totalSteps: totalSteps)
        }
        .padding(.top, 30)
        .padding(.horizontal, 30)
    }
}

struct SetupProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Circle()
                        .fill(step <= currentStep ? Color.accentColor : Color.secondary.opacity(0.3))
                        .frame(width: 10, height: 10)
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

// MARK: - Setup Content
struct SetupContent: View {
    let currentStep: Int
    let permissionManager: PermissionManager
    
    var body: some View {
        VStack(spacing: 30) {
            switch currentStep {
            case 0:
                WelcomeSetupStep()
            case 1:
                PermissionsSetupStep(permissionManager: permissionManager)
            case 2:
                CompletionSetupStep()
            default:
                WelcomeSetupStep()
            }
        }
        .padding(.horizontal, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct WelcomeSetupStep: View {
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Text("Welcome to EchoScribe")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("Let's get you set up with the essential permissions and preferences to start recording and transcribing audio.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            
            VStack(spacing: 16) {
                SetupFeatureRow(
                    icon: "mic.fill",
                    title: "Microphone Access",
                    description: "Record high-quality audio from your microphone"
                )
                
                SetupFeatureRow(
                    icon: "display",
                    title: "Screen Recording",
                    description: "Capture system audio for complete recordings"
                )
                
                SetupFeatureRow(
                    icon: "waveform",
                    title: "Speech Recognition",
                    description: "Real-time transcription of your audio"
                )
                
                SetupFeatureRow(
                    icon: "folder",
                    title: "File Access",
                    description: "Save and organize your recordings and notes"
                )
            }
        }
    }
}

struct PermissionsSetupStep: View {
    let permissionManager: PermissionManager
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Text("Required Permissions")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("EchoScribe needs these permissions to provide the best recording and transcription experience.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                SetupPermissionRow(
                    type: .microphone,
                    status: permissionManager.microphonePermission,
                    onRequest: { permissionManager.requestMicrophonePermission() }
                )
                
                SetupPermissionRow(
                    type: .screenCapture,
                    status: permissionManager.screenCapturePermission,
                    onRequest: { permissionManager.requestScreenCapturePermission() }
                )
                
                SetupPermissionRow(
                    type: .speechRecognition,
                    status: permissionManager.speechRecognitionPermission,
                    onRequest: { permissionManager.requestSpeechRecognitionPermission() }
                )
                
                SetupPermissionRow(
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

struct CompletionSetupStep: View {
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
                
                Text("Setup Complete!")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("EchoScribe is now ready to use. You can start recording and transcribing audio immediately.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                Text("What's Next:")
                    .font(.headline)
                    .fontWeight(.medium)
                
                VStack(alignment: .leading, spacing: 8) {
                    SetupTipRow(text: "Press Space to start/stop recording")
                    SetupTipRow(text: "Use Cmd+N for new recording")
                    SetupTipRow(text: "Access settings anytime from the menu")
                    SetupTipRow(text: "Export notes in multiple formats")
                }
            }
        }
    }
}

// MARK: - Setup Footer
struct SetupFooter: View {
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
            } else {
                Button("Next") {
                    onNext()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 30)
    }
}

// MARK: - Supporting Views
struct SetupFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 28)
            
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

struct SetupPermissionRow: View {
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

struct SetupTipRow: View {
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
    SetupView()
        .environmentObject(PermissionManager())
}
