import 'package:equatable/equatable.dart';

class Forecast extends Equatable {
  final DateTime date;
  final double temperature;
  final String description;
  final String iconCode;
  final int conditionId;
  final int? precipitationProbability;
  final double? precipitationAmount;

  const Forecast({
    required this.date,
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.conditionId,
    this.precipitationProbability,
    this.precipitationAmount,
  });

  @override
  List<Object?> get props => [date, temperature, description, iconCode, conditionId, precipitationProbability, precipitationAmount];
}
