import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/weather.dart';
import '../../domain/entities/forecast.dart';
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
import '../widgets/weather_particles.dart';

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
    // Night/Clear
    if (isDark) {
      return [const Color(0xFF0F172A), const Color(0xFF1E293B)]; // Rich Dark Slate for Dark Mode
    }
    
    // Sunny/Clear
    if (conditionId == 800) {
      return [const Color(0xFF4FACFE), const Color(0xFF00F2FE)]; // Vibrant Modern Blue
    }
    // Cloudy
    if (conditionId > 800) {
      return [const Color(0xFF6190E8), const Color(0xFFA7BFE8)]; // Modern Soft Blue/Grey
    }
    // Rain
    if (conditionId >= 500 && conditionId < 600) {
      return [const Color(0xFF2B32B2), const Color(0xFF1488CC)];
    }
    // Storm
    if (conditionId >= 200 && conditionId < 300) {
      return [const Color(0xFF0F0C29), const Color(0xFF302B63), const Color(0xFF24243E)];
    }
    // Snow
    if (conditionId >= 600 && conditionId < 700) {
      return [const Color(0xFF83a4d4), const Color(0xFFb6fbff)];
    }
    
    return isDark 
        ? [const Color(0xFF1a2a6c), const Color(0xFFb21f1f), const Color(0xFFfdbb2d)]
        : [const Color(0xFF2193b0), const Color(0xFF6dd5ed)];
  }

  Widget _buildBackgroundDecoration(int conditionId, bool isDark) {
    // Night/Clear - Add a subtle moon glow
    if (isDark && conditionId == 800) {
      return Positioned(
        top: -100,
        right: -100,
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF94A3B8).withOpacity(0.15),
                const Color(0xFF94A3B8).withOpacity(0),
              ],
            ),
          ),
        ),
      ).animate().scale(duration: 2.seconds, curve: Curves.easeOut);
    }

    if (isDark) return const SizedBox.shrink();

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

  Widget _buildGlassCard({required Widget child, BuildContext? context, Color? color, double blur = 15, double opacity = 0.12}) {
    final isDark = context != null ? Theme.of(context).brightness == Brightness.dark : false;
    return Container(
      decoration: BoxDecoration(
        color: (color ?? (isDark ? Colors.black : Colors.white)).withOpacity(isDark ? 0.25 : opacity),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: (isDark ? Colors.white10 : Colors.white).withOpacity(0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: child,
        ),
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
                Positioned.fill(
                  child: WeatherParticles(conditionId: weather.conditionId),
                ),
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
                            
                            if (locationDetails.region.isNotEmpty)
                              Text(
                                locationDetails.region,
                                style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                              ).animate().fadeIn(delay: 200.ms),
                            
                            const SizedBox(height: 40),
                            // Weather Icon and Temp
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Hero(
                                  tag: 'weather_icon',
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isDark ? Colors.blue : Colors.white).withOpacity(0.25),
                                          blurRadius: 50,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Image.network(
                                      'https://openweathermap.org/img/wn/${weather.iconCode}@4x.png',
                                      height: 140, // Increased size
                                      color: Colors.white,
                                      colorBlendMode: BlendMode.dstIn,
                                    ),
                                  ),
                                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                                 .scale(duration: 1.seconds, curve: Curves.easeInOut)
                                 .moveY(begin: -5, end: 5, duration: 2.seconds)
                                 .then()
                                 .shimmer(duration: 3.seconds, color: Colors.white.withOpacity(0.2)),
                                Flexible(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start, // Align to start
                                    children: [
                                      FittedBox(
                                        child: Text(
                                          '${weather.temperature.round()}°',
                                          style: TextStyle(
                                            color: isDark ? Colors.white : Colors.white,
                                            fontSize: 100, // Even larger
                                            fontWeight: FontWeight.w100, // Thinner for modern look
                                            letterSpacing: -4,
                                            shadows: [
                                              Shadow(
                                                color: isDark ? Colors.black45 : Colors.black12,
                                                blurRadius: 20,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Text(
                                        WeatherTranslator.getAllLanguagesDescription(
                                          weather.description,
                                          weather.conditionId,
                                        ).toUpperCase(),
                                        style: TextStyle(
                                          color: isDark ? Colors.white.withOpacity(0.9) : Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 2,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn(duration: 1.seconds).moveX(begin: 20, end: 0),
                              ],
                            ),
                            
                            const SizedBox(height: 40),
                            // Smart Tip Card
                            _buildGlassCard(
                              context: context,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(isDark ? 0.1 : 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.lightbulb_outline_rounded, color: isDark ? Colors.yellow.withOpacity(0.8) : Colors.yellow),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        _getWeatherTip(weather.conditionId, weather.temperature, context),
                                        style: TextStyle(
                                          color: isDark ? Colors.white : Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn(delay: 400.ms).scale(),

                            const SizedBox(height: 32),
                            // Main Stats Grid
                            _buildGlassCard(
                              context: context,
                              opacity: 0.08,
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: GridView(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 20,
                                    crossAxisSpacing: 20,
                                    mainAxisExtent: 110,
                                  ),
                                  children: [
                                    _buildStatCard(context, AppLocalizations.of(context)!.feelsLike, '${weather.feelsLike.round()}°', Icons.thermostat_rounded, isDark ? Colors.orange : Colors.orangeAccent),
                                    _buildStatCard(context, AppLocalizations.of(context)!.humidity, '${weather.humidity}%', Icons.water_drop_rounded, isDark ? Colors.blue : Colors.blueAccent),
                                    _buildStatCard(context, AppLocalizations.of(context)!.wind, '${weather.windSpeed} ${AppLocalizations.of(context)!.windUnit}', Icons.air_rounded, isDark ? Colors.teal : Colors.tealAccent),
                                    _buildStatCard(context, AppLocalizations.of(context)!.pressure, '${weather.pressure} hPa', Icons.speed_rounded, isDark ? Colors.purple : Colors.purpleAccent),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
                            
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
        error: (e, st) => Container(
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
            child: Text(
              'Error: $e',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color iconColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8, top: 16),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).moveX(begin: -10, end: 0);
  }

  Widget _buildForecastList(AsyncValue<List<Forecast>> forecast, Locale locale, {bool isHourly = false}) {
    return forecast.when(
      data: (list) => SizedBox(
        height: isHourly ? 130 : 160,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              child: _buildGlassCard(
                context: context,
                opacity: 0.08,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isHourly
                            ? DateFormat('ha').format(item.date)
                            : DateFormat('EEE').format(item.date),
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Image.network(
                        'https://openweathermap.org/img/wn/${item.iconCode}.png',
                        height: 40,
                        width: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${item.temperature.round()}°',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: (index * 100).ms).scale();
          },
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (e, st) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
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
