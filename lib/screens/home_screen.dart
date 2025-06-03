import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:weather_app/utils/getBackgroundWeather.dart';
import 'package:weather_app/widget/build_header.dart';
import 'package:weather_app/widget/build_temperature.dart';
import 'package:weather_app/widget/build_weatherDesc.dart';
import 'package:weather_app/widget/build_weatherCards.dart';
import 'package:weather_app/widget/build_dailyMinMax.dart';
import 'package:weather_app/widget/build_dailyRainSum.dart';
import 'package:weather_app/widget/build_dailyWind.dart';
import 'package:weather_app/widget/build_airQuality.dart';
import 'package:weather_app/widget/build_indexUV.dart';
import 'package:weather_app/widget/build_dailyHumidity.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // Ambil weatherCode terbaru dari dummy2.json
  Future<int> getLatestWeatherCode() async {
    // https://api.open-meteo.com/v1/forecast?latitude=-7.3993&longitude=108.2607&daily=weather_code,sunset,sunrise,temperature_2m_min,temperature_2m_max,rain_sum,wind_speed_10m_mean,wind_gusts_10m_mean,cloud_cover_mean&hourly=temperature_2m,weather_code,wind_speed_10m,wind_direction_10m,relative_humidity_2m,cloud_cover,precipitation,precipitation_probability,uv_index&current=weather_code,is_day,temperature_2m&timezone=auto
    // https://air-quality-api.open-meteo.com/v1/air-quality?latitude=-7.3993&longitude=108.2607&hourly=us_aqi_pm2_5&timezone=auto
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
                          BuildDailyminmax(),
                          const SizedBox(height: 24),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: BuildDailyRainSum(),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: BuildDailyWind(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: BuildAirquality(),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: BuildIndexUV(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: BuildDailyHumidity(),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: BuildDailyHumidity(),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
