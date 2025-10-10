import SwiftUI
import Speech
import WatchConnectivity
import Combine

struct VoiceGuidance {
    let id: String
    let title: String
    let spokenResponse: String
    let shortSummary: String
    let actionSteps: [String]
    let confidence: Double
    let timestamp: Date
    let lifeArea: String
}

class VoiceQueryManager: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    @Published var isProcessing = false
    @Published var lastGuidance: VoiceGuidance?
    @Published var todaysWellnessScore: Int?
    @Published var error: Error?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var watchConnectivitySession: WCSession?
    
    // API endpoint for voice queries
    private let voiceApiUrl = "https://us-central1-hub4apps-mindfulliving.cloudfunctions.net/processVoiceQuery"
    
    override init() {
        super.init()
        setupSpeechRecognition()
        setupWatchConnectivity()
        loadCachedData()
    }
    
    // MARK: - Setup Methods
    
    private func setupSpeechRecognition() {
        speechRecognizer?.delegate = self
        
        // Request speech recognition permission
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized")
                case .denied:
                    self.error = VoiceError.speechRecognitionDenied
                case .restricted:
                    self.error = VoiceError.speechRecognitionRestricted
                case .notDetermined:
                    self.error = VoiceError.speechRecognitionNotDetermined
                @unknown default:
                    self.error = VoiceError.speechRecognitionUnknown
                }
            }
        }
    }
    
    private func setupWatchConnectivity() {
        if WCSession.isSupported() {
            watchConnectivitySession = WCSession.default
            watchConnectivitySession?.delegate = self
            watchConnectivitySession?.activate()
        }
    }
    
    private func loadCachedData() {
        // Load last guidance from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "lastGuidance"),
           let guidance = try? JSONDecoder().decode(VoiceGuidanceCodable.self, from: data) {
            lastGuidance = guidance.toVoiceGuidance()
        }
        
        // Load today's wellness score
        let today = Calendar.current.startOfDay(for: Date())
        if let scoreDate = UserDefaults.standard.object(forKey: "wellnessScoreDate") as? Date,
           Calendar.current.isDate(scoreDate, inSameDayAs: today),
           UserDefaults.standard.object(forKey: "wellnessScore") != nil {
            todaysWellnessScore = UserDefaults.standard.integer(forKey: "wellnessScore")
        }
    }
    
    // MARK: - Voice Recognition Methods
    
    func startVoiceQuery(completion: @escaping (Bool) -> Void) {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            error = VoiceError.speechRecognitionUnavailable
            completion(false)
            return
        }
        
        isProcessing = true
        
        // Cancel any ongoing recognition
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            error = VoiceError.recognitionRequestFailed
            isProcessing = false
            completion(false)
            return
        }
        
        recognitionRequest.shouldReportPartialResults = false
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            self.error = error
            isProcessing = false
            completion(false)
            return
        }
        
        // Start recognition
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.handleVoiceRecognitionError(error)
                completion(false)
                return
            }
            
            if let result = result, result.isFinal {
                let spokenText = result.bestTranscription.formattedString
                self.processVoiceQuery(spokenText, completion: completion)
            }
        }
        
        // Start audio engine
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        do {
            audioEngine.prepare()
            try audioEngine.start()
            
            // Stop listening after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.stopVoiceRecognition()
            }
            
        } catch {
            self.error = error
            isProcessing = false
            completion(false)
        }
    }
    
    private func stopVoiceRecognition() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
    }
    
    private func handleVoiceRecognitionError(_ error: Error) {
        DispatchQueue.main.async {
            self.error = error
            self.isProcessing = false
        }
        stopVoiceRecognition()
    }
    
    // MARK: - API Communication
    
    private func processVoiceQuery(_ query: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: voiceApiUrl) else {
            error = VoiceError.invalidApiUrl
            isProcessing = false
            completion(false)
            return
        }
        
        let requestBody: [String: Any] = [
            "query": query,
            "source": "appleWatch",
            "userId": getCurrentUserId(),
            "context": [
                "deviceType": "appleWatch",
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            self.error = error
            isProcessing = false
            completion(false)
            return
        }
        
        // Make API request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.isProcessing = false
                self.stopVoiceRecognition()
                
                if let error = error {
                    self.error = error
                    completion(false)
                    return
                }
                
                guard let data = data else {
                    self.error = VoiceError.noResponseData
                    completion(false)
                    return
                }
                
                self.handleApiResponse(data, completion: completion)
            }
        }.resume()
    }
    
    private func handleApiResponse(_ data: Data, completion: @escaping (Bool) -> Void) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let guidance = parseVoiceGuidance(from: json)
                
                if let guidance = guidance {
                    self.lastGuidance = guidance
                    self.cacheGuidance(guidance)
                    
                    // Provide haptic feedback
                    WKInterfaceDevice.current().play(.success)
                    
                    completion(true)
                } else {
                    self.error = VoiceError.noGuidanceFound
                    completion(false)
                }
            } else {
                self.error = VoiceError.invalidResponseFormat
                completion(false)
            }
        } catch {
            self.error = error
            completion(false)
        }
    }
    
    private func parseVoiceGuidance(from json: [String: Any]) -> VoiceGuidance? {
        guard let spokenResponse = json["speech"] as? String,
              let situationData = json["additionalData"] as? [String: Any],
              let situationId = json["situationId"] as? String else {
            return nil
        }
        
        let title = situationData["cardTitle"] as? String ?? "Mindful Guidance"
        let lifeArea = situationData["lifeArea"] as? String ?? "General"
        let confidence = json["confidence"] as? Double ?? 0.0
        
        // Parse action steps from spoken response
        let actionSteps = parseActionSteps(from: spokenResponse)
        let shortSummary = createShortSummary(from: spokenResponse)
        
        return VoiceGuidance(
            id: situationId,
            title: title,
            spokenResponse: spokenResponse,
            shortSummary: shortSummary,
            actionSteps: actionSteps,
            confidence: confidence,
            timestamp: Date(),
            lifeArea: lifeArea
        )
    }
    
    private func parseActionSteps(from response: String) -> [String] {
        // Extract numbered or structured steps from the response
        let sentences = response.components(separatedBy: ". ")
        return sentences.compactMap { sentence in
            let trimmed = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }.prefix(3).map { String($0) }
    }
    
    private func createShortSummary(from response: String) -> String {
        let words = response.components(separatedBy: " ")
        let summary = words.prefix(10).joined(separator: " ")
        return summary + (words.count > 10 ? "..." : "")
    }
    
    // MARK: - Utility Methods
    
    private func getCurrentUserId() -> String {
        // In a real implementation, this would get the user ID from your auth system
        return UserDefaults.standard.string(forKey: "userId") ?? "anonymous_watch_user"
    }
    
    private func cacheGuidance(_ guidance: VoiceGuidance) {
        let codableGuidance = VoiceGuidanceCodable(guidance: guidance)
        if let data = try? JSONEncoder().encode(codableGuidance) {
            UserDefaults.standard.set(data, forKey: "lastGuidance")
        }
    }
    
    // MARK: - SFSpeechRecognizerDelegate
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if !available {
            error = VoiceError.speechRecognitionUnavailable
        }
    }
}

