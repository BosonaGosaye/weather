import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class WeatherApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://api.open-meteo.com/v1'));
  final Dio _geoDio = Dio(BaseOptions(baseUrl: 'https://geocoding-api.open-meteo.com/v1'));

  // Get city name from coordinates using Nominatim reverse geocoding
  Future<String?> getCityNameFromCoordinates(double lat, double lon, {String lang = 'en'}) async {
    try {
      final response = await Dio().get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'format': 'json',
          'accept-language': lang,
        },
        options: Options(
          headers: {'User-Agent': 'WeatherApp/1.0'},
        ),
      );

      if (response.data != null) {
        final address = response.data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final city = address['city'] ??
              address['town'] ??
              address['village'] ??
              address['municipality'] ??
              address['county'];
          final country = address['country'];
          if (city != null && (city as String).isNotEmpty) {
            return country != null ? '$city, $country' : city;
          }
        }
        final displayName = response.data['display_name'] as String?;
        if (displayName != null && displayName.isNotEmpty) {
          final parts = displayName.split(', ');
          return parts.isNotEmpty ? parts.first : displayName;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error reverse geocoding: $e');
      return null;
    }
  }

  // Open-Meteo WMO Weather code mappings
  static const Map<int, String> _weatherCodeDescriptions = {
    0: 'Clear sky',
    1: 'Mainly clear',
    2: 'Partly cloudy',
    3: 'Overcast',
    45: 'Fog',
    48: 'Depositing rime fog',
    51: 'Light drizzle',
    53: 'Moderate drizzle',
    55: 'Dense drizzle',
    56: 'Light freezing drizzle',
    57: 'Dense freezing drizzle',
    61: 'Light rain',
    63: 'Moderate rain',
    65: 'Heavy rain',
    66: 'Light freezing rain',
    67: 'Heavy freezing rain',
    71: 'Slight snow',
    73: 'Moderate snow',
    75: 'Heavy snow',
    77: 'Snow grains',
    80: 'Slight rain showers',
    81: 'Moderate rain showers',
    82: 'Violent rain showers',
    85: 'Slight snow showers',
    86: 'Heavy snow showers',
    95: 'Thunderstorm',
    96: 'Thunderstorm with slight hail',
    99: 'Thunderstorm with heavy hail',
  };

  static const Map<int, String> _weatherCodeIcons = {
    0: '01d',
    1: '01d',
    2: '02d',
    3: '04d',
    45: '50d',
    48: '50d',
    51: '09d',
    53: '09d',
    55: '09d',
    56: '13d',
    57: '13d',
    61: '10d',
    63: '10d',
    65: '10d',
    66: '13d',
    67: '13d',
    71: '13d',
    73: '13d',
    75: '13d',
    77: '13d',
    80: '09d',
    81: '09d',
    82: '09d',
    85: '13d',
    86: '13d',
    95: '11d',
    96: '11d',
    99: '11d',
  };

  // Map Open-Meteo weather codes to OpenWeatherMap-like condition IDs for compatibility
  int _mapWeatherCodeToConditionId(int code) {
    if (code == 0) return 800; // Clear
    if (code >= 1 && code <= 3) return 802; // Cloudy
    if (code >= 45 && code <= 48) return 741; // Fog
    if (code >= 51 && code <= 57) return 300; // Drizzle
    if (code >= 61 && code <= 67) return 500; // Rain
    if (code >= 71 && code <= 77) return 600; // Snow
    if (code >= 80 && code <= 82) return 521; // Rain showers
    if (code >= 85 && code <= 86) return 601; // Snow showers
    if (code >= 95) return 200; // Thunderstorm
    return 800;
  }

  String _mapWeatherCodeToDescription(int code) {
    if (code == 0) return 'Clear sky';
    if (code >= 1 && code <= 3) return 'Cloudy';
    if (code >= 45 && code <= 48) return 'Fog';
    if (code >= 51 && code <= 57) return 'Drizzle';
    if (code >= 61 && code <= 67) return 'Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Rain showers';
    if (code >= 95) return 'Thunderstorm';
    return 'Unknown';
  }

  String _mapWeatherCodeToIcon(int code) {
    if (code == 0) return '01d';
    if (code >= 1 && code <= 3) return '03d';
    if (code >= 45 && code <= 48) return '50d';
    if (code >= 51 && code <= 57) return '09d';
    if (code >= 61 && code <= 67) return '10d';
    if (code >= 71 && code <= 77) return '13d';
    if (code >= 80 && code <= 82) return '09d';
    if (code >= 95) return '11d';
    return '01d';
  }

  Future<WeatherModel> fetchWeatherByCity(String city, {String? lang = 'en'}) async {
    try {
      // First, get coordinates from city name using Open-Meteo Geocoding
      final geoResponse = await _geoDio.get('/search', queryParameters: {
        'name': city,
        'count': 1,
        'language': lang ?? 'en',
        'format': 'json',
      });

      if (geoResponse.data['results'] == null || (geoResponse.data['results'] as List).isEmpty) {
        throw Exception('City not found: $city');
      }

      final location = geoResponse.data['results'][0];
      final lat = location['latitude'] as double;
      final lon = location['longitude'] as double;
      final cityName = location['name'] as String;
      final country = location['country'] as String?;

      return fetchWeatherByLocation(lat, lon, cityName: '$cityName, $country', lang: lang);
    } catch (e) {
      throw Exception('Failed to fetch weather for $city: $e');
    }
  }

  Future<WeatherModel> fetchWeatherByLocation(double lat, double lon, {String? lang = 'en', String? cityName}) async {
    try {
      // If no cityName provided, get it from reverse geocoding
      String? resolvedCityName = cityName;
      if (resolvedCityName == null || resolvedCityName.isEmpty) {
        resolvedCityName = await getCityNameFromCoordinates(lat, lon, lang: lang ?? 'en');
      }
      
      final response = await _dio.get('/forecast', queryParameters: {
        'latitude': lat,
        'longitude': lon,
        'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,pressure_msl,wind_speed_10m,is_day,precipitation,rain,showers,snowfall',
        'hourly': 'precipitation_probability,precipitation',
        'timezone': 'auto',
        'lang': lang ?? 'en',
      });

      return _parseOpenMeteoWeather(response.data, lat, lon, resolvedCityName);
    } catch (e) {
      debugPrint('Error fetching weather: $e');
      throw Exception('Failed to fetch weather for coordinates: $e');
    }
  }

  WeatherModel _parseOpenMeteoWeather(dynamic data, double lat, double lon, String? cityName) {
    final current = data['current'];
    
    // Handle weather code - can be int or double
    final weatherCodeNum = current['weather_code'];
    final weatherCode = (weatherCodeNum is int) ? weatherCodeNum : (weatherCodeNum as num).toInt();
    
    final description = _weatherCodeDescriptions[weatherCode] ?? 'Unknown';
    final iconCode = _weatherCodeIcons[weatherCode] ?? '01d';
    final conditionId = _mapWeatherCodeToConditionId(weatherCode);
    
    // Handle is_day - can be int or double
    final isDayNum = current['is_day'];
    final isDay = (isDayNum == 1) || (isDayNum == 1.0);
    
    // Adjust icon for night time
    final actualIconCode = isDay ? iconCode : iconCode.replaceAll('d', 'n');

    // Get current time for sunrise/sunset (approximate using timezone)
    final now = DateTime.now().toUtc();
    
    // Handle humidity - can be int or double
    final humidityNum = current['relative_humidity_2m'];
    final humidity = (humidityNum is int) ? humidityNum : (humidityNum as num).toInt();
    
    // Handle pressure - can be int or double
    final pressureNum = current['pressure_msl'];
    final pressure = (pressureNum is int) ? pressureNum : (pressureNum as num).toInt();
    
    // Handle precipitation - can be int, double, or null
    double precipitation = 0.0;
    if (current['precipitation'] != null) {
      precipitation = (current['precipitation'] as num?)?.toDouble() ?? 0.0;
    }
    
    // Handle rain
    double rainAmount = 0.0;
    if (current['rain'] != null) {
      rainAmount = (current['rain'] as num?)?.toDouble() ?? 0.0;
    }
    
    // Use rain amount if available, otherwise use precipitation
    final totalPrecipitation = rainAmount > 0 ? rainAmount : precipitation;
    
    return WeatherModel(
      cityName: cityName ?? 'Unknown Location',
      temperature: (current['temperature_2m'] as num).toDouble(),
      description: description,
      iconCode: actualIconCode,
      humidity: humidity,
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      pressure: pressure,
      feelsLike: (current['apparent_temperature'] as num).toDouble(),
      conditionId: conditionId,
      sunrise: now.subtract(const Duration(hours: 6)), // Approximate
      sunset: now.add(const Duration(hours: 6)), // Approximate
      lat: lat,
      lon: lon,
      precipitation: totalPrecipitation,
    );
  }

  Future<List<ForecastModel>> fetchForecastByLocation(double lat, double lon, {String? lang = 'en'}) async {
    try {
      final response = await _dio.get('/forecast', queryParameters: {
        'latitude': lat,
        'longitude': lon,
        'hourly': 'temperature_2m,weather_code,precipitation_probability,precipitation',
        'forecast_days': 2,
        'timezone': 'auto',
        'lang': lang ?? 'en',
      });
      return _parseOpenMeteoHourlyForecast(response.data);
    } catch (e) {
      throw Exception('Failed to fetch forecast: $e');
    }
  }

  List<ForecastModel> _parseOpenMeteoHourlyForecast(dynamic data) {
    final hourly = data['hourly'];
    final List<dynamic> times = hourly['time'];
    final List<dynamic> weatherCodes = hourly['weather_code'];
    final List<dynamic> temps = hourly['temperature_2m'];
    final List<dynamic>? precipProb = hourly['precipitation_probability'];
    final List<dynamic>? precipAmount = hourly['precipitation'];
    
    List<ForecastModel> forecasts = [];
    for (int i = 0; i < times.length; i++) {
      final date = DateTime.parse(times[i]);
      final code = weatherCodes[i] as int;
      final temp = (temps[i] as num).toDouble();
      
      // Get precipitation probability (can be null)
      int? precipProbability;
      if (precipProb != null && precipProb[i] != null) {
        precipProbability = (precipProb[i] as num).toInt();
      }
      
      // Get precipitation amount (can be null)
      double? precipAmt;
      if (precipAmount != null && precipAmount[i] != null) {
        precipAmt = (precipAmount[i] as num).toDouble();
      }
      
      forecasts.add(ForecastModel(
        date: date,
        temperature: temp,
        description: _mapWeatherCodeToDescription(code),
        iconCode: _mapWeatherCodeToIcon(code),
        conditionId: _mapWeatherCodeToConditionId(code),
        precipitationProbability: precipProbability,
        precipitationAmount: precipAmt,
      ));
    }
    return forecasts;
  }

  Future<List<ForecastModel>> fetch7DayForecast(double lat, double lon) async {
    try {
      final response = await _dio.get('/forecast', queryParameters: {
        'latitude': lat,
        'longitude': lon,
        'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max',
        'timezone': 'auto',
      });
      return _parseOpenMeteoDailyForecast(response.data);
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
      return _parseOpenMeteoDailyForecast(response.data);
    } catch (e) {
      throw Exception('Failed to fetch past 7-day history: $e');
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  List<ForecastModel> _parseOpenMeteoDailyForecast(dynamic data) {
    final daily = data['daily'];
    final List<dynamic> times = daily['time'];
    final List<dynamic> weatherCodes = daily['weather_code'];
    final List<dynamic> tempMax = daily['temperature_2m_max'];
    final List<dynamic>? precipSum = daily['precipitation_sum'];
    final List<dynamic>? precipProbMax = daily['precipitation_probability_max'];
    
    List<ForecastModel> forecasts = [];
    for (int i = 0; i < times.length; i++) {
      final date = DateTime.parse(times[i]);
      final code = weatherCodes[i] as int;
      final temp = (tempMax[i] as num).toDouble();
      
      // Get precipitation sum (can be null)
      double? precipAmount;
      if (precipSum != null && precipSum[i] != null) {
        precipAmount = (precipSum[i] as num).toDouble();
      }
      
      // Get precipitation probability max (can be null)
      int? precipProbability;
      if (precipProbMax != null && precipProbMax[i] != null) {
        precipProbability = (precipProbMax[i] as num).toInt();
      }
      
      forecasts.add(ForecastModel(
        date: date,
        temperature: temp,
        description: _mapWeatherCodeToDescription(code),
        iconCode: _mapWeatherCodeToIcon(code),
        conditionId: _mapWeatherCodeToConditionId(code),
        precipitationProbability: precipProbability,
        precipitationAmount: precipAmount,
      ));
    }
    return forecasts;
  }
}
