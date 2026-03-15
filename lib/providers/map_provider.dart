import 'package:flutter/material.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import '../models/place.dart';

class MapProvider with ChangeNotifier {
  Place? _selectedPlace;
  Place? get selectedPlace => _selectedPlace;

  final List<Place> _favorites = [];
  List<Place> get favorites => _favorites;

  Set<Polyline> _polylines = {};
  Set<Polyline> get polylines => _polylines;

  MapType _mapType = MapType.standard;
  MapType get mapType => _mapType;

  bool _trafficEnabled = false;
  bool get trafficEnabled => _trafficEnabled;

  bool _isSearchFocused = false;
  bool get isSearchFocused => _isSearchFocused;

  bool _isDirectionsMode = false;
  bool get isDirectionsMode => _isDirectionsMode;

  // ── 検索関連の状態 ──
  bool _isSearchResultsMode = false;
  bool get isSearchResultsMode => _isSearchResultsMode;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<Place> _searchResults = [];
  List<Place> get searchResults => _searchResults;

  // 現在地（モック: 渋谷駅付近）
  static const LatLng currentLocation = LatLng(35.6580, 139.7016);

  // ── 全てのモック場所データ ──
  final List<Place> allPlaces = [
    Place(
      id: '1',
      name: '東京駅',
      address: '東京都千代田区丸の内１丁目',
      position: LatLng(35.681236, 139.767125),
      rating: 4.4,
      reviewsCount: 12500,
      category: '駅',
      isOpen: true,
      closingTime: '',
      imageUrls: [
        'https://images.unsplash.com/photo-1590766940554-634a7ed41450?auto=format&fit=crop&q=80&w=400',
        'https://images.unsplash.com/photo-1542051841857-5f90071e7989?auto=format&fit=crop&q=80&w=400',
      ],
      reviews: [
        Review(
          authorName: '田中 太郎',
          authorProfileImageUrl: '',
          rating: 5,
          relativeTimeDescription: '1週間前',
          text: '歴史的な建造物で、中には美味しいお店もたくさんあります。',
        ),
      ],
    ),
    Place(
      id: '2',
      name: 'スターバックス コーヒー 皇居外苑 和田倉噴水公園店',
      address: '東京都千代田区皇居外苑３−１',
      position: LatLng(35.6835, 139.7615),
      rating: 4.5,
      reviewsCount: 850,
      category: 'カフェ',
      isOpen: true,
      closingTime: '21:00',
    ),
    Place(
      id: '3',
      name: '一蘭 渋谷店',
      address: '東京都渋谷区神南１丁目２２−７ 岩本ビル B1F',
      position: LatLng(35.6614, 139.6993),
      rating: 4.4,
      reviewsCount: 3906,
      category: 'ラーメン',
      priceRange: '￥1,000〜2,000',
      isOpen: true,
      closingTime: '月 6:00',
      phoneNumber: '03-6427-0835',
    ),
    Place(
      id: '4',
      name: '一蘭 渋谷スペイン坂店',
      address: '東京都渋谷区宇田川町１３−７ コヤスワン B1F',
      position: LatLng(35.6611, 139.6975),
      rating: 4.4,
      reviewsCount: 2177,
      category: 'ラーメン',
      priceRange: '￥1,000〜2,000',
      isOpen: true,
      closingTime: '月 6:00',
      phoneNumber: '03-6416-1123',
    ),
    Place(
      id: '5',
      name: '一蘭 原宿店',
      address: '東京都渋谷区神宮前６丁目５−６',
      position: LatLng(35.6690, 139.7025),
      rating: 4.3,
      reviewsCount: 1821,
      category: 'ラーメン',
      priceRange: '￥1,000〜2,000',
      isOpen: true,
      closingTime: '21:45',
      phoneNumber: '03-3406-6665',
    ),
    Place(
      id: '6',
      name: '一蘭 新宿中央東口店',
      address: '東京都新宿区新宿３丁目３４−１１',
      position: LatLng(35.6907, 139.7019),
      rating: 4.3,
      reviewsCount: 2500,
      category: 'ラーメン',
      priceRange: '￥1,000〜2,000',
      isOpen: true,
      closingTime: '月 6:00',
      phoneNumber: '03-3225-5518',
    ),
    Place(
      id: '7',
      name: '一蘭 池袋店',
      address: '東京都豊島区東池袋１丁目３９−１１',
      position: LatLng(35.7310, 139.7130),
      rating: 4.2,
      reviewsCount: 1500,
      category: 'ラーメン',
      priceRange: '￥1,000〜2,000',
      isOpen: true,
      closingTime: '月 6:00',
      phoneNumber: '03-3989-0871',
    ),
    Place(
      id: '8',
      name: 'レストランよよぎの森',
      address: '東京都渋谷区代々木神園町１ 代々木パー…',
      position: LatLng(35.6712, 139.6950),
      rating: 3.8,
      reviewsCount: 400,
      category: 'レストラン',
      isOpen: true,
      closingTime: '21:00',
    ),
    Place(
      id: '9',
      name: 'イタリアン イルチェーロ 恵比寿',
      address: '東京都渋谷区東３丁目１５ 桑原ビル 101',
      position: LatLng(35.6460, 139.7130),
      rating: 4.1,
      reviewsCount: 320,
      category: 'イタリアン',
      isOpen: false,
      closingTime: '17:30',
      openingHours: '17:30 - 23:00',
    ),
    Place(
      id: '10',
      name: 'パレドール浅草',
      address: '東京都台東区寿１丁目２１ パレ・ドール…',
      position: LatLng(35.7098, 139.7940),
      rating: 3.5,
      reviewsCount: 100,
      category: 'レストラン',
      isOpen: false,
      closingTime: '',
    ),
    Place(
      id: '11',
      name: 'MALIKA 大宮西口店',
      address: '埼玉県さいたま市大宮区桜木町２丁目７…',
      position: LatLng(35.9065, 139.6234),
      rating: 4.0,
      reviewsCount: 300,
      category: 'レストラン',
      isOpen: true,
      closingTime: '22:00',
    ),
    Place(
      id: '12',
      name: '舟渡池公園',
      address: '東京都板橋区舟渡１丁目',
      position: LatLng(35.7870, 139.6790),
      rating: 3.9,
      reviewsCount: 50,
      category: '公園',
      isOpen: true,
      closingTime: '',
    ),
  ];

