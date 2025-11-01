# iOS Standalone SwiftUI Project Setup

Since you already have Flutter project, here's how to create a **separate iOS-only project** that won't interfere with your Flutter setup.

---

## Option B - RECOMMENDED: Create Separate iOS Project

### Step 1: Create New Directory
```bash
# Create NEW folder outside your Flutter project
mkdir -p ~/Projects/MindfulLiving-iOS
cd ~/Projects/MindfulLiving-iOS
```

### Step 2: Clone the iOS Branch
```bash
# Clone the feature/ios-swiftui branch
git clone --branch feature/ios-swiftui https://github.com/nishantgupta83/mindful-living.git .

# This extracts ONLY the SwiftUI files
```

### Step 3: Create Xcode Project Structure
```bash
# Create project directories
mkdir -p MindfulLiving/MindfulLiving
mkdir -p MindfulLiving/MindfulLivingTests

# Copy SwiftUI files
cp ios/MindfulSwiftUI/* MindfulLiving/MindfulLiving/

# Create empty test file
touch MindfulLiving/MindfulLivingTests/MindfulLivingTests.swift
```

### Step 4: Create Xcode Project Manually (2 minutes)

Since Xcode doesn't support full CLI project creation, do this in GUI:

1. **Open Xcode**
   ```bash
   open /Applications/Xcode.app
   ```

2. **File → New → Project**

3. **Choose iOS → App**

4. **Fill in project details:**
   - Product Name: `MindfulLiving`
   - Team: `None` (or your team)
   - Organization Identifier: `com.hub4apps`
   - Language: `Swift`
   - Interface: `SwiftUI`
   - Storage: `None`

5. **Choose location:** `~/Projects/MindfulLiving-iOS`

6. **Create!**

### Step 5: Add SwiftUI Files to Xcode

1. **In Xcode, right-click on Project → Add Files to Project**

2. **Navigate to:** `ios/MindfulSwiftUI/` folder

3. **Select all files:**
   - MindfulSwiftUIApp.swift
   - Screens/ folder (all 8 files)
   - ViewModels/ folder (all 4 files)
   - Managers/ folder (AuthManager.swift)

4. **Check "Copy items if needed"**

5. **Make sure target is selected: MindfulLiving**

6. **Click Add**

### Step 6: Run on Simulator

```bash
# In Xcode:
# Product → Destination → iPhone 16 Pro Max
# Product → Run (⌘R)
```

---

## Why This Approach Works

✅ **Separate from Flutter project** - No conflicts, both work independently
✅ **Uses your existing Xcode** - Same simulator setup
✅ **Clean project structure** - Easy to maintain
✅ **Production-ready** - Can deploy to App Store from this project
✅ **Easy to extend** - Add Firebase, features, etc.

---

## Project Structure After Setup

```
~/Projects/MindfulLiving-iOS/
├── MindfulLiving/                          (Xcode project)
│   ├── MindfulLiving/                      (Source code)
│   │   ├── MindfulLivingApp.swift
│   │   ├── Screens/
│   │   │   ├── DashboardView.swift
│   │   │   ├── ExploreView.swift
│   │   │   ├── DilemmaDetailView.swift
│   │   │   ├── JournalView.swift
│   │   │   ├── PracticesView.swift
│   │   │   ├── ProfileView.swift
│   │   │   └── LoginView.swift
│   │   ├── ViewModels/
│   │   │   ├── DashboardViewModel.swift
│   │   │   ├── ExploreViewModel.swift
│   │   │   ├── JournalViewModel.swift
│   │   │   └── PracticesViewModel.swift
│   │   └── Managers/
│   │       └── AuthManager.swift
│   ├── MindfulLivingTests/
│   ├── MindfulLiving.xcodeproj/
│   └── MindfulLiving.xcworkspace/
│
└── ios/                                    (Cloned from GitHub)
    └── MindfulSwiftUI/                     (Original files)
```

---

## Differences from Flutter Project

| Aspect | Flutter (Existing) | iOS SwiftUI (New) |
|--------|-------------------|--------------------|
| **Location** | `~/Documents/MindfulLiving/app` | `~/Projects/MindfulLiving-iOS` |
| **Language** | Dart | Swift |
| **Target** | iOS + Android | iOS only |
| **Run Command** | `flutter run` | Xcode (⌘R) |
| **Simulator** | Flutter emulator | Same iOS simulator |
| **Database** | Firebase (Dart) | Firebase (Swift) |
| **Status** | Production ready | Ready to test |

---

## Running Both Projects

