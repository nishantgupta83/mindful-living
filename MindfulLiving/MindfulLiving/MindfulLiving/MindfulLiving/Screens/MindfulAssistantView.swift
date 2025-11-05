import SwiftUI

struct MindfulAssistantView: View {
  @StateObject private var voiceManager = VoiceInputManager.shared
  @StateObject private var searchService = SemanticSearchService.shared
  @State private var searchQuery = ""
  @State private var searchResults: [LifeSituation] = []
  @State private var showResults = false
  @State private var selectedResult: LifeSituation?
  @State private var showDetailSheet = false

  // Debouncing state
  @State private var debounceTimer: Timer?
  private let debounceDelay: TimeInterval = 0.3 // 300ms debounce

  var body: some View {
    ZStack {
      LinearGradient(
        gradient: Gradient(colors: [.lavender.opacity(0.05), .white]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()

      VStack(spacing: 0) {
        // Header
        VStack(alignment: .leading, spacing: 12) {
          HStack {
            VStack(alignment: .leading, spacing: 4) {
              Text("Mindful Assistant")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.deepLavender)

              Text("What's on your mind?")
                .font(.system(size: 14))
                .foregroundColor(.lightGray)
            }

            Spacer()
          }
          .padding(20)
        }
        .background(Color.white.opacity(0.5))

        ScrollView {
          VStack(spacing: 20) {
            // Search Input Section
            VStack(spacing: 12) {
              // Text Input
              HStack {
                Image(systemName: "magnifyingglass")
                  .foregroundColor(.lavender)

                TextField("Type or speak...", text: $searchQuery)
                  .textFieldStyle(.plain)
                  .onChange(of: searchQuery) { newValue in
                    debouncedSearch(newValue)
                  }

                if !searchQuery.isEmpty {
                  Button(action: { searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                      .foregroundColor(.mutedGray)
                  }
                }
              }
              .padding(12)
              .background(Color.white)
              .cornerRadius(12)
              .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)

              // Voice Input Button
              HStack(spacing: 12) {
                VoiceMicButton(
                  isListening: voiceManager.isListening,
                  onTap: {
                    if voiceManager.isListening {
                      voiceManager.stopListening()
                    } else {
                      voiceManager.startListening()
                    }
                  }
                )

                if !voiceManager.recognizedText.isEmpty {
                  VStack(alignment: .leading, spacing: 4) {
                    Text("You said:")
                      .font(.system(size: 12, weight: .semibold))
                      .foregroundColor(.lightGray)

                    Text(voiceManager.recognizedText)
                      .font(.system(size: 14))
                      .foregroundColor(.deepCharcoal)
                      .lineLimit(2)
                  }

                  Spacer()

                  Button(action: {
                    searchQuery = voiceManager.recognizedText
                    voiceManager.clearText()
                  }) {
                    Text("Use")
                      .font(.system(size: 12, weight: .semibold))
                      .foregroundColor(.lavender)
                  }
                }
              }
              .padding(12)
              .background(Color.white)
              .cornerRadius(12)
              .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)

              // Error Message with Recovery
              if let error = voiceManager.errorMessage {
                VStack(spacing: 12) {
                  HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                      .foregroundColor(.red)
                    Text(error)
                      .font(.system(size: 12))
                      .foregroundColor(.red)
                    Spacer()
                  }

                  // Show Settings button for permission errors
                  if error.lowercased().contains("permission") {
                    Button(action: openAppSettings) {
                      HStack {
                        Image(systemName: "gear")
                        Text("Open Settings")
                      }
                      .font(.system(size: 12, weight: .semibold))
                      .foregroundColor(.white)
                      .frame(maxWidth: .infinity)
                      .padding(8)
                      .background(Color.red)
                      .cornerRadius(6)
                    }
                  }
                }
                .padding(12)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
              }
            }
            .padding(20)

            // Loading State
            if searchService.isLoading {
              VStack(spacing: 12) {
                ProgressView()
                  .tint(.lavender)

                Text("Loading scenarios...")
                  .font(.system(size: 14))
                  .foregroundColor(.mutedGray)
              }
              .padding(40)
            }

            // Results Section
            if !searchResults.isEmpty {
              VStack(alignment: .leading, spacing: 12) {
                HStack {
                  HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                      .font(.system(size: 12, weight: .semibold))
                      .foregroundColor(.deepLavender)

                    Text("AI Search")
                      .font(.system(size: 12, weight: .semibold))
                  }
                  .padding(.horizontal, 8)
                  .padding(.vertical, 4)
                  .background(Color.lavender.opacity(0.15))
                  .cornerRadius(6)

                  Text("\(searchResults.count) suggestion\(searchResults.count == 1 ? "" : "s")")
                    .font(.system(size: 12))
                    .foregroundColor(.mutedGray)

                  Spacer()
                }
                .padding(.horizontal, 20)

                ForEach(searchResults) { scenario in
                  ScenarioCard(scenario: scenario)
                    .padding(.horizontal, 20)
                    .onTapGesture {
                      selectedResult = scenario
                      showDetailSheet = true
                    }
                }
              }
            } else if !searchQuery.isEmpty && !searchService.isLoading {
              // No Results State
              VStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                  .font(.system(size: 32))
                  .foregroundColor(.lavender.opacity(0.5))

                Text("No suggestions found")
                  .font(.system(size: 16, weight: .semibold))
                  .foregroundColor(.deepCharcoal)

                Text("Try different keywords")
                  .font(.system(size: 14))
                  .foregroundColor(.mutedGray)
              }
              .frame(maxWidth: .infinity)
              .padding(40)
            }

            // Empty State
            if searchQuery.isEmpty && searchResults.isEmpty && !searchService.isLoading {
              VStack(spacing: 16) {
                Image(systemName: "leaf.fill")
                  .font(.system(size: 40))
                  .foregroundColor(.lavender.opacity(0.5))

                Text("Start a conversation")
                  .font(.system(size: 16, weight: .semibold))
                  .foregroundColor(.deepCharcoal)

                Text("Tell us what's on your mind or ask a question to get personalized suggestions")
                  .font(.system(size: 14))
                  .foregroundColor(.mutedGray)
                  .multilineTextAlignment(.center)
              }
              .frame(maxWidth: .infinity)
              .padding(40)
            }

            Spacer()
              .frame(height: 20)
          }
          .padding(.vertical, 20)
        }
      }
    }
    .sheet(isPresented: $showDetailSheet, onDismiss: { selectedResult = nil }) {
      if let scenario = selectedResult {
        ScenarioDetailSheet(scenario: scenario)
      }
    }
    .onAppear {
      // Scenarios are preloaded by SearchService
    }
  }

  private func debouncedSearch(_ query: String) {
    // Cancel existing timer
    debounceTimer?.invalidate()

    // If empty, clear immediately
    if query.isEmpty {
      searchResults = []
      return
    }

    // Schedule search after debounce delay
    debounceTimer = Timer.scheduledTimer(withTimeInterval: debounceDelay, repeats: false) { _ in
      performSearch(query)
    }
  }

  private func performSearch(_ query: String) {
    if query.isEmpty {
      searchResults = []
      return
    }

    // Perform local search (no Firebase calls after initial load)
    searchResults = searchService.searchLocally(query: query)
  }

  private func openAppSettings() {
    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
      return
    }
    UIApplication.shared.open(settingsURL)
  }
}

