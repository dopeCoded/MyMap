import 'dart:math';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';

class Place {
  final String id;
  final String name;
  final String address;
  final LatLng position;
  final double rating;
  final int reviewsCount;
  final String category;
  final List<String> imageUrls;
  final String priceRange;
  final String phoneNumber;
  final String website;
  final String openingHours;
  final List<Review> reviews;
  final bool isOpen;
  final String closingTime;

  Place({
    required this.id,
    required this.name,
    required this.address,
    required this.position,
    this.rating = 0.0,
    this.reviewsCount = 0,
    required this.category,
    this.imageUrls = const [],
    this.priceRange = '￥￥',
    this.phoneNumber = '03-xxxx-xxxx',
    this.website = 'https://example.com',
    this.openingHours = '09:00 - 21:00',
    this.reviews = const [],
    this.isOpen = true,
    this.closingTime = '',
  });

  /// 2点間の距離を計算してフォーマットした文字列を返す
  static String formatDistance(LatLng from, LatLng to) {
    const double earthRadius = 6371000;
    final dLat = (to.latitude - from.latitude) * pi / 180;
    final dLon = (to.longitude - from.longitude) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(from.latitude * pi / 180) *
            cos(to.latitude * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final d = earthRadius * c;
    if (d < 1000) {
      return '${(d / 50).round() * 50} m';
    } else {
      return '${(d / 1000).toStringAsFixed(1)} km';
    }
  }
}

class Review {
  final String authorName;
  final String authorProfileImageUrl;
  final double rating;
  final String relativeTimeDescription;
  final String text;

  Review({
    required this.authorName,
    required this.authorProfileImageUrl,
    required this.rating,
    required this.relativeTimeDescription,
    required this.text,
  });
}
