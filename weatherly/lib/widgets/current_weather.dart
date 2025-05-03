import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weatherly/models/weather_model.dart';
import 'package:weatherly/utils/weather_icons.dart';
import 'package:weatherly/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class CurrentWeatherWidget extends StatelessWidget {
  final WeatherData weather;

  const CurrentWeatherWidget({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final tempUnit = settings.temperatureUnit;
    final temp = tempUnit == TemperatureUnit.celsius
        ? weather.temperature
        : (weather.temperature * 9 / 5) + 32;
    final feelsLike = tempUnit == TemperatureUnit.celsius
        ? weather.feelsLike
        : (weather.feelsLike * 9 / 5) + 32;
    final unitSymbol = tempUnit == TemperatureUnit.celsius ? '°C' : '°F';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Location and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.location.city,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      DateFormat('EEEE, MMM d').format(weather.timestamp),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.location_on),
                  onPressed: () {
                    // Handle location change
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Main Weather Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Weather Icon
                WeatherIcon(
                  iconCode: weather.iconCode,
                  size: 80,
                ),

                // Temperature
                Column(
                  children: [
                    Text(
                      '${temp.round()}$unitSymbol',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      weather.condition,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Additional Weather Details
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.5,
              children: [
                _buildWeatherDetail(
                  context,
                  icon: Icons.thermostat,
                  label: 'Feels Like',
                  value: '${feelsLike.round()}$unitSymbol',
                ),
                _buildWeatherDetail(
                  context,
                  icon: Icons.water,
                  label: 'Humidity',
                  value: '${weather.humidity}%',
                ),
                _buildWeatherDetail(
                  context,
                  icon: Icons.air,
                  label: 'Wind',
                  value: '${weather.windSpeed.round()} km/h',
                ),
                if (weather.precipitation != null)
                  _buildWeatherDetail(
                    context,
                    icon: Icons.umbrella,
                    label: 'Precip',
                    value: '${weather.precipitation} mm',
                  ),
                if (weather.uvIndex != null)
                  _buildWeatherDetail(
                    context,
                    icon: Icons.wb_sunny,
                    label: 'UV Index',
                    value: weather.uvIndex!.toStringAsFixed(1),
                  ),
                if (weather.cloudCover != null)
                  _buildWeatherDetail(
                    context,
                    icon: Icons.cloud,
                    label: 'Clouds',
                    value: '${weather.cloudCover}%',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}