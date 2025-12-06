import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/location_controller.dart';
import '../controllers/theme_controller.dart';
import 'widgets/map_view_widget.dart';
import 'widgets/location_history_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LocationController locationController = Get.put(LocationController());
    final ThemeController themeController = Get.put(ThemeController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Location Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                themeController.isDarkMode.value
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () => themeController.toggleTheme(),
              tooltip: 'Toggle Theme',
            ),
          ),
          Obx(() {
            if (locationController.locationHistory.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Clear History'),
                      content: const Text(
                        'Are you sure you want to clear all location history?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            locationController.clearHistory();
                            Get.back();
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                },
                tooltip: 'Clear History',
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        // Show loading
        if (locationController.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Initializing location services...'),
              ],
            ),
          );
        }

        // Show permission error
        if (!locationController.hasPermission.value) {
          return _PermissionDeniedView(
            permissionStatus: locationController.permissionStatus.value,
            errorMessage: locationController.errorMessage.value,
            onRequestPermission: () => locationController.requestPermission(),
            onOpenSettings: () => locationController.openSettings(),
          );
        }

        // Show error if any
        if (locationController.errorMessage.value.isNotEmpty &&
            locationController.currentLocation.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    locationController.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => locationController.initializeLocation(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Main content
        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              // Current Location Card - Compact version
              const _CurrentLocationCardCompact(),
              // Tab Bar
              Container(
                color: Theme.of(context).cardColor,
                child: const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.map), text: 'Map View'),
                    Tab(icon: Icon(Icons.history), text: 'History'),
                  ],
                ),
              ),

              Expanded(
                child: TabBarView(
                  children: [
                    const MapViewWidget(),
                    LocationHistoryList(
                      locations: locationController.locationHistory,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _CurrentLocationCardCompact extends StatelessWidget {
  const _CurrentLocationCardCompact();

  @override
  Widget build(BuildContext context) {
    final LocationController locationController =
        Get.find<LocationController>();
    final theme = Theme.of(context);

    return Obx(() {
      final currentLoc = locationController.currentLocation.value;

      if (currentLoc == null) {
        return const SizedBox.shrink();
      }

      final timeFormat = DateFormat('hh:mm a');

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.primaryColor,
              theme.primaryColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Current Location',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.greenAccent,
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: Colors.greenAccent,
                                  size: 6,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Live',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${currentLoc.city ?? 'Unknown'}, ${currentLoc.state ?? 'Unknown'}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  timeFormat.format(currentLoc.timestamp),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _CompactInfoChip(
                    icon: Icons.gps_fixed,
                    label:
                        '${currentLoc.latitude.toStringAsFixed(4)}, ${currentLoc.longitude.toStringAsFixed(4)}',
                  ),
                ),
                if (currentLoc.pincode != null) ...[
                  const SizedBox(width: 8),
                  _CompactInfoChip(
                    icon: Icons.pin_drop,
                    label: currentLoc.pincode!,
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _CompactInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CompactInfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionDeniedView extends StatelessWidget {
  final String permissionStatus;
  final String errorMessage;
  final VoidCallback onRequestPermission;
  final VoidCallback onOpenSettings;

  const _PermissionDeniedView({
    required this.permissionStatus,
    required this.errorMessage,
    required this.onRequestPermission,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final isDeniedForever = permissionStatus == 'denied_forever';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDeniedForever ? Icons.location_off : Icons.location_disabled,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              isDeniedForever
                  ? 'Location Permission Required'
                  : 'Location Access Needed',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage.isNotEmpty
                  ? errorMessage
                  : 'This app needs location permission to track your location and display it on the map.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (isDeniedForever)
              ElevatedButton.icon(
                onPressed: onOpenSettings,
                icon: const Icon(Icons.settings),
                label: const Text('Open Settings'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: onRequestPermission,
                icon: const Icon(Icons.location_on),
                label: const Text('Grant Permission'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
