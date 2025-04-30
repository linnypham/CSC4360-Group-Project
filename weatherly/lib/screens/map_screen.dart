import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:weatherly/providers/weather_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController _mapController;
  LatLng? _currentLocation;
  int _currentLayer = 0;
  final List<MapLayer> _availableLayers = [
    MapLayer(name: 'Precipitation', layerCode: 'precipitation_new'),
    MapLayer(name: 'Temperature', layerCode: 'temp_new'),
    MapLayer(name: 'Wind', layerCode: 'wind_new'),
    MapLayer(name: 'Clouds', layerCode: 'clouds_new'),
  ];

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

  void _cycleMapLayer() {
    setState(() {
      _currentLayer = (_currentLayer + 1) % _availableLayers.length;
    });
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
        title: Text(_availableLayers[_currentLayer].name),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (_currentLocation != null) {
                _mapController.move(_currentLocation!, 10.0);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: _cycleMapLayer,
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentLocation!,
          initialZoom: 10.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.weatherly',
          ),
          TileLayer(
            urlTemplate:
                'https://tile.openweathermap.org/map/${_availableLayers[_currentLayer].layerCode}/{z}/{x}/{y}.png?appid=YOUR_API_KEY',
          ),
          if (weather != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentLocation!,
                  width: 40,
                  height: 40,
                  child: Icon(
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
        onPressed: _cycleMapLayer,
        child: const Icon(Icons.layers),
      ),
    );
  }
}

class MapLayer {
  final String name;
  final String layerCode;

  MapLayer({required this.name, required this.layerCode});
}