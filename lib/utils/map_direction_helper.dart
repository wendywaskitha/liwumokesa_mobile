// lib/utils/map_direction_helper.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class MapDirectionHelper {
  /// Membuka aplikasi Google Maps dengan petunjuk arah ke koordinat yang diberikan
  static Future<void> openGoogleMapsDirection(double lat, double lng) async {
    try {
      late final String url;
      
      if (Platform.isAndroid) {
        // Android: gunakan skema google.navigation untuk navigasi langsung
        url = 'google.navigation:q=$lat,$lng&mode=d';
      } else if (Platform.isIOS) {
        // iOS: gunakan skema comgooglemaps
        url = 'comgooglemaps://?daddr=$lat,$lng&directionsmode=driving';
      } else {
        // Fallback: buka Google Maps web
        url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';
      }

      final Uri uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback ke web Google Maps jika aplikasi tidak tersedia
        final fallbackUrl = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';
        final fallbackUri = Uri.parse(fallbackUrl);
        if (await canLaunchUrl(fallbackUri)) {
          await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Tidak dapat membuka aplikasi maps');
        }
      }
    } catch (e) {
      throw Exception('Error membuka petunjuk arah: ${e.toString()}');
    }
  }

  /// Membuka lokasi di Google Maps (view saja)
  static Future<void> openGoogleMapsLocation(double lat, double lng, String name) async {
    try {
      late final String url;
      final encodedName = Uri.encodeComponent(name);
      
      if (Platform.isAndroid) {
        url = 'geo:$lat,$lng?q=$lat,$lng($encodedName)';
      } else if (Platform.isIOS) {
        url = 'comgooglemaps://?center=$lat,$lng&q=$lat,$lng';
      } else {
        url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
      }

      final Uri uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        final fallbackUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
        final fallbackUri = Uri.parse(fallbackUrl);
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      throw Exception('Error membuka lokasi: ${e.toString()}');
    }
  }

  /// Membuka Apple Maps (khusus iOS)
  static Future<void> openAppleMaps(double lat, double lng, String name) async {
    if (!Platform.isIOS) {
      throw Exception('Apple Maps hanya tersedia di iOS');
    }

    try {
      final encodedName = Uri.encodeComponent(name);
      final url = 'http://maps.apple.com/?daddr=$lat,$lng&dirflg=d&t=m';
      final Uri uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Tidak dapat membuka Apple Maps');
      }
    } catch (e) {
      throw Exception('Error membuka Apple Maps: ${e.toString()}');
    }
  }

  /// Membuka Waze (jika tersedia)
  static Future<void> openWaze(double lat, double lng) async {
    try {
      final url = 'waze://?ll=$lat,$lng&navigate=yes';
      final Uri uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback ke web Waze
        final fallbackUrl = 'https://waze.com/ul?ll=$lat,$lng&navigate=yes';
        final fallbackUri = Uri.parse(fallbackUrl);
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      throw Exception('Error membuka Waze: ${e.toString()}');
    }
  }

  /// Menampilkan dialog pilihan aplikasi maps
  static Future<void> showMapsOptions(
    BuildContext context,
    double lat,
    double lng,
    String name,
  ) async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Pilih Aplikasi Maps',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              SizedBox(height: 20),
              _buildMapOption(
                context,
                icon: Icons.navigation,
                title: 'Google Maps (Navigasi)',
                subtitle: 'Petunjuk arah langsung',
                color: Color(0xFF4285F4),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await openGoogleMapsDirection(lat, lng);
                  } catch (e) {
                    _showError(context, e.toString());
                  }
                },
              ),
              _buildMapOption(
                context,
                icon: Icons.location_on,
                title: 'Google Maps (Lokasi)',
                subtitle: 'Lihat lokasi di peta',
                color: Color(0xFF34A853),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await openGoogleMapsLocation(lat, lng, name);
                  } catch (e) {
                    _showError(context, e.toString());
                  }
                },
              ),
              if (Platform.isIOS)
                _buildMapOption(
                  context,
                  icon: Icons.map,
                  title: 'Apple Maps',
                  subtitle: 'Navigasi dengan Apple Maps',
                  color: Color(0xFF007AFF),
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      await openAppleMaps(lat, lng, name);
                    } catch (e) {
                      _showError(context, e.toString());
                    }
                  },
                ),
              _buildMapOption(
                context,
                icon: Icons.alt_route,
                title: 'Waze',
                subtitle: 'Navigasi dengan Waze',
                color: Color(0xFF00D4FF),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await openWaze(lat, lng);
                  } catch (e) {
                    _showError(context, e.toString());
                  }
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildMapOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF718096),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFFE53E3E),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
