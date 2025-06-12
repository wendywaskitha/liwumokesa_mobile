// lib/widgets/home/error_section.dart
import 'package:flutter/material.dart';
import '../../providers/destination_provider.dart';

class ErrorSection extends StatelessWidget {
  final DestinationProvider destinationProvider;

  const ErrorSection({Key? key, required this.destinationProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFED7D7), Color(0xFFFEE2E2)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFF56565).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFF56565).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline, color: Color(0xFFF56565)),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Oops! Terjadi Kesalahan',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFC53030),
                      ),
                    ),
                    Text(
                      destinationProvider.error!,
                      style: TextStyle(
                        color: Color(0xFFC53030),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                destinationProvider.clearError();
                destinationProvider.loadDestinations(refresh: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF56565),
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Coba Lagi', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
