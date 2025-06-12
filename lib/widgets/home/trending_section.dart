// lib/widgets/home/trending_section.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/destination_provider.dart';
import '../../models/destination.dart';

class TrendingSection extends StatelessWidget {
  final DestinationProvider destinationProvider;

  const TrendingSection({Key? key, required this.destinationProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final trendingDestinations = destinationProvider.destinations.take(3).toList();
    
    if (trendingDestinations.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trending Sekarang 📈',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 16),
          ...trendingDestinations.asMap().entries.map((entry) {
            int index = entry.key;
            Destination destination = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              child: _buildTrendingItem(destination, index + 1),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTrendingItem(Destination destination, int rank) {
    return Container(
      padding: EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 50,
              height: 50,
              child: destination.featuredImage != null
                  ? CachedNetworkImage(
                      imageUrl: 'http://10.0.2.2:8000/storage/${destination.featuredImage}',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade300,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade300,
                        child: Icon(Icons.image, size: 24),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: Icon(Icons.image, size: 24),
                    ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (destination.location != null)
                  Text(
                    destination.location!,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Icon(Icons.trending_up, color: Color(0xFF48BB78)),
        ],
      ),
    );
  }
}
