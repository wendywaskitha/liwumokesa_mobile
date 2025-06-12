// lib/widgets/home/stats_cards.dart
import 'package:flutter/material.dart';
import '../../providers/destination_provider.dart';

class StatsCards extends StatelessWidget {
  final DestinationProvider destinationProvider;

  const StatsCards({Key? key, required this.destinationProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              Icons.location_on,
              '${destinationProvider.destinations.length}+',
              'Destinasi',
              Color(0xFF667EEA),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              Icons.star,
              '4.8',
              'Rating',
              Color(0xFFED8936),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              Icons.people,
              '10K+',
              'Wisatawan',
              Color(0xFF38B2AC),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
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
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }
}
