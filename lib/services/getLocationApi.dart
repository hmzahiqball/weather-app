import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationService {
  static Future<({double latitude, double longitude, String city})> getLocation() async {
    try {
      final position = await _getCurrentPosition();
      final city = await _getCityFromCoordinates(position.latitude, position.longitude);

      return (latitude: position.latitude, longitude: position.longitude, city: city);
    } catch (e) {
      debugPrint("📍 GPS gagal, fallback ke IP Geolocation");

      try {
        final response = await http.get(Uri.parse('http://ip-api.com/json/'));
        final data = json.decode(response.body);
        final double latitude = data['lat'];
        final double longitude = data['lon'];
        final city = await _getCityFromCoordinates(latitude, longitude);

        return (latitude: latitude, longitude: longitude, city: city);
      } catch (e) {
        debugPrint("🌐 IP Geolocation gagal juga: $e");
        return (latitude: 0.0, longitude: 0.0, city: 'Unknown');
      }
    }
  }

  static Future<Position> _getCurrentPosition() async {
    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  static Future<String> _getCityFromCoordinates(double lat, double lon) async {
    try {
      final url =
          'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lon&localityLanguage=id';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['city'] ?? 'Kota tidak ditemukan';
      } else {
        return 'Gagal ambil kota';
      }
    } catch (e) {
      debugPrint('❌ Error saat ambil kota dari koordinat: $e');
      return 'Error';
    }
  }
}
