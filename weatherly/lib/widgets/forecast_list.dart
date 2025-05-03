import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weatherly/models/weather_model.dart';
import 'package:weatherly/providers/weather_provider.dart';
import 'package:weatherly/utils/weather_icons.dart';

class HourlyForecastList extends StatelessWidget {
  const HourlyForecastList({super.key});

  @override
  Widget build(BuildContext context) {
    final forecast = context.watch<WeatherProvider>().forecast;
    
    if (forecast == null || forecast.hourly.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show next 12 hours forecast
    final hourly = forecast.hourly.take(12).toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Hourly Forecast',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: hourly.length,
                itemBuilder: (context, index) {
                  final weather = hourly[index];
                  return HourlyForecastItem(weather: weather);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HourlyForecastItem extends StatelessWidget {
  final WeatherData weather;

  const HourlyForecastItem({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('ha').format(weather.timestamp),
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
          WeatherIcon(iconCode: weather.iconCode, size: 32),
          const SizedBox(height: 4),
          Text(
            '${weather.temperature.round()}°',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class DailyForecastList extends StatelessWidget {
  const DailyForecastList({super.key});

  @override
  Widget build(BuildContext context) {
    final forecast = context.watch<WeatherProvider>().forecast;
    
    if (forecast == null || forecast.daily.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '7-Day Forecast',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ...forecast.daily.map((weather) => DailyForecastItem(weather: weather)),
          ],
        ),
      ),
    );
  }
}

class DailyForecastItem extends StatelessWidget {
  final WeatherData weather;

  const DailyForecastItem({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              DateFormat('EEEE').format(weather.timestamp),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            child: WeatherIcon(iconCode: weather.iconCode, size: 24),
          ),
          Expanded(
            child: Text(
              '${weather.temperature.round()}°',
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}