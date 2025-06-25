// lib/providers/destination_provider.dart
import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../services/destination_service.dart';

class DestinationProvider with ChangeNotifier {
  final DestinationService _destinationService = DestinationService();

  List<Destination> _destinations = [];
  List<Destination> _featuredDestinations = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _hasMore = true;

  // Getters
  List<Destination> get destinations => _destinations;
  List<Destination> get featuredDestinations => _featuredDestinations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;

  Future<void> loadDestinations({
    bool refresh = false,
    String? search,
    int? categoryId,
    int? districtId,
    String? type,
    bool? featured,
    String sortBy = 'name',
    String sortOrder = 'asc',
  }) async {
    print('loadDestinations called with refresh: $refresh');

    if (refresh) {
      _destinations.clear();
      _currentPage = 1;
      _hasMore = true;
      _error = null;
    }

    if (_isLoading || !_hasMore) {
      print('Skipping load: isLoading=$_isLoading, hasMore=$_hasMore');
      return;
    }

    _setLoading(true);
    _error = null;

    try {
      print('Calling API service...');
      final result = await _destinationService.getDestinations(
        page: _currentPage,
        search: search,
        categoryId: categoryId,
        districtId: districtId,
        type: type,
        featured: featured,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      print('API result received: ${result.keys}');
      final newDestinations = result['destinations'] as List<Destination>;
      final pagination = result['pagination'] as Map<String, dynamic>;

      print('New destinations count: ${newDestinations.length}');

      if (refresh) {
        _destinations = newDestinations;
      } else {
        _destinations.addAll(newDestinations);
      }

      _currentPage = (pagination['current_page'] as int) + 1;
      _lastPage = pagination['last_page'] as int;
      _hasMore = _currentPage <= _lastPage;

      print('Updated state: destinations=${_destinations.length}, hasMore=$_hasMore');

    } catch (e) {
      print('Error in loadDestinations: $e');
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadFeaturedDestinations() async {
    try {
      _setLoading(true);
      final result = await _destinationService.getDestinations(
        featured: true,
        perPage: 5,
      );

      _featuredDestinations = result['destinations'] as List<Destination>;
      print('Loaded ${_featuredDestinations.length} featured destinations');

    } catch (e) {
      print('Error loading featured destinations: $e');
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<Destination?> getDestination(int id) async {
    try {
      print('DestinationProvider: Getting destination with ID: $id');
      final destination = await _destinationService.getDestination(id);
      print('DestinationProvider: Successfully got destination: ${destination.name}');
      return destination;
    } catch (e) {
      print('DestinationProvider: Error getting destination: $e');
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<List<Destination>> getNearbyDestinations(int id) async {
    try {
      print('DestinationProvider: Getting nearby destinations for ID: $id');
      final nearbyDestinations = await _destinationService.getNearbyDestinations(id);
      print('DestinationProvider: Successfully got ${nearbyDestinations.length} nearby destinations');
      return nearbyDestinations;
    } catch (e) {
      print('DestinationProvider: Error getting nearby destinations: $e');
      // Return empty list instead of throwing error
      return [];
    }
  }

  void _setLoading(bool loading) {
    print('Setting loading: $loading');
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearDestinations() {
    _destinations.clear();
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }

  // Method untuk mencari destinasi berdasarkan nama
  List<Destination> searchDestinations(String query) {
    if (query.isEmpty) return _destinations;
    
    return _destinations.where((destination) =>
      destination.name.toLowerCase().contains(query.toLowerCase()) ||
      (destination.location?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }

  // Method untuk filter destinasi berdasarkan kategori
  List<Destination> getDestinationsByCategory(int categoryId) {
    return _destinations.where((destination) =>
      destination.category?.id == categoryId
    ).toList();
  }
}
