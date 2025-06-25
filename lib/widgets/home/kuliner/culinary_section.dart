// lib/widgets/home/kuliner/culinary_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/culinary_provider.dart';
import 'culinary_card.dart';

class CulinarySection extends StatelessWidget {
  const CulinarySection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CulinaryProvider>(
      builder: (context, culinaryProvider, child) {
        // Load recommended culinaries if not loaded yet
        if (culinaryProvider.recommendedCulinaries.isEmpty && !culinaryProvider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            culinaryProvider.loadRecommendedCulinaries();
          });
        }

        return Container(
          margin: EdgeInsets.only(top: 20, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kuliner Lokal 🍽️',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        Text(
                          'Cicipi kelezatan kuliner khas daerah',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/culinaries');
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Lihat Semua',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              _buildCulinaryContent(culinaryProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCulinaryContent(CulinaryProvider provider) {
    // Loading state
    if (provider.recommendedCulinaries.isEmpty && provider.isLoading) {
      return Container(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 20),
          itemCount: 3,
          itemBuilder: (context, index) {
            return Container(
              width: 160,
              margin: EdgeInsets.only(right: 16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.orange.shade100,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.orange),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    // Error state
    if (provider.error != null && provider.recommendedCulinaries.isEmpty) {
      return Container(
        height: 200,
        margin: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 48,
                color: Colors.orange.shade300,
              ),
              SizedBox(height: 12),
              Text(
                'Gagal memuat kuliner',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => provider.loadRecommendedCulinaries(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
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
      );
    }

    // Empty state
    if (provider.recommendedCulinaries.isEmpty) {
      return Container(
        height: 200,
        margin: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 48,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 12),
              Text(
                'Belum ada kuliner',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              Text(
                'Kuliner akan segera hadir',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Success state dengan data
    return Container(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        physics: BouncingScrollPhysics(),
        itemCount: provider.recommendedCulinaries.length,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: EdgeInsets.only(right: 16),
            child: CulinaryCard(
              culinary: provider.recommendedCulinaries[index],
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/culinary-detail',
                  arguments: provider.recommendedCulinaries[index].id,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
