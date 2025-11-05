# iOS Project Setup - Continue Here

Xcode has been opened. Follow these steps to complete the project setup:

## Step 1: Create New Xcode Project

In Xcode menu:
```
File → New → Project
```

## Step 2: Select iOS App Template

1. Click on **iOS**
2. Select **App**
3. Click **Next**

## Step 3: Configure Project

Fill in these values exactly:

| Field | Value |
|-------|-------|
| Product Name | `MindfulLiving` |
| Team | `None` (or select your team) |
| Organization Identifier | `com.hub4apps` |
| Language | `Swift` |
| Interface | `SwiftUI` |
| Use Core Data | `No` |
| Include Tests | `No` |

Click **Next**

## Step 4: Choose Save Location

**IMPORTANT**: Choose this location:
```
~/Projects/MindfulLiving-iOS
```

The path should show: `/Users/nishantgupta/Projects/MindfulLiving-iOS`

Click **Create**

## Step 5: Wait for Project Creation

Xcode will create the project and open it. This takes 30-60 seconds.

## Step 6: Add SwiftUI Files to Project

Once project is open:

1. In Xcode's left sidebar, right-click on **MindfulLiving** folder
2. Select **Add Files to "MindfulLiving"...**
3. Navigate to: `~/Projects/MindfulLiving-iOS/MindfulLiving/MindfulLiving/`
4. You should see these folders:
   - ✓ Managers/
   - ✓ Screens/
   - ✓ ViewModels/
   - ✓ MindfulSwiftUIApp.swift

5. **Important**: Check these options:
   - ✓ Copy items if needed
   - ✓ Create groups (not folders)
   - ✓ Add to target: MindfulLiving

6. Click **Add**

## Step 7: Replace Default App Entry Point

1. In the left sidebar, find **MindfulLivingApp.swift** (the one Xcode created)
2. **Delete it** (right-click → Delete)
3. When asked "Remove Reference" or "Delete", choose **Delete**

This prevents conflicts with our `MindfulSwiftUIApp.swift`

## Step 8: Select Simulator and Run

1. In the top center, click on **MindfulLiving** next to the play button
2. Select **iPhone 16 Pro Max**
3. Click the **Play** button (⌘R)

## Step 9: Watch App Build and Launch

Expected time: 1-3 minutes for first build

You should see:
- ✓ App compiling in the status bar
- ✓ Simulator launching
- ✓ Dashboard screen appearing with:
  - Wellness score circle (72%)
  - 4 stat cards (Streak, Mood, Entries, Practices)
  - Quick action buttons

## 🎉 Success Indicators

App is working when you see:

✓ **Dashboard**: Purple background with wellness score circle
✓ **Tab Bar**: 6 tabs at bottom (Dashboard, Explore, Journal, Practices, Profile, Settings)
✓ **Navigation**: Can tap between tabs and screens
✓ **No Errors**: Console shows no red errors

## 🧪 Quick Test

Try these interactions:

1. Tap **Explore** tab → See list of dilemmas
2. Tap a dilemma card → Go to Detail view
3. Tap **Journal** tab → Create new entry
4. Tap **Practices** tab → See 4 colored cards
5. Tap **Profile** tab → See settings

All should work smoothly!

## ⚠️ Common Issues

### "MindfulSwiftUIApp.swift not found"
- Make sure you added files from `~/Projects/MindfulLiving-iOS/MindfulLiving/MindfulLiving/`
- The folder names might be confusing, but that's the right path

### "Build fails"
- Clean build: Press ⇧⌘K
- Try building again: ⌘B

### "Simulator doesn't launch"
- Restart simulator: `xcrun simctl shutdown all`
- Then try running again

### "Buttons don't work"
- This is normal! They're placeholders
- Navigation between main screens works fine

## 📱 Next: Full Testing

Once app is running, follow the testing checklist in:
```
~/Documents/MindfulLiving/app/QUICK_TEST_SWIFTUI.md
```

Test all 6 screens:
- [ ] Dashboard
- [ ] Explore
- [ ] Dilemma Detail
- [ ] Journal
- [ ] Practices
- [ ] Profile

## 💾 Verify Files Are in Place

If build fails, verify files are copied. Run in terminal:
```bash
ls -la ~/Projects/MindfulLiving-iOS/MindfulLiving/MindfulLiving/
```

Should show:
```
total 8
drwxr-xr-x  6 user  staff   192 Oct 31 18:33 .
drwxr-xr-x  4 user  staff   128 Oct 31 18:33 ..
drwxr-xr-x  3 user  staff    96 Oct 31 18:33 Managers
-rw-r--r--  1 user  staff  2366 Oct 31 18:33 MindfulSwiftUIApp.swift
drwxr-xr-x  9 user  staff   288 Oct 31 18:33 Screens
drwxr-xr-x  6 user  staff   192 Oct 31 18:33 ViewModels
```

If these are missing, copy them:
```bash
cp -r ~/Projects/MindfulLiving-iOS/ios/MindfulSwiftUI/* \
      ~/Projects/MindfulLiving-iOS/MindfulLiving/MindfulLiving/
```

## 🎯 After Testing Works

1. Take screenshots of each screen
2. Verify colors match (purple/green)
3. Confirm all navigation works
4. Check console for any warnings

Then proceed to Firebase integration phase.

---

**Questions?** See:
- `~/Documents/MindfulLiving/app/iOS_QUICK_START.txt` - Quick reference
- `~/Documents/MindfulLiving/app/QUICK_TEST_SWIFTUI.md` - Testing guide
- `~/Documents/MindfulLiving/app/IOS_STANDALONE_PROJECT.md` - Full setup guide
