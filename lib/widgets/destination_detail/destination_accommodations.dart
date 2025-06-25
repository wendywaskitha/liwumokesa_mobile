// lib/widgets/destination_detail/destination_accommodations.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/destination.dart';

class DestinationAccommodations extends StatelessWidget {
  final Destination destination;

  const DestinationAccommodations({Key? key, required this.destination}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (destination.accommodations == null || destination.accommodations!.isEmpty) {
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
                'Akomodasi Terdekat 🏨',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              Text(
                '${destination.accommodations!.length} hotel',
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
            itemCount: destination.accommodations!.length,
            itemBuilder: (context, index) {
              final accommodation = destination.accommodations![index];
              return Container(
                width: 280,
                margin: EdgeInsets.only(right: 16),
                child: _buildAccommodationCard(accommodation),
              );
            },
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAccommodationCard(dynamic accommodation) {
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
                    child: accommodation['featured_image'] != null
                        ? CachedNetworkImage(
                            imageUrl: 'http://10.0.2.2:8000/storage/${accommodation['featured_image']}',
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Icon(Icons.hotel),
                          )
                        : Icon(Icons.hotel, color: Colors.grey.shade500),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        accommodation['name'] ?? 'Hotel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        accommodation['type'] ?? 'Hotel',
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
            SizedBox(height: 8),
            if (accommodation['address'] != null)
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      accommodation['address'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (accommodation['price_range_start'] != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Rp ${_formatPrice(accommodation['price_range_start'])}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                if (accommodation['pivot'] != null && accommodation['pivot']['distance'] != null)
                  Text(
                    '${accommodation['pivot']['distance']} km',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
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
