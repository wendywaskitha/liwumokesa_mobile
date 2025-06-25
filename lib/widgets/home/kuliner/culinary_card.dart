// lib/widgets/home/kuliner/culinary_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/culinary.dart';

class CulinaryCard extends StatelessWidget {
  final Culinary culinary;
  final VoidCallback? onTap;

  const CulinaryCard({
    Key? key,
    required this.culinary,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap ??
            () {
              Navigator.pushNamed(
                context,
                '/culinary-detail',
                arguments: culinary.id,
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
              // Image section - Fixed height
              Hero(
                tag: 'culinary-${culinary.id}',
                child: Container(
                  height: 100, // Kurangi tinggi image
                  width: double.infinity,
                  child: _buildImage(),
                ),
              ),

              // Content section - Flexible height
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(6), // Kurangi padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title and badges
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              culinary.name,
                              style: TextStyle(
                                fontSize: 11, // Kurangi font size
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (culinary.isRecommended)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.orange, Colors.deepOrange],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Top',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 6, // Kurangi font size
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: 2),

                      // Type
                      if (culinary.type != null)
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            culinary.type!,
                            style: TextStyle(
                              fontSize: 7, // Kurangi font size
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      SizedBox(height: 2),

                      // Address - Simplified
                      if (culinary.address != null)
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 8, // Kurangi icon size
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                culinary.address!,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 8, // Kurangi font size
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                      // Spacer untuk mendorong bottom content ke bawah
                      Expanded(child: SizedBox()),

                      // Bottom info - Simplified
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Price range
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getDisplayPrice(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                                fontSize: 7, // Kurangi font size
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          SizedBox(height: 2),

                          // Rating and features in one row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Rating
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 8,
                                    color: Colors.amber,
                                  ),
                                  SizedBox(width: 1),
                                  Text(
                                    culinary.averageRating.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 7,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),

                              // Features - Only show most important ones
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (culinary.halalCertified)
                                    _buildFeatureIcon(
                                        Icons.verified, Colors.green),
                                  if (culinary.hasDelivery)
                                    _buildFeatureIcon(
                                        Icons.delivery_dining, Colors.blue),
                                ],
                              ),
                            ],
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
    if (culinary.featuredImage != null && culinary.featuredImage!.isNotEmpty) {
      String imageUrl =
          'http://10.0.2.2:8000/storage/${culinary.featuredImage}';

      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade200, Colors.orange.shade300],
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.orange),
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          print('Error loading culinary card image: $url - $error');
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade200, Colors.orange.shade300],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant,
                  size: 16,
                  color: Colors.orange.shade700,
                ),
                SizedBox(height: 2),
                Text(
                  'Gambar error',
                  style: TextStyle(
                    fontSize: 7,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          );
        },
        // Tambahkan timeout
        httpHeaders: {
          'Connection': 'keep-alive',
        },
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade200, Colors.orange.shade300],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 20,
              color: Colors.orange.shade700,
            ),
            SizedBox(height: 4),
            Text(
              'No Image',
              style: TextStyle(
                fontSize: 8,
                color: Colors.orange.shade700,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildFeatureIcon(IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(left: 1),
      padding: EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Icon(
        icon,
        size: 6, // Kurangi icon size
        color: color,
      ),
    );
  }

  String _getDisplayPrice() {
    if (culinary.priceRangeStart == null || culinary.priceRangeEnd == null) {
      return 'Bervariasi';
    }

    return '${_formatPrice(culinary.priceRangeStart!)} - ${_formatPrice(culinary.priceRangeEnd!)}';
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}jt';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}k';
    }
    return '${price.toStringAsFixed(0)}';
  }
}
