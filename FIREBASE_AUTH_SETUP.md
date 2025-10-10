# Firebase Authentication Setup Guide
## Mindful Living App

**Last Updated:** 2025-10-10
**Purpose:** Configure Firebase Authentication providers for production deployment

---

## 📋 OVERVIEW

This guide provides step-by-step instructions to configure Firebase Authentication providers:
- ✅ Email/Password Authentication
- ✅ Google Sign-In (OAuth 2.0)
- ✅ Apple Sign-In (iOS/macOS)
- ✅ Anonymous Authentication (Guest Mode)

---

## 🔧 PREREQUISITES

### **1. Firebase Project**
- Project ID: `hub4apps-mindfulliving`
- Firebase Console: https://console.firebase.google.com

### **2. Required Access**
- Owner or Editor role in Firebase project
- Admin access to Google Cloud Console
- Apple Developer Account (for Apple Sign-In)

### **3. Local Setup Complete**
- ✅ FlutterFire configured: `lib/firebase_options.dart` exists
- ✅ GoogleService-Info.plist (iOS): `ios/Runner/GoogleService-Info.plist`
- ✅ google-services.json (Android): `android/app/google-services.json`

---

## 🎯 STEP 1: ENABLE AUTHENTICATION PROVIDERS

### **1.1. Access Firebase Console**
```bash
# Open Firebase Console
https://console.firebase.google.com/project/hub4apps-mindfulliving/authentication/providers
```

### **1.2. Enable Email/Password Provider**

1. Navigate to **Authentication** > **Sign-in method**
2. Click on **Email/Password**
3. Toggle **Enable** switch to ON
4. Toggle **Email link (passwordless sign-in)** to OFF (we use password-based)
5. Click **Save**

✅ **Email/Password authentication is now enabled**

---

### **1.3. Enable Anonymous Provider (Guest Mode)**

1. In **Sign-in method** tab
2. Click on **Anonymous**
3. Toggle **Enable** switch to ON
4. Click **Save**

✅ **Anonymous authentication is now enabled**

---

### **1.4. Enable Google Sign-In Provider**

1. In **Sign-in method** tab
2. Click on **Google**
3. Toggle **Enable** switch to ON
4. **Support email**: Enter your project support email (e.g., `nishantgupta83@gmail.com`)
5. Click **Save**

✅ **Google Sign-In is now enabled in Firebase**

**Next:** Configure OAuth consent screen (see Step 2)

---

### **1.5. Enable Apple Sign-In Provider**

1. In **Sign-in method** tab
2. Click on **Apple**
3. Toggle **Enable** switch to ON
4. Click **Save**

✅ **Apple Sign-In is now enabled in Firebase**

**Next:** Configure Apple Developer account (see Step 3)

---

## 🌐 STEP 2: CONFIGURE GOOGLE SIGN-IN

### **2.1. Android Configuration**

#### **A. Add SHA-1 Fingerprint to Firebase**

**Debug SHA-1 (for testing):**
```bash
# Get debug SHA-1 fingerprint
cd android
./gradlew signingReport

# Copy the SHA-1 fingerprint from the output
# Example: SHA1: A1:B2:C3:D4:E5:F6:G7:H8:I9:J0:K1:L2:M3:N4:O5:P6:Q7:R8:S9:T0
```

**Add to Firebase:**
1. Firebase Console > Project Settings
2. Scroll to **Your apps** section
3. Select your Android app
4. Click **Add fingerprint**
5. Paste the SHA-1 fingerprint
6. Click **Save**

**Production SHA-1 (for Play Store):**
```bash
# Generate release keystore if not exists
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Get release SHA-1 fingerprint
keytool -list -v -keystore ~/upload-keystore.jks -alias upload

# Add to Firebase (same steps as above)
```

#### **B. Download Updated google-services.json**
1. Firebase Console > Project Settings
2. Scroll to **Your apps** > Android app
3. Click **Download google-services.json**
4. Replace `android/app/google-services.json`

---

### **2.2. iOS Configuration**

#### **A. Download Updated GoogleService-Info.plist**
1. Firebase Console > Project Settings
2. Scroll to **Your apps** > iOS app
3. Click **Download GoogleService-Info.plist**
4. Replace `ios/Runner/GoogleService-Info.plist`

#### **B. Add URL Scheme to Info.plist**
1. Open `ios/Runner/Info.plist`
2. Add the following (replace REVERSED_CLIENT_ID from GoogleService-Info.plist):

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Replace with REVERSED_CLIENT_ID from GoogleService-Info.plist -->
            <string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

