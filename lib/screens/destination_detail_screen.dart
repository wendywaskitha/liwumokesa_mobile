// lib/screens/destination_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/destination.dart';
import '../providers/destination_provider.dart';
import '../widgets/destination_detail/destination_header.dart';
import '../widgets/destination_detail/destination_info.dart';
import '../widgets/destination_detail/destination_description.dart';
import '../widgets/destination_detail/destination_facilities.dart';
import '../widgets/destination_detail/destination_accommodations.dart';
import '../widgets/destination_detail/destination_culinaries.dart';
import '../widgets/destination_detail/destination_transportations.dart';
import '../widgets/destination_detail/destination_creative_economies.dart';
import '../widgets/destination_detail/destination_nearby.dart';
import '../widgets/destination_detail/destination_gallery.dart';
import '../widgets/destination_detail/destination_reviews.dart';

class DestinationDetailScreen extends StatefulWidget {
  final int destinationId;

  const DestinationDetailScreen({
    Key? key,
    required this.destinationId,
  }) : super(key: key);

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  Destination? destination;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadDestinationDetail();
  }

  Future<void> _loadDestinationDetail() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final provider = Provider.of<DestinationProvider>(context, listen: false);
      
      print('Loading destination detail for ID: ${widget.destinationId}');
      final dest = await provider.getDestination(widget.destinationId);
      
      if (dest != null) {
        destination = dest;
        print('Successfully loaded destination: ${dest.name}');
      } else {
        error = 'Destinasi tidak ditemukan';
      }
    } catch (e) {
      print('Error in _loadDestinationDetail: $e');
      error = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF667EEA).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFF667EEA)),
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Memuat detail destinasi...',
                style: TextStyle(
                  color: Color(0xFF667EEA),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(
          child: Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(24),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade400,
                  ),
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
                  error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadDestinationDetail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF667EEA),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
        ),
      );
    }

    if (destination == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Destinasi Tidak Ditemukan'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(
          child: Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(24),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_off,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 16),
                Text(
                  'Destinasi Tidak Ditemukan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Destinasi yang Anda cari tidak tersedia',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header dengan gambar
          DestinationHeader(destination: destination!),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DestinationInfo(destination: destination!),
                  DestinationDescription(destination: destination!),
                  DestinationFacilities(destination: destination!),
                  DestinationGallery(destination: destination!),
                  DestinationAccommodations(destination: destination!),
                  DestinationCulinaries(destination: destination!),
                  DestinationTransportations(destination: destination!),
                  DestinationCreativeEconomies(destination: destination!),
                  DestinationReviews(destination: destination!),
                  DestinationNearby(destinationId: widget.destinationId),
                  SizedBox(height: 100), // Space for floating button
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fitur navigasi akan segera hadir!'),
              backgroundColor: Color(0xFF667EEA),
            ),
          );
        },
        backgroundColor: Color(0xFF667EEA),
        icon: Icon(Icons.directions, color: Colors.white),
        label: Text(
          'Kunjungi',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
