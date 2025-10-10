# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
**Mindful Living** is a Flutter-based wellness app that provides practical guidance for life situations. This is a completely separate project from GitaWisdom, targeting mainstream wellness with secular, evidence-based content.

**Key Strategy**: Transform GitaWisdom content into secular wellness guidance, removing all religious references while maintaining wisdom essence.

## Development Commands

### Core Flutter Commands
- **Run app**: `flutter run` (development with hot reload)
- **Get dependencies**: `flutter pub get`
- **Analyze code**: `flutter analyze` (uses flutter_lints package)
- **Run tests**: `flutter test`
- **Format code**: `flutter format .`

### Build Commands
- **Android APK**: `flutter build apk`
- **Android Bundle**: `flutter build appbundle`
- **iOS**: `flutter build ios`
- **Web**: `flutter build web`

### Firebase Commands
- **Login**: `firebase login`
- **Deploy**: `firebase deploy`
- **Start emulators**: `firebase emulators:start`

## Project Architecture

### App Structure
```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── routes/
│   └── theme/
├── core/
│   ├── constants/
│   ├── utils/
│   └── services/
├── features/
│   ├── dashboard/
│   ├── life_situations/
│   ├── journal/
│   ├── practices/
│   └── profile/
├── shared/
│   ├── models/
│   ├── widgets/
│   └── providers/
└── firebase_options.dart
```

### State Management
- **Primary**: Provider + Riverpod
- **Local Storage**: Hive for offline data
- **Remote Storage**: Firebase Firestore

### Key Dependencies
- **Firebase**: Core, Firestore, Auth, Analytics, Crashlytics
- **UI**: Google Fonts, Flutter SVG, Lottie animations
- **Storage**: Hive, SharedPreferences, PathProvider
- **Charts**: FL Chart, Syncfusion Charts
- **Utilities**: UUID, Intl, URLLauncher, SharePlus

## Core Features (MVP)
1. **Life Situations Browser**: 1000+ scenarios with dual perspectives (Mindful + Practical)
2. **Daily Wellness Dashboard**: Wellness score, mood check-in, progress streaks
3. **Mindful Journal**: Private entries, mood tracking, gratitude prompts
4. **Guided Practices**: Breathing exercises, mindful moments, meditations

## Brand Guidelines
- **Colors**: Primary Blue (#4A90E2), Growth Green (#7ED321), Mindful Orange (#F5A623)
- **Typography**: Inter (primary), Poppins (secondary)
- **Style**: Clean, minimal, calming, secular
- **Package ID**: `com.hub4apps.mindfulliving`

## Content Transformation Rules
**Critical**: Remove ALL religious references when transforming GitaWisdom content
- "Gita Wisdom" → "Key Insights"
- "Krishna teaches" → "Research shows"
- "Spiritual practice" → "Mindful practice"
- "Sacred" → "Meaningful"
- "Dharma" → "Purpose"
- "Divine guidance" → "Inner wisdom"

## Testing Strategy
- Widget tests in `test/` directory
- Integration tests for core user flows
- Test on multiple platforms and screen sizes
- Verify all religious content is removed

## Data Models
Key models include `LifeSituation` with fields: title, description, mindfulApproach, practicalSteps, keyInsights, lifeArea, tags, difficultyLevel, estimatedReadTime, wellnessFocus.

## Development Workflow
1. Always use `flutter pub get` after dependency changes
2. Run `flutter analyze` before commits
3. Test on both Android and iOS regularly
4. Maintain separation from GitaWisdom project
5. Verify content transformation removes religious references

## Store Submission
- **Title**: "Mindful Living: Daily Wellness"
- **Category**: Health & Fitness (Primary), Lifestyle (Secondary)
- **Age Rating**: 4+
- **Keywords**: mindfulness, wellness, mental health, stress relief, life balance

## Firebase Configuration
Project ID: `hub4apps-mindfulliving`
Security rules configured for public read (life_situations), private write (user data)