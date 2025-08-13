import SwiftUI

struct RecordingView: View {
    @EnvironmentObject var audioManager: AudioRecordingManager
    @EnvironmentObject var transcriptionManager: TranscriptionManager
    @EnvironmentObject var notesManager: NotesManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    @State private var recordingTitle = ""
    @State private var showSaveDialog = false
    @State private var selectedNoteFormat: TranscriptionManager.NoteFormat = .detailed
    @State private var isProcessingNote = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            RecordingHeader()
            
            // Main Content
            ScrollView {
                VStack(spacing: 24) {
                    // Recording Controls
                    RecordingControlsSection()
                    
                    // Audio Visualization
                    AudioVisualizationSection()
                    
                    // Live Transcription
                    LiveTranscriptionSection()
                    
                    // Recording Info
                    RecordingInfoSection()
                }
                .padding()
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .onAppear {
            selectedNoteFormat = settingsManager.defaultNoteFormat
        }
        .sheet(isPresented: $showSaveDialog) {
            SaveRecordingView(
                title: $recordingTitle,
                noteFormat: $selectedNoteFormat,
                isProcessing: $isProcessingNote
            )
        }
    }
}

// MARK: - Recording Header
struct RecordingHeader: View {
    @EnvironmentObject var audioManager: AudioRecordingManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Recording")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(audioManager.isRecording ? "Live Recording" : "Ready to Record")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Recording Status Indicator
            if audioManager.isRecording {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .scaleEffect(1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: audioManager.isRecording)
                    
                    Text("REC")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.red.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
}

// MARK: - Recording Controls Section
struct RecordingControlsSection: View {
    @EnvironmentObject var audioManager: AudioRecordingManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        VStack(spacing: 20) {
            // Main Recording Button
            MainRecordingButton()
            
            // Secondary Controls
            HStack(spacing: 16) {
                // Pause/Resume Button
                SecondaryButton(
                    title: audioManager.isPaused ? "Resume" : "Pause",
                    icon: audioManager.isPaused ? "play.fill" : "pause.fill",
                    color: .orange,
                    isEnabled: audioManager.isRecording
                ) {
                    audioManager.togglePause()
                }
                
                // Stop Button
                SecondaryButton(
                    title: "Stop",
                    icon: "stop.fill",
                    color: .red,
                    isEnabled: audioManager.isRecording
                ) {
                    audioManager.stopRecording()
                }
            }
            
            // Recording Mode Selector
            RecordingModeSelector()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct MainRecordingButton: View {
    @EnvironmentObject var audioManager: AudioRecordingManager
    
    var body: some View {
        Button(action: {
            audioManager.toggleRecording()
        }) {
            ZStack {
                Circle()
                    .fill(audioManager.isRecording ? Color.red : Color.accentColor)
                    .frame(width: 120, height: 120)
                    .shadow(color: audioManager.isRecording ? Color.red.opacity(0.3) : Color.accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
                
                if audioManager.isRecording {
                    // Recording animation
                    Circle()
                        .stroke(Color.red.opacity(0.3), lineWidth: 4)
                        .frame(width: 140, height: 140)
                        .scaleEffect(1.0)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false), value: audioManager.isRecording)
                }
                
                Image(systemName: audioManager.isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(audioManager.isRecording ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: audioManager.isRecording)
    }
}

struct SecondaryButton: View {
    let title: String
    let icon: String
    let color: Color
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
            }
            .foregroundColor(isEnabled ? color : .secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isEnabled ? color.opacity(0.1) : Color.secondary.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isEnabled ? color.opacity(0.3) : Color.secondary.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

struct RecordingModeSelector: View {
    @EnvironmentObject var audioManager: AudioRecordingManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recording Mode")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                ForEach(AudioRecordingManager.RecordingMode.allCases, id: \.self) { mode in
                    RecordingModeButton(
                        mode: mode,
                        isSelected: audioManager.recordingMode == mode,
                        isEnabled: !audioManager.isRecording
                    ) {
                        audioManager.recordingMode = mode
                    }
                }
            }
        }
    }
}

struct RecordingModeButton: View {
    let mode: AudioRecordingManager.RecordingMode
    let isSelected: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: mode.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(mode.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.5)
    }
}

// MARK: - Audio Visualization Section
struct AudioVisualizationSection: View {
    @EnvironmentObject var audioManager: AudioRecordingManager
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Audio Level")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if audioManager.isRecording {
                    Text(formatDuration(audioManager.recordingDuration))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                }
            }
            
            // Waveform Visualization
            WaveformView(audioLevel: audioManager.audioLevel, isRecording: audioManager.isRecording)
            
            // Audio Level Meter
            AudioLevelMeter(audioLevel: audioManager.audioLevel)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct WaveformView: View {
    let audioLevel: Float
    let isRecording: Bool
    
    @State private var waveformData: [CGFloat] = Array(repeating: 0.1, count: 50)
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(waveformData.enumerated()), id: \.offset) { index, height in
                RoundedRectangle(cornerRadius: 2)
                    .fill(isRecording ? Color.accentColor : Color.secondary)
                    .frame(width: 4, height: max(4, height * 60))
                    .animation(.easeInOut(duration: 0.1), value: height)
            }
        }
        .frame(height: 60)
        .onChange(of: audioLevel) { _ in
            updateWaveform()
        }
        .onChange(of: isRecording) { _ in
            if !isRecording {
                resetWaveform()
            }
        }
    }
    
    private func updateWaveform() {
        guard isRecording else { return }
        
        let normalizedLevel = CGFloat(max(0, audioLevel + 60) / 60) // Normalize to 0-1
        let newHeight = 0.1 + normalizedLevel * 0.9
        
        // Shift waveform data
        waveformData.removeFirst()
        waveformData.append(newHeight)
    }
    
    private func resetWaveform() {
        waveformData = Array(repeating: 0.1, count: 50)
    }
}

