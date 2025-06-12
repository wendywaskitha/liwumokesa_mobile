// lib/providers/destination_provider.dart
import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../services/destination_service.dart';

class DestinationProvider with ChangeNotifier {
  final DestinationService _destinationService = DestinationService();
  
  List<Destination> _destinations = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _hasMore = true;

  List<Destination> get destinations => _destinations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> loadDestinations({
    bool refresh = false,
    String? search,
    int? categoryId,
    bool? featured,
  }) async {
    print('loadDestinations called with refresh: $refresh'); // Debug log

    if (refresh) {
      _destinations.clear();
      _currentPage = 1;
      _hasMore = true;
      _error = null;
    }

    if (_isLoading || !_hasMore) {
      print('Skipping load: isLoading=$_isLoading, hasMore=$_hasMore'); // Debug log
      return;
    }

    _setLoading(true);
    _error = null;

    try {
      print('Calling API service...'); // Debug log
      
      final result = await _destinationService.getDestinations(
        page: _currentPage,
        search: search,
        categoryId: categoryId,
        featured: featured,
      );

      print('API result received: ${result.keys}'); // Debug log

      final newDestinations = result['destinations'] as List<Destination>;
      final pagination = result['pagination'];

      print('New destinations count: ${newDestinations.length}'); // Debug log

      if (refresh) {
        _destinations = newDestinations;
      } else {
        _destinations.addAll(newDestinations);
      }

      _currentPage = pagination['current_page'] + 1;
      _lastPage = pagination['last_page'];
      _hasMore = _currentPage <= _lastPage;

      print('Updated state: destinations=${_destinations.length}, hasMore=$_hasMore'); // Debug log

    } catch (e) {
      print('Error in loadDestinations: $e'); // Debug log
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Get single destination
  Future<Destination?> getDestination(int id) async {
    try {
      return await _destinationService.getDestination(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void _setLoading(bool loading) {
    print('Setting loading: $loading'); // Debug log
    _isLoading = loading;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
