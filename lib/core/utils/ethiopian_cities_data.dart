import '../../domain/entities/city.dart';
import 'package:dio/dio.dart';

class EthiopianCitiesData {
  // Global cities loaded from Open-Meteo
  static List<City> _cities = [];
  
  // Flag to track if data is loaded
  static bool _isLoaded = false;
  
  // Getter for cities
  static List<City> get cities {
    if (!_isLoaded) {
      _loadCitiesSync();
    }
    return _cities;
  }
  
  // Load cities from Open-Meteo Geocoding API (global)
  static Future<void> _loadCitiesAsync() async {
    try {
      // Search for cities globally
      final response = await Dio().get(
        'https://geocoding-api.open-meteo.com/v1/search',
        queryParameters: {
          'name': '',
          'count': 100,
          'language': 'en',
          'format': 'json',
        },
      );
      
      if (response.data['results'] != null) {
        final results = response.data['results'] as List;
        int index = 0;
        _cities = results.map((json) => City(
          id: (index++).toString(),
          cityName: json['name'] ?? '',
          region: json['admin1'] ?? json['country'] ?? '',
          latitude: (json['latitude'] as num).toDouble(),
          longitude: (json['longitude'] as num).toDouble(),
        )).toList();
        _isLoaded = true;
      }
    } catch (e) {
      print('Error loading global cities: $e');
      _isLoaded = true;
    }
  }
  
  // Sync wrapper
  static void _loadCitiesSync() {
    _loadCitiesAsync();
  }
  
  // Search cities by name
  static Future<List<City>> searchCities(String query) async {
    if (query.isEmpty) return [];
    
    try {
      final response = await Dio().get(
        'https://geocoding-api.open-meteo.com/v1/search',
        queryParameters: {
          'name': query,
          'count': 20,
          'language': 'en',
          'format': 'json',
        },
      );
      
      if (response.data['results'] != null) {
        final results = response.data['results'] as List;
        int index = 0;
        return results.map((json) => City(
          id: (index++).toString(),
          cityName: json['name'] ?? '',
          region: json['admin1'] ?? json['country'] ?? '',
          latitude: (json['latitude'] as num).toDouble(),
          longitude: (json['longitude'] as num).toDouble(),
        )).toList();
      }
    } catch (e) {
      print('Error searching cities: $e');
    }
    return [];
  }
  
  // Get city by coordinates (reverse geocoding)
  static Future<City?> getCityFromCoordinates(double lat, double lon) async {
    try {
      final response = await Dio().get(
        'https://geocoding-api.open-meteo.com/v1/reverse',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'count': 1,
          'language': 'en',
          'format': 'json',
        },
      );
      
      if (response.data['results'] != null && 
          (response.data['results'] as List).isNotEmpty) {
        final json = response.data['results'][0];
        return City(
          id: '0',
          cityName: json['name'] ?? '',
          region: json['admin1'] ?? json['country'] ?? '',
          latitude: (json['latitude'] as num).toDouble(),
          longitude: (json['longitude'] as num).toDouble(),
        );
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
    }
    return null;
  }
}
