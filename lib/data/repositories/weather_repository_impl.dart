import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../models/weather_model.dart';
import '../services/weather_api_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/ethiopian_cities_data.dart';
import 'dart:math';

import '../../domain/entities/forecast.dart';

import '../models/forecast_model.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherApiService apiService;

  WeatherRepositoryImpl(this.apiService);

  String _findNearestEthiopianCityName(double lat, double lon) {
    if (EthiopianCitiesData.cities.isEmpty) return '';
    
    var nearestCity = EthiopianCitiesData.cities.first;
    double minDistance = double.infinity;
    
    for (final city in EthiopianCitiesData.cities) {
      final distance = _calculateDistance(lat, lon, city.latitude, city.longitude);
      if (distance < minDistance) {
        minDistance = distance;
        nearestCity = city;
      }
    }
    
    return nearestCity.cityName;
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

  @override
  Future<Weather> getWeatherByCity(String city, {String? lang}) async {
    try {
      final weather = await apiService.fetchWeatherByCity(city, lang: lang);
      await _cacheWeather(weather);
      return weather;
    } catch (e) {
      return _getCachedWeather(city: city) ?? (throw e);
    }
  }

  @override
  Future<Weather> getWeatherByLocation(double lat, double lon, {String? lang}) async {
    try {
      final weather = await apiService.fetchWeatherByLocation(lat, lon, lang: lang);
      final ethiopianCityName = _findNearestEthiopianCityName(lat, lon);
      
      final updatedWeather = ethiopianCityName.isNotEmpty
          ? WeatherModel(
              cityName: ethiopianCityName,
              temperature: weather.temperature,
              description: weather.description,
              iconCode: weather.iconCode,
              humidity: weather.humidity,
              windSpeed: weather.windSpeed,
              pressure: weather.pressure,
              feelsLike: weather.feelsLike,
              conditionId: weather.conditionId,
              sunrise: weather.sunrise,
              sunset: weather.sunset,
              lat: weather.lat,
              lon: weather.lon,
            )
          : weather;
      
      await _cacheWeather(updatedWeather as WeatherModel);
      return updatedWeather;
    } catch (e) {
      return _getCachedWeather() ?? (throw e);
    }
  }

  @override
  Future<List<Forecast>> getForecastByLocation(double lat, double lon, {String? lang}) async {
    try {
      final forecast = await apiService.fetchForecastByLocation(lat, lon, lang: lang);
      await _cacheForecast(forecast);
      return forecast;
    } catch (e) {
      return _getCachedForecast() ?? (throw e);
    }
  }

  @override
  Future<List<Forecast>> get7DayForecast(double lat, double lon) async {
    return await apiService.fetch7DayForecast(lat, lon);
  }

  @override
  Future<List<Forecast>> getPast7DayHistory(double lat, double lon) async {
    return await apiService.fetchPast7DayHistory(lat, lon);
  }

  Future<void> _cacheWeather(WeatherModel weather) async {
    final box = await Hive.openBox(AppConstants.weatherBox);
    await box.put('current_weather', weather.toJson());
    await box.put('last_update_time', DateTime.now().millisecondsSinceEpoch);
    // Cache by city name for offline search/favorites
    await box.put('city_${weather.cityName.toLowerCase()}', weather.toJson());
    // Also store last position for fallback
    await box.put('last_lat', weather.lat);
    await box.put('last_lon', weather.lon);
  }

  Weather? _getCachedWeather({String? city}) {
    final box = Hive.box(AppConstants.weatherBox);
    final data = city != null && city.isNotEmpty
        ? box.get('city_${city.toLowerCase()}')
        : box.get('current_weather');
    
    if (data != null) {
      return WeatherModel.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  Future<void> _cacheForecast(List<Forecast> forecast) async {
    final box = await Hive.openBox(AppConstants.weatherBox);
    final data = forecast.map((f) => (f as ForecastModel).toJson()).toList();
    await box.put('forecast', data);
  }

  List<Forecast>? _getCachedForecast() {
    final box = Hive.box(AppConstants.weatherBox);
    final data = box.get('forecast');
    if (data != null) {
      return (data as List)
          .map((f) => ForecastModel.fromJson(Map<String, dynamic>.from(f)))
          .toList();
    }
    return null;
  }
}