struct AudioLevelMeter: View {
    let audioLevel: Float
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Level")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(audioLevel)) dB")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 8)
                    
                    // Level indicator
                    RoundedRectangle(cornerRadius: 4)
                        .fill(levelColor)
                        .frame(width: levelWidth(in: geometry), height: 8)
                        .animation(.easeInOut(duration: 0.1), value: audioLevel)
                }
            }
            .frame(height: 8)
        }
    }
    
    private var levelColor: Color {
        let normalizedLevel = max(0, audioLevel + 60) / 60
        if normalizedLevel > 0.8 {
            return .red
        } else if normalizedLevel > 0.6 {
            return .orange
        } else if normalizedLevel > 0.4 {
            return .yellow
        } else {
            return .green
        }
    }
    
    private func levelWidth(in geometry: GeometryProxy) -> CGFloat {
        let normalizedLevel = max(0, audioLevel + 60) / 60
        return geometry.size.width * CGFloat(normalizedLevel)
    }
}

// MARK: - Live Transcription Section
struct LiveTranscriptionSection: View {
    @EnvironmentObject var audioManager: AudioRecordingManager
    @EnvironmentObject var transcriptionManager: TranscriptionManager
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Live Transcription")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if audioManager.isRecording {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                        
                        Text("Live")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            // Transcription Display
            TranscriptionDisplay()
            
            // Confidence Indicator
            if audioManager.isRecording && !audioManager.currentTranscription.isEmpty {
                ConfidenceIndicator(confidence: transcriptionManager.confidenceScore)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct TranscriptionDisplay: View {
    @EnvironmentObject var audioManager: AudioRecordingManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if audioManager.currentTranscription.isEmpty {
                    HStack {
                        Image(systemName: "waveform")
                            .foregroundColor(.secondary)
                        
                        Text(audioManager.isRecording ? "Listening..." : "Start recording to see transcription")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                } else {
                    Text(audioManager.currentTranscription)
                        .font(.body)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.accentColor.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
            }
        }
        .frame(maxHeight: 200)
    }
}

struct ConfidenceIndicator: View {
    let confidence: Double
    
