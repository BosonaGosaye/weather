import '../entities/weather.dart';
import '../repositories/weather_repository.dart';

class GetWeather {
  final WeatherRepository repository;

  GetWeather(this.repository);

  Future<Weather> byCity(String city, {String? lang}) {
    return repository.getWeatherByCity(city, lang: lang);
  }

  Future<Weather> byLocation(double lat, double lon, {String? lang}) {
    return repository.getWeatherByLocation(lat, lon, lang: lang);
  }
}
