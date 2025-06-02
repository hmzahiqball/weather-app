import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class BuildHeader extends StatelessWidget {
  Future<String> _loadLocation() async {
    try {
      Position position = await _determinePosition();
      return await getCityFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      print("GPS gagal, fallback ke IP Geolocation");
      try {
        final ipRes = await http.get(Uri.parse('http://ip-api.com/json/'));
        final ipData = json.decode(ipRes.body);
        double lat = ipData['lat'];
        double lon = ipData['lon'];
        return await getCityFromCoordinates(lat, lon);
      } catch (e) {
        print("IP Geolocation gagal juga: $e");
        return "Unknown";
      }
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<String> getCityFromCoordinates(double lat, double lon) async {
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
      print('Error getCityFromCoordinates: $e');
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
          FutureBuilder(
            future: _loadLocation(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  '${snapshot.data}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                );
              } else {
                return const Text('');
              }
            },
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.menu, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
