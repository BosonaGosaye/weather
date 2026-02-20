import 'package:equatable/equatable.dart';

class City extends Equatable {
  final String id;
  final String cityName;
  final String region;
  final double latitude;
  final double longitude;
  final String? elevation;
  final String? timezone;

  const City({
    required this.id,
    required this.cityName,
    required this.region,
    required this.latitude,
    required this.longitude,
    this.elevation,
    this.timezone,
  });

  @override
  List<Object?> get props => [id, cityName, region, latitude, longitude];
}
