import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weatherly/models/weather_model.dart';

class WeatherService {
  static const String _baseUrl = 'http://api.weatherapi.com/v1';
  final String apiKey;

  WeatherService(this.apiKey);

  Future<WeatherData> getCurrentWeather(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/current.json?key=d0481087b5fe4c27ab0153437250305&q=$lat,$lon&api=no'),
    );

    if (response.statusCode == 200) {
      return _parseWeatherData(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data: ${response.statusCode}');
    }
  }

  Future<Forecast> getForecast(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/forecast.json?key=d0481087b5fe4c27ab0153437250305&q=$lat,$lon&days=7&api=no%alerts=yes'),
    );

    if (response.statusCode == 200) {
      return _parseForecastData(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load forecast: ${response.statusCode}');
    }
  }

  WeatherData _parseWeatherData(Map<String, dynamic> json) {
    final current = json['current'];
    final location = json['location'];

    return WeatherData(
      location: Location(
        lat: location['lat'],
        lon: location['lon'],
        city: location['name'],
      ),
      temperature: current['temp_c'],
      feelsLike: current['feelslike_c'],
      humidity: current['humidity'],
      windSpeed: current['wind_kph'],
      condition: current['condition']['text'],
      description: current['condition']['text'],
      iconCode: _parseIconCode(current['condition']['icon']),
      timestamp: DateTime.parse(location['localtime']),
    );
  }

  Forecast _parseForecastData(Map<String, dynamic> json) {
    final daily = (json['forecast']['forecastday'] as List)
        .map((day) => _parseDailyWeather(day['day'], day['date']))
        .toList();

    return Forecast(
      hourly: [],
      daily: daily,
    );
  }

  WeatherData _parseDailyWeather(Map<String, dynamic> dayData, String date) {
    return WeatherData(
      location: Location(lat: 0, lon: 0, city: ''), // Will be overwritten
      temperature: dayData['avgtemp_c'],
      feelsLike: dayData['avgtemp_c'],
      humidity: dayData['avghumidity'],
      windSpeed: dayData['maxwind_kph'],
      condition: dayData['condition']['text'],
      description: dayData['condition']['text'],
      iconCode: _parseIconCode(dayData['condition']['icon']),
      timestamp: DateTime.parse(date),
    );
  }

  String _parseIconCode(String originalUrl) {
    return originalUrl.split('/').last.split('.').first;
  }

  Future<List<WeatherData>> getHourlyForecast(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/forecast.json?key=$apiKey&q=$lat,$lon&days=1&hourly=24'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['forecast']['forecastday'][0]['hour'] as List)
          .map((hour) => _parseHourlyWeather(hour))
          .toList();
    } else {
      throw Exception('Failed to load hourly forecast');
    }
  }

  WeatherData _parseHourlyWeather(Map<String, dynamic> hourData) {
    return WeatherData(
      location: Location(lat: 0, lon: 0, city: ''),
      temperature: hourData['temp_c'],
      feelsLike: hourData['feelslike_c'],
      humidity: hourData['humidity'],
      windSpeed: hourData['wind_kph'],
      condition: hourData['condition']['text'],
      description: hourData['condition']['text'],
      iconCode: _parseIconCode(hourData['condition']['icon']),
      timestamp: DateTime.parse(hourData['time']),
    );
  }
}