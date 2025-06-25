// lib/widgets/home/destinasi/destination_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/destination.dart';

class DestinationCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback? onTap;

  const DestinationCard({
    Key? key, 
    required this.destination,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap ?? () {
          Navigator.pushNamed(
            context,
            '/destination-detail',
            arguments: destination.id,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section dengan hero animation
              Hero(
                tag: 'destination-${destination.id}',
                child: Container(
                  height: 120, // Kurangi tinggi image
                  width: double.infinity,
                  child: _buildImage(),
                ),
              ),
              
              // Content section dengan Expanded untuk mencegah overflow
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8), // Kurangi padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Tambahkan ini
                    children: [
                      // Title and featured badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              destination.name,
                              style: TextStyle(
                                fontSize: 12, // Kurangi font size
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (destination.isFeatured)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.orange, Colors.deepOrange],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Featured',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 7, // Kurangi font size
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      SizedBox(height: 2), // Kurangi spacing
                      
                      // Location dengan icon
                      if (destination.location != null)
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 10, // Kurangi icon size
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                destination.location!,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 9, // Kurangi font size
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      
                      // Spacer untuk mendorong bottom info ke bawah
                      Expanded(child: SizedBox()),
                      
                      // Bottom info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Price
                          Flexible(
                            flex: 2,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: destination.entranceFee == null || destination.entranceFee == 0
                                    ? Colors.green.shade100
                                    : Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _getDisplayPrice(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: destination.entranceFee == null || destination.entranceFee == 0
                                      ? Colors.green.shade700
                                      : Colors.blue.shade700,
                                  fontSize: 8, // Kurangi font size
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          
                          SizedBox(width: 4),
                          
                          // Category
                          if (destination.category != null)
                            Flexible(
                              flex: 1,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Color(0xFF667EEA).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  destination.category!.name,
                                  style: TextStyle(
                                    fontSize: 7, // Kurangi font size
                                    color: Color(0xFF667EEA),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (destination.featuredImage != null && destination.featuredImage!.isNotEmpty) {
      String imageUrl = 'http://10.0.2.2:8000/storage/${destination.featuredImage}';
      
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade200, Colors.grey.shade300],
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFF667EEA)),
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade200, Colors.grey.shade300],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                size: 20, // Kurangi icon size
                color: Colors.grey.shade500,
              ),
              SizedBox(height: 2),
              Text(
                'No Image',
                style: TextStyle(
                  fontSize: 8, // Kurangi font size
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade200, Colors.grey.shade300],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.landscape,
              size: 24, // Kurangi icon size
              color: Colors.grey.shade500,
            ),
            SizedBox(height: 4),
            Text(
              'No Image',
              style: TextStyle(
                fontSize: 10, // Kurangi font size
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }
  }

  String _getDisplayPrice() {
    if (destination.entranceFee == null || destination.entranceFee == 0) {
      return 'GRATIS';
    }
    // Format harga dengan lebih singkat
    if (destination.entranceFee! >= 1000000) {
      return 'Rp ${(destination.entranceFee! / 1000000).toStringAsFixed(1)}M';
    } else if (destination.entranceFee! >= 1000) {
      return 'Rp ${(destination.entranceFee! / 1000).toStringAsFixed(0)}K';
    }
    return 'Rp ${destination.entranceFee!.toStringAsFixed(0)}';
  }
}
