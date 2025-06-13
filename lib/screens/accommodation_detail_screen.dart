// lib/screens/accommodation_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/accommodation.dart';
import '../providers/accommodation_provider.dart';
import '../utils/map_direction_helper.dart';

class AccommodationDetailScreen extends StatefulWidget {
  final int id;

  const AccommodationDetailScreen({Key? key, required this.id})
      : super(key: key);

  @override
  State<AccommodationDetailScreen> createState() =>
      _AccommodationDetailScreenState();
}

class _AccommodationDetailScreenState extends State<AccommodationDetailScreen> {
  Accommodation? _accommodation;
  bool _isLoading = true;
  String? _error;
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _loadDetail();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000));
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider =
          Provider.of<AccommodationProvider>(context, listen: false);
      final detail = await provider.getAccommodation(widget.id);
      setState(() {
        _accommodation = detail;
      });

      if (_accommodation?.latitude != null &&
          _accommodation?.longitude != null) {
        _loadMap();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadMap() {
    if (_accommodation?.latitude != null && _accommodation?.longitude != null) {
      final htmlContent = _generateLeafletMapHtml(
        _accommodation!.latitude!,
        _accommodation!.longitude!,
        _accommodation!.name,
      );
      _webViewController.loadHtmlString(htmlContent);
    }
  }

  Future<void> _openWhatsAppBooking() async {
    try {
      // Ambil nomor telepon dari accommodation
      String? phoneNumber = _accommodation?.phoneNumber;

      if (phoneNumber == null || phoneNumber.isEmpty) {
        _showSnackBar('Nomor telepon tidak tersedia');
        return;
      }

      // Bersihkan nomor telepon (hapus karakter non-digit)
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

      // Konversi nomor Indonesia (08xx) ke format internasional (+628xx)
      if (cleanPhone.startsWith('08')) {
        cleanPhone = '628${cleanPhone.substring(2)}';
      } else if (cleanPhone.startsWith('8')) {
        cleanPhone = '62$cleanPhone';
      } else if (!cleanPhone.startsWith('62')) {
        cleanPhone = '62$cleanPhone';
      }

      // Buat pesan WhatsApp untuk booking
      final accommodationName = _accommodation!.name;
      final accommodationType = _getTypeDisplayName();
      final message = Uri.encodeComponent(
          'Halo, saya tertarik untuk melakukan booking di $accommodationName ($accommodationType). '
          'Bisakah Anda memberikan informasi mengenai:\n\n'
          '• Ketersediaan kamar\n'
          '• Harga per malam\n'
          '• Fasilitas yang tersedia\n'
          '• Prosedur booking\n\n'
          'Terima kasih!');

      // URL WhatsApp
      final whatsappUrl = 'https://wa.me/$cleanPhone?text=$message';
      final Uri uri = Uri.parse(whatsappUrl);

      print('Opening WhatsApp booking: $whatsappUrl');

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback: buka WhatsApp tanpa pesan
        final fallbackUrl = 'https://wa.me/$cleanPhone';
        final fallbackUri = Uri.parse(fallbackUrl);

        if (await canLaunchUrl(fallbackUri)) {
          await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        } else {
          _showSnackBar('Tidak dapat membuka WhatsApp');
        }
      }
    } catch (e) {
      print('Error opening WhatsApp booking: $e');
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFFE53E3E),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _openWhatsAppDirect() async {
    try {
      String? phoneNumber = _accommodation?.phoneNumber;

      if (phoneNumber == null || phoneNumber.isEmpty) {
        _showSnackBar('Nomor telepon tidak tersedia');
        return;
      }

      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

      if (cleanPhone.startsWith('08')) {
        cleanPhone = '628${cleanPhone.substring(2)}';
      } else if (cleanPhone.startsWith('8')) {
        cleanPhone = '62$cleanPhone';
      } else if (!cleanPhone.startsWith('62')) {
        cleanPhone = '62$cleanPhone';
      }

      final whatsappUrl = 'https://wa.me/$cleanPhone';
      final Uri uri = Uri.parse(whatsappUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Tidak dapat membuka WhatsApp');
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
              ? _buildErrorState()
              : _accommodation == null
                  ? _buildNotFoundState()
                  : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat detail akomodasi...',
            style: TextStyle(
              color: Color(0xFF718096),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFE53E3E),
            ),
            SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF718096),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF667EEA),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Coba Lagi',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hotel_outlined,
            size: 64,
            color: Color(0xFF718096),
          ),
          SizedBox(height: 16),
          Text(
            'Akomodasi Tidak Ditemukan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Akomodasi yang Anda cari tidak tersedia',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF718096),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildMainInfo(),
              _buildContactInfo(),
              _buildFacilitiesSection(),
              _buildMapSection(),
              _buildNearbyDestinationsSection(),
              if (_accommodation!.reviews != null &&
                  _accommodation!.reviews!.isNotEmpty)
                _buildReviewsSection(),
              SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {
              // Share functionality
            },
            icon: Icon(Icons.share, color: Color(0xFF2D3748)),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildHeroImage(),
            _buildImageOverlay(),
            _buildImageBadges(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    if (_accommodation!.featuredImage != null &&
        _accommodation!.featuredImage!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: _accommodation!.validImageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholderImage(),
      );
    } else {
      return _buildPlaceholderImage();
    }
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
          children: [
            Icon(
              _getAccommodationIcon(),
              size: 64,
              color: Colors.white.withOpacity(0.8),
            ),
            SizedBox(height: 16),
            Text(
              _accommodation!.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAccommodationIcon() {
    switch (_accommodation!.type.toLowerCase()) {
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

  Widget _buildImageOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageBadges() {
    return Positioned(
      top: 100,
      left: 16,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _getTypeColors(),
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _getTypeColors().first.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getAccommodationIcon(), color: Colors.white, size: 16),
            SizedBox(width: 6),
            Text(
              _getTypeDisplayName(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getTypeColors() {
    switch (_accommodation!.type.toLowerCase()) {
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
    switch (_accommodation!.type.toLowerCase()) {
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
        return _accommodation!.type;
    }
  }

  Widget _buildMainInfo() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _accommodation!.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFFFFF5B7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Color(0xFFD69E2E), size: 16),
                    SizedBox(width: 4),
                    Text(
                      _accommodation!.averageRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD69E2E),
                      ),
                    ),
                    Text(
                      ' (${_accommodation!.approvedReviewsCount})',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFD69E2E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (_accommodation!.description != null &&
              _accommodation!.description!.isNotEmpty) ...[
            Text(
              'Deskripsi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 8),
            Text(
              _accommodation!.description!,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
                height: 1.5,
              ),
            ),
            SizedBox(height: 16),
          ],
          if (_accommodation!.priceRangeText != null) ...[
            Row(
              children: [
                Icon(Icons.attach_money, color: Color(0xFF48BB78), size: 20),
                SizedBox(width: 8),
                Text(
                  'Kisaran Harga: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF718096),
                  ),
                ),
                Text(
                  _accommodation!.priceRangeText!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF48BB78),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Kontak',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 16),
          if (_accommodation!.address != null &&
              _accommodation!.address!.isNotEmpty)
            _buildContactItem(
              icon: Icons.location_on,
              label: 'Alamat',
              value: _accommodation!.address!,
              color: Color(0xFF667EEA),
            ),
          if (_accommodation!.contactPerson != null &&
              _accommodation!.contactPerson!.isNotEmpty)
            _buildContactItem(
              icon: Icons.person,
              label: 'Contact Person',
              value: _accommodation!.contactPerson!,
              color: Color(0xFF9F7AEA),
            ),
          if (_accommodation!.phoneNumber != null &&
              _accommodation!.phoneNumber!.isNotEmpty)
            _buildContactItem(
              icon: Icons.phone,
              label: 'Telepon',
              value: _accommodation!.phoneNumber!,
              color: Color(0xFF48BB78),
              onTap: () => _launchUrl('tel:${_accommodation!.phoneNumber}'),
            ),
          if (_accommodation!.phoneNumber != null &&
              _accommodation!.phoneNumber!.isNotEmpty)
            _buildContactItem(
              icon: Icons.chat,
              label: 'WhatsApp',
              value: 'Chat via WhatsApp',
              color: Color(0xFF25D366),
              onTap: () => _openWhatsAppDirect(),
            ),
          if (_accommodation!.email != null &&
              _accommodation!.email!.isNotEmpty)
            _buildContactItem(
              icon: Icons.email,
              label: 'Email',
              value: _accommodation!.email!,
              color: Color(0xFF38B2AC),
              onTap: () => _launchUrl('mailto:${_accommodation!.email}'),
            ),
          if (_accommodation!.website != null &&
              _accommodation!.website!.isNotEmpty)
            _buildContactItem(
              icon: Icons.language,
              label: 'Website',
              value: _accommodation!.website!,
              color: Color(0xFFED8936),
              onTap: () => _launchUrl(_accommodation!.website!),
            ),
          if (_accommodation!.phoneNumber != null &&
              _accommodation!.phoneNumber!.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: 16),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _openWhatsAppBooking(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF25D366), // WhatsApp green color
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Booking via WhatsApp',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF718096),
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2D3748),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF718096),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFacilitiesSection() {
    if (_accommodation!.facilities == null ||
        _accommodation!.facilities!.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fasilitas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _accommodation!.facilities!.map((facility) {
              return _buildFacilityItem(facility);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityItem(String facility) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFF667EEA).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFF667EEA).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getFacilityIcon(facility),
            size: 16,
            color: Color(0xFF667EEA),
          ),
          SizedBox(width: 6),
          Text(
            _getFacilityDisplayName(facility),
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF667EEA),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFacilityIcon(String facility) {
    switch (facility.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case 'parking':
        return Icons.local_parking;
      case 'breakfast':
        return Icons.free_breakfast;
      case 'pool':
        return Icons.pool;
      case 'gym':
        return Icons.fitness_center;
      case 'spa':
        return Icons.spa;
      case 'restaurant':
        return Icons.restaurant;
      case 'bar':
        return Icons.local_bar;
      case 'ac':
        return Icons.ac_unit;
      case 'tv':
        return Icons.tv;
      default:
        return Icons.check_circle;
    }
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
        return 'Kolam Renang';
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

  Widget _buildMapSection() {
    if (_accommodation!.latitude == null || _accommodation!.longitude == null) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lokasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF667EEA).withOpacity(0.3),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        MapDirectionHelper.showMapsOptions(
                          context,
                          _accommodation!.latitude!,
                          _accommodation!.longitude!,
                          _accommodation!.name,
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.directions,
                                color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Petunjuk Arah',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 250,
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFE2E8F0)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: WebViewWidget(controller: _webViewController),
            ),
          ),
          if (_accommodation!.address != null &&
              _accommodation!.address!.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Color(0xFF667EEA), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _accommodation!.address!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNearbyDestinationsSection() {
    if (_accommodation!.nearbyDestinations == null ||
        _accommodation!.nearbyDestinations!.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Destinasi Terdekat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 16),
          ..._accommodation!.nearbyDestinations!.take(5).map((destination) {
            return _buildNearbyDestinationItem(destination);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildNearbyDestinationItem(dynamic destination) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF48BB78).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.place, color: Color(0xFF48BB78), size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination['name'] ?? 'Destinasi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D3748),
                  ),
                ),
                if (destination['distance'] != null)
                  Text(
                    '${destination['distance'].toStringAsFixed(1)} km',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF718096),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ulasan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFFFFF5B7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Color(0xFFD69E2E), size: 16),
                    SizedBox(width: 4),
                    Text(
                      _accommodation!.averageRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD69E2E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Ulasan dari tamu akan ditampilkan di sini',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  String _generateLeafletMapHtml(double lat, double lng, String title) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Map</title>
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" 
        integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" 
        crossorigin=""/>
  <style>
    #map { 
      height: 100%; 
      width: 100%; 
      border-radius: 12px;
    }
    html, body { 
      margin: 0; 
      height: 100%; 
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    }
    .custom-popup {
      font-size: 14px;
      line-height: 1.4;
    }
    .custom-popup .popup-title {
      font-weight: bold;
      color: #2D3748;
      margin-bottom: 4px;
    }
  </style>
</head>
<body>
  <div id="map"></div>
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
          integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo="
          crossorigin=""></script>
  <script>
    var map = L.map('map', {
      zoomControl: true,
      attributionControl: true
    }).setView([$lat, $lng], 16);
    
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '© OpenStreetMap contributors'
    }).addTo(map);
    
    var customIcon = L.divIcon({
      className: 'custom-marker',
      html: '<div style="background-color: #667EEA; width: 20px; height: 20px; border-radius: 50%; border: 3px solid white; box-shadow: 0 2px 4px rgba(0,0,0,0.3);"></div>',
      iconSize: [20, 20],
      iconAnchor: [10, 10]
    });
    
    var marker = L.marker([$lat, $lng], {icon: customIcon}).addTo(map);
    
    var popupContent = '<div class="custom-popup"><div class="popup-title">${title.replaceAll("'", "\\'")}</div></div>';
    marker.bindPopup(popupContent).openPopup();
    
    map.scrollWheelZoom.disable();
    
    map.on('click', function() {
      map.scrollWheelZoom.enable();
    });
    
    map.on('mouseout', function() {
      map.scrollWheelZoom.disable();
    });
  </script>
</body>
</html>
''';
  }

  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka $url'),
            backgroundColor: Color(0xFFE53E3E),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Color(0xFFE53E3E),
        ),
      );
    }
  }
}
