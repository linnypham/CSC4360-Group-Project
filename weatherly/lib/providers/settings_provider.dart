import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TemperatureUnit { celsius, fahrenheit }

class SettingsProvider with ChangeNotifier {
  static const String _darkModeKey = 'darkMode';
  static const String _primaryColorKey = 'primaryColor';
  static const String _rainAlertsKey = 'rainAlerts';
  static const String _tempAlertsKey = 'tempAlerts';
  static const String _tempUnitKey = 'tempUnit';

  bool _isDarkMode = false;
  Color _primaryColor = Colors.blue;
  bool _rainAlertsEnabled = true;
  bool _tempAlertsEnabled = true;
  TemperatureUnit _temperatureUnit = TemperatureUnit.celsius;

  SettingsProvider() {
    _loadSettings();
  }

  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;
  bool get rainAlertsEnabled => _rainAlertsEnabled;
  bool get tempAlertsEnabled => _tempAlertsEnabled;
  TemperatureUnit get temperatureUnit => _temperatureUnit;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    
    final colorValue = prefs.getInt(_primaryColorKey);
    if (colorValue != null) {
      _primaryColor = Color(colorValue);
    }
    
    _rainAlertsEnabled = prefs.getBool(_rainAlertsKey) ?? true;
    _tempAlertsEnabled = prefs.getBool(_tempAlertsKey) ?? true;
    
    final unitIndex = prefs.getInt(_tempUnitKey) ?? 0;
    _temperatureUnit = TemperatureUnit.values[unitIndex];
    
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    await SharedPreferences.getInstance()
      ..setBool(_darkModeKey, value);
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    await SharedPreferences.getInstance()
      ..setInt(_primaryColorKey, color.value);
    notifyListeners();
  }

  Future<void> toggleRainAlerts(bool value) async {
    _rainAlertsEnabled = value;
    await SharedPreferences.getInstance()
      ..setBool(_rainAlertsKey, value);
    notifyListeners();
  }

  Future<void> toggleTempAlerts(bool value) async {
    _tempAlertsEnabled = value;
    await SharedPreferences.getInstance()
      ..setBool(_tempAlertsKey, value);
    notifyListeners();
  }

  Future<void> setTemperatureUnit(TemperatureUnit unit) async {
    _temperatureUnit = unit;
    await SharedPreferences.getInstance()
      ..setInt(_tempUnitKey, unit.index);
    notifyListeners();
  }

  // Helper method to convert temperature based on user preference
  double convertTemperature(double tempCelsius) {
    return _temperatureUnit == TemperatureUnit.fahrenheit
        ? (tempCelsius * 9 / 5) + 32
        : tempCelsius;
  }

  // Helper method to get temperature unit symbol
  String get temperatureUnitSymbol {
    return _temperatureUnit == TemperatureUnit.fahrenheit ? '°F' : '°C';
  }

  // Reset all settings to defaults
  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    _isDarkMode = false;
    _primaryColor = Colors.blue;
    _rainAlertsEnabled = true;
    _tempAlertsEnabled = true;
    _temperatureUnit = TemperatureUnit.celsius;
    
    notifyListeners();
  }
}