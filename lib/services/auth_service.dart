// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'api_service.dart';

class AuthService extends ApiService {
  
  // Login method (tetap sama)
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/wisatawan/login');
    final headers = await getHeaders();
    
    final body = json.encode({
      'email': email,
      'password': password,
    });

    final response = await http.post(url, headers: headers, body: body);
    final responseData = handleResponse(response);

    if (responseData['success']) {
      final token = responseData['data']['access_token'];
      await saveToken(token);
      
      return {
        'success': true,
        'user': User.fromJson(responseData['data']['user']),
        'token': token,
      };
    }

    return responseData;
  }

  // PERBAIKAN: Method logout yang lebih robust
  Future<Map<String, dynamic>> logout() async {
    try {
      final url = Uri.parse('$baseUrl/wisatawan/logout');
      final headers = await getHeaders(withAuth: true);

      print('Attempting logout to: $url'); // Debug log
      print('Headers: $headers'); // Debug log

      final response = await http.post(url, headers: headers);
      print('Logout response status: ${response.statusCode}'); // Debug log
      print('Logout response body: ${response.body}'); // Debug log

      // Hapus token terlebih dahulu sebelum handle response
      await removeToken();

      // Handle response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'message': responseData['message'] ?? 'Logout berhasil'
        };
      } else {
        // Meskipun API error, token sudah dihapus
        return {
          'success': true,
          'message': 'Logout berhasil (local)'
        };
      }
    } catch (e) {
      print('Logout error: $e'); // Debug log
      // Tetap hapus token meskipun ada error
      await removeToken();
      return {
        'success': true,
        'message': 'Logout berhasil (offline)'
      };
    }
  }

  // Get Profile
  Future<User> getProfile() async {
    final url = Uri.parse('$baseUrl/wisatawan/profile');
    final headers = await getHeaders(withAuth: true);

    final response = await http.get(url, headers: headers);
    final responseData = handleResponse(response);

    return User.fromJson(responseData['data']);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
