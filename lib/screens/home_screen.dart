import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:weather_app/utils/getBackgroundWeather.dart';
import 'package:weather_app/widget/build_header.dart';
import 'package:weather_app/widget/build_temperature.dart';
import 'package:weather_app/widget/build_weatherDesc.dart';
import 'package:weather_app/widget/build_weatherCards.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Ambil weatherCode terbaru dari dummy2.json
  Future<int> getLatestWeatherCode() async {
    final jsonString = await rootBundle.loadString('assets/json/dummy2.json');
    final data = json.decode(jsonString);

    List<dynamic> times = data['hourly']['time'];
    List<dynamic> weatherCodes = data['hourly']['weather_code'];

    DateTime now = DateTime.now();
    int index = 0;

    for (int i = 0; i < times.length; i++) {
      DateTime hourlyTime = DateTime.parse(times[i]);
      if (hourlyTime.isAfter(now)) break;
      index = i;
    }

    return weatherCodes[index];
  }

  // Ambil deskripsi dari weatherCode via weather_code.json
  Future<String?> getWeatherDesc(int weatherCode) async {
    final jsonString = await rootBundle.loadString('assets/json/weather_code.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    final List<dynamic> mapping = jsonMap['weather_code_mapping'];

    final matched = mapping.firstWhere(
      (item) => item['code'] == weatherCode,
      orElse: () => null,
    );

    return matched != null ? matched['desc'] : 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: getLatestWeatherCode(),
      builder: (context, weatherSnapshot) {
        if (weatherSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (weatherSnapshot.hasError || !weatherSnapshot.hasData) {
          return const Center(child: Text('Error loading weather code'));
        }

        final int weatherCode = weatherSnapshot.data!;

        return FutureBuilder<String?>(
          future: getWeatherDesc(weatherCode),
          builder: (context, descSnapshot) {
            if (descSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (descSnapshot.hasError || !descSnapshot.hasData) {
              return const Center(child: Text('Error loading weather description'));
            }

            final String desc = descSnapshot.data!;
            final String backgroundImage = getWeatherBackground(desc);

            return Scaffold(
              body: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(backgroundImage, fit: BoxFit.cover),
                  Container(color: Colors.black.withOpacity(0.3)),
                  SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          BuildHeader(),
                          const SizedBox(height: 200),
                          BuildTemperature(),
                          const SizedBox(height: 8),
                          BuildWeatherdescription(),
                          const SizedBox(height: 20),
                          BuildWeathercards(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
