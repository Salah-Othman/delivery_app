import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/location_service.dart';

class MapPickerResult {
  final double latitude;
  final double longitude;
  final String address;

  const MapPickerResult({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

class MapPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapPickerScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late final MapController _mapController;
  final _locationService = LocationService();
  LatLng _center = const LatLng(27.9311, 30.8389);
  String _address = '';
  bool _loadingAddress = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.initialLat != null && widget.initialLng != null) {
      _center = LatLng(widget.initialLat!, widget.initialLng!);
    }
    _updateAddress(_center.latitude, _center.longitude);
  }

  Future<void> _updateAddress(double lat, double lng) async {
    setState(() => _loadingAddress = true);
    final address = await _locationService.addressFromCoordinates(lat, lng);
    if (mounted) {
      setState(() {
        _address = address;
        _loadingAddress = false;
      });
    }
  }

  void _onMapMoved(MapEvent event) {
    final center = _mapController.camera.center;
    setState(() => _center = center);
    _updateAddress(center.latitude, center.longitude);
  }

  void _goToMyLocation() async {
    final loc = await _locationService.getCurrentLocation();
    if (loc != null && mounted) {
      _mapController.move(
        LatLng(loc.latitude, loc.longitude),
        _mapController.camera.zoom,
      );
      setState(() => _center = LatLng(loc.latitude, loc.longitude));
      _updateAddress(loc.latitude, loc.longitude);
    }
  }

  void _confirm() {
    Navigator.pop(
      context,
      MapPickerResult(
        latitude: _center.latitude,
        longitude: _center.longitude,
        address: _address,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختيار الموقع'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _confirm,
            child: const Text('تأكيد'),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 15,
              onMapEvent: _onMapMoved,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'app_delivery',
              ),
            ],
          ),
          Center(
            child: Icon(
              Icons.location_on_rounded,
              size: 48,
              color: theme.colorScheme.primary,
            ),
          ),
          Positioned(
            left: 16,
            bottom: MediaQuery.of(context).padding.bottom + 100,
            child: FloatingActionButton.small(
              heroTag: 'myLocation',
              onPressed: _goToMyLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_loadingAddress)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: LinearProgressIndicator(),
                        ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _address.isNotEmpty
                                  ? _address
                                  : 'حرك الخريطة لتحديد الموقع',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _confirm,
                          child: const Text('تأكيد الموقع'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
