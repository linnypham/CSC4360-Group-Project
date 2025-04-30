import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:weatherly/providers/weather_provider.dart';

class WeatherMap extends StatefulWidget {
  const WeatherMap({super.key});

  @override
  State<WeatherMap> createState() => _WeatherMapState();
}

class _WeatherMapState extends State<WeatherMap> {
  late MapController _mapController;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
  }

  void _getCurrentLocation() {
    final weather = context.read<WeatherProvider>().currentWeather;
    if (weather != null) {
      setState(() {
        _currentLocation = LatLng(weather.location.lat, weather.location.lon);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(_currentLocation!, 10.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>().currentWeather;
    final theme = Theme.of(context);

    if (_currentLocation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (_currentLocation != null) {
                _mapController.move(_currentLocation!, 10.0);
              }
            },
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: _currentLocation,
          zoom: 10.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.weatherly',
          ),
          TileLayer(
            urlTemplate:
                'https://tile.openweathermap.org/map/precipitation_new/{z}/{x}/{y}.png?appid=YOUR_API_KEY',
          ),
          if (weather != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentLocation!,
                  width: 40,
                  height: 40,
                  builder: (ctx) => Icon(
                    Icons.location_on,
                    color: theme.primaryColor,
                    size: 40,
                  ),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Toggle between different map layers
        },
        child: const Icon(Icons.layers),
      ),
    );
  }
}