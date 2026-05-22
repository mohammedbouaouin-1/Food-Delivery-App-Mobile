import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/app_translations.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  Locale _locale = const Locale('fr');

  LocaleProvider() {
    _loadLocale();
  }

  Locale get locale => _locale;
  String get localeCode => _locale.languageCode;

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_localeKey);
      if (savedCode != null && (savedCode == 'fr' || savedCode == 'en')) {
        _locale = Locale(savedCode);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading locale: $e');
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    if (languageCode != 'fr' && languageCode != 'en') return;
    if (_locale.languageCode == languageCode) return;

    _locale = Locale(languageCode);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, languageCode);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  String translate(String key) {
    return AppTranslations.translate(key, localeCode);
  }
}
