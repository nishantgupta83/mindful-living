# Firebase Configuration Setup Guide

## Security Notice

**IMPORTANT**: Firebase configuration files contain sensitive API keys and project identifiers. These files should NEVER be committed to version control or shared publicly.

## Overview

This guide explains how to securely configure Firebase for the Mindful Living app across different environments and platforms.

---

## Table of Contents

1. [Initial Setup](#initial-setup)
2. [Platform-Specific Configuration](#platform-specific-configuration)
3. [Environment Setup](#environment-setup)
4. [CI/CD Configuration](#cicd-configuration)
5. [Security Best Practices](#security-best-practices)
6. [Troubleshooting](#troubleshooting)

---

## Initial Setup

### Prerequisites

1. **Firebase CLI**: Install the Firebase command-line tools
   ```bash
   npm install -g firebase-tools
   ```

2. **Firebase Account**: Ensure you have access to the `hub4apps-mindfulliving` Firebase project

3. **Platform Tools**:
   - Android Studio (for Android development)
   - Xcode (for iOS development)

### Firebase Login

```bash
# Login to Firebase
firebase login

# Verify you're logged in
firebase projects:list
```

---

## Platform-Specific Configuration

### Android Configuration

#### Step 1: Download google-services.json

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **hub4apps-mindfulliving**
3. Navigate to **Project Settings** (gear icon)
4. Scroll to **Your apps** section
5. Select your Android app or add new app:
   - **Package name**: `com.hub4apps.mindfulliving`
   - **App nickname**: Mindful Living (Android)
6. Click **Download google-services.json**

#### Step 2: Place Configuration File

```bash
# Place the file in the Android app directory
cp ~/Downloads/google-services.json android/app/google-services.json
```

**File Location**: `android/app/google-services.json`

#### Step 3: Verify Configuration

```bash
# Check if file exists and is valid JSON
cat android/app/google-services.json | python3 -m json.tool
```

**Expected Structure**:
```json
{
  "project_info": {
    "project_number": "YOUR_PROJECT_NUMBER",
    "project_id": "hub4apps-mindfulliving",
    "storage_bucket": "hub4apps-mindfulliving.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "YOUR_APP_ID",
        "android_client_info": {
          "package_name": "com.hub4apps.mindfulliving"
        }
      }
    }
  ]
}
```

---

### iOS Configuration

#### Step 1: Download GoogleService-Info.plist

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **hub4apps-mindfulliving**
3. Navigate to **Project Settings** (gear icon)
4. Scroll to **Your apps** section
5. Select your iOS app or add new app:
   - **Bundle ID**: `com.hub4apps.mindfulLiving`
   - **App nickname**: Mindful Living (iOS)
6. Click **Download GoogleService-Info.plist**

#### Step 2: Place Configuration File

```bash
# Place the file in the iOS Runner directory
cp ~/Downloads/GoogleService-Info.plist ios/Runner/GoogleService-Info.plist
```

**File Location**: `ios/Runner/GoogleService-Info.plist`

#### Step 3: Add to Xcode (Important!)

1. Open the iOS project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Right-click on the `Runner` folder in Xcode
3. Select **Add Files to "Runner"...**
4. Select `GoogleService-Info.plist`
5. **IMPORTANT**: Check **"Copy items if needed"**
6. **IMPORTANT**: Ensure it's added to the **Runner** target
7. Verify the file appears in **Runner > Runner** folder (not just references)

#### Step 4: Verify Configuration

```bash
# Check if file exists and is valid XML
plutil -lint ios/Runner/GoogleService-Info.plist
```

**Expected Structure**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CLIENT_ID</key>
    <string>YOUR_CLIENT_ID</string>
    <key>REVERSED_CLIENT_ID</key>
    <string>com.googleusercontent.apps.YOUR_ID</string>
    <key>API_KEY</key>
    <string>YOUR_API_KEY</string>
    <key>GCM_SENDER_ID</key>
    <string>YOUR_SENDER_ID</string>
    <key>PLIST_VERSION</key>
    <string>1</string>
    <key>BUNDLE_ID</key>
    <string>com.hub4apps.mindfulLiving</string>
    <key>PROJECT_ID</key>
    <string>hub4apps-mindfulliving</string>
    <!-- Additional keys... -->
</dict>
</plist>
```

---

### Flutter Firebase Options

#### Step 1: Install FlutterFire CLI

```bash
# Activate FlutterFire CLI
dart pub global activate flutterfire_cli

# Verify installation
flutterfire --version
```

#### Step 2: Configure Firebase for Flutter

```bash
# Run FlutterFire configuration (from project root)
flutterfire configure \
  --project=hub4apps-mindfulliving \
  --out=lib/firebase_options.dart \
  --platforms=android,ios,web
```

This command will:
- Connect to your Firebase project
- Generate `lib/firebase_options.dart` with platform-specific configurations
- Configure all necessary Firebase services

#### Step 3: Verify Generated File

**File Location**: `lib/firebase_options.dart`

**Expected Structure**:
```dart
// File generated by FlutterFire CLI.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      // ... other platforms
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'hub4apps-mindfulliving',
    // ... other options
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'hub4apps-mindfulliving',
    // ... other options
  );
}
```

---

## Environment Setup

### Development Environment

For local development, simply place the configuration files as described above. The app will automatically use these configurations.

### Multiple Environments (Staging/Production)

If you need separate Firebase projects for different environments:

#### 1. Create Environment-Specific Configs

```bash
# Development
flutterfire configure \
  --project=hub4apps-mindfulliving-dev \
  --out=lib/firebase_options_dev.dart

# Production
flutterfire configure \
  --project=hub4apps-mindfulliving \
  --out=lib/firebase_options_prod.dart
```

#### 2. Update main.dart to Use Environment-Specific Config

```dart
import 'firebase_options_dev.dart' as dev;
import 'firebase_options_prod.dart' as prod;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Determine which config to use
  final firebaseOptions = const String.fromEnvironment('ENV') == 'prod'
      ? prod.DefaultFirebaseOptions.currentPlatform
      : dev.DefaultFirebaseOptions.currentPlatform;

  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const MyApp());
}
```

#### 3. Build with Environment Flag

```bash
# Development build
flutter build apk --dart-define=ENV=dev

# Production build
flutter build apk --dart-define=ENV=prod
```

---

## CI/CD Configuration

### GitHub Actions

Store Firebase configuration files as encrypted secrets:

#### 1. Base64 Encode Configuration Files

```bash
# Encode Android config
base64 -i android/app/google-services.json | pbcopy

# Encode iOS config
base64 -i ios/Runner/GoogleService-Info.plist | pbcopy

# Encode Flutter options
base64 -i lib/firebase_options.dart | pbcopy
```

#### 2. Add to GitHub Secrets

1. Go to your repository on GitHub
2. Navigate to **Settings > Secrets and variables > Actions**
3. Add the following secrets:
   - `FIREBASE_GOOGLE_SERVICES_JSON` (Android config, base64 encoded)
   - `FIREBASE_GOOGLE_SERVICE_INFO_PLIST` (iOS config, base64 encoded)
   - `FIREBASE_OPTIONS_DART` (Flutter config, base64 encoded)

#### 3. Decode in CI/CD Workflow

```yaml
# .github/workflows/build.yml
name: Build and Test

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Decode Firebase Configs
        run: |
          # Decode Android config
          echo "${{ secrets.FIREBASE_GOOGLE_SERVICES_JSON }}" | base64 --decode > android/app/google-services.json

          # Decode iOS config
          echo "${{ secrets.FIREBASE_GOOGLE_SERVICE_INFO_PLIST }}" | base64 --decode > ios/Runner/GoogleService-Info.plist

          # Decode Flutter options
          echo "${{ secrets.FIREBASE_OPTIONS_DART }}" | base64 --decode > lib/firebase_options.dart

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.35.3'

      - name: Install dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test

      - name: Build Android APK
        run: flutter build apk --release
```

### GitLab CI/CD

```yaml
# .gitlab-ci.yml
variables:
  FLUTTER_VERSION: "3.35.3"

before_script:
  # Decode Firebase configs from CI/CD variables
  - echo "$FIREBASE_GOOGLE_SERVICES_JSON" | base64 -d > android/app/google-services.json
  - echo "$FIREBASE_GOOGLE_SERVICE_INFO_PLIST" | base64 -d > ios/Runner/GoogleService-Info.plist
  - echo "$FIREBASE_OPTIONS_DART" | base64 -d > lib/firebase_options.dart

build:android:
  stage: build
  script:
    - flutter pub get
    - flutter build apk --release
  artifacts:
    paths:
      - build/app/outputs/apk/release/app-release.apk
```

### Bitrise

1. Go to **Workflow > Secrets**
2. Add environment variables:
   - `FIREBASE_GOOGLE_SERVICES_JSON`
   - `FIREBASE_GOOGLE_SERVICE_INFO_PLIST`
   - `FIREBASE_OPTIONS_DART`

3. Add Script step before build:
```bash
#!/bin/bash
set -e

# Decode Firebase configs
echo "$FIREBASE_GOOGLE_SERVICES_JSON" | base64 --decode > android/app/google-services.json
echo "$FIREBASE_GOOGLE_SERVICE_INFO_PLIST" | base64 --decode > ios/Runner/GoogleService-Info.plist
echo "$FIREBASE_OPTIONS_DART" | base64 --decode > lib/firebase_options.dart
```

---

## Security Best Practices

### 1. API Key Security

**Important**: Firebase API keys in client apps are not security risks by themselves. Firebase uses:
- **Security Rules**: Control data access at the database level
- **App Check**: Verify requests come from your legitimate app
- **Authentication**: User-level access control

However, you should still:

#### Enable App Check (Recommended)

```dart
// Add to main.dart
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,
  );

  runApp(const MyApp());
}
```

#### Configure Firebase Security Rules

```javascript
// Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Only authenticated users can write
    match /{document=**} {
      allow read: if true;  // Public read
      allow write: if request.auth != null;  // Authenticated write
    }

    // User-specific data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Admin-only collections
    match /admin/{document=**} {
      allow read, write: if request.auth != null &&
        request.auth.token.admin == true;
    }
  }
}
```

### 2. Key Rotation (If Compromised)

If your Firebase keys have been exposed publicly:

#### Step 1: Restrict Current API Keys

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select project: **hub4apps-mindfulliving**
3. Navigate to **APIs & Services > Credentials**
4. Find your API keys
5. Click **Edit** and add restrictions:
   - **Application restrictions**:
     - Android apps: Add package name and SHA-1 fingerprint
     - iOS apps: Add bundle ID
   - **API restrictions**: Select only required APIs

#### Step 2: Create New Firebase Project (If Necessary)

```bash
# Create new Firebase project via CLI
firebase projects:create hub4apps-mindfulliving-v2

