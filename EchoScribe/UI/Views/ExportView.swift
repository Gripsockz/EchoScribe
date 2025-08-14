import SwiftUI

struct ExportView: View {
    @EnvironmentObject var exportManager: ExportManager
    @EnvironmentObject var notesManager: NotesManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedFormat: ExportFormat = .markdown
    @State private var exportConfiguration = ExportConfiguration()
    @State private var showAdvancedOptions = false
    @State private var isExporting = false
    @State private var exportProgress: Double = 0.0
    @State private var showSuccessAlert = false
    @State private var exportedFileURL: URL?
    
    let recording: Recording
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Export Recording")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(recording.title)
                                .font(.headline)
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
                        // Format Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Export Format")
                                .font(.headline)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                                ForEach(ExportFormat.allCases, id: \.self) { format in
                                    FormatCard(
                                        format: format,
                                        isSelected: selectedFormat == format
                                    ) {
                                        selectedFormat = format
                                        exportConfiguration.format = format
                                    }
                                }
                            }
                        }
                        
                        // Basic Options
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Content Options")
                                .font(.headline)
                            
                            VStack(spacing: 8) {
                                ExportOptionToggle(
                                    title: "Include Transcription",
                                    description: "Export the AI-generated transcription",
                                    isOn: $exportConfiguration.includeTranscription
                                )
                                
                                ExportOptionToggle(
                                    title: "Include Notes",
                                    description: "Export your manual notes and annotations",
                                    isOn: $exportConfiguration.includeNotes
                                )
                                
                                ExportOptionToggle(
                                    title: "Include Metadata",
                                    description: "Export recording details and timestamps",
                                    isOn: $exportConfiguration.includeMetadata
                                )
                                
                                ExportOptionToggle(
                                    title: "Include Summary",
                                    description: "Export AI-generated summary",
                                    isOn: $exportConfiguration.includeSummary
                                )
                            }
                        }
                        
                        // Advanced Options
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Advanced Options")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button(showAdvancedOptions ? "Hide" : "Show") {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showAdvancedOptions.toggle()
                                    }
                                }
                                .buttonStyle(.bordered)
                            }
                            
                            if showAdvancedOptions {
                                VStack(spacing: 8) {
                                    ExportOptionToggle(
                                        title: "Include Timestamps",
                                        description: "Add timestamps to transcription segments",
                                        isOn: $exportConfiguration.includeTimestamps
                                    )
                                    
                                    ExportOptionToggle(
                                        title: "Include Speaker Labels",
                                        description: "Add speaker identification labels",
                                        isOn: $exportConfiguration.includeSpeakerLabels
                                    )
                                    
                                    ExportOptionToggle(
                                        title: "Include Confidence Scores",
                                        description: "Show transcription confidence levels",
                                        isOn: $exportConfiguration.includeConfidenceScores
                                    )
                                    
                                    ExportOptionToggle(
                                        title: "Include Keywords",
                                        description: "Export extracted keywords and topics",
                                        isOn: $exportConfiguration.includeKeywords
                                    )
                                    
                                    ExportOptionToggle(
                                        title: "Include Sentiment Analysis",
                                        description: "Export emotional tone analysis",
                                        isOn: $exportConfiguration.includeSentiment
                                    )
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        
                        // Export Button
                        VStack(spacing: 16) {
                            if isExporting {
                                VStack(spacing: 12) {
                                    ProgressView(value: exportProgress)
                                        .progressViewStyle(.linear)
                                    
                                    Text("Exporting... \(Int(exportProgress * 100))%")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                Button(action: performExport) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Export Recording")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.accentColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Export")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Export Successful", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
            Button("Show in Finder") {
                if let url = exportedFileURL {
                    NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: "")
                }
            }
        } message: {
            if let url = exportedFileURL {
                Text("Recording exported successfully to:\n\(url.lastPathComponent)")
            }
        }
    }
    
    private func performExport() {
        isExporting = true
        exportProgress = 0.0
        
        Task {
            do {
                let exportedURL = try await exportManager.exportRecording(recording, with: exportConfiguration)
                
                await MainActor.run {
                    exportedFileURL = exportedURL
                    showSuccessAlert = true
                    isExporting = false
                }
            } catch {
                await MainActor.run {
                    isExporting = false
                    // Handle error
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct FormatCard: View {
    let format: ExportFormat
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: formatIcon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .accentColor)
                
                Text(format.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(format.fileExtension.uppercased())
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.accentColor : Color(.controlBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.accentColor : Color(.separatorColor), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var formatIcon: String {
        switch format {
        case .markdown: return "doc.text"
        case .pdf: return "doc.richtext"
        case .plainText: return "doc.plaintext"
        case .richText: return "doc.richtext"
        case .html: return "globe"
        case .json: return "curlybraces"
        case .csv: return "tablecells"
        case .word: return "doc.wordprocessing"
        case .obsidian: return "bookmark"
        case .notion: return "note.text"
        case .appleNotes: return "note.text.badge.plus"
        case .audioOnly: return "waveform"
        }
    }
}

struct ExportOptionToggle: View {
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
