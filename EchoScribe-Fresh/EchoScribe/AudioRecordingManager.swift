import Foundation
import AVFoundation
import ScreenCaptureKit
import Speech
import SwiftUI
import Combine

@MainActor
class AudioRecordingManager: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var isRecording = false
    @Published var isPaused = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var audioLevel: Float = 0.0
    @Published var currentTranscription = ""
    @Published var recordingMode: RecordingMode = .microphone
    @Published var permissionStatus: PermissionStatus = .unknown
    @Published var recordingQuality: RecordingQuality = .high
    @Published var errorMessage: String?
    @Published var isProcessing = false
    @Published var systemAudioAvailable = false
    
    // MARK: - Private Properties
    private var audioRecorder: AVAudioRecorder?
    private var audioEngine = AVAudioEngine()
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioLevelTimer: Timer?
    private var durationTimer: Timer?
    private var transcriptionChunks: [String] = []
    private var currentRecordingURL: URL?
    private var cancellables = Set<AnyCancellable>()
    
    // System Audio Capture
    private var screenCaptureSession: SCStream?
    private var systemAudioMixer: AVAudioMixerNode?
    
    // MARK: - Enums
    enum RecordingMode: String, CaseIterable {
        case microphone = "Microphone"
        case systemAudio = "System Audio"
        case both = "Both"
        
        var icon: String {
            switch self {
            case .microphone: return "mic.fill"
            case .systemAudio: return "speaker.wave.3.fill"
            case .both: return "mic.and.signal.meter.fill"
            }
        }
        
        var description: String {
            switch self {
            case .microphone: return "Record from microphone only"
            case .systemAudio: return "Record system audio only"
            case .both: return "Record both microphone and system audio"
            }
        }
    }
    
    enum RecordingQuality: String, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case lossless = "Lossless"
        
        var bitrate: Int {
            switch self {
            case .low: return 64000
            case .medium: return 128000
            case .high: return 256000
            case .lossless: return 1411000
            }
        }
        
        var sampleRate: Double {
            switch self {
            case .low: return 22050
            case .medium: return 44100
            case .high: return 48000
            case .lossless: return 96000
            }
        }
        
        var description: String {
            switch self {
            case .low: return "64 kbps - Good for voice notes"
            case .medium: return "128 kbps - Balanced quality"
            case .high: return "256 kbps - High quality audio"
            case .lossless: return "Lossless - Maximum quality"
            }
        }
    }
    
    enum PermissionStatus {
        case unknown, granted, denied, restricted
    }
    
    enum RecordingError: LocalizedError {
        case permissionDenied
        case audioEngineFailed
        case recordingFailed
        case transcriptionFailed
        case systemAudioNotSupported
        case screenCaptureFailed
        
        var errorDescription: String? {
            switch self {
            case .permissionDenied:
                return "Microphone access is required to record audio"
            case .audioEngineFailed:
                return "Failed to initialize audio recording"
            case .recordingFailed:
                return "Failed to start recording"
            case .transcriptionFailed:
                return "Failed to start transcription"
            case .systemAudioNotSupported:
                return "System audio recording is not supported on this device"
            case .screenCaptureFailed:
                return "Failed to start screen capture for system audio"
            }
        }
    }
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupSpeechRecognition()
        checkPermissions()
        setupAudioSession()
        checkSystemAudioAvailability()
    }
    
    // MARK: - Setup Methods
    private func setupAudioSession() {
        // AVAudioSession is not available on macOS
        // macOS handles audio routing automatically
        print("Audio session setup completed (macOS)")
    }
    
    private func setupSpeechRecognition() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            Task { @MainActor in
                switch status {
                case .authorized:
                    self?.permissionStatus = .granted
                case .denied:
                    self?.permissionStatus = .denied
                case .restricted:
                    self?.permissionStatus = .restricted
                case .notDetermined:
                    self?.permissionStatus = .unknown
                @unknown default:
                    self?.permissionStatus = .unknown
                }
            }
        }
    }
    
    private func checkPermissions() {
        // On macOS, we'll assume permission is granted for now
        // In a real app, you'd check microphone permission using AVCaptureDevice
        permissionStatus = .granted
    }
    
    private func checkSystemAudioAvailability() {
        Task {
            do {
                let availableContent = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
                systemAudioAvailable = !availableContent.displays.isEmpty
            } catch {
                systemAudioAvailable = false
                print("System audio not available: \(error)")
            }
        }
    }
    
    // MARK: - Public Methods
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    func togglePause() {
        if isPaused {
            resumeRecording()
        } else {
            pauseRecording()
        }
    }
    
    func startRecording() {
        guard permissionStatus == .granted else {
            errorMessage = RecordingError.permissionDenied.errorDescription
            return
        }
        
        do {
            let recordingURL = createRecordingURL()
            currentRecordingURL = recordingURL
            
            let settings = getRecordingSettings()
            audioRecorder = try AVAudioRecorder(url: recordingURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            isRecording = true
            isPaused = false
            recordingDuration = 0
            currentTranscription = ""
            transcriptionChunks = []
            errorMessage = nil
            
            startTimers()
            
            // Start appropriate recording based on mode
            switch recordingMode {
            case .microphone:
                startMicrophoneRecording()
            case .systemAudio:
                startSystemAudioRecording()
            case .both:
                startBothRecording()
            }
            
        } catch {
            errorMessage = RecordingError.recordingFailed.errorDescription
            print("Could not start recording: \(error)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        
        isRecording = false
        isPaused = false
        
        stopTimers()
        stopSpeechRecognition()
        stopSystemAudioCapture()
        
        // Process the recording
        processRecording()
    }
    
    private func pauseRecording() {
        audioRecorder?.pause()
        isPaused = true
        stopTimers()
        stopSpeechRecognition()
        stopSystemAudioCapture()
    }
    
    private func resumeRecording() {
        audioRecorder?.record()
        isPaused = false
        startTimers()
        
        switch recordingMode {
        case .microphone:
            startMicrophoneRecording()
        case .systemAudio:
            startSystemAudioRecording()
        case .both:
            startBothRecording()
        }
    }
    
    // MARK: - Recording Methods
    private func startMicrophoneRecording() {
        startSpeechRecognition()
    }
    
    private func startSystemAudioRecording() {
        guard systemAudioAvailable else {
            errorMessage = RecordingError.systemAudioNotSupported.errorDescription
            return
        }
        
        Task {
            do {
                try await startScreenCapture()
            } catch {
                errorMessage = RecordingError.screenCaptureFailed.errorDescription
                print("Failed to start screen capture: \(error)")
            }
        }
    }
    
    private func startBothRecording() {
        startMicrophoneRecording()
        startSystemAudioRecording()
    }
    
    private func startScreenCapture() async throws {
        let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        
        let filter = SCContentFilter(display: content.displays.first!, excludingWindows: [])
        let configuration = SCStreamConfiguration()
        configuration.capturesAudio = true
        configuration.sampleRate = Int(recordingQuality.sampleRate)
        configuration.channelCount = 1
        
        screenCaptureSession = SCStream(filter: filter, configuration: configuration, delegate: self)
        try await screenCaptureSession?.addStreamOutput(self, type: .audio, sampleHandlerQueue: .main)
        try await screenCaptureSession?.startCapture()
    }
    
    private func stopSystemAudioCapture() {
        Task {
            do {
                try await screenCaptureSession?.stopCapture()
            } catch {
                print("Error stopping screen capture: \(error)")
            }
            screenCaptureSession = nil
        }
    }
    
    // MARK: - Private Methods
    private func createRecordingURL() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let echoScribePath = documentsPath.appendingPathComponent("EchoScribe")
        let recordingsPath = echoScribePath.appendingPathComponent("Recordings")
        
        // Create directories if they don't exist
        try? FileManager.default.createDirectory(at: recordingsPath, withIntermediateDirectories: true)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        
        return recordingsPath.appendingPathComponent("recording_\(timestamp).m4a")
    }
    
    private func getRecordingSettings() -> [String: Any] {
        return [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: Int(recordingQuality.sampleRate),
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey: recordingQuality.bitrate
        ]
    }
    
    private func startTimers() {
        // Audio level timer
        audioLevelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateAudioLevel()
            }
        }
        
        // Duration timer
        durationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.recordingDuration += 1.0
            }
        }
    }
    
    private func stopTimers() {
        audioLevelTimer?.invalidate()
        audioLevelTimer = nil
        durationTimer?.invalidate()
        durationTimer = nil
        audioLevel = 0.0
    }
    
    private func updateAudioLevel() {
        guard let recorder = audioRecorder else { return }
        recorder.updateMeters()
        audioLevel = recorder.averagePower(forChannel: 0)
    }
    
    private func startSpeechRecognition() {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = RecordingError.transcriptionFailed.errorDescription
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor in
                guard let self = self else { return }
                
                if let result = result {
                    self.currentTranscription = result.bestTranscription.formattedString
                    if result.isFinal {
                        self.transcriptionChunks.append(result.bestTranscription.formattedString)
                    }
                }
                
                if error != nil {
                    self.stopSpeechRecognition()
                }
            }
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            errorMessage = RecordingError.audioEngineFailed.errorDescription
            print("Audio engine could not start: \(error)")
        }
    }
    
    private func stopSpeechRecognition() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
    }
    
    private func processRecording() {
        isProcessing = true
        
        // Generate final transcription
        let finalTranscription = transcriptionChunks.joined(separator: " ")
        
        // Save to notes manager (will be handled by the main app)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isProcessing = false
        }
    }
    
    // MARK: - Public Getters
    var liveTranscription: String {
        get { currentTranscription }
        set { currentTranscription = newValue }
    }
    
    var transcriptionChunksArray: [String] {
        get { transcriptionChunks }
        set { transcriptionChunks = newValue }
    }
    
    var currentRecordingFileURL: URL? {
        return currentRecordingURL
    }
}

// MARK: - AVAudioRecorderDelegate
extension AudioRecordingManager: AVAudioRecorderDelegate {
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Task { @MainActor in
            if flag {
                print("Recording finished successfully")
            } else {
                errorMessage = "Recording failed to complete"
                print("Recording failed")
            }
        }
    }
    
    nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        Task { @MainActor in
            if let error = error {
                errorMessage = "Recording error: \(error.localizedDescription)"
                print("Recording encode error: \(error)")
            }
        }
    }
}

// MARK: - SCStreamDelegate
extension AudioRecordingManager: SCStreamDelegate {
    nonisolated func stream(_ stream: SCStream, didStopWithError error: Error) {
        print("Screen capture stream stopped with error: \(error)")
    }
}

// MARK: - SCStreamOutput
extension AudioRecordingManager: SCStreamOutput {
    nonisolated func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .audio else { return }
        
        // Process system audio here
        // This would be integrated with the audio engine for mixing
    }
}
