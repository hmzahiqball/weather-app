import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BuildHeader extends StatelessWidget {
  Future<Map<String, double>> _loadLocation() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/dummy2.json',
      );
      final data = json.decode(response);
      // List<Placemark> placemarks = await placemarkFromCoordinates(52.2165157, 6.9437819);
      return {'latitude': data['latitude'], 'longitude': data['longitude']};
    } catch (e) {
      print(e);
      return {'latitude': 0.0, 'longitude': 0.0};
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
                  '(${snapshot.data!['latitude']}, ${snapshot.data!['longitude']})',
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
