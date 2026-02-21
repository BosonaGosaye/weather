# Weather Ethiopia 🌦️

A modern, immersive, and trilingual weather application specifically designed for the Ethiopian context. Built with Flutter, this app provides real-time weather data, forecasts, and historical insights with a beautiful AR-inspired user interface.

## ✨ Features

### 🇪🇹 Localized for Ethiopia
- **Trilingual Support**: Full support for **English**, **አማርኛ (Amharic)**, and **Afaan Oromoo**.
- **Extensive Location Data**: Includes major cities, smaller towns, and rural areas across all Ethiopian regions (Addis Ababa, Oromia, Amhara, Tigray, Somali, etc.).
- **Region Filtering**: Easily browse and find locations by their respective administrative regions.

### 🎨 Immersive UI/UX
- **AR-Inspired Weather Particles**: Dynamic, real-time animations for rain, snow, mist, and thunderstorms.
- **Dynamic Celestial System**: 
  - Realistic **Animated Sun** with rotating rays for daytime.
  - Detailed **Crescent Moon** with craters and atmospheric glow for nighttime.
  - **Real-time Sync**: The sky automatically switches based on Ethiopia's local time (UTC+3).
- **Glassmorphism Design**: Modern, translucent UI components with real-time blur effects.
- **Dark Mode Support**: Seamless transition between light and dark themes.
- **Skeletonizer**: Smooth loading states with shimmer effects for a premium feel.

### 📊 Weather Insights
- **Hourly Forecast**: Categorized into **Day** and **Night** sections for easier planning.
- **7-Day Forecast**: Detailed daily outlook with localized descriptions.
- **7-Day History**: View past weather conditions and trends.
- **Smart Weather Tips**: Context-aware, trilingual suggestions based on current temperature and conditions (e.g., "Wear a Gabi" during cold nights).
- **Favorites**: Save and quickly access weather for your most important locations.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev)
- **State Management**: [Riverpod](https://riverpod.dev)
- **Local Database**: [Hive](https://docs.hivedb.dev) (for caching and favorites)
- **Animations**: [Flutter Animate](https://pub.dev/packages/flutter_animate)
- **API**: [OpenWeatherMap API](https://openweathermap.org/api)
- **Icons**: [Lucide Icons](https://lucide.dev) & Material Symbols

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (Latest Stable)
- An OpenWeatherMap API Key

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/BosonaGosaye/weather.git
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Key**
   Update the constant file in `lib/core/constants/app_constants.dart` with your API key:
   ```dart
   static const String apiKey = 'YOUR_API_KEY_HERE';
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 👨‍💻 Developer

**Bosona Gosaye**
- [Portfolio](https://bsgportfolio.vercel.app/)
- [GitHub](https://github.com/BosonaGosaye)
- [LinkedIn](https://www.linkedin.com/in/bosona-gosaye-5887533aa/)

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

---
*Made with ❤️ for Ethiopia*