### Option 1: Side by Side
```bash
# Terminal 1: Flutter project
cd ~/Documents/MindfulLiving/app
flutter run

# Terminal 2: iOS project (Xcode)
cd ~/Projects/MindfulLiving-iOS
open MindfulLiving.xcodeproj
# Then Product → Run
```

### Option 2: Switch between them
```bash
# Test iOS app
cd ~/Projects/MindfulLiving-iOS
open MindfulLiving.xcodeproj

# Later, test Flutter app
cd ~/Documents/MindfulLiving/app
flutter run
```

### Option 3: Use same simulator
```bash
# Both use iPhone 16 Pro Max simulator
# Just don't run both at the same time

# Run iOS app first
xcode: Product → Run

# Kill simulator when done
xcrun simctl shutdown all

# Then run Flutter app
flutter run
```

---

## Quick Setup Script (Automate Steps 1-5)

Save as `setup_ios_project.sh`:

```bash
#!/bin/bash

set -e

echo "🍎 Setting up iOS SwiftUI Project..."

# Step 1: Create directory
PROJECT_DIR="$HOME/Projects/MindfulLiving-iOS"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Step 2: Clone iOS branch
echo "Cloning feature/ios-swiftui..."
git clone --branch feature/ios-swiftui https://github.com/nishantgupta83/mindful-living.git temp-clone

# Step 3: Create directory structure
mkdir -p MindfulLiving/MindfulLiving
mkdir -p MindfulLiving/MindfulLivingTests

# Step 4: Copy files
echo "Copying SwiftUI files..."
cp -r temp-clone/ios/MindfulSwiftUI/* MindfulLiving/MindfulLiving/
cp temp-clone/ios/Runner/Assets.xcassets MindfulLiving/MindfulLiving/ 2>/dev/null || true

# Cleanup
rm -rf temp-clone

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. open /Applications/Xcode.app"
echo "2. File → New → Project → iOS App"
echo "3. Product Name: MindfulLiving"
echo "4. Language: Swift, Interface: SwiftUI"
echo "5. Location: $PROJECT_DIR"
echo "6. Right-click project → Add Files"
echo "7. Select MindfulLiving/MindfulLiving folder"
echo "8. Product → Run (⌘R)"
```

Run it:
```bash
chmod +x setup_ios_project.sh
./setup_ios_project.sh
```

---

## Testing Both Versions

### Flutter Version (Existing)
```bash
cd ~/Documents/MindfulLiving/app
flutter run -d "iPhone 16 Pro Max"
```

### iOS SwiftUI Version (New)
```bash
cd ~/Projects/MindfulLiving-iOS
open MindfulLiving.xcodeproj
# Then ⌘R in Xcode
```

---

## Comparing Both Implementations

| Feature | Flutter | SwiftUI |
|---------|---------|---------|
| **Code Size** | ~931 lines | ~1,645 lines |
| **Architecture** | MVVM + Riverpod | MVVM + @StateObject |
| **Firebase** | Integrated | Ready (dummy data) |
| **UI Framework** | Material 3 | SwiftUI + iOS HIG |
| **Performance** | Excellent | Excellent |
| **Development Speed** | Fast (hot reload) | Medium (compile) |
| **Code Maturity** | Production ready | Ready to test |

---

## Switching Project in Xcode

If you had Flutter's iOS project open, here's how to switch:

1. **Close Flutter iOS project**
   ```bash
   # Or just close Xcode window
   ```

2. **Open SwiftUI iOS project**
   ```bash
   open ~/Projects/MindfulLiving-iOS/MindfulLiving.xcodeproj
   ```

3. **Select simulator**
   - Product → Destination → iPhone 16 Pro Max

4. **Run**
   - Product → Run (⌘R)

---

## Using Xcode Workspaces (Advanced)

If you want both projects in one Xcode window:

```bash
# Create workspace
cd ~/Projects/MindfulLiving-iOS
xcodebuild -scheme MindfulLiving -workspace MindfulLiving.xcworkspace
```

But simpler approach: **Keep them separate** (easier to manage)

---

## Summary

### For Option B (Full Testing):

1. **Create separate directory:** `~/Projects/MindfulLiving-iOS`
2. **Use Xcode GUI:** File → New → Project
3. **Copy SwiftUI files** into Xcode project
4. **Run on simulator:** Product → Run (⌘R)

### Key Benefits:
✅ Separate from Flutter project
✅ No conflicts or interference
✅ Clean, isolated codebase
✅ Easy to deploy to App Store
✅ Can work on both in parallel

### Time Required:
- With script: 2 minutes
- Without script: 10 minutes

Ready? Let's go! 🚀
