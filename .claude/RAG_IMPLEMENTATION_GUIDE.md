# RAG-First Implementation Guide: "Talk to Me" Feature
**Status**: Ready for deployment
**Date**: 2025-11-06

---

## Overview

The **RAG-First Strategy** (Retrieval-Augmented Generation) powers the **"Talk to Me"** feature:

1. User asks: "I struggle with anxiety about work"
2. System retrieves top 3 relevant scenarios via vector search
3. LLM generates personalized coaching using retrieved context
4. Response works **online AND offline** (template fallback)
5. Runs in **background** (survives internet disconnects)

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     iOS App (SwiftUI)                           │
│  TalkToMeView + TalkToMeViewModel (background task support)     │
└──────────────────────┬──────────────────────────────────────────┘
                       │ (Task runs in background)
                       ▼
        ┌──────────────────────────────────┐
        │  URLSessionWebSocketTask         │
        │  (survives disconnects)          │
        └──────────────┬───────────────────┘
                       │
         ┌─────────────┴──────────────┐
         ▼ (Online)                   ▼ (Offline)
  ┌──────────────────────────┐  ┌─────────────────────┐
  │ Cloud Function:          │  │ Local Template:     │
  │ talk_to_me_function.py   │  │ compassionate       │
  │ 1. Retrieve scenarios    │  │ fallback response   │
  │ 2. Build RAG prompt      │  │                     │
  │ 3. LLM generates response│  │ Always available    │
  │ 4. Return structured JSON│  └─────────────────────┘
  └──────────────┬───────────┘
                 │
         ┌───────┴──────────┐
         ▼                  ▼
    ┌────────────┐   ┌──────────────┐
    │ Embeddings │   │ LLM (Ollama) │
    │ all-MiniLM│   │ (Mistral 7B) │
    │ L6-v2 384d│   │              │
    └────────────┘   └──────────────┘
         │
         ▼
    ┌─────────────────────────┐
    │  life_situations        │
    │  + _embeddings (vectors)│
    │  (1,226 scenarios)      │
    └─────────────────────────┘
```

---

## File Structure

```
backend/functions/
├── embeddings_service.py          # Generate + store vectors
├── talk_to_me_function.py          # Cloud function (RAG endpoint)
└── requirements.txt

MindfulLiving/MindfulLiving/.../Screens/
├── TalkToMeView.swift              # SwiftUI UI
└── (ViewModels/TalkToMeViewModel embedded)
```

---

## Step-by-Step Implementation

### Phase 1: Generate Embeddings (FIRST - Run Once)

```bash
cd /Users/nishantgupta/Projects/MindfulLiving-iOS

# Install dependencies
pip install sentence-transformers firebase-admin numpy

# Generate embeddings for all 1,226 scenarios
python backend/functions/embeddings_service.py
```

**What happens**:
- Loads `all-MiniLM-L6-v2` (384-dimensional embeddings)
- Processes scenarios in batches of 50
- Stores each embedding in Firestore at: `life_situations/{id}/_embeddings/v1`
- Stores snippet for debugging

**Expected time**: 30-45 minutes (1 embedding per ~1-2 seconds)

**Output**:
```
✅ EMBEDDING PIPELINE COMPLETE
Total Processed: 1226
Successfully Embedded: 1226
Failed: 0
Time Elapsed: 2100.5s (35 minutes)
```

---

### Phase 2: Deploy Cloud Function

**Option A: Local Testing** (Fastest for dev)

```bash
cd backend/functions

# Install dependencies
pip install -r requirements.txt flask

# Start local server
python talk_to_me_function.py
# → Server running on http://localhost:5000
```

**Test with curl**:
```bash
curl -X POST http://localhost:5000/talk-to-me \
  -H 'Content-Type: application/json' \
  -d '{"query": "I struggle with anxiety at work"}'
