import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:weather_app/utils/getBackgroundWeather.dart';
import 'package:weather_app/widget/build_airQuality.dart';
import 'package:weather_app/widget/build_dailyHumidity.dart';
import 'package:weather_app/widget/build_dailyMinMax.dart';
import 'package:weather_app/widget/build_dailyRainSum.dart';
import 'package:weather_app/widget/build_dailyWind.dart';
import 'package:weather_app/widget/build_header.dart';
import 'package:weather_app/widget/build_indexUV.dart';
import 'package:weather_app/widget/build_risenset.dart';
import 'package:weather_app/widget/build_temperature.dart';
import 'package:weather_app/widget/build_weatherCards.dart';
import 'package:weather_app/widget/build_weatherDesc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Ambil kode cuaca terbaru dari dummy2.json (hourly)
  Future<int> _getLatestWeatherCode() async {
    // https://api.open-meteo.com/v1/forecast?latitude=-7.3993&longitude=108.2607&daily=weather_code,sunset,sunrise,temperature_2m_min,temperature_2m_max,rain_sum,wind_speed_10m_mean,wind_gusts_10m_mean,cloud_cover_mean&hourly=temperature_2m,weather_code,wind_speed_10m,wind_direction_10m,relative_humidity_2m,cloud_cover,precipitation,precipitation_probability,uv_index&current=weather_code,is_day,temperature_2m&timezone=auto
    // https://air-quality-api.open-meteo.com/v1/air-quality?latitude=-7.3993&longitude=108.2607&hourly=us_aqi_pm2_5&timezone=auto
    final jsonString = await rootBundle.loadString('assets/json/dummy2.json');
    final data = json.decode(jsonString);

    final List<dynamic> times = data['hourly']['time'];
    final List<dynamic> weatherCodes = data['hourly']['weather_code'];

    final now = DateTime.now();
    int latestIndex = 0;

    for (int i = 0; i < times.length; i++) {
      final time = DateTime.parse(times[i]);
      if (time.isAfter(now)) break;
      latestIndex = i;
    }

    return weatherCodes[latestIndex];
  }

  /// Ambil deskripsi berdasarkan kode cuaca dari weather_code.json
  Future<String?> _getWeatherDescription(int weatherCode) async {
    final jsonString = await rootBundle.loadString('assets/json/weather_code.json');
    final Map<String, dynamic> data = json.decode(jsonString);
    final List<dynamic> mappings = data['weather_code_mapping'];

    final match = mappings.firstWhere(
      (item) => item['code'] == weatherCode,
      orElse: () => null,
    );

    return match != null ? match['desc'] : 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _getLatestWeatherCode(),
      builder: (context, weatherSnapshot) {
        if (weatherSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (weatherSnapshot.hasError || !weatherSnapshot.hasData) {
          return const Center(child: Text('Error loading weather code'));
        }

        final int weatherCode = weatherSnapshot.data!;

        return FutureBuilder<String?>(
          future: _getWeatherDescription(weatherCode),
          builder: (context, descSnapshot) {
            if (descSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (descSnapshot.hasError || !descSnapshot.hasData) {
              return const Center(child: Text('Error loading weather description'));
            }

            final String description = descSnapshot.data!;
            final String backgroundImage = getWeatherBackground(description);

            return Scaffold(
              body: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(backgroundImage, fit: BoxFit.cover),
                  Container(color: Colors.black.withOpacity(0.3)),
                  SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

                          /// Rain & Wind
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: BuildDailyRainSum(),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: BuildDailyWind(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          /// Air Quality & UV Index
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: BuildAirquality(),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: BuildIndexUV(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          /// Humidity & Sunrise/Sunset
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: BuildDailyHumidity(),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: BuildSetnrise(),
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
