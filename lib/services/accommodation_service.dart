// lib/services/accommodation_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/accommodation.dart';
import 'api_service.dart';

class AccommodationService extends ApiService {
  
  Future<Map<String, dynamic>> getAccommodations({
    int page = 1,
    int perPage = 10,
    String? search,
    String? type,
    int? districtId,
    double? minPrice,
    double? maxPrice,
    List<String>? facilities,
    String sortBy = 'name',
    String sortOrder = 'asc',
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
        'sort_by': sortBy,
        'sort_order': sortOrder,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      if (districtId != null) {
        queryParams['district_id'] = districtId.toString();
      }
      if (minPrice != null) {
        queryParams['min_price'] = minPrice.toString();
      }
      if (maxPrice != null) {
        queryParams['max_price'] = maxPrice.toString();
      }
      if (facilities != null && facilities.isNotEmpty) {
        queryParams['facilities'] = facilities.join(',');
      }

      final uri = Uri.parse('$baseUrl/wisatawan/accommodations').replace(
        queryParameters: queryParams,
      );

      print('=== Accommodation Service Debug ===');
      print('Making request to: $uri');

      final headers = await getHeaders(withAuth: await isLoggedIn());
      print('Request headers: $headers');
      
      final response = await http.get(uri, headers: headers);
      
      print('Response status: ${response.statusCode}');
      print('Response body length: ${response.body.length}');

      final responseData = handleResponse(response);
      
      return _parseAccommodationResponse(responseData);

    } catch (e) {
      print('Error in getAccommodations: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _parseAccommodationResponse(Map<String, dynamic> responseData) {
    try {
      print('=== Parsing Accommodation Response ===');
      print('Response keys: ${responseData.keys.toList()}');
      
      if (!responseData.containsKey('data')) {
        throw Exception('Response does not contain data field');
      }

      final dataField = responseData['data'];
      print('Data field type: ${dataField.runtimeType}');
      
      if (dataField is! Map<String, dynamic>) {
        throw Exception('Data field is not a Map');
      }

      if (!dataField.containsKey('data') || dataField['data'] is! List) {
        throw Exception('Data field does not contain accommodations array');
      }

      final accommodationsData = dataField['data'] as List;
      print('Found ${accommodationsData.length} accommodations in response');

      List<Accommodation> accommodations = [];
      for (int i = 0; i < accommodationsData.length; i++) {
        try {
          final accommodationJson = accommodationsData[i];
          if (accommodationJson is Map<String, dynamic>) {
            final accommodation = Accommodation.fromJson(accommodationJson);
            accommodations.add(accommodation);
            print('Successfully parsed accommodation: ${accommodation.name}');
          } else {
            print('Warning: Accommodation at index $i is not a Map');
          }
        } catch (e) {
          print('Error parsing accommodation at index $i: $e');
        }
      }

      final paginationData = {
        'current_page': dataField['current_page'] ?? 1,
        'last_page': dataField['last_page'] ?? 1,
        'per_page': dataField['per_page'] ?? 10,
        'total': dataField['total'] ?? accommodations.length,
        'from': dataField['from'],
        'to': dataField['to'],
        'first_page_url': dataField['first_page_url'],
        'last_page_url': dataField['last_page_url'],
        'next_page_url': dataField['next_page_url'],
        'prev_page_url': dataField['prev_page_url'],
      };

      print('Successfully parsed ${accommodations.length} accommodations');
      print('=====================================');

      return {
        'accommodations': accommodations,
        'pagination': paginationData,
      };

    } catch (e) {
      print('Error in _parseAccommodationResponse: $e');
      rethrow;
    }
  }

  Future<Accommodation> getAccommodation(int id) async {
    try {
      final url = Uri.parse('$baseUrl/wisatawan/accommodations/$id');
      
      print('=== Get Accommodation Detail ===');
      print('Making request to: $url');
      
      final headers = await getHeaders(withAuth: await isLoggedIn());
      final response = await http.get(url, headers: headers);
      
      print('Response status: ${response.statusCode}');
      
      final responseData = handleResponse(response);

      if (responseData.containsKey('data') && responseData['data'] is Map) {
        final accommodation = Accommodation.fromJson(responseData['data']);
        print('Successfully parsed accommodation detail: ${accommodation.name}');
        return accommodation;
      } else {
        throw Exception('Invalid accommodation response format');
      }
    } catch (e) {
      print('Error in getAccommodation: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> searchAccommodations({
    required String query,
    int page = 1,
    int perPage = 15,
    String? type,
    int? districtId,
    double? minPrice,
    double? maxPrice,
    List<String>? facilities,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      final queryParams = <String, String>{
        'q': query,
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (type != null) queryParams['type'] = type;
      if (districtId != null) queryParams['district_id'] = districtId.toString();
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
      if (facilities != null && facilities.isNotEmpty) {
        queryParams['facilities'] = facilities.join(',');
      }
      if (latitude != null && longitude != null) {
        queryParams['latitude'] = latitude.toString();
        queryParams['longitude'] = longitude.toString();
        if (radius != null) {
          queryParams['radius'] = radius.toString();
        }
      }

      final uri = Uri.parse('$baseUrl/wisatawan/accommodations/search').replace(
        queryParameters: queryParams,
      );

      print('Making search request to: $uri');

      final headers = await getHeaders(withAuth: await isLoggedIn());
      final response = await http.get(uri, headers: headers);
      
      print('Search response status: ${response.statusCode}');

      final responseData = handleResponse(response);
      
      return _parseAccommodationResponse(responseData);

    } catch (e) {
      print('Error in searchAccommodations: $e');
      rethrow;
    }
  }

  Future<List<String>> getAccommodationTypes() async {
    try {
      final uri = Uri.parse('$baseUrl/wisatawan/accommodations/types');
      
      final headers = await getHeaders(withAuth: await isLoggedIn());
      final response = await http.get(uri, headers: headers);
      
      final responseData = handleResponse(response);
      
      if (responseData['success'] && responseData['data'] is List) {
        return List<String>.from(responseData['data']);
      }
      
      return [];
    } catch (e) {
      print('Error in getAccommodationTypes: $e');
      return [];
    }
  }

  Future<List<String>> getPopularFacilities() async {
    try {
      final uri = Uri.parse('$baseUrl/wisatawan/accommodations/facilities');
      
      final headers = await getHeaders(withAuth: await isLoggedIn());
      final response = await http.get(uri, headers: headers);
      
      final responseData = handleResponse(response);
      
      if (responseData['success'] && responseData['data'] is List) {
        return List<String>.from(responseData['data']);
      }
      
      return [];
    } catch (e) {
      print('Error in getPopularFacilities: $e');
      return [];
    }
  }

  Future<List<Accommodation>> getNearbyAccommodations({
    required double latitude,
    required double longitude,
    double radius = 5,
  }) async {
    try {
      final queryParams = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': radius.toString(),
      };

      final uri = Uri.parse('$baseUrl/wisatawan/accommodations/nearby').replace(
        queryParameters: queryParams,
      );

      final headers = await getHeaders(withAuth: await isLoggedIn());
      final response = await http.get(uri, headers: headers);
      
      final responseData = handleResponse(response);
      
      if (responseData['success'] && responseData['data'] is List) {
        return (responseData['data'] as List)
            .map((json) => Accommodation.fromJson(json))
            .toList();
      }
      
      return [];
    } catch (e) {
      print('Error in getNearbyAccommodations: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getAccommodationsByType(String type, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      return await getAccommodations(
        type: type,
        page: page,
        perPage: perPage,
      );
    } catch (e) {
      print('Error in getAccommodationsByType: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAccommodationsByDistrict(int districtId, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      return await getAccommodations(
        districtId: districtId,
        page: page,
        perPage: perPage,
      );
    } catch (e) {
      print('Error in getAccommodationsByDistrict: $e');
      rethrow;
    }
  }
}
