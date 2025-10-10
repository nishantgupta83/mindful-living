# Apple Watch Deployment Agent

## 🎯 Purpose
Deploy Mindful Living Apple Watch app with voice integration, complications, and wellness tracking. Works independently in parallel with other development.

## 📋 Responsibilities
- Add Watch target to iOS project
- Implement SwiftUI interface
- Voice query integration
- Watch Connectivity setup
- Complications (watch faces)
- Submit with iOS app

## ⚡ Quick Start (Complete Workflow)

```bash
# Run full Watch deployment
./scripts/deploy_watch.sh

# Individual steps
./scripts/watch_create_target.sh
./scripts/watch_implement_ui.sh
./scripts/watch_test_device.sh
```

---

## 📅 Timeline: 3-4 Days

### Day 1: Project Setup
- Add Watch app target in Xcode
- Configure project settings
- Set up Watch Connectivity

### Day 2: UI Implementation
- Build SwiftUI interface
- Implement voice queries
- Add complications

### Day 3: Testing & Refinement
- Test on physical device
- Optimize performance
- Refine UX

### Day 4: Integration & Submission
- Integrate with iPhone app
- Final testing
- Submit with iOS app

---

## 🔧 Step 1: Add Watch Target

### Xcode Setup

1. **Open Project**:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Add Watch App Target**:
   - File → New → Target
   - Select "Watch App for iOS App"
   - Product Name: "MindfulWatch"
   - Language: Swift
   - User Interface: SwiftUI
   - ✅ Include Notification Scene
   - ✅ Include Complication

3. **Configure Bundle Identifiers**:
   ```
   iOS App: com.hub4apps.mindfulliving
   Watch App: com.hub4apps.mindfulliving.watchkitapp
   Watch Extension: com.hub4apps.mindfulliving.watchkitapp.watchkitextension
   ```

4. **Add App Groups**:
   - Signing & Capabilities
   - + Capability → App Groups
   - Add: `group.com.hub4apps.mindfulliving`
   - Apply to iOS and Watch targets

---

## 📱 Step 2: SwiftUI Interface

### Main Watch App
```swift
// ios/MindfulWatch Watch App/MindfulWatchApp.swift

import SwiftUI

@main
struct MindfulWatchApp: App {
    @StateObject private var connectivityManager = WatchConnectivityManager.shared
    @StateObject private var voiceManager = VoiceQueryManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connectivityManager)
                .environmentObject(voiceManager)
        }
    }
}
```

### Content View
```swift
// ios/MindfulWatch Watch App/ContentView.swift

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var voiceManager: VoiceQueryManager
    @State private var wellnessScore: Int = 75
    @State private var streak: Int = 5
    @State private var showingVoiceSheet = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Wellness Score Ring
                    WellnessScoreView(score: wellnessScore)

                    // Voice Query Button
                    Button(action: {
                        showingVoiceSheet = true
                    }) {
                        HStack {
                            Image(systemName: "mic.circle.fill")
                                .font(.title)
                            Text("Ask Mindful")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .sheet(isPresented: $showingVoiceSheet) {
                        VoiceQueryView()
                    }

                    // Quick Actions
                    VStack(spacing: 12) {
                        QuickActionButton(
                            icon: "lungs.fill",
                            title: "Breathe",
                            action: { startBreathingExercise() }
                        )

                        QuickActionButton(
                            icon: "book.fill",
                            title: "Reflect",
                            action: { showDailyReflection() }
                        )

                        QuickActionButton(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Progress",
                            action: { showProgress() }
                        )
                    }

                    // Streak Counter
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(streak) day streak")
                            .font(.caption)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Mindful")
        }
    }

    private func startBreathingExercise() {
        // Navigate to breathing exercise
    }

    private func showDailyReflection() {
        // Show today's reflection
    }

    private func showProgress() {
        // Show progress view
    }
}

// Wellness Score Ring Component
struct WellnessScoreView: View {
    let score: Int

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 12)

            // Progress circle
            Circle()
                .trim(from: 0, to: CGFloat(score) / 100)
                .stroke(
                    LinearGradient(
                        colors: [.blue, .green],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: score)

            // Score text
            VStack {
                Text("\(score)")
                    .font(.system(size: 36, weight: .bold))
                Text("Wellness")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 100, height: 100)
    }
}

// Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 30)
                Text(title)
                    .font(.subheadline)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .foregroundColor(.primary)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
```

