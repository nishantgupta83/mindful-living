import Foundation

// MARK: - Models
struct LifeSituation: Identifiable, Codable, Hashable {
  let id: String
  let title: String
  let description: String
  let category: String
  let difficulty: String
  let mindfulApproach: String
  let practicalSteps: [String]
  let tags: [String]
  var relevanceScore: Double? = nil // Added dynamically, not stored in Firebase

  enum CodingKeys: String, CodingKey {
    case id, title, description, category, difficulty, mindfulApproach, practicalSteps, tags
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: LifeSituation, rhs: LifeSituation) -> Bool {
    lhs.id == rhs.id
  }
}

// MARK: - Search Cache Models
struct SearchCache: Codable {
  let query: String
  let results: [LifeSituation]
  let timestamp: Date
  let expirationDate: Date
}

struct WellnessConceptMap {
  static let concepts: [String: Set<String>] = [
    // Stress/Pressure related
    "stress": ["pressure", "tension", "overwhelm", "burnout", "strain", "worry", "anxiety"],
    "anxiety": ["worry", "fear", "nervous", "apprehension", "unease", "stress", "anxious", "panic"],
    "pressure": ["stress", "tension", "burden", "weight", "load", "demand"],

    // Work/Career
    "work": ["career", "job", "employment", "profession", "vocation", "workplace", "office"],
    "career": ["work", "job", "profession", "employment", "promotion", "advancement"],
    "job": ["work", "career", "employment", "workplace", "boss", "colleague"],

    // Relationships
    "relationship": ["partner", "dating", "romance", "connection", "love", "intimacy", "marriage"],
    "family": ["parent", "sibling", "relative", "household", "home", "loved ones"],
    "friend": ["friendship", "companion", "colleague", "social", "community"],

    // Mental Health
    "depression": ["sadness", "low", "mood", "unhappy", "despair", "hopeless"],
    "sleep": ["insomnia", "rest", "tired", "fatigue", "exhausted", "bedtime", "rest"],
    "mindfulness": ["meditation", "awareness", "presence", "contemplation", "mindful", "present"],

    // Financial
    "money": ["finance", "budget", "debt", "savings", "income", "expense", "financial"],
    "finance": ["money", "budget", "income", "debt", "spending", "wealth"],

    // Health
    "health": ["wellness", "medical", "physical", "body", "fitness", "exercise"],
    "exercise": ["fitness", "workout", "physical", "activity", "sport", "movement"],
  ]

  static func expandQuery(_ query: String) -> Set<String> {
    let tokens = tokenize(query)
    var expandedTerms = Set(tokens)

    for token in tokens {
      if let relatedConcepts = concepts[token.lowercased()] {
        expandedTerms.formUnion(relatedConcepts)
      }
    }

    return expandedTerms
  }

  static func tokenize(_ text: String) -> [String] {
    let tokens = text.lowercased()
      .split(separator: " ")
      .map(String.init)
      .filter { $0.count > 2 } // Filter words shorter than 2 chars
    return tokens
  }
}

// MARK: - Semantic Search Service
@MainActor
final class SemanticSearchService: NSObject, ObservableObject {
  static let shared = SemanticSearchService()

  @Published var allScenarios: [LifeSituation] = []
  @Published var isLoading = false
  @Published var errorMessage: String?

  private var searchCache: [String: SearchCache] = [:]
  private let cacheExpirationMinutes: TimeInterval = 30 // 30-minute cache
  private let maxCacheEntries = 50 // LRU cache bound
  private var allScenariosLoaded = false
  private var scenarioLoadTask: Task<Void, Never>?

  override init() {
    super.init()
    // Preload all scenarios once on app startup
    preloadAllScenarios()
  }

  // MARK: - Optimized API Strategy
  // Strategy: Load all scenarios ONCE on startup (1 Firebase call when Firebase is configured)
  // Then do local in-memory semantic search (0 API calls for searches)

  func preloadAllScenarios() {
    scenarioLoadTask = Task {
      guard !allScenariosLoaded else { return }

      await MainActor.run {
        isLoading = true
      }

      // Load mock data for testing (will be replaced with Firebase later)
      let mockScenarios = loadMockScenarios()

      await MainActor.run {
        self.allScenarios = mockScenarios
        self.allScenariosLoaded = true
        self.isLoading = false
      }
    }
  }

