import Foundation
import AVFoundation
import SwiftUI
import Accelerate

// MARK: - Audio Effect Models
struct AudioEffect: Identifiable, Equatable {
    let id = UUID()
    let type: EffectType
    var intensity: Float // 0.0 to 1.0
    var isEnabled: Bool = true
    
    enum EffectType: String, CaseIterable {
        case noiseReduction = "Noise Reduction"
        case echoCancellation = "Echo Cancellation"
        case normalization = "Normalization"
        case compression = "Compression"
        case equalizer = "Equalizer"
        case reverb = "Reverb"
        
        var icon: String {
            switch self {
            case .noiseReduction: return "waveform.path.ecg"
            case .echoCancellation: return "speaker.wave.2"
            case .normalization: return "waveform.path"
            case .compression: return "waveform"
            case .equalizer: return "slider.horizontal.3"
            case .reverb: return "speaker.wave.3"
            }
        }
        
        var description: String {
            switch self {
            case .noiseReduction: return "Remove background noise and static"
            case .echoCancellation: return "Eliminate echo and feedback"
            case .normalization: return "Balance audio levels automatically"
            case .compression: return "Reduce dynamic range for consistency"
            case .equalizer: return "Adjust frequency response"
            case .reverb: return "Add spatial depth and ambience"
            }
        }
    }
}

// MARK: - Audio Effects Manager
class AudioEffectsManager: ObservableObject {
    @Published var activeEffects: [AudioEffect] = []
    @Published var isProcessing = false
    @Published var processingProgress: Double = 0.0
    
    private var audioEngine: AVAudioEngine?
    private var audioPlayerNode: AVAudioPlayerNode?
    private var audioFile: AVAudioFile?
    
