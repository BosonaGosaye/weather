import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'dart:math';
import '../../domain/entities/location_details.dart';
import '../../domain/entities/city.dart';
import '../constants/app_constants.dart';
import 'ethiopian_cities_data.dart';

class LocationService {
  static bool _isRequestingPermission = false;

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return await _getFallbackPosition('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (_isRequestingPermission) {
        while (_isRequestingPermission) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        permission = await Geolocator.checkPermission();
      } else {
        _isRequestingPermission = true;
        try {
          permission = await Geolocator.requestPermission();
        } finally {
          _isRequestingPermission = false;
        }
      }
      
      if (permission == LocationPermission.denied) {
        return await _getFallbackPosition('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return await _getFallbackPosition('Location permissions are permanently denied');
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (_) {
      return await _getFallbackPosition('Failed to get current position');
    }
  }

  Future<Position> _getFallbackPosition(String error) async {
    final lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) return lastKnown;

    // Fallback to Hive stored coordinates if even lastKnown is null
    try {
      final box = Hive.box(AppConstants.weatherBox);
      final lat = box.get('last_lat');
      final lon = box.get('last_lon');
      if (lat != null && lon != null) {
        return Position(
          latitude: lat,
          longitude: lon,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
    } catch (_) {}

    throw Exception(error);
  }

  // Major cities that should be prioritized when finding nearest city
  // These are the most important cities/towns in Ethiopia
  static const List<String> majorCities = [
    'Addis Ababa', 'Adama', 'Nazret', 'Dire Dawa', 'Gondar', 'Bahir Dar', 'Hawassa', 
    'Jimma', 'Jijiga', 'Adigrat', 'Shire', 'Axum', 'Mekelle', 'Harar',
    'Bishoftu', 'Kombolcha', 'Sebeta', 'Burayu', 'Ziway',
    'Ambo', 'Asella', 'Nekemte', 'Weldiya', 'Woldia',
    'Debre Birhan', 'Debre Markos', 'Finote Selam', 'Lalibela',
    'Arba Minch', 'Dilla', 'Konso', 'Wolaita Sodo', 'Hosaena',
    'Gambella', 'Asosa', 'Metu', 'Bule Hora', 'Shashamane',
  ];
  
  City? findNearestEthiopianCity(double lat, double lon) {
    if (EthiopianCitiesData.cities.isEmpty) return null;
    
    // First, check if there's a major city within a reasonable distance (80km)
    // If found, use it - this prevents showing small localities
    for (final city in EthiopianCitiesData.cities) {
      if (majorCities.any((m) => m.toLowerCase() == city.cityName.toLowerCase())) {
        final distance = _calculateDistance(lat, lon, city.latitude, city.longitude);
        if (distance <= 80) { // Within 80km - use this major city
          return city;
        }
      }
    }
    
    // If no major city within 80km, find the nearest city
    City? nearestCity;
    double minDistance = double.infinity;
    
    for (final city in EthiopianCitiesData.cities) {
      final distance = _calculateDistance(lat, lon, city.latitude, city.longitude);
      if (distance < minDistance) {
        minDistance = distance;
        nearestCity = city;
      }
    }
    
    // If the nearest city is very far (>150km), still try to find a better match
    if (minDistance > 150) {
      // Look for any major city even if farther
      for (final city in EthiopianCitiesData.cities) {
        if (majorCities.any((m) => m.toLowerCase() == city.cityName.toLowerCase())) {
          final distance = _calculateDistance(lat, lon, city.latitude, city.longitude);
          if (distance < minDistance) {
            minDistance = distance;
            nearestCity = city;
          }
        }
      }
    }
    
    return nearestCity;
  }
  
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371;
    
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  Future<LocationDetails> getPlaceMark(Position position) async {
    // Try to get location details using reverse geocoding
    try {
      // First try with geocoding package
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return LocationDetails(
          street: place.street ?? '',
          city: place.locality ?? place.subLocality ?? place.name ?? '',
          region: place.administrativeArea ?? '',
          country: place.country ?? '',
          postalCode: place.postalCode ?? '',
        );
      }
    } catch (e) {
      // If geocoding fails, try Open-Meteo reverse geocoding
      try {
        final response = await Dio().get(
          'https://geocoding-api.open-meteo.com/v1/reverse',
          queryParameters: {
            'latitude': position.latitude,
            'longitude': position.longitude,
            'count': 1,
            'language': 'en',
            'format': 'json',
          },
        );
        
        if (response.data['results'] != null && 
            (response.data['results'] as List).isNotEmpty) {
          final result = response.data['results'][0];
          return LocationDetails(
            street: '',
            city: result['name'] ?? '',
            region: result['admin1'] ?? '',
            country: result['country'] ?? '',
            postalCode: '',
          );
        }
      } catch (e2) {
        // Fallback to coordinates
      }
    }
    
    // Generic fallback using coordinates
    return LocationDetails(
      street: '',
      city: 'Lat: ${position.latitude.toStringAsFixed(2)}, Lon: ${position.longitude.toStringAsFixed(2)}',
      region: '',
      country: '',
      postalCode: '',
    );
  }
}
