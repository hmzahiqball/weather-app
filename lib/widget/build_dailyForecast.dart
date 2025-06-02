import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_app/painter/DailyTemperaturePainter.dart';
import 'package:weather_app/utils/getIconDataFromString.dart';
import 'package:intl/intl.dart';

class BuildForecastWithTemperatureDiagram extends StatefulWidget {
  @override
  _BuildForecastWithTemperatureDiagramState createState() =>
      _BuildForecastWithTemperatureDiagramState();
}

class _BuildForecastWithTemperatureDiagramState
    extends State<BuildForecastWithTemperatureDiagram> {
  final ScrollController _scrollController = ScrollController();
  final double itemWidth = 60.0;

  Future<Map<String, dynamic>> loadAllWeatherData() async {
    final String response =
        await rootBundle.loadString('assets/json/dummy2.json');
    final data = json.decode(response);

    final String mappingResponse =
        await rootBundle.loadString('assets/json/weather_code.json');
    final Map<String, dynamic> mappingData = json.decode(mappingResponse);

    // daily
    final List<String> allDatesRaw = List<String>.from(data["daily"]["time"]);
    
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

    final List<String> allTimeLabel = allDatesRaw.map((dateStr) {
      final date = DateTime.parse(dateStr);
      final currentDate = DateTime(date.year, date.month, date.day);
      return getDayLabel(currentDate);
    }).toList();

    final List<int> tempMin =
        List<num>.from(data["daily"]["temperature_2m_min"]).map((e) => e.round()).toList();
    final List<int> tempMax =
        List<num>.from(data["daily"]["temperature_2m_max"]).map((e) => e.round()).toList();

    final List<int> weatherCodes = List<int>.from(data["daily"]["weather_code"]);

    final List<dynamic> weatherCodeMapping = mappingData["weather_code_mapping"];
    final List<String> descriptions = weatherCodes.map((code) {
      return weatherCodeMapping
          .firstWhere((entry) => entry["code"] == code,
              orElse: () => {"desc": "Tidak diketahui"})["desc"]
          .toString();
    }).toList();

    final List<IconData> icons = weatherCodes.map((code) {
      final iconStr = weatherCodeMapping
          .firstWhere((entry) => entry["code"] == code,
              orElse: () => {"icon": "help_outline"})["icon"];
      return getIconDataFromString(iconStr);
    }).toList();

    return {
      "dayNames": allTimeLabel,
      "tempMin": tempMin,
      "tempMax": tempMax,
      "descriptions": descriptions,
      "icons": icons,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: loadAllWeatherData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<String> dayNames = List<String>.from(snapshot.data!["dayNames"]);
          final List<int> tempMin = List<int>.from(snapshot.data!["tempMin"]);
          final List<int> tempMax = List<int>.from(snapshot.data!["tempMax"]);
          final List<String> descriptions = List<String>.from(snapshot.data!["descriptions"]);
          final List<IconData> icons = List<IconData>.from(snapshot.data!["icons"]);

          final double totalWidth = itemWidth * dayNames.length;

          return Container(
            height: 220,
            child: ShaderMask(
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
                  tileMode: TileMode.mirror,
                ).createShader(bounds);
              },
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: totalWidth,
                  child: Stack(
                    children: [
                      // 🟡 Custom Painter for Min/Max Temp Diagram
                      Positioned(
                        top: 0,
                        left: 0,
                        child: CustomPaint(
                          size: Size(totalWidth, 100),
                          painter: DailyTemperaturePainter(
                            minTemperatures: tempMin,
                            maxTemperatures: tempMax,
                            itemWidth: itemWidth,
                          ),
                        ),
                      ),
                      // 🔵 Info per Hari
                      ...List.generate(dayNames.length, (index) {
                        return Positioned(
                          left: index * itemWidth,
                          top: 104,
                          child: SizedBox(
                            width: itemWidth,
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                Icon(icons[index], color: Colors.white.withOpacity(0.9), size: 24),
                                const SizedBox(height: 4),
                                Text(
                                  descriptions[index],
                                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dayNames[index],
                                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
