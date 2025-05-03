import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'utils/theme_manager.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/community_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(WeatherlyApp());
}

class WeatherlyApp extends StatefulWidget {
  @override
  State<WeatherlyApp> createState() => _WeatherlyAppState();
}

class _WeatherlyAppState extends State<WeatherlyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weatherly',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => SplashScreen(onThemeChange: _changeTheme),
        '/home': (context) => HomeScreen(),
        '/map': (context) => MapScreen(),
        '/community': (context) => CommunityScreen(),
        '/settings': (context) => SettingsScreen(onThemeChange: _changeTheme),
      },
    );
  }
}