  // ── 検索履歴 ──
  List<Place> _searchHistory = [];
  List<Place> get searchHistory => _searchHistory;

  MapProvider() {
    // 初期検索履歴をセット（モック）
    _searchHistory = [
      allPlaces.firstWhere((p) => p.id == '3'),  // 一蘭 渋谷店 (ラーメン)
      allPlaces.firstWhere((p) => p.id == '12'), // 舟渡池公園
      allPlaces.firstWhere((p) => p.id == '9'),  // イタリアン イルチェーロ 恵比寿
      allPlaces.firstWhere((p) => p.id == '8'),  // レストランよよぎの森
      allPlaces.firstWhere((p) => p.id == '10'), // パレドール浅草
      allPlaces.firstWhere((p) => p.id == '11'), // MALIKA 大宮西口店
    ];
  }

  // ── 既存メソッド ──

  void selectPlace(Place? place) {
    _selectedPlace = place;
    _isSearchFocused = false;
    _isDirectionsMode = false;
    _isSearchResultsMode = false;
    _polylines = {};
    notifyListeners();
  }

  void toggleFavorite(Place place) {
    if (_favorites.any((p) => p.id == place.id)) {
      _favorites.removeWhere((p) => p.id == place.id);
    } else {
      _favorites.add(place);
    }
    notifyListeners();
  }

  bool isFavorite(Place place) {
    return _favorites.any((p) => p.id == place.id);
  }

  void showRoute(LatLng start, LatLng end) {
    _polylines = {
      Polyline(
        polylineId: PolylineId('route_${DateTime.now().millisecondsSinceEpoch}'),
        points: [
          start,
          LatLng((start.latitude + end.latitude) / 2,
              (start.longitude + end.longitude) / 2 + 0.005),
          end,
        ],
        color: Colors.blueAccent,
        width: 8,
      ),
    };

    _routeBounds = LatLngBounds(
      southwest: LatLng(
        start.latitude < end.latitude ? start.latitude : end.latitude,
        start.longitude < end.longitude ? start.longitude : end.longitude,
      ),
      northeast: LatLng(
        start.latitude > end.latitude ? start.latitude : end.latitude,
        start.longitude > end.longitude ? start.longitude : end.longitude,
      ),
    );

    _isDirectionsMode = false;
    _isSearchFocused = false;
    notifyListeners();
  }

  LatLngBounds? _routeBounds;
  LatLngBounds? get routeBounds => _routeBounds;

  void clearRouteBounds() {
    _routeBounds = null;
  }

  void setDirectionsMode(bool active) {
    _isDirectionsMode = active;
    if (active) {
      _selectedPlace = null;
    }
    notifyListeners();
  }

  void setSearchFocus(bool focused) {
    _isSearchFocused = focused;
    if (!focused) {
      _searchQuery = '';
    }
    notifyListeners();
  }

  void setMapType(MapType type) {
    _mapType = type;
    notifyListeners();
  }

  void toggleTraffic() {
    _trafficEnabled = !_trafficEnabled;
    notifyListeners();
  }

  // ── 検索メソッド ──

  /// オートコンプリート候補を取得
  List<Place> getAutocompleteSuggestions(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return allPlaces.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.address.toLowerCase().contains(q);
    }).toList();
  }

  /// 検索を実行して結果モードに遷移
  void performSearch(String query) {
    _searchQuery = query;
    _searchResults = getAutocompleteSuggestions(query);
    _isSearchResultsMode = true;
    _isSearchFocused = false;
    _selectedPlace = null;
    notifyListeners();
  }

  /// 検索結果の場所を履歴に追加
  void addToHistory(Place place) {
    _searchHistory.removeWhere((p) => p.id == place.id);
    _searchHistory.insert(0, place);
    if (_searchHistory.length > 10) _searchHistory.removeLast();
  }

  /// 検索結果モードを終了
  void exitSearchResults() {
    _isSearchResultsMode = false;
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }
}
