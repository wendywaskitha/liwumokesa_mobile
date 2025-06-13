// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/auth_provider.dart';
import '../providers/destination_provider.dart';
import '../providers/creative_economy_provider.dart';
import '../providers/accommodation_provider.dart';
import '../widgets/destination_card.dart';
import '../models/destination.dart';
import '../widgets/home/search_section.dart';
import '../widgets/home/quick_actions.dart';
import '../widgets/home/featured_section.dart';
import '../widgets/home/trending_section.dart';
import '../widgets/home/destinations_list.dart';
import '../widgets/home/stats_cards.dart';
import '../widgets/home/error_section.dart';
import '../widgets/home/ekonomi-kreatif/creative_economy_section.dart';
import '../widgets/home/akomodasi/accommodation_section.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

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
      Provider.of<CreativeEconomyProvider>(context, listen: false)
          .loadFeaturedCreativeEconomies();
      Provider.of<AccommodationProvider>(context, listen: false) // Add this
          .loadAccommodations(refresh: true, perPage: 5);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      Provider.of<DestinationProvider>(context, listen: false)
          .loadDestinations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: Consumer4<AuthProvider, DestinationProvider,
          CreativeEconomyProvider, AccommodationProvider>(
        builder: (context, authProvider, destinationProvider,
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
            child: CustomScrollView(
              controller: _scrollController,
              physics: BouncingScrollPhysics(),
              slivers: [
                _buildModernSliverAppBar(authProvider),
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
                  child:
                      FeaturedSection(destinationProvider: destinationProvider),
                ),
                SliverToBoxAdapter(
                  child: CreativeEconomySection(),
                ),
                SliverToBoxAdapter(
                  child: AccommodationSection(),
                ),
                SliverToBoxAdapter(
                  child:
                      TrendingSection(destinationProvider: destinationProvider),
                ),
                SliverToBoxAdapter(child: _buildModernDestinationsHeader()),
                if (destinationProvider.error != null)
                  SliverToBoxAdapter(
                    child:
                        ErrorSection(destinationProvider: destinationProvider),
                  ),
                DestinationsList(destinationProvider: destinationProvider),
                SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildModernSliverAppBar(AuthProvider authProvider) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
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
              padding: EdgeInsets.all(20),
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
                          radius: 25,
                          backgroundColor: Colors.white,
                          child: Text(
                            authProvider.user?.name
                                    ?.substring(0, 1)
                                    .toUpperCase() ??
                                'W',
                            style: TextStyle(
                              color: Color(0xFF667EEA),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selamat datang kembali! 👋',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              authProvider.user?.name ?? 'Wisatawan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () => _showModernProfileMenu(context),
                          icon: Icon(Icons.menu, color: Colors.white, size: 24),
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
          Column(
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
              Text(
                'Jelajahi semua pilihan destinasi',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
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
                child: Icon(Icons.tune, color: Color(0xFF667EEA), size: 20),
              ),
              SizedBox(width: 8),
              Container(
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
                child:
                    Icon(Icons.view_module, color: Color(0xFF667EEA), size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient:
            LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _performSearch(String query) {
    Provider.of<DestinationProvider>(context, listen: false)
        .loadDestinations(refresh: true, search: query);
  }

  void _showModernProfileMenu(BuildContext context) {
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
            _buildProfileMenuItem(Icons.person, 'Profile', () {
              Navigator.pop(modalContext);
            }),
            _buildProfileMenuItem(Icons.settings, 'Pengaturan', () {
              Navigator.pop(modalContext);
            }),
            _buildProfileMenuItem(Icons.help, 'Bantuan', () {
              Navigator.pop(modalContext);
            }),
            _buildProfileMenuItem(Icons.info, 'Tentang Aplikasi', () {
              Navigator.pop(modalContext);
            }),
            Divider(height: 30),
            _buildProfileMenuItem(
              Icons.logout,
              'Logout',
              () {
                Navigator.pop(modalContext); // Tutup modal dengan context modal
                _showLogoutConfirmation(
                    context); // Gunakan context asli untuk dialog
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem(IconData icon, String title, VoidCallback onTap,
      {bool isDestructive = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? Color(0xFFF56565).withOpacity(0.1)
                : Color(0xFF667EEA).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Color(0xFFF56565) : Color(0xFF667EEA),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Color(0xFFF56565) : Color(0xFF2D3748),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Update method _handleLogout
  Future<void> _handleLogout(BuildContext context) async {
    // PENTING: Simpan reference provider SEBELUM operasi async
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // Lakukan logout tanpa menggunakan context lagi
      final success = await authProvider.logout();

      // Cek apakah widget masih mounted sebelum navigasi
      if (mounted) {
        if (success) {
          // Navigate ke login screen
          navigator.pushNamedAndRemoveUntil(
            '/login',
            (Route<dynamic> route) => false,
          );

          // Tampilkan snackbar sukses
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Logout berhasil'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // Jika gagal, tetap paksa logout
          authProvider.forceLogout();
          navigator.pushNamedAndRemoveUntil(
            '/login',
            (Route<dynamic> route) => false,
          );
        }
      }
    } catch (e) {
      print('Logout error: $e');

      // Cek apakah widget masih mounted
      if (mounted) {
        // Force logout jika ada error
        authProvider.forceLogout();

        navigator.pushNamedAndRemoveUntil(
          '/login',
          (Route<dynamic> route) => false,
        );

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Logout berhasil'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

// Update profile menu untuk menghindari masalah context

// Tambahkan konfirmasi logout yang aman
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Konfirmasi Logout'),
          content: Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Tutup dialog
                _handleLogout(context); // Gunakan context asli untuk logout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF56565),
              ),
              child: Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
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
