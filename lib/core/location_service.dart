import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'error_utils.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String address;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

class LocationService {
  Future<bool> requestPermission() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return false;

      var status = await Geolocator.checkPermission();
      if (status == LocationPermission.denied) {
        status = await Geolocator.requestPermission();
      }
      return status == LocationPermission.whileInUse ||
          status == LocationPermission.always;
    } catch (e, s) {
      logError(e, s, context: 'LocationService.requestPermission');
      return false;
    }
  }

  Future<LocationResult?> getCurrentLocation() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) return null;

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      final address = await _reverseGeocode(pos.latitude, pos.longitude);

      return LocationResult(
        latitude: pos.latitude,
        longitude: pos.longitude,
        address: address,
      );
    } catch (e, s) {
      logError(e, s, context: 'LocationService.getCurrentLocation');
      return null;
    }
  }

  Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = <String>[
          if (p.street != null && p.street!.isNotEmpty) p.street!,
          if (p.subLocality != null && p.subLocality!.isNotEmpty)
            p.subLocality!,
          if (p.locality != null && p.locality!.isNotEmpty) p.locality!,
          if (p.administrativeArea != null &&
              p.administrativeArea!.isNotEmpty)
            p.administrativeArea!,
        ];
        return parts.join('، ');
      }
    } catch (_) {}
    return '$lat, $lng';
  }

  Future<String> addressFromCoordinates(double lat, double lng) async {
    return _reverseGeocode(lat, lng);
  }
}
