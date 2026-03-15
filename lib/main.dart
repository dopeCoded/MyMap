import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'providers/map_provider.dart';
import 'models/place.dart';
import 'components/search/google_search_bar.dart';
import 'components/search/google_category_chips.dart';
import 'components/search/search_overlay.dart';
import 'components/search/search_results_sheet.dart';
import 'components/details/explore_sheet.dart';
import 'components/details/spot_detail_sheet.dart';
import 'components/details/saved_places_sheet.dart';
import 'components/details/commute_sheet.dart';
import 'components/details/contribute_sheet.dart';
import 'components/details/updates_sheet.dart';
import 'components/directions/directions_ui.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MapProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps UI Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1A73E8),
      ),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late AppleMapController mapController;
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(35.681236, 139.767125),
    zoom: 15,
  );

  void _onMapCreated(AppleMapController controller) {
    mapController = controller;
  }

  void _handleSearch(String value) {
    if (value.trim().isEmpty) return;
    _searchController.text = value;
    final mapProvider = context.read<MapProvider>();
    mapProvider.performSearch(value);

    // 検索結果がある場合、最初の結果付近にカメラを移動
    if (mapProvider.searchResults.isNotEmpty) {
      final first = mapProvider.searchResults.first;
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: first.position, zoom: 14),
        ),
      );
    }
  }

  void _selectPlace(Place place) {
    final mapProvider = context.read<MapProvider>();
    mapProvider.addToHistory(place);
    mapProvider.selectPlace(place);
    _searchController.text = place.name;
    setState(() => _selectedIndex = 0);
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: place.position, zoom: 16),
      ),
    );
  }

  void _exitSearchResults() {
    final mapProvider = context.read<MapProvider>();
    mapProvider.exitSearchResults();
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);

    // ルートが設定されたらカメラを移動
    if (mapProvider.routeBounds != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        mapController.animateCamera(
          CameraUpdate.newLatLngBounds(mapProvider.routeBounds!, 50),
        );
        mapProvider.clearRouteBounds();
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          // 地図
          AppleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _kInitialPosition,
            mapType: mapProvider.mapType,
            trafficEnabled: mapProvider.trafficEnabled,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            annotations: _buildAnnotations(mapProvider),
            polylines: mapProvider.polylines,
            onTap: (_) {
              if (!mapProvider.isSearchResultsMode) {
                mapProvider.selectPlace(null);
              }
            },
          ),

          // Directions UI
          if (mapProvider.isDirectionsMode)
            const DirectionsUI(),

          // ── 検索結果モード ──
          if (mapProvider.isSearchResultsMode && !mapProvider.isDirectionsMode) ...[
            // 検索結果バー + フィルタチップ
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GoogleSearchBar(
                    controller: _searchController,
                    onSubmitted: _handleSearch,
                    onFocusChanged: (focused) => mapProvider.setSearchFocus(focused),
                    isResultsMode: true,
                    onBackFromResults: _exitSearchResults,
                  ),
                  const SearchResultsFilterChips(),
                ],
              ),
            ),
            // 検索結果シート
            DraggableScrollableSheet(
              initialChildSize: 0.45,
              minChildSize: 0.12,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                  ),
                  child: SearchResultsSheet(
                    scrollController: scrollController,
                    onPlaceTap: _selectPlace,
                    onDirectionsTap: (place) {
                      _selectPlace(place);
                      context.read<MapProvider>().setDirectionsMode(true);
                    },
                  ),
                );
              },
            ),
            // 「地図を表示」ボタン
            Positioned(
              right: 16,
              bottom: 24,
              child: GestureDetector(
                onTap: () {
                  // シートを最小化（実装簡易版）
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map, size: 18, color: Colors.blue[700]),
                      const SizedBox(width: 6),
                      Text(
                        '地図を表示',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // ── 探索タブUI（検索結果・経路モード以外）──
          if (_selectedIndex == 0 &&
              !mapProvider.isDirectionsMode &&
              !mapProvider.isSearchResultsMode) ...[
            // 検索オーバーレイ（フォーカス時のみ、検索バーの後ろ）
            if (mapProvider.isSearchFocused)
              SearchOverlay(
                searchController: _searchController,
                onSearch: _handleSearch,
                onPlaceTap: _selectPlace,
              ),
            // カテゴリチップ（非フォーカス時のみ、検索バーの下）
            if (!mapProvider.isSearchFocused)
              Positioned(
                top: MediaQuery.of(context).padding.top + 64,
                left: 0,
                right: 0,
                child: GoogleCategoryChips(
                  onCategoryPressed: _handleSearch,
                ),
              ),
            // 検索バー: 常に同じPositionedに配置（ツリーから外さない）
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: GoogleSearchBar(
                controller: _searchController,
                onSubmitted: _handleSearch,
                onFocusChanged: (focused) => mapProvider.setSearchFocus(focused),
              ),
            ),
          ],

          // Map Control Buttons
          if (_selectedIndex == 0 &&
              !mapProvider.isSearchFocused &&
              !mapProvider.isDirectionsMode &&
              !mapProvider.isSearchResultsMode) ...[
            Positioned(
              right: 12,
              top: MediaQuery.of(context).padding.top + 130,
              child: Column(
                children: [
                  _buildMapFab(Icons.layers_outlined, onTap: _showMapTypeSheet),
                  const SizedBox(height: 12),
                  _buildMapFab(
                    mapProvider.trafficEnabled ? Icons.traffic : Icons.traffic_outlined,
                    color: mapProvider.trafficEnabled ? Colors.blue : Colors.black87,
                    onTap: () => mapProvider.toggleTraffic(),
                  ),
                  const SizedBox(height: 12),
                  _buildMapFab(Icons.explore_outlined),
                ],
              ),
            ),

            Positioned(
              right: 12,
              bottom: 140,
              child: FloatingActionButton(
                onPressed: () => mapController.animateCamera(
                  CameraUpdate.newCameraPosition(_kInitialPosition),
                ),
                backgroundColor: Colors.white,
                mini: true,
                shape: const CircleBorder(),
                child: const Icon(Icons.my_location, color: Colors.blue),
              ),
            ),

            _buildDraggableSheet(mapProvider),
          ],

          // Other Tab Views
          if (_selectedIndex == 1)
            const SafeArea(child: CommuteSheet()),
          if (_selectedIndex == 2)
            const SafeArea(child: SavedPlacesSheet()),
          if (_selectedIndex == 3)
            const SafeArea(child: ContributeSheet()),
          if (_selectedIndex == 4)
            const SafeArea(child: UpdatesSheet()),
        ],
      ),
      bottomNavigationBar:
          (mapProvider.isSearchFocused || mapProvider.isDirectionsMode || mapProvider.isSearchResultsMode)
              ? null
              : NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (i) => setState(() => _selectedIndex = i),
                  height: 65,
                  destinations: const [
                    NavigationDestination(icon: Icon(Icons.explore), label: '探索'),
                    NavigationDestination(icon: Icon(Icons.commute), label: '移動'),
                    NavigationDestination(icon: Icon(Icons.bookmark_border), label: '保存済み'),
                    NavigationDestination(icon: Icon(Icons.add_circle_outline), label: '投稿'),
                    NavigationDestination(icon: Icon(Icons.notifications_none), label: '最新'),
                  ],
                ),
    );
  }

  Set<Annotation> _buildAnnotations(MapProvider provider) {
    // 検索結果モード時は結果のアノテーションを表示
    if (provider.isSearchResultsMode) {
      return provider.searchResults.map((place) {
        return Annotation(
          annotationId: AnnotationId(place.id),
          position: place.position,
          onTap: () => _selectPlace(place),
          infoWindow: InfoWindow(title: place.name, snippet: place.category),
        );
      }).toSet();
    }

    // 通常時は全場所のアノテーションを表示
    return provider.allPlaces.map((place) {
      return Annotation(
        annotationId: AnnotationId(place.id),
        position: place.position,
        onTap: () => _selectPlace(place),
        infoWindow: InfoWindow(title: place.name, snippet: place.category),
      );
    }).toSet();
  }

  Widget _buildDraggableSheet(MapProvider provider) {
    return DraggableScrollableSheet(
      initialChildSize: 0.12,
      minChildSize: 0.12,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: provider.selectedPlace == null
              ? ExploreSheet(scrollController: scrollController)
              : SpotDetailSheet(scrollController: scrollController),
        );
      },
    );
  }

  Widget _buildMapFab(IconData icon, {VoidCallback? onTap, Color color = Colors.black87}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  void _showMapTypeSheet() {
    final provider = context.read<MapProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (c) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('地図の種類', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTypeItem(MapType.standard, 'デフォルト', Icons.map, provider),
                _buildTypeItem(MapType.satellite, '航空写真', Icons.satellite_alt, provider),
                _buildTypeItem(MapType.hybrid, 'ハイブリッド', Icons.layers, provider),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeItem(MapType t, String l, IconData i, MapProvider provider) {
    bool s = provider.mapType == t;
    return GestureDetector(
      onTap: () {
        provider.setMapType(t);
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: s ? Colors.blue[50] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: s ? Colors.blue : Colors.transparent, width: 2),
            ),
            child: Icon(i, color: s ? Colors.blue : Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(l, style: TextStyle(fontSize: 12, color: s ? Colors.blue : Colors.black87)),
        ],
      ),
    );
  }
}
