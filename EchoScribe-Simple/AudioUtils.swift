import Foundation
import AVFoundation

struct AudioUtils {
    
    // MARK: - Duration Formatting
    static func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    static func formatDurationShort(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - File Size Formatting
    static func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    // MARK: - Audio Quality Settings
    static func getAudioSettings(for quality: AudioRecordingManager.RecordingQuality) -> [String: Any] {
        return [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: quality.sampleRate,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: getAudioQuality(for: quality),
            AVEncoderBitRateKey: quality.bitrate
        ]
    }
    
    private static func getAudioQuality(for quality: AudioRecordingManager.RecordingQuality) -> Int {
        switch quality {
        case .low:
            return Int(AVAudioQuality.low.rawValue)
        case .medium:
            return Int(AVAudioQuality.medium.rawValue)
        case .high:
            return Int(AVAudioQuality.high.rawValue)
        case .lossless:
            return Int(AVAudioQuality.max.rawValue)
        }
    }
    
    // MARK: - File Management
    static func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    static func getRecordingsDirectory() -> URL {
        let recordingsDir = getDocumentsDirectory().appendingPathComponent("Recordings")
        createDirectoryIfNeeded(at: recordingsDir)
        return recordingsDir
    }
    
    static func getExportsDirectory() -> URL {
        let exportsDir = getDocumentsDirectory().appendingPathComponent("Exports")
        createDirectoryIfNeeded(at: exportsDir)
        return exportsDir
    }
    
    static func getBackupsDirectory() -> URL {
        let backupsDir = getDocumentsDirectory().appendingPathComponent("Backups")
        createDirectoryIfNeeded(at: backupsDir)
        return backupsDir
    }
    
    private static func createDirectoryIfNeeded(at url: URL) {
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - File Operations
    static func generateFileName(with prefix: String = "Recording") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        return "\(prefix)_\(timestamp).m4a"
    }
    
    static func getFileSize(at url: URL) -> Int64 {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64 ?? 0
        } catch {
            return 0
        }
    }
    
    static func deleteFile(at url: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            print("Error deleting file: \(error)")
            return false
        }
    }
    
    // MARK: - Audio Level Processing
    static func processAudioLevel(_ buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData?[0] else { return 0.0 }
        
        let frameLength = UInt(buffer.frameLength)
        var sum: Float = 0.0
        
        for i in 0..<Int(frameLength) {
            let sample = channelData[i]
            sum += sample * sample
        }
        
        let rms = sqrt(sum / Float(frameLength))
        let db = 20 * log10(rms)
        
        // Normalize to 0-1 range
        let normalized = max(0.0, min(1.0, (db + 60) / 60))
        return normalized
    }
    
    // MARK: - Validation
    static func isValidAudioFile(at url: URL) -> Bool {
        let audioExtensions = ["m4a", "mp3", "wav", "aac", "flac"]
        let fileExtension = url.pathExtension.lowercased()
        return audioExtensions.contains(fileExtension)
    }
    
    static func getAudioDuration(at url: URL) -> TimeInterval {
        let asset = AVAsset(url: url)
        return CMTimeGetSeconds(asset.duration)
    }
}
