import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider pour gérer la langue de l'application
class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('fr');

  Locale get locale => _locale;

  LanguageProvider() {
    _loadLanguage();
  }

  /// Charger la langue sauvegardée
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language') ?? 'fr';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  /// Changer la langue
  Future<void> setLanguage(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
    notifyListeners();
  }

  /// Basculer entre français et anglais
  Future<void> toggleLanguage() async {
    final newLocale = _locale.languageCode == 'fr' ? const Locale('en') : const Locale('fr');
    await setLanguage(newLocale);
  }
}


