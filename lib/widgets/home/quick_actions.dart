// lib/widgets/home/quick_actions.dart
import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final categories = [
      {'icon': Icons.beach_access, 'label': 'Pantai', 'color': Color(0xFF4299E1), 'emoji': '🏖️'},
      {'icon': Icons.landscape, 'label': 'Gunung', 'color': Color(0xFF48BB78), 'emoji': '⛰️'},
      {'icon': Icons.account_balance, 'label': 'Budaya', 'color': Color(0xFFED8936), 'emoji': '🏛️'},
      {'icon': Icons.local_dining, 'label': 'Kuliner', 'color': Color(0xFFE53E3E), 'emoji': '🍜'},
    ];

    return Container(
      margin: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kategori Populer 🔥',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Lihat Semua',
                  style: TextStyle(color: Color(0xFF667EEA)),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: categories.map((category) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: categories.last == category ? 0 : 12),
                  child: _buildQuickActionItem(
                    category['icon'] as IconData,
                    category['label'] as String,
                    category['color'] as Color,
                    category['emoji'] as String,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(IconData icon, String label, Color color, String emoji) {
    return InkWell(
      onTap: () => print('Filter by: $label'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
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
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.1), color.withOpacity(0.2)],
                ),
                shape: BoxShape.circle,
              ),
              child: Text(emoji, style: TextStyle(fontSize: 24)),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
