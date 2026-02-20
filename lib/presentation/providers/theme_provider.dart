import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() async {
    final box = await Hive.openBox(AppConstants.settingsBox);
    final isDark = box.get('isDark', defaultValue: null);
    if (isDark != null) {
      state = isDark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  void toggleTheme() async {
    final box = await Hive.openBox(AppConstants.settingsBox);
    if (state == ThemeMode.light) {
      state = ThemeMode.dark;
      await box.put('isDark', true);
    } else {
      state = ThemeMode.light;
      await box.put('isDark', false);
    }
  }
}
