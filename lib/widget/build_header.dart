import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class BuildHeader extends StatelessWidget {
  Future<String> _loadLocation() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/dummy2.json',
      );
      final data = json.decode(response);

      double lat = -6.9614;
      double lon = 107.5875;
      final result = getCityFromCoordinates(
        // data['latitude'],
        lat,
        // data['longitude'],
        lon
      );
      return result;
    } catch (e) {
      print(e);
      return "Unknown";
    }
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
