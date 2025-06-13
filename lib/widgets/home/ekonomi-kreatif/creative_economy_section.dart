// lib/widgets/home/ekonomi-kreatif/creative_economy_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/creative_economy_provider.dart';
import 'creative_economy_card.dart';

class CreativeEconomySection extends StatefulWidget {
  const CreativeEconomySection({Key? key}) : super(key: key);

  @override
  State<CreativeEconomySection> createState() => _CreativeEconomySectionState();
}

class _CreativeEconomySectionState extends State<CreativeEconomySection> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFeaturedData();
    });
  }

  void _loadFeaturedData() async {
    if (!_isInitialized) {
      setState(() {
        _isInitialized = true;
      });
      
      try {
        await context.read<CreativeEconomyProvider>().loadFeaturedCreativeEconomies();
      } catch (e) {
        print('Error loading featured creative economies: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreativeEconomyProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Prevent overflow
          children: [
            _buildSectionHeader(context),
            SizedBox(height: 12), // Reduced spacing
            _buildContent(context, provider),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded( // Prevent overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ekonomi Kreatif Unggulan 🎨',
                  style: TextStyle(
                    fontSize: 16, // Reduced font size
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                Text(
                  'Temukan produk kreatif lokal terbaik',
                  style: TextStyle(
                    fontSize: 12, // Reduced font size
                    color: Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF667EEA).withOpacity(0.3),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, '/creative-economy'),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lihat Semua',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, CreativeEconomyProvider provider) {
    if (!_isInitialized && provider.featuredCreativeEconomies.isEmpty) {
      return _buildLoadingState();
    }

    if (_isInitialized && provider.featuredCreativeEconomies.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      height: 280, // Reduced height to prevent overflow
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 20),
        itemCount: provider.featuredCreativeEconomies.length,
        physics: BouncingScrollPhysics(), // Better scroll physics
        itemBuilder: (context, index) {
          final creativeEconomy = provider.featuredCreativeEconomies[index];
          return CreativeEconomyCard(
            creativeEconomy: creativeEconomy,
            isHorizontal: true,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/creative-economy-detail',
                arguments: creativeEconomy.id,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 20),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 260,
            height: 280,
            margin: EdgeInsets.only(right: 16),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Color(0xFFF7FAFC),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 14,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xFFEDF2F7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(height: 6),
                          Container(
                            height: 10,
                            width: 120,
                            decoration: BoxDecoration(
                              color: Color(0xFFEDF2F7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 280,
      padding: EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFEDF2F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.store_outlined,
                size: 32,
                color: Color(0xFF718096),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Belum Ada Ekonomi Kreatif Unggulan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              'Ekonomi kreatif unggulan akan muncul di sini',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF718096),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