    var body: some View {
        HStack(spacing: 8) {
            Text("Confidence:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ProgressView(value: confidence)
                .progressViewStyle(LinearProgressViewStyle(tint: confidenceColor))
                .frame(width: 100)
            
            Text("\(Int(confidence * 100))%")
                .font(.caption)
                .foregroundColor(confidenceColor)
        }
    }
    
    private var confidenceColor: Color {
        if confidence > 0.8 {
            return .green
        } else if confidence > 0.6 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Recording Info Section
struct RecordingInfoSection: View {
    @EnvironmentObject var audioManager: AudioRecordingManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recording Info")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if audioManager.isRecording {
                    Button("Save Note") {
                        // Trigger save dialog
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(audioManager.currentTranscription.isEmpty)
                }
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                InfoCard(
                    title: "Mode",
                    value: audioManager.recordingMode.rawValue,
                    icon: audioManager.recordingMode.icon
                )
                
                InfoCard(
                    title: "Quality",
                    value: audioManager.recordingQuality.rawValue,
                    icon: "waveform"
                )
                
                InfoCard(
                    title: "Duration",
                    value: formatDuration(audioManager.recordingDuration),
                    icon: "clock"
                )
                
                InfoCard(
                    title: "Status",
                    value: recordingStatus,
                    icon: statusIcon
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var recordingStatus: String {
        if audioManager.isRecording {
            return audioManager.isPaused ? "Paused" : "Recording"
        } else {
            return "Ready"
        }
    }
    
    private var statusIcon: String {
        if audioManager.isRecording {
            return audioManager.isPaused ? "pause.circle" : "record.circle"
        } else {
            return "mic.circle"
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.accentColor)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.1))
        )
    }
}

// MARK: - Save Recording View
struct SaveRecordingView: View {
    @Binding var title: String
    @Binding var noteFormat: TranscriptionManager.NoteFormat
    @Binding var isProcessing: Bool
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var audioManager: AudioRecordingManager
    @EnvironmentObject var transcriptionManager: TranscriptionManager
    @EnvironmentObject var notesManager: NotesManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Title Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recording Title")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    TextField("Enter recording title", text: $title)
                        .textFieldStyle(.roundedBorder)
                }
                
                // Note Format Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Note Format")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Picker("Note Format", selection: $noteFormat) {
                        ForEach(TranscriptionManager.NoteFormat.allCases, id: \.self) { format in
                            HStack {
                                Image(systemName: format.icon)
                                Text(format.rawValue)
                            }
                            .tag(format)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Preview
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preview")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    ScrollView {
                        Text(audioManager.currentTranscription)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.secondary.opacity(0.1))
                            )
                    }
                    .frame(maxHeight: 200)
                }
                
                Spacer()
                
                // Action Buttons
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button("Save Note") {
                        saveNote()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(title.isEmpty || isProcessing)
                }
            }
            .padding()
            .frame(width: 500, height: 600)
            .navigationTitle("Save Recording")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func saveNote() {
        isProcessing = true
        
        Task {
            // Process transcription with AI
            let processedContent = await transcriptionManager.processTranscription(
                audioManager.currentTranscription,
                format: noteFormat
            )
            
            // Save to notes manager
            notesManager.addNote(
                title: title,
                content: processedContent,
                duration: audioManager.recordingDuration,
                format: noteFormat.rawValue,
                audioURL: audioManager.currentRecordingFileURL,
                transcription: audioManager.currentTranscription
            )
            
            await MainActor.run {
                isProcessing = false
                dismiss()
            }
        }
    }
}

#Preview {
    RecordingView()
        .environmentObject(AudioRecordingManager())
        .environmentObject(TranscriptionManager())
        .environmentObject(NotesManager())
        .environmentObject(SettingsManager())
}
