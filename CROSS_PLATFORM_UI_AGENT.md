# Cross-Platform UI Agent System

## Purpose
Ensure UI requirements are implemented consistently across SwiftUI (iOS) and Flutter (Android) with a single specification.

---

## How It Works

### 1. PM Submits Requirement
```
Input: "Add wellness tips carousel on Dashboard that rotates daily"
```

### 2. Agent Processes Requirement
The agent:
- ✅ Analyzes requirement
- ✅ Generates SwiftUI component
- ✅ Generates Flutter widget
- ✅ Creates shared data models
- ✅ Runs code analysis on both
- ✅ Ensures succinctness
- ✅ Tests on simulators

### 3. Both UIs Update Automatically
```
SwiftUI/Screens/DashboardView.swift - Updated
Flutter/lib/features/dashboard/presentation/pages/dashboard_page.dart - Updated
Both use same specs, different implementations
```

---

## File Structure

```
ios/MindfulSwiftUI/
├── Screens/          # SwiftUI Views
├── ViewModels/       # State management
└── Managers/         # Services

lib/features/dashboard/  # Flutter
├── presentation/      # UI layer
├── domain/           # Business logic
└── data/             # Data sources

UI_SPECIFICATION.md   # Single source of truth
CROSS_PLATFORM_UI_AGENT.md  # This file
```

---

## PM Commands

### Add Component
```
SPEC: Add new component
Name: Wellness Tips
Type: Card with carousel
Platform: Both (iOS + Android)
Location: Dashboard (after wellness score)
Data: { tips: [String], color: "teal", rotateInterval: 24h }
```

**Agent handles**:
- SwiftUI: TabView + ForEach
- Flutter: PageView + List
- Shared: TipsViewModel + TipsModel

### Update Component
```
SPEC: Update Wellness Tips styling
Changes:
- Color: teal → indigo
- CardRadius: 12 → 16
- Typography: body_small → body_regular
```

**Agent handles**:
- Finds all references in both codebases
- Updates Color definitions
- Updates CardTheme properties
- Runs analysis on both
- No manual sync needed

### Remove Component
```
SPEC: Remove Wellness Tips section
Reason: Consolidating into wellness score card
```

**Agent handles**:
- Removes from both UIs
- Removes ViewModels
- Removes data models
- Cleans up imports
- Verifies no broken references

---

## Real Example: Add Wellness Tips

### 1. PM Input
```
Add wellness tips carousel:
- Display random wellness tip
- Rotate every 24 hours
- Location: Dashboard, after wellness score
- Icon: lightbulb.fill
- Color: teal
```

### 2. Agent Creates SwiftUI View
```swift
// ios/MindfulSwiftUI/Screens/Components/WellnessTipsView.swift

struct WellnessTipsView: View {
  let tips: [String]
  let color: Color = .teal
  @State private var currentTipIndex = 0

  var body: some View {
    TabView(selection: $currentTipIndex) {
      ForEach(Array(tips.enumerated()), id: \.offset) { index, tip in
        VStack(spacing: 12) {
          Image(systemName: "lightbulb.fill")
            .font(.system(size: 28))
            .foregroundColor(color)
          Text(tip)
            .font(.system(size: 14))
        }
        .tag(index)
      }
    }
    .onAppear { startRotation() }
  }

  private func startRotation() {
    Timer.scheduledTimer(withTimeInterval: 86400, repeats: true) { _ in
      currentTipIndex = (currentTipIndex + 1) % tips.count
    }
  }
}
```

### 3. Agent Creates Flutter Widget
```dart
// lib/features/dashboard/presentation/widgets/wellness_tips_widget.dart

class WellnessTipsWidget extends StatefulWidget {
  final List<String> tips;

  const WellnessTipsWidget({required this.tips});

  @override
  State<WellnessTipsWidget> createState() => _WellnessTipsWidgetState();
}

class _WellnessTipsWidgetState extends State<WellnessTipsWidget> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startRotation();
  }

  void _startRotation() {
    Timer.periodic(Duration(hours: 24), (_) {
      _currentIndex = (_currentIndex + 1) % widget.tips.length;
      _pageController.animateToPage(_currentIndex, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Icon(Icons.lightbulb, color: AppColors.teal),
          PageView(
            controller: _pageController,
            children: widget.tips.map((tip) => Text(tip)).toList(),
          ),
        ],
      ),
    );
  }
}
```

### 4. Agent Creates Shared Data Model
```dart
// lib/shared/models/wellness_tip.dart

class WellnessTip {
  final String content;
  final String category;
  final DateTime createdAt;

  WellnessTip({
    required this.content,
    required this.category,
    required this.createdAt,
  });
}
```

### 5. Agent Updates Both ViewModels
```swift
// SwiftUI
@Published var wellnessTips: [String] = []

private func loadTips() {
  // Load tips from Firebase
}
```

```dart
// Flutter
@observable
ObservableList<String> wellnessTips = ObservableList();

Future<void> loadTips() async {
  // Load tips from Firebase
}
```

### 6. Agent Runs Analysis
- ✅ No unused imports
- ✅ No unused variables
- ✅ Consistent naming
- ✅ Proper error handling
- ✅ Succinctness check

---

## Implementation Rules

### Naming Convention
- **SwiftUI**: CamelCase (e.g., `WellnessTipsView`)
- **Flutter**: snake_case (e.g., `wellness_tips_widget.dart`)
- **Shared Models**: CamelCase (e.g., `WellnessTip.swift` / `wellness_tip.dart`)

### Color Management
- **SwiftUI**: `Color.teal` in extensions
- **Flutter**: `AppColors.teal` in constants
- **Agent**: Maps PM color names to both

### Typography
- **SwiftUI**: `.system(size: X, weight: .Y)`
- **Flutter**: `TextStyle(fontSize: X, fontWeight: FontWeight.Y)`
- **Agent**: Converts between systems

### Layout
- **SwiftUI**: VStack/HStack with spacing
- **Flutter**: Column/Row with SizedBox
- **Agent**: Maintains visual parity

---

## Validation Rules

Agent ensures:
1. ✅ Both UIs have identical functionality
2. ✅ Same data structures
3. ✅ Visual consistency (colors, spacing, typography)
4. ✅ No code duplication
5. ✅ Proper error handling
6. ✅ Accessible (a11y labels)
7. ✅ Performance optimized
8. ✅ Succinctness (no verbosity)

---

## Quick Start for PM

### To Add a Feature:
1. Write SPEC in `UI_SPECIFICATION.md`
2. Tag with `@agent-implement`
3. Agent automatically:
   - Generates SwiftUI code
   - Generates Flutter code
   - Updates both apps
   - Tests on simulators
   - Runs code analysis

### To Update Styling:
1. Update color/typography in `UI_SPECIFICATION.md`
2. Agent finds all references
3. Updates both codebases
4. Verifies consistency

### To Remove Feature:
1. Update `UI_SPECIFICATION.md` (delete section)
2. Agent removes from both platforms
3. Cleans up unused code
4. Verifies no broken links

---

## Example: Quick Update

**PM says**: "Change Dashboard header from 'Welcome Back' to 'Your Wellness Journey'"

**Agent automatically**:
```swift
// SwiftUI - Updates
- Text("Your Wellness Journey")

// Flutter - Updates
- Text('Your Wellness Journey')

// Both updated in <30 seconds
```

---

## Status

✅ Cross-platform UI agent system ready
✅ SwiftUI fully implemented
✅ Flutter implementation compatible
✅ Single spec system in place
✅ Ready for PM requirements

