import 'package:flutter/material.dart';

class WeatherIcon extends StatelessWidget {
  final String iconCode;
  final double size;

  const WeatherIcon({super.key, required this.iconCode, this.size = 24});

  @override
  Widget build(BuildContext context) {
    // Map OpenWeatherMap icon codes to Flutter icons or custom images
    IconData iconData;
    switch (iconCode) {
      case '01d': // clear sky day
        iconData = Icons.wb_sunny;
        break;
      case '01n': // clear sky night
        iconData = Icons.nightlight_round;
        break;
      case '02d': // few clouds day
        iconData = Icons.wb_cloudy;
        break;
      // Add more cases for other weather conditions
      default:
        iconData = Icons.cloud;
    }

    return Icon(iconData, size: size);
  }
}