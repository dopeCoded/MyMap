import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import '../../providers/map_provider.dart';

class DirectionsUI extends StatelessWidget {
  const DirectionsUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.read<MapProvider>().setDirectionsMode(false),
                ),
                const Expanded(
                  child: Column(
                    children: [
                      _DirectionInput(hint: '現在地', isSource: true),
                      SizedBox(height: 8),
                      _DirectionInput(hint: '目的地を入力', isSource: false),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.swap_vert, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TransportChip(icon: Icons.directions_car, label: '15分', isSelected: true),
                  _TransportChip(icon: Icons.directions_transit, label: '25分'),
                  _TransportChip(icon: Icons.directions_walk, label: '45分'),
                  _TransportChip(icon: Icons.directions_bike, label: '20分'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DirectionInput extends StatelessWidget {
  final String hint;
  final bool isSource;

  const _DirectionInput({required this.hint, required this.isSource});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(
            isSource ? Icons.my_location : Icons.location_on,
            size: 16,
            color: isSource ? Colors.blue : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hint,
              style: TextStyle(color: isSource ? Colors.black87 : Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransportChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const _TransportChip({
    required this.icon,
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final provider = context.read<MapProvider>();
        // 現在地(東京駅付近)から皇居付近へのルートをシミュレート
        provider.showRoute(
          const LatLng(35.6812, 139.7671),
          const LatLng(35.6835, 139.7615),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.blue : Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
