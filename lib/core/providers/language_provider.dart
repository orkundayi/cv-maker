import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language provider for managing app language state
class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('tr')) {
    _loadLanguage();
  }

  static const String _languageKey = 'app_language';

  /// Load saved language from SharedPreferences
  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey) ?? 'tr';
      state = Locale(languageCode);
    } catch (e) {
      // Default to Turkish if loading fails
      state = const Locale('tr');
    }
  }

  /// Change app language and save to SharedPreferences
  Future<void> changeLanguage(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
      state = locale;
    } catch (e) {
      // Handle error but still change language in memory
      state = locale;
    }
  }

  /// Toggle between Turkish and English
  Future<void> toggleLanguage() async {
    final newLocale = state.languageCode == 'tr' ? const Locale('en') : const Locale('tr');
    await changeLanguage(newLocale);
  }

  /// Check if current language is Turkish
  bool get isTurkish => state.languageCode == 'tr';

  /// Check if current language is English
  bool get isEnglish => state.languageCode == 'en';
}

/// Language provider instance
final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});
