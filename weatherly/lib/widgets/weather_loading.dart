import 'package:flutter/material.dart';

class WeatherLoading extends StatelessWidget {
  const WeatherLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            'Fetching Weather Data...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          // Optional: Add a weather-themed loading animation
          SizedBox(
            height: 100,
            child: Image.asset(
              'assets/weather_loading.gif', // Add this asset to your project
              package: 'weatherly',
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Please ensure location services are enabled',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Alternative minimal version:
class SimpleWeatherLoading extends StatelessWidget {
  const SimpleWeatherLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}