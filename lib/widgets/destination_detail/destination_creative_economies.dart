// lib/widgets/destination_detail/destination_creative_economies.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/destination.dart';

class DestinationCreativeEconomies extends StatelessWidget {
  final Destination destination;

  const DestinationCreativeEconomies({Key? key, required this.destination}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (destination.creativeEconomies == null || destination.creativeEconomies!.isEmpty) {
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
                'Ekonomi Kreatif 🎨',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              Text(
                '${destination.creativeEconomies!.length} usaha',
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
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 24),
            itemCount: destination.creativeEconomies!.length,
            itemBuilder: (context, index) {
              final creativeEconomy = destination.creativeEconomies![index];
              return Container(
                width: 280,
                margin: EdgeInsets.only(right: 16),
                child: _buildCreativeEconomyCard(creativeEconomy),
              );
            },
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCreativeEconomyCard(dynamic creativeEconomy) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: creativeEconomy['featured_image'] != null
                        ? CachedNetworkImage(
                            imageUrl: 'http://10.0.2.2:8000/storage/${creativeEconomy['featured_image']}',
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Icon(Icons.palette),
                          )
                        : Icon(Icons.palette, color: Colors.grey.shade500),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        creativeEconomy['name'] ?? 'Usaha Kreatif',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      if (creativeEconomy['establishment_year'] != null)
                        Text(
                          'Berdiri sejak ${creativeEconomy['establishment_year']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 8),
            
            if (creativeEconomy['short_description'] != null)
              Text(
                creativeEconomy['short_description'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            
            SizedBox(height: 8),
            
            Row(
              children: [
                if (creativeEconomy['has_workshop'] == true)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Workshop',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.purple.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                SizedBox(width: 4),
                if (creativeEconomy['has_direct_selling'] == true)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Jual Langsung',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            
            Spacer(),
            
            if (creativeEconomy['price_range_start'] != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Mulai Rp ${_formatPrice(creativeEconomy['price_range_start'])}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
          ],
        ),
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
