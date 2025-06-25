// lib/widgets/destination_detail/destination_culinaries.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/destination.dart';

class DestinationCulinaries extends StatelessWidget {
  final Destination destination;

  const DestinationCulinaries({Key? key, required this.destination}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (destination.culinaries == null || destination.culinaries!.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kuliner Lokal 🍽️',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              Text(
                '${destination.culinaries!.length} tempat',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 24),
            itemCount: destination.culinaries!.length,
            itemBuilder: (context, index) {
              final culinary = destination.culinaries![index];
              return Container(
                width: 260,
                margin: EdgeInsets.only(right: 16),
                child: _buildCulinaryCard(culinary),
              );
            },
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCulinaryCard(dynamic culinary) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            height: 100,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: culinary['featured_image'] != null
                  ? CachedNetworkImage(
                      imageUrl: 'http://10.0.2.2:8000/storage/${culinary['featured_image']}',
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade300,
                        child: Icon(Icons.restaurant, color: Colors.grey.shade500),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: Icon(Icons.restaurant, color: Colors.grey.shade500),
                    ),
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    culinary['name'] ?? 'Tempat Makan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 4),
                  
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      culinary['type'] ?? 'Kuliner',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 8),
                  
                  if (culinary['opening_hours'] != null)
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: Colors.grey.shade600),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            culinary['opening_hours'],
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  
                  Spacer(),
                  
                  // Price range
                  if (culinary['price_range_start'] != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Rp ${_formatPrice(culinary['price_range_start'])} - ${_formatPrice(culinary['price_range_end'])}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    double priceDouble = price is String ? double.tryParse(price) ?? 0 : price.toDouble();
    if (priceDouble >= 1000000) {
      return '${(priceDouble / 1000000).toStringAsFixed(1)}jt';
    } else if (priceDouble >= 1000) {
      return '${(priceDouble / 1000).toStringAsFixed(0)}rb';
    }
    return priceDouble.toStringAsFixed(0);
  }
}