// MARK: - WCSessionDelegate

extension VoiceQueryManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Watch connectivity activation error: \(error)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle messages from iPhone app
        if let wellnessScore = message["wellnessScore"] as? Int {
            DispatchQueue.main.async {
                self.todaysWellnessScore = wellnessScore
                UserDefaults.standard.set(wellnessScore, forKey: "wellnessScore")
                UserDefaults.standard.set(Date(), forKey: "wellnessScoreDate")
            }
        }
    }
}

// MARK: - Supporting Types

enum VoiceError: LocalizedError {
    case speechRecognitionDenied
    case speechRecognitionRestricted
    case speechRecognitionNotDetermined
    case speechRecognitionUnknown
    case speechRecognitionUnavailable
    case recognitionRequestFailed
    case invalidApiUrl
    case noResponseData
    case invalidResponseFormat
    case noGuidanceFound
    
    var errorDescription: String? {
        switch self {
        case .speechRecognitionDenied:
            return "Speech recognition access denied. Enable in Settings."
        case .speechRecognitionRestricted:
            return "Speech recognition is restricted on this device."
        case .speechRecognitionNotDetermined:
            return "Speech recognition permission not determined."
        case .speechRecognitionUnknown:
            return "Unknown speech recognition error."
        case .speechRecognitionUnavailable:
            return "Speech recognition is not available right now."
        case .recognitionRequestFailed:
            return "Failed to create speech recognition request."
        case .invalidApiUrl:
            return "Invalid API URL configuration."
        case .noResponseData:
            return "No response data received."
        case .invalidResponseFormat:
            return "Invalid response format from server."
        case .noGuidanceFound:
            return "No guidance found for your query."
        }
    }
}

struct VoiceGuidanceCodable: Codable {
    let id: String
    let title: String
    let spokenResponse: String
    let shortSummary: String
    let actionSteps: [String]
    let confidence: Double
    let timestamp: Date
    let lifeArea: String
    
    init(guidance: VoiceGuidance) {
        self.id = guidance.id
        self.title = guidance.title
        self.spokenResponse = guidance.spokenResponse
        self.shortSummary = guidance.shortSummary
        self.actionSteps = guidance.actionSteps
        self.confidence = guidance.confidence
        self.timestamp = guidance.timestamp
        self.lifeArea = guidance.lifeArea
    }
    
    func toVoiceGuidance() -> VoiceGuidance {
        return VoiceGuidance(
            id: id,
            title: title,
            spokenResponse: spokenResponse,
            shortSummary: shortSummary,
            actionSteps: actionSteps,
            confidence: confidence,
            timestamp: timestamp,
            lifeArea: lifeArea
        )
    }
}