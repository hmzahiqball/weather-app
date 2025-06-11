import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:weather_app/widget/build_shimmerEffect.dart';

class BuildDailyHumidity extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  const BuildDailyHumidity({super.key, required this.weatherData});

  Future<Map<String, dynamic>> loadAllWeatherData() async {
    try {
      final data = weatherData;

      final now = DateFormat("yyyy-MM-ddTHH:00").format(DateTime.now());
      final hourlyTimes = data["hourly"]["time"] as List;
      final indexNow = hourlyTimes.indexOf(now);

      final dailyHumidity = data["hourly"]["relative_humidity_2m"][indexNow];

      return {
        "dailyHumidity": dailyHumidity,
      };
    } catch (e) {
      print(e);
      return {};
    }
  }

  String getHumidityDescription(int humidity) {
    if (humidity < 30) {
      return "Kelembaban udara sangat rendah";
    } else if (humidity < 60) {
      return "Kelembaban udara sedang";
    } else if (humidity < 80) {
      return "Kelembaban udara tinggi";
    } else {
      return "Kelembaban udara sangat tinggi";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadAllWeatherData(),
      builder: (context, snapshot) {
        final humidity = snapshot.data?["dailyHumidity"]?.toInt() ?? 0;
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
                          ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.white,
                                  Colors.white.withOpacity(0.0),
                                ],
                                stops: [0.6, 1],
                                tileMode: TileMode.mirror,
                              ).createShader(bounds);
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.water_drop,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Persentase Kelembaban Udara',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Data utama
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
                  else if (snapshot.hasData && snapshot.data != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$humidity%',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 24,
                              ),
                            ),
                            TextSpan(
                              text: '  ${getHumidityDescription(humidity)}',
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
                        "Pantau kelembaban untuk menjaga kenyamanan dan kesehatan kulit.",
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