**How to find REVERSED_CLIENT_ID:**
```bash
# Open GoogleService-Info.plist and look for:
<key>REVERSED_CLIENT_ID</key>
<string>com.googleusercontent.apps.123456789-abc...</string>
```

---

### **2.3. Configure OAuth Consent Screen (Google Cloud Console)**

1. **Open Google Cloud Console:**
   ```
   https://console.cloud.google.com/apis/credentials/consent
   ```

2. **Select Project:** `hub4apps-mindfulliving`

3. **Configure Consent Screen:**
   - **User Type:** External
   - **App name:** Mindful Living
   - **User support email:** Your email
   - **App logo:** Upload app icon (512x512 PNG)
   - **Application home page:** (Your website or app store link)
   - **Privacy policy link:** (Required before production)
   - **Terms of service link:** (Optional)

4. **Scopes:**
   - Add scopes: `email`, `profile`
   - No sensitive scopes needed

5. **Test users (while in testing mode):**
   - Add your email for testing
   - Add team members' emails

6. **Verification Status:**
   - **Testing mode:** Available immediately (max 100 users)
   - **Production mode:** Requires Google verification (submit when ready)

---

### **2.4. Test Google Sign-In**

**Android:**
```bash
# Run on physical device or emulator
flutter run -d <device-id>

# Test Google Sign-In:
# 1. Tap "Google" button on login screen
# 2. Select Google account
# 3. Grant permissions
# 4. Verify user is logged in
```

**iOS:**
```bash
# Run on iOS Simulator or physical device
flutter run -d <device-id>

# Test Google Sign-In (same steps as Android)
```

**Troubleshooting:**
- **Error:** "Sign-in failed: PlatformException(sign_in_failed...)"
  - **Fix:** Verify SHA-1 fingerprint is correct
  - **Fix:** Download latest google-services.json
  - **Fix:** Run `flutter clean && flutter pub get`

- **Error:** "Developer Error" on Android
  - **Fix:** SHA-1 fingerprint not added to Firebase
  - **Fix:** Incorrect package name in Firebase

---

## 🍎 STEP 3: CONFIGURE APPLE SIGN-IN

### **3.1. Apple Developer Account Setup**

#### **A. Create App ID with Sign in with Apple Capability**

1. **Open Apple Developer Portal:**
   ```
   https://developer.apple.com/account/resources/identifiers/list
   ```

2. **Create/Edit App ID:**
   - **Description:** Mindful Living
   - **Bundle ID:** `com.hub4apps.mindfulliving` (must match your app)
   - **Capabilities:** Check ✅ **Sign in with Apple**
   - Click **Save**

#### **B. Create Service ID (for Web/Android if needed)**

1. In **Identifiers** section
2. Click **+** > **Services IDs**
3. **Description:** Mindful Living Sign In
4. **Identifier:** `com.hub4apps.mindfulliving.signin`
5. Check **Sign in with Apple**
6. Configure:
   - **Primary App ID:** Select your app ID
   - **Web Authentication Configuration:**
     - **Domains:** (Your website domain if applicable)
     - **Return URLs:** (Firebase redirect URL)
7. Click **Save**

---

### **3.2. iOS/macOS Configuration**

#### **A. Enable Sign in with Apple in Xcode**

1. **Open iOS project in Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Select Runner target**

3. **Signing & Capabilities tab:**
   - Click **+ Capability**
   - Add **Sign in with Apple**
   - Verify capability is added

4. **Build Settings:**
   - Ensure **Bundle Identifier** matches: `com.hub4apps.mindfulliving`

#### **B. Update Info.plist (if needed)**

Already configured via `sign_in_with_apple` package, but verify:

```xml
<key>UIApplicationSceneManifest</key>
<dict>
    <key>UIApplicationSupportsMultipleScenes</key>
    <false/>
</dict>
```

---

### **3.3. Configure Firebase for Apple Sign-In**

1. **Get Apple Service ID Details:**
   - From Apple Developer Portal, copy **Service ID**
   - Example: `com.hub4apps.mindfulliving.signin`

2. **Firebase Console Configuration:**
   - Authentication > Sign-in method > Apple
   - **Service ID:** (Leave blank for iOS-only)
   - **Team ID:** Find in Apple Developer Account (top-right corner)
   - **Key ID & Private Key:** (Required for web, optional for iOS)

**To get Key ID and Private Key (optional but recommended):**

