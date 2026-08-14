import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language state notifier
class LanguageNotifier extends StateNotifier<String> {
  static const String _languageKey = 'app_language';
  static const String _defaultLanguage = 'en';

  LanguageNotifier() : super(_defaultLanguage) {
    _loadLanguage();
  }

  /// Load saved language preference
  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey) ?? _defaultLanguage;
      state = savedLanguage;
    } catch (e) {
      state = _defaultLanguage;
    }
  }

  /// Change language
  Future<void> changeLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      state = languageCode;
    } catch (e) {
      // Handle error
      print('Error saving language preference: $e');
    }
  }

  /// Get current language
  String getCurrentLanguage() => state;
}

/// Language provider
final languageProvider = StateNotifierProvider<LanguageNotifier, String>(
  (ref) => LanguageNotifier(),
);

/// Supported languages
final supportedLanguages = {
  'en': 'English',
  'hi': 'हिन्दी',
  'mr': 'मराठी',
  'ta': 'தமிழ்',
  'te': 'తెలుగు',
  'kn': 'ಕನ್ನಡ',
  'bn': 'বাংলা',
  'gu': 'ગુજરાતી',
  'pa': 'ਪੰਜਾਬੀ',
  'ml': 'മലയാളം',
};

/// Get language name
String getLanguageName(String code) {
  return supportedLanguages[code] ?? 'Unknown';
}
