import SwiftUI
import WatchKit

struct ContentView: View {
    @EnvironmentObject var voiceManager: VoiceQueryManager
    @State private var isListening = false
    @State private var showingResponse = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Mindful Living logo/title
                Text("Mindful")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                // Main voice button
                Button(action: startVoiceQuery) {
                    VStack(spacing: 8) {
                        Image(systemName: isListening ? "mic.fill" : "mic")
                            .font(.largeTitle)
                            .foregroundColor(isListening ? .red : .blue)
                            .scaleEffect(isListening ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: isListening)
                        
                        Text(isListening ? "Listening..." : "Ask for advice")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                }
                .buttonStyle(.plain)
                .disabled(voiceManager.isProcessing)
                
                // Quick wellness score
                if let score = voiceManager.todaysWellnessScore {
                    WellnessScoreView(score: score)
                }
                
                // Recent guidance preview
                if let lastGuidance = voiceManager.lastGuidance {
                    LastGuidanceView(guidance: lastGuidance)
                        .onTapGesture {
                            showingResponse = true
                        }
                }
            }
            .padding()
            .navigationTitle("Mindful")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingResponse) {
            if let guidance = voiceManager.lastGuidance {
                GuidanceDetailView(guidance: guidance)
            }
        }
        .alert("Voice Error", 
               isPresented: Binding<Bool>(
                get: { voiceManager.error != nil },
                set: { _ in voiceManager.error = nil }
               )) {
            Button("OK") { }
        } message: {
            Text(voiceManager.error?.localizedDescription ?? "")
        }
    }
    
    private func startVoiceQuery() {
        isListening = true
        
        // Start voice recognition
        voiceManager.startVoiceQuery { success in
            DispatchQueue.main.async {
                isListening = false
                if success {
                    showingResponse = true
                }
            }
        }
    }
}

struct WellnessScoreView: View {
    let score: Int
    
    private var scoreColor: Color {
        switch score {
        case 80...100: return .green
        case 60...79: return .orange
        default: return .red
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Wellness")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(score)%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(scoreColor)
            }
            
            ProgressView(value: Double(score), total: 100.0)
                .progressViewStyle(LinearProgressViewStyle(tint: scoreColor))
                .scaleEffect(y: 0.8)
        }
        .padding(.horizontal, 4)
    }
}

struct LastGuidanceView: View {
    let guidance: VoiceGuidance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Recent Advice")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(guidance.title)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
            
            Text(guidance.shortSummary)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct GuidanceDetailView: View {
    let guidance: VoiceGuidance
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(guidance.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(guidance.spokenResponse)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if !guidance.actionSteps.isEmpty {
                        Divider()
                        
                        Text("Action Steps")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        ForEach(Array(guidance.actionSteps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 8) {
                                Text("\(index + 1).")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(step)
                                    .font(.caption)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer()
                            }
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Guidance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(VoiceQueryManager())
}