    // MARK: - Effect Processing
    func applyEffects(to audioBuffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer? {
        guard !activeEffects.isEmpty else { return audioBuffer }
        
        isProcessing = true
        processingProgress = 0.0
        
        var processedBuffer = audioBuffer
        
        for (index, effect) in activeEffects.enumerated() {
            guard effect.isEnabled else { continue }
            
            switch effect.type {
            case .noiseReduction:
                processedBuffer = applyNoiseReduction(to: processedBuffer, intensity: effect.intensity)
            case .echoCancellation:
                processedBuffer = applyEchoCancellation(to: processedBuffer, intensity: effect.intensity)
            case .normalization:
                processedBuffer = applyNormalization(to: processedBuffer, intensity: effect.intensity)
            case .compression:
                processedBuffer = applyCompression(to: processedBuffer, intensity: effect.intensity)
            case .equalizer:
                processedBuffer = applyEqualizer(to: processedBuffer, intensity: effect.intensity)
            case .reverb:
                processedBuffer = applyReverb(to: processedBuffer, intensity: effect.intensity)
            }
            
            processingProgress = Double(index + 1) / Double(activeEffects.count)
        }
        
        isProcessing = false
        return processedBuffer
    }
    
    // MARK: - Individual Effect Implementations
    private func applyNoiseReduction(to buffer: AVAudioPCMBuffer, intensity: Float) -> AVAudioPCMBuffer {
        guard let channelData = buffer.floatChannelData?[0] else { return buffer }
        let frameLength = Int(buffer.frameLength)
        
        // Simple noise gate implementation
        let threshold = 0.1 * intensity
        let samples = Array(UnsafeBufferPointer(start: channelData, count: frameLength))
        
        let processedSamples = samples.map { sample in
            abs(sample) < threshold ? 0.0 : sample
        }
        
        // Copy processed samples back to buffer
        for i in 0..<frameLength {
            channelData[i] = Float(processedSamples[i])
        }
        
        return buffer
    }
    
    private func applyEchoCancellation(to buffer: AVAudioPCMBuffer, intensity: Float) -> AVAudioPCMBuffer {
        guard let channelData = buffer.floatChannelData?[0] else { return buffer }
        let frameLength = Int(buffer.frameLength)
        
        // Simple echo cancellation using adaptive filtering
        let delaySamples = Int(0.1 * 44100) // 100ms delay
        let samples = Array(UnsafeBufferPointer(start: channelData, count: frameLength))
        var processedSamples = samples
        
        for i in delaySamples..<frameLength {
            let echoComponent = samples[i - delaySamples] * intensity * 0.3
            processedSamples[i] -= echoComponent
        }
        
        // Copy processed samples back to buffer
        for i in 0..<frameLength {
            channelData[i] = Float(processedSamples[i])
        }
        
        return buffer
    }
    
    private func applyNormalization(to buffer: AVAudioPCMBuffer, intensity: Float) -> AVAudioPCMBuffer {
        guard let channelData = buffer.floatChannelData?[0] else { return buffer }
        let frameLength = Int(buffer.frameLength)
        
        let samples = Array(UnsafeBufferPointer(start: channelData, count: frameLength))
        let maxAmplitude = samples.map { abs($0) }.max() ?? 1.0
        
        if maxAmplitude > 0 {
            let scaleFactor = (0.8 * intensity) / maxAmplitude
            let processedSamples = samples.map { $0 * scaleFactor }
            
            // Copy processed samples back to buffer
            for i in 0..<frameLength {
                channelData[i] = Float(processedSamples[i])
            }
        }
        
        return buffer
    }
    
    private func applyCompression(to buffer: AVAudioPCMBuffer, intensity: Float) -> AVAudioPCMBuffer {
        guard let channelData = buffer.floatChannelData?[0] else { return buffer }
        let frameLength = Int(buffer.frameLength)
        
        let threshold = 0.5
        let ratio = 4.0 * intensity
        let samples = Array(UnsafeBufferPointer(start: channelData, count: frameLength))
        
        let processedSamples = samples.map { sample in
            let absSample = abs(sample)
            if absSample > threshold {
                let excess = absSample - threshold
                let compressedExcess = excess / ratio
                return sample > 0 ? threshold + compressedExcess : -(threshold + compressedExcess)
            }
            return sample
        }
        
        // Copy processed samples back to buffer
        for i in 0..<frameLength {
            channelData[i] = Float(processedSamples[i])
        }
        
        return buffer
    }
    
    private func applyEqualizer(to buffer: AVAudioPCMBuffer, intensity: Float) -> AVAudioPCMBuffer {
        guard let channelData = buffer.floatChannelData?[0] else { return buffer }
        let frameLength = Int(buffer.frameLength)
        
        // Simple 3-band equalizer (low, mid, high)
        let samples = Array(UnsafeBufferPointer(start: channelData, count: frameLength))
        let processedSamples = samples.enumerated().map { index, sample in
            let frequency = Float(index) * 44100.0 / Float(frameLength)
            
            if frequency < 1000 { // Low frequencies
                return sample * (1.0 + intensity * 0.5)
            } else if frequency < 8000 { // Mid frequencies
                return sample * (1.0 + intensity * 0.2)
            } else { // High frequencies
                return sample * (1.0 + intensity * 0.3)
            }
        }
        
        // Copy processed samples back to buffer
        for i in 0..<frameLength {
            channelData[i] = Float(processedSamples[i])
        }
        
        return buffer
    }
    
    private func applyReverb(to buffer: AVAudioPCMBuffer, intensity: Float) -> AVAudioPCMBuffer {
        guard let channelData = buffer.floatChannelData?[0] else { return buffer }
        let frameLength = Int(buffer.frameLength)
        
        // Simple reverb using multiple delays
        let samples = Array(UnsafeBufferPointer(start: channelData, count: frameLength))
        var processedSamples = samples
        
        let delays = [100, 150, 200, 250] // ms
        let decay = 0.3 * intensity
        
        for delay in delays {
            let delaySamples = Int(Double(delay) * 44.1) // Convert ms to samples
            for i in delaySamples..<frameLength {
                processedSamples[i] += samples[i - delaySamples] * decay
            }
        }
        
        // Copy processed samples back to buffer
        for i in 0..<frameLength {
            channelData[i] = Float(processedSamples[i])
        }
        
        return buffer
    }
    
    // MARK: - Effect Management
    func addEffect(_ effect: AudioEffect) {
        if !activeEffects.contains(where: { $0.type == effect.type }) {
            activeEffects.append(effect)
        }
    }
    
    func removeEffect(_ effect: AudioEffect) {
        activeEffects.removeAll { $0.id == effect.id }
    }
    
    func updateEffect(_ effect: AudioEffect) {
        if let index = activeEffects.firstIndex(where: { $0.id == effect.id }) {
            activeEffects[index] = effect
        }
    }
    
    func clearAllEffects() {
        activeEffects.removeAll()
    }
}
