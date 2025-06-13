// lib/providers/creative_economy_provider.dart (update existing)
import 'package:flutter/foundation.dart';
import '../models/creative_economy.dart';
import '../services/creative_economy_service.dart';

class CreativeEconomyProvider with ChangeNotifier {
  final CreativeEconomyService _service = CreativeEconomyService();
  
  List<CreativeEconomy> _creativeEconomies = [];
  List<CreativeEconomy> _featuredCreativeEconomies = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreData = true;
  Map<String, dynamic>? _paginationData;

  // Getters
  List<CreativeEconomy> get creativeEconomies => _creativeEconomies;
  List<CreativeEconomy> get featuredCreativeEconomies => _featuredCreativeEconomies;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMoreData => _hasMoreData;
  Map<String, dynamic>? get paginationData => _paginationData;
  
  // Stats untuk home screen
  int get totalCreativeEconomies => _paginationData?['total'] ?? _creativeEconomies.length;
  int get verifiedCount => _creativeEconomies.where((ce) => ce.isVerified).length;
  int get workshopCount => _creativeEconomies.where((ce) => ce.hasWorkshop).length;

  // Load initial data
  Future<void> loadCreativeEconomies({
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
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _creativeEconomies.clear();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getCreativeEconomies(
        page: _currentPage,
        search: search,
        categoryId: categoryId,
        districtId: districtId,
        isFeatured: isFeatured,
        hasWorkshop: hasWorkshop,
        hasDirectSelling: hasDirectSelling,
        isVerified: isVerified,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      final newCreativeEconomies = response['creative_economies'] as List<CreativeEconomy>;
      _paginationData = response['pagination'] as Map<String, dynamic>;

      if (refresh) {
        _creativeEconomies = newCreativeEconomies;
      } else {
        _creativeEconomies.addAll(newCreativeEconomies);
      }

      _hasMoreData = _currentPage < (_paginationData?['last_page'] ?? 1);
      _currentPage++;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading creative economies: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more data for pagination
  Future<void> loadMoreCreativeEconomies({
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
    if (_isLoadingMore || !_hasMoreData) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final response = await _service.getCreativeEconomies(
        page: _currentPage,
        search: search,
        categoryId: categoryId,
        districtId: districtId,
        isFeatured: isFeatured,
        hasWorkshop: hasWorkshop,
        hasDirectSelling: hasDirectSelling,
        isVerified: isVerified,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      final newCreativeEconomies = response['creative_economies'] as List<CreativeEconomy>;
      _paginationData = response['pagination'] as Map<String, dynamic>;

      _creativeEconomies.addAll(newCreativeEconomies);
      _hasMoreData = _currentPage < (_paginationData?['last_page'] ?? 1);
      _currentPage++;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading more creative economies: $_error');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Load featured creative economies
  Future<void> loadFeaturedCreativeEconomies() async {
    try {
      _featuredCreativeEconomies = await _service.getFeaturedCreativeEconomies(limit: 5);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading featured creative economies: $e');
    }
  }

  // Search creative economies
  Future<void> searchCreativeEconomies({
    required String query,
    double? latitude,
    double? longitude,
    double? radius,
    bool refresh = true,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _creativeEconomies.clear();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.searchCreativeEconomies(
        query: query,
        page: _currentPage,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );

      final newCreativeEconomies = response['creative_economies'] as List<CreativeEconomy>;
      _paginationData = response['pagination'] as Map<String, dynamic>;

      if (refresh) {
        _creativeEconomies = newCreativeEconomies;
      } else {
        _creativeEconomies.addAll(newCreativeEconomies);
      }

      _hasMoreData = _currentPage < (_paginationData?['last_page'] ?? 1);
      _currentPage++;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error searching creative economies: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get single creative economy
  Future<CreativeEconomy?> getCreativeEconomy(int id) async {
    try {
      return await _service.getCreativeEconomy(id);
    } catch (e) {
      debugPrint('Error getting creative economy: $e');
      return null;
    }
  }

  // Clear data
  void clearData() {
    _creativeEconomies.clear();
    _featuredCreativeEconomies.clear();
    _currentPage = 1;
    _hasMoreData = true;
    _error = null;
    _paginationData = null;
    notifyListeners();
  }
}
