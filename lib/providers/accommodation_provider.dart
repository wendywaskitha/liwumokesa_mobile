// lib/providers/accommodation_provider.dart
import 'package:flutter/foundation.dart';
import '../models/accommodation.dart';
import '../services/accommodation_service.dart';

class AccommodationProvider with ChangeNotifier {
  final AccommodationService _service = AccommodationService();
  
  List<Accommodation> _accommodations = [];
  List<String> _accommodationTypes = [];
  List<String> _popularFacilities = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreData = true;
  Map<String, dynamic>? _paginationData;

  // Getters
  List<Accommodation> get accommodations => _accommodations;
  List<String> get accommodationTypes => _accommodationTypes;
  List<String> get popularFacilities => _popularFacilities;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMoreData => _hasMoreData;
  Map<String, dynamic>? get paginationData => _paginationData;
  
  // Stats untuk home screen
  int get totalAccommodations => _paginationData?['total'] ?? _accommodations.length;
  int get hotelCount => _accommodations.where((acc) => acc.type.toLowerCase() == 'hotel').length;
  int get resortCount => _accommodations.where((acc) => acc.type.toLowerCase() == 'resort').length;
  int get homestayCount => _accommodations.where((acc) => acc.type.toLowerCase() == 'homestay').length;

  // Load initial data
  Future<void> loadAccommodations({
    String? search,
    String? type,
    int? districtId,
    double? minPrice,
    double? maxPrice,
    List<String>? facilities,
    String sortBy = 'name',
    String sortOrder = 'asc',
    bool refresh = false,
    int perPage = 10,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _accommodations.clear();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getAccommodations(
        page: _currentPage,
        perPage: perPage,
        search: search,
        type: type,
        districtId: districtId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        facilities: facilities,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      final newAccommodations = response['accommodations'] as List<Accommodation>;
      _paginationData = response['pagination'] as Map<String, dynamic>;

      if (refresh) {
        _accommodations = newAccommodations;
      } else {
        _accommodations.addAll(newAccommodations);
      }

      _hasMoreData = _currentPage < (_paginationData?['last_page'] ?? 1);
      _currentPage++;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading accommodations: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more data for pagination
  Future<void> loadMoreAccommodations({
    String? search,
    String? type,
    int? districtId,
    double? minPrice,
    double? maxPrice,
    List<String>? facilities,
    String sortBy = 'name',
    String sortOrder = 'asc',
    int perPage = 10,
  }) async {
    if (_isLoadingMore || !_hasMoreData) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final response = await _service.getAccommodations(
        page: _currentPage,
        perPage: perPage,
        search: search,
        type: type,
        districtId: districtId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        facilities: facilities,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      final newAccommodations = response['accommodations'] as List<Accommodation>;
      _paginationData = response['pagination'] as Map<String, dynamic>;

      _accommodations.addAll(newAccommodations);
      _hasMoreData = _currentPage < (_paginationData?['last_page'] ?? 1);
      _currentPage++;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading more accommodations: $_error');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Search accommodations
  Future<void> searchAccommodations({
    required String query,
    String? type,
    int? districtId,
    double? minPrice,
    double? maxPrice,
    List<String>? facilities,
    double? latitude,
    double? longitude,
    double? radius,
    bool refresh = true,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _accommodations.clear();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.searchAccommodations(
        query: query,
        page: _currentPage,
        type: type,
        districtId: districtId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        facilities: facilities,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );

      final newAccommodations = response['accommodations'] as List<Accommodation>;
      _paginationData = response['pagination'] as Map<String, dynamic>;

      if (refresh) {
        _accommodations = newAccommodations;
      } else {
        _accommodations.addAll(newAccommodations);
      }

      _hasMoreData = _currentPage < (_paginationData?['last_page'] ?? 1);
      _currentPage++;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error searching accommodations: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load accommodation types
  Future<void> loadAccommodationTypes() async {
    try {
      _accommodationTypes = await _service.getAccommodationTypes();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading accommodation types: $e');
    }
  }

  // Load popular facilities
  Future<void> loadPopularFacilities() async {
    try {
      _popularFacilities = await _service.getPopularFacilities();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading popular facilities: $e');
    }
  }

  // Get single accommodation
  Future<Accommodation?> getAccommodation(int id) async {
    try {
      return await _service.getAccommodation(id);
    } catch (e) {
      debugPrint('Error getting accommodation: $e');
      return null;
    }
  }

  // Get accommodations by type
  Future<void> loadAccommodationsByType(String type, {bool refresh = true}) async {
    await loadAccommodations(type: type, refresh: refresh);
  }

  // Get accommodations by district
  Future<void> loadAccommodationsByDistrict(int districtId, {bool refresh = true}) async {
    await loadAccommodations(districtId: districtId, refresh: refresh);
  }

  // Get nearby accommodations
  Future<List<Accommodation>> getNearbyAccommodations({
    required double latitude,
    required double longitude,
    double radius = 5,
  }) async {
    try {
      return await _service.getNearbyAccommodations(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
    } catch (e) {
      debugPrint('Error getting nearby accommodations: $e');
      return [];
    }
  }

  // Filter accommodations by price range
  List<Accommodation> getAccommodationsByPriceRange(double minPrice, double maxPrice) {
    return _accommodations.where((accommodation) {
      if (accommodation.priceRangeStart == null || accommodation.priceRangeEnd == null) {
        return false;
      }
      return accommodation.priceRangeStart! >= minPrice && 
             accommodation.priceRangeEnd! <= maxPrice;
    }).toList();
  }

  // Filter accommodations by facilities
  List<Accommodation> getAccommodationsByFacilities(List<String> requiredFacilities) {
    return _accommodations.where((accommodation) {
      if (accommodation.facilities == null || accommodation.facilities!.isEmpty) {
        return false;
      }
      return requiredFacilities.every((facility) => 
          accommodation.facilities!.contains(facility));
    }).toList();
  }

  // Get accommodations with high rating
  List<Accommodation> getHighRatedAccommodations({double minRating = 4.0}) {
    return _accommodations.where((accommodation) => 
        accommodation.averageRating >= minRating).toList();
  }

  // Clear data
  void clearData() {
    _accommodations.clear();
    _accommodationTypes.clear();
    _popularFacilities.clear();
    _currentPage = 1;
    _hasMoreData = true;
    _error = null;
    _paginationData = null;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadAccommodations(refresh: true),
      loadAccommodationTypes(),
      loadPopularFacilities(),
    ]);
  }
}
