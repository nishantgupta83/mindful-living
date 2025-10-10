import Intents
import UIKit

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        if intent is GetLifeAdviceIntent {
            return GetLifeAdviceIntentHandler()
        } else if intent is CheckWellnessIntent {
            return CheckWellnessIntentHandler()
        } else if intent is StartReflectionIntent {
            return StartReflectionIntentHandler()
        }
        
        fatalError("Unhandled intent type: \(intent)")
    }
}

// MARK: - Get Life Advice Intent Handler

class GetLifeAdviceIntentHandler: NSObject, GetLifeAdviceIntentHandling {
    
    func handle(intent: GetLifeAdviceIntent, completion: @escaping (GetLifeAdviceIntentResponse) -> Void) {
        guard let situation = intent.situation, !situation.isEmpty else {
            let response = GetLifeAdviceIntentResponse(code: .failure, userActivity: nil)
            response.spokenResponse = "I need to know what situation you'd like advice about. Try asking about something specific like work stress or relationship issues."
            completion(response)
            return
        }
        
        // Process the voice query using our voice API service
        processVoiceQuery(situation: situation) { result in
            switch result {
            case .success(let guidance):
                let response = GetLifeAdviceIntentResponse(code: .success, userActivity: nil)
                response.spokenResponse = guidance.spokenResponse
                response.situationTitle = guidance.title
                response.confidence = NSNumber(value: guidance.confidence)
                
                // Create user activity for handoff to main app
                let userActivity = NSUserActivity(activityType: "com.hub4apps.mindfulliving.viewGuidance")
                userActivity.title = "View Guidance: \(guidance.title)"
                userActivity.userInfo = [
                    "situationId": guidance.id,
                    "title": guidance.title,
                    "spokenResponse": guidance.spokenResponse
                ]
                response.userActivity = userActivity
                
                completion(response)
                
            case .failure(let error):
                let response = GetLifeAdviceIntentResponse(code: .failure, userActivity: nil)
                response.spokenResponse = self.getErrorResponse(for: error)
                completion(response)
            }
        }
    }
    
    func confirm(intent: GetLifeAdviceIntent, completion: @escaping (GetLifeAdviceIntentResponse) -> Void) {
        let response = GetLifeAdviceIntentResponse(code: .ready, userActivity: nil)
        completion(response)
    }
    
    func resolveSituation(for intent: GetLifeAdviceIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        guard let situation = intent.situation else {
            completion(INStringResolutionResult.needsValue())
            return
        }
        
        if situation.isEmpty {
            completion(INStringResolutionResult.needsValue())
        } else {
            completion(INStringResolutionResult.success(with: situation))
        }
    }
    
