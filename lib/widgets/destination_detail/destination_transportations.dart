// lib/widgets/destination_detail/destination_transportations.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/destination.dart';

class DestinationTransportations extends StatelessWidget {
  final Destination destination;

  const DestinationTransportations({Key? key, required this.destination}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (destination.transportations == null || destination.transportations!.isEmpty) {
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
                'Transportasi 🚗',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              Text(
                '${destination.transportations!.length} pilihan',
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
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 24),
            itemCount: destination.transportations!.length,
            itemBuilder: (context, index) {
              final transportation = destination.transportations![index];
              return Container(
                width: 240,
                margin: EdgeInsets.only(right: 16),
                child: _buildTransportationCard(transportation),
              );
            },
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTransportationCard(dynamic transportation) {
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
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getTransportationColor(transportation['type']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTransportationIcon(transportation['type']),
                    color: _getTransportationColor(transportation['type']),
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transportation['name'] ?? 'Transportasi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${transportation['type']} - ${transportation['subtype']}',
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
            
            SizedBox(height: 12),
            
            Row(
              children: [
                Icon(Icons.people, size: 14, color: Colors.grey.shade600),
                SizedBox(width: 4),
                Text(
                  'Kapasitas: ${transportation['capacity']} orang',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 8),
            
            Row(
              children: [
                Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    transportation['phone_number'] ?? 'Tidak tersedia',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            Spacer(),
            
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Mulai Rp ${_formatPrice(transportation['base_price'])}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTransportationIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'darat':
        return Icons.directions_car;
      case 'laut':
        return Icons.directions_boat;
      case 'udara':
        return Icons.flight;
      default:
        return Icons.directions;
    }
  }

  Color _getTransportationColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'darat':
        return Colors.green;
      case 'laut':
        return Colors.blue;
      case 'udara':
        return Colors.orange;
      default:
        return Colors.grey;
    }
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
