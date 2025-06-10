import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'build_weatherCard.dart';
import 'build_hourlyForecast.dart';
import 'package:weather_app/utils/getIconDataFromString.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

class BuildWeathercards extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  const BuildWeathercards({super.key, required this.weatherData});

  Future<Map<String, dynamic>> loadAllWeatherData() async {
    try {
      final data = weatherData;

      final String mappingResponse = await rootBundle.loadString('assets/json/weather_code.json');
      final Map<String, dynamic> mappingData = json.decode(mappingResponse);

      final List<String> allTime = List<String>.from(data["daily"]["time"]);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(Duration(days: 1));

      String getDayLabel(DateTime date) {
        if (date == today) return "Hari ini";
        if (date == tomorrow) return "Besok";
        return DateFormat.EEEE('id_ID').format(date);
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
      debugPrint("Error loading weather data: $e");
      return {}; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadAllWeatherData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // fallback UI pas data gagal di-load
          return Center(
            child: Text(
              'Data cuaca gak tersedia 😓',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        } else {
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
                            Icons.access_time,
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
                    const SizedBox(height: 16),
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white,
                            Colors.white,
                            Colors.white.withOpacity(0.0),
                          ],
                          stops: [0.0, 0.05, 0.95, 1.0],
                        ).createShader(bounds);
                      },
                      child: SizedBox(
                        height: 110,
                        child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: 7,
                          itemBuilder: (context, index) {
                            final isLoading = snapshot.connectionState == ConnectionState.waiting ||
                                !snapshot.hasData || snapshot.data!.isEmpty;
                          
                            return Container(
                              width: 160,
                              margin: EdgeInsets.only(right: index < 6 ? 12 : 0),
                              child: BuildWeathercard(
                                isLoading: isLoading,
                                title: isLoading ? null : snapshot.data!["allTime"][index],
                                temp: isLoading ? null : "${snapshot.data!["allMin"][index]}°/${snapshot.data!["allMax"][index]}°",
                                description: isLoading ? null : snapshot.data!["allWeather"][index],
                                icon: isLoading ? null : getIconDataFromString(snapshot.data!["allIcon"][index]),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    BuildForecastWithTemperatureDiagram(),
                    const SizedBox(height: 20),
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