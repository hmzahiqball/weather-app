import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:weather_app/painter/SunPathPainter.dart';

class BuildSetnrise extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  const BuildSetnrise({super.key, required this.weatherData});

  Future<Map<String, dynamic>> loadAllWeatherData() async {
    try {
      final data = weatherData;

      // ambil tanggal hari ini dalam format yang cocok dengan daily time
      final today = DateFormat("yyyy-MM-dd").format(DateTime.now());
      final dailyTimes = data["daily"]["time"] as List;
      final indexToday = dailyTimes.indexOf(today);

      // ambil jam sunrise dan sunset
      final sunriseHour = DateFormat("HH:mm").format(DateTime.parse(data["daily"]["sunrise"][indexToday]));
      final sunsetHour = DateFormat("HH:mm").format(DateTime.parse(data["daily"]["sunset"][indexToday]));

      return {
        "sunrise": sunriseHour,
        "sunset": sunsetHour,
      };
    } catch (e) {
      print(e);
      return {};
    }
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
              'Error loading rain data',
              style: TextStyle(color: Colors.white),
            ),
          );
        } else {
          final sunrise = snapshot.data?["sunrise"] ?? 00.00;
          final sunset = snapshot.data?["sunset"] ?? 00.00;
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
                              Icons.wb_sunny,
                              color: Colors.white.withOpacity(0.8),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Sunrise - Sunset',
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
                      child: SunPathProgress(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${sunrise} - ${sunset}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
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