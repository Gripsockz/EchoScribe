import Foundation
import SwiftUI
import UniformTypeIdentifiers
import PDFKit
import NaturalLanguage

// MARK: - Export Format Models
enum ExportFormat: String, CaseIterable {
    case markdown = "Markdown"
    case pdf = "PDF"
    case plainText = "Plain Text"
    case richText = "Rich Text"
    case html = "HTML"
    case json = "JSON"
    case csv = "CSV"
    case word = "Word Document"
    case obsidian = "Obsidian"
    case notion = "Notion"
    case appleNotes = "Apple Notes"
    case audioOnly = "Audio Only"
    
    var fileExtension: String {
        switch self {
        case .markdown: return "md"
        case .pdf: return "pdf"
        case .plainText: return "txt"
        case .richText: return "rtf"
        case .html: return "html"
        case .json: return "json"
        case .csv: return "csv"
        case .word: return "docx"
        case .obsidian: return "md"
        case .notion: return "md"
        case .appleNotes: return "txt"
        case .audioOnly: return "m4a"
        }
    }
    
    var mimeType: String {
        switch self {
        case .markdown: return "text/markdown"
        case .pdf: return "application/pdf"
        case .plainText: return "text/plain"
        case .richText: return "application/rtf"
        case .html: return "text/html"
        case .json: return "application/json"
        case .csv: return "text/csv"
        case .word: return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case .obsidian: return "text/markdown"
        case .notion: return "text/markdown"
        case .appleNotes: return "text/plain"
        case .audioOnly: return "audio/mp4"
        }
    }
}

// MARK: - Export Configuration
struct ExportConfiguration {
    var format: ExportFormat = .markdown
    var includeAudio: Bool = true
    var includeTranscription: Bool = true
    var includeNotes: Bool = true
    var includeMetadata: Bool = true
    var includeTimestamps: Bool = true
    var includeSpeakerLabels: Bool = true
    var includeConfidenceScores: Bool = false
    var includeAudioWaveform: Bool = false
    var includeKeywords: Bool = true
    var includeSummary: Bool = true
    var includeSentiment: Bool = false
    var customTemplate: String?
    var outputDirectory: URL?
    var filename: String?
}

// MARK: - Export Manager
class ExportManager: ObservableObject {
    @Published var isExporting = false
    @Published var exportProgress: Double = 0.0
    @Published var currentExportFormat: ExportFormat = .markdown
    @Published var exportHistory: [ExportRecord] = []
    @Published var lastExportError: String?
    
    private let fileManager = FileManager.default
    private let dateFormatter = DateFormatter()
    
    init() {
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
    }
    
    // MARK: - Main Export Function
    func exportRecording(_ recording: Recording, with configuration: ExportConfiguration) async throws -> URL {
        await MainActor.run {
            isExporting = true
            exportProgress = 0.0
            lastExportError = nil
        }
        
        defer {
            Task { @MainActor in
                isExporting = false
                exportProgress = 1.0
            }
        }
        
        let exportURL = try await performExport(recording, with: configuration)
        
        await MainActor.run {
            let record = ExportRecord(
                id: UUID(),
                recordingId: recording.id,
                format: configuration.format,
                exportDate: Date(),
                fileURL: exportURL,
                fileSize: getFileSize(exportURL)
            )
            exportHistory.append(record)
        }
        
        return exportURL
    }
    
