import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherly/providers/weather_provider.dart';
import 'package:weatherly/screens/community_screen.dart';
import 'package:weatherly/screens/map_screen.dart';
import 'package:weatherly/screens/settings_screen.dart';
import 'package:weatherly/widgets/current_weather.dart';
import 'package:weatherly/widgets/forecast_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weatherly'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MapScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CommunityScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<WeatherProvider>().refreshWeather(),
        child: SingleChildScrollView(
          child: Column(
            children: const [
              CurrentWeatherWidget(),
              HourlyForecastList(),
              DailyForecastList(),
            ],
          ),
        ),
      ),
    );
  }
}