import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class BuildWeatherdescription extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  const BuildWeatherdescription({super.key, required this.weatherData});

  Future<Map<String, dynamic>> _loadWeatherData() async {
    final data = weatherData;

    // ambil waktu lokal sekarang dalam format yang cocok dengan hourly time
    final now = DateFormat("yyyy-MM-ddTHH:00").format(DateTime.now());

    final hourlyTimes = data["hourly"]["time"] as List;
    final indexNow = hourlyTimes.indexOf(now);

    if (indexNow == -1) {
      throw Exception("Data jam sekarang (${now}) gak ketemu di hourly");
    }

    final weatherCode = data["hourly"]["weather_code"][indexNow];
    final windSpeed = data["hourly"]["wind_speed_10m"][indexNow];
    final windDir = data["hourly"]["wind_direction_10m"][indexNow];

    // Ambil deskripsi berdasarkan kode cuaca dari weather_code.json
    final String mappingResponse = await rootBundle.loadString('assets/json/weather_code.json');
    final Map<String, dynamic> mappingData = json.decode(mappingResponse);

    final List<dynamic> weatherCodeMapping = mappingData["weather_code_mapping"];
    final weatherEntry = weatherCodeMapping.firstWhere(
      (entry) => entry["code"] == weatherCode,
      orElse: () => {"desc": "Tidak diketahui"},
    );
    final matchedWeather = weatherEntry["desc"];

    return {
      "desc": matchedWeather, // hasil mapping kode ke deskripsi
      "feels_like": data["current"]["temperature_2m"].toInt() - 2,
      "wind_dir": windDir,
      "wind_speed": windSpeed,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadWeatherData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(color: Colors.white);
        } else if (snapshot.hasError) {
          return const Text('Error ngambil data cuaca');
        } else {
          final data = snapshot.data!;
          final desc = data["desc"];
          final feelsLike = data["feels_like"];
          final windDir = data["wind_dir"];
          final windSpeed = data["wind_speed"];

          String windScale;
          if (windSpeed < 5) {
            windScale = "Skala angin ringan";
          } else if (windSpeed < 10) {
            windScale = "Skala angin sedang";
          } else {
            windScale = "Skala angin kencang";
          }

          return Column(
            children: [
              Text(
                desc,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Terasa seperti ${feelsLike}°, ${windScale} dari arah $windDir°',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        }
      },
    );
  }
}
