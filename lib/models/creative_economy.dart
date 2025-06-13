// lib/models/creative_economy.dart
class CreativeEconomy {
  final int id;
  final String name;
  final String slug;
  final String? shortDescription;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final String? priceRangeText;
  final bool hasWorkshop;
  final bool hasDirectSelling;
  final bool isFeatured;
  final bool isVerified;
  final String? featuredImage;
  final double averageRating;
  final District? district;
  final Category? category;
  final int galleryCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CreativeEconomy({
    required this.id,
    required this.name,
    required this.slug,
    this.shortDescription,
    this.address,
    this.latitude,
    this.longitude,
    this.phoneNumber,
    this.email,
    this.website,
    this.priceRangeText,
    required this.hasWorkshop,
    required this.hasDirectSelling,
    required this.isFeatured,
    required this.isVerified,
    this.featuredImage,
    required this.averageRating,
    this.district,
    this.category,
    required this.galleryCount,
    this.createdAt,
    this.updatedAt,
  });

  factory CreativeEconomy.fromJson(Map<String, dynamic> json) {
    return CreativeEconomy(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      shortDescription: json['short_description'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      phoneNumber: json['phone_number'],
      email: json['email'],
      website: json['website'],
      priceRangeText: json['price_range_text'],
      hasWorkshop: json['has_workshop'] ?? false,
      hasDirectSelling: json['has_direct_selling'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      isVerified: json['is_verified'] ?? false,
      featuredImage: json['featured_image'],
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      district: json['district'] != null ? District.fromJson(json['district']) : null,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      galleryCount: json['gallery_count'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }
}

class District {
  final int id;
  final String name;

  District({required this.id, required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class CreativeEconomyResponse {
  final bool success;
  final String message;
  final PaginatedData<CreativeEconomy> data;

  CreativeEconomyResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CreativeEconomyResponse.fromJson(Map<String, dynamic> json) {
    return CreativeEconomyResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: PaginatedData<CreativeEconomy>.fromJson(
        json['data'],
        (item) => CreativeEconomy.fromJson(item),
      ),
    );
  }
}

class PaginatedData<T> {
  final int currentPage;
  final List<T> data;
  final String? firstPageUrl;
  final int? from;
  final int lastPage;
  final int perPage;
  final int? to;
  final int total;

  PaginatedData({
    required this.currentPage,
    required this.data,
    this.firstPageUrl,
    this.from,
    required this.lastPage,
    required this.perPage,
    this.to,
    required this.total,
  });

  factory PaginatedData.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedData<T>(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List? ?? [])
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      to: json['to'],
      total: json['total'] ?? 0,
    );
  }
}
