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
          '/creative-economy': (context) => const CreativeEconomyScreen(),
          '/creative-economy-detail': (context) {
            final id = ModalRoute.of(context)!.settings.arguments as int;
            return CreativeEconomyDetailScreen(id: id);
          },
        },
      ),
    );
  }
}
