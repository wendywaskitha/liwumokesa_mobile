// lib/services/culinary_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/culinary.dart';
import 'api_service.dart';

class CulinaryService extends ApiService {
  Future<Map<String, dynamic>> getCulinaries({
    int page = 1,
    int perPage = 10,
    String? search,
    String? type,
    int? districtId,
    double? minPrice,
    double? maxPrice,
    bool? hasVegetarian,
    bool? halalCertified,
    bool? hasDelivery,
    bool? isRecommended,
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

      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (type != null && type.isNotEmpty) queryParams['type'] = type;
      if (districtId != null)
        queryParams['district_id'] = districtId.toString();
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
      if (hasVegetarian != null)
        queryParams['has_vegetarian'] = hasVegetarian.toString();
      if (halalCertified != null)
        queryParams['halal_certified'] = halalCertified.toString();
      if (hasDelivery != null)
        queryParams['has_delivery'] = hasDelivery.toString();
      if (isRecommended != null)
        queryParams['is_recommended'] = isRecommended.toString();

      final uri = Uri.parse('$baseUrl/wisatawan/culinaries').replace(
        queryParameters: queryParams,
      );

      print('Making request to: $uri');

      final headers = await getHeaders(withAuth: await isLoggedIn());
      final response = await http.get(uri, headers: headers);

      print('Response status: ${response.statusCode}');
      print('Response body length: ${response.body.length}');

      final responseData = handleResponse(response);
      return _parseCulinaryResponse(responseData);
    } catch (e) {
      print('Error in getCulinaries: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _parseCulinaryResponse(
      Map<String, dynamic> responseData) {
    try {
      if (!responseData.containsKey('data')) {
        throw Exception('Response does not contain data field');
      }

      final dataField = responseData['data'];
      if (dataField is! Map<String, dynamic>) {
        throw Exception('Data field is not a Map');
      }

      if (!dataField.containsKey('data') || dataField['data'] is! List) {
        throw Exception('Data field does not contain culinaries array');
      }

      final culinariesData = dataField['data'] as List;
      print('Found ${culinariesData.length} culinaries in response');

      List<Culinary> culinaries = [];
      for (int i = 0; i < culinariesData.length; i++) {
        try {
          final culinaryJson = culinariesData[i];
          if (culinaryJson is Map<String, dynamic>) {
            final culinary = Culinary.fromJson(culinaryJson);
            culinaries.add(culinary);
            print('Successfully parsed culinary: ${culinary.name}');
          } else {
            print('Warning: Culinary at index $i is not a Map');
          }
        } catch (e) {
          print('Error parsing culinary at index $i: $e');
        }
      }

      final paginationData = {
        'current_page': dataField['current_page'] ?? 1,
        'last_page': dataField['last_page'] ?? 1,
        'per_page': dataField['per_page'] ?? 10,
        'total': dataField['total'] ?? culinaries.length,
      };

      print('Successfully parsed ${culinaries.length} culinaries');
      print('Pagination: $paginationData');

      return {
        'culinaries': culinaries,
        'pagination': paginationData,
      };
    } catch (e) {
      print('Error in _parseCulinaryResponse: $e');
      rethrow;
    }
  }

  Future<Culinary> getCulinary(int id) async {
    try {
      final url = Uri.parse('$baseUrl/wisatawan/culinaries/$id');
      final headers = await getHeaders(withAuth: await isLoggedIn());

      print('Making request to get culinary: $url');

      final response = await http.get(url, headers: headers);

      print('Get culinary response status: ${response.statusCode}');

      // Truncate response body for logging to avoid too long logs
      String responseBody = response.body;
      String logBody = responseBody.length > 500
          ? '${responseBody.substring(0, 500)}...[truncated]'
          : responseBody;
      print('Get culinary response body: $logBody');

      final responseData = handleResponse(response);

      if (responseData.containsKey('data') &&
          responseData['data'] is Map<String, dynamic>) {
        try {
          return Culinary.fromJson(
              responseData['data'] as Map<String, dynamic>);
        } catch (parseError) {
          print('Error parsing culinary data: $parseError');
          print('Raw data: ${responseData['data']}');
          rethrow;
        }
      } else {
        throw Exception('Invalid culinary response format');
      }
    } catch (e) {
      print('Error in getCulinary: $e');
      rethrow;
    }
  }

  Future<List<Culinary>> getNearbyCulinaries(int id) async {
    try {
      final url = Uri.parse('$baseUrl/wisatawan/culinaries/$id/nearby');
      final headers = await getHeaders(withAuth: await isLoggedIn());

      print('Making request to get nearby culinaries: $url');

      final response = await http.get(url, headers: headers);

      print('Nearby culinaries response status: ${response.statusCode}');
      print('Nearby culinaries response body: ${response.body}');

      // Handle 404 error gracefully
      if (response.statusCode == 404) {
        print('Nearby culinaries endpoint not found, returning empty list');
        return [];
      }

      final responseData = handleResponse(response);

      List<Culinary> nearbyCulinaries = [];

      if (responseData.containsKey('data')) {
        final data = responseData['data'];

        if (data is List) {
          print('Processing nearby culinaries as direct list');
          for (int i = 0; i < data.length; i++) {
            try {
              final culinaryJson = data[i];
              if (culinaryJson is Map<String, dynamic>) {
                final culinary = Culinary.fromJson(culinaryJson);
                nearbyCulinaries.add(culinary);
                print('Successfully parsed nearby culinary: ${culinary.name}');
              } else {
                print('Warning: Nearby culinary at index $i is not a Map');
              }
            } catch (e) {
              print('Error parsing nearby culinary at index $i: $e');
            }
          }
        }
      }

      print('Successfully parsed ${nearbyCulinaries.length} nearby culinaries');
      return nearbyCulinaries;
    } catch (e) {
      print('Error in getNearbyCulinaries: $e');
      // Return empty list instead of throwing error
      return [];
    }
  }

  Future<List<String>> getCulinaryTypes() async {
    try {
      final url = Uri.parse('$baseUrl/wisatawan/culinaries/types');
      final headers = await getHeaders(withAuth: await isLoggedIn());

      final response = await http.get(url, headers: headers);
      final responseData = handleResponse(response);

      if (responseData.containsKey('data') && responseData['data'] is List) {
        return (responseData['data'] as List).cast<String>();
      } else {
        throw Exception('Invalid culinary types response format');
      }
    } catch (e) {
      print('Error in getCulinaryTypes: $e');
      return [];
    }
  }

  Future<List<Culinary>> getRecommendedCulinaries({int perPage = 5}) async {
    try {
      final url = Uri.parse(
          '$baseUrl/wisatawan/culinaries/recommended?per_page=$perPage');
      final headers = await getHeaders(withAuth: await isLoggedIn());

      final response = await http.get(url, headers: headers);
      final responseData = handleResponse(response);

      if (responseData.containsKey('data') && responseData['data'] is Map) {
        final dataField = responseData['data'] as Map<String, dynamic>;
        if (dataField.containsKey('data') && dataField['data'] is List) {
          return (dataField['data'] as List)
              .where((json) => json is Map<String, dynamic>)
              .map((json) => Culinary.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('Error in getRecommendedCulinaries: $e');
      return [];
    }
  }
}
