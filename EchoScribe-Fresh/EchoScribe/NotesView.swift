import SwiftUI

struct NotesView: View {
    @EnvironmentObject var notesManager: NotesManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    @State private var searchText = ""
    @State private var selectedFilter: NotesManager.NoteFilter = .all
    @State private var sortOrder: NotesManager.SortOrder = .dateDesc
    @State private var showNoteDetail = false
    @State private var selectedNote: Note?
    @State private var showExportDialog = false
    @State private var selectedNotes: Set<UUID> = []
    @State private var isSelectionMode = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            NotesHeader(
                searchText: $searchText,
                selectedFilter: $selectedFilter,
                sortOrder: $sortOrder,
                isSelectionMode: $isSelectionMode,
                selectedNotes: $selectedNotes,
                showExportDialog: $showExportDialog
            )
            
            // Content
            if notesManager.isLoading {
                LoadingView()
            } else if notesManager.notes.isEmpty {
                EmptyNotesView()
            } else {
                NotesList(
                    notes: filteredNotes,
                    selectedNotes: $selectedNotes,
                    isSelectionMode: $isSelectionMode,
                    onNoteSelected: { note in
                        selectedNote = note
                        showNoteDetail = true
                    }
                )
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .sheet(isPresented: $showNoteDetail) {
            if let note = selectedNote {
                NoteDetailView(note: note)
            }
        }
        .sheet(isPresented: $showExportDialog) {
            ExportDialogView(selectedNotes: Array(selectedNotes))
        }
        .onChange(of: searchText) { _ in
            notesManager.searchText = searchText
        }
        .onChange(of: selectedFilter) { _ in
            notesManager.selectedFilter = selectedFilter
        }
        .onChange(of: sortOrder) { _ in
            notesManager.sortOrder = sortOrder
        }
    }
    
    private var filteredNotes: [Note] {
        return notesManager.filteredNotes
    }
}

// MARK: - Notes Header
struct NotesHeader: View {
    @Binding var searchText: String
    @Binding var selectedFilter: NotesManager.NoteFilter
    @Binding var sortOrder: NotesManager.SortOrder
    @Binding var isSelectionMode: Bool
    @Binding var selectedNotes: Set<UUID>
    @Binding var showExportDialog: Bool
    @EnvironmentObject var notesManager: NotesManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Top Row
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notes")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(notesManager.notes.count) total notes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 12) {
                    if isSelectionMode {
                        Button("Cancel") {
                            isSelectionMode = false
                            selectedNotes.removeAll()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Export Selected (\(selectedNotes.count))") {
                            showExportDialog = true
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(selectedNotes.isEmpty)
                    } else {
                        Button("Select") {
                            isSelectionMode = true
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Export All") {
                            selectedNotes = Set(notesManager.notes.map { $0.id })
                            showExportDialog = true
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(notesManager.notes.isEmpty)
                    }
                }
            }
            
            // Search and Filters
            HStack(spacing: 16) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search notes...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.1))
                )
                
                // Filter Picker
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(NotesManager.NoteFilter.allCases, id: \.self) { filter in
                        HStack {
                            Image(systemName: filter.icon)
                            Text(filter.rawValue)
                        }
                        .tag(filter)
                    }
                }
                .pickerStyle(.menu)
                
                // Sort Picker
                Picker("Sort", selection: $sortOrder) {
                    ForEach(NotesManager.SortOrder.allCases, id: \.self) { order in
                        HStack {
                            Image(systemName: order.icon)
                            Text(order.rawValue)
                        }
                        .tag(order)
                    }
                }
                .pickerStyle(.menu)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
}

// MARK: - Notes List
struct NotesList: View {
    let notes: [Note]
    @Binding var selectedNotes: Set<UUID>
    @Binding var isSelectionMode: Bool
    let onNoteSelected: (Note) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(notes) { note in
                    NoteRow(
                        note: note,
                        isSelected: selectedNotes.contains(note.id),
                        isSelectionMode: isSelectionMode,
                        onToggleSelection: {
                            if selectedNotes.contains(note.id) {
                                selectedNotes.remove(note.id)
                            } else {
                                selectedNotes.insert(note.id)
                            }
                        },
                        onNoteSelected: onNoteSelected
                    )
                }
            }
            .padding()
        }
    }
}

struct NoteRow: View {
    let note: Note
    let isSelected: Bool
    let isSelectionMode: Bool
    let onToggleSelection: () -> Void
    let onNoteSelected: (Note) -> Void
    @EnvironmentObject var notesManager: NotesManager
    
