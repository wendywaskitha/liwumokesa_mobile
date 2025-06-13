// lib/models/accommodation.dart
import 'dart:convert';

class Accommodation {
  final int id;
  final String name;
  final String slug;
  final String type;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;
  final District? district;
  final double? priceRangeStart;
  final double? priceRangeEnd;
  final String? priceRangeText;
  final List<String>? facilities;
  final String? contactPerson;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final String? bookingLink;
  final String? featuredImage;
  final bool status;
  final double averageRating;
  final int approvedReviewsCount;
  final int galleryCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Fields for detail
  final List<dynamic>? galleries;
  final List<dynamic>? reviews;
  final List<dynamic>? destinations;
  final List<dynamic>? culturalHeritages;
  final List<dynamic>? nearbyDestinations;

  Accommodation({
    required this.id,
    required this.name,
    required this.slug,
    required this.type,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.district,
    this.priceRangeStart,
    this.priceRangeEnd,
    this.priceRangeText,
    this.facilities,
    this.contactPerson,
    this.phoneNumber,
    this.email,
    this.website,
    this.bookingLink,
    this.featuredImage,
    required this.status,
    required this.averageRating,
    required this.approvedReviewsCount,
    required this.galleryCount,
    this.createdAt,
    this.updatedAt,
    this.galleries,
    this.reviews,
    this.destinations,
    this.culturalHeritages,
    this.nearbyDestinations,
  });

  factory Accommodation.fromJson(Map<String, dynamic> json) {
    print('Accommodation JSON: ${json.toString()}');
    
    // Parse featured image dengan validasi
    String? parsedFeaturedImage;
    if (json['featured_image'] != null) {
      final imageValue = json['featured_image'].toString();
      if (imageValue.isNotEmpty && imageValue != 'null') {
        if (imageValue.startsWith('/') || !imageValue.startsWith('http')) {
          parsedFeaturedImage = 'http://10.0.2.2:8000/storage/$imageValue';
        } else {
          parsedFeaturedImage = imageValue;
        }
      }
    }

    // Parse facilities
    List<String>? parsedFacilities;
    if (json['facilities'] != null) {
      if (json['facilities'] is List) {
        parsedFacilities = List<String>.from(json['facilities']);
      } else if (json['facilities'] is String) {
        // Jika facilities berupa string JSON
        try {
          final decoded = jsonDecode(json['facilities']); // Gunakan jsonDecode, bukan json.decode
          if (decoded is List) {
            parsedFacilities = List<String>.from(decoded);
          }
        } catch (e) {
          print('Error parsing facilities: $e');
        }
      }
    }

    return Accommodation(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      type: json['type'] ?? '',
      description: json['description'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      district: json['district'] != null ? District.fromJson(json['district']) : null,
      priceRangeStart: json['price_range_start']?.toDouble(),
      priceRangeEnd: json['price_range_end']?.toDouble(),
      priceRangeText: json['price_range_text'],
      facilities: parsedFacilities,
      contactPerson: json['contact_person'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      website: json['website'],
      bookingLink: json['booking_link'],
      featuredImage: parsedFeaturedImage,
      status: json['status'] ?? false,
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      approvedReviewsCount: json['approved_reviews_count'] ?? 0,
      galleryCount: json['gallery_count'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      galleries: json['galleries'],
      reviews: json['reviews'],
      destinations: json['destinations'],
      culturalHeritages: json['cultural_heritages'],
      nearbyDestinations: json['nearby_destinations'],
    );
  }

  // Helper method untuk mendapatkan URL gambar yang valid
  String? get validImageUrl {
    if (featuredImage == null || featuredImage!.isEmpty) return null;
    
    if (featuredImage!.startsWith('http')) {
      return featuredImage;
    }
    
    String cleanPath = featuredImage!;
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    
    return 'http://10.0.2.2:8000/storage/$cleanPath';
  }

  // Helper method untuk debugging
  void debugInfo() {
    print('=== Accommodation Debug ===');
    print('ID: $id');
    print('Name: $name');
    print('Type: $type');
    print('Featured Image: $featuredImage');
    print('Valid Image URL: $validImageUrl');
    print('Facilities: $facilities');
    print('===========================');
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

class AccommodationResponse {
  final bool success;
  final String message;
  final PaginatedData<Accommodation> data;

  AccommodationResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AccommodationResponse.fromJson(Map<String, dynamic> json) {
    return AccommodationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: PaginatedData<Accommodation>.fromJson(
        json['data'],
        (item) => Accommodation.fromJson(item),
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