1. Apple Developer Portal > **Keys**
2. Click **+** to create new key
3. **Key Name:** Apple Sign In Key
4. Check **Sign in with Apple**
5. **Configure:** Select your Primary App ID
6. Click **Save**
7. Download `.p8` file (save securely, can't re-download)
8. Copy **Key ID** (10-character string)
9. Add to Firebase:
   - **Team ID:** (From Apple Developer account)
   - **Key ID:** (From key creation)
   - **Private Key:** (Contents of .p8 file)

---

### **3.4. Test Apple Sign-In**

**Requirements:**
- Physical iOS device (iOS 13+) OR macOS (10.15+)
- Apple Simulator (iOS 13.5+) also works

**Test Steps:**
```bash
# Run on iOS device/simulator
flutter run -d <ios-device-id>

# Test Apple Sign-In:
# 1. Tap "Apple" button on login screen
# 2. Authenticate with Face ID/Touch ID/Password
# 3. Choose to share or hide email
# 4. Choose to share or hide name
# 5. Verify user is logged in
```

**Troubleshooting:**
- **Error:** "Sign in with Apple not available"
  - **Fix:** Verify iOS 13+ or simulator iOS 13.5+
  - **Fix:** Capability added in Xcode
  - **Fix:** Bundle ID matches Apple Developer account

- **Error:** "Invalid client"
  - **Fix:** Service ID configuration in Apple Developer Portal
  - **Fix:** Bundle ID mismatch

- **Error:** "User cancelled"
  - **Expected:** User tapped "Cancel" button

---

## 🔒 STEP 4: VERIFY FIRESTORE SECURITY RULES

Your Firestore security rules are already configured for authentication. Verify they're deployed:

### **4.1. Check Current Rules**

```bash
# View deployed rules
firebase firestore:rules:get
```

### **4.2. Verify Rules Content**

File: `firestore.rules`

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Public read for life situations (no auth required)
    match /life_situations/{situationId} {
      allow read: if true;
      allow write: if false;
    }

    // Private user data (requires authentication)
    match /users/{userId} {
      allow read, write: if request.auth != null &&
                           request.auth.uid == userId;

      // User's private journal entries
      match /journal_entries/{entryId} {
        allow read, write: if request.auth != null &&
                             request.auth.uid == userId;
      }

      // User's favorites
      match /favorites/{favoriteId} {
        allow read, write: if request.auth != null &&
                             request.auth.uid == userId;
      }
    }
  }
}
```

### **4.3. Deploy Rules (if needed)**

```bash
# Deploy Firestore security rules
firebase deploy --only firestore:rules
```

✅ **Security rules ensure:**
- Life situations are publicly readable
- User data is private (only accessible by the user)
- Journal entries are private
- Favorites are private

---

## 🧪 STEP 5: TESTING CHECKLIST

### **5.1. Email/Password Authentication**

- [ ] **Sign Up:**
  - [ ] Create new account with email and password
  - [ ] Receive verification email
  - [ ] Verify email address
  - [ ] User document created in Firestore

- [ ] **Sign In:**
  - [ ] Log in with email and password
  - [ ] Incorrect password shows error message
  - [ ] Unverified email still allows login (Firebase default)

- [ ] **Password Reset:**
  - [ ] Request password reset
  - [ ] Receive password reset email
  - [ ] Reset password successfully
  - [ ] Log in with new password

---

### **5.2. Google Sign-In**

- [ ] **Android:**
  - [ ] Tap "Google" button
  - [ ] Select Google account
  - [ ] Grant permissions
  - [ ] User logged in successfully
  - [ ] User document created in Firestore with `authProvider: 'google'`

- [ ] **iOS:**
  - [ ] Same steps as Android
  - [ ] Works on both device and simulator

---

### **5.3. Apple Sign-In**

- [ ] **iOS:**
  - [ ] Tap "Apple" button
  - [ ] Authenticate with Face ID/Touch ID
  - [ ] Choose email visibility (share or hide)
  - [ ] Choose name visibility
  - [ ] User logged in successfully
  - [ ] User document created with `authProvider: 'apple'`
  - [ ] Email may be hidden (user choice)

- [ ] **First Sign-In:**
  - [ ] Full name provided by Apple (only on first sign-in)
  - [ ] Subsequent sign-ins: name not provided (cached by Apple)

---

### **5.4. Anonymous Authentication (Guest Mode)**

- [ ] **Guest Sign-In:**
  - [ ] User can access app without account
  - [ ] Anonymous user ID generated
  - [ ] Local data saved
  - [ ] User document created with `authProvider: 'anonymous'`

- [ ] **Convert to Full Account:**
  - [ ] Link anonymous account with email/password
  - [ ] Data preserved after conversion
  - [ ] `authProvider` updated to 'email'

---

### **5.5. Firestore Security**

- [ ] **Authenticated User:**
  - [ ] Can read own user document
  - [ ] Can write to own user document
  - [ ] Can read/write own journal entries
  - [ ] Can read/write own favorites

- [ ] **Unauthenticated User:**
  - [ ] Can read life_situations collection
  - [ ] Cannot read other users' data
  - [ ] Cannot write to any user data

- [ ] **Cross-User Access:**
  - [ ] User A cannot read User B's journal
  - [ ] User A cannot modify User B's data

---

## 📝 STEP 6: PRODUCTION CHECKLIST

### **6.1. Before App Store Submission**

- [ ] **Google Sign-In:**
  - [ ] Add production SHA-1 fingerprint to Firebase
  - [ ] Download production google-services.json/GoogleService-Info.plist
  - [ ] Submit OAuth consent screen for verification (if using sensitive scopes)
  - [ ] Test with production build

- [ ] **Apple Sign-In:**
  - [ ] App ID has "Sign in with Apple" capability
  - [ ] Xcode project has "Sign in with Apple" capability
  - [ ] Service ID configured (if needed)
  - [ ] Test on physical device with production build

- [ ] **Firebase:**
  - [ ] Upgrade to Blaze plan (required for production)
  - [ ] Set up billing alerts
  - [ ] Configure authentication quotas
  - [ ] Deploy Firestore security rules
  - [ ] Review Cloud Functions (if any)

- [ ] **Privacy & Compliance:**
  - [ ] Privacy Policy published
  - [ ] Terms of Service published
  - [ ] GDPR compliance verified
  - [ ] COPPA compliance (if under 13)
  - [ ] Data retention policy implemented

---

### **6.2. App Store Requirements**

**iOS App Store:**
- Apple Sign-In is **REQUIRED** if you offer other third-party sign-in options (Google)
- Privacy Policy URL in App Store Connect
- Data collection disclosure in App Privacy section

**Google Play Store:**
- Google Sign-In SHA-1 must be from production keystore
- Privacy Policy URL in Play Console
- Data safety section filled out

---

## 🛠️ TROUBLESHOOTING

### **Common Errors**

| Error | Cause | Solution |
|-------|-------|----------|
| "Google sign-in failed: PlatformException(sign_in_failed...)" | Missing/incorrect SHA-1 | Add debug & release SHA-1 to Firebase |
| "Developer Error" (Android) | Package name mismatch | Verify package name in Firebase matches android/app/build.gradle |
| "Apple Sign-In not available" | iOS version < 13 | Test on iOS 13+ device or simulator |
| "Invalid client" (Apple) | Service ID misconfigured | Verify Service ID in Apple Developer Portal |
| "Permission denied" (Firestore) | Security rules not deployed | Run `firebase deploy --only firestore:rules` |
| "User cancelled" | User tapped Cancel | Expected behavior, not an error |
| "Email already in use" | Account exists | User should log in instead of signing up |

---

### **Debug Commands**

```bash
# Check Firebase project
firebase projects:list

