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
  final List<Map<String, dynamic>>? facilities; // Ubah tipe data
  final String? website;
  final String? contact;
  final String? bestTimeToVisit;
  final String? tips;
  final String? featuredImage;
  final bool isFeatured;
  final bool? isWished;
  final Category? category;
  final District? district;

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
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    // Parse facilities dengan error handling
    List<Map<String, dynamic>>? facilitiesList;
    try {
      if (json['facilities'] != null) {
        if (json['facilities'] is String) {
          // Jika facilities berupa string JSON, parse dulu
          final facilitiesString = json['facilities'] as String;
          final facilitiesData = jsonDecode(facilitiesString);
          if (facilitiesData is List) {
            facilitiesList = facilitiesData.cast<Map<String, dynamic>>();
          }
        } else if (json['facilities'] is List) {
          // Jika sudah berupa List
          facilitiesList = (json['facilities'] as List).cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      print('Error parsing facilities for destination ${json['name']}: $e');
      facilitiesList = null;
    }

    return Destination(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      type: json['type'],
      location: json['location'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      visitingHours: json['visiting_hours'],
      entranceFee: json['entrance_fee']?.toDouble(),
      facilities: facilitiesList,
      website: json['website'],
      contact: json['contact'],
      bestTimeToVisit: json['best_time_to_visit'],
      tips: json['tips'],
      featuredImage: json['featured_image'],
      isFeatured: json['is_featured'] ?? false,
      isWished: json['is_wished'],
      category: json['category'] != null 
          ? Category.fromJson(json['category']) 
          : null,
      district: json['district'] != null 
          ? District.fromJson(json['district']) 
          : null,
    );
  }
}

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }
}

class District {
  final int id;
  final String name;

  District({required this.id, required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'],
      name: json['name'],
    );
  }
}
