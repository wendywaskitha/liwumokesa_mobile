// lib/services/destination_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/destination.dart';
import 'api_service.dart';

class DestinationService extends ApiService {
  Future<Map<String, dynamic>> getDestinations({
    int page = 1,
    int perPage = 10,
    String? search,
    int? categoryId,
    int? districtId,
    String? type,
    bool? featured,
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
      if (categoryId != null) queryParams['category_id'] = categoryId.toString();
      if (districtId != null) queryParams['district_id'] = districtId.toString();
      if (type != null && type.isNotEmpty) queryParams['type'] = type;
      if (featured != null) queryParams['featured'] = featured.toString();

      final uri = Uri.parse('$baseUrl/wisatawan/destinations').replace(
        queryParameters: queryParams,
      );

      print('Making request to: $uri');

      final headers = await getHeaders(withAuth: await isLoggedIn());
      final response = await http.get(uri, headers: headers);

      print('Response status: ${response.statusCode}');
      print('Response body length: ${response.body.length}');

      final responseData = handleResponse(response);

      return _parseDestinationResponse(responseData);
    } catch (e) {
      print('Error in getDestinations: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _parseDestinationResponse(Map<String, dynamic> responseData) {
    try {
      if (!responseData.containsKey('data')) {
        throw Exception('Response does not contain data field');
      }

      final dataField = responseData['data'];
      if (dataField is! Map<String, dynamic>) {
        throw Exception('Data field is not a Map');
      }

      if (!dataField.containsKey('data') || dataField['data'] is! List) {
        throw Exception('Data field does not contain destinations array');
      }

      final destinationsData = dataField['data'] as List;
      print('Found ${destinationsData.length} destinations in response');

      List<Destination> destinations = [];
      for (int i = 0; i < destinationsData.length; i++) {
        try {
          final destinationJson = destinationsData[i];
          if (destinationJson is Map<String, dynamic>) {
            final destination = Destination.fromJson(destinationJson);
            destinations.add(destination);
            print('Successfully parsed destination: ${destination.name}');
          } else {
            print('Warning: Destination at index $i is not a Map');
          }
        } catch (e) {
          print('Error parsing destination at index $i: $e');
        }
      }

      final paginationData = {
        'current_page': dataField['current_page'] ?? 1,
        'last_page': dataField['last_page'] ?? 1,
        'per_page': dataField['per_page'] ?? 10,
        'total': dataField['total'] ?? destinations.length,
      };

      print('Successfully parsed ${destinations.length} destinations');
      print('Pagination: $paginationData');

      return {
        'destinations': destinations,
        'pagination': paginationData,
      };
    } catch (e) {
      print('Error in _parseDestinationResponse: $e');
      rethrow;
    }
  }

  Future<Destination> getDestination(int id) async {
    try {
      final url = Uri.parse('$baseUrl/wisatawan/destinations/$id');
      final headers = await getHeaders(withAuth: await isLoggedIn());

      print('Making request to get destination: $url');

      final response = await http.get(url, headers: headers);

      print('Get destination response status: ${response.statusCode}');
      print('Get destination response body: ${response.body}');

      final responseData = handleResponse(response);

      if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
        return Destination.fromJson(responseData['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Invalid destination response format');
      }
    } catch (e) {
      print('Error in getDestination: $e');
      rethrow;
    }
  }

  Future<List<Destination>> getNearbyDestinations(int id) async {
    try {
      final url = Uri.parse('$baseUrl/wisatawan/destinations/$id/nearby');
      final headers = await getHeaders(withAuth: await isLoggedIn());

      print('Making request to get nearby destinations: $url');

      final response = await http.get(url, headers: headers);

      print('Nearby destinations response status: ${response.statusCode}');
      print('Nearby destinations response body: ${response.body}');

      final responseData = handleResponse(response);

      List<Destination> nearbyDestinations = [];

      if (responseData.containsKey('data')) {
        final data = responseData['data'];
        
        // Jika data adalah List langsung
        if (data is List) {
          print('Processing nearby destinations as direct list');
          for (int i = 0; i < data.length; i++) {
            try {
              final destinationJson = data[i];
              if (destinationJson is Map<String, dynamic>) {
                final destination = Destination.fromJson(destinationJson);
                nearbyDestinations.add(destination);
                print('Successfully parsed nearby destination: ${destination.name}');
              } else {
                print('Warning: Nearby destination at index $i is not a Map');
              }
            } catch (e) {
              print('Error parsing nearby destination at index $i: $e');
            }
          }
        }
        // Jika data memiliki struktur nested
        else if (data is Map<String, dynamic> && data.containsKey('data')) {
          print('Processing nearby destinations as nested structure');
          final destinationsData = data['data'];
          if (destinationsData is List) {
            for (int i = 0; i < destinationsData.length; i++) {
              try {
                final destinationJson = destinationsData[i];
                if (destinationJson is Map<String, dynamic>) {
                  final destination = Destination.fromJson(destinationJson);
                  nearbyDestinations.add(destination);
                  print('Successfully parsed nearby destination: ${destination.name}');
                } else {
                  print('Warning: Nearby destination at index $i is not a Map');
                }
              } catch (e) {
                print('Error parsing nearby destination at index $i: $e');
              }
            }
          }
        }
      }

      print('Successfully parsed ${nearbyDestinations.length} nearby destinations');
      return nearbyDestinations;

    } catch (e) {
      print('Error in getNearbyDestinations: $e');
      // Return empty list untuk avoid crash
      return [];
    }
  }
}
