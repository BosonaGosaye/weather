import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/utils/weather_translator.dart';
import '../../core/utils/weather_tips.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/app_constants.dart';
import '../providers/locale_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/weather_info_card.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import '../widgets/weather_chart_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _lastUpdated;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(weatherStateProvider.notifier).getWeatherByLocation();
      _loadLastUpdateTime();
    });
  }

  void _loadLastUpdateTime() {
    final box = Hive.box(AppConstants.weatherBox);
    final time = box.get('last_update_time');
    if (time != null) {
      final date = DateTime.fromMillisecondsSinceEpoch(time);
      setState(() {
        _lastUpdated = DateFormat('h:mm a').format(date);
      });
    }
  }

  List<Color> _getBackgroundColors(int conditionId, bool isDark) {
    if (isDark) {
      return [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)];
    }
    
    // Sunny/Clear
    if (conditionId == 800) {
      return [const Color(0xFF00B4DB), const Color(0xFF0083B0)]; // Deep Vibrant Blue Sky
    }
    // Cloudy (Partly to Mostly Cloudy)
    if (conditionId > 800) {
      return [const Color(0xFF2193b0), const Color(0xFF7ecce0)]; // Lighter Blue with soft grey tint
    }
    // Rain
    if (conditionId >= 500 && conditionId < 600) {
      return [const Color(0xFF485563), const Color(0xFF29323C)];
    }
    // Storm
    if (conditionId >= 200 && conditionId < 300) {
      return [const Color(0xFF1D2671), const Color(0xFFC33764)];
    }
    
    return [const Color(0xFF2193b0), const Color(0xFF6dd5ed)];
  }

  Widget _buildBackgroundDecoration(int conditionId, bool isDark) {
    if (isDark) return const SizedBox.shrink();

    // Clear Sky - Add a subtle sun glow
    if (conditionId == 800) {
      return Positioned(
        top: -100,
        right: -100,
        child: Container(
          width: 400,
          height: 400,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.yellow.withOpacity(0.3),
                Colors.yellow.withOpacity(0),
              ],
            ),
          ),
        ).animate(onPlay: (controller) => controller.repeat(reverse: true))
         .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 5.seconds),
      );
    }

    // Cloudy - Add some floating clouds
    if (conditionId > 800) {
      return Stack(
        children: [
          _buildCloud(top: 100, left: -50, opacity: 0.6, scale: 1.5, duration: 20),
          _buildCloud(top: 300, right: -100, opacity: 0.5, scale: 2, duration: 25),
          _buildCloud(top: 50, right: 50, opacity: 0.4, scale: 1, duration: 15),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildCloud({required double top, double? left, double? right, required double opacity, required double scale, required int duration}) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Icon(
        Icons.cloud_rounded,
        size: 100,
        color: Colors.white.withOpacity(opacity),
      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
       .moveX(begin: -20, end: 20, duration: duration.seconds)
       .scale(begin: Offset(scale, scale), end: Offset(scale * 1.1, scale * 1.1), duration: (duration / 2).seconds),
    );
  }

  Widget _buildGlassCard({required Widget child, Color? color}) {
    return Container(
      decoration: BoxDecoration(
        color: (color ?? Colors.white).withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: child,
      ),
    );
  }

  String _getWeatherTip(int conditionId, double temp, BuildContext context) {
    final locale = Localizations.localeOf(context);
    return WeatherTips.getTip(conditionId, temp, locale);
  }

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(weatherStateProvider);
    final forecastAsync = ref.watch(forecastProvider);
    final locationDetails = ref.watch(locationDetailsProvider);
    final favorites = ref.watch(favoritesProvider);
    final themeMode = ref.watch(themeProvider);
    final locale = Localizations.localeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.favorite_rounded, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FavoritesScreen()),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            ),
          ),
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: Colors.white,
            ),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.language_rounded, color: Colors.white),
            onSelected: (lang) {
              if (lang == 'en') ref.read(localeProvider.notifier).setLocale(const Locale('en'));
              if (lang == 'am') ref.read(localeProvider.notifier).setLocale(const Locale('am'));
              if (lang == 'om') ref.read(localeProvider.notifier).setLocale(const Locale('om'));
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'en', child: Text('English')),
              const PopupMenuItem(value: 'am', child: Text('አማርኛ')),
              const PopupMenuItem(value: 'om', child: Text('Afaan Oromoo')),
            ],
          ),
        ],
      ),
      body: weatherAsync.when(
        data: (weather) {
          if (weather == null) return const Center(child: CircularProgressIndicator(color: Colors.white));
          
          final isFavorite = favorites.contains(weather.cityName);
          final bgColors = _getBackgroundColors(weather.conditionId, isDark);
          
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: bgColors,
              ),
            ),
            child: Stack(
              children: [
                _buildBackgroundDecoration(weather.conditionId, isDark),
                RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(weatherStateProvider.notifier).getWeatherByLocation();
                    _loadLastUpdateTime();
                    return ref.refresh(forecastProvider.future);
                  },
                  child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            // Offline/Last Updated Indicator
                            if (_lastUpdated != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "Last updated: $_lastUpdated",
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ).animate().fadeIn(),
                            
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on_rounded, color: Colors.white, size: 24),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    weather.cityName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      shadows: [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2))],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    color: isFavorite ? Colors.redAccent : Colors.white70,
                                  ),
                                  onPressed: () {
                                    if (isFavorite) {
                                      ref.read(favoritesProvider.notifier).removeFavorite(weather.cityName);
                                    } else {
                                      ref.read(favoritesProvider.notifier).addFavorite(weather.cityName);
                                    }
                                  },
                                ),
                              ],
                            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
                            
                            if (locationDetails.street.isNotEmpty)
                              Text(
                                locationDetails.street,
                                style: const TextStyle(color: Colors.white70, fontSize: 16),
                              ).animate().fadeIn(delay: 200.ms),
                            
                            const SizedBox(height: 40),
                            // Weather Icon and Temp
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Hero(
                                  tag: 'weather_icon',
                                  child: Image.network(
                                    'https://openweathermap.org/img/wn/${weather.iconCode}@4x.png',
                                    height: 120, // Slightly smaller to avoid overflow
                                    color: Colors.white,
                                    colorBlendMode: BlendMode.dstIn,
                                  ),
                                ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
                                Flexible(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FittedBox(
                                        child: Text(
                                          '${weather.temperature.round()}°',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 90,
                                            fontWeight: FontWeight.w200,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        WeatherTranslator.getAllLanguagesDescription(
                                          weather.description,
                                          weather.conditionId,
                                        ).toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12, // Smaller to fit multiple languages
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.1,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn(duration: 800.ms).moveX(begin: 30, end: 0),
                              ],
                            ),
                            
                            const SizedBox(height: 40),
                            // Smart Tip Card
                            _buildGlassCard(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    const Icon(Icons.lightbulb_outline_rounded, color: Colors.yellowAccent),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _getWeatherTip(weather.conditionId, weather.temperature, context),
                                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn(delay: 400.ms).scale(),

                            const SizedBox(height: 32),
                            // Main Stats Grid
                            _buildGlassCard(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: GridView(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    mainAxisExtent: 100, // Fixed height to prevent overflow
                                  ),
                                  children: [
                                    _buildStatCard(context, AppLocalizations.of(context)!.feelsLike, '${weather.feelsLike.round()}°', Icons.thermostat_rounded, Colors.orangeAccent),
                                    _buildStatCard(context, AppLocalizations.of(context)!.humidity, '${weather.humidity}%', Icons.water_drop_rounded, Colors.blueAccent),
                                    _buildStatCard(context, AppLocalizations.of(context)!.wind, '${weather.windSpeed} ${AppLocalizations.of(context)!.windUnit}', Icons.air_rounded, Colors.greenAccent),
                                    _buildStatCard(context, AppLocalizations.of(context)!.pressure, '${weather.pressure} hPa', Icons.speed_rounded, Colors.purpleAccent),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
                            
                            const SizedBox(height: 32),
                            _buildSectionTitle(context, AppLocalizations.of(context)!.hourlyForecast),
                            const SizedBox(height: 16),
                            _buildForecastList(ref.watch(forecastProvider), locale, isHourly: true),
                            
                            const SizedBox(height: 32),
                            _buildSectionTitle(context, AppLocalizations.of(context)!.sevenDayForecast),
                            const SizedBox(height: 16),
                            _buildForecastList(ref.watch(forecast7DayProvider), locale),
                            
                            const SizedBox(height: 32),
                            _buildSectionTitle(context, AppLocalizations.of(context)!.pastSevenDays),
                            const SizedBox(height: 16),
                            _buildForecastList(ref.watch(history7DayProvider), locale),
                            
                            const SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
        loading: () => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark 
                  ? [const Color(0xFF1A237E), const Color(0xFF000000)]
                  : [const Color(0xFF42A5F5), const Color(0xFFE3F2FD)],
            ),
          ),
          child: Skeletonizer(
            enabled: true,
            child: _buildSkeleton(context),
          ),
        ),
        error: (err, _) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark 
                  ? [const Color(0xFF1A237E), const Color(0xFF000000)]
                  : [const Color(0xFF42A5F5), const Color(0xFFE3F2FD)],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_rounded, size: 80, color: Colors.white70),
                  const SizedBox(height: 16),
                  Text(
                    'Connection lost',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please check your internet and try again',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => ref.read(weatherStateProvider.notifier).getWeatherByLocation(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(AppLocalizations.of(context)!.retry),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue[900],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24).animate().rotate(duration: 500.ms),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 10), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildForecastList(AsyncValue<List<dynamic>> asyncValue, Locale locale, {bool isHourly = false}) {
    // Handle Afaan Oromo locale for DateFormat which might not be supported by default intl
    final dateLocale = locale.languageCode == 'om' ? 'en' : locale.languageCode;
    
    return SizedBox(
      height: 220,
      child: asyncValue.when(
        data: (forecasts) {
          if (forecasts.isEmpty) return const SizedBox.shrink();
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: forecasts.length,
            itemBuilder: (context, index) {
              final forecast = forecasts[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildGlassCard(
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isHourly 
                              ? DateFormat('h:mm a', dateLocale).format(forecast.date)
                              : DateFormat('EEE, d MMM', dateLocale).format(forecast.date),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Image.network(
                          'https://openweathermap.org/img/wn/${forecast.iconCode}@2x.png',
                          height: 50,
                          color: Colors.white,
                        ).animate().scale(),
                        const SizedBox(height: 8),
                        Text(
                          '${forecast.temperature.round()}°',
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Flexible(
                          child: Text(
                            WeatherTranslator.getAllLanguagesDescription(
                              forecast.description,
                              forecast.conditionId,
                            ),
                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (e, s) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Container(height: 40, width: 200, color: Colors.white),
            const SizedBox(height: 40),
            Container(height: 120, width: 120, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
            const SizedBox(height: 40),
            Container(height: 80, width: 150, color: Colors.white),
            const SizedBox(height: 20),
            Container(height: 20, width: 100, color: Colors.white),
            const SizedBox(height: 40),
            Container(height: 200, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32))),
          ],
        ),
      ),
    );
  }
}
