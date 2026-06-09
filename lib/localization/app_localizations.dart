import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizations {
  final Locale locale;
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
  
  AppLocalizations(this.locale);
  
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  String translate(String key) {
    return _localizedStrings[locale.languageCode]?[key] ?? key;
  }
  
  static final Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'welcome': 'Welcome',
      'login': 'Login',
      'register': 'Register',
      'home': 'Home',
      'market': 'Market',
      'messages': 'Messages',
      'profile': 'Profile',
      'settings': 'Settings',
      'logout': 'Logout',
    },
    'sw': {
      'welcome': 'Karibu',
      'login': 'Ingia',
      'register': 'Jisajili',
      'home': 'Nyumbani',
      'market': 'Soko',
      'messages': 'Ujumbe',
      'profile': 'Wasifu',
      'settings': 'Mipangilio',
      'logout': 'Toka',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['en', 'sw'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
