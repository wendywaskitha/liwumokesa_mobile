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
    return Container(
      width: isHorizontal ? 260 : double.infinity, // Reduced width
      height: isHorizontal ? 280 : null, // Fixed height for horizontal
      margin: EdgeInsets.only(
        right: isHorizontal ? 16 : 0,
        bottom: isHorizontal ? 0 : 12, // Reduced margin
        left: isHorizontal ? 0 : 20,
        top: isHorizontal ? 0 : 0,
      ),
      child: Card(
        elevation: 6, // Reduced elevation
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Reduced radius
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Important: prevent overflow
            children: [
              _buildImageSection(),
              Flexible( // Use Flexible instead of fixed padding
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
            height: isHorizontal ? 120 : 140, // Reduced height
            width: double.infinity,
            child: _buildImage(),
          ),
          _buildBadges(),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (creativeEconomy.featuredImage != null && 
        creativeEconomy.featuredImage!.isNotEmpty &&
        Uri.tryParse(creativeEconomy.featuredImage!) != null) {
      
      return CachedNetworkImage(
        imageUrl: creativeEconomy.featuredImage!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildLoadingPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholderImage(),
        fadeInDuration: Duration(milliseconds: 200),
        fadeOutDuration: Duration(milliseconds: 200),
        memCacheWidth: 400, // Optimize memory usage
        memCacheHeight: 300,
      );
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF7FAFC),
      ),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
          ),
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
                maxLines: 1,
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
      padding: EdgeInsets.all(12), // Reduced padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Prevent overflow
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
        fontSize: 14, // Reduced font size
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
        fontSize: 11, // Reduced font size
        color: Color(0xFF718096),
        height: 1.3,
      ),
      maxLines: 1, // Reduced max lines
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
      children: features.take(2).toList(), // Limit to 2 features
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
