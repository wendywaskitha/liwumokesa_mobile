// lib/widgets/home/search_section.dart
import 'package:flutter/material.dart';

class SearchSection extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;

  const SearchSection({
    Key? key,
    required this.controller,
    required this.onSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Temukan destinasi impianmu ✨',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF667EEA).withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Mau ke mana hari ini?',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Container(
                  margin: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF667EEA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.search, color: Color(0xFF667EEA)),
                ),
                suffixIcon: Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF667EEA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () => onSearch(controller.text),
                    icon: Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              onSubmitted: onSearch,
            ),
          ),
        ],
      ),
    );
  }
}
