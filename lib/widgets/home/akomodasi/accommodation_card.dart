// lib/widgets/home/akomodasi/accommodation_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/accommodation.dart';

class AccommodationCard extends StatelessWidget {
  final Accommodation accommodation;
  final VoidCallback? onTap;
  final bool isHorizontal;

  const AccommodationCard({
    Key? key,
    required this.accommodation,
    this.onTap,
    this.isHorizontal = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('=== Accommodation Card Debug ===');
    print('Building card for: ${accommodation.name}');
    print('Featured Image: ${accommodation.featuredImage}');
    print('Valid Image URL: ${accommodation.validImageUrl}');
    print('===================================');

    return Container(
      width: isHorizontal ? 260 : double.infinity,
      height: isHorizontal ? 280 : null,
      margin: EdgeInsets.only(
        right: isHorizontal ? 16 : 0,
        bottom: isHorizontal ? 0 : 12,
        left: isHorizontal ? 0 : 20,
        top: isHorizontal ? 0 : 0,
      ),
      child: Card(
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildImageSection(),
              Flexible(
                child: _buildContentSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      child: Stack(
        children: [
          Container(
            height: isHorizontal ? 120 : 140,
            width: double.infinity,
            child: _buildImage(),
          ),
          _buildTypeBadge(),
          _buildRatingBadge(),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final imageUrl = accommodation.validImageUrl;
    
    print('Building image with URL: $imageUrl');
    
    if (imageUrl != null && imageUrl.isNotEmpty) {
      print('Using CachedNetworkImage for: $imageUrl');
      
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) {
          print('Loading placeholder for: $url');
          return _buildLoadingPlaceholder();
        },
        errorWidget: (context, url, error) {
          print('Error loading image: $url');
          print('Error details: $error');
          return _buildErrorPlaceholder();
        },
        fadeInDuration: Duration(milliseconds: 300),
        fadeOutDuration: Duration(milliseconds: 300),
        memCacheWidth: 400,
        memCacheHeight: 300,
        httpHeaders: {
          'Cache-Control': 'max-age=3600',
          'User-Agent': 'Flutter App',
        },
      );
    } else {
      print('No valid image URL, using placeholder');
      return _buildPlaceholderImage();
    }
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF7FAFC), Color(0xFFEDF2F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Memuat gambar...',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF718096),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE53E3E), Color(0xFFC53030)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 24,
              color: Colors.white.withOpacity(0.8),
            ),
            SizedBox(height: 4),
            Text(
              'Gagal memuat gambar',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getAccommodationIcon(),
              size: 24,
              color: Colors.white.withOpacity(0.8),
            ),
            SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                accommodation.name,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAccommodationIcon() {
    switch (accommodation.type.toLowerCase()) {
      case 'hotel':
        return Icons.hotel;
      case 'resort':
        return Icons.pool;
      case 'homestay':
        return Icons.home;
      case 'villa':
        return Icons.villa;
      case 'guesthouse':
        return Icons.house;
      default:
        return Icons.bed;
    }
  }

  Widget _buildTypeBadge() {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _getTypeColors(),
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _getTypeColors().first.withOpacity(0.3),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getAccommodationIcon(), color: Colors.white, size: 12),
            SizedBox(width: 4),
            Text(
              _getTypeDisplayName(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getTypeColors() {
    switch (accommodation.type.toLowerCase()) {
      case 'hotel':
        return [Color(0xFF667EEA), Color(0xFF764BA2)];
      case 'resort':
        return [Color(0xFF48BB78), Color(0xFF38A169)];
      case 'homestay':
        return [Color(0xFFED8936), Color(0xFFDD6B20)];
      case 'villa':
        return [Color(0xFF9F7AEA), Color(0xFF805AD5)];
      case 'guesthouse':
        return [Color(0xFF38B2AC), Color(0xFF319795)];
      default:
        return [Color(0xFF718096), Color(0xFF4A5568)];
    }
  }

  String _getTypeDisplayName() {
    switch (accommodation.type.toLowerCase()) {
      case 'hotel':
        return 'Hotel';
      case 'resort':
        return 'Resort';
      case 'homestay':
        return 'Homestay';
      case 'villa':
        return 'Villa';
      case 'guesthouse':
        return 'Guest House';
      default:
        return accommodation.type;
    }
  }

  Widget _buildRatingBadge() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Color(0xFFFFF5B7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Color(0xFFD69E2E), size: 12),
            SizedBox(width: 2),
            Text(
              accommodation.averageRating.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFFD69E2E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTitle(),
          SizedBox(height: 4),
          _buildLocation(),
          SizedBox(height: 6),
          _buildPriceAndReviews(),
          SizedBox(height: 6),
          _buildFacilities(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      accommodation.name,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3748),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLocation() {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: 12,
          color: Color(0xFF667EEA),
        ),
        SizedBox(width: 2),
        Expanded(
          child: Text(
            accommodation.district?.name ?? accommodation.address ?? 'Lokasi tidak tersedia',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF718096),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceAndReviews() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Price
        if (accommodation.priceRangeText != null)
          Expanded(
            child: Text(
              accommodation.priceRangeText!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF48BB78),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        // Reviews count
        Text(
          '${accommodation.approvedReviewsCount} ulasan',
          style: TextStyle(
            fontSize: 10,
            color: Color(0xFF718096),
          ),
        ),
      ],
    );
  }

  Widget _buildFacilities() {
    if (accommodation.facilities == null || accommodation.facilities!.isEmpty) {
      return SizedBox.shrink();
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: accommodation.facilities!.take(3).map((facility) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Color(0xFF667EEA).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Color(0xFF667EEA).withOpacity(0.2)),
          ),
          child: Text(
            _getFacilityDisplayName(facility),
            style: TextStyle(
              fontSize: 9,
              color: Color(0xFF667EEA),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getFacilityDisplayName(String facility) {
    switch (facility.toLowerCase()) {
      case 'wifi':
        return 'WiFi';
      case 'parking':
        return 'Parkir';
      case 'breakfast':
        return 'Sarapan';
      case 'pool':
        return 'Kolam';
      case 'gym':
        return 'Gym';
      case 'spa':
        return 'Spa';
      case 'restaurant':
        return 'Restoran';
      case 'bar':
        return 'Bar';
      case 'ac':
        return 'AC';
      case 'tv':
        return 'TV';
      default:
        return facility;
    }
  }
}
