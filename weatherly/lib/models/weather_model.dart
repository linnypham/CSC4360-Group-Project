import 'package:google_maps_flutter/google_maps_flutter.dart';

class WeatherData {
  final Location location;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String condition;
  final String description;
  final String iconCode;
  final DateTime timestamp;
  final double? precipitation;
  final int? cloudCover;
  final double? uvIndex;

  WeatherData({
    required this.location,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    required this.description,
    required this.iconCode,
    required this.timestamp,
    this.precipitation,
    this.cloudCover,
    this.uvIndex,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      location: Location(
        lat: json['coord']['lat'].toDouble(),
        lon: json['coord']['lon'].toDouble(),
        city: json['name'],
      ),
      temperature: json['main']['temp'].toDouble(),
      feelsLike: json['main']['feels_like'].toDouble(),
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      condition: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      iconCode: json['weather'][0]['icon'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      precipitation: json['rain']?['1h']?.toDouble(),
      cloudCover: json['clouds']['all'],
      uvIndex: json['uvi']?.toDouble(),
    );
  }
}

class Location {
  final double lat;
  final double lon;
  final String city;

  Location({required this.lat, required this.lon, required this.city});

  LatLng toLatLng() => LatLng(lat, lon);
}

class Forecast {
  final List<WeatherData> hourly;
  final List<WeatherData> daily;

  Forecast({required this.hourly, required this.daily});

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      hourly: (json['hourly'] as List)
          .map((e) => WeatherData.fromJson(e))
          .toList(),
      daily: (json['daily'] as List)
          .map((e) => WeatherData.fromJson(e))
          .toList(),
    );
  }
}