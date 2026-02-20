import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hive_flutter/hive_flutter.dart';
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

  City? findNearestEthiopianCity(double lat, double lon) {
    if (EthiopianCitiesData.cities.isEmpty) return null;
    
    City? nearestCity;
    double minDistance = double.infinity;
    
    for (final city in EthiopianCitiesData.cities) {
      final distance = _calculateDistance(lat, lon, city.latitude, city.longitude);
      if (distance < minDistance) {
        minDistance = distance;
        nearestCity = city;
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
    final nearestCity = findNearestEthiopianCity(position.latitude, position.longitude);
    
    if (nearestCity != null) {
      return LocationDetails(
        street: '',
        city: nearestCity.cityName,
        region: nearestCity.region,
        country: 'Ethiopia',
        postalCode: '',
      );
    }
    
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return LocationDetails(
          street: place.street ?? '',
          city: place.locality ?? place.subLocality ?? '',
          region: place.administrativeArea ?? '',
          country: place.country ?? '',
          postalCode: place.postalCode ?? '',
        );
      }
      return const LocationDetails();
    } catch (e) {
      return const LocationDetails();
    }
  }
}
