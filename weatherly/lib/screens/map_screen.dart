import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:weatherly/providers/weather_provider.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentLocation;
  Set<Marker> _markers = {};
  String _mapType = 'normal';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _isLoading = false;
      _addMarkers();
    });

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(_currentLocation!, 12),
    );
  }

  void _addMarkers() {
    final weather = context.read<WeatherProvider>().currentWeather;
    if (weather != null && _currentLocation != null) {
      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: _currentLocation!,
            infoWindow: InfoWindow(
              title: weather.location.city,
              snippet: '${weather.temperature.round()}°C, ${weather.condition}',
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
            onPressed: _getCurrentLocation,
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
          target: _currentLocation!,
          zoom: 12,
        ),
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
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