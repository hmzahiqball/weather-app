import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

class BuildAirquality extends StatelessWidget {
  Future<Map<String, dynamic>> loadAllWeatherData() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/dummy.json',
      );
      final data = json.decode(response);

      // ambil waktu lokal sekarang dalam format yang cocok dengan hourly time
      final now = DateFormat("yyyy-MM-ddTHH:00").format(DateTime.now());
      final hourlyTimes = data["hourly"]["time"] as List;
      final indexNow = hourlyTimes.indexOf(now);

      // ambil data hourly
      final airQuality = data["hourly"]["us_aqi_pm2_5"][indexNow];

      return {
        "airQuality": airQuality,
      };
    } catch (e) {
      print(e);
      return {};
    }
  }

  String getAirQualityDescription(int airQuality) {
    if (airQuality < 51) {
      return "Kualitas Udara Baik";
    } else if (airQuality < 101) {
      return "Kualitas Udara Sedang";
    } else if (airQuality < 151) {
      return "Kualitas Udara Tidak Sehat";
    } else if (airQuality < 201) {
      return "Kualitas Udara Sangat Tidak Sehat";
    } else {
      return "Kualitas Udara Berbahaya";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadAllWeatherData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading rain data',
              style: TextStyle(color: Colors.white),
            ),
          );
        } else {
          final airQuality = snapshot.data?["airQuality"] ?? 0;
          return ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(40, 58, 58, 58),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Icon(
                              airQuality <= 50 ? Icons.water_drop : airQuality <= 100 ? Icons.water_drop_outlined : Icons.warning,
                              color: Colors.white.withOpacity(0.8),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Kualitas Udara',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${airQuality}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 24,
                              ),
                            ),
                            TextSpan(
                              text: 'μg/m³',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        getAirQualityDescription(airQuality),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
