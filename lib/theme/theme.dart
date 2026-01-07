import 'package:flutter/material.dart';

class AppTheme {
  // Sophisticated Monochrome - Academic Professional Theme

  // Light Mode Colors
  static const _lightPrimary = Color(0xFF2563EB); // Deep Blue
  static const _lightBackground = Color(0xFFFFFFFF);
  static const _lightSurface = Color(0xFFF8FAFC);
  static const _lightBorder = Color(0xFFE8EDF2);
  static const _lightText = Color(0xFF0F172A);
  static const _lightTextSecondary = Color(0xFF64748B);

  // Dark Mode Colors
  static const _darkPrimary = Color(0xFF3B82F6); // Bright Blue
  static const _darkBackground = Color(0xFF0F1419);
  static const _darkSurface = Color(0xFF1A1F26);
  static const _darkSurfaceVariant = Color(0xFF1E2430);
  static const _darkBorder = Color(0xFF2A3340);
  static const _darkText = Color(0xFFE2E8F0);
  static const _darkTextSecondary = Color(0xFF94A3B8);

  // Success, Warning, Error
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: _lightPrimary,
      secondary: _lightPrimary,
      surface: _lightSurface,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _lightText,
      onError: Colors.white,
      outline: _lightBorder,
    ),
    scaffoldBackgroundColor: _lightBackground,
    cardColor: _lightSurface,
    dividerColor: _lightBorder,

    // App Bar
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightBackground,
      foregroundColor: _lightText,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: _lightText,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: _lightText),
    ),

    // Card
    cardTheme: CardThemeData(
      color: _lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _lightBorder, width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _lightPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _lightText,
        side: const BorderSide(color: _lightBorder),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Icon Button
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: _lightText,
        iconSize: 22,
      ),
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _lightPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: error),
      ),
      labelStyle: const TextStyle(color: _lightTextSecondary),
      hintStyle: const TextStyle(color: _lightTextSecondary),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: _lightSurface,
      selectedColor: _lightPrimary.withValues(alpha: 0.1),
      labelStyle: const TextStyle(color: _lightText, fontSize: 13),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: _lightBorder),
      ),
    ),

    // Bottom Sheet
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: _lightBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // Tab Bar
    tabBarTheme: const TabBarThemeData(
      labelColor: _lightPrimary,
      unselectedLabelColor: _lightTextSecondary,
      indicatorColor: _lightPrimary,
      labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
    ),

    // Typography
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: _lightText, letterSpacing: -1),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: _lightText, letterSpacing: -0.5),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: _lightText, letterSpacing: -0.5),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _lightText, letterSpacing: -0.5),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _lightText),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _lightText),
      titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _lightText),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _lightText),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: _lightText, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: _lightText, height: 1.5),
      bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: _lightTextSecondary, height: 1.5),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _lightText),
      labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _lightTextSecondary),
      labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _lightTextSecondary),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: _darkPrimary,
      secondary: _darkPrimary,
      surface: _darkSurface,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _darkText,
      onError: Colors.white,
      outline: _darkBorder,
    ),
    scaffoldBackgroundColor: _darkBackground,
    cardColor: _darkSurface,
    dividerColor: _darkBorder,

    // App Bar
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkBackground,
      foregroundColor: _darkText,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: _darkText,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: _darkText),
    ),

    // Card
    cardTheme: CardThemeData(
      color: _darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _darkBorder, width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkText,
        side: const BorderSide(color: _darkBorder),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Icon Button
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: _darkText,
        iconSize: 22,
      ),
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurfaceVariant,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _darkPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: error),
      ),
      labelStyle: const TextStyle(color: _darkTextSecondary),
      hintStyle: const TextStyle(color: _darkTextSecondary),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: _darkSurfaceVariant,
      selectedColor: _darkPrimary.withValues(alpha: 0.2),
      labelStyle: const TextStyle(color: _darkText, fontSize: 13),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: _darkBorder),
      ),
    ),

    // Bottom Sheet
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: _darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // Tab Bar
    tabBarTheme: const TabBarThemeData(
      labelColor: _darkPrimary,
      unselectedLabelColor: _darkTextSecondary,
      indicatorColor: _darkPrimary,
      labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
    ),

    // Typography
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: _darkText, letterSpacing: -1),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: _darkText, letterSpacing: -0.5),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: _darkText, letterSpacing: -0.5),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _darkText, letterSpacing: -0.5),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _darkText),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _darkText),
      titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _darkText),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _darkText),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: _darkText, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: _darkText, height: 1.5),
      bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: _darkTextSecondary, height: 1.5),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _darkText),
      labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _darkTextSecondary),
      labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _darkTextSecondary),
    ),
  );
}