// MARK: - Voice Mic Button
struct VoiceMicButton: View {
  let isListening: Bool
  let onTap: () -> Void

  var body: some View {
    Button(action: onTap) {
      VStack(spacing: 4) {
        Image(systemName: isListening ? "mic.fill" : "mic")
          .font(.system(size: 20, weight: .semibold))
          .foregroundColor(isListening ? .white : .lavender)
          .accessibilityHidden(true)

        Text(isListening ? "Stop" : "Speak")
          .font(.system(size: 10, weight: .semibold))
          .foregroundColor(isListening ? .white : .lavender)
      }
      .frame(maxWidth: .infinity)
      // Minimum 44x44 touch target for accessibility
      .frame(height: 60)
      .background(isListening ? Color.lavender : Color.lavender.opacity(0.1))
      .cornerRadius(12)
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(Color.lavender.opacity(0.3), lineWidth: 1)
      )
    }
    .accessibilityLabel(isListening ? "Stop listening" : "Start voice input")
    .accessibilityHint(isListening ? "Tap to stop recording" : "Tap to start recording your voice")
  }
}

// MARK: - Scenario Card
struct ScenarioCard: View {
  let scenario: LifeSituation

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(alignment: .top, spacing: 12) {
        VStack(alignment: .leading, spacing: 8) {
          Text(scenario.title)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.deepCharcoal)
            .lineLimit(2)

          Text(scenario.description)
            .font(.system(size: 12))
            .foregroundColor(.mutedGray)
            .lineLimit(2)
        }

