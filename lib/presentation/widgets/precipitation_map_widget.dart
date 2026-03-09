import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';

class PrecipitationMapWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String cityName;
  final double? temperature;
  final String? weatherCondition;
  final double? precipitation;
  final int? precipitationProbability;
  final Function(double lat, double lon, String cityName)? onLocationSelected;

  const PrecipitationMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.cityName,
    this.temperature,
    this.weatherCondition,
    this.precipitation,
    this.precipitationProbability,
    this.onLocationSelected,
  });

  @override
  State<PrecipitationMapWidget> createState() => _PrecipitationMapWidgetState();
}

class _PrecipitationMapWidgetState extends State<PrecipitationMapWidget> {
  late final MapController _mapController;
  late LatLng _currentLocation;
  String _mapStyle = 'standard'; // standard, satellite, precipitation

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentLocation = LatLng(widget.latitude, widget.longitude);
  }

  @override
  void didUpdateWidget(PrecipitationMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude || oldWidget.longitude != widget.longitude) {
      _currentLocation = LatLng(widget.latitude, widget.longitude);
      _mapController.move(_currentLocation, 12);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Color _getPrecipitationColor(double? precip) {
    if (precip == null || precip <= 0) return Colors.grey.shade300;
    if (precip < 0.5) return Colors.lightBlue.shade200;
    if (precip < 2) return Colors.blue.shade400;
    if (precip < 5) return Colors.blue.shade700;
    if (precip < 10) return Colors.blue.shade900;
    return Colors.purple.shade900;
  }

  String _getPrecipitationLabel(double? precip) {
    if (precip == null || precip <= 0) return 'No Rain';
    if (precip < 0.5) return 'Light';
    if (precip < 2) return 'Moderate';
    if (precip < 5) return 'Heavy';
    if (precip < 10) return 'Very Heavy';
    return 'Extreme';
  }

  IconData _getWeatherIcon(String? condition) {
    if (condition == null) return Icons.cloud_outlined;
    final lower = condition.toLowerCase();
    if (lower.contains('clear') || lower.contains('sunny')) return Icons.wb_sunny_outlined;
    if (lower.contains('cloud')) return Icons.cloud_outlined;
    if (lower.contains('rain') || lower.contains('drizzle')) return Icons.water_drop_outlined;
    if (lower.contains('thunder') || lower.contains('storm')) return Icons.thunderstorm_outlined;
    if (lower.contains('snow')) return Icons.ac_unit_outlined;
    if (lower.contains('fog') || lower.contains('mist')) return Icons.foggy;
    return Icons.cloud_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        // Map Controls
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _buildMapStyleButton('standard', Icons.map_outlined, 'Map'),
              const SizedBox(width: 8),
              _buildMapStyleButton('satellite', Icons.satellite_alt_outlined, 'Satellite'),
              const SizedBox(width: 8),
              _buildMapStyleButton('precipitation', Icons.water_drop_outlined, 'Rain'),
            ],
          ),
        ),
        
        // Map View
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation,
                initialZoom: 10,
                minZoom: 5,
                maxZoom: 18,
                onTap: (tapPosition, point) async {
                  // Move map to tapped location
                  _mapController.move(point, 12);
                  
                  // Try to get location name using Nominatim reverse geocoding
                  String locationName = 'Selected Location';
                  try {
                    final response = await Dio().get(
                      'https://nominatim.openstreetmap.org/reverse',
                      queryParameters: {
                        'lat': point.latitude,
                        'lon': point.longitude,
                        'format': 'json',
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
                          locationName = country != null ? '$city, $country' : city;
                        }
                      } else {
                        final displayName = response.data['display_name'] as String?;
                        if (displayName != null && displayName.isNotEmpty) {
                          locationName = displayName.split(', ').first;
                        }
                      }
                    }
                  } catch (e) {
                    debugPrint('Reverse geocoding error: $e');
                  }
                  
                  // Notify parent widget
                  if (widget.onLocationSelected != null) {
                    widget.onLocationSelected!(point.latitude, point.longitude, locationName);
                  }
                },
              ),
              children: [
                // Base tile layer
                if (_mapStyle == 'standard')
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.weather',
                  )
                else if (_mapStyle == 'satellite')
                  TileLayer(
                    urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                    userAgentPackageName: 'com.example.weather',
                  )
                else
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.weather',
                  ),
                
                // Marker for current location with precipitation info
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation,
                      width: 60,
                      height: 70,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getPrecipitationColor(widget.precipitation),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _getPrecipitationColor(widget.precipitation).withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: Icon(
                              _getWeatherIcon(widget.weatherCondition),
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (widget.precipitation != null && widget.precipitation! > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade700,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.water_drop, color: Colors.white, size: 10),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${widget.precipitation!.toStringAsFixed(1)}mm',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Precipitation Info Card
        if (widget.cityName.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getPrecipitationColor(widget.precipitation).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: _getPrecipitationColor(widget.precipitation),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.cityName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          if (widget.weatherCondition != null)
                            Text(
                              widget.weatherCondition!,
                              style: TextStyle(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (widget.temperature != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.temperature!.round()}°C',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Precipitation details
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade700 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPrecipInfo(
                        icon: Icons.water_drop_outlined,
                        label: 'Precipitation',
                        value: widget.precipitation != null 
                            ? '${widget.precipitation!.toStringAsFixed(1)} mm' 
                            : '0 mm',
                        color: Colors.blue,
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                      ),
                      _buildPrecipInfo(
                        icon: Icons.percent,
                        label: 'Probability',
                        value: widget.precipitationProbability != null 
                            ? '${widget.precipitationProbability}%' 
                            : '0%',
                        color: Colors.teal,
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                      ),
                      _buildPrecipInfo(
                        icon: _getWeatherIcon(widget.weatherCondition),
                        label: 'Status',
                        value: _getPrecipitationLabel(widget.precipitation),
                        color: _getPrecipitationColor(widget.precipitation),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMapStyleButton(String style, IconData icon, String label) {
    final isSelected = _mapStyle == style;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _mapStyle = style;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrecipInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Full screen precipitation map view
class PrecipitationFullMapView extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String cityName;
  final double? temperature;
  final String? weatherCondition;
  final double? precipitation;
  final int? precipitationProbability;
  final VoidCallback? onClose;

  const PrecipitationFullMapView({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.cityName,
    this.temperature,
    this.weatherCondition,
    this.precipitation,
    this.precipitationProbability,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full screen precipitation map
          PrecipitationMapWidget(
            latitude: latitude,
            longitude: longitude,
            cityName: cityName,
            temperature: temperature,
            weatherCondition: weatherCondition,
            precipitation: precipitation,
            precipitationProbability: precipitationProbability,
          ),
          
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black87),
                  onPressed: onClose ?? () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
