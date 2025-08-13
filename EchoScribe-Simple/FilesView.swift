import SwiftUI

struct FilesView: View {
    @EnvironmentObject var notesManager: NotesManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    @State private var selectedFolder: FileFolder = .recordings
    @State private var showExportDialog = false
    @State private var showBackupDialog = false
    @State private var isExporting = false
    @State private var isBackingUp = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            FilesHeader()
            
            // Content
            HStack(spacing: 0) {
                // Sidebar
                FilesSidebar(selectedFolder: $selectedFolder)
                
                // Main Content
                FilesContent(selectedFolder: selectedFolder)
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .sheet(isPresented: $showExportDialog) {
            ExportDialogView(selectedNotes: notesManager.notes.map { $0.id })
        }
        .sheet(isPresented: $showBackupDialog) {
            BackupDialogView()
        }
    }
}

// MARK: - Files Header
struct FilesHeader: View {
    @EnvironmentObject var notesManager: NotesManager
    @Binding var showExportDialog: Bool
    @Binding var showBackupDialog: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Files")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Manage your recordings and exports")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 12) {
                Button("Backup") {
                    showBackupDialog = true
                }
                .buttonStyle(.bordered)
                
                Button("Export All") {
                    showExportDialog = true
                }
                .buttonStyle(.borderedProminent)
                .disabled(notesManager.notes.isEmpty)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
}

// MARK: - Files Sidebar
struct FilesSidebar: View {
    @Binding var selectedFolder: FileFolder
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(FileFolder.allCases, id: \.self) { folder in
                FileFolderButton(
                    folder: folder,
                    isSelected: selectedFolder == folder
                ) {
                    selectedFolder = folder
                }
            }
            
            Spacer()
        }
        .frame(width: 200)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct FileFolderButton: View {
    let folder: FileFolder
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: folder.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : .primary)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(folder.title)
                        .font(.body)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(folder.description)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer()
                
                if let count = folder.count {
                    Text("\(count)")
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(isSelected ? Color.white.opacity(0.2) : Color.secondary.opacity(0.2))
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
    }
}

// MARK: - Files Content
struct FilesContent: View {
    let selectedFolder: FileFolder
    @EnvironmentObject var notesManager: NotesManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Folder Header
            FolderHeader(folder: selectedFolder)
            
            // Folder Content
            FolderContent(folder: selectedFolder)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct FolderHeader: View {
    let folder: FileFolder
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(folder.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(folder.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Folder Actions
            HStack(spacing: 8) {
                Button("Sort") {
                    // Sort functionality
                }
                .buttonStyle(.bordered)
                
                Button("Filter") {
                    // Filter functionality
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct FolderContent: View {
    let folder: FileFolder
    @EnvironmentObject var notesManager: NotesManager
    
    var body: some View {
        Group {
            switch folder {
            case .recordings:
                RecordingsFolderView()
            case .exports:
                ExportsFolderView()
            case .backups:
                BackupsFolderView()
            case .trash:
                TrashFolderView()
            }
        }
    }
}

// MARK: - Folder Views
struct RecordingsFolderView: View {
    @EnvironmentObject var notesManager: NotesManager
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(notesManager.notes.filter { $0.audioURL != nil }) { note in
                    RecordingFileRow(note: note)
                }
            }
            .padding()
        }
    }
}

struct ExportsFolderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Exports Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Export your notes to see them here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct BackupsFolderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "externaldrive")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Backups Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create a backup to see it here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TrashFolderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "trash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Trash is Empty")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Deleted files will appear here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - File Rows
struct RecordingFileRow: View {
    let note: Note
    @EnvironmentObject var notesManager: NotesManager
    
    var body: some View {
        HStack(spacing: 16) {
            // File Icon
            Image(systemName: "waveform")
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)
            
            // File Info
            VStack(alignment: .leading, spacing: 4) {
                Text(note.title)
                    .font(.body)
                    .fontWeight(.medium)
                
                HStack {
                    Text(formatDate(note.date))
                    Text("•")
                    Text(formatDuration(note.duration))
                    Text("•")
                    Text(formatFileSize())
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // File Actions
            HStack(spacing: 8) {
                Button("Play") {
                    // Play audio
                }
                .buttonStyle(.bordered)
                
                Button("Export") {
                    // Export file
                }
                .buttonStyle(.bordered)
                
                Button("Delete") {
                    notesManager.deleteNote(note)
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
            }
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
    
    private func formatFileSize() -> String {
        // Simulate file size calculation
        let sizeInMB = Double(note.content.count) / 1000.0
        return String(format: "%.1f MB", sizeInMB)
    }
}

// MARK: - Backup Dialog
struct BackupDialogView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var notesManager: NotesManager
    @State private var isBackingUp = false
    @State private var backupLocation: BackupLocation = .documents
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Create Backup")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Backup all your notes and recordings")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Backup Location")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Picker("Location", selection: $backupLocation) {
                        ForEach(BackupLocation.allCases, id: \.self) { location in
                            HStack {
                                Image(systemName: location.icon)
                                Text(location.rawValue)
                            }
                            .tag(location)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Backup Contents")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        BackupItemRow(title: "Notes", count: notesManager.notes.count)
                        BackupItemRow(title: "Recordings", count: notesManager.notes.filter { $0.audioURL != nil }.count)
                        BackupItemRow(title: "Settings", count: 1)
                    }
                }
                
                Spacer()
                
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button("Create Backup") {
                        createBackup()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isBackingUp)
                }
            }
            .padding()
            .frame(width: 400, height: 400)
            .navigationTitle("Backup")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func createBackup() {
        isBackingUp = true
        
        Task {
            // Simulate backup process
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            await MainActor.run {
                isBackingUp = false
                dismiss()
            }
        }
    }
}

struct BackupItemRow: View {
    let title: String
    let count: Int
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
            
            Spacer()
            
            Text("\(count)")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Supporting Types
enum FileFolder: String, CaseIterable {
    case recordings = "Recordings"
    case exports = "Exports"
    case backups = "Backups"
    case trash = "Trash"
    
    var title: String {
        return rawValue
    }
    
    var description: String {
        switch self {
        case .recordings:
            return "Audio recordings and transcriptions"
        case .exports:
            return "Exported notes and files"
        case .backups:
            return "Backup files and archives"
        case .trash:
            return "Deleted files"
        }
    }
    
    var icon: String {
        switch self {
        case .recordings:
            return "waveform"
        case .exports:
            return "square.and.arrow.up"
        case .backups:
            return "externaldrive"
        case .trash:
            return "trash"
        }
    }
    
    var count: Int? {
        switch self {
        case .recordings:
            return NotesManager().notes.filter { $0.audioURL != nil }.count
        case .exports:
            return 0
        case .backups:
            return 0
        case .trash:
            return 0
        }
    }
}

enum BackupLocation: String, CaseIterable {
    case documents = "Documents"
    case downloads = "Downloads"
    case desktop = "Desktop"
    case custom = "Custom"
    
    var icon: String {
        switch self {
        case .documents:
            return "doc.on.doc"
        case .downloads:
            return "arrow.down.circle"
        case .desktop:
            return "display"
        case .custom:
            return "folder.badge.gearshape"
        }
    }
}

#Preview {
    FilesView()
        .environmentObject(NotesManager())
        .environmentObject(SettingsManager())
}
