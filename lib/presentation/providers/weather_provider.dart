import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../data/services/weather_api_service.dart';
import '../../domain/entities/weather.dart';
import '../../domain/entities/forecast.dart';
import '../../domain/usecases/get_weather.dart';
import '../../core/utils/location_service.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/location_details.dart';
import 'locale_provider.dart';

final weatherApiServiceProvider = Provider((ref) => WeatherApiService());

final weatherRepositoryProvider = Provider((ref) {
  final apiService = ref.watch(weatherApiServiceProvider);
  return WeatherRepositoryImpl(apiService);
});

final getWeatherProvider = Provider((ref) {
  final repository = ref.watch(weatherRepositoryProvider);
  return GetWeather(repository);
});

final locationServiceProvider = Provider((ref) => LocationService());

final forecastProvider = FutureProvider.autoDispose<List<Forecast>>((ref) async {
  final weatherAsync = ref.watch(weatherStateProvider);
  final weather = weatherAsync.asData?.value;
  
  if (weather == null) return [];

  final repository = ref.watch(weatherRepositoryProvider);
  final locale = ref.watch(localeProvider);
  return repository.getForecastByLocation(weather.lat, weather.lon, lang: locale.languageCode);
});

final forecast7DayProvider = FutureProvider.autoDispose<List<Forecast>>((ref) async {
  final weatherAsync = ref.watch(weatherStateProvider);
  final weather = weatherAsync.asData?.value;
  
  if (weather == null) return [];
  
  final repository = ref.watch(weatherRepositoryProvider);
  return repository.get7DayForecast(weather.lat, weather.lon);
});

final history7DayProvider = FutureProvider.autoDispose<List<Forecast>>((ref) async {
  final weatherAsync = ref.watch(weatherStateProvider);
  final weather = weatherAsync.asData?.value;
  
  if (weather == null) return [];

  final repository = ref.watch(weatherRepositoryProvider);
  return repository.getPast7DayHistory(weather.lat, weather.lon);
});

final weatherStateProvider = StateNotifierProvider<WeatherNotifier, AsyncValue<Weather?>>((ref) {
  return WeatherNotifier(
    ref.watch(getWeatherProvider),
    ref.watch(locationServiceProvider),
    ref,
  );
});

final locationDetailsProvider = StateNotifierProvider<LocationDetailsNotifier, LocationDetails>((ref) {
  return LocationDetailsNotifier(ref.watch(locationServiceProvider));
});

class LocationDetailsNotifier extends StateNotifier<LocationDetails> {
  final LocationService _locationService;
  LocationDetailsNotifier(this._locationService) : super(const LocationDetails());

  Future<void> updateLocation(double lat, double lon) async {
    try {
        final position = Position(
            longitude: lon,
            latitude: lat,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0, 
            altitudeAccuracy: 0, 
            headingAccuracy: 0,
        );
        final details = await _locationService.getPlaceMark(position);
        state = details;
    } catch (_) {}
  }
}

class WeatherNotifier extends StateNotifier<AsyncValue<Weather?>> {
  final GetWeather _getWeather;
  final LocationService _locationService;
  final Ref _ref;

  WeatherNotifier(this._getWeather, this._locationService, this._ref) : super(const AsyncValue.data(null));

  Future<void> getWeatherByLocation() async {
    state = const AsyncValue.loading();
    try {
      final position = await _locationService.getCurrentLocation();
      // Update location details in parallel
      _ref.read(locationDetailsProvider.notifier).updateLocation(position.latitude, position.longitude);
      
      final locale = _ref.read(localeProvider);
      final weather = await _getWeather.byLocation(position.latitude, position.longitude, lang: locale.languageCode);
      state = AsyncValue.data(weather);
    } catch (e, st) {
      // Try to load cached weather on error
      try {
        final weather = await _ref.read(weatherRepositoryProvider).getWeatherByCity(''); 
        if (weather != null) {
          _ref.read(locationDetailsProvider.notifier).updateLocation(weather.lat, weather.lon);
          state = AsyncValue.data(weather);
        } else {
          state = AsyncValue.error(e, st);
        }
      } catch (_) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> getWeatherByCoordinates(double lat, double lon) async {
    state = const AsyncValue.loading();
    try {
      final locale = _ref.read(localeProvider);
      // Update location details
      _ref.read(locationDetailsProvider.notifier).updateLocation(lat, lon);
      
      final weather = await _getWeather.byLocation(lat, lon, lang: locale.languageCode);
      state = AsyncValue.data(weather);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> getWeatherByCity(String city) async {
    state = const AsyncValue.loading();
    try {
      final locale = _ref.read(localeProvider);
      final weather = await _getWeather.byCity(city, lang: locale.languageCode);
      state = AsyncValue.data(weather);
    } catch (e, st) {
      // Try to load cached weather on error
      try {
        final weather = await _ref.read(weatherRepositoryProvider).getWeatherByCity(city);
        state = AsyncValue.data(weather);
      } catch (_) {
        state = AsyncValue.error(e, st);
      }
    }
  }
}
