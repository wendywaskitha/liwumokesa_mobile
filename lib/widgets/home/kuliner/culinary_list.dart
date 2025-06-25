// lib/widgets/home/kuliner/culinary_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/culinary_provider.dart';
import 'culinary_card.dart';
import '../../../models/culinary.dart';

class CulinaryList extends StatefulWidget {
  final String? title;
  final bool showRecommendedOnly;
  final String? type;

  const CulinaryList({
    Key? key,
    this.title,
    this.showRecommendedOnly = false,
    this.type,
  }) : super(key: key);

  @override
  State<CulinaryList> createState() => _CulinaryListState();
}

class _CulinaryListState extends State<CulinaryList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCulinaries();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      final provider = Provider.of<CulinaryProvider>(context, listen: false);
      if (!provider.isLoading && provider.hasMore) {
        _loadMoreCulinaries();
      }
    }
  }

  void _loadCulinaries() {
    final provider = Provider.of<CulinaryProvider>(context, listen: false);
    provider.loadCulinaries(
      refresh: true,
      type: widget.type,
      isRecommended: widget.showRecommendedOnly ? true : null,
    );
  }

  void _loadMoreCulinaries() {
    final provider = Provider.of<CulinaryProvider>(context, listen: false);
    provider.loadCulinaries(
      refresh: false,
      type: widget.type,
      isRecommended: widget.showRecommendedOnly ? true : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CulinaryProvider>(
      builder: (context, culinaryProvider, child) {
        return _buildCulinaryContent(culinaryProvider);
      },
    );
  }

  Widget _buildCulinaryContent(CulinaryProvider provider) {
    // Loading state untuk pertama kali
    if (provider.culinaries.isEmpty && provider.isLoading) {
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
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.orange),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Memuat kuliner...',
                  style: TextStyle(
                    color: Colors.orange,
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
    if (provider.error != null && provider.culinaries.isEmpty) {
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
                    provider.error!,
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
                  onPressed: _loadCulinaries,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
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
    if (provider.culinaries.isEmpty && !provider.isLoading) {
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
                    Icons.restaurant_menu,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Belum ada kuliner',
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
                  onPressed: _loadCulinaries,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
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
            if (index == provider.culinaries.length) {
              if (provider.hasMore && provider.isLoading) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.2),
                    ),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.orange),
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            }

            final culinary = provider.culinaries[index];
            return CulinaryCard(
              culinary: culinary,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/culinary-detail',
                  arguments: culinary.id,
                );
              },
            );
          },
          childCount: provider.culinaries.length +
              (provider.hasMore && provider.isLoading ? 1 : 0),
        ),
      ),
    );
  }
}
