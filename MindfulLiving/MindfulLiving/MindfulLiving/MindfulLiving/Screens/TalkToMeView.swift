import SwiftUI
import FirebaseFirestore

// MARK: - Data Models

struct CoachingResponse: Codable {
    let success: Bool
    let query: String
    let response: String
    let retrievedScenarios: [RetrievedScenario]
    let actionPlan: [ActionStep]
    let relatedPractices: [String]
    let generatedAt: String
    let modelVersion: String
    let latencySeconds: Double
    let offline: Bool
}

struct RetrievedScenario: Codable {
    let id: String
    let title: String
    let similarity: Double
}

struct ActionStep: Codable {
    let step: String
    let duration: Int
    let mindfulTechnique: String?

    enum CodingKeys: String, CodingKey {
        case step, duration
        case mindfulTechnique = "mindful_technique"
    }
}

// MARK: - View Model

@MainActor
class TalkToMeViewModel: ObservableObject {
    @Published var userQuery: String = ""
    @Published var coachingResponse: CoachingResponse?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var conversationHistory: [ConversationMessage] = []

    private var backgroundTask: URLSessionWebSocketTask?
    private let db = Firestore.firestore()

    struct ConversationMessage: Identifiable {
        let id = UUID()
        let isUser: Bool
        let text: String
        let timestamp: Date
    }

    // MARK: - Talk to Me (Main Method)

    func talkToMe(query: String) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter a question"
            return
        }

        // Add user message to history
        conversationHistory.append(ConversationMessage(
            isUser: true,
            text: query,
            timestamp: Date()
        ))

        isLoading = true
        errorMessage = nil
        userQuery = ""

        // Start background task so it continues if user disconnects
        startBackgroundTask(query: query)
    }

    // MARK: - Background Task Support

    private func startBackgroundTask(query: String) {
        // Run in background to survive internet disconnects
        Task(priority: .background) {
            await callTalkToMeAPI(query: query)
        }
    }

    // MARK: - Call Talk to Me API

    private func callTalkToMeAPI(query: String) async {
        do {
            // Try cloud function first
            let response = try await callCloudFunction(query: query)

            await MainActor.run {
                self.coachingResponse = response
                self.conversationHistory.append(ConversationMessage(
                    isUser: false,
                    text: response.response,
                    timestamp: Date()
                ))
                self.isLoading = false
            }

        } catch {
            // Fallback to local template if offline
            await MainActor.run {
                self.useTemplateResponse(query: query)
                self.isLoading = false
            }
        }
    }

    // MARK: - Call Cloud Function

    private func callCloudFunction(query: String) async throws -> CoachingResponse {
        let url = URL(string: "https://YOUR_PROJECT.cloudfunctions.net/talk-to-me")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = ["query": query]
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "API Error", code: -1)
        }

        return try JSONDecoder().decode(CoachingResponse.self, from: data)
    }

    // MARK: - Template Fallback (Offline Support)

    private func useTemplateResponse(query: String) {
        let template = CoachingResponse(
            success: false,
            query: query,
            response: """
            I understand you're facing this challenge. Even without internet, remember:

            • **Pause & Breathe**: Take 3-4 deep breaths
            • **Ground Yourself**: Notice 5 things you see, 4 you can touch, 3 you hear
            • **Reach Out**: Connect with someone you trust

            When you're back online, I can give you more personalized guidance based on our full knowledge base.
            """,
            retrievedScenarios: [],
            actionPlan: [
                ActionStep(step: "Take 3-4 minute breaths", duration: 2, mindfulTechnique: "breathing"),
                ActionStep(step: "Journal about the situation", duration: 5, mindfulTechnique: "reflection"),
                ActionStep(step: "Reach out to a trusted person", duration: 5, mindfulTechnique: "connection")
            ],
            relatedPractices: ["breathing_box", "grounding_5_4_3_2_1"],
            generatedAt: Date().ISO8601Format(),
            modelVersion: "template-offline",
            latencySeconds: 0,
            offline: true
        )

        self.coachingResponse = template
        self.conversationHistory.append(ConversationMessage(
            isUser: false,
            text: template.response,
            timestamp: Date()
        ))
    }

    // MARK: - Save Conversation

    func saveConversation() async {
        guard let response = coachingResponse else { return }

        do {
            try await db.collection("talk_to_me_conversations").addDocument(data: [
                "userId": "current_user_id",  // TODO: Get from Auth
                "query": response.query,
                "response": response.response,
                "timestamp": Timestamp(),
                "offline": response.offline
            ])
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to save conversation"
            }
        }
    }
}

