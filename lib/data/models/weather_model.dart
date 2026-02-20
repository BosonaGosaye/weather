import '../../domain/entities/weather.dart';

class WeatherModel extends Weather {
  const WeatherModel({
    required super.cityName,
    required super.temperature,
    required super.description,
    required super.iconCode,
    required super.humidity,
    required super.windSpeed,
    required super.pressure,
    required super.feelsLike,
    required super.conditionId,
    required super.sunrise,
    required super.sunset,
    required super.lat,
    required super.lon,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'],
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'],
      iconCode: json['weather'][0]['icon'],
      humidity: json['main']['humidity'],
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      pressure: json['main']['pressure'],
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      conditionId: json['weather'][0]['id'],
      sunrise: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunrise'] * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunset'] * 1000),
      lat: (json['coord']['lat'] as num).toDouble(),
      lon: (json['coord']['lon'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': cityName,
      'coord': {
        'lat': lat,
        'lon': lon,
      },
      'main': {
        'temp': temperature,
        'humidity': humidity,
        'pressure': pressure,
        'feels_like': feelsLike,
      },
      'weather': [
        {'description': description, 'icon': iconCode, 'id': conditionId}
      ],
      'wind': {'speed': windSpeed},
      'sys': {
        'sunrise': sunrise.millisecondsSinceEpoch ~/ 1000,
        'sunset': sunset.millisecondsSinceEpoch ~/ 1000,
      },
    };
  }
}
