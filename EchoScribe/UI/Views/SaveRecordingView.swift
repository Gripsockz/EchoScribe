import SwiftUI

struct SaveRecordingView: View {
    @EnvironmentObject var audioManager: AudioRecordingManager
    @EnvironmentObject var notesManager: NotesManager
    @EnvironmentObject var transcriptionManager: TranscriptionManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var noteTitle = ""
    @State private var noteDescription = ""
    @State private var selectedTags: Set<String> = []
    @State private var showTagInput = false
    @State private var newTagName = ""
    @State private var autoGenerateTitle = true
    @State private var autoGenerateSummary = true
    @State private var isSaving = false
    @State private var showSuccessAlert = false
    
    let recording: Recording
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Save Recording")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Recording completed successfully")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Cancel") {
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Divider()
                }
                .padding()
                .background(Color(.windowBackgroundColor))
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Recording Info
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recording Details")
                                .font(.headline)
                            
                            VStack(spacing: 8) {
                                InfoRow(label: "Duration", value: formatDuration(recording.duration))
                                InfoRow(label: "File Size", value: formatFileSize(recording.fileSize))
                                InfoRow(label: "Quality", value: recording.quality.rawValue)
                                InfoRow(label: "Created", value: formatDate(recording.createdAt))
                            }
                            .padding()
                            .background(Color(.controlBackgroundColor))
                            .cornerRadius(8)
                        }
                        
                        // Title and Description
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Note Information")
                                .font(.headline)
                            
                            VStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Title")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        Spacer()
                                        
                                        Toggle("Auto-generate", isOn: $autoGenerateTitle)
                                            .toggleStyle(.switch)
                                            .labelsHidden()
                                    }
                                    
                                    TextField("Enter title...", text: $noteTitle)
                                        .textFieldStyle(.roundedBorder)
                                        .disabled(autoGenerateTitle)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Description")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    TextField("Enter description...", text: $noteDescription, axis: .vertical)
                                        .textFieldStyle(.roundedBorder)
                                        .lineLimit(3...6)
                                }
                            }
                        }
                        
                        // Tags
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Tags")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button("Add Tag") {
                                    showTagInput = true
                                }
                                .buttonStyle(.bordered)
                            }
                            
                            if selectedTags.isEmpty {
                                Text("No tags added")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.controlBackgroundColor))
                                    .cornerRadius(8)
                            } else {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                                    ForEach(Array(selectedTags), id: \.self) { tag in
                                        TagView(tag: tag) {
                                            selectedTags.remove(tag)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // AI Features
                        VStack(alignment: .leading, spacing: 12) {
                            Text("AI Features")
                                .font(.headline)
                            
                            VStack(spacing: 8) {
                                AIFeatureToggle(
                                    title: "Auto-generate Summary",
                                    description: "Create an AI summary of the recording",
                                    isOn: $autoGenerateSummary
                                )
                                
                                AIFeatureToggle(
                                    title: "Extract Keywords",
                                    description: "Identify key topics and themes",
                                    isOn: .constant(true)
                                )
                                
                                AIFeatureToggle(
                                    title: "Speaker Identification",
                                    description: "Identify different speakers",
                                    isOn: .constant(true)
                                )
                            }
                        }
                        
                        // Save Button
                        VStack(spacing: 16) {
                            if isSaving {
                                VStack(spacing: 12) {
                                    ProgressView()
                                        .scaleEffect(1.2)
                                    
                                    Text("Saving recording...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                Button(action: saveRecording) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("Save Recording")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.accentColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                .buttonStyle(.plain)
                                .disabled(noteTitle.isEmpty && !autoGenerateTitle)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Save Recording")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupInitialValues()
        }
        .alert("Add Tag", isPresented: $showTagInput) {
            TextField("Tag name", text: $newTagName)
            Button("Add") {
                if !newTagName.isEmpty {
                    selectedTags.insert(newTagName.trimmingCharacters(in: .whitespacesAndNewlines))
                    newTagName = ""
                }
            }
            Button("Cancel", role: .cancel) {
                newTagName = ""
            }
        }
        .alert("Recording Saved", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your recording has been saved successfully with all AI-generated content.")
        }
    }
    
    private func setupInitialValues() {
        if autoGenerateTitle && noteTitle.isEmpty {
            noteTitle = generateTitle()
        }
        
        if autoGenerateSummary && noteDescription.isEmpty {
            noteDescription = generateSummary()
        }
    }
    
    private func generateTitle() -> String {
        // Generate title based on transcription content
        let words = recording.transcription.components(separatedBy: .whitespacesAndNewlines)
        let firstWords = Array(words.prefix(5)).joined(separator: " ")
        return firstWords.isEmpty ? "Recording \(formatDate(recording.createdAt))" : firstWords
    }
    
    private func generateSummary() -> String {
        // Generate summary based on transcription
        if recording.transcription.isEmpty {
            return "Audio recording with duration \(formatDuration(recording.duration))"
        }
        
        let sentences = recording.transcription.components(separatedBy: ". ")
        let summary = Array(sentences.prefix(2)).joined(separator: ". ")
        return summary.isEmpty ? "Audio recording" : summary
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    private func formatFileSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func saveRecording() {
        isSaving = true
        
        Task {
            // Update recording with new information
            var updatedRecording = recording
            updatedRecording.title = noteTitle
            updatedRecording.notes = noteDescription
            updatedRecording.tags = Array(selectedTags)
            
            // Save to database
            await notesManager.saveRecording(updatedRecording)
            
            await MainActor.run {
                isSaving = false
                showSuccessAlert = true
            }
        }
    }
}

// MARK: - Supporting Views
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct TagView: View {
    let tag: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.caption)
                .fontWeight(.medium)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.accentColor.opacity(0.1))
        .foregroundColor(.accentColor)
        .cornerRadius(12)
    }
}

struct AIFeatureToggle: View {
    let title: String
    let description: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .labelsHidden()
        }
        .padding(.vertical, 4)
    }
}
