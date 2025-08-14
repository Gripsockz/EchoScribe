import Foundation
import SwiftUI

// MARK: - Recording Model
struct Recording: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var duration: TimeInterval
    var fileSize: Int64
    var quality: RecordingQuality
    var transcription: String
    var notes: String
    var tags: [String]
    var summary: String
    var keywords: [String]
    var createdAt: Date
    var updatedAt: Date
    var audioURL: URL?
    var transcriptionSegments: [TranscriptionSegment]
    
    enum RecordingQuality: String, CaseIterable, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case lossless = "Lossless"
    }
    
    init(title: String = "", description: String = "", duration: TimeInterval = 0, fileSize: Int64 = 0, quality: RecordingQuality = .high) {
        self.title = title
        self.description = description
        self.duration = duration
        self.fileSize = fileSize
        self.quality = quality
        self.transcription = ""
        self.notes = ""
        self.tags = []
        self.summary = ""
        self.keywords = []
        self.createdAt = Date()
        self.updatedAt = Date()
        self.audioURL = nil
        self.transcriptionSegments = []
    }
}