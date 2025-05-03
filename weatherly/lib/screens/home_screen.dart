import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _currentWeather;
  List<dynamic>? _forecastDays;
  bool _loading = true;
  String _location = 'New York';
  String _locationInput = '';

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final forecastData = await _weatherService.fetchForecast(_location);
      setState(() {
        _currentWeather = forecastData['current'];
        _forecastDays = forecastData['forecast']['forecastday'];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _currentWeather = null;
        _forecastDays = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load weather for '$_location'")),
      );
    }
  }

  Widget _buildForecastList() {
    return Column(
      children: _forecastDays!.map((day) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: Image.network("https:${day['day']['condition']['icon']}"),
            title: Text(day['date']),
            subtitle: Text(day['day']['condition']['text']),
            trailing: Text("${day['day']['avgtemp_c']}°C"),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Weatherly")),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Text("Menu")),
            ListTile(title: Text("Map"), onTap: () => Navigator.pushNamed(context, '/map')),
            ListTile(title: Text("Community"), onTap: () => Navigator.pushNamed(context, '/community')),
            ListTile(title: Text("Settings"), onTap: () => Navigator.pushNamed(context, '/settings')),
          ],
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _currentWeather == null
              ? Center(child: Text("Failed to load weather."))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Enter location",
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {
                              if (_locationInput.trim().isNotEmpty) {
                                setState(() {
                                  _location = _locationInput;
                                  _loading = true;
                                });
                                _loadWeather();
                              }
                            },
                          ),
                        ),
                        onChanged: (value) {
                          _locationInput = value;
                        },
                      ),
                      SizedBox(height: 20),
                      Text("$_location", style: Theme.of(context).textTheme.headlineMedium),
                      Text("${_currentWeather!['temp_c']}°C", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                      Text(_currentWeather!['condition']['text'], style: TextStyle(fontSize: 18)),
                      Image.network("https:${_currentWeather!['condition']['icon']}", width: 80),
                      SizedBox(height: 30),
                      Text("7-Day Forecast", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      _buildForecastList(),
                    ],
                  ),
                ),
    );
  }
}