import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<String>>((ref) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<List<String>> {
  FavoritesNotifier() : super([]) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final box = await Hive.openBox(AppConstants.settingsBox);
    final List<String> favorites = List<String>.from(box.get('favorites', defaultValue: []));
    state = favorites;
  }

  Future<void> addFavorite(String city) async {
    if (!state.contains(city)) {
      state = [...state, city];
      final box = await Hive.openBox(AppConstants.settingsBox);
      await box.put('favorites', state);
    }
  }

  Future<void> removeFavorite(String city) async {
    state = state.where((item) => item != city).toList();
    final box = await Hive.openBox(AppConstants.settingsBox);
    await box.put('favorites', state);
  }
}