    // MARK: - Format-Specific Export
    private func performExport(_ recording: Recording, with config: ExportConfiguration) async throws -> URL {
        let outputURL = try getOutputURL(for: recording, with: config)
        
        switch config.format {
        case .markdown:
            return try await exportToMarkdown(recording, config: config, outputURL: outputURL)
        case .pdf:
            return try await exportToPDF(recording, config: config, outputURL: outputURL)
        case .plainText:
            return try await exportToPlainText(recording, config: config, outputURL: outputURL)
        case .richText:
            return try await exportToRichText(recording, config: config, outputURL: outputURL)
        case .html:
            return try await exportToHTML(recording, config: config, outputURL: outputURL)
        case .json:
            return try await exportToJSON(recording, config: config, outputURL: outputURL)
        case .csv:
            return try await exportToCSV(recording, config: config, outputURL: outputURL)
        case .word:
            return try await exportToWord(recording, config: config, outputURL: outputURL)
        case .obsidian:
            return try await exportToObsidian(recording, config: config, outputURL: outputURL)
        case .notion:
            return try await exportToNotion(recording, config: config, outputURL: outputURL)
        case .appleNotes:
            return try await exportToAppleNotes(recording, config: config, outputURL: outputURL)
        case .audioOnly:
            return try await exportAudioOnly(recording, config: config, outputURL: outputURL)
        }
    }
    
    // MARK: - Markdown Export
    private func exportToMarkdown(_ recording: Recording, config: ExportConfiguration, outputURL: URL) async throws -> URL {
        var markdown = ""
        
        // Header
        markdown += "# \(recording.title)\n\n"
        
        if config.includeMetadata {
            markdown += "**Recording Details:**\n"
            markdown += "- **Date:** \(formatDate(recording.createdAt))\n"
            markdown += "- **Duration:** \(formatDuration(recording.duration))\n"
            markdown += "- **File Size:** \(formatFileSize(recording.fileSize))\n"
            markdown += "- **Quality:** \(recording.quality.rawValue)\n\n"
        }
        
        if config.includeSummary && !recording.summary.isEmpty {
            markdown += "## Summary\n\n\(recording.summary)\n\n"
        }
        
        if config.includeKeywords && !recording.keywords.isEmpty {
            markdown += "## Keywords\n\n"
            markdown += recording.keywords.map { "`\($0)`" }.joined(separator: " ")
            markdown += "\n\n"
        }
        
        if config.includeTranscription && !recording.transcription.isEmpty {
            markdown += "## Transcription\n\n"
            
            for segment in recording.transcriptionSegments {
                if config.includeTimestamps {
                    markdown += "**[\(formatTimestamp(segment.startTime))]** "
                }
                
                if config.includeSpeakerLabels && segment.speaker != nil {
                    markdown += "**\(segment.speaker!):** "
                }
                
                markdown += segment.text
                
                if config.includeConfidenceScores {
                    markdown += " *(confidence: \(Int(segment.confidence * 100))%)*"
                }
                
                markdown += "\n\n"
            }
        }
        
        if config.includeNotes && !recording.notes.isEmpty {
            markdown += "## Notes\n\n\(recording.notes)\n\n"
        }
        
        try markdown.write(to: outputURL, atomically: true, encoding: .utf8)
        return outputURL
    }
    
    // MARK: - PDF Export
    private func exportToPDF(_ recording: Recording, config: ExportConfiguration, outputURL: URL) async throws -> URL {
        let pdfDocument = PDFDocument()
        let page = PDFPage()
        
        // Create PDF content
        let content = createPDFContent(for: recording, config: config)
        page.setValue(content, forKey: "string")
        
        pdfDocument.insert(page, at: 0)
        pdfDocument.write(to: outputURL)
        
        return outputURL
    }
    
