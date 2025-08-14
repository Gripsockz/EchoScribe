import Foundation
import SwiftUI

// MARK: - Notes Manager
class NotesManager: ObservableObject {
    @Published var recordings: [Recording] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        loadRecordings()
    }
    
    func loadRecordings() {
        // Load recordings from persistent storage
        isLoading = true
        // Implementation would load from CoreData or file system
        isLoading = false
    }
    
    func saveRecording(_ recording: Recording) async {
        await MainActor.run {
            if let index = recordings.firstIndex(where: { $0.id == recording.id }) {
                recordings[index] = recording
            } else {
                recordings.append(recording)
            }
        }
        // Save to persistent storage
    }
    
    func deleteRecording(_ recording: Recording) {
        recordings.removeAll { $0.id == recording.id }
        // Delete from persistent storage
    }
}