        Spacer()

        VStack(alignment: .center, spacing: 4) {
          if let score = scenario.relevanceScore {
            Text("\(Int(score * 100))%")
              .font(.system(size: 12, weight: .bold))
              .foregroundColor(.lavender)

            Text("match")
              .font(.system(size: 10))
              .foregroundColor(.mutedGray)
          }
        }
      }

      HStack(spacing: 8) {
        CategoryBadge(category: scenario.category)
        DifficultyBadge(difficulty: scenario.difficulty)
        Spacer()
      }
    }
    .padding(12)
    .background(Color.white)
    .cornerRadius(12)
    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    .accessibilityElement(children: .combine)
    .accessibilityLabel(scenario.title)
    .accessibilityValue(scenario.description)
    .accessibilityHint("Category: \(scenario.category), Difficulty: \(scenario.difficulty), Relevance: \(Int((scenario.relevanceScore ?? 0) * 100))%")
  }
}

// MARK: - Detail Sheet
struct ScenarioDetailSheet: View {
  let scenario: LifeSituation
  @Environment(\.dismiss) var dismiss

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          // Title and Meta
          VStack(alignment: .leading, spacing: 8) {
            Text(scenario.title)
              .font(.system(size: 22, weight: .bold))
              .foregroundColor(.deepCharcoal)

            Text(scenario.description)
              .font(.system(size: 14))
              .foregroundColor(.mutedGray)

            HStack(spacing: 8) {
              CategoryBadge(category: scenario.category)
              DifficultyBadge(difficulty: scenario.difficulty)
            }
          }
          .padding(20)

          Divider()
            .padding(.horizontal, 20)

          // Mindful Approach
          VStack(alignment: .leading, spacing: 8) {
            Label("Mindful Approach", systemImage: "leaf.fill")
              .font(.system(size: 14, weight: .semibold))
              .foregroundColor(.deepLavender)

            Text(scenario.mindfulApproach)
              .font(.system(size: 13))
              .foregroundColor(.deepCharcoal)
          }
          .padding(20)

          // Practical Steps
          VStack(alignment: .leading, spacing: 12) {
            Label("Practical Steps", systemImage: "checklist")
              .font(.system(size: 14, weight: .semibold))
              .foregroundColor(.deepLavender)

            ForEach(Array(scenario.practicalSteps.enumerated()), id: \.offset) { index, step in
              HStack(alignment: .top, spacing: 12) {
                Text("\(index + 1)")
                  .font(.system(size: 12, weight: .semibold))
                  .foregroundColor(.white)
                  .frame(width: 24, height: 24)
                  .background(Color.lavender)
                  .cornerRadius(12)

                Text(step)
                  .font(.system(size: 13))
                  .foregroundColor(.deepCharcoal)

                Spacer()
              }
            }
          }
          .padding(20)

          Spacer()
            .frame(height: 20)
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: { dismiss() }) {
            Image(systemName: "xmark.circle.fill")
              .foregroundColor(.mutedGray)
          }
        }
      }
    }
  }
}

// MARK: - Helper Views
struct CategoryBadge: View {
  let category: String

  var body: some View {
    Text(category)
      .font(.system(size: 10, weight: .semibold))
      .foregroundColor(.deepLavender)
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(Color.lavender.opacity(0.15))
      .cornerRadius(6)
  }
}

struct DifficultyBadge: View {
  let difficulty: String

  var color: Color {
    switch difficulty.lowercased() {
    case "easy", "low":
      return .mintGreen
    case "medium":
      return .orange
    case "hard", "high":
      return .red
    default:
      return .gray
    }
  }

  var body: some View {
    Text(difficulty)
      .font(.system(size: 10, weight: .semibold))
      .foregroundColor(color)
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(color.opacity(0.15))
      .cornerRadius(6)
  }
}

#Preview {
  MindfulAssistantView()
}
