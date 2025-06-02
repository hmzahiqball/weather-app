import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class BuildTemperature extends StatelessWidget {
  Future<int> _loadTemperature() async {
    final String response = await rootBundle.loadString('assets/json/dummy2.json');
    final data = json.decode(response);

    // ambil waktu lokal sekarang dalam format yang cocok dengan hourly time
    final now = DateFormat("yyyy-MM-ddTHH:00").format(DateTime.now());

    final hourlyTimes = data["hourly"]["time"] as List;
    final indexNow = hourlyTimes.indexOf(now);

    if (indexNow == -1) {
      throw Exception("Data jam sekarang (${now}) gak ketemu di hourly");
    }

    final temperature = data["hourly"]["temperature_2m"][indexNow];

    return temperature.toInt();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _loadTemperature(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
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
          return const Text('Error ngambil data suhu haha');
        }
      },
    );
  }
}
