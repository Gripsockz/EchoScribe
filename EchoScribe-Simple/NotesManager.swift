import Foundation
import CoreData
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
    private let container: NSPersistentContainer
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
        container = NSPersistentContainer(name: "EchoScribeDataModel")
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
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
        let context = container.viewContext
        let noteEntity = NoteEntity(context: context)
        
        noteEntity.id = UUID()
        noteEntity.title = title
        noteEntity.content = content
        noteEntity.date = Date()
        noteEntity.duration = duration
        noteEntity.format = format
        noteEntity.audioURL = audioURL
        noteEntity.transcription = transcription
        noteEntity.isStarred = false
        noteEntity.lastModified = Date()
        
        saveContext()
        loadNotes()
    }
    
    func updateNote(_ note: Note, with newContent: String) {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", note.id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let noteEntity = results.first {
                noteEntity.content = newContent
                noteEntity.lastModified = Date()
                saveContext()
                loadNotes()
            }
        } catch {
            errorMessage = "Failed to update note: \(error.localizedDescription)"
        }
    }
    
    func deleteNote(_ note: Note) {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", note.id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let noteEntity = results.first {
                // Delete associated audio file if it exists
                if let audioURL = noteEntity.audioURL {
                    try? FileManager.default.removeItem(at: audioURL)
                }
                
                context.delete(noteEntity)
                saveContext()
                loadNotes()
            }
        } catch {
            errorMessage = "Failed to delete note: \(error.localizedDescription)"
        }
    }
    
    func toggleStar(_ note: Note) {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", note.id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let noteEntity = results.first {
                noteEntity.isStarred.toggle()
                noteEntity.lastModified = Date()
                saveContext()
                loadNotes()
            }
        } catch {
            errorMessage = "Failed to toggle star: \(error.localizedDescription)"
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
        
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        
        // Apply search filter
        if !searchText.isEmpty {
            let searchPredicate = NSPredicate(format: "title CONTAINS[cd] %@ OR content CONTAINS[cd] %@ OR transcription CONTAINS[cd] %@", searchText, searchText, searchText)
            fetchRequest.predicate = searchPredicate
        }
        
        // Apply content filter
        let filterPredicate = getFilterPredicate()
        if let existingPredicate = fetchRequest.predicate {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [existingPredicate, filterPredicate])
        } else {
            fetchRequest.predicate = filterPredicate
        }
        
        // Apply sort order
        fetchRequest.sortDescriptors = getSortDescriptors()
        
        do {
            let noteEntities = try context.fetch(fetchRequest)
            notes = noteEntities.compactMap { entity in
                guard let id = entity.id,
                      let title = entity.title,
                      let content = entity.content,
                      let date = entity.date,
                      let format = entity.format else { return nil }
                
                return Note(
                    id: id,
                    title: title,
                    content: content,
                    date: date,
                    duration: entity.duration,
                    format: format,
                    audioURL: entity.audioURL,
                    transcription: entity.transcription ?? "",
                    isStarred: entity.isStarred,
                    lastModified: entity.lastModified ?? date
                )
            }
        } catch {
            errorMessage = "Failed to load notes: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func getFilterPredicate() -> NSPredicate {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedFilter {
        case .all:
            return NSPredicate(value: true)
        case .starred:
            return NSPredicate(format: "isStarred == YES")
        case .today:
            let startOfDay = calendar.startOfDay(for: now)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            return NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        case .thisWeek:
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            return NSPredicate(format: "date >= %@", startOfWeek as NSDate)
        case .thisMonth:
            let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            return NSPredicate(format: "date >= %@", startOfMonth as NSDate)
        case .withAudio:
            return NSPredicate(format: "audioURL != nil")
        case .withoutAudio:
            return NSPredicate(format: "audioURL == nil")
        }
    }
    
    private func getSortDescriptors() -> [NSSortDescriptor] {
        switch sortOrder {
        case .dateDesc:
            return [NSSortDescriptor(keyPath: \NoteEntity.date, ascending: false)]
        case .dateAsc:
            return [NSSortDescriptor(keyPath: \NoteEntity.date, ascending: true)]
        case .titleAsc:
            return [NSSortDescriptor(keyPath: \NoteEntity.title, ascending: true)]
        case .titleDesc:
            return [NSSortDescriptor(keyPath: \NoteEntity.title, ascending: false)]
        case .durationDesc:
            return [NSSortDescriptor(keyPath: \NoteEntity.duration, ascending: false)]
        case .durationAsc:
            return [NSSortDescriptor(keyPath: \NoteEntity.duration, ascending: true)]
        }
    }
    
    private func saveContext() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                errorMessage = "Failed to save: \(error.localizedDescription)"
            }
        }
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
    let content: String
    let date: Date
    let duration: TimeInterval
    let format: String
    let audioURL: URL?
    let transcription: String
    var isStarred: Bool
    let lastModified: Date
    
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
            {\rtf1\ansi\deff0 {\fonttbl {\f0 Times New Roman;}}
            \f0\fs24 \b \(note.title)\b0\par
            \par
            \b Date:\b0 \(formatDate(note.date))\par
            \b Duration:\b0 \(formatDuration(note.duration))\par
            \b Format:\b0 \(note.format)\par
            \par
            \b Content:\b0\par
            \(note.content)\par
            \par
            \b Transcription:\b0\par
            \(note.transcription)\par
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
