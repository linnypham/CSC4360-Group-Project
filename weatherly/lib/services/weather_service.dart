import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weatherly/models/weather_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  final String apiKey;

  WeatherService(this.apiKey);

  Future<WeatherData> getCurrentWeather(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<Forecast> getForecast(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/onecall?lat=$lat&lon=$lon&exclude=minutely&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return Forecast.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load forecast data');
    }
  }
}