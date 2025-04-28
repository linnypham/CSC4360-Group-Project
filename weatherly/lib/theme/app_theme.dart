import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: _createMaterialColor(const Color(0xFF4285F4)),
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    appBarTheme: const AppBarTheme(
      color: Color(0xFF4285F4),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: _createMaterialColor(const Color(0xFF8AB4F8)),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      color: Color(0xFF1E1E1E),
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFF1E1E1E),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.white70,
      ),
    ),
  );

  static ThemeData getRainyTheme(bool isDark) {
    final base = isDark ? darkTheme : lightTheme;
    return base.copyWith(
      primaryColor: isDark ? const Color(0xFF5E97F6) : const Color(0xFF1976D2),
      scaffoldBackgroundColor: isDark ? const Color(0xFF0A0E21) : const Color(0xFFE3F2FD),
      cardTheme: base.cardTheme.copyWith(
        color: isDark ? const Color(0xFF1A237E) : const Color(0xFFBBDEFB),
      ),
    );
  }

  static ThemeData getSnowyTheme(bool isDark) {
    final base = isDark ? darkTheme : lightTheme;
    return base.copyWith(
      primaryColor: isDark ? const Color(0xFF80DEEA) : const Color(0xFF00ACC1),
      scaffoldBackgroundColor: isDark ? const Color(0xFF000A12) : const Color(0xFFE0F7FA),
      cardTheme: base.cardTheme.copyWith(
        color: isDark ? const Color(0xFF263238) : const Color(0xFFB2EBF2),
      ),
    );
  }

  static ThemeData getSunnyTheme(bool isDark) {
    final base = isDark ? darkTheme : lightTheme;
    return base.copyWith(
      primaryColor: isDark ? const Color(0xFFFFD54F) : const Color(0xFFFFA000),
      scaffoldBackgroundColor: isDark ? const Color(0xFF1A1A00) : const Color(0xFFFFF8E1),
      cardTheme: base.cardTheme.copyWith(
        color: isDark ? const Color(0xFF424242) : const Color(0xFFFFECB3),
      ),
    );
  }

  static MaterialColor _createMaterialColor(Color color) {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};
    final r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (final strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(color.value, swatch);
  }

  static ThemeData getThemeForWeather(String condition, bool isDark) {
    switch (condition.toLowerCase()) {
      case 'rain':
      case 'drizzle':
        return getRainyTheme(isDark);
      case 'snow':
        return getSnowyTheme(isDark);
      case 'clear':
        return getSunnyTheme(isDark);
      case 'clouds':
        return isDark 
          ? darkTheme.copyWith(primaryColor: const Color(0xFF9E9E9E))
          : lightTheme.copyWith(primaryColor: const Color(0xFF757575));
      case 'thunderstorm':
        return isDark
          ? darkTheme.copyWith(primaryColor: const Color(0xFF7B1FA2))
          : lightTheme.copyWith(primaryColor: const Color(0xFF9C27B0));
      default:
        return isDark ? darkTheme : lightTheme;
    }
  }
}