import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user_location.dart';

class LocationHistoryList extends StatelessWidget {
  final List<UserLocation> locations;

  const LocationHistoryList({super.key, required this.locations});

  @override
  Widget build(BuildContext context) {
    if (locations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No location history yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: locations.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final location = locations[index];
        return _LocationHistoryCard(location: location, index: index);
      },
    );
  }
}

class _LocationHistoryCard extends StatelessWidget {
  final UserLocation location;
  final int index;

  const _LocationHistoryCard({required this.location, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm:ss a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: theme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.city ?? 'Unknown City',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${dateFormat.format(location.timestamp)} • ${timeFormat.format(location.timestamp)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.my_location,
              label: 'Coordinates',
              value:
                  '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
            ),
            const SizedBox(height: 8),
            if (location.state != null)
              _InfoRow(icon: Icons.map, label: 'State', value: location.state!),
            if (location.state != null) const SizedBox(height: 8),
            if (location.pincode != null)
              _InfoRow(
                icon: Icons.pin_drop,
                label: 'Pincode',
                value: location.pincode!,
              ),
            if (location.pincode != null) const SizedBox(height: 8),
            if (location.fullAddress != null)
              _InfoRow(
                icon: Icons.home,
                label: 'Address',
                value: location.fullAddress!,
                maxLines: 3,
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final int maxLines;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
