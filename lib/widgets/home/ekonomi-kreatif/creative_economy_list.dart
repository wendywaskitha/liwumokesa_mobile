// lib/widgets/home/ekonomi-kreatif/creative_economy_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/creative_economy_provider.dart';
import 'creative_economy_card.dart';

class CreativeEconomyList extends StatefulWidget {
  final String? search;
  final int? categoryId;
  final int? districtId;

  const CreativeEconomyList({
    Key? key,
    this.search,
    this.categoryId,
    this.districtId,
  }) : super(key: key);

  @override
  State<CreativeEconomyList> createState() => _CreativeEconomyListState();
}

class _CreativeEconomyListState extends State<CreativeEconomyList> {
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
      final provider = context.read<CreativeEconomyProvider>();
      if (!provider.isLoadingMore && provider.hasMoreData) {
        provider.loadMoreCreativeEconomies(
          search: widget.search,
          categoryId: widget.categoryId,
          districtId: widget.districtId,
        );
      }
    }
  }

  void _loadData() {
    context.read<CreativeEconomyProvider>().loadCreativeEconomies(
      search: widget.search,
      categoryId: widget.categoryId,
      districtId: widget.districtId,
      refresh: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreativeEconomyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.creativeEconomies.isEmpty) {
          return _buildLoadingState();
        }

        if (provider.error != null && provider.creativeEconomies.isEmpty) {
          return _buildErrorState(provider.error!);
        }

        if (provider.creativeEconomies.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.only(top: 16, bottom: 100),
            itemCount: provider.creativeEconomies.length + 
                      (provider.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == provider.creativeEconomies.length) {
                return Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
                    ),
                  ),
                );
              }

              final creativeEconomy = provider.creativeEconomies[index];
              return CreativeEconomyCard(
                creativeEconomy: creativeEconomy,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/creative-economy-detail',
                    arguments: creativeEconomy.id,
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
            'Memuat ekonomi kreatif...',
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
                Icons.store_outlined,
                size: 48,
                color: Color(0xFF718096),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Belum Ada Ekonomi Kreatif',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Belum ada ekonomi kreatif yang tersedia saat ini',
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
