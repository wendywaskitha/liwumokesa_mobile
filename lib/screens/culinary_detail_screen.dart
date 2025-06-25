// lib/screens/culinary_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/culinary.dart';
import '../providers/culinary_provider.dart';

class CulinaryDetailScreen extends StatefulWidget {
  final int culinaryId;

  const CulinaryDetailScreen({
    Key? key,
    required this.culinaryId,
  }) : super(key: key);

  @override
  State<CulinaryDetailScreen> createState() => _CulinaryDetailScreenState();
}

class _CulinaryDetailScreenState extends State<CulinaryDetailScreen> {
  Culinary? culinary;
  List<Culinary> nearbyCulinaries = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadCulinaryDetail();
  }

  Future<void> _loadCulinaryDetail() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final provider = Provider.of<CulinaryProvider>(context, listen: false);

      print('Loading culinary detail for ID: ${widget.culinaryId}');
      final cul = await provider.getCulinary(widget.culinaryId);

      if (cul != null) {
        culinary = cul;
        print('Successfully loaded culinary: ${cul.name}');

        // Load nearby culinaries
        try {
          print('Loading nearby culinaries...');
          final nearby = await provider.getNearbyCulinaries(widget.culinaryId);
          nearbyCulinaries = nearby;
          print(
              'Successfully loaded ${nearbyCulinaries.length} nearby culinaries');
        } catch (nearbyError) {
          print('Error loading nearby culinaries: $nearbyError');
          nearbyCulinaries = [];
        }
      } else {
        error = 'Kuliner tidak ditemukan';
      }
    } catch (e) {
      print('Error in _loadCulinaryDetail: $e');
      error = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.orange),
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Memuat detail kuliner...',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(
          child: Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(24),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade400,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Terjadi Kesalahan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadCulinaryDetail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Coba Lagi',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (culinary == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Kuliner Tidak Ditemukan'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(
          child: Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(24),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 16),
                Text(
                  'Kuliner Tidak Ditemukan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Kuliner yang Anda cari tidak tersedia',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header dengan gambar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'culinary-${culinary!.id}',
                child: _buildHeaderImage(),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.favorite_border),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Fitur wishlist akan segera hadir!'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCulinaryInfo(),
                  _buildDescription(),
                  _buildFeaturedMenu(),
                  _buildFeatures(),
                  _buildContactInfo(),
                  _buildGallery(),
                  _buildReviews(),
                  _buildNearbyCulinaries(),
                  SizedBox(height: 100), // Space for floating button
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (culinary!.phoneNumber != null)
            FloatingActionButton(
              heroTag: "call",
              onPressed: () => _makePhoneCall(culinary!.phoneNumber!),
              backgroundColor: Colors.green,
              child: Icon(Icons.phone, color: Colors.white),
            ),
          SizedBox(width: 16),
          FloatingActionButton.extended(
            heroTag: "navigate",
            onPressed: () => _openMaps(),
            backgroundColor: Colors.orange,
            icon: Icon(Icons.directions, color: Colors.white),
            label: Text(
              'Navigasi',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage() {
    if (culinary!.featuredImage != null &&
        culinary!.featuredImage!.isNotEmpty) {
      String imageUrl =
          'http://10.0.2.2:8000/storage/${culinary!.featuredImage}';

      print('Loading culinary image: $imageUrl'); // Debug log

      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade200, Colors.orange.shade300],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.orange),
                ),
                SizedBox(height: 8),
                Text(
                  'Memuat gambar...',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          print('Error loading culinary image: $url - $error');
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade300, Colors.orange.shade400],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant, size: 64, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Gambar tidak tersedia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Koneksi terputus',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        // Tambahkan timeout dan retry logic
        httpHeaders: {
          'Connection': 'keep-alive',
          'Cache-Control': 'no-cache',
        },
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade300, Colors.orange.shade400],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant, size: 64, color: Colors.white),
              SizedBox(height: 8),
              Text(
                'No Image Available',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildCulinaryInfo() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  culinary!.name,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
              if (culinary!.isRecommended)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange, Colors.deepOrange],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Rekomendasi',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8),
          if (culinary!.type != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                culinary!.type!,
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          SizedBox(height: 16),
          if (culinary!.address != null)
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey.shade600, size: 20),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    culinary!.address!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  culinary!.displayPrice,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),

              Spacer(),

              // Rating
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  SizedBox(width: 4),
                  Text(
                    culinary!.averageRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' (${culinary!.reviewsCount} ulasan)',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (culinary!.openingHours != null) ...[
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey.shade600, size: 20),
                SizedBox(width: 8),
                Text(
                  'Jam Buka: ${culinary!.openingHours}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDescription() {
    if (culinary!.description == null || culinary!.description!.isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deskripsi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 12),
          Text(
            culinary!.description!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFeaturedMenu() {
    // Perbaikan: Tambahkan null check dan type validation
    if (culinary!.featuredMenu == null || culinary!.featuredMenu!.isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Menu Unggulan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 12),
          // Perbaikan: Handle type casting dengan safe approach
          ...culinary!.featuredMenu!
              .map((menuItem) {
                // Safe casting dengan validation
                Map<String, dynamic> menu;

                if (menuItem is Map<String, dynamic>) {
                  menu = menuItem;
                } else if (menuItem is String) {
                  // Jika menuItem adalah String, coba parse sebagai JSON
                  try {
                    menu = {'name': menuItem, 'price': null};
                  } catch (e) {
                    print('Error parsing menu item: $e');
                    return SizedBox.shrink();
                  }
                } else {
                  print('Unknown menu item type: ${menuItem.runtimeType}');
                  return SizedBox.shrink();
                }

                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.restaurant_menu,
                          color: Colors.orange.shade700),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              menu['name']?.toString() ?? 'Menu',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            if (menu['price'] != null)
                              Text(
                                'Rp ${_formatMenuPrice(menu['price'])}',
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            if (menu['description'] != null)
                              Text(
                                menu['description'].toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              })
              .where((widget) => widget is! SizedBox)
              .toList(), // Filter out empty widgets
          SizedBox(height: 24),
        ],
      ),
    );
  }

// Tambahkan helper method untuk format harga menu
  String _formatMenuPrice(dynamic price) {
    if (price == null) return '0';

    try {
      double priceDouble =
          price is String ? double.parse(price) : price.toDouble();
      if (priceDouble >= 1000000) {
        return '${(priceDouble / 1000000).toStringAsFixed(1)}jt';
      } else if (priceDouble >= 1000) {
        return '${(priceDouble / 1000).toStringAsFixed(0)}rb';
      }
      return priceDouble.toStringAsFixed(0);
    } catch (e) {
      print('Error formatting menu price: $e');
      return price.toString();
    }
  }

  Widget _buildFeatures() {
    List<Widget> features = [];

    if (culinary!.halalCertified) {
      features.add(
          _buildFeatureItem(Icons.verified, 'Halal Certified', Colors.green));
    }

    if (culinary!.hasVegetarianOption) {
      features.add(
          _buildFeatureItem(Icons.eco, 'Vegetarian Options', Colors.green));
    }

    if (culinary!.hasDelivery) {
      features.add(_buildFeatureItem(
          Icons.delivery_dining, 'Delivery Available', Colors.blue));
    }

    if (features.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fitur & Layanan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: features,
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kontak',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 12),
          if (culinary!.contactPerson != null)
            _buildContactItem(
                Icons.person, 'Kontak Person', culinary!.contactPerson!),
          if (culinary!.phoneNumber != null)
            _buildContactItem(Icons.phone, 'Telepon', culinary!.phoneNumber!,
                onTap: () => _makePhoneCall(culinary!.phoneNumber!)),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value,
      {VoidCallback? onTap}) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: Colors.orange, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color:
                            onTap != null ? Colors.orange : Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGallery() {
    if (culinary!.galleries == null || culinary!.galleries!.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Galeri Foto',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 24),
            itemCount: culinary!.galleries!.length,
            itemBuilder: (context, index) {
              final gallery = culinary!.galleries![index];

              // Safe access to gallery data
              String? imagePath;
              if (gallery is Map<String, dynamic>) {
                imagePath = gallery['image_path'] as String?;
              }

              if (imagePath == null || imagePath.isEmpty) {
                return Container(
                  width: 120,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.image, color: Colors.grey.shade500),
                );
              }

              return Container(
                width: 120,
                margin: EdgeInsets.only(right: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: 'http://10.0.2.2:8000/storage/$imagePath',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade300,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.orange),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade300,
                      child: Icon(Icons.image_not_supported,
                          color: Colors.grey.shade500),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildReviews() {
    if (culinary!.reviews == null || culinary!.reviews!.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Ulasan Terbaru',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
        ),
        SizedBox(height: 12),
        ...culinary!.reviews!
            .take(3)
            .map((reviewData) {
              // Safe casting untuk review data
              Map<String, dynamic> review;

              if (reviewData is Map<String, dynamic>) {
                review = reviewData;
              } else {
                print('Invalid review data type: ${reviewData.runtimeType}');
                return SizedBox.shrink();
              }

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.orange,
                          child: Text(
                            (review['user_name']?.toString() ?? 'U')
                                .substring(0, 1)
                                .toUpperCase(),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review['user_name']?.toString() ?? 'Anonymous',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: List.generate(5, (index) {
                                  int rating = review['rating'] is int
                                      ? review['rating']
                                      : int.tryParse(
                                              review['rating']?.toString() ??
                                                  '0') ??
                                          0;
                                  return Icon(
                                    index < rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 16,
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      review['comment']?.toString() ?? '',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              );
            })
            .where((widget) => widget is! SizedBox)
            .toList(),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildNearbyCulinaries() {
    if (nearbyCulinaries.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Kuliner Terdekat',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 24),
            itemCount: nearbyCulinaries.length,
            itemBuilder: (context, index) {
              final nearby = nearbyCulinaries[index];
              return Container(
                width: 150,
                margin: EdgeInsets.only(right: 16),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CulinaryDetailScreen(
                            culinaryId: nearby.id,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 100,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: nearby.featuredImage != null
                                ? CachedNetworkImage(
                                    imageUrl:
                                        'http://10.0.2.2:8000/storage/${nearby.featuredImage}',
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: Colors.orange.shade200,
                                      child: Icon(Icons.restaurant),
                                    ),
                                  )
                                : Container(
                                    color: Colors.orange.shade200,
                                    child: Icon(Icons.restaurant),
                                  ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nearby.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                if (nearby.type != null)
                                  Text(
                                    nearby.type!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                Spacer(),
                                Row(
                                  children: [
                                    Icon(Icons.star,
                                        size: 12, color: Colors.amber),
                                    SizedBox(width: 2),
                                    Text(
                                      nearby.averageRating.toStringAsFixed(1),
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak dapat melakukan panggilan')),
      );
    }
  }

  void _openMaps() async {
    if (culinary!.latitude != null && culinary!.longitude != null) {
      final Uri launchUri = Uri(
        scheme: 'https',
        host: 'www.google.com',
        path: '/maps/search/',
        queryParameters: {
          'api': '1',
          'query': '${culinary!.latitude},${culinary!.longitude}',
        },
      );

      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat membuka maps')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Koordinat lokasi tidak tersedia')),
      );
    }
  }

  Widget _buildSocialMedia() {
    if (culinary!.socialMedia == null || culinary!.socialMedia!.isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Media Sosial',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: culinary!.socialMedia!.entries.map((entry) {
              return GestureDetector(
                onTap: () =>
                    _openSocialMedia(entry.key, entry.value.toString()),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getSocialMediaColor(entry.key).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color:
                            _getSocialMediaColor(entry.key).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getSocialMediaIcon(entry.key),
                          color: _getSocialMediaColor(entry.key), size: 16),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          entry.value.toString(),
                          style: TextStyle(
                            color: _getSocialMediaColor(entry.key),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  IconData _getSocialMediaIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
      case 'fb':
        return Icons.facebook;
      case 'instagram':
      case 'ig':
        return Icons.camera_alt;
      case 'whatsapp':
      case 'wa':
        return Icons.phone;
      case 'twitter':
        return Icons.alternate_email;
      case 'website':
        return Icons.language;
      default:
        return Icons.link;
    }
  }

  Color _getSocialMediaColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
      case 'fb':
        return Color(0xFF1877F2);
      case 'instagram':
      case 'ig':
        return Color(0xFFE4405F);
      case 'whatsapp':
      case 'wa':
        return Color(0xFF25D366);
      case 'twitter':
        return Color(0xFF1DA1F2);
      case 'website':
        return Color(0xFF667EEA);
      default:
        return Colors.blue;
    }
  }

  void _openSocialMedia(String platform, String handle) {
    // Implement opening social media links
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Membuka $platform: $handle'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
