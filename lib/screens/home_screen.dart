import 'package:flutter/material.dart';
import 'package:weather_app/utils/getBackgroundWeather.dart';
import 'package:weather_app/widget/build_header.dart';
import 'package:weather_app/widget/build_sunIlustration.dart';
import 'package:weather_app/widget/build_temperature.dart';
import 'package:weather_app/widget/build_weatherDesc.dart';
import 'package:weather_app/widget/build_weatherCards.dart';
import 'package:weather_app/widget/build_hourlyForecast.dart';

class HomeScreen extends StatelessWidget {
  final String weatherCondition = 'cerah';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundImage = getWeatherBackground(weatherCondition);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            backgroundImage,
            fit: BoxFit.cover,
          ),
          // Overlay biar tulisan tetap kebaca
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                BuildHeader(),
                
                // Main weather content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Temperature
                      BuildTemperature(),
                      
                      const SizedBox(height: 8),
                      
                      // Weather description
                      BuildWeatherdescription(),
                      
                      const SizedBox(height: 60),
                      
                      // Weather info cards
                      BuildWeathercards(),
                      
                      const SizedBox(height: 24),
                      
                      // Hourly forecast
                      BuildHourlyForecast(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}