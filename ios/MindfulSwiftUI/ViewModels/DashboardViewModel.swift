import Foundation
import Combine

class DashboardViewModel: ObservableObject {
  @Published var wellnessScore: Double = 72
  @Published var streak: Int = 5
  @Published var currentMood: String = "😊"
  @Published var journalEntries: Int = 12
  @Published var completedPractices: Int = 8

  init() {
    loadDashboardData()
  }

  private func loadDashboardData() {
    // Simulate loading from Firebase
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.wellnessScore = Double.random(in: 65...85)
      self.streak = Int.random(in: 1...30)
      self.journalEntries = Int.random(in: 5...50)
      self.completedPractices = Int.random(in: 1...20)
    }
  }
}
