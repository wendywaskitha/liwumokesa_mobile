// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import '../providers/auth_provider.dart';
import '../providers/culinary_provider.dart';
import '../providers/destination_provider.dart';
import '../providers/creative_economy_provider.dart';
import '../providers/accommodation_provider.dart';
import '../widgets/home/destinasi/destination_card.dart';
import '../models/destination.dart';
import '../widgets/home/search_section.dart';
import '../widgets/home/quick_actions.dart';
import '../widgets/home/featured_section.dart';
import '../widgets/home/trending_section.dart';
import '../widgets/home/stats_cards.dart';
import '../widgets/home/error_section.dart';
import '../widgets/home/ekonomi-kreatif/creative_economy_section.dart';
import '../widgets/home/akomodasi/accommodation_section.dart';
import '../widgets/home/kuliner/culinary_section.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  // State untuk view mode dan filter
  bool _isGridView = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );

    _loadInitialData();
    _scrollController.addListener(_onScroll);
    _animationController!.forward();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DestinationProvider>(context, listen: false)
          .loadDestinations(refresh: true);
      Provider.of<CulinaryProvider>(context, listen: false)
          .loadRecommendedCulinaries();
      Provider.of<CreativeEconomyProvider>(context, listen: false)
          .loadFeaturedCreativeEconomies();
      Provider.of<AccommodationProvider>(context, listen: false)
          .loadAccommodations(refresh: true, perPage: 5);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      Provider.of<DestinationProvider>(context, listen: false)
          .loadDestinations();
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      await Future.wait([
        Provider.of<DestinationProvider>(context, listen: false)
            .loadDestinations(refresh: true),
        Provider.of<CulinaryProvider>(context, listen: false)
            .loadRecommendedCulinaries(),
        Provider.of<CreativeEconomyProvider>(context, listen: false)
            .loadFeaturedCreativeEconomies(),
        Provider.of<AccommodationProvider>(context, listen: false)
            .loadAccommodations(refresh: true, perPage: 5),
      ]);
    } catch (e) {
      print('Error refreshing data: $e');
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: Consumer5<AuthProvider, DestinationProvider, CulinaryProvider,
          CreativeEconomyProvider, AccommodationProvider>(
        builder: (context, authProvider, destinationProvider, culinaryProvider,
            creativeEconomyProvider, accommodationProvider, child) {
          if (_fadeAnimation == null) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
              ),
            );
          }

          return FadeTransition(
            opacity: _fadeAnimation!,
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: Color(0xFF667EEA),
              backgroundColor: Colors.white,
              child: CustomScrollView(
                controller: _scrollController,
                physics: AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  _buildCompactSliverAppBar(authProvider),
                  SliverToBoxAdapter(
                    child: SearchSection(
                      controller: _searchController,
                      onSearch: _performSearch,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: StatsCards(destinationProvider: destinationProvider),
                  ),
                  SliverToBoxAdapter(child: QuickActions()),
                  SliverToBoxAdapter(
                    child: FeaturedSection(
                        destinationProvider: destinationProvider),
                  ),
                  SliverToBoxAdapter(
                    child: CulinarySection(),
                  ),
                  SliverToBoxAdapter(
                    child: CreativeEconomySection(),
                  ),
                  SliverToBoxAdapter(
                    child: AccommodationSection(),
                  ),
                  SliverToBoxAdapter(
                    child: TrendingSection(
                        destinationProvider: destinationProvider),
                  ),
                  SliverToBoxAdapter(child: _buildModernDestinationsHeader()),
                  if (destinationProvider.error != null)
                    SliverToBoxAdapter(
                      child: ErrorSection(
                          destinationProvider: destinationProvider),
                    ),
                  _buildDestinationsContent(destinationProvider),
                  SliverToBoxAdapter(child: SizedBox(height: 120)), // Extra space for bottom nav
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Update SliverAppBar untuk lebih compact karena ada bottom navigation
  Widget _buildCompactSliverAppBar(AuthProvider authProvider) {
    return SliverAppBar(
      expandedHeight: 120, // Kurangi dari 140 ke 120
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false, // Hilangkan back button
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF667EEA), Color(0xFF764BA2), Color(0xFF6B73FF)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 22, // Kurangi dari 25 ke 22
                          backgroundColor: Colors.white,
                          child: Text(
                            authProvider.user?.name
                                    ?.substring(0, 1)
                                    .toUpperCase() ??
                                'W',
                            style: TextStyle(
                              color: Color(0xFF667EEA),
                              fontWeight: FontWeight.bold,
                              fontSize: 16, // Kurangi dari 18 ke 16
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selamat datang! 👋',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12, // Kurangi dari 14 ke 12
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              authProvider.user?.name ?? 'Wisatawan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18, // Kurangi dari 22 ke 18
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          onPressed: () => _showNotificationSheet(context),
                          icon: Stack(
                            children: [
                              Icon(Icons.notifications_outlined, 
                                   color: Colors.white, size: 22),
                              // Notification badge
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 12,
                                    minHeight: 12,
                                  ),
                                  child: Text(
                                    '3',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernDestinationsHeader() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Semua Destinasi 🗺️',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Jelajahi semua pilihan destinasi',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  _showFilterBottomSheet();
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.tune,
                    color: Color(0xFF667EEA),
                    size: 20,
                  ),
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  _toggleViewMode();
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isGridView ? Icons.view_list : Icons.view_module,
                    color: Color(0xFF667EEA),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationsContent(DestinationProvider provider) {
    if (provider.destinations.isEmpty && provider.isLoading) {
      return SliverToBoxAdapter(
        child: Container(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFF667EEA)),
                ),
                SizedBox(height: 16),
                Text(
                  'Memuat destinasi...',
                  style: TextStyle(
                    color: Color(0xFF667EEA),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (provider.error != null && provider.destinations.isEmpty) {
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
                Text('Terjadi Kesalahan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(provider.error!, textAlign: TextAlign.center),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadDestinations(refresh: true),
                  child: Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (provider.destinations.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.explore_off, size: 64, color: Colors.grey.shade400),
                SizedBox(height: 16),
                Text('Belum ada destinasi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Coba refresh atau periksa koneksi internet'),
              ],
            ),
          ),
        ),
      );
    }

    if (_isGridView) {
      return _buildGridView(provider);
    } else {
      return _buildListView(provider);
    }
  }

  Widget _buildGridView(DestinationProvider provider) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == provider.destinations.length) {
              if (provider.hasMore && provider.isLoading) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFF667EEA).withOpacity(0.2)),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFF667EEA)),
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            }

            final destination = provider.destinations[index];
            return DestinationCard(
              destination: destination,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/destination-detail',
                  arguments: destination.id,
                );
              },
            );
          },
          childCount: provider.destinations.length +
              (provider.hasMore && provider.isLoading ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildListView(DestinationProvider provider) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == provider.destinations.length) {
              if (provider.hasMore && provider.isLoading) {
                return Container(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFF667EEA)),
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            }

            final destination = provider.destinations[index];
            return Container(
              margin: EdgeInsets.only(bottom: 16),
              child: _buildListItem(destination),
            );
          },
          childCount: provider.destinations.length +
              (provider.hasMore && provider.isLoading ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildListItem(Destination destination) {
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
            '/destination-detail',
            arguments: destination.id,
          );
        },
        child: Container(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Hero(
                tag: 'destination-${destination.id}',
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: destination.featuredImage != null &&
                            destination.featuredImage!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl:
                                'http://10.0.2.2:8000/storage/${destination.featuredImage}',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade300,
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Color(0xFF667EEA)),
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade300,
                              child: Icon(Icons.image,
                                  color: Colors.grey.shade500),
                            ),
                          )
                        : Container(
                            color: Colors.grey.shade300,
                            child: Icon(Icons.landscape,
                                color: Colors.grey.shade500),
                          ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            destination.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (destination.isFeatured)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.orange, Colors.deepOrange],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Featured',
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
                    if (destination.location != null)
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 14, color: Colors.grey.shade600),
                          SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              destination.location!,
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
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: destination.entranceFee == null ||
                                    destination.entranceFee == 0
                                ? Colors.green.shade100
                                : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            destination.entranceFee == null ||
                                    destination.entranceFee == 0
                                ? 'GRATIS'
                                : 'Rp ${destination.entranceFee!.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: destination.entranceFee == null ||
                                      destination.entranceFee == 0
                                  ? Colors.green.shade700
                                  : Colors.blue.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (destination.category != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(0xFF667EEA).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              destination.category!.name,
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF667EEA),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                    'Filter Destinasi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Kategori:',
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
                      _buildFilterChip('Semua', true, () {}),
                      _buildFilterChip('Wisata Alam', false, () {}),
                      _buildFilterChip('Wisata Budaya', false, () {}),
                      _buildFilterChip('Wisata Kuliner', false, () {}),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Harga:',
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
                      _buildFilterChip('Gratis', false, () {}),
                      _buildFilterChip('< Rp 50K', false, () {}),
                      _buildFilterChip('Rp 50K - 100K', false, () {}),
                      _buildFilterChip('> Rp 100K', false, () {}),
                    ],
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Filter diterapkan!'),
                            backgroundColor: Color(0xFF667EEA),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF667EEA),
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
      ),
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
        backgroundColor: Color(0xFF667EEA),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Color(0xFF667EEA),
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.white,
      selectedColor: Color(0xFF667EEA),
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? Color(0xFF667EEA) : Colors.grey.shade300,
      ),
    );
  }

  void _performSearch(String query) {
    Provider.of<DestinationProvider>(context, listen: false)
        .loadDestinations(refresh: true, search: query);
  }

  void _showNotificationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.notifications, color: Color(0xFF667EEA)),
                SizedBox(width: 12),
                Text(
                  'Notifikasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildNotificationItem(
              'Destinasi Baru',
              'Pantai Napabale telah ditambahkan!',
              '2 jam lalu',
              Icons.explore,
              Color(0xFF667EEA),
            ),
            _buildNotificationItem(
              'Promo Kuliner',
              'Diskon 20% di Warung Seafood Pak Mahmud',
              '1 hari lalu',
              Icons.restaurant,
              Colors.orange,
            ),
            _buildNotificationItem(
              'Update Aplikasi',
              'Versi terbaru tersedia di Play Store',
              '3 hari lalu',
              Icons.system_update,
              Colors.green,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String subtitle, String time, 
                                IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _animationController?.dispose();
    super.dispose();
  }
}
