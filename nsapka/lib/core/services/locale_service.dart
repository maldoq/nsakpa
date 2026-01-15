import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  static final LocaleService _instance = LocaleService._internal();
  factory LocaleService() => _instance;
  LocaleService._internal();

  Locale _locale = const Locale('fr');
  Locale get locale => _locale;

  /// Langues supportées
  static const List<Locale> supportedLocales = [
    Locale('fr', 'FR'), // Français
    Locale('en', 'US'), // Anglais
  ];

  /// Initialise la locale depuis SharedPreferences
  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode') ?? 'fr';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  /// Change la langue
  Future<void> setLocale(String languageCode) async {
    if (_locale.languageCode != languageCode) {
      _locale = Locale(languageCode);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('languageCode', languageCode);
      notifyListeners();
    }
  }

  /// Obtient le nom de la langue actuelle
  String getLanguageName() {
    switch (_locale.languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      default:
        return 'Français';
    }
  }
}
