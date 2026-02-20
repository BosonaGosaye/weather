import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home_screen.dart';
import 'l10n/app_localizations.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox(AppConstants.settingsBox),
    Hive.openBox(AppConstants.weatherBox),
  ]);
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    
    return MaterialApp(
      title: 'BSG Weather',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,

      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        // Fallback for unsupported locales (like 'om') to use 'en' strings
        _FallbackMaterialLocalizationsDelegate(),
        _FallbackCupertinoLocalizationsDelegate(),
        _FallbackWidgetsLocalizationsDelegate(),
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeScreen(),
    );
  }
}

class _FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'om';
  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      const DefaultMaterialLocalizations();
  @override
  bool shouldReload(_) => false;
}

class _FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'om';
  @override
  Future<CupertinoLocalizations> load(Locale locale) async =>
      const DefaultCupertinoLocalizations();
  @override
  bool shouldReload(_) => false;
}

class _FallbackWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'om';
  @override
  Future<WidgetsLocalizations> load(Locale locale) async =>
      const DefaultWidgetsLocalizations();
  @override
  bool shouldReload(_) => false;
}
