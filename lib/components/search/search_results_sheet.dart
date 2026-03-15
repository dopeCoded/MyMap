import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/place.dart';
import '../../providers/map_provider.dart';

class SearchResultsFilterChips extends StatelessWidget {
  const SearchResultsFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            // チューンアイコン
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.tune, size: 18, color: Colors.grey[700]),
            ),
            const SizedBox(width: 8),
            _buildFilterChip('並べ替え', hasDropdown: true),
            const SizedBox(width: 8),
            _buildFilterChip('現在営業中'),
            const SizedBox(width: 8),
            _buildFilterChip('他のフィルタ', isLink: true),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool hasDropdown = false, bool isLink = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isLink ? const Color(0xFF1A73E8) : Colors.grey[800],
            ),
          ),
          if (hasDropdown) ...[
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey[700]),
          ],
        ],
      ),
    );
  }
}

class SearchResultsSheet extends StatelessWidget {
  final ScrollController scrollController;
  final Function(Place) onPlaceTap;
  final Function(Place) onDirectionsTap;

  const SearchResultsSheet({
    super.key,
    required this.scrollController,
    required this.onPlaceTap,
    required this.onDirectionsTap,
  });

  @override
  Widget build(BuildContext context) {
    final mapProvider = context.watch<MapProvider>();
    final results = mapProvider.searchResults;

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        _buildHandle(),
        ...results.map((place) => _buildResultCard(context, place)),
        const SizedBox(height: 100),
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

  Widget _buildResultCard(BuildContext context, Place place) {
    final distance = Place.formatDistance(MapProvider.currentLocation, place.position);

    return InkWell(
      onTap: () => onPlaceTap(place),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 店名
            Text(
              place.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),

            // 評価行: 星 + レビュー数 + 価格帯 + 距離
            Row(
              children: [
                Text(
                  '${place.rating}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 4),
                _buildStars(place.rating),
                const SizedBox(width: 4),
                Text(
                  '(${_formatReviewCount(place.reviewsCount)})',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                Text(
                  ' ・ ${place.priceRange} ・ $distance',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 2),

            // カテゴリ + 住所
            Row(
              children: [
                Text(
                  '${place.category} ・ ${_shortenAddress(place.address)}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                if (place.category == 'ラーメン') ...[
                  const SizedBox(width: 4),
                  Text(' ・ ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  Icon(Icons.accessible, size: 14, color: Colors.grey[600]),
                ],
              ],
            ),
            const SizedBox(height: 2),

            // 営業状態
            Row(
              children: [
                Text(
                  place.isOpen ? '営業中' : '営業時間外',
                  style: TextStyle(
                    fontSize: 13,
                    color: place.isOpen ? Colors.green[700] : Colors.red[700],
                  ),
                ),
                if (place.closingTime.isNotEmpty)
                  Text(
                    place.isOpen
                        ? ' ・ 営業終了: ${place.closingTime}'
                        : ' ・ 営業開始: ${place.closingTime}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // アクションボタン行
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildActionChip(Icons.directions, '経路', isPrimary: true, onTap: () => onDirectionsTap(place)),
                  const SizedBox(width: 8),
                  _buildActionChip(Icons.restaurant_menu, 'メニュー'),
                  const SizedBox(width: 8),
                  _buildActionChip(Icons.phone, '電話'),
                  const SizedBox(width: 8),
                  _buildActionChip(Icons.share, '共有'),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey[200]),
          ],
        ),
      ),
    );
  }

  Widget _buildStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, size: 14, color: Color(0xFFE8A100));
        } else if (index < rating) {
          return const Icon(Icons.star_half, size: 14, color: Color(0xFFE8A100));
        } else {
          return Icon(Icons.star_border, size: 14, color: Colors.grey[400]);
        }
      }),
    );
  }

  Widget _buildActionChip(IconData icon, String label, {bool isPrimary = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFD3E3FD) : Colors.white,
          border: Border.all(
            color: isPrimary ? const Color(0xFFD3E3FD) : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isPrimary ? const Color(0xFF1A73E8) : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isPrimary ? const Color(0xFF1A73E8) : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatReviewCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count % 1000 == 0 ? 0 : 0)},${(count % 1000).toString().padLeft(3, '0')}';
    }
    return count.toString();
  }

  String _shortenAddress(String address) {
    // "東京都渋谷区" を除いて短くする
    final shortened = address
        .replaceAll('東京都', '')
        .replaceAll('埼玉県', '');
    if (shortened.length > 20) {
      return '${shortened.substring(0, 20)}…';
    }
    return shortened;
  }
}
