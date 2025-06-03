import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'build_dailyForecast.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

class BuildDailyminmax extends StatelessWidget {
  Future<Map<String, dynamic>> loadAllWeatherData() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/dummy2.json',
      );
      final data = json.decode(response);

      final String mappingResponse = await rootBundle.loadString(
        'assets/json/weather_code.json',
      );
      final Map<String, dynamic> mappingData = json.decode(mappingResponse);

      // Ambil data cuaca
      final List<String> allTime = List<String>.from(data["daily"]["time"]);

      // Waktu sekarang
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(Duration(days: 1));

      // Helper untuk label hari
      String getDayLabel(DateTime date) {
        if (date == today) return "Hari ini";
        if (date == tomorrow) return "Besok";
        return DateFormat.EEEE('id_ID').format(date); // Contoh: Senin, Selasa
      }

      final List<String> allTimeLabel = allTime.map((dateStr) {
        final date = DateTime.parse(dateStr);
        final currentDate = DateTime(date.year, date.month, date.day);
        return getDayLabel(currentDate);
      }).toList();

      final List<int> allWeather = List<int>.from(data["daily"]["weather_code"]);
      final List<int> allMin = List<num>.from(data["daily"]["temperature_2m_min"]).map((e) => e.round()).toList();
      final List<int> allMax = List<num>.from(data["daily"]["temperature_2m_max"]).map((e) => e.round()).toList();

      final List<dynamic> weatherCodeMapping = mappingData["weather_code_mapping"];

      final matchedWeather = allWeather.map(
        (code) => weatherCodeMapping.firstWhere(
          (entry) => entry["code"] == code,
          orElse: () => {"desc": "Tidak diketahui"},
        )["desc"],
      ).toList();

      final matchedIcon = allWeather.map(
        (code) => weatherCodeMapping.firstWhere(
          (entry) => entry["code"] == code,
          orElse: () => {"icon": "Tidak diketahui"},
        )["icon"],
      ).toList();

      return {
        "allTime": allTimeLabel,
        "allWeather": matchedWeather,
        "allIcon": matchedIcon,
        "allMin": allMin,
        "allMax": allMax,
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
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading temperature data',
              style: TextStyle(color: Colors.white),
            ),
          );
        } else {
          return ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  // color: Colors.white.withOpacity(0.1), // semi-transparent
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
                            Icons.calendar_month,
                            color: Colors.white.withOpacity(0.8),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '7 Hari Berikutnya',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Temperature diagram
                    BuildForecastWithTemperatureDiagram(),
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