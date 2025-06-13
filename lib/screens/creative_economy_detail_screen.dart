// lib/screens/creative_economy_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/creative_economy.dart';
import '../providers/creative_economy_provider.dart';
import '../utils/map_direction_helper.dart'; // Import helper

class CreativeEconomyDetailScreen extends StatefulWidget {
  final int id;

  const CreativeEconomyDetailScreen({Key? key, required this.id})
      : super(key: key);

  @override
  State<CreativeEconomyDetailScreen> createState() =>
      _CreativeEconomyDetailScreenState();
}

class _CreativeEconomyDetailScreenState
    extends State<CreativeEconomyDetailScreen> {
  CreativeEconomy? _creativeEconomy;
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
          Provider.of<CreativeEconomyProvider>(context, listen: false);
      final detail = await provider.getCreativeEconomy(widget.id);
      setState(() {
        _creativeEconomy = detail;
      });

      if (_creativeEconomy?.latitude != null &&
          _creativeEconomy?.longitude != null) {
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
    if (_creativeEconomy?.latitude != null &&
        _creativeEconomy?.longitude != null) {
      final htmlContent = _generateLeafletMapHtml(
        _creativeEconomy!.latitude!,
        _creativeEconomy!.longitude!,
        _creativeEconomy!.name,
      );
      _webViewController.loadHtmlString(htmlContent);
    }
  }

  // Method untuk membuka WhatsApp penjual
  Future<void> _contactSellerWhatsApp(dynamic product) async {
    try {
      // Ambil nomor telepon dari creative economy
      String? phoneNumber = _creativeEconomy?.phoneNumber;

      if (phoneNumber == null || phoneNumber.isEmpty) {
        _showSnackBar('Nomor telepon penjual tidak tersedia');
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

      // Buat pesan WhatsApp
      final productName = product['name'] ?? 'Produk';
      final sellerName = _creativeEconomy?.name ?? 'Penjual';
      final message = Uri.encodeComponent(
          'Halo, saya tertarik dengan produk "$productName" dari $sellerName. '
          'Bisakah Anda memberikan informasi lebih lanjut?');

      // URL WhatsApp
      final whatsappUrl = 'https://wa.me/$cleanPhone?text=$message';
      final Uri uri = Uri.parse(whatsappUrl);

      print('Opening WhatsApp: $whatsappUrl');

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
      print('Error opening WhatsApp: $e');
      _showSnackBar('Error: ${e.toString()}');
    }
  }

// Method alternatif untuk membuka WhatsApp langsung tanpa pesan
  Future<void> _openWhatsAppDirect() async {
    try {
      String? phoneNumber = _creativeEconomy?.phoneNumber;

      if (phoneNumber == null || phoneNumber.isEmpty) {
        _showSnackBar('Nomor telepon penjual tidak tersedia');
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
              : _creativeEconomy == null
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
            'Memuat detail...',
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
            Icons.store_outlined,
            size: 64,
            color: Color(0xFF718096),
          ),
          SizedBox(height: 16),
          Text(
            'Data Tidak Ditemukan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Ekonomi kreatif yang Anda cari tidak tersedia',
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
              _buildBusinessInfo(),
              _buildMapSection(),
              _buildFeaturesSection(),
              _buildRelatedProductsSection(),
              if (_creativeEconomy!.products != null &&
                  _creativeEconomy!.products!.isNotEmpty)
                _buildProductsSection(),
              if (_creativeEconomy!.reviews != null &&
                  _creativeEconomy!.reviews!.isNotEmpty)
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
    if (_creativeEconomy!.featuredImage != null &&
        _creativeEconomy!.featuredImage!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: _creativeEconomy!.featuredImage!,
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
              Icons.store,
              size: 64,
              color: Colors.white.withOpacity(0.8),
            ),
            SizedBox(height: 16),
            Text(
              _creativeEconomy!.name,
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
      child: Row(
        children: [
          if (_creativeEconomy!.isFeatured)
            _buildBadge(
              icon: Icons.star,
              text: 'Unggulan',
              colors: [Color(0xFFED8936), Color(0xFFDD6B20)],
            ),
          if (_creativeEconomy!.isVerified) ...[
            if (_creativeEconomy!.isFeatured) SizedBox(width: 8),
            _buildBadge(
              icon: Icons.verified,
              text: 'Terverifikasi',
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
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
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
                  _creativeEconomy!.name,
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
                      _creativeEconomy!.averageRating.toStringAsFixed(1),
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
          if (_creativeEconomy!.category != null) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFF667EEA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFF667EEA).withOpacity(0.2)),
              ),
              child: Text(
                _creativeEconomy!.category!.name,
                style: TextStyle(
                  color: Color(0xFF667EEA),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          if (_creativeEconomy!.description != null &&
              _creativeEconomy!.description!.isNotEmpty) ...[
            SizedBox(height: 16),
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
              _creativeEconomy!.description!,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
                height: 1.5,
              ),
            ),
          ],
          if (_creativeEconomy!.priceRangeText != null) ...[
            SizedBox(height: 16),
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
                  _creativeEconomy!.priceRangeText!,
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
          if (_creativeEconomy!.address != null &&
              _creativeEconomy!.address!.isNotEmpty)
            _buildContactItem(
              icon: Icons.location_on,
              label: 'Alamat',
              value: _creativeEconomy!.address!,
              color: Color(0xFF667EEA),
            ),
          if (_creativeEconomy!.phoneNumber != null &&
              _creativeEconomy!.phoneNumber!.isNotEmpty)
            _buildContactItem(
              icon: Icons.phone,
              label: 'Telepon',
              value: _creativeEconomy!.phoneNumber!,
              color: Color(0xFF48BB78),
              onTap: () => _launchUrl('tel:${_creativeEconomy!.phoneNumber}'),
            ),
          if (_creativeEconomy!.phoneNumber != null &&
              _creativeEconomy!.phoneNumber!.isNotEmpty)
            _buildContactItem(
              icon: Icons.chat,
              label: 'WhatsApp',
              value: 'Chat via WhatsApp',
              color: Color(0xFF25D366),
              onTap: () => _openWhatsAppDirect(),
            ),
          if (_creativeEconomy!.email != null &&
              _creativeEconomy!.email!.isNotEmpty)
            _buildContactItem(
              icon: Icons.email,
              label: 'Email',
              value: _creativeEconomy!.email!,
              color: Color(0xFF9F7AEA),
              onTap: () => _launchUrl('mailto:${_creativeEconomy!.email}'),
            ),
          if (_creativeEconomy!.website != null &&
              _creativeEconomy!.website!.isNotEmpty)
            _buildContactItem(
              icon: Icons.language,
              label: 'Website',
              value: _creativeEconomy!.website!,
              color: Color(0xFFED8936),
              onTap: () => _launchUrl(_creativeEconomy!.website!),
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

  Widget _buildBusinessInfo() {
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
            'Informasi Bisnis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 16),
          if (_creativeEconomy!.businessHours != null &&
              _creativeEconomy!.businessHours!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.access_time,
              label: 'Jam Operasional',
              value: _creativeEconomy!.businessHours!,
            ),
          if (_creativeEconomy!.ownerName != null &&
              _creativeEconomy!.ownerName!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.person,
              label: 'Pemilik',
              value: _creativeEconomy!.ownerName!,
            ),
          if (_creativeEconomy!.establishmentYear != null)
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Tahun Berdiri',
              value: _creativeEconomy!.establishmentYear.toString(),
            ),
          if (_creativeEconomy!.employeesCount != null)
            _buildInfoRow(
              icon: Icons.group,
              label: 'Jumlah Karyawan',
              value: '${_creativeEconomy!.employeesCount} orang',
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF667EEA), size: 20),
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
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    if (_creativeEconomy!.latitude == null ||
        _creativeEconomy!.longitude == null) {
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
                        // Tampilkan dialog pilihan maps
                        MapDirectionHelper.showMapsOptions(
                          context,
                          _creativeEconomy!.latitude!,
                          _creativeEconomy!.longitude!,
                          _creativeEconomy!.name,
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
          if (_creativeEconomy!.address != null &&
              _creativeEconomy!.address!.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Color(0xFF667EEA), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _creativeEconomy!.address!,
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

  Widget _buildFeaturesSection() {
    final features = <Map<String, dynamic>>[];

    if (_creativeEconomy!.hasWorkshop) {
      features.add({
        'icon': Icons.school,
        'title': 'Workshop Tersedia',
        'description': _creativeEconomy!.workshopInformation ??
            'Menyediakan workshop untuk umum',
        'color': Color(0xFF667EEA),
      });
    }

    if (_creativeEconomy!.hasDirectSelling) {
      features.add({
        'icon': Icons.shopping_bag,
        'title': 'Penjualan Langsung',
        'description': 'Produk dapat dibeli langsung di lokasi',
        'color': Color(0xFF9F7AEA),
      });
    }

    if (_creativeEconomy!.acceptsCreditCard) {
      features.add({
        'icon': Icons.credit_card,
        'title': 'Terima Kartu Kredit',
        'description': 'Pembayaran dengan kartu kredit tersedia',
        'color': Color(0xFF48BB78),
      });
    }

    if (_creativeEconomy!.providesTraining) {
      features.add({
        'icon': Icons.cast_for_education,
        'title': 'Pelatihan',
        'description': 'Menyediakan pelatihan keterampilan',
        'color': Color(0xFFED8936),
      });
    }

    if (_creativeEconomy!.shippingAvailable) {
      features.add({
        'icon': Icons.local_shipping,
        'title': 'Pengiriman',
        'description': 'Layanan pengiriman tersedia',
        'color': Color(0xFF38B2AC),
      });
    }

    if (features.isEmpty) return SizedBox.shrink();

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
            'Fasilitas & Layanan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 16),
          ...features
              .map((feature) => _buildFeatureItem(
                    icon: feature['icon'],
                    title: feature['title'],
                    description: feature['description'],
                    color: feature['color'],
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                Text(
                  description,
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

  Widget _buildProductsSection() {
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
            'Produk',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 16),
          Text(
            _creativeEconomy!.productsDescription ??
                'Berbagai produk kreatif tersedia',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF718096),
              height: 1.5,
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
                      _creativeEconomy!.averageRating.toStringAsFixed(1),
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
            'Ulasan dari pengunjung akan ditampilkan di sini',
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

  // lib/screens/creative_economy_detail_screen.dart (tambahkan method ini)

  Widget _buildRelatedProductsSection() {
    print('=== Building Related Products Section ===');
    print('Featured Products: ${_creativeEconomy!.featuredProducts}');
    print(
        'Featured Products Length: ${_creativeEconomy!.featuredProducts?.length ?? 0}');

    if (_creativeEconomy!.featuredProducts == null ||
        _creativeEconomy!.featuredProducts!.isEmpty) {
      print('No featured products found');
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
        mainAxisSize: MainAxisSize.min, // PENTING: Prevent overflow
        children: [
          Padding(
            padding: EdgeInsets.all(16), // Kurangi dari 20 ke 16
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Produk Terkait',
                  style: TextStyle(
                    fontSize: 16, // Kurangi dari 18 ke 16
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                if (_creativeEconomy!.featuredProducts!.length > 3)
                  TextButton(
                    onPressed: () {
                      _showAllProductsModal();
                    },
                    child: Text(
                      'Lihat Semua',
                      style: TextStyle(
                        color: Color(0xFF667EEA),
                        fontSize: 12, // Kurangi dari 14 ke 12
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            height: 200, // Kurangi dari 280 ke 220
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 16, bottom: 12), // Kurangi padding
              physics: BouncingScrollPhysics(), // Tambahkan physics
              itemCount: _creativeEconomy!.featuredProducts!.length > 3
                  ? 3
                  : _creativeEconomy!.featuredProducts!.length,
              itemBuilder: (context, index) {
                final product = _creativeEconomy!.featuredProducts![index];
                print('Building product card $index: ${product['name']}');
                return _buildProductCard(product);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(dynamic product) {
    return Container(
      width: 170, // Kurangi width lagi
      margin: EdgeInsets.only(right: 12),
      child: Card(
        elevation: 3, // Kurangi elevation
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Kurangi radius
        ),
        child: InkWell(
          onTap: () => _showProductDetail(product),
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                child: Container(
                  height: 90, // Kurangi height image
                  width: double.infinity,
                  child: _buildProductImage(product),
                ),
              ),
              // Simplified Product Info
              Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Name
                    Text(
                      product['name'] ?? 'Produk Tanpa Nama',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    // Price
                    Text(
                      product['discounted_price'] != null
                          ? 'Rp ${_formatPrice(product['discounted_price'])}'
                          : 'Rp ${_formatPrice(product['price'])}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF48BB78),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tambahkan method untuk handle product image
  Widget _buildProductImage(dynamic product) {
    String? imageUrl;

    // Cek featured_image dari product
    if (product['featured_image'] != null &&
        product['featured_image'].toString().isNotEmpty) {
      final imageValue = product['featured_image'].toString();
      if (imageValue != 'null') {
        if (imageValue.startsWith('http')) {
          imageUrl = imageValue;
        } else {
          // Tambahkan base URL jika path relatif
          String cleanPath = imageValue;
          if (cleanPath.startsWith('/')) {
            cleanPath = cleanPath.substring(1);
          }
          // PERBAIKAN: Pastikan path storage benar
          if (cleanPath.startsWith('storage/')) {
            imageUrl = 'http://10.0.2.2:8000/$cleanPath';
          } else {
            imageUrl = 'http://10.0.2.2:8000/storage/$cleanPath';
          }
        }
      }
    }

    print('Product ${product['name']} image URL: $imageUrl');

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildProductImagePlaceholder(),
        errorWidget: (context, url, error) {
          print('Error loading product image: $error');
          print('Failed URL: $url');
          return _buildProductImagePlaceholder();
        },
        // Tambahkan headers untuk debugging
        httpHeaders: {
          'User-Agent': 'Flutter App',
        },
      );
    } else {
      return _buildProductImagePlaceholder();
    }
  }

  Widget _buildProductImagePlaceholder() {
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
            Icons.shopping_bag,
            size: 32,
            color: Colors.white.withOpacity(0.8),
          ),
          SizedBox(height: 8),
          Text(
            'Gambar Produk',
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

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  void _showProductDetail(dynamic product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildProductDetailModal(product),
    );
  }

  Widget _buildProductDetailModal(dynamic product) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detail Produk',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFE2E8F0)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildProductImage(product),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Product Name
                  Text(
                    product['name'] ?? 'Produk Tanpa Nama',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  SizedBox(height: 8),
                  // SKU
                  if (product['sku'] != null)
                    Text(
                      'SKU: ${product['sku']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF718096),
                      ),
                    ),
                  SizedBox(height: 16),
                  // Price
                  Row(
                    children: [
                      if (product['discounted_price'] != null) ...[
                        Text(
                          'Rp ${_formatPrice(product['discounted_price'])}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF48BB78),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Rp ${_formatPrice(product['price'])}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF718096),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'Rp ${_formatPrice(product['price'])}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF48BB78),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 16),
                  // Description
                  if (product['description'] != null) ...[
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
                      product['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF718096),
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                  // Product Details
                  _buildProductDetailRow('Material', product['material']),
                  _buildProductDetailRow('Ukuran', product['size']),
                  _buildProductDetailRow('Berat', product['weight']),
                  _buildProductDetailRow('Warna', product['colors']),
                  _buildProductDetailRow('Stok', product['stock']?.toString()),
                  _buildProductDetailRow(
                      'Waktu Produksi',
                      product['production_time'] != null
                          ? '${product['production_time']} hari'
                          : null),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Action Buttons
          // Action Buttons - GANTI BAGIAN INI
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Hubungi Penjual via WhatsApp
                      Navigator.pop(context);
                      _contactSellerWhatsApp(product);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color(0xFF25D366), // WhatsApp green color
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Hubungi Penjual',
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
                SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF667EEA)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Add to wishlist functionality
                      _showSnackBar('Produk ditambahkan ke wishlist');
                    },
                    icon: Icon(
                      Icons.favorite_border,
                      color: Color(0xFF667EEA),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF718096),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF2D3748),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllProductsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Semua Produk',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _creativeEconomy!.featuredProducts!.length,
                itemBuilder: (context, index) {
                  final product = _creativeEconomy!.featuredProducts![index];
                  return _buildProductCard(product);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFF48BB78),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
