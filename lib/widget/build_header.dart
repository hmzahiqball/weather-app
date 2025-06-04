import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class BuildHeader extends StatelessWidget {
  const BuildHeader({super.key});

  Future<String> _fetchLocation() async {
    try {
      final position = await _getCurrentPosition();
      return await _getCityFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      debugPrint("GPS gagal, fallback ke IP Geolocation");

      try {
        final response = await http.get(Uri.parse('http://ip-api.com/json/'));
        final data = json.decode(response.body);
        final double latitude = data['lat'];
        final double longitude = data['lon'];

        return await _getCityFromCoordinates(latitude, longitude);
      } catch (e) {
        debugPrint("IP Geolocation gagal juga: $e");
        return "Unknown";
      }
    }
  }

  Future<Position> _getCurrentPosition() async {
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

  Future<String> _getCityFromCoordinates(double lat, double lon) async {
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
      debugPrint('Error saat ambil kota dari koordinat: $e');
      return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FutureBuilder<String>(
            future: _fetchLocation(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text(
                  'Memuat lokasi...',
                  style: TextStyle(color: Colors.white),
                );
              } else if (snapshot.hasData) {
                return Text(
                  snapshot.data!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                );
              } else {
                return const Text(
                  'Lokasi tidak ditemukan',
                  style: TextStyle(color: Colors.white),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
