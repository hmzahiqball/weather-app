import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'build_dailyForecast.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

class BuildDailyminmax extends StatelessWidget {
  Future<Map<String, dynamic>> loadAllWeatherData() async {
    try {
      // Load JSON dummy data
      final String response = await rootBundle.loadString('assets/json/dummy2.json');
      final data = json.decode(response);

      // Load weather code mapping
      final String mappingResponse = await rootBundle.loadString('assets/json/weather_code.json');
      final Map<String, dynamic> mappingData = json.decode(mappingResponse);

      // Waktu sekarang + besok
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(Duration(days: 1));

      // Label hari
      String getDayLabel(DateTime date) {
        if (date == today) return "Hari ini";
        if (date == tomorrow) return "Besok";
        return DateFormat.EEEE('id_ID').format(date);
      }

      // Extract data harian
      final List<String> allTime = List<String>.from(data["daily"]["time"]);
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
    } catch (e, stacktrace) {
      debugPrint("⚠️ Error loadAllWeatherData: $e\n$stacktrace");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: loadAllWeatherData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: Colors.redAccent, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Gagal load data cuaca',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          );
        } else if (snapshot.hasData) {
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
                          Icon(Icons.calendar_month, color: Colors.white.withOpacity(0.8), size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '7 Hari Berikutnya',
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Diagram suhu
                    BuildForecastWithTemperatureDiagram(),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const SizedBox(); // fallback
        }
      },
    );
  }
}
