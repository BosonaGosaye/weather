import 'package:equatable/equatable.dart';

class Weather extends Equatable {
  final String cityName;
  final double temperature;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final double feelsLike;
  final int conditionId;
  final DateTime sunrise;
  final DateTime sunset;
  final double lat;
  final double lon;

  const Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.feelsLike,
    required this.conditionId,
    required this.sunrise,
    required this.sunset,
    required this.lat,
    required this.lon,
  });

  @override
  List<Object?> get props => [
        cityName,
        temperature,
        description,
        iconCode,
        humidity,
        windSpeed,
        pressure,
        feelsLike,
        conditionId,
        sunrise,
        sunset,
        lat,
        lon,
      ];
}
