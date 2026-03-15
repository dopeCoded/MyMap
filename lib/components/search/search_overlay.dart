import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/place.dart';
import '../../providers/map_provider.dart';

class SearchOverlay extends StatefulWidget {
  final TextEditingController searchController;
  final Function(String) onSearch;
  final Function(Place) onPlaceTap;

  const SearchOverlay({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.onPlaceTap,
  });

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  @override
  void initState() {
    super.initState();
    widget.searchController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final query = widget.searchController.text;
    return Container(
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: query.isEmpty
            ? _buildHistoryView()
            : _buildAutocompleteView(query),
      ),
    );
  }

  // ── 履歴ビュー（テキスト未入力時）──
  Widget _buildHistoryView() {
    final mapProvider = context.watch<MapProvider>();
    final history = mapProvider.searchHistory;

    return ListView(
      padding: const EdgeInsets.only(top: 60),
      children: [
        _buildQuickAccessRow(),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('履歴',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Icon(Icons.info_outline, color: Colors.grey[500], size: 20),
            ],
          ),
        ),
        ...history.map((place) => _buildHistoryItem(place)),
        if (history.length >= 3)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  '最近の履歴をもっと見る',
                  style: TextStyle(color: Color(0xFF1A73E8), fontSize: 14),
                ),
              ),
            ),
          ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.person_outline, color: Colors.grey[600], size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '友だちを検索する場合',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'スマートフォンの連絡先を追加すると、マップで住所を検索できます。',
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '連絡先を追加する',
                      style:
                          TextStyle(color: Color(0xFF1A73E8), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessRow() {
    return SizedBox(
      height: 72,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildQuickAccessItem(
              Icons.home, '自宅', '〒150-0011…', Colors.blue),
          const SizedBox(width: 24),
          _buildQuickAccessItem(
              Icons.work_outline, '職場', '場所を設定', Colors.blue),
          const SizedBox(width: 24),
          _buildQuickAccessItem(Icons.location_on, 'ラーメン', '〒150-…',
              const Color(0xFF6750A4)),
        ],
      ),
    );
  }

  Widget _buildQuickAccessItem(
      IconData icon, String title, String subtitle, Color iconColor) {
    return GestureDetector(
      onTap: () {
        if (title != '職場') {
          widget.onSearch(title);
        }
      },
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              Text(subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Place place) {
    final hasDetails = place.address.isNotEmpty &&
        place.category != '公園' &&
        place.category != '駅';
    final mapProvider = context.read<MapProvider>();

    return InkWell(
      onTap: () {
        mapProvider.addToHistory(place);
        widget.onPlaceTap(place);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildHistoryIcon(place),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.name, style: const TextStyle(fontSize: 15)),
                  if (hasDetails) ...[
                    const SizedBox(height: 2),
                    Text(
                      place.address,
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          place.isOpen ? '営業中' : '営業時間外',
                          style: TextStyle(
                            fontSize: 12,
                            color: place.isOpen
                                ? Colors.green[700]
                                : Colors.red[700],
                          ),
                        ),
                        if (place.closingTime.isNotEmpty)
                          Text(
                            place.isOpen
                                ? ' ・ 営業終了: ${place.closingTime}'
                                : ' ・ 営業開始: ${place.closingTime}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryIcon(Place place) {
    if (place.category == 'ラーメン') {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF6750A4).withAlpha(20),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.location_on,
            color: Color(0xFF6750A4), size: 20),
      );
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.access_time, color: Colors.grey[600], size: 20),
    );
  }

  // ── オートコンプリートビュー（テキスト入力時）──
  Widget _buildAutocompleteView(String query) {
    final mapProvider = context.watch<MapProvider>();
    final suggestions = mapProvider.getAutocompleteSuggestions(query);

    return ListView(
      padding: const EdgeInsets.only(top: 60),
      children: [
        if (suggestions.isNotEmpty)
          _buildBrandSuggestion(query, suggestions.first),
        ...suggestions
            .map((place) => _buildAutocompleteSuggestionItem(place)),
      ],
    );
  }

  Widget _buildBrandSuggestion(String query, Place firstMatch) {
    return InkWell(
      onTap: () => widget.onSearch(query),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.restaurant,
                  color: Colors.deepOrange, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(query, style: const TextStyle(fontSize: 15)),
                  Text('場所を表示',
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(Icons.north_west, color: Colors.grey[400], size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildAutocompleteSuggestionItem(Place place) {
    final distance =
        Place.formatDistance(MapProvider.currentLocation, place.position);

    return InkWell(
      onTap: () {
        context.read<MapProvider>().addToHistory(place);
        widget.onPlaceTap(place);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Column(
                children: [
                  Icon(Icons.location_on_outlined,
                      color: Colors.grey[600], size: 20),
                  const SizedBox(height: 2),
                  Text(
                    distance,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.name, style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(
                    place.address,
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.north_west,
                  color: Colors.grey[400], size: 18),
              onPressed: () {
                widget.searchController.text = place.name;
                widget.searchController.selection =
                    TextSelection.fromPosition(
                  TextPosition(offset: place.name.length),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
