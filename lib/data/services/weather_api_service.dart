import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../models/weather_model.dart';

import '../models/forecast_model.dart';

class WeatherApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));

  Future<WeatherModel> fetchWeatherByCity(String city, {String? lang = 'en'}) async {
    try {
      final response = await _dio.get('/weather', queryParameters: {
        'q': city,
        'units': 'metric',
        'appid': AppConstants.apiKey,
        'lang': lang,
      });
      return compute(_parseWeather, response.data);
    } catch (e) {
      throw Exception('Failed to fetch weather for $city');
    }
  }

  Future<WeatherModel> fetchWeatherByLocation(double lat, double lon, {String? lang = 'en'}) async {
    try {
      final response = await _dio.get('/weather', queryParameters: {
        'lat': lat,
        'lon': lon,
        'units': 'metric',
        'appid': AppConstants.apiKey,
        'lang': lang,
      });
      return compute(_parseWeather, response.data);
    } catch (e) {
      debugPrint('Error fetching weather: $e');
      throw Exception('Failed to fetch weather for coordinates: $e');
    }
  }

  Future<List<ForecastModel>> fetchForecastByLocation(double lat, double lon, {String? lang = 'en'}) async {
    try {
      final response = await _dio.get('/forecast', queryParameters: {
        'lat': lat,
        'lon': lon,
        'units': 'metric',
        'appid': AppConstants.apiKey,
        'lang': lang,
      });
      return compute(_parseForecast, response.data);
    } catch (e) {
      throw Exception('Failed to fetch forecast');
    }
  }

  Future<List<ForecastModel>> fetch7DayForecast(double lat, double lon) async {
    try {
      final response = await Dio().get('https://api.open-meteo.com/v1/forecast', queryParameters: {
        'latitude': lat,
        'longitude': lon,
        'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
        'timezone': 'auto',
      });
      return _parseOpenMeteoForecast(response.data);
    } catch (e) {
      throw Exception('Failed to fetch 7-day forecast: $e');
    }
  }

  Future<List<ForecastModel>> fetchPast7DayHistory(double lat, double lon) async {
    try {
      final today = DateTime.now();
      final startDate = today.subtract(const Duration(days: 7));
      final endDate = today.subtract(const Duration(days: 1));
      
      final response = await Dio().get('https://archive-api.open-meteo.com/v1/archive', queryParameters: {
        'latitude': lat,
        'longitude': lon,
        'start_date': _formatDate(startDate),
        'end_date': _formatDate(endDate),
        'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
        'timezone': 'auto',
      });
      return _parseOpenMeteoForecast(response.data);
    } catch (e) {
      throw Exception('Failed to fetch past 7-day history: $e');
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  List<ForecastModel> _parseOpenMeteoForecast(dynamic data) {
    final daily = data['daily'];
    final List<dynamic> times = daily['time'];
    final List<dynamic> weatherCodes = daily['weather_code'];
    final List<dynamic> tempMax = daily['temperature_2m_max'];
    
    List<ForecastModel> forecasts = [];
    for (int i = 0; i < times.length; i++) {
      final date = DateTime.parse(times[i]);
      final code = weatherCodes[i] as int;
      final temp = tempMax[i] as double;
      
      forecasts.add(ForecastModel(
        date: date,
        temperature: temp,
        description: _mapWeatherCodeToDescription(code),
        iconCode: _mapWeatherCodeToIcon(code),
        conditionId: _mapWeatherCodeToConditionId(code),
      ));
    }
    return forecasts;
  }

  String _mapWeatherCodeToDescription(int code) {
    switch (code) {
      case 0: return 'Clear sky';
      case 1: case 2: case 3: return 'Cloudy';
      case 45: case 48: return 'Fog';
      case 51: case 53: case 55: return 'Drizzle';
      case 61: case 63: case 65: return 'Rain';
      case 71: case 73: case 75: return 'Snow';
      case 80: case 81: case 82: return 'Rain showers';
      case 95: case 96: case 99: return 'Thunderstorm';
      default: return 'Unknown';
    }
  }

  String _mapWeatherCodeToIcon(int code) {
    switch (code) {
      case 0: return '01d';
      case 1: case 2: case 3: return '03d';
      case 45: case 48: return '50d';
      case 51: case 53: case 55: return '09d';
      case 61: case 63: case 65: return '10d';
      case 71: case 73: case 75: return '13d';
      case 80: case 81: case 82: return '09d';
      case 95: case 96: case 99: return '11d';
      default: return '01d';
    }
  }

  int _mapWeatherCodeToConditionId(int code) {
    switch (code) {
      case 0: return 800;
      case 1: case 2: case 3: return 802;
      case 45: case 48: return 741;
      case 51: case 53: case 55: return 300;
      case 61: case 63: case 65: return 500;
      case 71: case 73: case 75: return 600;
      case 80: case 81: case 82: return 521;
      case 95: case 96: case 99: return 200;
      default: return 800;
    }
  }
}

// Top-level functions for compute
WeatherModel _parseWeather(dynamic data) {
  return WeatherModel.fromJson(data as Map<String, dynamic>);
}

List<ForecastModel> _parseForecast(dynamic data) {
  final List list = data['list'];
  return list.map((item) => ForecastModel.fromJson(item)).toList();
}
