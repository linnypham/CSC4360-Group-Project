import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:weatherly/providers/weather_provider.dart';
import 'package:weatherly/services/location_service.dart';
import 'package:weatherly/models/weather_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  final LocationService _locationService = LocationService();
  LatLng? _currentPosition;
  Set<Marker> _markers = {};
  String _mapType = 'normal';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  Future<void> _initMap() async {
    try {
      final position = await _locationService.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      _addWeatherMarkers();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _addWeatherMarkers() {
    final weather = context.read<WeatherProvider>().currentWeather;
    if (weather != null && _currentPosition != null) {
      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId('current_weather'),
            position: _currentPosition!,
            infoWindow: InfoWindow(
              title: weather.location.city,
              snippet: '${weather.temperature.round()}° | ${weather.condition}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _getMarkerHue(weather.condition),
            ),
          ),
        );
      });
    }
  }

  double _getMarkerHue(String condition) {
    switch (condition.toLowerCase()) {
      case 'rain':
        return BitmapDescriptor.hueAzure;
      case 'clear':
        return BitmapDescriptor.hueYellow;
      case 'clouds':
        return BitmapDescriptor.hueBlue;
      case 'snow':
        return BitmapDescriptor.hueViolet;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  void _toggleMapType() {
    setState(() {
      _mapType = _mapType == 'normal' ? 'hybrid' : 'normal';
    });
  }

  Future<void> _goToCurrentLocation() async {
    final position = await _locationService.getCurrentPosition();
    final controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
            onPressed: _goToCurrentLocation,
          ),
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: _toggleMapType,
          ),
        ],
      ),
      body: GoogleMap(
        mapType: _mapType == 'normal' ? MapType.normal : MapType.hybrid,
        initialCameraPosition: CameraPosition(
          target: _currentPosition ?? const LatLng(0, 0),
          zoom: 12,
        ),
        markers: _markers,
        onMapCreated: (controller) {
          _mapController.complete(controller);
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleMapType,
        child: const Icon(Icons.layers),
      ),
    );
  }
}