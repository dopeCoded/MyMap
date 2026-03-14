import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps Style UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
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
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  Set<Annotation> _annotations = {};
  bool _isSearching = false;

  // Native MethodChannel for Apple MapKit Search
  static const platform = MethodChannel('com.example.map/search');

  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(35.681236, 139.767125),
    zoom: 15,
  );

  void _onMapCreated(AppleMapController controller) {
    mapController = controller;
  }

  // Apple純正 (MapKit) の検索エンジンを呼び出す
  Future<void> _handleSearch(String value) async {
    if (value.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      // Swift側を呼び出し、座標（緯度・経度）を受け取る
      final dynamic result = await platform.invokeMethod('searchLocation', {"address": value});
      
      if (result != null) {
        final double lat = result['lat'];
        final double lng = result['lng'];
        final String name = result['name'] ?? value;
        final latLng = LatLng(lat, lng);

        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: 15),
          ),
        );

        setState(() {
          _annotations = {
            Annotation(
              annotationId: AnnotationId(value),
              position: latLng,
              infoWindow: InfoWindow(title: name),
            ),
          };
        });
      } else {
        _showErrorSnackBar('「$value」が見つかりませんでした');
      }
    } on PlatformException catch (error) {
      debugPrint('Native error: ${error.message}');
      _showErrorSnackBar('検索中にエラーが発生しました');
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Apple Map
          AppleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _kInitialPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            annotations: _annotations,
          ),

          // Search Bar and Categories
          SafeArea(
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 8),
                _buildCategoryList(),
              ],
            ),
          ),

          if (_isSearching)
            const Center(child: CircularProgressIndicator()),

          // Right Side Buttons
          Positioned(
            right: 12,
            top: MediaQuery.of(context).padding.top + 130,
            child: Column(
              children: [
                _buildMapActionButton(Icons.layers_outlined),
                const SizedBox(height: 12),
                _buildMapActionButton(Icons.explore_outlined),
              ],
            ),
          ),

          // Current Location Button
          Positioned(
            right: 12,
            bottom: 20,
            child: FloatingActionButton(
              onPressed: () {
                mapController.animateCamera(
                  CameraUpdate.newCameraPosition(_kInitialPosition),
                );
              },
              backgroundColor: Colors.white,
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(Icons.my_location, color: Colors.blueAccent),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onSubmitted: _handleSearch,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'ここで検索',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
            prefixIcon: const Icon(Icons.menu, color: Colors.grey),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.blue),
                    onPressed: () => _handleSearch(_searchController.text),
                  ),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blue[100],
                    child: const Text('R', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    final categories = [
      {'icon': Icons.restaurant, 'label': 'レストラン'},
      {'icon': Icons.local_gas_station, 'label': 'ガソリン'},
      {'icon': Icons.hotel, 'label': 'ホテル'},
      {'icon': Icons.local_cafe, 'label': 'カフェ'},
    ];

    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ActionChip(
              avatar: Icon(categories[index]['icon'] as IconData, size: 16, color: Colors.black87),
              label: Text(categories[index]['label'] as String),
              onPressed: () {
                _searchController.text = categories[index]['label'] as String;
                _handleSearch(_searchController.text);
              },
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Colors.transparent),
              ),
              elevation: 2,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapActionButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 4,
          ),
        ],
      ),
      child: Icon(icon, color: Colors.blueGrey, size: 22),
    );
  }
}
