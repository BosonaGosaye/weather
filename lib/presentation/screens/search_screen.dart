import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/weather_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/utils/ethiopian_cities_data.dart';
import '../../domain/entities/city.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _selectedRegion = 'All';
  List<City> _filteredCities = List.from(EthiopianCitiesData.cities);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _filteredCities.sort((a, b) => a.cityName.compareTo(b.cityName));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _filterCities(String query) {
    setState(() {
      final lowercaseQuery = query.toLowerCase();
      
      _filteredCities = EthiopianCitiesData.cities.where((city) {
        final cityName = city.cityName.toLowerCase();
        final matchesQuery = lowercaseQuery.isEmpty || cityName.contains(lowercaseQuery);
        final matchesRegion = _selectedRegion == 'All' || city.region == _selectedRegion;
        return matchesQuery && matchesRegion;
      }).toList();

      // Sort: prioritize those that start with query, then alphabetical
      _filteredCities.sort((a, b) {
        if (lowercaseQuery.isEmpty) {
          return a.cityName.compareTo(b.cityName);
        }
        final aName = a.cityName.toLowerCase();
        final bName = b.cityName.toLowerCase();
        final aStarts = aName.startsWith(lowercaseQuery);
        final bStarts = bName.startsWith(lowercaseQuery);

        if (aStarts && !bStarts) return -1;
        if (!aStarts && bStarts) return 1;
        return aName.compareTo(bName);
      });
    });
  }

  void _selectCity(City city) {
    ref.read(weatherStateProvider.notifier).getWeatherByCoordinates(city.latitude, city.longitude);
    Navigator.pop(context);
  }

  void _selectCityByName(String name) {
    ref.read(weatherStateProvider.notifier).getWeatherByCity(name);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.searchCity,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1A237E), const Color(0xFF000000)]
                : [const Color(0xFF42A5F5), const Color(0xFF1A237E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _controller,
                  onChanged: _filterCities,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.search,
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ).animate().fadeIn().slideY(begin: -0.2, end: 0),

              // Region Filter
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: EthiopianCitiesData.regions.length,
                  itemBuilder: (context, index) {
                    final region = EthiopianCitiesData.regions[index];
                    final isSelected = _selectedRegion == region;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(region),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedRegion = region;
                            _filterCities(_controller.text);
                          });
                        },
                        selectedColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.blue[900] : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: Colors.white.withOpacity(0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    );
                  },
                ),
              ).animate().fadeIn(delay: 100.ms),

              // Cities List
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      thickness: 6,
                      radius: const Radius.circular(10),
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredCities.length + (_controller.text.isNotEmpty ? 1 : 0),
                        separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.05)),
                        itemBuilder: (context, index) {
                          if (_controller.text.isNotEmpty && index == 0) {
                            return ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.search, color: Colors.white, size: 20),
                              ),
                              title: Text(
                                'Search for "${_controller.text}"',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              subtitle: const Text(
                                'Search globally',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              trailing: const Icon(Icons.public, color: Colors.white30, size: 16),
                              onTap: () => _selectCityByName(_controller.text),
                            );
                          }

                          final cityIndex = _controller.text.isNotEmpty ? index - 1 : index;
                          final city = _filteredCities[cityIndex];
                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.location_city, color: Colors.white, size: 20),
                            ),
                            title: Text(
                              city.cityName,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              city.region,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
                            onTap: () => _selectCity(city),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}
