import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class HomeProvider extends ChangeNotifier {
  Position? currentPosition;
  LatLng? pickup;
  LatLng? dropoff;
  String pickupAddress = '';
  String dropoffAddress = '';
  double distanceKm = 0.0;

  Future<void> updateUserLocation() async {
    try {
      currentPosition = await determinePosition();

      pickup = LatLng(currentPosition!.latitude, currentPosition!.longitude);
      pickupAddress = await getAddressFromLatLng(pickup!);

      debugPrint(
        'Latitude: ${currentPosition?.latitude}, Longitude: ${currentPosition?.longitude}',
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<String> getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];

      return '${place.street}, ${place.locality}';
    } catch (e) {
      debugPrint('Error: $e');
      return '';
    }
  }

  Future<void> updateDropOffLocation(LatLng point) async {
    if (currentPosition != null) {
      dropoff = point;
      dropoffAddress = await getAddressFromLatLng(point);
      calculateDistanceInKm(
        currentPosition!.latitude,
        currentPosition!.longitude,
        point.latitude,
        point.longitude,
      );
      notifyListeners();
    }
  }

  void calculateDistanceInKm(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    double distanceInMeters = Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );

    distanceKm = distanceInMeters / 1000;
  }

  double get estimatedFare => distanceKm * 1.0; // €1 per km

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}

final homeProvider = ChangeNotifierProvider(
  create: (context) => HomeProvider(),
);