# Or use Firebase Console to create new project
```

#### Step 3: Migrate Data

```bash
# Export existing data
firebase firestore:export gs://hub4apps-mindfulliving.appspot.com/exports

# Import to new project
firebase firestore:import gs://hub4apps-mindfulliving-v2.appspot.com/exports
```

#### Step 4: Update App Configuration

Re-run the configuration steps above with the new project.

### 3. .gitignore Verification

Ensure these files are NEVER committed:

```bash
# Check if files are ignored
git check-ignore -v android/app/google-services.json
git check-ignore -v ios/Runner/GoogleService-Info.plist
git check-ignore -v lib/firebase_options.dart

# If any file is already tracked, remove from git (but keep locally)
git rm --cached android/app/google-services.json
git rm --cached ios/Runner/GoogleService-Info.plist
git rm --cached lib/firebase_options.dart
git rm --cached ios/firebase_app_id_file.json
```

### 4. Team Access Management

1. **Firebase Project Permissions**:
   - Go to **Project Settings > Users and permissions**
   - Grant minimum required access:
     - **Viewer**: Read-only access
     - **Editor**: Can modify configurations
     - **Owner**: Full administrative access

2. **Share Configs Securely**:
   - Use encrypted communication (never email plain text)
   - Use 1Password, LastPass, or similar secret management tools
   - Share via secure file transfer services with expiration

### 5. Monitor for Unauthorized Access

#### Enable Alerts

1. Go to **Firebase Console > Project Settings > Integrations**
2. Enable **Cloud Monitoring**
3. Set up alerts for:
   - Unusual API usage spikes
   - Failed authentication attempts
   - Database rule violations

#### Review Audit Logs

```bash
# View Firebase audit logs
gcloud logging read "resource.type=firebase" \
  --project=hub4apps-mindfulliving \
  --limit=50 \
  --format=json
