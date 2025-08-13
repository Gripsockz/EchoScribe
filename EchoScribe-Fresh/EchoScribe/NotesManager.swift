import Foundation
import SwiftUI
import Combine

@MainActor
class NotesManager: ObservableObject {
    // MARK: - Published Properties
    @Published var notes: [Note] = []
    @Published var currentNote: Note?
    @Published var searchText = ""
    @Published var selectedFilter: NoteFilter = .all
    @Published var sortOrder: SortOrder = .dateDesc
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Enums
    enum NoteFilter: String, CaseIterable {
        case all = "All"
        case starred = "Starred"
        case today = "Today"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        case withAudio = "With Audio"
        case withoutAudio = "Without Audio"
        
        var icon: String {
            switch self {
            case .all: return "folder"
            case .starred: return "star.fill"
            case .today: return "calendar"
            case .thisWeek: return "calendar.badge.clock"
            case .thisMonth: return "calendar.badge.plus"
            case .withAudio: return "waveform"
            case .withoutAudio: return "doc.text"
            }
        }
    }
    
    enum SortOrder: String, CaseIterable {
        case dateDesc = "Newest First"
        case dateAsc = "Oldest First"
        case titleAsc = "Title A-Z"
        case titleDesc = "Title Z-A"
        case durationDesc = "Longest First"
        case durationAsc = "Shortest First"
        
        var icon: String {
            switch self {
            case .dateDesc: return "arrow.down.circle"
            case .dateAsc: return "arrow.up.circle"
            case .titleAsc: return "textformat.abc"
            case .titleDesc: return "textformat.abc.dottedunderline"
            case .durationDesc: return "clock.arrow.circlepath"
            case .durationAsc: return "clock"
            }
        }
    }
    
    // MARK: - Initialization
    init() {
        setupObservers()
        loadNotes()
    }
    
    // MARK: - Setup Methods
    private func setupObservers() {
        // Observe search text changes
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.loadNotes()
            }
            .store(in: &cancellables)
        
        // Observe filter changes
        $selectedFilter
            .sink { [weak self] _ in
                self?.loadNotes()
            }
            .store(in: &cancellables)
        
