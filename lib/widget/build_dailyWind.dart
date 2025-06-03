import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

class BuildDailyWind extends StatelessWidget {
  Future<Map<String, dynamic>> loadAllWeatherData() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/dummy2.json',
      );
      final data = json.decode(response);

      // ambil waktu lokal sekarang dalam format yang cocok dengan hourly time
      final now = DateFormat("yyyy-MM-ddTHH:00").format(DateTime.now());
      final hourlyTimes = data["hourly"]["time"] as List;
      final indexNow = hourlyTimes.indexOf(now);

      // ambil data hourly
      final windDirection = data["hourly"]["wind_direction_10m"][indexNow];
      final windSpeed = data["hourly"]["wind_speed_10m"][indexNow];

      return {
        "windDirection": windDirection,
        "windSpeed": windSpeed,
      };
    } catch (e) {
      print(e);
      return {};
    }
  }

  String getWindDirection(int windDirection) {
    if (windDirection >= 0 && windDirection < 45) {
      return "Utara";
    } else if (windDirection >= 45 && windDirection < 90) {
      return "Timur Laut";
    } else if (windDirection >= 90 && windDirection < 135) {
      return "Timur";
    } else if (windDirection >= 135 && windDirection < 180) {
      return "Tenggara";
    } else if (windDirection >= 180 && windDirection < 225) {
      return "Selatan";
    } else if (windDirection >= 225 && windDirection < 270) {
      return "Barat Daya";
    } else if (windDirection >= 270 && windDirection < 315) {
      return "Barat";
    } else if (windDirection >= 315 && windDirection < 360) {
      return "Barat Laut";
    } else {
      return "Tidak Diketahui";
    }
  }

  String getWindDescription(int windSpeed) {
    if (windSpeed < 1) {
      return "angin sangat lemah";
    } else if (windSpeed < 5) {
      return "angin lemah";
    } else if (windSpeed < 10) {
      return "angin sedang";
    } else if (windSpeed < 15) {
      return "angin kuat";
    } else if (windSpeed < 20) {
      return "angin sangat kuat";
    } else {
      return "angin ekstrem";
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
              'Error loading wind data',
              style: TextStyle(color: Colors.white),
            ),
          );
        } else {
          final windDirection = snapshot.data?["windDirection"] ?? "0°";
          final windSpeed = snapshot.data?["windSpeed"] ?? 0.0;
          final windDirectionText = getWindDirection(windDirection);
          final windSpeedText = getWindDescription(windSpeed.toInt());
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
                              Icons.wind_power,
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
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${windSpeed}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 24,
                              ),
                            ),
                            TextSpan(
                              text: ' km/h | ${windDirection}°',
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
                        // getWindDescription(windSpeed.toInt()),
                        'Kecepatan ${windSpeedText} dari arah ${windDirectionText}.',
                        style: TextStyle(
                          color: Colors.white
                              .withOpacity(0.8)
                              .withOpacity(0.8),
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