```

---

## Troubleshooting

### Android Issues

#### Error: "google-services.json not found"

**Solution**:
```bash
# Verify file exists
ls -la android/app/google-services.json

# Verify file is valid JSON
cat android/app/google-services.json | python3 -m json.tool

# Clean and rebuild
flutter clean
flutter pub get
flutter build apk
```

#### Error: "Package name mismatch"

**Solution**: Ensure package name in `google-services.json` matches `android/app/build.gradle.kts`:

```kotlin
// android/app/build.gradle.kts
android {
    namespace = "com.hub4apps.mindfulliving"  // Must match Firebase
    defaultConfig {
        applicationId = "com.hub4apps.mindfulliving"  // Must match Firebase
    }
}
```

### iOS Issues

#### Error: "GoogleService-Info.plist not found"

**Solution**:
```bash
# Verify file exists
ls -la ios/Runner/GoogleService-Info.plist

# Verify file is valid XML
plutil -lint ios/Runner/GoogleService-Info.plist

# Verify file is added to Xcode project
# Open ios/Runner.xcworkspace and check if file appears in Runner folder
```

#### Error: "Bundle ID mismatch"

**Solution**: Ensure bundle ID matches across:

1. `GoogleService-Info.plist`:
   ```xml
   <key>BUNDLE_ID</key>
   <string>com.hub4apps.mindfulLiving</string>
   ```

2. `ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleIdentifier</key>
   <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
   ```

3. Xcode project settings:
   - Open `ios/Runner.xcworkspace`
   - Select **Runner** target
   - **General** tab > **Bundle Identifier**: `com.hub4apps.mindfulLiving`

### Flutter Issues

#### Error: "Firebase options not initialized"

**Solution**:
```dart
// Ensure Firebase is initialized in main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}
```

#### Error: "Platform not supported"

**Solution**: Re-run FlutterFire configuration:
```bash
flutterfire configure --project=hub4apps-mindfulliving
```

### General Firebase Connection Issues

#### Test Firebase Connection

```dart
// Add test code to verify Firebase is working
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> testFirebaseConnection() async {
  try {
    // Test Firestore connection
    final snapshot = await FirebaseFirestore.instance
        .collection('life_situations')
        .limit(1)
        .get();

    print('Firebase connected successfully!');
    print('Document count: ${snapshot.docs.length}');
  } catch (e) {
    print('Firebase connection failed: $e');
  }
}
```

#### Enable Debug Logging

```dart
// Enable Firebase debug logging
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable debug mode
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Firestore logging
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const MyApp());
}
```

---

## Quick Reference

### File Locations Checklist

- [ ] `android/app/google-services.json` - Android Firebase config
- [ ] `ios/Runner/GoogleService-Info.plist` - iOS Firebase config
- [ ] `lib/firebase_options.dart` - Flutter Firebase options
- [ ] All files added to `.gitignore`
- [ ] iOS config added to Xcode project (not just file system)

### Verification Commands

```bash
# Verify .gitignore
git check-ignore -v android/app/google-services.json
git check-ignore -v ios/Runner/GoogleService-Info.plist
git check-ignore -v lib/firebase_options.dart