    private func processVoiceQuery(situation: String, completion: @escaping (Result<VoiceGuidanceResult, Error>) -> Void) {
        let voiceApiUrl = "https://us-central1-hub4apps-mindfulliving.cloudfunctions.net/processVoiceQuery"
        
        guard let url = URL(string: voiceApiUrl) else {
            completion(.failure(SiriIntentError.invalidApiUrl))
            return
        }
        
        let requestBody: [String: Any] = [
            "query": situation,
            "source": "siri",
            "userId": getCurrentUserId(),
            "context": [
                "deviceType": "siri",
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10.0 // Quick timeout for voice interactions
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(SiriIntentError.noResponseData))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let spokenResponse = json["speech"] as? String,
                   let situationId = json["situationId"] as? String {
                    
                    let additionalData = json["additionalData"] as? [String: Any]
                    let title = additionalData?["cardTitle"] as? String ?? "Mindful Guidance"
                    let confidence = json["confidence"] as? Double ?? 0.0
                    
                    let guidance = VoiceGuidanceResult(
                        id: situationId,
                        title: title,
                        spokenResponse: spokenResponse,
                        confidence: confidence
                    )
                    
                    completion(.success(guidance))
                } else {
                    completion(.failure(SiriIntentError.invalidResponseFormat))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func getCurrentUserId() -> String {
        // Get user ID from keychain or UserDefaults
        return UserDefaults(suiteName: "group.com.hub4apps.mindfulliving")?
            .string(forKey: "userId") ?? "anonymous_siri_user"
    }
    
    private func getErrorResponse(for error: Error) -> String {
        if let siriError = error as? SiriIntentError {
            switch siriError {
            case .noGuidanceFound:
                return "I couldn't find specific guidance for that. Could you try rephrasing your question or asking about common situations like work stress or relationship issues?"
            case .networkError:
                return "I'm having trouble connecting right now. Please try again in a moment."
            default:
                return "I'm having some technical difficulties. Please try again later."
            }
        }
        
        return "I'm sorry, I encountered an error. Please try asking your question again."
    }
}

// MARK: - Check Wellness Intent Handler

class CheckWellnessIntentHandler: NSObject, CheckWellnessIntentHandling {
    
    func handle(intent: CheckWellnessIntent, completion: @escaping (CheckWellnessIntentResponse) -> Void) {
        // Fetch today's wellness score
        fetchWellnessScore { score in
            let response = CheckWellnessIntentResponse(code: .success, userActivity: nil)
            
            if let score = score {
                response.wellnessScore = NSNumber(value: score)
                response.spokenResponse = self.getWellnessResponse(score: score)
            } else {
                response.spokenResponse = "I don't have your wellness data yet. Start using the Mindful Living app to track your daily wellness."
            }
            
            completion(response)
        }
    }
    
    func confirm(intent: CheckWellnessIntent, completion: @escaping (CheckWellnessIntentResponse) -> Void) {
        let response = CheckWellnessIntentResponse(code: .ready, userActivity: nil)
        completion(response)
    }
    
    private func fetchWellnessScore(completion: @escaping (Int?) -> Void) {
        // In a real implementation, this would fetch from your backend
        // For now, check local storage
        let defaults = UserDefaults(suiteName: "group.com.hub4apps.mindfulliving")
        
        if let scoreDate = defaults?.object(forKey: "wellnessScoreDate") as? Date,
           Calendar.current.isDateInToday(scoreDate) {
            let score = defaults?.integer(forKey: "wellnessScore") ?? 0
            completion(score > 0 ? score : nil)
        } else {
            completion(nil)
        }
    }
    
    private func getWellnessResponse(score: Int) -> String {
        switch score {
        case 90...100:
            return "Your wellness score today is \(score) percent. Excellent! You're maintaining great balance."
        case 80...89:
            return "Your wellness score is \(score) percent. You're doing well! Keep up the good habits."
        case 70...79:
            return "Your wellness score today is \(score) percent. Good progress, with room to grow."
        case 60...69:
            return "Your wellness score is \(score) percent. Consider some mindful practices to boost your well-being."
        default:
            return "Your wellness score today is \(score) percent. Let me help you with some guidance to improve your day."
        }
    }
}

// MARK: - Start Reflection Intent Handler

class StartReflectionIntentHandler: NSObject, StartReflectionIntentHandling {
    
    func handle(intent: StartReflectionIntent, completion: @escaping (StartReflectionIntentResponse) -> Void) {
        let response = StartReflectionIntentResponse(code: .success, userActivity: nil)
        
        let reflectionPrompts = [
            "What small step can I take today to improve my well-being?",
            "What am I most grateful for right now?",
            "How can I show more kindness to myself today?",
            "What would bring me peace in this moment?",
            "What positive change can I make in my relationships today?"
        ]
        
        let randomPrompt = reflectionPrompts.randomElement() ?? reflectionPrompts[0]
        response.reflectionPrompt = randomPrompt
        response.spokenResponse = "Here's your reflection prompt: \(randomPrompt). Take a moment to think about this."
        
        // Create user activity for handoff to main app
        let userActivity = NSUserActivity(activityType: "com.hub4apps.mindfulliving.reflection")
        userActivity.title = "Daily Reflection"
        userActivity.userInfo = ["prompt": randomPrompt]
        response.userActivity = userActivity
        
        completion(response)
    }
    
    func confirm(intent: StartReflectionIntent, completion: @escaping (StartReflectionIntentResponse) -> Void) {
        let response = StartReflectionIntentResponse(code: .ready, userActivity: nil)
        completion(response)
    }
}

// MARK: - Supporting Types

struct VoiceGuidanceResult {
    let id: String
    let title: String
    let spokenResponse: String
    let confidence: Double
}

enum SiriIntentError: LocalizedError {
    case invalidApiUrl
    case noResponseData
    case invalidResponseFormat
    case noGuidanceFound
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidApiUrl:
            return "Invalid API configuration"
        case .noResponseData:
            return "No response data received"
        case .invalidResponseFormat:
            return "Invalid response format"
        case .noGuidanceFound:
            return "No guidance found for query"
        case .networkError:
            return "Network connection error"
        }
    }
}