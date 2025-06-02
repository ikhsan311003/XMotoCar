import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VehicleCard extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  final VoidCallback onTap;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brand = vehicle['brand'] ?? '';
    final model = vehicle['model'] ?? '';
    final name = '$brand $model';

    final price = double.tryParse(vehicle['price_per_day'].toString()) ?? 0;
    final formattedPrice = NumberFormat.decimalPattern('id').format(price);

    final status = (vehicle['status'] ?? '').toString().toUpperCase();

    // Support averageRating or average_rating from API
    final ratingRaw = double.tryParse(
      vehicle['averageRating']?.toString() ??
      vehicle['average_rating']?.toString() ??
      '0',
    ) ?? 0.0;
    final rating = ratingRaw.toStringAsFixed(1);

    final imageUrl = vehicle['image_url'] ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2E1E50),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.network(
                imageUrl.isNotEmpty
                    ? imageUrl
                    : 'https://via.placeholder.com/300x180.png?text=No+Image',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/no_image.png',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                name.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Rp $formattedPrice/hari',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 6),
            Text(
              status,
              style: TextStyle(
                color: status == 'AVAILABLE' ? Colors.greenAccent : Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$rating / 5',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
