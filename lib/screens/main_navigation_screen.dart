// lib/screens/main_navigation_screen.dart
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'home_screen.dart';
import 'destination_screen.dart';
import 'culinary_screen.dart';
import 'accommodation_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    DestinationScreen(),
    CulinaryScreen(),
    AccommodationScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react,
        items: [
          TabItem(icon: Icons.home, title: 'Beranda'),
          TabItem(icon: Icons.explore, title: 'Destinasi'),
          TabItem(icon: Icons.restaurant_menu, title: 'Kuliner'),
          TabItem(icon: Icons.hotel, title: 'Akomodasi'),
          TabItem(icon: Icons.person, title: 'Profile'),
        ],
        initialActiveIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Color(0xFF667EEA),
        activeColor: Colors.white,
        color: Colors.white70,
      ),
    );
  }
}
