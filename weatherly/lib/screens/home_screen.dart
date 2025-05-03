import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherly/providers/weather_provider.dart';
import 'package:weatherly/screens/community_screen.dart';
import 'package:weatherly/screens/map_screen.dart';
import 'package:weatherly/screens/settings_screen.dart';
import 'package:weatherly/widgets/current_weather.dart';
import 'package:weatherly/widgets/forecast_list.dart';
import 'package:weatherly/widgets/weather_loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    await weatherProvider.fetchWeather(33.7501, -84.3885); // Default to ATL
    if (mounted) {
      setState(() => _isInitialLoad = false);
    }
  }

  Future<void> _refreshData() async {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    await weatherProvider.refreshWeather();
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final weather = weatherProvider.currentWeather;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weatherly'),
        actions: [
          // Map Button
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => _navigateTo(MapScreen()),
          ),
          // Community Button
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => _navigateTo(const CommunityScreen()),
          ),
          // Settings Button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _navigateTo(const SettingsScreen()),
          ),
        ],
      ),
      body: _isInitialLoad
          ? const WeatherLoading()
          : weather == null
              ? _buildErrorWidget()
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        CurrentWeatherWidget(weather: weather),
                        const HourlyForecastList(),
                        const DailyForecastList(),
                      ],
                    ),
                  ),
                ),
    );
  }

  void _navigateTo(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Failed to load weather data'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}