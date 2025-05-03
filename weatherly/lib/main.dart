import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherly/app.dart';
import 'package:weatherly/firebase_options.dart';
import 'package:weatherly/providers/auth_provider.dart';
import 'package:weatherly/providers/settings_provider.dart';
import 'package:weatherly/providers/weather_provider.dart';
import 'package:weatherly/services/firebase_service.dart';
import 'package:weatherly/services/location_service.dart';
import 'package:weatherly/services/weather_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final firebaseService = FirebaseService();
  final weatherService = WeatherService('AIzaSyCpx5CJA5SDzdzkZJCFF4HvXvmxs1H9Ork');
  final locationService = LocationService();
  
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => locationService),
        ChangeNotifierProvider(create: (_) => AuthProvider(firebaseService)),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(
          create: (_) => WeatherProvider(weatherService, firebaseService),
        ),
      ],
      child: const WeatherlyApp(),
    ),
  );
}