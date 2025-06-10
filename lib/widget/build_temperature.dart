import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/widget/build_shimmerEffect.dart';

class BuildTemperature extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  const BuildTemperature({super.key, required this.weatherData});

  Future<int> _getCurrentTemperature() async {
    try {
      final jsonData = weatherData;

      final now = DateFormat("yyyy-MM-ddTHH:00").format(DateTime.now());
      final List<dynamic> hourlyTime = jsonData["hourly"]["time"];
      final List<dynamic> temperatures = jsonData["hourly"]["temperature_2m"];

      final int currentIndex = hourlyTime.indexOf(now);
      if (currentIndex == -1) {
        throw Exception("Waktu saat ini ($now) tidak ditemukan dalam data hourly.");
      }

      final dynamic temperature = temperatures[currentIndex];
      return temperature.toInt();
    } catch (e) {
      debugPrint('Gagal load suhu: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _getCurrentTemperature(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return shimmerBox(width: 120, height: 120);
        } else if (snapshot.hasData) {
          return Container(
            margin: const EdgeInsets.only(left: 40),
            child: Text(
              '${snapshot.data}°',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 80,
                fontWeight: FontWeight.w200,
              ),
            ),
          );
        } else {
          return const Padding(
            padding: EdgeInsets.only(left: 40),
            child: Text(
              'Error mendapatkan suhu',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }
      },
    );
  }
}
