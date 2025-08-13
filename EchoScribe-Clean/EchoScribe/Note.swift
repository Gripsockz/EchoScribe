import Foundation
import CoreData

// MARK: - Note Model
struct Note: Identifiable, Hashable {
    let id: UUID
    var title: String
    var content: String
    var transcription: String
    var duration: TimeInterval
    var format: String
    var audioURL: URL?
    var createdAt: Date
    var updatedAt: Date
    var isStarred: Bool
    var tags: [String]
    var confidenceScore: Double
    var language: String
    var fileSize: Int64
    var exportFormats: [String]
    
    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        transcription: String = "",
        duration: TimeInterval = 0,
        format: String = "Detailed Notes",
        audioURL: URL? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isStarred: Bool = false,
        tags: [String] = [],
        confidenceScore: Double = 0.0,
        language: String = "en-US",
        fileSize: Int64 = 0,
        exportFormats: [String] = []
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.transcription = transcription
        self.duration = duration
        self.format = format
        self.audioURL = audioURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isStarred = isStarred
        self.tags = tags
        self.confidenceScore = confidenceScore
        self.language = language
        self.fileSize = fileSize
        self.exportFormats = exportFormats
    }
    
    // MARK: - Computed Properties
    var formattedDuration: String {
        return AudioUtils.formatDuration(duration)
    }
    
    var formattedFileSize: String {
        return AudioUtils.formatFileSize(fileSize)
    }
    
    var formattedCreatedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    var formattedUpdatedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: updatedAt)
    }
    
    var isRecent: Bool {
        return Calendar.current.isDateInToday(createdAt) || Calendar.current.isDateInYesterday(createdAt)
    }
    
    var isLongRecording: Bool {
        return duration > 300 // 5 minutes
    }
    
    var hasAudio: Bool {
        return audioURL != nil
    }
    
    var hasTranscription: Bool {
        return !transcription.isEmpty
    }
    
    var wordCount: Int {
        return content.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
    }
    
    var transcriptionWordCount: Int {
        return transcription.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Note Format
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
    
    var description: String {
        switch self {
        case .detailed: return "Complete transcription with timestamps"
        case .summary: return "Condensed summary of main points"
        case .bullet: return "Organized bullet point format"
        case .outline: return "Hierarchical outline structure"
        case .qa: return "Questions and answers format"
        case .timeline: return "Chronological timeline format"
        case .actionItems: return "Extracted action items and tasks"
        case .keyPoints: return "Highlighted key points and insights"
        }
    }
}

// MARK: - Note Export Format
enum NoteExportFormat: String, CaseIterable {
    case markdown = "Markdown"
    case plainText = "Plain Text"
    case richText = "Rich Text"
    case json = "JSON"
    case csv = "CSV"
    case pdf = "PDF"
    
    var fileExtension: String {
        switch self {
        case .markdown: return "md"
        case .plainText: return "txt"
        case .richText: return "rtf"
        case .json: return "json"
        case .csv: return "csv"
        case .pdf: return "pdf"
        }
    }
    
    var mimeType: String {
        switch self {
        case .markdown: return "text/markdown"
        case .plainText: return "text/plain"
        case .richText: return "application/rtf"
        case .json: return "application/json"
        case .csv: return "text/csv"
        case .pdf: return "application/pdf"
        }
    }
    
    var icon: String {
        switch self {
        case .markdown: return "doc.text"
        case .plainText: return "doc.plaintext"
        case .richText: return "doc.richtext"
        case .json: return "doc.json"
        case .csv: return "tablecells"
        case .pdf: return "doc.pdf"
        }
    }
}

// MARK: - Note Filter
struct NoteFilter {
    var searchText: String = ""
    var selectedFormat: NoteFormat?
    var selectedTags: Set<String> = []
    var dateRange: DateRange = .all
    var isStarred: Bool?
    var hasAudio: Bool?
    var sortBy: SortOption = .dateCreated
    var sortOrder: SortOrder = .descending
    
    enum DateRange {
        case all
        case today
        case yesterday
        case thisWeek
        case thisMonth
        case custom(Date, Date)
    }
    
    enum SortOption: String, CaseIterable {
        case dateCreated = "Date Created"
        case dateUpdated = "Date Updated"
        case title = "Title"
        case duration = "Duration"
        case fileSize = "File Size"
        case wordCount = "Word Count"
        
        var icon: String {
            switch self {
            case .dateCreated: return "calendar"
            case .dateUpdated: return "clock"
            case .title: return "textformat"
            case .duration: return "timer"
            case .fileSize: return "externaldrive"
            case .wordCount: return "text.word.spacing"
            }
        }
    }
    
    enum SortOrder: String, CaseIterable {
        case ascending = "Ascending"
        case descending = "Descending"
        
        var icon: String {
            switch self {
            case .ascending: return "arrow.up"
            case .descending: return "arrow.down"
            }
        }
    }
}

// MARK: - Note Statistics
struct NoteStatistics {
    let totalNotes: Int
    let totalDuration: TimeInterval
    let totalFileSize: Int64
    let averageConfidence: Double
    let mostUsedFormat: NoteFormat?
    let mostUsedLanguage: String
    let recentActivity: [Date: Int]
    
    var formattedTotalDuration: String {
        return AudioUtils.formatDuration(totalDuration)
    }
    
    var formattedTotalFileSize: String {
        return AudioUtils.formatFileSize(totalFileSize)
    }
    
    var averageDuration: TimeInterval {
        return totalNotes > 0 ? totalDuration / Double(totalNotes) : 0
    }
    
    var formattedAverageDuration: String {
        return AudioUtils.formatDuration(averageDuration)
    }
}