### Voice Query View
```swift
// ios/MindfulWatch Watch App/VoiceQueryView.swift

import SwiftUI
import Speech

struct VoiceQueryView: View {
    @EnvironmentObject var voiceManager: VoiceQueryManager
    @Environment(\.dismiss) var dismiss
    @State private var isListening = false
    @State private var query = ""
    @State private var response = ""
    @State private var showResponse = false

    var body: some View {
        VStack(spacing: 20) {
            if !showResponse {
                // Listening UI
                VStack {
                    Spacer()

                    // Animated mic icon
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .scaleEffect(isListening ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.8).repeatForever(), value: isListening)

                        Image(systemName: "mic.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.blue)
                    }

                    Spacer()

                    Text(isListening ? "Listening..." : query)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding()

                    if !isListening {
                        Button("Tap to Speak") {
                            startListening()
                        }
                        .foregroundColor(.blue)
                    }

                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            } else {
                // Response UI
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Guidance")
                            .font(.headline)

                        Text(response)
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)

                        Button("Done") {
                            dismiss()
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            startListening()
        }
    }

    private func startListening() {
        isListening = true
        query = ""

        voiceManager.startListening { result in
            isListening = false

            switch result {
            case .success(let transcription):
                query = transcription
                processQuery(transcription)

            case .failure(let error):
                query = "Error: \(error.localizedDescription)"
            }
        }
    }

    private func processQuery(_ query: String) {
        voiceManager.getLifeAdvice(for: query) { result in
            switch result {
            case .success(let advice):
                response = formatAdviceForWatch(advice)
                showResponse = true

            case .failure(let error):
                response = "Sorry, I couldn't find guidance for that."
                showResponse = true
            }
        }
    }

    private func formatAdviceForWatch(_ advice: LifeAdvice) -> String {
        return """
        \(advice.mindfulApproach)

        Steps:
        \(advice.practicalSteps.prefix(3).joined(separator: "\n"))
        """
    }
}
```

---

## 🗣️ Step 3: Voice Integration

### Voice Query Manager
```swift
// ios/MindfulWatch Watch App/VoiceQueryManager.swift

import Foundation
import Speech
import Combine

class VoiceQueryManager: NSObject, ObservableObject {
    @Published var isListening = false
    @Published var query = ""

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    func startListening(completion: @escaping (Result<String, Error>) -> Void) {
        // Request authorization
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self.performRecognition(completion: completion)
                case .denied, .restricted, .notDetermined:
                    completion(.failure(NSError(domain: "VoiceError", code: 1)))
                @unknown default:
                    completion(.failure(NSError(domain: "VoiceError", code: 2)))
                }
            }
        }
    }

    private func performRecognition(completion: @escaping (Result<String, Error>) -> Void) {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            completion(.failure(NSError(domain: "VoiceError", code: 3)))
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            completion(.failure(NSError(domain: "VoiceError", code: 4)))
            return
        }

        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                self.query = result.bestTranscription.formattedString

                if result.isFinal {
                    completion(.success(self.query))
                    self.stopListening()
                }
            }

            if let error = error {
                completion(.failure(error))
                self.stopListening()
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
            isListening = true

            // Auto-stop after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.stopListening()
            }
        } catch {
            completion(.failure(error))
        }
    }

    func stopListening() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
        isListening = false
    }

    func getLifeAdvice(for query: String, completion: @escaping (Result<LifeAdvice, Error>) -> Void) {
        // Call Firebase Functions endpoint
        guard let url = URL(string: "https://us-central1-hub4apps-mindfulliving.cloudfunctions.net/processVoiceQuery") else {
            completion(.failure(NSError(domain: "URLError", code: 1)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "query": query,
            "platform": "watch"
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "DataError", code: 1)))
                return
            }

            do {
                let advice = try JSONDecoder().decode(LifeAdvice.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(advice))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

struct LifeAdvice: Codable {
    let title: String
    let mindfulApproach: String
    let practicalSteps: [String]
}
```

---

## 🔗 Step 4: Watch Connectivity

