import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherly/providers/settings_provider.dart';
import 'package:weatherly/screens/home_screen.dart';
import 'package:weatherly/theme/app_theme.dart';

class WeatherlyApp extends StatelessWidget {
  const WeatherlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    
    return MaterialApp(
      title: 'Weatherly',
      theme: AppTheme.lightTheme.copyWith(
        primaryColor: settings.primaryColor,
        colorScheme: AppTheme.lightTheme.colorScheme.copyWith(
          primary: settings.primaryColor,
        ),
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        primaryColor: settings.primaryColor,
        colorScheme: AppTheme.darkTheme.colorScheme.copyWith(
          primary: settings.primaryColor,
        ),
      ),
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}