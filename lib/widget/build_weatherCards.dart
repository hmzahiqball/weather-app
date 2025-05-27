import 'package:flutter/material.dart';
import 'build_weatherCard.dart';
import 'build_hourlyForecast.dart';
import 'dart:ui';

class BuildWeathercards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1), // semi-transparent
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
                      '72 Jam Berikutnya',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Scrollable weather cards
              SizedBox(
                height: 120,
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 160,
                      margin: EdgeInsets.only(right: index < 4 ? 12 : 0),
                      child: BuildWeathercard(
                        title: _getWeatherData(index)['title'],
                        temp: _getWeatherData(index)['temp'],
                        description: _getWeatherData(index)['description'],
                        icon: _getWeatherData(index)['icon'],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Temperature diagram
              BuildForecastWithTemperatureDiagram(),

              const SizedBox(height: 20),

              // Hourly forecast
              // BuildForecastWithTemperatureDiagram(),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getWeatherData(int index) {
    final weatherData = [
      {
        'title': 'Hari ini',
        'temp': '22°/30°',
        'description': 'Cerah',
        'icon': Icons.wb_sunny,
      },
      {
        'title': 'Besok',
        'temp': '21°/30°',
        'description': 'Sebagian berawan',
        'icon': Icons.wb_cloudy,
      },
      {
        'title': 'Kamis',
        'temp': '20°/28°',
        'description': 'Berawan',
        'icon': Icons.cloud,
      },
      {
        'title': 'Jumat',
        'temp': '19°/26°',
        'description': 'Hujan ringan',
        'icon': Icons.grain,
      },
      {
        'title': 'Sabtu',
        'temp': '22°/29°',
        'description': 'Cerah',
        'icon': Icons.wb_sunny,
      },
    ];
    return weatherData[index];
  }
}