import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class BuildDailyRainSum extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  const BuildDailyRainSum({super.key, required this.weatherData});

  Future<Map<String, dynamic>> loadRainData() async {
    try {
      final data = weatherData;

      // Ambil waktu sekarang dalam format yang sesuai dengan format hourly
      final String now = DateFormat("yyyy-MM-ddTHH:00").format(DateTime.now());
      final List<dynamic> hourlyTimes = data["hourly"]["time"];
      final int indexNow = hourlyTimes.indexOf(now);

      if (indexNow == -1) throw Exception("Waktu saat ini tidak ditemukan di data hourly");

      final double rainSum = data["hourly"]["precipitation"][indexNow].toDouble();
      final int rainProbability = data["hourly"]["precipitation_probability"][indexNow].toInt();

      return {
        "rainSum": rainSum,
        "rainProbability": rainProbability,
      };
    } catch (e) {
      print("Error loading rain data: $e");
      return {};
    }
  }

  String getRainDescription(double rainSum) {
    if (rainSum < 1) {
      return "Cuaca cerah berawan, tetap waspada perubahan cuaca.";
    } else if (rainSum < 5) {
      return "Diperkirakan hujan ringan, sebaiknya sediakan payung.";
    } else if (rainSum < 10) {
      return "Diperkirakan hujan sedang, bawa perlengkapan hujan.";
    } else if (rainSum < 20) {
      return "Diperkirakan hujan lebat, hati-hati di jalan.";
    } else {
      return "Hujan sangat lebat, waspadai banjir.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: loadRainData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'Gagal memuat data hujan',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final double rainSum = snapshot.data!["rainSum"] ?? 0.0;
        final int rainProbability = snapshot.data!["rainProbability"] ?? 0;

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
                  // Title Row
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

                  // Value Display
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: rainSum.toStringAsFixed(1),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: ' mm | $rainProbability%',
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

                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      getRainDescription(rainSum),
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
      },
    );
  }
}
