// lib/models/creative_economy.dart
class CreativeEconomy {
  final int id;
  final String name;
  final String slug;
  final String? shortDescription;
  final String? description;
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

  // Field tambahan untuk detail
  final String? businessHours;
  final String? ownerName;
  final int? establishmentYear;
  final int? employeesCount;
  final String? productsDescription;
  final String? workshopInformation;
  final bool acceptsCreditCard;
  final bool providesTraining;
  final bool shippingAvailable;
  final List<dynamic>? products;
  final List<dynamic>? reviews;
  final List<dynamic>? galleries;
  final List<dynamic>? featuredProducts; // Tambahkan field ini

  CreativeEconomy({
    required this.id,
    required this.name,
    required this.slug,
    this.shortDescription,
    this.description,
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
    this.businessHours,
    this.ownerName,
    this.establishmentYear,
    this.employeesCount,
    this.productsDescription,
    this.workshopInformation,
    required this.acceptsCreditCard,
    required this.providesTraining,
    required this.shippingAvailable,
    this.products,
    this.reviews,
    this.galleries,
    this.featuredProducts, // Tambahkan di constructor
  });

  factory CreativeEconomy.fromJson(Map<String, dynamic> json) {
    // Debug print untuk melihat data yang diterima
    print('CreativeEconomy JSON: ${json.toString()}');
    print('Featured Image Raw: ${json['featured_image']}');
    print('Featured Products Raw: ${json['featured_products']}');

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

    // Parse featured_products langsung dari API
    List<dynamic>? parsedFeaturedProducts;
    if (json['featured_products'] != null &&
        json['featured_products'] is List) {
      parsedFeaturedProducts = json['featured_products'] as List<dynamic>;
      print('Parsed ${parsedFeaturedProducts.length} featured products');

      // Debug setiap featured product
      for (int i = 0; i < parsedFeaturedProducts.length; i++) {
        final product = parsedFeaturedProducts[i];
        print(
            'Featured Product $i: ${product['name']} - Price: ${product['price']}');
      }
    }

    print('Parsed Featured Image: $parsedFeaturedImage');
    print(
        'Final featured products count: ${parsedFeaturedProducts?.length ?? 0}');

    return CreativeEconomy(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      shortDescription: json['short_description'],
      description: json['description'],
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
      featuredImage: parsedFeaturedImage,
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      district:
          json['district'] != null ? District.fromJson(json['district']) : null,
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
      galleryCount: json['gallery_count'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      businessHours: json['business_hours'],
      ownerName: json['owner_name'],
      establishmentYear: json['establishment_year'],
      employeesCount: json['employees_count'],
      productsDescription: json['products_description'],
      workshopInformation: json['workshop_information'],
      acceptsCreditCard: json['accepts_credit_card'] ?? false,
      providesTraining: json['provides_training'] ?? false,
      shippingAvailable: json['shipping_available'] ?? false,
      products: json['products'], // Products biasa
      reviews: json['reviews'],
      galleries: json['galleries'],
      featuredProducts: parsedFeaturedProducts, // Featured products dari API
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
  void debugImageInfo() {
    print('=== Creative Economy Debug ===');
    print('ID: $id');
    print('Name: $name');
    print('Featured Image Raw: $featuredImage');
    print('Valid Image URL: $validImageUrl');
    print('Products Count: ${products?.length ?? 0}');
    print('Featured Products Count: ${featuredProducts?.length ?? 0}');
    print('===============================');
  }
}

// District, Category, dan class lainnya tetap sama...
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
