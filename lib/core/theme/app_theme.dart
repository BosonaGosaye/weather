import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme Colors
  static const Color primaryLight = Color(0xFF2563EB); // Vivid Blue
  static const Color backgroundLight = Color(0xFFF0F4F8); // Soft Cool Grey
  static const Color surfaceLight = Colors.white;
  static const Color textMainLight = Color(0xFF1E293B); // Slate 800
  static const Color textMetaLight = Color(0xFF64748B); // Slate 500

  // Dark Theme Colors
  static const Color primaryDark = Color(0xFF3B82F6); // Lighter Blue for Dark Mode
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900 (Rich Dark Blue)
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color textMainDark = Color(0xFFF1F5F9); // Slate 100
  static const Color textMetaDark = Color(0xFF94A3B8); // Slate 400

  static TextTheme _buildTextTheme(ThemeData base) {
    return GoogleFonts.outfitTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.outfit(
        fontWeight: FontWeight.w700,
        fontSize: 64,
        letterSpacing: -2,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontWeight: FontWeight.w600,
        fontSize: 32,
        letterSpacing: -1,
      ),
      titleLarge: GoogleFonts.outfit(
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      bodyLarge: GoogleFonts.outfit(
        fontWeight: FontWeight.w400,
        fontSize: 16,
      ),
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryLight,
        brightness: Brightness.light,
        surface: surfaceLight,
        background: backgroundLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: surfaceLight,
        margin: EdgeInsets.zero,
      ),
      textTheme: _buildTextTheme(base).apply(
        bodyColor: textMainLight,
        displayColor: textMainLight,
      ),
      iconTheme: const IconThemeData(color: textMainLight),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: textMainLight,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: textMainLight),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDark,
        brightness: Brightness.dark,
        surface: surfaceDark,
        background: backgroundDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: surfaceDark,
        margin: EdgeInsets.zero,
      ),
      textTheme: _buildTextTheme(base).apply(
        bodyColor: textMainDark,
        displayColor: textMainDark,
      ),
      iconTheme: const IconThemeData(color: textMainDark),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: textMainDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: textMainDark),
      ),
      useMaterial3: true,
    );
  }
}
