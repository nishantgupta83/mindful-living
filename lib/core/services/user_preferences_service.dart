import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user preferences and settings persistence
/// Uses SharedPreferences for local storage with singleton pattern
class UserPreferencesService {
  // Singleton instance
  static final UserPreferencesService _instance = UserPreferencesService._internal();
  factory UserPreferencesService() => _instance;
  UserPreferencesService._internal();

  // SharedPreferences instance
  SharedPreferences? _prefs;

  // Preference keys
  static const String _keyDarkMode = 'dark_mode_enabled';
  static const String _keyBackgroundMusic = 'background_music_enabled';
  static const String _keyBreathingReminders = 'breathing_reminders_enabled';
  static const String _keyFontSize = 'font_size';

  // Default values
  static const bool _defaultDarkMode = false;
  static const bool _defaultBackgroundMusic = false;
  static const bool _defaultBreathingReminders = true;
  static const String _defaultFontSize = 'Medium';

  /// Initialize SharedPreferences
  /// Should be called once during app startup
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      throw Exception('Failed to initialize UserPreferencesService: $e');
    }
  }

  /// Ensures SharedPreferences is initialized before use
  Future<SharedPreferences> _getPrefs() async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // ==================== Dark Mode ====================

  /// Save dark mode preference
  Future<bool> saveDarkMode(bool value) async {
    try {
      final prefs = await _getPrefs();
      return await prefs.setBool(_keyDarkMode, value);
    } catch (e) {
      print('Error saving dark mode preference: $e');
      return false;
    }
  }

  /// Get dark mode preference
  Future<bool> getDarkMode() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getBool(_keyDarkMode) ?? _defaultDarkMode;
    } catch (e) {
      print('Error getting dark mode preference: $e');
      return _defaultDarkMode;
    }
  }

  // ==================== Background Music ====================

  /// Save background music preference
  Future<bool> saveBackgroundMusic(bool value) async {
    try {
      final prefs = await _getPrefs();
      return await prefs.setBool(_keyBackgroundMusic, value);
    } catch (e) {
      print('Error saving background music preference: $e');
      return false;
    }
  }

  /// Get background music preference
  Future<bool> getBackgroundMusic() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getBool(_keyBackgroundMusic) ?? _defaultBackgroundMusic;
    } catch (e) {
      print('Error getting background music preference: $e');
      return _defaultBackgroundMusic;
    }
  }

  // ==================== Breathing Reminders ====================

  /// Save breathing reminders preference
  Future<bool> saveBreathingReminders(bool value) async {
    try {
      final prefs = await _getPrefs();
      return await prefs.setBool(_keyBreathingReminders, value);
    } catch (e) {
      print('Error saving breathing reminders preference: $e');
      return false;
    }
  }

  /// Get breathing reminders preference
  Future<bool> getBreathingReminders() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getBool(_keyBreathingReminders) ?? _defaultBreathingReminders;
    } catch (e) {
      print('Error getting breathing reminders preference: $e');
      return _defaultBreathingReminders;
    }
  }

  // ==================== Font Size ====================

  /// Save font size preference
  /// Valid values: 'Small', 'Medium', 'Large'
  Future<bool> saveFontSize(String value) async {
    try {
      // Validate input
      if (!['Small', 'Medium', 'Large'].contains(value)) {
        print('Invalid font size value: $value. Using default.');
        value = _defaultFontSize;
      }

      final prefs = await _getPrefs();
      return await prefs.setString(_keyFontSize, value);
    } catch (e) {
      print('Error saving font size preference: $e');
      return false;
    }
  }

  /// Get font size preference
  /// Returns: 'Small', 'Medium', or 'Large'
  Future<String> getFontSize() async {
    try {
      final prefs = await _getPrefs();
      final value = prefs.getString(_keyFontSize) ?? _defaultFontSize;

      // Validate stored value
      if (!['Small', 'Medium', 'Large'].contains(value)) {
        return _defaultFontSize;
      }

      return value;
    } catch (e) {
      print('Error getting font size preference: $e');
      return _defaultFontSize;
    }
  }

  // ==================== Batch Operations ====================

  /// Load all preferences at once
  /// Returns a map with all current preference values
  Future<Map<String, dynamic>> loadAllPreferences() async {
    try {
      final darkMode = await getDarkMode();
      final backgroundMusic = await getBackgroundMusic();
      final breathingReminders = await getBreathingReminders();
      final fontSize = await getFontSize();

      return {
        'darkMode': darkMode,
        'backgroundMusic': backgroundMusic,
        'breathingReminders': breathingReminders,
        'fontSize': fontSize,
      };
    } catch (e) {
      print('Error loading all preferences: $e');
      return {
        'darkMode': _defaultDarkMode,
        'backgroundMusic': _defaultBackgroundMusic,
        'breathingReminders': _defaultBreathingReminders,
        'fontSize': _defaultFontSize,
      };
    }
  }

  /// Reset all preferences to default values
  Future<bool> resetAllPreferences() async {
    try {
      await saveDarkMode(_defaultDarkMode);
      await saveBackgroundMusic(_defaultBackgroundMusic);
      await saveBreathingReminders(_defaultBreathingReminders);
      await saveFontSize(_defaultFontSize);
      return true;
    } catch (e) {
      print('Error resetting preferences: $e');
      return false;
    }
  }

  /// Clear all stored preferences
  Future<bool> clearAllPreferences() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(_keyDarkMode);
      await prefs.remove(_keyBackgroundMusic);
      await prefs.remove(_keyBreathingReminders);
      await prefs.remove(_keyFontSize);
      return true;
    } catch (e) {
      print('Error clearing preferences: $e');
      return false;
    }
  }
}
