import 'package:flutter/material.dart';

class WeatherIcon extends StatelessWidget {
  final String iconCode;
  final double size;

  const WeatherIcon({super.key, required this.iconCode, this.size = 24});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    switch (iconCode) {
      case '01d': // clear sky day
        iconData = Icons.wb_sunny;
        break;
      case '01n': // clear sky night
        iconData = Icons.nightlight_round;
        break;
      case '02d': // few clouds day
      case '02n': // few clouds night
      case '03d': // scattered clouds
      case '03n':
      case '04d': // broken clouds
      case '04n':
        iconData = Icons.cloud;
        break;
      case '09d': // shower rain
      case '09n':
      case '10d': // rain
      case '10n':
        iconData = Icons.grain;
        break;
      case '11d': // thunderstorm
      case '11n':
        iconData = Icons.flash_on;
        break;
      case '13d': // snow
      case '13n':
        iconData = Icons.ac_unit;
        break;
      case '50d': // mist
      case '50n':
        iconData = Icons.blur_on;
        break;
      default:
        iconData = Icons.help_outline;
    }

    return Icon(iconData, size: size);
  }
}