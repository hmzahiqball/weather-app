import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_app/painter/TemperaturePainter.dart';
import 'package:weather_app/utils/getIconDataFromString.dart';

class BuildForecastWithTemperatureDiagram extends StatelessWidget {
  Future<Map<String, dynamic>> loadAllWeatherData() async {
    final String response = await rootBundle.loadString(
      'assets/json/dummy2.json',
    );
    final data = json.decode(response);

    final String mappingResponse = await rootBundle.loadString('assets/json/weather_code.json');
    final Map<String, dynamic> mappingData = json.decode(mappingResponse);

    // Ambil data cuaca
    final List<String> allTimeRaw = List<String>.from(data["hourly"]["time"]);
    final List<String> allTime = allTimeRaw.map((time) {
      return time.split('T').last; // ambil bagian setelah 'T' => '00:00'
    }).toList();

    final List<int> allWeather = List<int>.from(data["hourly"]["weather_code"]);
    final List<int> allTemp = List<num>.from(data["hourly"]["temperature_2m"]).map((e) => e.round()).toList();

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
      "allTime": allTime,
      "allWeather": matchedWeather,
      "allIcon": matchedIcon,
      "allTemp": allTemp,
    };
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<Map<String, dynamic>>(
      future: loadAllWeatherData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<String> allTime = List<String>.from(snapshot.data!["allTime"]);
          final List<String> allWeather = List<String>.from(snapshot.data!["allWeather"]);
          final List<String> allIconn = List<String>.from(snapshot.data!["allIcon"]);
          final List<IconData> allIcon = allIconn.map<IconData>((e) => getIconDataFromString(e)).toList();
          final List<int> allTemp = List<int>.from(snapshot.data!["allTemp"]);

          final double itemWidth = 60.0;
          final double totalWidth = itemWidth * allTime.length;

          return Container(
            height: 200,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: totalWidth,
                child: Stack(
                  children: [
                    // Background temperature diagram (garis dan titik dengan suhu)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: CustomPaint(
                        size: Size(totalWidth, 100),
                        painter: ImprovedTemperaturePainter(
                          temperatures: allTemp,
                          itemWidth: itemWidth,
                        ),
                      ),
                    ),
                    
                    // Overlay forecast items - sejajar dengan dots
                    ...List.generate(allTime.length, (index) {
                      return Positioned(
                        left: index * itemWidth, // Sejajar dengan calculation di painter
                        top: 104, // Posisi di bawah grafik
                        child: SizedBox(
                          width: itemWidth,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                allIcon[index],
                                color: Colors.white.withOpacity(0.9),
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                allWeather[index],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                allTime[index],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 11,
                                ),
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
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}