import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_app/painter/TemperaturePainter.dart';
import 'package:weather_app/utils/getIconDataFromString.dart';

class BuildForecastWithTemperatureDiagram extends StatefulWidget {
  @override
  _BuildForecastWithTemperatureDiagramState createState() => _BuildForecastWithTemperatureDiagramState();
}

class _BuildForecastWithTemperatureDiagramState extends State<BuildForecastWithTemperatureDiagram> {
  final ScrollController _scrollController = ScrollController();
  final double itemWidth = 60.0;

  Future<Map<String, dynamic>> loadAllWeatherData() async {
    final String response = await rootBundle.loadString('assets/json/dummy2.json');
    final data = json.decode(response);

    final String mappingResponse = await rootBundle.loadString('assets/json/weather_code.json');
    final Map<String, dynamic> mappingData = json.decode(mappingResponse);

    final List<String> allTimeRaw = List<String>.from(data["hourly"]["time"]);
    final List<String> allTime = allTimeRaw.map((time) => time.split('T').last).toList();

    final List<int> allWeather = List<int>.from(data["hourly"]["weather_code"]);
    final List<int> allTemp = List<num>.from(data["hourly"]["temperature_2m"]).map((e) => e.round()).toList();

    final List<dynamic> weatherCodeMapping = mappingData["weather_code_mapping"];
    final matchedWeather = allWeather.map((code) =>
      weatherCodeMapping.firstWhere((entry) => entry["code"] == code, orElse: () => {"desc": "Tidak diketahui"})["desc"]
    ).toList();

    final matchedIcon = allWeather.map((code) =>
      weatherCodeMapping.firstWhere((entry) => entry["code"] == code, orElse: () => {"icon": "Tidak diketahui"})["icon"]
    ).toList();

    return {
      "allTime": allTime,
      "allWeather": matchedWeather,
      "allIcon": matchedIcon,
      "allTemp": allTemp,
    };
  }

  void scrollToCurrentHour(List<String> allTime) {
    final now = DateTime.now();
    final nowHourStr = now.hour.toString().padLeft(2, '0') + ':00'; // contoh: "10:00"
    final index = allTime.indexOf(nowHourStr);

    if (index != -1) {
      final position = index * itemWidth;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          position,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      });
    }
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

          final double totalWidth = itemWidth * allTime.length;

          // Trigger scroll ke jam sekarang
          scrollToCurrentHour(allTime);

          return Container(
            height: 200,
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
                      ...List.generate(allTime.length, (index) {
                        return Positioned(
                          left: index * itemWidth,
                          top: 104,
                          child: SizedBox(
                            width: itemWidth,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(allIcon[index], color: Colors.white.withOpacity(0.9), size: 24),
                                const SizedBox(height: 4),
                                Text(
                                  allWeather[index],
                                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  allTime[index],
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
