// lib/widgets/home/destinations_list.dart
import 'package:flutter/material.dart';
import '../../providers/destination_provider.dart';
import '../destination_card.dart';

class DestinationsList extends StatelessWidget {
  final DestinationProvider destinationProvider;

  const DestinationsList({Key? key, required this.destinationProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (destinationProvider.destinations.isEmpty && destinationProvider.isLoading) {
      return SliverToBoxAdapter(
        child: Container(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF667EEA).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Memuat destinasi amazing...',
                  style: TextStyle(
                    color: Color(0xFF667EEA),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (destinationProvider.destinations.isEmpty && !destinationProvider.isLoading) {
      return SliverToBoxAdapter(
        child: Container(
          height: 300,
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.explore_off, size: 48, color: Colors.grey.shade400),
                ),
                SizedBox(height: 16),
                Text(
                  'Belum ada destinasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                Text(
                  'Coba refresh atau periksa koneksi internet',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    destinationProvider.loadDestinations(refresh: true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF667EEA),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Refresh', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == destinationProvider.destinations.length) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
                  ),
                ),
              );
            }

            final destination = destinationProvider.destinations[index];
            return DestinationCard(destination: destination);
          },
          childCount: destinationProvider.destinations.length +
              (destinationProvider.hasMore && !destinationProvider.isLoading ? 1 : 0),
        ),
      ),
    );
  }
}