### Connectivity Manager
```swift
// ios/MindfulWatch Watch App/WatchConnectivityManager.swift

import WatchConnectivity

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    @Published var wellnessScore: Int = 0
    @Published var streak: Int = 0
    @Published var recentSituations: [String] = []

    private let session: WCSession

    private override init() {
        self.session = WCSession.default
        super.init()

        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }

    func requestWellnessData() {
        guard session.isReachable else { return }

        session.sendMessage(["request": "wellnessData"], replyHandler: { response in
            DispatchQueue.main.async {
                self.wellnessScore = response["score"] as? Int ?? 0
                self.streak = response["streak"] as? Int ?? 0
            }
        }) { error in
            print("Error requesting data: \(error)")
        }
    }

    func logAction(_ action: String) {
        session.sendMessage(["action": action], replyHandler: nil) { error in
            print("Error logging action: \(error)")
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Activation error: \(error)")
            return
        }

        print("Watch session activated")
        requestWellnessData()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle messages from iPhone
        if let score = message["wellnessScore"] as? Int {
            DispatchQueue.main.async {
                self.wellnessScore = score
            }
        }

        if let streak = message["streak"] as? Int {
            DispatchQueue.main.async {
                self.streak = streak
            }
        }
    }
}
```

---

## ⌚ Step 5: Complications

### Complication Controller
```swift
// ios/MindfulWatch Watch App/ComplicationController.swift

import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Get current wellness score
        let wellnessScore = UserDefaults(suiteName: "group.com.hub4apps.mindfulliving")?.integer(forKey: "wellnessScore") ?? 75

        let entry = createTimelineEntry(for: complication, score: wellnessScore, date: Date())
        handler(entry)
    }

    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        let template = createTemplate(for: complication, score: 75)
        handler(template)
    }

    private func createTimelineEntry(for complication: CLKComplication, score: Int, date: Date) -> CLKComplicationTimelineEntry? {
        guard let template = createTemplate(for: complication, score: score) else {
            return nil
        }

        return CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
    }

    private func createTemplate(for complication: CLKComplication, score: Int) -> CLKComplicationTemplate? {
        switch complication.family {
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: "\(score)")
            template.fillFraction = Float(score) / 100.0
            template.ringStyle = .closed
            return template

        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: "\(score)")
            template.fillFraction = Float(score) / 100.0
            template.ringStyle = .closed
            return template

        case .graphicCircular:
            let template = CLKComplicationTemplateGraphicCircularClosedGaugeText()
            template.centerTextProvider = CLKSimpleTextProvider(text: "\(score)")
            template.gaugeProvider = CLKSimpleGaugeProvider(
                style: .fill,
                gaugeColor: .blue,
                fillFraction: Float(score) / 100.0
            )
            return template

        default:
            return nil
        }
    }
}
```

---

## 🧪 Step 6: Testing

### Testing Checklist
- [ ] App launches on Watch
- [ ] Voice recognition works
- [ ] Firebase queries succeed
- [ ] Complications display correctly
- [ ] Watch Connectivity syncs
- [ ] Breathing exercise flows
- [ ] Haptic feedback works
- [ ] Battery impact acceptable
- [ ] Works offline (cached data)

### Test on Physical Device
```bash
# Connect Apple Watch
# Select Watch scheme in Xcode
# Cmd + R to run
```

---

## 📤 Step 7: Submission

### Pre-Submission Checklist
- [ ] Watch app icons (all sizes)
- [ ] Screenshots for all Watch sizes
- [ ] App works on Series 4+
- [ ] No crashes or errors
- [ ] Privacy policy updated
- [ ] Complication descriptions added

### App Store Submission
- Submit as part of iOS app bundle
- Include Watch app in binary
- Add Watch-specific screenshots
- Mention Watch support in description

---

## 🚀 Deployment Commands

```bash
# Build for device
xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme MindfulWatch \
  -destination 'platform=watchOS,name=Apple Watch' \
  build

# Archive for submission
xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -archivePath build/Runner.xcarchive \
  archive

# Upload to App Store
xcodebuild -exportArchive \
  -archivePath build/Runner.xcarchive \
  -exportPath build \
  -exportOptionsPlist ios/ExportOptions.plist
```

---

## 🎯 Success Criteria

### Must Pass
- [ ] Voice recognition works reliably
- [ ] Firebase integration functional
- [ ] Complications update correctly
- [ ] No crashes on watch
- [ ] Battery impact < 5%/hour
- [ ] Apple approval

### Should Have
- [ ] Smooth animations (60 FPS)
- [ ] Quick response times (< 2s)
- [ ] Intuitive UX
- [ ] Good user ratings (4.5+)

---

## 📚 Resources
- [WatchOS Developer Guide](https://developer.apple.com/watchos/)
- [Watch Connectivity Framework](https://developer.apple.com/documentation/watchconnectivity)
- [Complications Programming Guide](https://developer.apple.com/documentation/clockkit)

---

**Timeline: 3-4 days to Apple Watch app! ⌚**
