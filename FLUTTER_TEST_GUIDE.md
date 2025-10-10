# 🧪 Flutter Firebase Testing Guide

## Quick Start

### 1. Get Dependencies
```bash
cd /Users/nishantgupta/Documents/MindfulLiving/app
flutter pub get
```

### 2. Run the App
```bash
# For iOS Simulator
flutter run -d iPhone

# For Android Emulator  
flutter run -d emulator-5554

# For any connected device
flutter run
```

### 3. What You'll See

The app will launch with the **Firebase Test Screen** that:
- ✅ Connects to Firestore
- ✅ Shows total situations count from metadata
- ✅ Displays first 10 situations
- ✅ Tests different queries (wellness, voice keywords, difficulty)

## Expected Output

### Console
```
✅ Firebase initialized successfully
Connecting to Firestore...
Connected! Found 1226 situations in database
✅ Success! Loaded 10 situations
```

### Screen Display
- **Status Card** (green): "✅ Success! Loaded 10 situations"
- **List of 10 situations** with:
  - Title
  - Description
  - Life area chip (wellness, career, etc.)
  - Difficulty chip (beginner, intermediate, advanced)

### Test Buttons
1. **Test: Query Wellness Situations** - Shows count of wellness situations
2. **Test: Search by Voice Keywords** - Searches for "stress" keyword
3. **Test: Filter by Difficulty** - Shows beginner-level situations

## Troubleshooting

### Issue: Firebase not initialized
**Error:** `Firebase has not been initialized`

**Fix:**
```bash
# Regenerate Firebase options
flutterfire configure --project=hub4apps-mindfulliving
```

### Issue: Firestore permission denied
**Error:** `PERMISSION_DENIED: Missing or insufficient permissions`

**Fix:** Security rules already deployed ✅ (should not happen)

### Issue: No data showing
**Check:**
1. Internet connection
2. Firebase Console: https://console.firebase.google.com/u/0/project/hub4apps-mindfulliving/firestore
3. Verify 1,226 documents exist in `life_situations` collection

### Issue: Index required
**Error:** `The query requires an index`

**Fix:** Click the provided link in error message → Firebase creates index automatically

## Test Queries You Can Try

### Basic Query
```dart
final situations = await FirebaseFirestore.instance
    .collection('life_situations')
    .limit(10)
    .get();
```

### Filter by Life Area
```dart
final wellness = await FirebaseFirestore.instance
    .collection('life_situations')
    .where('lifeArea', isEqualTo: 'wellness')
    .limit(10)
    .get();
```

### Search by Voice Keywords
```dart
final stress = await FirebaseFirestore.instance
    .collection('life_situations')
    .where('voiceKeywords', arrayContains: 'stress')
    .limit(5)
    .get();
```

### Filter by Difficulty
```dart
final beginner = await FirebaseFirestore.instance
    .collection('life_situations')
    .where('difficulty', isEqualTo: 'beginner')
    .limit(20)
    .get();
```

### Combined Query
```dart
final wellnessBeginner = await FirebaseFirestore.instance
    .collection('life_situations')
    .where('lifeArea', isEqualTo: 'wellness')
    .where('difficulty', isEqualTo: 'beginner')
    .where('isActive', isEqualTo: true)
    .limit(10)
    .get();
```

## Restore Normal App Flow

When testing is complete, edit `lib/app/app.dart`:

```dart
home: const AndroidOptimizedWrapper(
  // child: FirebaseTestScreen(), // Comment this out
  child: LoginPage(), // Uncomment this
),
```

## Next Steps After Successful Test

1. ✅ Verify all queries work
2. ✅ Check console for no errors
3. ✅ Test on both iOS and Android
4. ✅ Deploy Alexa skill: `cd scripts && npm run deploy-alexa`
5. ✅ Deploy Apple Watch: `cd scripts && npm run deploy-watch`

## Success Criteria

- [ ] App launches without errors
- [ ] Firebase initialized message in console
- [ ] Test screen shows "✅ Success! Loaded 10 situations"
- [ ] 10 situations displayed with titles and descriptions
- [ ] All 3 test buttons work and show results
- [ ] No religious content visible (Krishna, Gita, etc.)
- [ ] Life area colors match: wellness=green, relationships=pink, career=blue

---

**You're ready to test!** 🚀

Run: `flutter pub get && flutter run`
