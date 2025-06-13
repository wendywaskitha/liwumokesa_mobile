// lib/widgets/home/ekonomi-kreatif/creative_economy_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/creative_economy.dart';

class CreativeEconomyCard extends StatelessWidget {
  final CreativeEconomy creativeEconomy;
  final VoidCallback? onTap;
  final bool isHorizontal;

  const CreativeEconomyCard({
    Key? key,
    required this.creativeEconomy,
    this.onTap,
    this.isHorizontal = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Debug image info at widget level
    print('=== Creative Economy Card Debug ===');
    print('Building card for: ${creativeEconomy.name}');
    print('Featured Image: ${creativeEconomy.featuredImage}');
    print('Valid Image URL: ${creativeEconomy.validImageUrl}');
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
          _buildBadges(),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final imageUrl = creativeEconomy.validImageUrl;
    
    print('Building image with URL: $imageUrl');
    
    // Check if we have a valid image URL
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
        // Add timeout and retry options
        cacheManager: null, // Use default cache manager
        useOldImageOnUrlChange: false,
        filterQuality: FilterQuality.medium,
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
            SizedBox(height: 2),
            Text(
              creativeEconomy.name,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 8,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
              Icons.store,
              size: 24,
              color: Colors.white.withOpacity(0.8),
            ),
            SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                creativeEconomy.name,
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

  Widget _buildBadges() {
    return Positioned(
      top: 8,
      left: 8,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (creativeEconomy.isFeatured)
            _buildBadge(
              icon: Icons.star,
              text: 'Unggulan',
              colors: [Color(0xFFED8936), Color(0xFFDD6B20)],
            ),
          if (creativeEconomy.isVerified) ...[
            if (creativeEconomy.isFeatured) SizedBox(width: 4),
            _buildBadge(
              icon: Icons.verified,
              text: 'Verified',
              colors: [Color(0xFF48BB78), Color(0xFF38A169)],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String text,
    required List<Color> colors,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 10),
          SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
          if (creativeEconomy.shortDescription != null && 
              creativeEconomy.shortDescription!.isNotEmpty)
            _buildDescription(),
          SizedBox(height: 6),
          _buildLocationAndRating(),
          SizedBox(height: 6),
          _buildPriceAndFeatures(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      creativeEconomy.name,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3748),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription() {
    return Text(
      creativeEconomy.shortDescription!,
      style: TextStyle(
        fontSize: 11,
        color: Color(0xFF718096),
        height: 1.3,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLocationAndRating() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                size: 12,
                color: Color(0xFF667EEA),
              ),
              SizedBox(width: 2),
              Expanded(
                child: Text(
                  _getLocationText(),
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF718096),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 4),
        _buildRatingContainer(),
      ],
    );
  }

  String _getLocationText() {
    if (creativeEconomy.district?.name != null && 
        creativeEconomy.district!.name.isNotEmpty) {
      return creativeEconomy.district!.name;
    } else if (creativeEconomy.address != null && 
               creativeEconomy.address!.isNotEmpty) {
      return creativeEconomy.address!;
    } else {
      return 'Lokasi tidak tersedia';
    }
  }

  Widget _buildRatingContainer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Color(0xFFFFF5B7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Color(0xFFD69E2E), size: 10),
          SizedBox(width: 2),
          Text(
            creativeEconomy.averageRating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFFD69E2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAndFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (creativeEconomy.priceRangeText != null && 
            creativeEconomy.priceRangeText!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text(
              creativeEconomy.priceRangeText!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF48BB78),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        _buildFeatureChips(),
      ],
    );
  }

  Widget _buildFeatureChips() {
    final features = <Widget>[];
    
    if (creativeEconomy.hasWorkshop) {
      features.add(_buildFeatureChip('Workshop', Icons.school, Color(0xFF667EEA)));
    }
    
    if (creativeEconomy.hasDirectSelling) {
      features.add(_buildFeatureChip('Jual Langsung', Icons.shopping_bag, Color(0xFF9F7AEA)));
    }
    
    if (creativeEconomy.category != null && 
        creativeEconomy.category!.name.isNotEmpty) {
      features.add(_buildFeatureChip(
        creativeEconomy.category!.name,
        Icons.category,
        Color(0xFF718096),
      ));
    }

    if (features.isEmpty) return SizedBox.shrink();

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: features.take(2).toList(),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
