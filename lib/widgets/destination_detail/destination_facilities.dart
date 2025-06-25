// lib/widgets/destination_detail/destination_facilities.dart
import 'package:flutter/material.dart';
import '../../models/destination.dart';

class DestinationFacilities extends StatelessWidget {
  final Destination destination;

  const DestinationFacilities({Key? key, required this.destination}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (destination.facilities == null || destination.facilities!.isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fasilitas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: destination.facilities!.map((facility) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  facility['name'] ?? 'Fasilitas',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
