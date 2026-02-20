import '../entities/weather.dart';
import '../entities/forecast.dart';

abstract class WeatherRepository {
  Future<Weather> getWeatherByCity(String city, {String? lang});
  Future<Weather> getWeatherByLocation(double lat, double lon, {String? lang});
  Future<List<Forecast>> getForecastByLocation(double lat, double lon, {String? lang});
  Future<List<Forecast>> get7DayForecast(double lat, double lon);
  Future<List<Forecast>> getPast7DayHistory(double lat, double lon);
}
