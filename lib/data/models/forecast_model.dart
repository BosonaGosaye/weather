import '../../domain/entities/forecast.dart';

class ForecastModel extends Forecast {
  const ForecastModel({
    required super.date,
    required super.temperature,
    required super.description,
    required super.iconCode,
    required super.conditionId,
    super.precipitationProbability,
    super.precipitationAmount,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      date: json['dt'] is int 
          ? DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000)
          : DateTime.parse(json['dt']),
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'],
      iconCode: json['weather'][0]['icon'],
      conditionId: json['weather'][0]['id'],
      precipitationProbability: (json['precipitation_probability'] as num?)?.toInt(),
      precipitationAmount: (json['precipitation'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dt': date.toIso8601String(),
      'main': {'temp': temperature},
      'weather': [
        {'description': description, 'icon': iconCode, 'id': conditionId}
      ],
      'precipitation_probability': precipitationProbability,
      'precipitation': precipitationAmount,
    };
  }
}
