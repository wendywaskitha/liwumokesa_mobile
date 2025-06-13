// lib/services/creative_economy_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/creative_economy.dart';
import 'api_service.dart';

class CreativeEconomyService extends ApiService {
  
  Future<Map<String, dynamic>> getCreativeEconomies({
    int page = 1,
    int perPage = 10,
    String? search,
    int? categoryId,
    int? districtId,
    bool? isFeatured,
    bool? hasWorkshop,
    bool? hasDirectSelling,
    bool? isVerified,
    double? minPrice,
    double? maxPrice,
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
      if (categoryId != null) {
        queryParams['category_id'] = categoryId.toString();
      }
      if (districtId != null) {
        queryParams['district_id'] = districtId.toString();
      }
      if (isFeatured != null && isFeatured) {
        queryParams['is_featured'] = '1';
      }
      if (hasWorkshop != null && hasWorkshop) {
        queryParams['has_workshop'] = '1';
      }
      if (hasDirectSelling != null && hasDirectSelling) {
        queryParams['has_direct_selling'] = '1';
      }
      if (isVerified != null && isVerified) {
        queryParams['is_verified'] = '1';
      }
      if (minPrice != null) {
        queryParams['min_price'] = minPrice.toString();
      }
      if (maxPrice != null) {
        queryParams['max_price'] = maxPrice.toString();
      }

      final uri = Uri.parse('$baseUrl/wisatawan/creative-economies').replace(
        queryParameters: queryParams,
      );

      print('=== Creative Economy Service Debug ===');
      print('Making request to: $uri');

      final headers = await getHeaders(withAuth: await isLoggedIn());
      print('Request headers: $headers');
      
      final response = await http.get(uri, headers: headers);
      
      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body length: ${response.body.length}');
      
      // Log first 500 characters of response for debugging
      if (response.body.length > 500) {
        print('Response body preview: ${response.body.substring(0, 500)}...');
      } else {
        print('Response body: ${response.body}');
      }

      final responseData = handleResponse(response);
      
      // Parse creative economies dengan error handling yang lebih robust
      return _parseCreativeEconomyResponse(responseData);

    } catch (e) {
      print('Error in getCreativeEconomies: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Map<String, dynamic> _parseCreativeEconomyResponse(Map<String, dynamic> responseData) {
    try {
      print('=== Parsing Creative Economy Response ===');
      print('Response keys: ${responseData.keys.toList()}');
      
      // Berdasarkan response API yang Anda berikan
      if (!responseData.containsKey('data')) {
        throw Exception('Response does not contain data field');
      }

      final dataField = responseData['data'];
      print('Data field type: ${dataField.runtimeType}');
      
      if (dataField is! Map<String, dynamic>) {
        throw Exception('Data field is not a Map');
      }

      print('Data field keys: ${dataField.keys.toList()}');

      // Extract creative economies array
      if (!dataField.containsKey('data') || dataField['data'] is! List) {
        throw Exception('Data field does not contain creative economies array');
      }

      final creativeEconomiesData = dataField['data'] as List;
      print('Found ${creativeEconomiesData.length} creative economies in response');

      // Parse each creative economy with individual error handling
      List<CreativeEconomy> creativeEconomies = [];
      for (int i = 0; i < creativeEconomiesData.length; i++) {
        try {
          final creativeEconomyJson = creativeEconomiesData[i];
          print('Parsing creative economy $i: ${creativeEconomyJson.runtimeType}');
          
          if (creativeEconomyJson is Map<String, dynamic>) {
            // Debug image field specifically
            print('Creative Economy $i image field: ${creativeEconomyJson['featured_image']}');
            
            final creativeEconomy = CreativeEconomy.fromJson(creativeEconomyJson);
            creativeEconomies.add(creativeEconomy);
            
            // Debug parsed image
            print('Parsed creative economy: ${creativeEconomy.name}');
            print('Parsed image URL: ${creativeEconomy.validImageUrl}');
            
            // Call debug method
            creativeEconomy.debugImageInfo();
          } else {
            print('Warning: Creative economy at index $i is not a Map');
          }
        } catch (e) {
          print('Error parsing creative economy at index $i: $e');
          print('Creative economy data: ${creativeEconomiesData[i]}');
          // Continue dengan creative economy lainnya
        }
      }

      // Extract pagination info
      final paginationData = {
        'current_page': dataField['current_page'] ?? 1,
        'last_page': dataField['last_page'] ?? 1,
        'per_page': dataField['per_page'] ?? 10,
        'total': dataField['total'] ?? creativeEconomies.length,
        'from': dataField['from'],
        'to': dataField['to'],
        'first_page_url': dataField['first_page_url'],
        'last_page_url': dataField['last_page_url'],
        'next_page_url': dataField['next_page_url'],
        'prev_page_url': dataField['prev_page_url'],
      };

      print('Successfully parsed ${creativeEconomies.length} creative economies');
      print('Pagination: $paginationData');
      print('=====================================');

      return {
        'creative_economies': creativeEconomies,
        'pagination': paginationData,
      };

    } catch (e) {
      print('Error in _parseCreativeEconomyResponse: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Get single creative economy detail
  Future<CreativeEconomy> getCreativeEconomy(int id) async {
    try {
      final url = Uri.parse('$baseUrl/wisatawan/creative-economies/$id');
      
      print('=== Get Creative Economy Detail ===');
      print('Making request to: $url');
      
      final headers = await getHeaders(withAuth: await isLoggedIn());
      print('Request headers: $headers');

      final response = await http.get(url, headers: headers);
      
      print('Response status: ${response.statusCode}');
      print('Response body length: ${response.body.length}');
      
      // Log response for debugging
      if (response.body.length > 1000) {
        print('Response body preview: ${response.body.substring(0, 1000)}...');
      } else {
        print('Response body: ${response.body}');
      }
      
      final responseData = handleResponse(response);
      print('Parsed response data keys: ${responseData.keys.toList()}');

      if (responseData.containsKey('data') && responseData['data'] is Map) {
        final creativeEconomyData = responseData['data'] as Map<String, dynamic>;
        print('Creative economy data keys: ${creativeEconomyData.keys.toList()}');
        print('Featured image in detail: ${creativeEconomyData['featured_image']}');
        
        final creativeEconomy = CreativeEconomy.fromJson(creativeEconomyData);
        print('Successfully parsed creative economy detail: ${creativeEconomy.name}');
        print('Detail image URL: ${creativeEconomy.validImageUrl}');
        
        // Debug image info
        creativeEconomy.debugImageInfo();
        
        return creativeEconomy;
      } else {
        throw Exception('Invalid creative economy response format');
      }
    } catch (e) {
      print('Error in getCreativeEconomy: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Search creative economies
  Future<Map<String, dynamic>> searchCreativeEconomies({
    required String query,
    int page = 1,
    int perPage = 15,
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

      if (latitude != null && longitude != null) {
        queryParams['latitude'] = latitude.toString();
        queryParams['longitude'] = longitude.toString();
        if (radius != null) {
          queryParams['radius'] = radius.toString();
        }
      }

      final uri = Uri.parse('$baseUrl/wisatawan/creative-economies/search').replace(
        queryParameters: queryParams,
      );

      print('Making search request to: $uri');

      final headers = await getHeaders(withAuth: await isLoggedIn());
      final response = await http.get(uri, headers: headers);
      
      print('Search response status: ${response.statusCode}');
      print('Search response body length: ${response.body.length}');

      final responseData = handleResponse(response);
      
      return _parseCreativeEconomyResponse(responseData);

    } catch (e) {
      print('Error in searchCreativeEconomies: $e');
      rethrow;
    }
  }

  // Get featured creative economies
  Future<List<CreativeEconomy>> getFeaturedCreativeEconomies({
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'is_featured': '1',
        'per_page': limit.toString(),
      };

      final uri = Uri.parse('$baseUrl/wisatawan/creative-economies').replace(
        queryParameters: queryParams,
      );

      print('=== Get Featured Creative Economies ===');
      print('Making featured request to: $uri');

      final headers = await getHeaders(withAuth: await isLoggedIn());
      final response = await http.get(uri, headers: headers);
      
      print('Featured response status: ${response.statusCode}');
      print('Featured response body length: ${response.body.length}');

      final responseData = handleResponse(response);
      final parsedData = _parseCreativeEconomyResponse(responseData);
      
      final featuredList = parsedData['creative_economies'] as List<CreativeEconomy>;
      print('Featured creative economies count: ${featuredList.length}');
      
      // Debug each featured item
      for (int i = 0; i < featuredList.length; i++) {
        print('Featured $i: ${featuredList[i].name} - Image: ${featuredList[i].validImageUrl}');
      }
      
      return featuredList;

    } catch (e) {
      print('Error in getFeaturedCreativeEconomies: $e');
      rethrow;
    }
  }

  // Get creative economies by category
  Future<Map<String, dynamic>> getCreativeEconomiesByCategory({
    required int categoryId,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      return await getCreativeEconomies(
        categoryId: categoryId,
        page: page,
        perPage: perPage,
      );
    } catch (e) {
      print('Error in getCreativeEconomiesByCategory: $e');
      rethrow;
    }
  }

  // Get creative economies by district
  Future<Map<String, dynamic>> getCreativeEconomiesByDistrict({
    required int districtId,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      return await getCreativeEconomies(
        districtId: districtId,
        page: page,
        perPage: perPage,
      );
    } catch (e) {
      print('Error in getCreativeEconomiesByDistrict: $e');
      rethrow;
    }
  }

  // Get creative economies with workshop
  Future<Map<String, dynamic>> getCreativeEconomiesWithWorkshop({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      return await getCreativeEconomies(
        hasWorkshop: true,
        page: page,
        perPage: perPage,
      );
    } catch (e) {
      print('Error in getCreativeEconomiesWithWorkshop: $e');
      rethrow;
    }
  }

  // Get verified creative economies
  Future<Map<String, dynamic>> getVerifiedCreativeEconomies({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      return await getCreativeEconomies(
        isVerified: true,
        page: page,
        perPage: perPage,
      );
    } catch (e) {
      print('Error in getVerifiedCreativeEconomies: $e');
      rethrow;
    }
  }

  // Get creative economies by price range
  Future<Map<String, dynamic>> getCreativeEconomiesByPriceRange({
    required double minPrice,
    required double maxPrice,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      return await getCreativeEconomies(
        minPrice: minPrice,
        maxPrice: maxPrice,
        page: page,
        perPage: perPage,
      );
    } catch (e) {
      print('Error in getCreativeEconomiesByPriceRange: $e');
      rethrow;
    }
  }

  // Helper method untuk test koneksi
  Future<bool> testConnection() async {
    try {
      final uri = Uri.parse('$baseUrl/wisatawan/creative-economies?per_page=1');
      print('Testing connection to: $uri');
      
      final headers = await getHeaders(withAuth: await isLoggedIn());
      final response = await http.get(uri, headers: headers);
      
      print('Test connection status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}
