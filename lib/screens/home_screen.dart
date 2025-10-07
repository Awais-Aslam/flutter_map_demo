import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_demo/provider/home_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().updateUserLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Home Screen',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: Stack(
          children: [
            _buildMap(context),
            const _BottomInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        final position = provider.currentPosition;

        if (position == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: LatLng(position.latitude, position.longitude),
            initialZoom: 15,
            onTap: (tapPosition, point) async {
              try {
                await provider.updateDropOffLocation(point);
                mapController.move(point, mapController.camera.zoom);

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Drop-off location set!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                debugPrint('Failed to update drop-off: $e');
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.flutter_map_demo',
            ),
            if (provider.pickup != null && provider.dropoff != null)
              _buildPolyline([provider.pickup!, provider.dropoff!]),
            _buildMarkers(provider),
          ],
        );
      },
    );
  }

  PolylineLayer _buildPolyline(List<LatLng> points) {
    return PolylineLayer(
      polylines: [
        Polyline(
          points: points,
          color: Colors.blue,
          strokeWidth: 3.0,
          pattern: const StrokePattern.dotted(),
        ),
      ],
    );
  }

  MarkerLayer _buildMarkers(HomeProvider provider) {
    final markers = <Marker>[];

    if (provider.pickup != null) {
      markers.add(
        Marker(
          point: provider.pickup!,
          width: 50,
          height: 50,
          child: const Icon(
            Icons.location_on,
            color: Colors.green,
            size: 45,
          ),
        ),
      );
    }

    if (provider.dropoff != null) {
      markers.add(
        Marker(
          point: provider.dropoff!,
          width: 50,
          height: 50,
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 45,
          ),
        ),
      );
    }

    return MarkerLayer(markers: markers);
  }
}

class _BottomInfoCard extends StatelessWidget {
  const _BottomInfoCard();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Consumer<HomeProvider>(
        builder: (context, provider, child) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.pickupAddress.isNotEmpty
                            ? provider.pickupAddress
                            : 'Fetching pickup location...',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.flag, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.dropoffAddress.isNotEmpty
                            ? provider.dropoffAddress
                            : 'Tap map to set drop-off',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Distance: ${provider.distanceKm > 0 ? provider.distanceKm.toStringAsFixed(2) : '--'} km',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Fare: €${provider.estimatedFare > 0 ? provider.estimatedFare.toStringAsFixed(2) : '--'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
