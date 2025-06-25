// lib/screens/culinary_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/culinary_provider.dart';
import '../widgets/home/kuliner/culinary_card.dart';
import '../models/culinary.dart';

class CulinaryScreen extends StatefulWidget {
  const CulinaryScreen({Key? key}) : super(key: key);

  @override
  State<CulinaryScreen> createState() => _CulinaryScreenState();
}

class _CulinaryScreenState extends State<CulinaryScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  String _searchQuery = '';
  String? _selectedType;
  bool _showRecommendedOnly = false;
  bool _halalOnly = false;
  bool _vegetarianOnly = false;
  bool _deliveryOnly = false;
  String _sortBy = 'name';
  String _sortOrder = 'asc';
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCulinaries();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      final provider = Provider.of<CulinaryProvider>(context, listen: false);
      if (!provider.isLoading && provider.hasMore) {
        _loadMoreCulinaries();
      }
    }
  }

  void _loadCulinaries() {
    final provider = Provider.of<CulinaryProvider>(context, listen: false);
    provider.loadCulinaries(
      refresh: true,
      search: _searchQuery.isEmpty ? null : _searchQuery,
      type: _selectedType,
      isRecommended: _showRecommendedOnly ? true : null,
      halalCertified: _halalOnly ? true : null,
      hasVegetarian: _vegetarianOnly ? true : null,
      hasDelivery: _deliveryOnly ? true : null,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
    );
  }

  void _loadMoreCulinaries() {
    final provider = Provider.of<CulinaryProvider>(context, listen: false);
    provider.loadCulinaries(
      refresh: false,
      search: _searchQuery.isEmpty ? null : _searchQuery,
      type: _selectedType,
      isRecommended: _showRecommendedOnly ? true : null,
      halalCertified: _halalOnly ? true : null,
      hasVegetarian: _vegetarianOnly ? true : null,
      hasDelivery: _deliveryOnly ? true : null,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    
    Future.delayed(Duration(milliseconds: 500), () {
      if (_searchQuery == query) {
        _loadCulinaries();
      }
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isGridView ? 'Tampilan Grid Aktif' : 'Tampilan List Aktif',
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: RefreshIndicator(
        onRefresh: () async {
          _loadCulinaries();
        },
        color: Colors.orange,
        child: CustomScrollView(
          controller: _scrollController,
          physics: AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Custom App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.orange,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Kuliner Lokal',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.orange,
                        Colors.deepOrange,
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.filter_list, color: Colors.white),
                  onPressed: _showFilterBottomSheet,
                ),
                IconButton(
                  icon: Icon(
                    _isGridView ? Icons.view_list : Icons.view_module,
                    color: Colors.white,
                  ),
                  onPressed: _toggleViewMode,
                ),
              ],
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Cari kuliner...',
                    prefixIcon: Icon(Icons.search, color: Colors.orange),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),

            // Filter Chips
            SliverToBoxAdapter(
              child: Container(
                height: 50,
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip(
                      'Semua',
                      !_showRecommendedOnly && _selectedType == null,
                      () {
                        setState(() {
                          _showRecommendedOnly = false;
                          _selectedType = null;
                        });
                        _loadCulinaries();
                      },
                    ),
                    _buildFilterChip(
                      'Rekomendasi',
                      _showRecommendedOnly,
                      () {
                        setState(() {
                          _showRecommendedOnly = !_showRecommendedOnly;
                        });
                        _loadCulinaries();
                      },
                    ),
                    _buildFilterChip(
                      'Halal',
                      _halalOnly,
                      () {
                        setState(() {
                          _halalOnly = !_halalOnly;
                        });
                        _loadCulinaries();
                      },
                    ),
                    _buildFilterChip(
                      'Vegetarian',
                      _vegetarianOnly,
                      () {
                        setState(() {
                          _vegetarianOnly = !_vegetarianOnly;
                        });
                        _loadCulinaries();
                      },
                    ),
                    _buildFilterChip(
                      'Delivery',
                      _deliveryOnly,
                      () {
                        setState(() {
                          _deliveryOnly = !_deliveryOnly;
                        });
                        _loadCulinaries();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Culinaries Content
            Consumer<CulinaryProvider>(
              builder: (context, culinaryProvider, child) {
                return _buildCulinariesContent(culinaryProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: Colors.orange,
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected ? Colors.orange : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildCulinariesContent(CulinaryProvider provider) {
    // Loading state
    if (provider.culinaries.isEmpty && provider.isLoading) {
      return SliverToBoxAdapter(
        child: Container(
          height: 400,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.orange),
                ),
                SizedBox(height: 16),
                Text(
                  'Memuat kuliner...',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Error state
    if (provider.error != null && provider.culinaries.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          height: 300,
          margin: EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                SizedBox(height: 16),
                Text('Terjadi Kesalahan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(provider.error!, textAlign: TextAlign.center),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadCulinaries(refresh: true),
                  child: Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Empty state
    if (provider.culinaries.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.shade400),
                SizedBox(height: 16),
                Text('Belum ada kuliner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Coba refresh atau periksa koneksi internet'),
              ],
            ),
          ),
        ),
      );
    }

    // Content berdasarkan view mode
    if (_isGridView) {
      return _buildGridView(provider);
    } else {
      return _buildListView(provider);
    }
  }

  Widget _buildGridView(CulinaryProvider provider) {
    return SliverPadding(
      padding: EdgeInsets.all(20),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == provider.culinaries.length) {
              if (provider.hasMore && provider.isLoading) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.withOpacity(0.2)),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.orange),
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            }

            final culinary = provider.culinaries[index];
            return CulinaryCard(culinary: culinary);
          },
          childCount: provider.culinaries.length + 
              (provider.hasMore && provider.isLoading ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildListView(CulinaryProvider provider) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == provider.culinaries.length) {
              if (provider.hasMore && provider.isLoading) {
                return Container(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.orange),
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            }

            final culinary = provider.culinaries[index];
            return Container(
              margin: EdgeInsets.only(bottom: 16),
              child: _buildListItem(culinary),
            );
          },
          childCount: provider.culinaries.length + 
              (provider.hasMore && provider.isLoading ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildListItem(Culinary culinary) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/culinary-detail',
            arguments: culinary.id,
          );
        },
        child: Container(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              Hero(
                tag: 'culinary-${culinary.id}',
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: culinary.featuredImage != null && culinary.featuredImage!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: 'http://10.0.2.2:8000/storage/${culinary.featuredImage}',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.orange.shade200,
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(Colors.orange),
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.orange.shade200,
                              child: Icon(Icons.restaurant, color: Colors.orange.shade700),
                            ),
                          )
                        : Container(
                            color: Colors.orange.shade200,
                            child: Icon(Icons.restaurant, color: Colors.orange.shade700),
                          ),
                  ),
                ),
              ),
              
              SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            culinary.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (culinary.isRecommended)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.orange, Colors.deepOrange],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Rekomendasi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    SizedBox(height: 4),
                    
                    if (culinary.type != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          culinary.type!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    
                    SizedBox(height: 4),
                    
                    if (culinary.address != null)
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                          SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              culinary.address!,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    
                    SizedBox(height: 8),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            culinary.displayPrice,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber),
                            SizedBox(width: 2),
                            Text(
                              culinary.averageRating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              ' (${culinary.reviewsCount})',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBottomSheet() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter & Urutkan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                SizedBox(height: 20),
                
                Text(
                  'Urutkan berdasarkan:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildSortChip('Nama A-Z', 'name', 'asc'),
                    _buildSortChip('Nama Z-A', 'name', 'desc'),
                    _buildSortChip('Rating Tertinggi', 'rating', 'desc'),
                    _buildSortChip('Harga Terendah', 'price', 'asc'),
                    _buildSortChip('Terbaru', 'created_at', 'desc'),
                  ],
                ),
                
                SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _loadCulinaries();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Terapkan Filter',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String sortBy, String sortOrder) {
    bool isSelected = _sortBy == sortBy && _sortOrder == sortOrder;
    
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.orange,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _sortBy = sortBy;
          _sortOrder = sortOrder;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: Colors.orange,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? Colors.orange : Colors.grey.shade300,
      ),
    );
  }
}