        // Observe sort order changes
        $sortOrder
            .sink { [weak self] _ in
                self?.loadNotes()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func addNote(title: String, content: String, duration: TimeInterval, format: String, audioURL: URL? = nil, transcription: String = "") {
        let note = Note(
            id: UUID(),
            title: title,
            content: content,
            date: Date(),
            duration: duration,
            format: format,
            audioURL: audioURL,
            transcription: transcription,
            isStarred: false,
            lastModified: Date()
        )
        
        notes.append(note)
        saveNotesToFile()
    }
    
    func updateNote(_ note: Note, with newContent: String) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].content = newContent
            notes[index].lastModified = Date()
            saveNotesToFile()
        }
    }
    
    func deleteNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            // Delete associated audio file if it exists
            if let audioURL = notes[index].audioURL {
                try? FileManager.default.removeItem(at: audioURL)
            }
            
            notes.remove(at: index)
            saveNotesToFile()
        }
    }
    
    func toggleStar(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].isStarred.toggle()
            notes[index].lastModified = Date()
            saveNotesToFile()
        }
    }
    
    func exportNote(_ note: Note, format: ExportFormat) async -> URL? {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let exportURL = try await createExportFile(for: note, format: format)
            return exportURL
        } catch {
            errorMessage = "Export failed: \(error.localizedDescription)"
            return nil
        }
    }
    
    func exportMultipleNotes(_ notes: [Note], format: ExportFormat) async -> URL? {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let exportURL = try await createBatchExportFile(for: notes, format: format)
            return exportURL
        } catch {
            errorMessage = "Batch export failed: \(error.localizedDescription)"
            return nil
        }
    }
    
    // MARK: - Private Methods
    private func loadNotes() {
        isLoading = true
        
        // Load notes from file
        loadNotesFromFile()
        
        // Apply filter and sort
        applyFilterAndSort()
        
        isLoading = false
    }
    
    private func applyFilterAndSort() {
        var filteredNotes = notes
        
        // Apply search filter
        if !searchText.isEmpty {
            filteredNotes = notes.filter { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText) ||
                note.transcription.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply content filter
        switch selectedFilter {
        case .all:
            break
        case .starred:
            filteredNotes = filteredNotes.filter { $0.isStarred }
        case .today:
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            filteredNotes = filteredNotes.filter { calendar.isDate($0.date, inSameDayAs: today) }
        case .thisWeek:
            let calendar = Calendar.current
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
            filteredNotes = filteredNotes.filter { $0.date >= startOfWeek }
        case .thisMonth:
            let calendar = Calendar.current
            let startOfMonth = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
            filteredNotes = filteredNotes.filter { $0.date >= startOfMonth }
        case .withAudio:
            filteredNotes = filteredNotes.filter { $0.audioURL != nil }
        case .withoutAudio:
            filteredNotes = filteredNotes.filter { $0.audioURL == nil }
        }
        
        // Apply sort
        switch sortOrder {
        case .dateDesc:
            filteredNotes.sort { $0.date > $1.date }
        case .dateAsc:
            filteredNotes.sort { $0.date < $1.date }
        case .titleAsc:
            filteredNotes.sort { $0.title < $1.title }
        case .titleDesc:
            filteredNotes.sort { $0.title > $1.title }
        case .durationDesc:
            filteredNotes.sort { $0.duration > $1.duration }
        case .durationAsc:
            filteredNotes.sort { $0.duration < $1.duration }
        }
        
        notes = filteredNotes
    }
    
    private func loadNotesFromFile() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let notesURL = documentsPath.appendingPathComponent("EchoScribe_Notes.json")
        
        guard let data = try? Data(contentsOf: notesURL),
              let loadedNotes = try? JSONDecoder().decode([Note].self, from: data) else {
            return
        }
        
        notes = loadedNotes
    }
    
    private func saveNotesToFile() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let notesURL = documentsPath.appendingPathComponent("EchoScribe_Notes.json")
        
        guard let data = try? JSONEncoder().encode(notes) else { return }
        try? data.write(to: notesURL)
    }
    

    
    private func createExportFile(for note: Note, format: ExportFormat) async throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let echoScribePath = documentsPath.appendingPathComponent("EchoScribe")
        let exportsPath = echoScribePath.appendingPathComponent("Exports")
        
        try? FileManager.default.createDirectory(at: exportsPath, withIntermediateDirectories: true)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        
        let fileName = "\(note.title.replacingOccurrences(of: " ", with: "_"))_\(timestamp).\(format.fileExtension)"
        let exportURL = exportsPath.appendingPathComponent(fileName)
        
        let exportContent = format.exportContent(for: note)
        try exportContent.write(to: exportURL, atomically: true, encoding: .utf8)
        
        return exportURL
    }
    
    private func createBatchExportFile(for notes: [Note], format: ExportFormat) async throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let echoScribePath = documentsPath.appendingPathComponent("EchoScribe")
        let exportsPath = echoScribePath.appendingPathComponent("Exports")
        
        try? FileManager.default.createDirectory(at: exportsPath, withIntermediateDirectories: true)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        
        let fileName = "EchoScribe_Export_\(timestamp).\(format.fileExtension)"
        let exportURL = exportsPath.appendingPathComponent(fileName)
        
        let exportContent = format.exportBatchContent(for: notes)
        try exportContent.write(to: exportURL, atomically: true, encoding: .utf8)
        
        return exportURL
    }
    
    // MARK: - Public Getters
    var filteredNotes: [Note] {
        return notes
    }
    
    var starredNotes: [Note] {
        return notes.filter { $0.isStarred }
    }
    
    var recentNotes: [Note] {
        return Array(notes.prefix(10))
    }
    
    var totalDuration: TimeInterval {
        return notes.reduce(0) { $0 + $1.duration }
    }
    
    var averageDuration: TimeInterval {
        return notes.isEmpty ? 0 : totalDuration / Double(notes.count)
    }
}

