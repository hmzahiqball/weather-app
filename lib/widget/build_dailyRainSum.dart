import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

class BuildDailyRainSum extends StatelessWidget {
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
      final rainSum = data["hourly"]["rain"][indexNow];
      final cloudCover = data["hourly"]["cloud_cover"][indexNow];

      return {
        "totalRainSum": rainSum,
        "totalCloudCover": cloudCover,
      };
    } catch (e) {
      print(e);
      return {};
    }
  }

  String getRainSumDescription(int rainSum) {
    if (rainSum < 1) {
      return "Cuaca akan cerah berawan, tetap waspada perubahan cuaca";
    } else if (rainSum < 5) {
      return "Diperkirakan Hujan ringan, sebaiknya sediakan payung";
    } else if (rainSum < 10) {
      return "Diperkirakan Hujan sedang, sebaiknya sediakan perlengkapan hujan";
    } else if (rainSum < 20) {
      return "Diperkirakan Hujan lebat, hati-hati terhadap kondisi yang licin";
    } else {
      return "Hujan sangat lebat, waspadai bahaya banjir";
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
          final totalRainSum = snapshot.data?["totalRainSum"] ?? 2.0;
          final totalCloudCover = snapshot.data?["totalCloudCover"] ?? 0;
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
                              Icons.water_drop,
                              color: Colors.white.withOpacity(0.8),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
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
                              child: Text(
                                'Curah Hujan Kumulatif',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
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
                              text: '${totalRainSum.toStringAsFixed(1)}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 24,
                              ),
                            ),
                            TextSpan(
                              text: ' mm | ${totalCloudCover}%',
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
                        getRainSumDescription(totalRainSum.toInt()),
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
