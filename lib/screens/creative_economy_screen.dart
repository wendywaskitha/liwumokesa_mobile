// lib/screens/creative_economy_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/creative_economy_provider.dart';
import '../widgets/home/ekonomi-kreatif/creative_economy_list.dart';

class CreativeEconomyScreen extends StatefulWidget {
  const CreativeEconomyScreen({Key? key}) : super(key: key);

  @override
  State<CreativeEconomyScreen> createState() => _CreativeEconomyScreenState();
}

class _CreativeEconomyScreenState extends State<CreativeEconomyScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _currentSearch;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CreativeEconomyProvider>().loadCreativeEconomies(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildSearchSection(),
          ),
          SliverFillRemaining(
            child: CreativeEconomyList(
              search: _currentSearch,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF667EEA), Color(0xFF764BA2), Color(0xFF6B73FF)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Ekonomi Kreatif',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Jelajahi produk kreatif lokal terbaik',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Container(
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
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cari ekonomi kreatif...',
            prefixIcon: Icon(Icons.search, color: Color(0xFF667EEA)),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _currentSearch = null;
                      });
                    },
                    icon: Icon(Icons.clear, color: Color(0xFF718096)),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(16),
          ),
          onSubmitted: (value) {
            setState(() {
              _currentSearch = value.isEmpty ? null : value;
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
