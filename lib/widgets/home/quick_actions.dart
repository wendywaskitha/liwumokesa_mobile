// lib/widgets/home/quick_actions.dart
import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jelajahi Wisata 🔥',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/destinations');
                },
                child: Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: Color(0xFF667EEA),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionItem(
                  context,
                  Icons.explore,
                  'Destinasi',
                  Color(0xFF667EEA),
                  '/destinations',
                  '🗺️',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildActionItem(
                  context,
                  Icons.restaurant_menu,
                  'Kuliner',
                  Colors.orange,
                  '/culinaries',
                  '🍽️',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildActionItem(
                  context,
                  Icons.hotel,
                  'Akomodasi',
                  Color(0xFF48BB78),
                  '/accommodations', // Sesuaikan dengan route yang benar
                  '🏨',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildActionItem(
                  context,
                  Icons.palette,
                  'Ekonomi Kreatif',
                  Color(0xFF9F7AEA),
                  '/creative-economies', // Sesuaikan dengan route yang benar
                  '🎨',
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Kategori destinasi
          Text(
            'Kategori Destinasi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCategoryItem(
                  context,
                  Icons.beach_access,
                  'Pantai',
                  Color(0xFF4299E1),
                  '🏖️',
                  () => _filterByCategory(context, 'pantai'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildCategoryItem(
                  context,
                  Icons.landscape,
                  'Gunung',
                  Color(0xFF48BB78),
                  '⛰️',
                  () => _filterByCategory(context, 'gunung'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildCategoryItem(
                  context,
                  Icons.account_balance,
                  'Budaya',
                  Color(0xFFED8936),
                  '🏛️',
                  () => _filterByCategory(context, 'budaya'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildCategoryItem(
                  context,
                  Icons.water,
                  'Air Terjun',
                  Color(0xFF38B2AC),
                  '💧',
                  () => _filterByCategory(context, 'air_terjun'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    String route,
    String emoji,
  ) {
    return GestureDetector(
      onTap: () {
        try {
          Navigator.pushNamed(context, route);
        } catch (e) {
          print('Navigation error to $route: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Halaman $label belum tersedia'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.1), color.withOpacity(0.2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Text(
                      emoji,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    String emoji,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: 16,
                  ),
                  Positioned(
                    top: -1,
                    right: -1,
                    child: Text(
                      emoji,
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _filterByCategory(BuildContext context, String category) {
    Navigator.pushNamed(
      context,
      '/destinations',
      arguments: {'filter': category},
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filter kategori: ${category.replaceAll('_', ' ')}'),
        backgroundColor: Color(0xFF667EEA),
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Lihat',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, '/destinations');
          },
        ),
      ),
    );
  }
}
