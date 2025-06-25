// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/destination_provider.dart';
import 'providers/creative_economy_provider.dart';
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

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DestinationProvider()),
        ChangeNotifierProvider(create: (_) => CreativeEconomyProvider()),
        ChangeNotifierProvider(create: (_) => AccommodationProvider()),
      ],
      child: MaterialApp(
        title: 'Visit Liwu Mokesa',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/login': (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),
          '/destinations': (context) => DestinationScreen(),
          '/destination-detail': (context) {
            final destinationId =
                ModalRoute.of(context)!.settings.arguments as int;
            return DestinationDetailScreen(destinationId: destinationId);
          },
          '/creative-economy': (context) => const CreativeEconomyScreen(),
          '/creative-economy-detail': (context) {
            final id = ModalRoute.of(context)!.settings.arguments as int;
            return CreativeEconomyDetailScreen(id: id);
          },
          '/accommodation': (context) =>
              const AccommodationScreen(), // Add this
          '/accommodation-detail': (context) {
            // Add this
            final id = ModalRoute.of(context)!.settings.arguments as int;
            return AccommodationDetailScreen(id: id);
          },
        },
      ),
    );
  }
}
