import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/favorites_provider.dart';
import '../providers/weather_provider.dart';
import '../../l10n/app_localizations.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.favoriteCities),
      ),
      body: favorites.isEmpty
          ? Center(child: Text(AppLocalizations.of(context)!.noFavorites))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final city = favorites[index];
                return ListTile(
                  title: Text(city),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: AppLocalizations.of(context)!.delete,
                    onPressed: () => ref.read(favoritesProvider.notifier).removeFavorite(city),
                  ),
                  onTap: () {
                    ref.read(weatherStateProvider.notifier).getWeatherByCity(city);
                    Navigator.pop(context);
                  },
                );
              },
            ),
    );
  }
}