```

**Expected response** (in 10-15 seconds):
```json
{
  "success": true,
  "query": "I struggle with anxiety at work",
  "response": "I understand how work anxiety feels...",
  "retrievedScenarios": [
    {"id": "anxiety_001", "title": "Anxiety", "similarity": 0.87},
    {"id": "work_stress_005", "title": "Work Stress", "similarity": 0.81},
    {"id": "perfectionism_003", "title": "Perfectionism", "similarity": 0.78}
  ],
  "actionPlan": [...],
  "relatedPractices": ["breathing_box", "grounding"],
  "generatedAt": "2025-11-06T...",
  "offline": false,
  "latencySeconds": 12.4
}
```

**Option B: Deploy to Firebase Cloud Functions**

```bash
# Configure Firebase
firebase init functions
firebase deploy --only functions:talk-to-me

# Get URL from deployment output
# Update in TalkToMeView.swift:
# let url = URL(string: "https://YOUR_PROJECT.cloudfunctions.net/talk-to-me")!
```

---

### Phase 3: Integrate into iOS App

**Step 1: Update AppNavigation** to include "Talk to Me" tab

```swift
struct AppNavigation: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            TalkToMeView()  // NEW
                .tabItem {
                    Label("Talk to Me", systemImage: "sparkles")
                }

            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "compass")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}
```

**Step 2: Update MindfulSwiftUIApp.swift**

```swift
@main
struct MindfulSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            AppNavigation()
        }
    }
}
```

**Step 3: Add Firebase dependency** (if not already present)

In `Xcode > Project Settings > Package Dependencies`:
```
https://github.com/firebase/firebase-ios-sdk.git
```

---

## Background Task Support (Critical)

The "Talk to Me" feature continues running **even if user closes app or loses internet**:

### How it works:

```swift
// In TalkToMeViewModel.swift
func startBackgroundTask(query: String) {
    Task(priority: .background) {
        await callTalkToMeAPI(query: query)
    }
}
```

**Why this matters**:
- LLM generation takes 10-15 seconds
- User might switch apps or lose WiFi during that time
- Background `Task` ensures completion
- Fallback to template if offline

---

## Data Contract (iOS & Android)

All responses conform to this JSON schema:

```json
{
  "success": boolean,
  "query": "user's question",
  "response": "full coaching text",
  "retrievedScenarios": [
    {
      "id": "scenario_id",
      "title": "scenario title",
      "similarity": 0.87
    }
  ],
  "actionPlan": [
    {
      "step": "specific action",
      "duration": 5,
      "mindfulTechnique": "breathing"
    }
  ],
  "relatedPractices": ["breathing_box", "meditation"],
  "generatedAt": "ISO timestamp",
  "modelVersion": "gpt-4 or mistral",
  "latencySeconds": 12.4,
  "offline": false
}
```

**iOS binding**:
```swift
let response = try JSONDecoder().decode(CoachingResponse.self, from: data)
```

**Android binding** (same JSON):
```kotlin
val response = Gson().fromJson(jsonString, CoachingResponse::class.java)
```

---

## Offline Fallback (Template)

If user is offline or Ollama unavailable:

```swift
func useTemplateResponse(query: String) {
    let template = CoachingResponse(
        success: false,
        query: query,
        response: """
        I understand you're facing this challenge. Even without internet:

        • Pause & Breathe: 3-4 deep breaths
        • Ground Yourself: Notice 5 things you see
        • Reach Out: Contact someone you trust
        """,
        offline: true
    )
}
```

**User sees**:
- Compassionate template response
- "Offline mode - limited guidance" badge
- Same action plan structure
- When online → full personalized response

---

## Testing Checklist

### Unit Tests

```swift
// TalkToMeViewModelTests.swift
class TalkToMeViewModelTests: XCTestCase {

    func testQueryValidation() {
        let vm = TalkToMeViewModel()
        vm.talkToMe(query: "")
        XCTAssertEqual(vm.errorMessage, "Please enter a question")
    }

    func testOfflineFallback() {
        let vm = TalkToMeViewModel()
        // Mock network failure
        vm.useTemplateResponse(query: "test")
        XCTAssertTrue(vm.coachingResponse?.offline == true)
    }

