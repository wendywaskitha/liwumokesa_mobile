// lib/providers/culinary_provider.dart
import 'package:flutter/material.dart';
import '../models/culinary.dart';
import '../services/culinary_service.dart';

class CulinaryProvider with ChangeNotifier {
  final CulinaryService _culinaryService = CulinaryService();

  List<Culinary> _culinaries = [];
  List<Culinary> _recommendedCulinaries = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _hasMore = true;

  // Getters
  List<Culinary> get culinaries => _culinaries;
  List<Culinary> get recommendedCulinaries => _recommendedCulinaries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;

  Future<void> loadCulinaries({
    bool refresh = false,
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
    print('loadCulinaries called with refresh: $refresh');

    if (refresh) {
      _culinaries.clear();
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
      final result = await _culinaryService.getCulinaries(
        page: _currentPage,
        search: search,
        type: type,
        districtId: districtId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        hasVegetarian: hasVegetarian,
        halalCertified: halalCertified,
        hasDelivery: hasDelivery,
        isRecommended: isRecommended,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      print('API result received: ${result.keys}');
      final newCulinaries = result['culinaries'] as List<Culinary>;
      final pagination = result['pagination'] as Map<String, dynamic>;

      print('New culinaries count: ${newCulinaries.length}');

      if (refresh) {
        _culinaries = newCulinaries;
      } else {
        _culinaries.addAll(newCulinaries);
      }

      _currentPage = (pagination['current_page'] as int) + 1;
      _lastPage = pagination['last_page'] as int;
      _hasMore = _currentPage <= _lastPage;

      print('Updated state: culinaries=${_culinaries.length}, hasMore=$_hasMore');

    } catch (e) {
      print('Error in loadCulinaries: $e');
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadRecommendedCulinaries() async {
    try {
      _setLoading(true);
      final recommended = await _culinaryService.getRecommendedCulinaries(perPage: 5);
      _recommendedCulinaries = recommended;
      print('Loaded ${_recommendedCulinaries.length} recommended culinaries');
    } catch (e) {
      print('Error loading recommended culinaries: $e');
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<Culinary?> getCulinary(int id) async {
    try {
      print('CulinaryProvider: Getting culinary with ID: $id');
      final culinary = await _culinaryService.getCulinary(id);
      print('CulinaryProvider: Successfully got culinary: ${culinary.name}');
      return culinary;
    } catch (e) {
      print('CulinaryProvider: Error getting culinary: $e');
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<List<Culinary>> getNearbyCulinaries(int id) async {
    try {
      print('CulinaryProvider: Getting nearby culinaries for ID: $id');
      final nearbyCulinaries = await _culinaryService.getNearbyCulinaries(id);
      print('CulinaryProvider: Successfully got ${nearbyCulinaries.length} nearby culinaries');
      return nearbyCulinaries;
    } catch (e) {
      print('CulinaryProvider: Error getting nearby culinaries: $e');
      return [];
    }
  }

  Future<List<String>> getCulinaryTypes() async {
    try {
      return await _culinaryService.getCulinaryTypes();
    } catch (e) {
      print('Error getting culinary types: $e');
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

  void clearCulinaries() {
    _culinaries.clear();
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }

  List<Culinary> searchCulinaries(String query) {
    if (query.isEmpty) return _culinaries;
    
    return _culinaries.where((culinary) =>
      culinary.name.toLowerCase().contains(query.toLowerCase()) ||
      (culinary.type?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
      (culinary.address?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }

  List<Culinary> getCulinaryByType(String type) {
    return _culinaries.where((culinary) =>
      culinary.type?.toLowerCase() == type.toLowerCase()
    ).toList();
  }
}
