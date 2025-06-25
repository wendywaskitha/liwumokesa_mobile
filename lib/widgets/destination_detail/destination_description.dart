// lib/widgets/destination_detail/destination_description.dart
import 'package:flutter/material.dart';
import '../../models/destination.dart';

class DestinationDescription extends StatelessWidget {
  final Destination destination;

  const DestinationDescription({Key? key, required this.destination}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (destination.description == null || destination.description!.isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deskripsi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 12),
          Text(
            destination.description!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