// MARK: - Note Model
struct Note: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    var content: String
    let date: Date
    let duration: TimeInterval
    let format: String
    let audioURL: URL?
    let transcription: String
    var isStarred: Bool
    var lastModified: Date
    
    enum CodingKeys: String, CodingKey {
        case id, title, content, date, duration, format, audioURL, transcription, isStarred, lastModified
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Export Format
enum ExportFormat: String, CaseIterable {
    case markdown = "Markdown"
    case plainText = "Plain Text"
    case richText = "Rich Text"
    case json = "JSON"
    case csv = "CSV"
    
    var fileExtension: String {
        switch self {
        case .markdown: return "md"
        case .plainText: return "txt"
        case .richText: return "rtf"
        case .json: return "json"
        case .csv: return "csv"
        }
    }
    
    var icon: String {
        switch self {
        case .markdown: return "doc.text"
        case .plainText: return "doc.plaintext"
        case .richText: return "doc.richtext"
        case .json: return "curlybraces"
        case .csv: return "tablecells"
        }
    }
    
    func exportContent(for note: Note) -> String {
        switch self {
        case .markdown:
            return """
            # \(note.title)
            
            **Date:** \(formatDate(note.date))  
            **Duration:** \(formatDuration(note.duration))  
            **Format:** \(note.format)  
            **Starred:** \(note.isStarred ? "Yes" : "No")
            
            ## Content
            
            \(note.content)
            
            ## Transcription
            
            \(note.transcription)
            """
        case .plainText:
            return """
            \(note.title)
            
            Date: \(formatDate(note.date))
            Duration: \(formatDuration(note.duration))
            Format: \(note.format)
            Starred: \(note.isStarred ? "Yes" : "No")
            
            CONTENT:
            \(note.content)
            
            TRANSCRIPTION:
            \(note.transcription)
            """
        case .richText:
            return """
            {\\rtf1\\ansi\\deff0 {\\fonttbl {\\f0 Times New Roman;}}
            \\f0\\fs24 \\b \(note.title)\\b0\\par
            \\par
            \\b Date:\\b0 \(formatDate(note.date))\\par
            \\b Duration:\\b0 \(formatDuration(note.duration))\\par
            \\b Format:\\b0 \(note.format)\\par
            \\par
            \\b Content:\\b0\\par
            \(note.content)\\par
            \\par
            \\b Transcription:\\b0\\par
            \(note.transcription)\\par
            }
            """
        case .json:
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            if let data = try? encoder.encode(note),
               let jsonString = String(data: data, encoding: .utf8) {
                return jsonString
            }
            return "{}"
        case .csv:
            return """
            "Title","Date","Duration","Format","Starred","Content","Transcription"
            "\(note.title)","\(formatDate(note.date))","\(formatDuration(note.duration))","\(note.format)","\(note.isStarred)","\(note.content.replacingOccurrences(of: "\"", with: "\"\""))","\(note.transcription.replacingOccurrences(of: "\"", with: "\"\""))"
            """
        }
    }
    
    func exportBatchContent(for notes: [Note]) -> String {
        switch self {
        case .markdown:
            var content = "# EchoScribe Export\n\n"
            content += "**Export Date:** \(formatDate(Date()))\n"
            content += "**Total Notes:** \(notes.count)\n\n"
            
            for note in notes {
                content += "## \(note.title)\n\n"
                content += "**Date:** \(formatDate(note.date))\n"
                content += "**Duration:** \(formatDuration(note.duration))\n\n"
                content += "\(note.content)\n\n"
                content += "---\n\n"
            }
            return content
        case .plainText:
            var content = "EchoScribe Export\n\n"
            content += "Export Date: \(formatDate(Date()))\n"
            content += "Total Notes: \(notes.count)\n\n"
            
            for note in notes {
                content += "\(note.title)\n"
                content += "Date: \(formatDate(note.date))\n"
                content += "Duration: \(formatDuration(note.duration))\n\n"
                content += "\(note.content)\n\n"
                content += "---\n\n"
            }
            return content
        case .richText:
            var content = "{\\rtf1\\ansi\\deff0 {\\fonttbl {\\f0 Times New Roman;}}\n"
            content += "\\f0\\fs24 \\b EchoScribe Export\\b0\\par\\par"
            content += "Export Date: \(formatDate(Date()))\\par"
            content += "Total Notes: \(notes.count)\\par\\par"
            
            for note in notes {
                content += "\\b \(note.title)\\b0\\par"
                content += "Date: \(formatDate(note.date))\\par"
                content += "Duration: \(formatDuration(note.duration))\\par\\par"
                content += "\(note.content)\\par\\par"
                content += "---\\par\\par"
            }
            content += "}"
            return content
        case .json:
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            if let data = try? encoder.encode(notes),
               let jsonString = String(data: data, encoding: .utf8) {
                return jsonString
            }
            return "[]"
        case .csv:
            var content = "\"Title\",\"Date\",\"Duration\",\"Format\",\"Starred\",\"Content\",\"Transcription\"\n"
            for note in notes {
                content += "\"\(note.title)\",\"\(formatDate(note.date))\",\"\(formatDuration(note.duration))\",\"\(note.format)\",\"\(note.isStarred)\",\"\(note.content.replacingOccurrences(of: "\"", with: "\"\""))\",\"\(note.transcription.replacingOccurrences(of: "\"", with: "\"\""))\"\n"
            }
            return content
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
