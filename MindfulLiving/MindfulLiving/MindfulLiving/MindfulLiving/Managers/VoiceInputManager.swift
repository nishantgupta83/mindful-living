import Foundation
import Speech
import AVFoundation

/// VoiceInputManager: Device-based speech-to-text using SFSpeechRecognizer
/// - No API calls: Uses native iOS speech recognition framework
/// - Real-time transcription: Provides partial and final results
/// - Automatic timeout: 60-second max listening duration
/// - Memory safe: Uses weak self in closures and proper cleanup
///
/// Published properties thread-safe via @MainActor annotation.
@MainActor
final class VoiceInputManager: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
  /// Current listening state
  @Published var isListening = false
  /// Latest recognized text from speech input
  @Published var recognizedText = ""
  /// Error message if speech recognition fails
  @Published var errorMessage: String?
  /// Whether microphone permissions are granted
  @Published var isMicrophoneAvailable = false

  /// Shared singleton instance
  static let shared = VoiceInputManager()

  /// Speech recognizer (optional - may be nil if framework unavailable)
  private let speechRecognizer: SFSpeechRecognizer?
  /// Current speech recognition request
  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  /// Active speech recognition task
  private var recognitionTask: SFSpeechRecognitionTask?
  /// Audio engine for capturing microphone input
  private let audioEngine = AVAudioEngine()
  /// Timer to enforce 60-second max listening duration
  private var listeningTimer: Timer?

  override init() {
    self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    super.init()
    setupSpeechRecognition()
  }

  // MARK: - Setup
  private func setupSpeechRecognition() {
    speechRecognizer?.delegate = self

    AVAudioApplication.requestRecordPermission { [weak self] granted in
      Task { @MainActor in
        self?.isMicrophoneAvailable = granted
      }
    }

    SFSpeechRecognizer.requestAuthorization { [weak self] authorizationStatus in
      Task { @MainActor in
        self?.isMicrophoneAvailable = authorizationStatus == .authorized
      }
    }
  }

  // MARK: - Voice Recording
  func startListening() {
    guard !isListening else { return }
    guard isMicrophoneAvailable else {
      errorMessage = "Microphone permission not granted"
      return
    }

    // Cancel previous task if exists
    if let recognitionTask = recognitionTask {
      recognitionTask.cancel()
      self.recognitionTask = nil
    }

    // Clear any existing timer
    listeningTimer?.invalidate()
    listeningTimer = nil

    do {
      // Create audio session
      let audioSession = AVAudioSession.sharedInstance()
      try audioSession.setCategory(.record, mode: .default, options: .duckOthers)
      try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

      // Create recognition request
      recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
      guard let recognitionRequest = recognitionRequest else {
        errorMessage = "Unable to create recognition request"
        return
      }

      recognitionRequest.shouldReportPartialResults = true

      // Start audio engine
      let inputNode = audioEngine.inputNode
      let recordingFormat = inputNode.outputFormat(forBus: 0)

      // Use weak self in closure to prevent memory leak
      inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
        self?.recognitionRequest?.append(buffer)
      }

      audioEngine.prepare()
      try audioEngine.start()

      // Start recognition task with optional speechRecognizer
      guard let speechRecognizer = speechRecognizer else {
        errorMessage = "Speech recognition unavailable"
        stopListening()
        return
      }

      recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
        DispatchQueue.main.async {
          if let result = result {
            self?.recognizedText = result.bestTranscription.formattedString
          }

          if error != nil || (result?.isFinal ?? false) {
            self?.stopListening()
          }
        }
      }

      // Set 60-second timeout
      listeningTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: false) { [weak self] _ in
        self?.stopListening()
      }

      isListening = true
      errorMessage = nil
    } catch {
      errorMessage = "Failed to start recording: \(error.localizedDescription)"
    }
  }

  func stopListening() {
    guard isListening else { return }

    // Cancel listening timer
    listeningTimer?.invalidate()
    listeningTimer = nil

    // Stop audio engine
    audioEngine.stop()
    audioEngine.inputNode.removeTap(onBus: 0)

    // End recognition
    recognitionRequest?.endAudio()
    recognitionTask?.cancel()
    recognitionTask = nil
    recognitionRequest = nil

    // Clean up audio session
    do {
      let audioSession = AVAudioSession.sharedInstance()
      try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
    } catch {
      errorMessage = "Failed to deactivate audio session: \(error.localizedDescription)"
    }

    isListening = false
  }

  func clearText() {
    recognizedText = ""
    errorMessage = nil
  }

  // MARK: - SFSpeechRecognizerDelegate
  nonisolated func speechRecognizer(
    _ speechRecognizer: SFSpeechRecognizer,
    availabilityDidChange available: Bool
  ) {
    Task { @MainActor in
      self.isMicrophoneAvailable = available
    }
  }
}