# Check current Firebase project
firebase use

# View Firestore rules
firebase firestore:rules:get

# Deploy Firestore rules
firebase deploy --only firestore:rules

# View Firebase logs
firebase functions:log

# Flutter clean rebuild
flutter clean
flutter pub get
flutter run

# Android signing report
cd android && ./gradlew signingReport

# iOS pods update
cd ios && pod repo update && pod install
```

---

## 📞 SUPPORT

### **Firebase Support**
- Firebase Console: https://console.firebase.google.com
- Firebase Documentation: https://firebase.google.com/docs
- Firebase Support: https://firebase.google.com/support

### **Google Sign-In**
- Google Cloud Console: https://console.cloud.google.com
- Documentation: https://developers.google.com/identity

### **Apple Sign-In**
- Apple Developer Portal: https://developer.apple.com
- Documentation: https://developer.apple.com/sign-in-with-apple

---

## ✅ COMPLETION

Once all steps are completed:

1. ✅ All authentication providers enabled in Firebase Console
2. ✅ Google Sign-In configured (SHA-1, OAuth consent)
3. ✅ Apple Sign-In configured (App ID, capabilities)
4. ✅ Firestore security rules deployed
5. ✅ All authentication flows tested on both platforms
6. ✅ Production checklist reviewed
7. ✅ Privacy policy and terms published

**Your authentication system is now fully configured and ready for production! 🚀**

---

**Last Updated:** 2025-10-10
**Next Review:** Before production deployment
**Version:** 1.0.0
