import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = 'd0481087b5fe4c27ab0153437250305';
  final String baseUrl = 'http://api.weatherapi.com/v1';

  Future<Map<String, dynamic>> fetchCurrentWeather(String location) async {
    final response = await http.get(
      Uri.parse('$baseUrl/current.json?key=$apiKey&q=$location'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<Map<String, dynamic>> fetchForecast(String location) async {
    final response = await http.get(
      Uri.parse('$baseUrl/forecast.json?key=$apiKey&q=$location&days=7'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load forecast');
    }
  }
}