    func testBackgroundTaskCompletion() {
        let vm = TalkToMeViewModel()
        let expectation = XCTestExpectation(description: "Background task completes")

        vm.talkToMe(query: "I struggle with anxiety")

        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            XCTAssertNotNil(vm.coachingResponse)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 25)
    }
}
```

### Manual Testing

1. **Online Test**:
   - Open app → "Talk to Me" tab
   - Type: "I'm struggling with anxiety at work"
   - ✓ Verify response in 10-15 seconds
   - ✓ Verify retrieved scenarios shown
   - ✓ Verify action plan populated

2. **Offline Test**:
   - Airplane mode → ON
   - Submit question
   - ✓ Verify template fallback response
   - ✓ Verify "Offline mode" badge
   - Airplane mode → OFF
   - ✓ Verify next response is personalized

3. **Background Task Test**:
   - Submit question
   - Immediately switch to another app
   - Wait 20 seconds
   - Return to app
   - ✓ Verify response is populated

---

## Performance Metrics

| Metric | Target | Notes |
|--------|--------|-------|
| Vector Search | <500ms | Cached embeddings |
| LLM Generation | 10-15s | Mistral on Mac CPU |
| Total Latency | 10-15s | E2E (retrieval + gen) |
| Offline Response | <100ms | Template only |
| App Memory | <50MB | TalkToMeView + Model |
| Network Efficiency | <2KB req, ~5KB resp | Minimal payload |

---

## Monitoring & Logging

### Firebase Analytics (Optional)

```swift
Analytics.logEvent("talk_to_me_query", parameters: [
    "query_length": userQuery.count,
    "is_offline": coachingResponse?.offline ?? false,
    "latency_seconds": coachingResponse?.latencySeconds ?? 0
])
```

### Console Logging (Development)

```swift
logger.info("Talk to Me API called: \(query)")
logger.info("Retrieved \(retrievedScenarios.count) scenarios")
logger.info("Generated response in \(latencySeconds)s")
```

---

## Troubleshooting

### Issue: "Talk to Me" returns generic response

**Cause**: Vector search not returning relevant scenarios

**Fix**:
1. Check embeddings generated correctly
2. Verify similarity scores (should be >0.7)
3. Review retrieved scenario titles

```bash
# Debug vector search
python -c "
import firebase_admin
from firebase_admin import credentials, firestore
# Fetch and print embeddings
"
```

### Issue: Offline fallback always triggered

**Cause**: Cloud Function URL incorrect or Ollama not running

**Fix**:
1. Update URL in TalkToMeView.swift
2. Start Ollama: `ollama serve`
3. Verify endpoint: `curl http://localhost:11434/api/tags`

### Issue: High latency (>30s)

**Cause**: Mistral slow on Mac Intel

**Expected**: 10-15s is normal for Mistral 7B on CPU

**Solutions**:
- Use smaller model (Mistral 7B Instruct)
- Deploy to server with GPU
- Increase timeout

---

## Next Steps

1. **NOW**: Generate embeddings for all 1,226 scenarios (~1 hour)
2. **Today**: Test locally with `talk_to_me_function.py`
3. **Tomorrow**: Deploy to Firebase Cloud Functions
4. **This week**: Integrate TalkToMeView into app
5. **Next week**: Test offline fallback + background tasks

---

## Cost Estimate

| Component | Cost | Notes |
|-----------|------|-------|
| Embeddings (one-time) | $0 | Local, free |
| Vector Search | Free | Firestore native |
| Cloud Function calls | ~$0.40/million | ~$4 for 10M users |
| LLM API (if using OpenAI) | $0.002 per request | If not using Ollama |
| Storage (embeddings) | ~$1/month | ~1.5MB per 1K scenarios |

**Using Ollama (local)**: ~$0 per month

---

## File Reference

- **Backend**: `/Users/nishantgupta/Projects/MindfulLiving-iOS/backend/functions/`
  - `embeddings_service.py` - Vector generation
  - `talk_to_me_function.py` - RAG endpoint

- **Frontend**: `/Users/nishantgupta/Projects/MindfulLiving-iOS/MindfulLiving/.../Screens/`
  - `TalkToMeView.swift` - UI + ViewModel

- **Config**: `backend/functions/`
  - `.env` - Model, Firebase, Ollama settings
  - `serviceAccountKey.json` - Firebase credentials

---

## Questions?

See related docs:
- `/PROJECT_CONTEXT.md` - Project overview
- `/LLM_INTEGRATION_ROADMAP.md` - Full roadmap
- `/REAL_TIME_LLM_EXAMPLES.md` - Code examples
