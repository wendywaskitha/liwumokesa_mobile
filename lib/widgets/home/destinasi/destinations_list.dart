// lib/widgets/home/destinasi/destinations_list.dart
import 'package:flutter/material.dart';
import '../../../models/destination.dart';
import '../../../providers/destination_provider.dart';
import 'destination_card.dart';

class DestinationsList extends StatefulWidget {
  final DestinationProvider destinationProvider;
  final String? title;
  final bool showFeaturedOnly;
  final int? categoryId;

  const DestinationsList({
    Key? key,
    required this.destinationProvider,
    this.title,
    this.showFeaturedOnly = false,
    this.categoryId,
  }) : super(key: key);

  @override
  State<DestinationsList> createState() => _DestinationsListState();
}

class _DestinationsListState extends State<DestinationsList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!widget.destinationProvider.isLoading && widget.destinationProvider.hasMore) {
        _loadMoreDestinations();
      }
    }
  }

  void _loadMoreDestinations() {
    widget.destinationProvider.loadDestinations(
      refresh: false,
      featured: widget.showFeaturedOnly ? true : null,
      categoryId: widget.categoryId,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Loading state untuk pertama kali
    if (widget.destinationProvider.destinations.isEmpty && widget.destinationProvider.isLoading) {
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
                    valueColor: AlwaysStoppedAnimation(Color(0xFF667EEA)),
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

    // Error state
    if (widget.destinationProvider.error != null && widget.destinationProvider.destinations.isEmpty) {
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
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    widget.destinationProvider.error!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    widget.destinationProvider.loadDestinations(refresh: true);
                  },
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
        ),
      );
    }

    // Empty state
    if (widget.destinationProvider.destinations.isEmpty && !widget.destinationProvider.isLoading) {
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
                  child: Icon(
                    Icons.explore_off,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
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
                    widget.destinationProvider.loadDestinations(refresh: true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF667EEA),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Refresh',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Success state dengan data
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
            // Loading indicator di akhir list
            if (index == widget.destinationProvider.destinations.length) {
              if (widget.destinationProvider.hasMore && widget.destinationProvider.isLoading) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Color(0xFF667EEA).withOpacity(0.2),
                    ),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFF667EEA)),
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            }

            final destination = widget.destinationProvider.destinations[index];
            return DestinationCard(
              destination: destination,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/destination-detail',
                  arguments: destination.id,
                );
              },
            );
          },
          childCount: widget.destinationProvider.destinations.length +
              (widget.destinationProvider.hasMore && widget.destinationProvider.isLoading ? 1 : 0),
        ),
      ),
    );
  }
}
