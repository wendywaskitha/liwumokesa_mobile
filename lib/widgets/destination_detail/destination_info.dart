// lib/widgets/destination_detail/destination_info.dart
import 'package:flutter/material.dart';
import '../../models/destination.dart';

class DestinationInfo extends StatelessWidget {
  final Destination destination;

  const DestinationInfo({Key? key, required this.destination}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  destination.name,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
              if (destination.isFeatured)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange, Colors.deepOrange],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Featured',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          
          SizedBox(height: 8),
          
          if (destination.location != null)
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey.shade600, size: 20),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    destination.location!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          
          SizedBox(height: 16),
          
          Row(
            children: [
              if (destination.category != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF667EEA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    destination.category!.name,
                    style: TextStyle(
                      color: Color(0xFF667EEA),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              
              Spacer(),
              
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: destination.entranceFee == null || destination.entranceFee == 0
                      ? Colors.green.shade100
                      : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  destination.entranceFee == null || destination.entranceFee == 0
                      ? 'GRATIS'
                      : 'Rp ${destination.entranceFee!.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: destination.entranceFee == null || destination.entranceFee == 0
                        ? Colors.green.shade700
                        : Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
          
          if (destination.visitingHours != null) ...[
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey.shade600, size: 20),
                SizedBox(width: 8),
                Text(
                  'Jam Buka: ${destination.visitingHours}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
