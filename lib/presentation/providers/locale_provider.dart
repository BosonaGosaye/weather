import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadLocale();
  }

  void _loadLocale() async {
    final box = await Hive.openBox(AppConstants.settingsBox);
    final languageCode = box.get('language_code', defaultValue: 'en');
    state = Locale(languageCode);
  }

  void setLocale(Locale __locale) async {
    state = __locale;
    final box = await Hive.openBox(AppConstants.settingsBox);
    await box.put('language_code', __locale.languageCode);
  }
}
