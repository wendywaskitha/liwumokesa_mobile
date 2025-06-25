// lib/models/destination.dart
import 'dart:convert';

class Destination {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? type;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? visitingHours;
  final double? entranceFee;
  final List<Map<String, dynamic>>? facilities;
  final String? website;
  final String? contact;
  final String? bestTimeToVisit;
  final String? tips;
  final String? featuredImage;
  final bool isFeatured;
  final bool? isWished;
  final Category? category;
  final District? district;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Tambahan untuk relasi baru
  final List<Map<String, dynamic>>? accommodations;
  final List<Map<String, dynamic>>? culinaries;
  final List<Map<String, dynamic>>? transportations;
  final List<Map<String, dynamic>>? creativeEconomies;
  final List<Map<String, dynamic>>? galleries;
  final List<Map<String, dynamic>>? reviews;

  Destination({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.type,
    this.location,
    this.latitude,
    this.longitude,
    this.visitingHours,
    this.entranceFee,
    this.facilities,
    this.website,
    this.contact,
    this.bestTimeToVisit,
    this.tips,
    this.featuredImage,
    required this.isFeatured,
    this.isWished,
    this.category,
    this.district,
    this.createdAt,
    this.updatedAt,
    this.accommodations,
    this.culinaries,
    this.transportations,
    this.creativeEconomies,
    this.galleries,
    this.reviews,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      type: json['type'] as String?,
      location: json['location'] as String?,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      visitingHours: json['visiting_hours'] as String?,
      entranceFee: json['entrance_fee']?.toDouble(),
      facilities: _parseListData(json['facilities']),
      website: json['website'] as String?,
      contact: json['contact'] as String?,
      bestTimeToVisit: json['best_time_to_visit'] as String?,
      tips: json['tips'] as String?,
      featuredImage: json['featured_image'] as String?,
      isFeatured: json['is_featured'] ?? false,
      isWished: json['is_wished'] as bool?,
      category: json['category'] != null 
          ? Category.fromJson(json['category'] as Map<String, dynamic>) 
          : null,
      district: json['district'] != null 
          ? District.fromJson(json['district'] as Map<String, dynamic>) 
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      accommodations: _parseListData(json['accommodations']),
      culinaries: _parseListData(json['culinaries']),
      transportations: _parseListData(json['transportations']),
      creativeEconomies: _parseListData(json['creative_economies']),
      galleries: _parseListData(json['galleries']),
      reviews: _parseListData(json['reviews']),
    );
  }

  // Helper method untuk parsing list data
  static List<Map<String, dynamic>>? _parseListData(dynamic data) {
    try {
      if (data == null) return null;
      
      if (data is String) {
        // Jika data berupa string JSON, parse dulu
        if (data.isEmpty) return null;
        final parsedData = jsonDecode(data);
        if (parsedData is List) {
          return parsedData.cast<Map<String, dynamic>>();
        }
      } else if (data is List) {
        // Jika sudah berupa List
        return data.cast<Map<String, dynamic>>();
      }
      
      return null;
    } catch (e) {
      print('Error parsing list data: $e');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'type': type,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'visiting_hours': visitingHours,
      'entrance_fee': entranceFee,
      'facilities': facilities != null ? jsonEncode(facilities) : null,
      'website': website,
      'contact': contact,
      'best_time_to_visit': bestTimeToVisit,
      'tips': tips,
      'featured_image': featuredImage,
      'is_featured': isFeatured,
      'is_wished': isWished,
      'category': category?.toJson(),
      'district': district?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'accommodations': accommodations != null ? jsonEncode(accommodations) : null,
      'culinaries': culinaries != null ? jsonEncode(culinaries) : null,
      'transportations': transportations != null ? jsonEncode(transportations) : null,
      'creative_economies': creativeEconomies != null ? jsonEncode(creativeEconomies) : null,
      'galleries': galleries != null ? jsonEncode(galleries) : null,
      'reviews': reviews != null ? jsonEncode(reviews) : null,
    };
  }

  // Helper methods
  String get displayPrice {
    if (entranceFee == null || entranceFee == 0) {
      return 'Gratis';
    }
    return 'Rp ${entranceFee!.toStringAsFixed(0)}';
  }

  String get imageUrl {
    if (featuredImage == null || featuredImage!.isEmpty) return '';
    return 'http://10.0.2.2:8000/storage/$featuredImage';
  }

  bool get hasValidCoordinates {
    return latitude != null && longitude != null;
  }

  bool get hasAccommodations {
    return accommodations != null && accommodations!.isNotEmpty;
  }

  bool get hasCulinaries {
    return culinaries != null && culinaries!.isNotEmpty;
  }

  bool get hasTransportations {
    return transportations != null && transportations!.isNotEmpty;
  }

  bool get hasCreativeEconomies {
    return creativeEconomies != null && creativeEconomies!.isNotEmpty;
  }

  bool get hasGalleries {
    return galleries != null && galleries!.isNotEmpty;
  }

  bool get hasReviews {
    return reviews != null && reviews!.isNotEmpty;
  }

  // Method untuk mendapatkan rating rata-rata dari reviews
  double get averageRating {
    if (reviews == null || reviews!.isEmpty) return 0.0;
    
    double totalRating = 0.0;
    int validRatings = 0;
    
    for (var review in reviews!) {
      if (review['rating'] != null) {
        totalRating += (review['rating'] as num).toDouble();
        validRatings++;
      }
    }
    
    return validRatings > 0 ? totalRating / validRatings : 0.0;
  }

  // Method untuk mendapatkan jumlah total reviews
  int get totalReviews {
    return reviews?.length ?? 0;
  }
}

class Category {
  final int id;
  final String name;
  final String? description;
  final String? icon;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}
