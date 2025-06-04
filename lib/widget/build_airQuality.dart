import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:weather_app/services/getAirQualityApi.dart';

class BuildAirquality extends StatelessWidget {
  Future<Map<String, dynamic>> loadAllWeatherData() async {
    try {
      final data = await AirApiService.fetchWeatherData();

      final now = DateFormat("yyyy-MM-ddTHH:00").format(DateTime.now());
      final hourlyTimes = data["hourly"]["time"] as List;
      final indexNow = hourlyTimes.indexOf(now);

      final airQuality = data["hourly"]["us_aqi_pm2_5"][indexNow];

      return {
        "airQuality": airQuality,
      };
    } catch (e) {
      print(e);
      return {};
    }
  }

  String getAirQualityLevel(int aqi) {
    if (aqi < 51) return "Baik";
    if (aqi < 101) return "Sedang";
    if (aqi < 151) return "Tidak Sehat";
    if (aqi < 201) return "Sangat Tidak Sehat";
    return "Berbahaya";
  }

  String getAirQualityMessage(int aqi) {
    if (aqi < 51) return "Udara bersih, aman buat semua aktivitas!";
    if (aqi < 101) return "Kualitas udara sedang, masih aman tapi hati-hati buat yang sensitif."; 
    if (aqi < 151) return "Udara agak kotor, disarankan kurangi aktivitas di luar.";
    if (aqi < 201) return "Udara nggak sehat, pakai masker kalau ke luar ya.";
    return "Udara berbahaya! Mending di rumah aja dan tutup jendela.";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadAllWeatherData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading air quality data',
              style: TextStyle(color: Colors.white),
            ),
          );
        } else {
          final airQuality = snapshot.data?["airQuality"] ?? 0;
          final airQualityLevel = getAirQualityLevel(airQuality);
          final airQualityMessage = getAirQualityMessage(airQuality);

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
                      child: Row(
                        children: [
                          Icon(
                            airQuality <= 50
                                ? Icons.water_drop
                                : airQuality <= 100
                                    ? Icons.water_drop_outlined
                                    : Icons.warning,
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
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$airQuality',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 24,
                              ),
                            ),
                            TextSpan(
                              text: ' μg/m³',
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
                        'Kualitas udara saat ini: $airQualityLevel. $airQualityMessage',
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
