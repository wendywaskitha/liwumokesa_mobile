// lib/models/culinary.dart
import 'dart:convert';

class Culinary {
  final int id;
  final String name;
  final String slug;
  final String? type;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;
  final int? districtId;
  final double? priceRangeStart;
  final double? priceRangeEnd;
  final String? openingHours;
  final String? contactPerson;
  final String? phoneNumber;
  final String? featuredImage;
  final bool status;
  final Map<String, dynamic>? socialMedia;
  final bool hasVegetarianOption;
  final bool halalCertified;
  final bool hasDelivery;
  final List<Map<String, dynamic>>? featuredMenu;
  final bool isRecommended;
  final int? categoryId;
  final double averageRating;
  final int reviewsCount;
  final District? district;
  final List<Map<String, dynamic>>? galleries;
  final List<Map<String, dynamic>>? reviews;
  final List<Map<String, dynamic>>? destinations;
  final double? distance;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Culinary({
    required this.id,
    required this.name,
    required this.slug,
    this.type,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.districtId,
    this.priceRangeStart,
    this.priceRangeEnd,
    this.openingHours,
    this.contactPerson,
    this.phoneNumber,
    this.featuredImage,
    required this.status,
    this.socialMedia,
    required this.hasVegetarianOption,
    required this.halalCertified,
    required this.hasDelivery,
    this.featuredMenu,
    required this.isRecommended,
    this.categoryId,
    required this.averageRating,
    required this.reviewsCount,
    this.district,
    this.galleries,
    this.reviews,
    this.destinations,
    this.distance,
    this.createdAt,
    this.updatedAt,
  });

  factory Culinary.fromJson(Map<String, dynamic> json) {
    return Culinary(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      type: json['type'] as String?,
      description: json['description'] as String?,
      address: json['address'] as String?,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      districtId: json['district_id'] as int?,
      priceRangeStart: json['price_range_start']?.toDouble(),
      priceRangeEnd: json['price_range_end']?.toDouble(),
      openingHours: json['opening_hours'] as String?,
      contactPerson: json['contact_person'] as String?,
      phoneNumber: json['phone_number'] as String?,
      featuredImage: json['featured_image'] as String?,
      status: json['status'] ?? true,
      socialMedia: _parseSocialMedia(json['social_media']),
      hasVegetarianOption: json['has_vegetarian_option'] ?? false,
      halalCertified: json['halal_certified'] ?? false,
      hasDelivery: json['has_delivery'] ?? false,
      featuredMenu: _parseListData(json['featured_menu']),
      isRecommended: json['is_recommended'] ?? false,
      categoryId: json['category_id'] as int?,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      district: json['district'] != null
          ? District.fromJson(json['district'] as Map<String, dynamic>)
          : null,
      galleries: _parseListData(json['galleries']),
      reviews: _parseListData(json['reviews']),
      destinations: _parseListData(json['destinations']),
      distance: json['distance']?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  static List<Map<String, dynamic>>? _parseListData(dynamic data) {
    try {
      if (data == null) return null;

      if (data is String) {
        if (data.isEmpty) return null;
        try {
          final parsedData = jsonDecode(data);
          if (parsedData is List) {
            // Handle mixed types dalam list
            List<Map<String, dynamic>> result = [];
            for (var item in parsedData) {
              if (item is Map<String, dynamic>) {
                result.add(item);
              } else if (item is String) {
                // Convert string to map
                result.add({'name': item, 'price': null});
              } else {
                print('Unknown item type in list: ${item.runtimeType}');
              }
            }
            return result;
          } else if (parsedData is Map<String, dynamic>) {
            return [parsedData];
          }
        } catch (e) {
          print('Error parsing JSON string: $e');
          // Fallback: treat as single string item
          return [
            {'name': data, 'price': null}
          ];
        }
      } else if (data is List) {
        // Handle mixed types dalam list
        List<Map<String, dynamic>> result = [];
        for (var item in data) {
          if (item is Map<String, dynamic>) {
            result.add(item);
          } else if (item is String) {
            result.add({'name': item, 'price': null});
          } else {
            print('Unknown item type in list: ${item.runtimeType}');
          }
        }
        return result;
      } else if (data is Map<String, dynamic>) {
        return [data];
      }

      return null;
    } catch (e) {
      print('Error parsing list data: $e');
      return null;
    }
  }

  static Map<String, dynamic>? _parseSocialMedia(dynamic data) {
    try {
      if (data == null) return null;

      if (data is String) {
        if (data.isEmpty) return null;

        // Cek apakah string adalah JSON
        if (data.startsWith('{') && data.endsWith('}')) {
          try {
            final parsedData = jsonDecode(data);
            if (parsedData is Map<String, dynamic>) {
              return parsedData;
            }
          } catch (e) {
            print('Error parsing JSON social media: $e');
          }
        }

        // Jika bukan JSON, treat sebagai username/handle
        // Deteksi platform berdasarkan format
        Map<String, dynamic> socialMedia = {};

        if (data.startsWith('@')) {
          // Instagram atau Twitter handle
          if (data.toLowerCase().contains('instagram') ||
              data.toLowerCase().contains('ig')) {
            socialMedia['instagram'] = data;
          } else {
            // Default ke Instagram jika dimulai dengan @
            socialMedia['instagram'] = data;
          }
        } else if (data.toLowerCase().contains('facebook') ||
            data.toLowerCase().contains('fb')) {
          socialMedia['facebook'] = data;
        } else if (data.toLowerCase().contains('whatsapp') ||
            data.toLowerCase().contains('wa')) {
          socialMedia['whatsapp'] = data;
        } else if (data.toLowerCase().contains('twitter')) {
          socialMedia['twitter'] = data;
        } else if (data.contains('http') || data.contains('www')) {
          socialMedia['website'] = data;
        } else {
          // Default platform
          socialMedia['social'] = data;
        }

        return socialMedia;
      } else if (data is Map<String, dynamic>) {
        return data;
      }

      return null;
    } catch (e) {
      print('Error parsing social media: $e');
      return null;
    }
  }

  // Helper methods
  String get displayPrice {
    if (priceRangeStart == null || priceRangeEnd == null) {
      return 'Harga tidak tersedia';
    }
    return 'Rp ${_formatPrice(priceRangeStart!)} - Rp ${_formatPrice(priceRangeEnd!)}';
  }

  String get imageUrl {
    if (featuredImage == null || featuredImage!.isEmpty) return '';
    return 'http://10.0.2.2:8000/storage/$featuredImage';
  }

  bool get hasValidCoordinates {
    return latitude != null && longitude != null;
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}jt';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}rb';
    }
    return price.toStringAsFixed(0);
  }
}

class District {
  final int id;
  final String name;
  final String? description;

  District({
    required this.id,
    required this.name,
    this.description,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }
}
