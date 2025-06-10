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
import 'package:weather_app/services/getWeatherApi.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _weatherDataFuture;

  @override
  void initState() {
    super.initState();
    _weatherDataFuture = _loadWeatherData();
  }

  Future<Map<String, dynamic>> _loadWeatherData() async {
    // Coba ambil data dari cache
    Map<String, dynamic>? cachedData = await ApiService.getCachedWeatherData();
    
    // Jika tidak ada data di cache, ambil dari API
    if (cachedData != null) {
      return cachedData;
    } else {
      return await ApiService.fetchWeatherData();
    }
  }

  Future<int> _getLatestWeatherCode() async {
    final data = await _weatherDataFuture;
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
    return FutureBuilder<Map<String, dynamic>>(
      future: _weatherDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Error loading weather data'));
        }

        final weatherData = snapshot.data!;

        return FutureBuilder<int>(
          future: _getLatestWeatherCode(),
          builder: (context, weatherSnapshot) {
            if (weatherSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            if (weatherSnapshot.hasError || !weatherSnapshot.hasData) {
              return const Center(child: Text('Error loading weather code'));
            }

            final int weatherCode = weatherSnapshot.data!;

            return FutureBuilder<String?>(
              future: _getWeatherDescription(weatherCode),
              builder: (context, descSnapshot) {
                if (descSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
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
                              BuildTemperature(weatherData: weatherData),
                              const SizedBox(height: 8),
                              BuildWeatherdescription(weatherData: weatherData),
                              const SizedBox(height: 20),
                              BuildWeathercards(weatherData: weatherData),
                              const SizedBox(height: 24),
                              BuildDailyminmax(weatherData: weatherData),
                              const SizedBox(height: 24),
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: BuildDailyRainSum(weatherData: weatherData),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: BuildDailyWind(weatherData: weatherData),
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
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: BuildAirquality(),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: BuildIndexUV(weatherData: weatherData),
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
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: BuildDailyHumidity(weatherData: weatherData),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: BuildSetnrise(weatherData: weatherData),
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
      },
    );
  }
}