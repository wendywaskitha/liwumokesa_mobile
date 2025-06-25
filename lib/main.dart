// lib/main.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/destination_provider.dart';
import 'providers/creative_economy_provider.dart';
import 'screens/culinary_detail_screen.dart';
import 'screens/culinary_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/creative_economy_screen.dart';
import 'screens/creative_economy_detail_screen.dart';
import 'providers/accommodation_provider.dart';
import 'screens/accommodation_screen.dart';
import 'screens/accommodation_detail_screen.dart';
import 'screens/destination_screen.dart';
import 'screens/destination_detail_screen.dart';
import 'providers/culinary_provider.dart';

void main() {
  // Set global error handler untuk CachedNetworkImage
  CachedNetworkImage.logLevel = CacheManagerLogLevel.debug;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DestinationProvider()),
        ChangeNotifierProvider(create: (_) => CulinaryProvider()),
        ChangeNotifierProvider(create: (_) => CreativeEconomyProvider()),
        ChangeNotifierProvider(create: (_) => AccommodationProvider()),
      ],
      child: MaterialApp(
        title: 'Visit Liwu Mokesa',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/login': (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),
          
          // Destinations
          '/destinations': (context) => DestinationScreen(),
          '/destination-detail': (context) {
            final destinationId =
                ModalRoute.of(context)!.settings.arguments as int;
            return DestinationDetailScreen(destinationId: destinationId);
          },
          
          // Culinaries
          '/culinaries': (context) => CulinaryScreen(),
          '/culinary-detail': (context) {
            final culinaryId =
                ModalRoute.of(context)!.settings.arguments as int;
            return CulinaryDetailScreen(culinaryId: culinaryId);
          },
          
          // Creative Economies - Perbaiki route name
          '/creative-economies': (context) => const CreativeEconomyScreen(), // Ubah dari '/creative-economy'
          '/creative-economy-detail': (context) {
            final id = ModalRoute.of(context)!.settings.arguments as int;
            return CreativeEconomyDetailScreen(id: id);
          },
          
          // Accommodations - Perbaiki route name
          '/accommodations': (context) => const AccommodationScreen(), // Ubah dari '/accommodation'
          '/accommodation-detail': (context) {
            final id = ModalRoute.of(context)!.settings.arguments as int;
            return AccommodationDetailScreen(id: id);
          },
        },
      ),
    );
  }
}
