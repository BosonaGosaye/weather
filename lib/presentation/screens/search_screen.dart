import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dio/dio.dart';
import '../providers/weather_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/utils/ethiopian_cities_data.dart';
import '../../domain/entities/city.dart';

// Global search results provider
final globalSearchProvider = FutureProvider.family<List<dynamic>, String>((ref, query) async {
  if (query.isEmpty) return [];
  
  try {
    final dio = Dio();
    final response = await dio.get(
      'https://geocoding-api.open-meteo.com/v1/search',
      queryParameters: {
        'name': query,
        'count': 20,
        'language': 'en',
        'format': 'json',
      },
    );
    
    if (response.data['results'] != null) {
      return response.data['results'] as List;
    }
  } catch (e) {
    // Return empty on error
  }
  return [];
});

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _selectedRegion = 'All';
  List<City> _filteredCities = [];
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;
  bool _isGlobalSearch = true;
  List<dynamic> _globalResults = [];
  
  // Major Ethiopian cities with coordinates
  static final List<Map<String, String>> _majorCities = [
    {'name': 'Addis Ababa', 'region': 'Addis Ababa', 'lat': '9.03', 'lon': '38.74'},
    {'name': 'Adama', 'region': 'Oromia', 'lat': '8.54', 'lon': '39.27'},
    {'name': 'Dire Dawa', 'region': 'Dire Dawa', 'lat': '9.59', 'lon': '41.87'},
    {'name': 'Gondar', 'region': 'Amhara', 'lat': '12.60', 'lon': '37.47'},
    {'name': 'Bahir Dar', 'region': 'Amhara', 'lat': '11.59', 'lon': '37.06'},
    {'name': 'Hawassa', 'region': 'Sidama', 'lat': '7.05', 'lon': '38.47'},
    {'name': 'Jimma', 'region': 'Oromia', 'lat': '7.67', 'lon': '36.83'},
    {'name': 'Jijiga', 'region': 'Somali', 'lat': '9.35', 'lon': '42.80'},
    {'name': 'Mekelle', 'region': 'Tigray', 'lat': '13.50', 'lon': '39.47'},
    {'name': 'Harar', 'region': 'Harari', 'lat': '9.31', 'lon': '42.13'},
    {'name': 'Arba Minch', 'region': 'SNNPR', 'lat': '6.04', 'lon': '37.56'},
    {'name': 'Konso', 'region': 'SNNPR', 'lat': '5.25', 'lon': '37.48'},
    {'name': 'Wolaita Sodo', 'region': 'SNNPR', 'lat': '6.90', 'lon': '37.75'},
    {'name': 'Hosaena', 'region': 'SNNPR', 'lat': '7.55', 'lon': '37.86'},
    {'name': 'Dilla', 'region': 'SNNPR', 'lat': '6.41', 'lon': '38.31'},
    {'name': 'Gambella', 'region': 'Gambella', 'lat': '8.25', 'lon': '34.50'},
    {'name': 'Asosa', 'region': 'Benishangul Gumaz', 'lat': '10.07', 'lon': '34.53'},
    {'name': 'Bishoftu', 'region': 'Oromia', 'lat': '8.75', 'lon': '38.99'},
    {'name': 'Sebeta', 'region': 'Oromia', 'lat': '8.93', 'lon': '38.62'},
    {'name': 'Burayu', 'region': 'Oromia', 'lat': '9.09', 'lon': '38.81'},
    {'name': 'Ziway', 'region': 'Oromia', 'lat': '7.93', 'lon': '38.72'},
    {'name': 'Ambo', 'region': 'Oromia', 'lat': '8.98', 'lon': '37.85'},
    {'name': 'Asella', 'region': 'Oromia', 'lat': '7.95', 'lon': '39.13'},
    {'name': 'Nekemte', 'region': 'Oromia', 'lat': '9.09', 'lon': '36.65'},
    {'name': 'Weldiya', 'region': 'Amhara', 'lat': '11.08', 'lon': '39.60'},
    {'name': 'Woldia', 'region': 'Amhara', 'lat': '11.60', 'lon': '39.60'},
    {'name': 'Debre Birhan', 'region': 'Amhara', 'lat': '9.68', 'lon': '39.53'},
    {'name': 'Debre Markos', 'region': 'Amhara', 'lat': '10.35', 'lon': '37.72'},
    {'name': 'Finote Selam', 'region': 'Amhara', 'lat': '10.70', 'lon': '37.20'},
    {'name': 'Lalibela', 'region': 'Amhara', 'lat': '12.03', 'lon': '39.04'},
  ];

  @override
  void initState() {
    super.initState();
    _filteredCities.sort((a, b) => a.cityName.compareTo(b.cityName));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      // Always do global search - worldwide weather
      if (query.length >= 1) {
        _doGlobalSearch(query);
      } else {
        // Show major cities when search is empty
        setState(() {
          _isGlobalSearch = false;
          _globalResults = [];
        });
      }
    });
  }

  Future<void> _doGlobalSearch(String query) async {
    setState(() {
      _isGlobalSearch = true;
    });
    
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://geocoding-api.open-meteo.com/v1/search',
        queryParameters: {
          'name': query,
          'count': 20,
          'language': 'en',
          'format': 'json',
        },
      );
      
      if (response.data['results'] != null && mounted) {
        setState(() {
          _globalResults = response.data['results'] as List;
        });
      }
    } catch (e) {
      // Ignore errors
    }
  }

  void _filterCities(String query) async {
    setState(() {
      _isGlobalSearch = false;
      _globalResults = [];
    });
    
    final lowercaseQuery = query.toLowerCase();
    
    // Use global search via API
    final cities = await EthiopianCitiesData.searchCities(query);
    
    setState(() {
      _filteredCities = cities;

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

  void _selectGlobalCity(dynamic result) {
    final lat = result['latitude'] as double;
    final lon = result['longitude'] as double;
    final name = result['name'] as String;
    final country = result['country'] as String? ?? '';
    final admin1 = result['admin1'] as String?;
    final displayName = admin1 != null && admin1.isNotEmpty
        ? '$name, $admin1, $country'
        : country.isNotEmpty
            ? '$name, $country'
            : name;

    ref.read(weatherStateProvider.notifier).getWeatherByCoordinates(lat, lon, cityName: displayName);
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
                  onChanged: _onSearchChanged,
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

              // Show major Ethiopian cities hint
              if (_controller.text.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Major Ethiopian Cities',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8), 
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
                        // Show major cities when search is empty, otherwise show search results
                        itemCount: _isGlobalSearch 
                            ? _globalResults.length + 1  // +1 for search globally button
                            : _majorCities.length + _filteredCities.length + (_controller.text.isNotEmpty ? 1 : 0),
                        separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.05)),
                        itemBuilder: (context, index) {
                          // Global search results
                          if (_isGlobalSearch) {
                            if (index == 0) {
                              // Show "Search for X" option that searches globally
                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.public, color: Colors.white, size: 20),
                                ),
                                title: Text(
                                  'Search "${_controller.text}" globally',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                subtitle: const Text(
                                  'Find weather anywhere in the world',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
                                onTap: () => _selectCityByName(_controller.text),
                              );
                            }
                            
                            final resultIndex = index - 1;
                            if (resultIndex >= _globalResults.length) return const SizedBox();
                            
                            final result = _globalResults[resultIndex];
                            final name = result['name'] as String? ?? '';
                            final country = result['country'] as String? ?? '';
                            final admin1 = result['admin1'] as String?; // State/Region
                            
                            return ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.public, color: Colors.white, size: 20),
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                admin1 != null ? '$admin1, $country' : country,
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
                              onTap: () => _selectGlobalCity(result),
                            );
                          }
                          
                          // Show major cities at the top when search is empty
                          if (_controller.text.isEmpty && index < _majorCities.length) {
                            final majorCity = _majorCities[index];
                            return ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.star, color: Colors.amber, size: 20),
                              ),
                              title: Text(
                                majorCity['name']!,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                majorCity['region']!,
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
                              onTap: () {
                                final lat = double.parse(majorCity['lat']!);
                                final lon = double.parse(majorCity['lon']!);
                                ref.read(weatherStateProvider.notifier).getWeatherByCoordinates(lat, lon, cityName: majorCity['name']);
                                Navigator.pop(context);
                              },
                            );
                          }

                          // Search globally option
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

                          // Adjust index for filtered cities
                          int cityIndex = _controller.text.isEmpty 
                              ? index - _majorCities.length 
                              : index - 1;
                          if (cityIndex < 0 || cityIndex >= _filteredCities.length) return const SizedBox();
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
