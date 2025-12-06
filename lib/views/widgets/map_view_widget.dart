import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../controllers/location_controller.dart';

class MapViewWidget extends StatefulWidget {
  const MapViewWidget({super.key});

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {
  final MapController _mapController = MapController();
  final LocationController locationController = Get.find<LocationController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentLoc = locationController.currentLocation.value;

      if (currentLoc == null) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Waiting for location...'),
            ],
          ),
        );
      }

      final currentLatLng = LatLng(currentLoc.latitude, currentLoc.longitude);


      final List<Marker> markers = [
        Marker(
          point: currentLatLng,
          width: 80,
          height: 80,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'You are here',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 25,
              ),
            ],
          ),
        ),
      ];


      final List<LatLng> polylinePoints = locationController.locationHistory
          .map((loc) => LatLng(loc.latitude, loc.longitude))
          .toList();

      return FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: currentLatLng,
          initialZoom: 15.0,
          minZoom: 5.0,
          maxZoom: 20.0,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.googlemap',
            maxZoom: 19,
          ),
          // Polyline Layer (Path history)
          if (polylinePoints.length > 1)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: polylinePoints,
                  strokeWidth: 4.0,
                  color: Colors.blue.withOpacity(0.7),
                  borderStrokeWidth: 2.0,
                  borderColor: Colors.white,
                ),
              ],
            ),

          MarkerLayer(
            markers: markers,
          ),

          // RichAttributionWidget(
          //   attributions: [
          //     TextSourceAttribution(
          //       'OpenStreetMap contributors',
          //       onTap: () {},
          //     ),
          //   ],
          // ),
        ],
      );
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