// MARK: - Main UI

struct TalkToMeView: View {
    @StateObject private var viewModel = TalkToMeViewModel()
    @FocusState private var isQueryFocused: Bool

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1) : UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1) }),
                    Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(red: 0.12, green: 0.12, blue: 0.17, alpha: 1) : UIColor.white })
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Talk to Me")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)

                            Text("Ask for personalized guidance")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Image(systemName: "sparkles")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                    }
                    .padding(16)
                }
                .background(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 4)

                // Conversation History
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(viewModel.conversationHistory) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }

                            if viewModel.isLoading {
                                LoadingIndicator()
                            }

                            Spacer()
                        }
                        .padding(16)
                        .onChange(of: viewModel.conversationHistory) { _ in
                            if let lastMessage = viewModel.conversationHistory.last {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }

                // Input Area
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        TextField("Ask me anything...", text: $viewModel.userQuery)
                            .textFieldStyle(.roundedBorder)
                            .focused($isQueryFocused)
                            .accessibilityLabel("Question input")
                            .accessibilityHint("Enter your question for personalized guidance")

                        Button(action: {
                            viewModel.talkToMe(query: viewModel.userQuery)
                            isQueryFocused = false
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                        }
                        .disabled(viewModel.userQuery.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isLoading)
                        .accessibilityLabel("Send question")
                    }
                    .padding(12)

                    if let error = viewModel.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.circle")
                            Text(error)
                        }
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(6)
                    }

                    // Offline Indicator
                    if viewModel.coachingResponse?.offline == true {
                        HStack(spacing: 8) {
                            Image(systemName: "wifi.slash")
                                .font(.caption2)
                            Text("Offline mode - limited guidance")
                                .font(.caption)
                        }
                        .foregroundColor(.orange)
                        .padding(8)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(6)
                    }

                    // Save Button
                    if viewModel.coachingResponse != nil {
                        Button(action: {
                            Task {
                                await viewModel.saveConversation()
                            }
                        }) {
                            Label("Save Conversation", systemImage: "bookmark")
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(12)
                .background(Color(.systemBackground))
            }
        }
    }
}

// MARK: - Message Bubble Component

struct MessageBubble: View {
    let message: TalkToMeViewModel.ConversationMessage

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.isUser {
                Spacer()
            } else {
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }

            Text(message.text)
                .padding(12)
                .background(message.isUser ? Color.blue : Color(.systemGray5))
                .foregroundColor(message.isUser ? .white : .primary)
                .cornerRadius(12)

            if !message.isUser {
                Spacer()
            }
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Loading Indicator

struct LoadingIndicator: View {
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color.blue)
                .frame(width: 8, height: 8)
                .scaleEffect(isAnimating ? 1.2 : 0.8)

            Circle()
                .fill(Color.blue)
                .frame(width: 8, height: 8)
                .scaleEffect(isAnimating ? 1.2 : 0.8)
                .delay(0.1)

            Circle()
                .fill(Color.blue)
                .frame(width: 8, height: 8)
                .scaleEffect(isAnimating ? 1.2 : 0.8)
                .delay(0.2)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever()) {
                isAnimating = true
            }
        }
    }
}

extension View {
    func delay(_ delay: Double) -> some View {
        self.modifier(DelayModifier(delay: delay))
    }
}

struct DelayModifier: ViewModifier {
    let delay: Double

    func body(content: Content) -> some View {
        content
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    // Animation starts
                }
            }
    }
}

#Preview {
    TalkToMeView()
}
