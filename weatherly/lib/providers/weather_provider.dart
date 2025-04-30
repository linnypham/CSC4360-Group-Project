import 'package:flutter/material.dart';
import 'package:weatherly/models/weather_model.dart';
import 'package:weatherly/services/firebase_service.dart';
import 'package:weatherly/services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService;
  final FirebaseService _firebaseService;
  WeatherData? _currentWeather;
  Forecast? _forecast;
  bool _isLoading = false;
  String? _error;

  WeatherProvider(this._weatherService, this._firebaseService);

  WeatherData? get currentWeather => _currentWeather;
  Forecast? get forecast => _forecast;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWeather(double lat, double lon) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentWeather = await _weatherService.getCurrentWeather(lat, lon);
      _forecast = await _weatherService.getForecast(lat, lon);
      await _firebaseService.logWeatherFetch(lat, lon);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshWeather() async {
    if (_currentWeather != null) {
      await fetchWeather(
        _currentWeather!.location.lat,
        _currentWeather!.location.lon,
      );
    }
  }
}