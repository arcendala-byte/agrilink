import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'providers/language_provider.dart';
import 'localization/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final prefs = await SharedPreferences.getInstance();
  final languageCode = prefs.getString('language_code') ?? 'en';
  
  runApp(ProviderScope(
    child: MyApp(languageCode: languageCode),
  ));
}

class MyApp extends ConsumerWidget {
  final String languageCode;
  
  const MyApp({super.key, required this.languageCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageProvider = ref.watch(languageProviderNotifier);
    
    return MaterialApp(
      title: 'AgriLink',
      debugShowCheckedModeBanner: false,
      locale: languageProvider,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('sw'),
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF2E7D32),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2E7D32),
          secondary: Color(0xFF66BB6A),
          tertiary: Color(0xFFFFA726),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAF8),
      ),
      home: const SplashScreen(),
    );
  }
}

// Riverpod provider for language
final languageProviderNotifier = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('en')) {
    _loadLanguage();
  }
  
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    state = Locale(languageCode);
  }
  
  Future<void> setLanguage(String languageCode) async {
    state = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
  }
}
