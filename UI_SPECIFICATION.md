# UI Specification - Single Source of Truth

**Purpose**: Define all UI requirements once, automatically generate/sync for both SwiftUI and Flutter

---

## Product Manager Input Format

```yaml
screen:
  name: "Screen Name"
  description: "What the screen does"
  platforms: ["ios", "android"]  # or both

sections:
  - id: "section_id"
    title: "Section Title"
    type: "header|card|form|list"
    items:
      - id: "item_1"
        label: "Item Label"
        icon: "icon_name"
        color: "color_name"
        action: "navigation|callback"

colors:
  primary: "lavender"
  secondary: "mintGreen"

typography:
  heading: "28 bold"
  body: "16 regular"
```

---

## Example: Dashboard Screen

```yaml
screen:
  name: "Dashboard"
  id: "dashboard"
  platforms: ["ios", "android"]

sections:
  # Header
  - id: "header"
    type: "header"
    title: "Welcome Back"
    subtitle: "Your daily wellness journey"

  # Wellness Score Card
  - id: "wellness_score"
    type: "card"
    layout: "vertical"
    items:
      - id: "score_title"
        type: "text"
        content: "Wellness Score"
        style: "subtitle"

      - id: "score_value"
        type: "progress_circle"
        value: 72
        max: 100

  # Stats Grid
  - id: "stats_grid"
    type: "grid"
    columns: 2
    items:
      - id: "stat_streak"
        type: "stat_card"
        icon: "flame.fill"
        title: "Streak"
        value: "5 days"
        color: "orange"

      - id: "stat_mood"
        type: "stat_card"
        icon: "heart.fill"
        title: "Mood"
        value: "😊"
        color: "pink"

      - id: "stat_entries"
        type: "stat_card"
        icon: "book.fill"
        title: "Entries"
        value: "12"
        color: "blue"

      - id: "stat_practices"
        type: "stat_card"
        icon: "sparkles"
        title: "Practices"
        value: "8"
        color: "purple"

  # Quick Actions
  - id: "quick_actions"
    type: "horizontal_scroll"
    title: "Quick Actions"
    items:
      - id: "action_journal"
        type: "action_button"
        icon: "book"
        label: "Journal"
        color: "blue"

      - id: "action_breathe"
        type: "action_button"
        icon: "wind"
        label: "Breathe"
        color: "lavender"

      - id: "action_meditate"
        type: "action_button"
        icon: "moon.stars"
        label: "Meditate"
        color: "purple"

colors_used: ["lavender", "orange", "pink", "blue", "purple", "mintGreen"]
typography_used: ["heading_large", "heading_small", "body_regular", "caption"]
```

---

## Component Library

### 1. Stat Card
**Props**:
- icon: String
- title: String
- value: String
- color: Color

**SwiftUI Implementation**: `StatCard.swift`
**Flutter Implementation**: `stat_card_widget.dart`

---

### 2. Wellness Score Circle
**Props**:
- value: Double (0-100)
- color: Color

**SwiftUI**: Circular progress indicator
**Flutter**: Flutter CircularProgressIndicator

---

### 3. Action Button
**Props**:
- icon: String
- label: String
- color: Color
- onTap: Callback

**SwiftUI**: VStack with Image + Text
**Flutter**: Card + InkWell

---

## Sync Rules

1. **If PM changes Dashboard colors from "lavender" → "deepPurple"**:
   - SwiftUI: Update `Color.lavender` reference
   - Flutter: Update `AppColors.lavender` reference
   - AUTOMATIC: Agent applies to both

2. **If PM adds new section "Health Metrics"**:
   - Agent generates SwiftUI component
   - Agent generates Flutter widget
   - Both use same data structure

3. **If PM changes typography (e.g., heading: 28 bold → 32 bold)**:
   - Updates all occurrences in both platforms
   - Consistent across apps

---

## Using the Agent System

### Input from PM:
```
Update Dashboard:
- Add wellness tips section after wellness score
- Show rotating tips every 24 hours
- Display as card with lightbulb icon
- Color: "teal"
- Typography: "body_small italic"
```

### Agent Automatically:
1. ✅ Creates SwiftUI view for tips
2. ✅ Creates Flutter widget for tips
3. ✅ Adds data structure to both ViewModels
4. ✅ Runs code analysis on both
5. ✅ Ensures no duplication
6. ✅ Tests on simulators

---

## Benefits

✅ Single source of truth
✅ No manual sync required
✅ Consistent across platforms
✅ PM doesn't need code knowledge
✅ Automatic code generation
✅ Both UIs always in sync

