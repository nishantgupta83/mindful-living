import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../generated/l10n/app_localizations.dart';

/// Manages app localization state and language switching
class LocalizationManager extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  
  Locale _currentLocale = const Locale('en', 'US');
  
  Locale get currentLocale => _currentLocale;
  
  /// Supported languages with their display names
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'es': 'Español',
    'hi': 'हिंदी',
  };
  
  /// Get localized display name for current language
  String getCurrentLanguageDisplayName() {
    return supportedLanguages[_currentLocale.languageCode] ?? 'English';
  }
  
  /// Initialize localization from saved preferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);
    
    if (savedLocale != null) {
      final parts = savedLocale.split('_');
      if (parts.length == 2) {
        _currentLocale = Locale(parts[0], parts[1]);
        notifyListeners();
      }
    }
  }
  
  /// Change app language
  Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Map language codes to full locales
    late Locale newLocale;
    switch (languageCode) {
      case 'en':
        newLocale = const Locale('en', 'US');
        break;
      case 'es':
        newLocale = const Locale('es', 'ES');
        break;
      case 'hi':
        newLocale = const Locale('hi', 'IN');
        break;
      default:
        newLocale = const Locale('en', 'US');
    }
    
    _currentLocale = newLocale;
    await prefs.setString(_localeKey, '${newLocale.languageCode}_${newLocale.countryCode}');
    notifyListeners();
  }
  
  /// Get current app localizations
  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context)!;
  }
  
  /// Check if current language is RTL (Right-to-Left)
  bool get isRTL {
    return _currentLocale.languageCode == 'ar' || 
           _currentLocale.languageCode == 'he' ||
           _currentLocale.languageCode == 'fa';
  }
  
  /// Get text direction for current locale
  TextDirection get textDirection {
    return isRTL ? TextDirection.rtl : TextDirection.ltr;
  }
}

/// Extension to easily access localizations
extension LocalizationContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}