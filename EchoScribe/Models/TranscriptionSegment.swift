import Foundation

// MARK: - Transcription Segment Model
struct TranscriptionSegment: Identifiable, Codable {
    let id = UUID()
    let text: String
    let confidence: Float
    let startTime: TimeInterval
    let endTime: TimeInterval
    let speaker: String?
    let language: String
    
    init(text: String, confidence: Float, startTime: TimeInterval, endTime: TimeInterval, speaker: String? = nil, language: String = "en-US") {
        self.text = text
        self.confidence = confidence
        self.startTime = startTime
        self.endTime = endTime
        self.speaker = speaker
        self.language = language
    }
}