# Verify JSON validity
python3 -m json.tool < android/app/google-services.json

# Verify plist validity
plutil -lint ios/Runner/GoogleService-Info.plist

# Test Firebase connection
flutter run --debug
# Then check logs for Firebase initialization messages
```

### Environment Variables for CI/CD

```bash
# Generate base64 encoded configs
base64 -i android/app/google-services.json > google-services.base64
base64 -i ios/Runner/GoogleService-Info.plist > GoogleService-Info.base64
base64 -i lib/firebase_options.dart > firebase_options.base64

# Add these to your CI/CD secrets:
# - FIREBASE_GOOGLE_SERVICES_JSON
# - FIREBASE_GOOGLE_SERVICE_INFO_PLIST
# - FIREBASE_OPTIONS_DART
```

---

## Support

If you encounter issues not covered in this guide:

1. **Firebase Documentation**: [firebase.google.com/docs](https://firebase.google.com/docs)
2. **FlutterFire Documentation**: [firebase.flutter.dev](https://firebase.flutter.dev)
3. **Stack Overflow**: Tag questions with `flutter`, `firebase`, `flutterfire`
4. **Firebase Support**: [firebase.google.com/support](https://firebase.google.com/support)

---

## Changelog

### 2025-10-10
- Initial Firebase configuration guide created
- Security best practices added
- CI/CD configuration examples added
- Troubleshooting section added

---

**Last Updated**: 2025-10-10
**Firebase Project**: hub4apps-mindfulliving
**Supported Platforms**: Android, iOS, Web
