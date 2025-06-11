import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/widget/build_shimmerEffect.dart';

class BuildDailyWind extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  const BuildDailyWind({super.key, required this.weatherData});

  Future<Map<String, dynamic>> loadWindData() async {
    try {
      final data = weatherData;

      final now = DateFormat("yyyy-MM-ddTHH:00").format(DateTime.now());
      final hourlyTime = List<String>.from(data["hourly"]["time"]);
      final indexNow = hourlyTime.indexOf(now);

      final windDir = data["hourly"]["wind_direction_10m"][indexNow] as int;
      final windSpeed = data["hourly"]["wind_speed_10m"][indexNow] as double;

      final dirText = getWindDirection(windDir);
      final speedText = getWindDescription(windSpeed.toInt());

      return {
        "windDir": windDir,
        "windSpeed": windSpeed,
        "dirText": dirText,
        "speedText": speedText
      };
    } catch (e) {
      print("Error loading wind data: $e");
      return {};
    }
  }

  String getWindDirection(int degree) {
    if (degree < 45) return "Utara";
    if (degree < 90) return "Timur Laut";
    if (degree < 135) return "Timur";
    if (degree < 180) return "Tenggara";
    if (degree < 225) return "Selatan";
    if (degree < 270) return "Barat Daya";
    if (degree < 315) return "Barat";
    return "Barat Laut";
  }

  String getWindDescription(int speed) {
    if (speed < 1) return "sangat lemah";
    if (speed < 5) return "lemah";
    if (speed < 10) return "sedang";
    if (speed < 15) return "kuat";
    if (speed < 20) return "sangat kuat";
    return "ekstrem";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadWindData(),
      builder: (context, snapshot) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(40, 58, 58, 58),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.air,
                          color: Colors.white.withOpacity(0.8),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Angin',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Data utama
                  // Value Display
                  if (snapshot.connectionState == ConnectionState.waiting)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          shimmerBox(width: MediaQuery.of(context).size.width * 0.7, height: 20),
                          const SizedBox(height: 16),
                          shimmerBox(width: double.infinity, height: 60),
                        ],
                      ),
                    )
                  else if (snapshot.hasError)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Gagal memuat data hujan',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  else if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: snapshot.data!["windSpeed"].toString(),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: ' km/h | ${snapshot.data!["windDir"]}°',
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
                    // Keterangan deskriptif
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Kecepatan angin ${snapshot.data!["speedText"]} dari arah ${snapshot.data!["dirText"]}.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
