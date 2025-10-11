import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindful_living/core/services/user_preferences_service.dart';

/// Unit tests for UserPreferencesService
/// Verifies that user preferences are properly saved and retrieved
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserPreferencesService', () {
    late UserPreferencesService service;

    setUp(() async {
      // Clear any existing preferences before each test
      SharedPreferences.setMockInitialValues({});
      service = UserPreferencesService();
      await service.init();
    });

    test('should save and retrieve dark mode preference', () async {
      // Save dark mode preference
      final saved = await service.saveDarkMode(true);
      expect(saved, true);

      // Retrieve dark mode preference
      final darkMode = await service.getDarkMode();
      expect(darkMode, true);
    });

    test('should save and retrieve background music preference', () async {
      // Save background music preference
      final saved = await service.saveBackgroundMusic(true);
      expect(saved, true);

      // Retrieve background music preference
      final backgroundMusic = await service.getBackgroundMusic();
      expect(backgroundMusic, true);
    });

    test('should save and retrieve breathing reminders preference', () async {
      // Save breathing reminders preference
      final saved = await service.saveBreathingReminders(false);
      expect(saved, true);

      // Retrieve breathing reminders preference
      final breathingReminders = await service.getBreathingReminders();
      expect(breathingReminders, false);
    });

    test('should save and retrieve font size preference', () async {
      // Save font size preference
      final saved = await service.saveFontSize('Large');
      expect(saved, true);

      // Retrieve font size preference
      final fontSize = await service.getFontSize();
      expect(fontSize, 'Large');
    });

    test('should validate font size and use default for invalid values', () async {
      // Try to save invalid font size
      await service.saveFontSize('ExtraLarge');

      // Should return default value
      final fontSize = await service.getFontSize();
      expect(fontSize, 'Medium');
    });

    test('should load all preferences at once', () async {
      // Save some preferences
      await service.saveDarkMode(true);
      await service.saveBackgroundMusic(true);
      await service.saveBreathingReminders(false);
      await service.saveFontSize('Small');

      // Load all preferences
      final prefs = await service.loadAllPreferences();

      expect(prefs['darkMode'], true);
      expect(prefs['backgroundMusic'], true);
      expect(prefs['breathingReminders'], false);
      expect(prefs['fontSize'], 'Small');
    });

    test('should return default values when preferences are not set', () async {
      final darkMode = await service.getDarkMode();
      final backgroundMusic = await service.getBackgroundMusic();
      final breathingReminders = await service.getBreathingReminders();
      final fontSize = await service.getFontSize();

      expect(darkMode, false);
      expect(backgroundMusic, false);
      expect(breathingReminders, true);
      expect(fontSize, 'Medium');
    });

    test('should reset all preferences to defaults', () async {
      // Set some custom preferences
      await service.saveDarkMode(true);
      await service.saveBackgroundMusic(true);
      await service.saveBreathingReminders(false);
      await service.saveFontSize('Large');

      // Reset all preferences
      final reset = await service.resetAllPreferences();
      expect(reset, true);

      // Verify all are back to defaults
      final darkMode = await service.getDarkMode();
      final backgroundMusic = await service.getBackgroundMusic();
      final breathingReminders = await service.getBreathingReminders();
      final fontSize = await service.getFontSize();

      expect(darkMode, false);
      expect(backgroundMusic, false);
      expect(breathingReminders, true);
      expect(fontSize, 'Medium');
    });

    test('should clear all preferences', () async {
      // Set some preferences
      await service.saveDarkMode(true);
      await service.saveBackgroundMusic(true);

      // Clear all preferences
      final cleared = await service.clearAllPreferences();
      expect(cleared, true);

      // Verify preferences return to defaults (since keys are removed)
      final darkMode = await service.getDarkMode();
      final backgroundMusic = await service.getBackgroundMusic();

      expect(darkMode, false);
      expect(backgroundMusic, false);
    });

    test('should persist preferences across service instances', () async {
      // Save preferences with first instance
      await service.saveDarkMode(true);
      await service.saveFontSize('Large');

      // Create a new service instance
      final newService = UserPreferencesService();
      await newService.init();

      // Verify preferences are persisted
      final darkMode = await newService.getDarkMode();
      final fontSize = await newService.getFontSize();

      expect(darkMode, true);
      expect(fontSize, 'Large');
    });
  });
}
