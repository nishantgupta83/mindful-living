import Foundation
import SwiftUI

class PracticesViewModel: ObservableObject {
  @Published var practices: [Practice] = []

  init() {
    loadPractices()
  }

  private func loadPractices() {
    practices = [
      Practice(
        id: "1",
        name: "Mindful Breathing",
        description: "Calm your mind with guided breathing exercises",
        icon: "wind",
        color: Color.lavender,
        duration: 5,
        difficulty: "Easy",
        benefits: ["Reduces anxiety", "Improves focus", "Lowers blood pressure"]
      ),
      Practice(
        id: "2",
        name: "Body Scan",
        description: "Progressive relaxation to release tension",
        icon: "figure.walk",
        color: Color.mintGreen,
        duration: 10,
        difficulty: "Easy",
        benefits: ["Reduces muscle tension", "Improves awareness", "Better sleep"]
      ),
      Practice(
        id: "3",
        name: "Gratitude Meditation",
        description: "Cultivate appreciation for life's moments",
        icon: "heart.fill",
        color: Color(red: 1, green: 0.4, blue: 0.5),
        duration: 8,
        difficulty: "Medium",
        benefits: ["Increases happiness", "Improves relationships", "Better perspective"]
      ),
      Practice(
        id: "4",
        name: "Loving-Kindness",
        description: "Develop compassion for yourself and others",
        icon: "sparkles",
        color: Color(red: 1, green: 0.8, blue: 0.2),
        duration: 12,
        difficulty: "Medium",
        benefits: ["Builds empathy", "Reduces negativity", "Enhances well-being"]
      ),
    ]
  }
}

struct Practice: Identifiable, Hashable {
  let id: String
  let name: String
  let description: String
  let icon: String
  let color: Color
  let duration: Int
  let difficulty: String
  let benefits: [String]

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: Practice, rhs: Practice) -> Bool {
    lhs.id == rhs.id
  }
}