    var body: some View {
        HStack(spacing: 16) {
            // Selection Checkbox
            if isSelectionMode {
                Button(action: onToggleSelection) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(isSelected ? .accentColor : .secondary)
                }
                .buttonStyle(.plain)
            }
            
            // Note Icon
            Image(systemName: noteIcon)
                .font(.title2)
                .foregroundColor(noteColor)
                .frame(width: 32)
            
            // Note Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(note.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if note.isStarred {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
                
                Text(note.content.prefix(100) + (note.content.count > 100 ? "..." : ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(formatDate(note.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formatDuration(note.duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(note.format)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.secondary.opacity(0.1))
                        )
                }
            }
            
            // Action Buttons
            if !isSelectionMode {
                HStack(spacing: 8) {
                    Button(action: {
                        notesManager.toggleStar(note)
                    }) {
                        Image(systemName: note.isStarred ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(note.isStarred ? .yellow : .secondary)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        onNoteSelected(note)
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if isSelectionMode {
                onToggleSelection()
            } else {
                onNoteSelected(note)
            }
        }
    }
    
    private var noteIcon: String {
        if note.audioURL != nil {
            return "waveform"
        } else {
            return "doc.text"
        }
    }
    
    private var noteColor: Color {
        if note.audioURL != nil {
            return .blue
        } else {
            return .green
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Note Detail View
struct NoteDetailView: View {
    let note: Note
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var notesManager: NotesManager
    @State private var showExportDialog = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Note Header
                    NoteDetailHeader(note: note)
                    
                    // Note Content
                    NoteDetailContent(note: note)
                    
                    // Transcription (if available)
                    if !note.transcription.isEmpty {
                        NoteDetailTranscription(note: note)
                    }
                    
                    // Metadata
                    NoteDetailMetadata(note: note)
                }
                .padding()
            }
            .navigationTitle(note.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Export") {
                            showExportDialog = true
                        }
                        
                        Button("Star/Unstar") {
                            notesManager.toggleStar(note)
                        }
                        
                        Divider()
                        
                        Button("Delete", role: .destructive) {
                            showDeleteAlert = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showExportDialog) {
            ExportDialogView(selectedNotes: [note.id])
        }
        .alert("Delete Note", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                notesManager.deleteNote(note)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this note? This action cannot be undone.")
        }
    }
}

struct NoteDetailHeader: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(note.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                if note.isStarred {
                    Image(systemName: "star.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)
                }
            }
            
            HStack {
                Label(formatDate(note.date), systemImage: "calendar")
                Label(formatDuration(note.duration), systemImage: "clock")
                Label(note.format, systemImage: "doc.text")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.accentColor.opacity(0.1))
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct NoteDetailContent: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Content")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(note.content)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct NoteDetailTranscription: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Transcription")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(note.transcription)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.green.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct NoteDetailMetadata: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Metadata")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                MetadataItem(title: "Created", value: formatDate(note.date))
                MetadataItem(title: "Modified", value: formatDate(note.lastModified))
                MetadataItem(title: "Duration", value: formatDuration(note.duration))
                MetadataItem(title: "Format", value: note.format)
                MetadataItem(title: "Starred", value: note.isStarred ? "Yes" : "No")
                MetadataItem(title: "Audio", value: note.audioURL != nil ? "Available" : "None")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.1))
        )
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

struct MetadataItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Export Dialog View
struct ExportDialogView: View {
    let selectedNotes: [UUID]
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var notesManager: NotesManager
    @State private var selectedFormat: ExportFormat = .markdown
    @State private var isExporting = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Export Notes")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Export \(selectedNotes.count) note\(selectedNotes.count == 1 ? "" : "s")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Export Format")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Picker("Format", selection: $selectedFormat) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            HStack {
                                Image(systemName: format.icon)
                                Text(format.rawValue)
                            }
                            .tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Spacer()
                
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button("Export") {
                        exportNotes()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isExporting)
                }
            }
            .padding()
            .frame(width: 400, height: 300)
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func exportNotes() {
        isExporting = true
        
        Task {
            let notes = notesManager.notes.filter { selectedNotes.contains($0.id) }
            let _ = await notesManager.exportMultipleNotes(notes, format: selectedFormat)
            
            await MainActor.run {
                isExporting = false
                dismiss()
            }
        }
    }
}

// MARK: - Supporting Views
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading notes...")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyNotesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Notes Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start recording to create your first note")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NotesView()
        .environmentObject(NotesManager())
        .environmentObject(SettingsManager())
}
