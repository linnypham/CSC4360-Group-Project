import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weatherly/models/weather_model.dart';
import 'package:weatherly/providers/settings_provider.dart';
import 'package:weatherly/providers/weather_provider.dart';
import 'package:weatherly/utils/weather_icons.dart';

class HourlyForecastList extends StatelessWidget {
  const HourlyForecastList({super.key});

  @override
  Widget build(BuildContext context) {
    final forecast = context.watch<WeatherProvider>().forecast;
    final settings = context.watch<SettingsProvider>();
    
    if (forecast == null || forecast.hourly.isEmpty) {
      return const SizedBox.shrink();
    }

    final hourly = forecast.hourly.take(12).toList();

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
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
                  final temp = settings.convertTemperature(weather.temperature);
                  return HourlyForecastItem(
                    weather: weather,
                    temp: temp.toStringAsFixed(1),
                  );
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
  final String temp;

  const HourlyForecastItem({
    super.key,
    required this.weather,
    required this.temp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('ha').format(weather.timestamp),
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
          WeatherIcon(iconCode: weather.iconCode, size: 24),
          const SizedBox(height: 4),
          Text(
            temp,
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
    final settings = context.watch<SettingsProvider>();
    
    if (forecast == null || forecast.daily.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Text(
                '7-Day Forecast',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ...forecast.daily.map((weather) {
              final temp = settings.convertTemperature(weather.temperature);
              return DailyForecastItem(
                weather: weather,
                temp: temp.toStringAsFixed(1),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class DailyForecastItem extends StatelessWidget {
  final WeatherData weather;
  final String temp;

  const DailyForecastItem({
    super.key,
    required this.weather,
    required this.temp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
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
              temp,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}