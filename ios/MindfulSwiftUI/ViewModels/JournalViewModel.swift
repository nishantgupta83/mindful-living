import Foundation

class JournalViewModel: ObservableObject {
  @Published var entries: [JournalEntry] = []

  init() {
    loadEntries()
  }

  private func loadEntries() {
    entries = [
      JournalEntry(
        id: "1",
        title: "Morning reflection",
        content: "Started the day with gratitude. Feeling calm and focused. Looking forward to the week ahead.",
        mood: "😊",
        date: Date().addingTimeInterval(-86400)
      ),
      JournalEntry(
        id: "2",
        title: "Meditation session",
        content: "Completed 10-minute breathing exercise. Felt peaceful and grounded afterwards.",
        mood: "🧘",
        date: Date().addingTimeInterval(-172800)
      ),
    ]
  }

  func addEntry(content: String) {
    let newEntry = JournalEntry(
      id: UUID().uuidString,
      title: extractTitle(from: content),
      content: content,
      mood: "😊",
      date: Date()
    )
    entries.insert(newEntry, at: 0)
  }

  private func extractTitle(from content: String) -> String {
    let lines = content.split(separator: "\n", maxSplits: 1)
    return String(lines.first ?? "Untitled").prefix(50) + (lines.first?.count ?? 0 > 50 ? "..." : "")
  }
}

struct JournalEntry: Identifiable {
  let id: String
  let title: String
  let content: String
  let mood: String
  let date: Date
}
