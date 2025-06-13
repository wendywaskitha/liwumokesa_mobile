// lib/widgets/home/akomodasi/accommodation_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/accommodation_provider.dart';
import 'accommodation_card.dart';

class AccommodationSection extends StatefulWidget {
  const AccommodationSection({Key? key}) : super(key: key);

  @override
  State<AccommodationSection> createState() => _AccommodationSectionState();
}

class _AccommodationSectionState extends State<AccommodationSection> {
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
        await context.read<AccommodationProvider>().loadAccommodations(
          refresh: true,
          perPage: 5,
          sortBy: 'average_rating',
          sortOrder: 'desc',
        );
      } catch (e) {
        print('Error loading featured accommodations: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccommodationProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context),
            SizedBox(height: 12),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Akomodasi Terbaik 🏨',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                Text(
                  'Temukan tempat menginap terbaik',
                  style: TextStyle(
                    fontSize: 12,
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
                onTap: () => Navigator.pushNamed(context, '/accommodation'),
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

  Widget _buildContent(BuildContext context, AccommodationProvider provider) {
    if (!_isInitialized && provider.accommodations.isEmpty) {
      return _buildLoadingState();
    }

    if (_isInitialized && provider.accommodations.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 20),
        physics: BouncingScrollPhysics(),
        itemCount: provider.accommodations.length > 5 
            ? 5 
            : provider.accommodations.length,
        itemBuilder: (context, index) {
          final accommodation = provider.accommodations[index];
          return AccommodationCard(
            accommodation: accommodation,
            isHorizontal: true,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/accommodation-detail',
                arguments: accommodation.id,
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
                Icons.hotel_outlined,
                size: 32,
                color: Color(0xFF718096),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Belum Ada Akomodasi',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              'Akomodasi akan muncul di sini',
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