  private func loadMockScenarios() -> [LifeSituation] {
    return [
      LifeSituation(
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
        ],
        tags: ["stress", "work", "pressure", "balance"]
      ),
      LifeSituation(
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
        ],
        tags: ["relationship", "communication", "conflict", "family"]
      ),
      LifeSituation(
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
        ],
        tags: ["money", "anxiety", "finance", "budget"]
      ),
      LifeSituation(
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
        ],
        tags: ["anxiety", "stress", "mindfulness", "calm"]
      ),
      LifeSituation(
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
        ],
        tags: ["family", "communication", "relationship", "parent"]
      ),
      LifeSituation(
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
        ],
        tags: ["sleep", "health", "rest", "routine"]
      ),
    ]
  }

  // MARK: - Local Semantic Search (Zero Firebase Calls)
  func searchLocally(query: String) -> [LifeSituation] {
    guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }

    // Clean expired cache entries
    cleanExpiredCache()

    // Check cache first (100% local)
    let cacheKey = query.lowercased()
    if let cached = searchCache[cacheKey], !isExpired(cached) {
      return cached.results
    }

    // Expand query using wellness concepts
    let expandedTerms = WellnessConceptMap.expandQuery(query)

    // Score all scenarios based on expanded terms
    let scoredScenarios = allScenarios.map { scenario -> (scenario: LifeSituation, score: Double) in
      let score = calculateRelevanceScore(
        scenario: scenario,
        queryTerms: Array(expandedTerms)
      )
      var mutableScenario = scenario
      mutableScenario.relevanceScore = score
      return (scenario: mutableScenario, score: score)
    }

    // Filter and sort by relevance
    let results = scoredScenarios
      .filter { $0.score > ScoringWeights.minRelevanceThreshold } // Only return scenarios above threshold
      .sorted { $0.score > $1.score }
      .map { $0.scenario }
      .prefix(10) // Limit to top 10 results
      .map { $0 }

    // Cache results with LRU eviction
    let cacheEntry = SearchCache(
      query: query,
      results: results,
      timestamp: Date(),
      expirationDate: Date().addingTimeInterval(cacheExpirationMinutes * 60)
    )

    // Evict oldest entry if cache exceeds max size
    if searchCache.count >= maxCacheEntries {
      let oldest = searchCache.min { $0.value.timestamp < $1.value.timestamp }
      if let oldest = oldest {
        searchCache.removeValue(forKey: oldest.key)
      }
    }

    searchCache[cacheKey] = cacheEntry

    return results
  }

  // MARK: - Scoring Configuration
  /// Relevance scoring weights for different scenario fields
  /// These weights determine importance: higher weight = stronger relevance indicator
  private struct ScoringWeights {
    /// Base relevance score when term found in title (most important)
    static let titleBaseScore: Double = 0.6
    /// Weight multiplier for title field (3x more important)
    static let titleWeight: Double = 3.0

    /// Base relevance score when term found in description
    static let descriptionBaseScore: Double = 0.4
    /// Weight multiplier for description field (2x)
    static let descriptionWeight: Double = 2.0

    /// Base relevance score when term found in mindful approach section
    static let mindfulApproachBaseScore: Double = 0.3
    /// Weight multiplier for mindful approach (1x)
    static let mindfulApproachWeight: Double = 1.0

    /// Base relevance score when term found in practical steps
    static let stepsBaseScore: Double = 0.2
    /// Weight multiplier for steps (1x)
    static let stepsWeight: Double = 1.0

    /// Base relevance score when term found in category
    static let categoryBaseScore: Double = 0.5
    /// Weight multiplier for category (2x - fairly important)
    static let categoryWeight: Double = 2.0

    /// Base relevance score when term found in tags
    static let tagsBaseScore: Double = 0.4
    /// Weight multiplier for tags (1.5x)
    static let tagsWeight: Double = 1.5

    /// Minimum relevance score (0-1) to include in results
    static let minRelevanceThreshold: Double = 0.1
  }

  // MARK: - Private Methods

  /// Calculates TF-IDF-inspired relevance score for a scenario against query terms
  /// Scoring strategy:
  /// 1. Expands query using wellness concept map for semantic matching
  /// 2. Checks scenario fields with weighted importance (title > category > description > tags > steps > approach)
  /// 3. Normalizes by query length to avoid bias toward multi-term queries
  /// Result: 0-1 score indicating relevance strength
  private func calculateRelevanceScore(scenario: LifeSituation, queryTerms: [String]) -> Double {
    var totalScore: Double = 0

    for term in queryTerms {
      // Title: Most relevant field (highest weight)
      if scenario.title.lowercased().contains(term) {
        totalScore += ScoringWeights.titleBaseScore * ScoringWeights.titleWeight
      }

      // Description: Second most important
      if scenario.description.lowercased().contains(term) {
        totalScore += ScoringWeights.descriptionBaseScore * ScoringWeights.descriptionWeight
      }

      // Mindful approach: Supporting context
      if scenario.mindfulApproach.lowercased().contains(term) {
        totalScore += ScoringWeights.mindfulApproachBaseScore * ScoringWeights.mindfulApproachWeight
      }

      // Practical steps: Actionable content
      if scenario.practicalSteps.joined(separator: " ").lowercased().contains(term) {
        totalScore += ScoringWeights.stepsBaseScore * ScoringWeights.stepsWeight
      }

      // Category: Contextual field
      if scenario.category.lowercased().contains(term) {
        totalScore += ScoringWeights.categoryBaseScore * ScoringWeights.categoryWeight
      }

      // Tags: Indexed keywords
      if scenario.tags.contains(where: { $0.lowercased().contains(term) }) {
        totalScore += ScoringWeights.tagsBaseScore * ScoringWeights.tagsWeight
      }
    }

    // Normalize: Divide by term count to get average relevance per query term
    // This prevents multi-term queries from inflating scores artificially
    let normalizedScore = min(1.0, totalScore / Double(queryTerms.count))

    return normalizedScore
  }

  private func isExpired(_ cache: SearchCache) -> Bool {
    return Date() > cache.expirationDate
  }

  private func cleanExpiredCache() {
    let now = Date()
    searchCache = searchCache.filter { $0.value.expirationDate >= now }
  }

  // MARK: - Cache Management
  func clearCache() {
    searchCache.removeAll()
  }

  func getCacheStats() -> (totalCached: Int, cacheSize: Int) {
    let totalCached = searchCache.count
    let cacheSize = searchCache.values.reduce(0) { $0 + $1.results.count }
    return (totalCached, cacheSize)
  }
}
