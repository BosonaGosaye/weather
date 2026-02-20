// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BSG Weather';

  @override
  String get search => 'Search';

  @override
  String get myLocation => 'My Location';

  @override
  String get feelsLike => 'Feels Like';

  @override
  String get humidity => 'Humidity';

  @override
  String get wind => 'Wind';

  @override
  String get windUnit => 'km/h';

  @override
  String get pressure => 'Pressure';

  @override
  String get hourlyForecast => 'Hourly Forecast';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get searchPlaceholder => 'Search for a city or use your location';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get toggleTheme => 'Toggle Theme';

  @override
  String get searchCity => 'Search City';

  @override
  String get enterCityName => 'Enter city name...';

  @override
  String get favoriteCities => 'Favorite Cities';

  @override
  String get noFavorites => 'No favorite cities yet.';

  @override
  String get delete => 'Delete';

  @override
  String get sevenDayForecast => '7-Day Forecast';

  @override
  String get pastSevenDays => 'Past 7 Days History';
}
