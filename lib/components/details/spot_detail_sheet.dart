import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/place.dart';
import '../../providers/map_provider.dart';

class SpotDetailSheet extends StatelessWidget {
  final ScrollController scrollController;

  const SpotDetailSheet({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);
    final place = mapProvider.selectedPlace;

    if (place == null) {
      return const SizedBox.shrink();
    }

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        _buildHandle(),
        _buildHeroSection(place),
        _buildActionButtons(context, mapProvider, place),
        const Divider(),
        _buildInfoSection(place),
        const Divider(),
        _buildReviewSection(place),
      ],
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeroSection(Place place) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            place.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Text(
                '${place.rating}',
                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star, color: Colors.orange, size: 16),
              const Icon(Icons.star, color: Colors.orange, size: 16),
              const Icon(Icons.star, color: Colors.orange, size: 16),
              const Icon(Icons.star, color: Colors.orange, size: 16),
              const Icon(Icons.star_half, color: Colors.orange, size: 16),
              const SizedBox(width: 4),
              Text('(${place.reviewsCount})', style: const TextStyle(color: Colors.grey)),
            ],
          ),
          Text('${place.category} ・ ${place.priceRange}', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          if (place.imageUrls.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: place.imageUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(place.imageUrls[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, MapProvider mapProvider, Place place) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(Icons.directions, '経路', Colors.blue, isPrimary: true, onTap: () {
            context.read<MapProvider>().setDirectionsMode(true);
          }),
          _buildActionButton(Icons.play_arrow_outlined, '開始', Colors.blue),
          _buildActionButton(
            mapProvider.isFavorite(place) ? Icons.bookmark : Icons.bookmark_border,
            '保存',
            Colors.blue,
            onTap: () => mapProvider.toggleFavorite(place),
          ),
          _buildActionButton(Icons.share, '共有', Colors.blue),
          _buildActionButton(Icons.call, '電話', Colors.blue),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, {bool isPrimary = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPrimary ? Colors.blue : Colors.white,
              shape: BoxShape.circle,
              border: isPrimary ? null : Border.all(color: Colors.grey[300]!),
            ),
            child: Icon(icon, color: isPrimary ? Colors.white : Colors.blue),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.blue, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildInfoSection(Place place) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _buildInfoRow(Icons.location_on_outlined, place.address),
          _buildInfoRow(Icons.access_time_outlined, '営業中 ・ ${place.openingHours}'),
          _buildInfoRow(Icons.language_outlined, place.website, color: Colors.blue),
          _buildInfoRow(Icons.phone_outlined, place.phoneNumber, color: Colors.blue),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: TextStyle(color: color))),
        ],
      ),
    );
  }

  Widget _buildReviewSection(Place place) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('口コミの概要', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // モックレビュー
          ...place.reviews.map((review) => _buildReviewItem(review)),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Review review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 16, backgroundColor: Colors.grey[200]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(review.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(review.relativeTimeDescription, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(review.text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
