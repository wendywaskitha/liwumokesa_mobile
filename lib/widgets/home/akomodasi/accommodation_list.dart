// lib/widgets/home/akomodasi/accommodation_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/accommodation_provider.dart';
import '../../../widgets/home/akomodasi/accommodation_card.dart';

class AccommodationList extends StatefulWidget {
  final String? search;
  final String? type;
  final int? districtId;
  final double? minPrice;
  final double? maxPrice;
  final List<String>? facilities;

  const AccommodationList({
    Key? key,
    this.search,
    this.type,
    this.districtId,
    this.minPrice,
    this.maxPrice,
    this.facilities,
  }) : super(key: key);

  @override
  State<AccommodationList> createState() => _AccommodationListState();
}

class _AccommodationListState extends State<AccommodationList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<AccommodationProvider>();
      if (!provider.isLoadingMore && provider.hasMoreData) {
        provider.loadMoreAccommodations(
          search: widget.search,
          type: widget.type,
          districtId: widget.districtId,
          minPrice: widget.minPrice,
          maxPrice: widget.maxPrice,
          facilities: widget.facilities,
        );
      }
    }
  }

  void _loadData() {
    context.read<AccommodationProvider>().loadAccommodations(
      search: widget.search,
      type: widget.type,
      districtId: widget.districtId,
      minPrice: widget.minPrice,
      maxPrice: widget.maxPrice,
      facilities: widget.facilities,
      refresh: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccommodationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.accommodations.isEmpty) {
          return _buildLoadingState();
        }

        if (provider.error != null && provider.accommodations.isEmpty) {
          return _buildErrorState(provider.error!);
        }

        if (provider.accommodations.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.only(top: 16, bottom: 100),
            itemCount: provider.accommodations.length + 
                      (provider.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == provider.accommodations.length) {
                return Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
                    ),
                  ),
                );
              }

              final accommodation = provider.accommodations[index];
              return AccommodationCard(
                accommodation: accommodation,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/accommodation-detail',
                    arguments: accommodation.id,
                  );
                },
              );
            },
          ),
        );
      },
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
            'Memuat akomodasi...',
            style: TextStyle(
              color: Color(0xFF718096),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFFED7D7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Color(0xFFE53E3E),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF718096),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadData,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFEDF2F7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.hotel_outlined,
                size: 48,
                color: Color(0xFF718096),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Tidak Ada Akomodasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tidak ada akomodasi yang sesuai dengan kriteria pencarian',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF718096),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
