import Foundation

class ExploreViewModel: ObservableObject {
  @Published var dilemmas: [DilemmaItem] = []
  @Published var categories = ["Relationships", "Career", "Finance", "Mental Health", "Family", "Health"]

  init() {
    loadDilemmas()
  }

  private func loadDilemmas() {
    dilemmas = [
      DilemmaItem(
        id: "1",
        title: "Dealing with workplace stress",
        description: "How to manage pressure and maintain work-life balance",
        category: "Career",
        difficulty: "Medium",
        mindfulApproach: "Practice mindfulness at work, take short breaks",
        practicalSteps: [
          "Identify stress triggers",
          "Practice breathing exercises",
          "Set boundaries with work",
          "Communicate with managers"
        ]
      ),
      DilemmaItem(
        id: "2",
        title: "Relationship conflicts",
        description: "Navigating disagreements and improving communication",
        category: "Relationships",
        difficulty: "High",
        mindfulApproach: "Listen with compassion and speak with intention",
        practicalSteps: [
          "Practice active listening",
          "Express feelings clearly",
          "Take breaks when needed",
          "Seek professional help if needed"
        ]
      ),
      DilemmaItem(
        id: "3",
        title: "Financial worries",
        description: "Managing money anxiety and building better habits",
        category: "Finance",
        difficulty: "Medium",
        mindfulApproach: "Develop a realistic budget and review regularly",
        practicalSteps: [
          "Track expenses",
          "Create a budget",
          "Set savings goals",
          "Seek financial advice"
        ]
      ),
      DilemmaItem(
        id: "4",
        title: "Anxiety management",
        description: "Techniques to reduce anxiety and find calm",
        category: "Mental Health",
        difficulty: "Medium",
        mindfulApproach: "Practice grounding techniques and mindfulness",
        practicalSteps: [
          "Use 5-4-3-2-1 grounding",
          "Practice deep breathing",
          "Regular exercise",
          "Seek professional support"
        ]
      ),
      DilemmaItem(
        id: "5",
        title: "Family communication",
        description: "Improving relationships with family members",
        category: "Family",
        difficulty: "High",
        mindfulApproach: "Approach with patience and understanding",
        practicalSteps: [
          "Schedule regular check-ins",
          "Practice empathy",
          "Set healthy boundaries",
          "Address issues calmly"
        ]
      ),
      DilemmaItem(
        id: "6",
        title: "Sleep issues",
        description: "Improving sleep quality and developing healthy habits",
        category: "Health",
        difficulty: "Low",
        mindfulApproach: "Establish a consistent sleep routine",
        practicalSteps: [
          "Stick to a schedule",
          "Reduce screen time",
          "Try relaxation techniques",
          "Consult a doctor if needed"
        ]
      ),
    ]
  }
}

struct DilemmaItem: Identifiable, Hashable, Codable {
  let id: String
  let title: String
  let description: String
  let category: String
  let difficulty: String
  let mindfulApproach: String
  let practicalSteps: [String]

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: DilemmaItem, rhs: DilemmaItem) -> Bool {
    lhs.id == rhs.id
  }
}