    // MARK: - JSON Export
    private func exportToJSON(_ recording: Recording, config: ExportConfiguration, outputURL: URL) async throws -> URL {
        let exportData = ExportData(
            recording: recording,
            exportDate: Date(),
            format: config.format.rawValue,
            version: "1.0"
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(exportData)
        try jsonData.write(to: outputURL)
        
        return outputURL
    }
    
    // MARK: - Helper Functions
    private func getOutputURL(for recording: Recording, with config: ExportConfiguration) throws -> URL {
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let exportDirectory = documentsDirectory.appendingPathComponent("EchoScribe/Exports")
        
        try fileManager.createDirectory(at: exportDirectory, withIntermediateDirectories: true)
        
        let filename = config.filename ?? "\(recording.title)_\(dateFormatter.string(from: Date()))"
        let fileURL = exportDirectory.appendingPathComponent("\(filename).\(config.format.fileExtension)")
        
        return fileURL
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
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
    
    private func formatTimestamp(_ time: TimeInterval) -> String {
        return formatDuration(time)
    }
    
    private func formatFileSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    private func getFileSize(_ url: URL) -> Int64 {
        do {
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64 ?? 0
        } catch {
            return 0
        }
    }
    
    private func createPDFContent(for recording: Recording, config: ExportConfiguration) -> String {
        var content = ""
        content += "\(recording.title)\n\n"
        
        if config.includeMetadata {
            content += "Recording Details:\n"
            content += "Date: \(formatDate(recording.createdAt))\n"
            content += "Duration: \(formatDuration(recording.duration))\n\n"
        }
        
        if config.includeTranscription {
            content += "Transcription:\n\n"
            for segment in recording.transcriptionSegments {
                if config.includeTimestamps {
                    content += "[\(formatTimestamp(segment.startTime))] "
                }
                content += segment.text + "\n"
            }
        }
        
        return content
    }
    
    // MARK: - Placeholder Export Functions
    private func exportToPlainText(_ recording: Recording, config: ExportConfiguration, outputURL: URL) async throws -> URL {
        // Implementation for plain text export
        let content = "Plain text export for \(recording.title)"
        try content.write(to: outputURL, atomically: true, encoding: .utf8)
        return outputURL
    }
    
    private func exportToRichText(_ recording: Recording, config: ExportConfiguration, outputURL: URL) async throws -> URL {
        // Implementation for rich text export
        let content = "Rich text export for \(recording.title)"
        try content.write(to: outputURL, atomically: true, encoding: .utf8)
        return outputURL
    }
    
    private func exportToHTML(_ recording: Recording, config: ExportConfiguration, outputURL: URL) async throws -> URL {
        // Implementation for HTML export
        let content = "<html><body><h1>\(recording.title)</h1></body></html>"
        try content.write(to: outputURL, atomically: true, encoding: .utf8)
        return outputURL
    }
    
    private func exportToCSV(_ recording: Recording, config: ExportConfiguration, outputURL: URL) async throws -> URL {
        // Implementation for CSV export
        let content = "Timestamp,Speaker,Text,Confidence\n"
        try content.write(to: outputURL, atomically: true, encoding: .utf8)
        return outputURL
    }
    
    private func exportToWord(_ recording: Recording, config: ExportConfiguration, outputURL: URL) async throws -> URL {
        // Implementation for Word export
        let content = "Word document export for \(recording.title)"
        try content.write(to: outputURL, atomically: true, encoding: .utf8)
        return outputURL
    }
    
    private func exportToObsidian(_ recording: Recording, config: ExportConfiguration, outputURL: URL) async throws -> URL {
        // Implementation for Obsidian export
        return try await exportToMarkdown(recording, config: config, outputURL: outputURL)
    }
    
    private func exportToNotion(_ recording: Recording, config: ExportConfiguration, outputURL: URL) async throws -> URL {
        // Implementation for Notion export
        return try await exportToMarkdown(recording, config: config, outputURL: outputURL)
    }
    
    private func exportToAppleNotes(_ recording: Recording, config: ExportConfiguration, outputURL: URL) async throws -> URL {
        // Implementation for Apple Notes export
        let content = "Apple Notes export for \(recording.title)"
        try content.write(to: outputURL, atomically: true, encoding: .utf8)
        return outputURL
    }
    
    private func exportAudioOnly(_ recording: Recording, config: ExportConfiguration, outputURL: URL) async throws -> URL {
        // Implementation for audio-only export
        if let audioURL = recording.audioURL {
            try fileManager.copyItem(at: audioURL, to: outputURL)
        }
        return outputURL
    }
}

// MARK: - Supporting Models
struct ExportRecord: Identifiable, Codable {
    let id: UUID
    let recordingId: UUID
    let format: ExportFormat
    let exportDate: Date
    let fileURL: URL
    let fileSize: Int64
}

struct ExportData: Codable {
    let recording: Recording
    let exportDate: Date
    let format: String
    let version: String
}
