// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Login method
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _authService.login(email, password);
      
      if (result['success']) {
        _user = result['user'];
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // PERBAIKAN: Method logout yang lebih robust
  Future<bool> logout() async {
    _setLoading(true);
    _error = null;

    try {
      // Panggil API logout
      final result = await _authService.logout();
      
      if (result['success']) {
        // Clear user data
        _user = null;
        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? 'Logout gagal';
        return false;
      }
    } catch (e) {
      print('Error during logout: $e'); // Debug log
      // Tetap clear user data meskipun API error
      _user = null;
      notifyListeners();
      return true; // Return true agar UI tetap redirect
    } finally {
      _setLoading(false);
    }
  }

  // Check login status
  Future<void> checkAuthStatus() async {
    _setLoading(true);

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      
      if (isLoggedIn) {
        _user = await _authService.getProfile();
      } else {
        _user = null;
      }
    } catch (e) {
      print('Error checking auth status: $e'); // Debug log
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  // Force logout (untuk emergency logout)
  void forceLogout() {
    _user = null;
    _authService.removeToken();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
