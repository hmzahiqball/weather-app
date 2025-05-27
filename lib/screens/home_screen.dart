import 'package:flutter/material.dart';
import 'package:weather_app/utils/getBackgroundWeather.dart';
import 'package:weather_app/widget/build_header.dart';
import 'package:weather_app/widget/build_temperature.dart';
import 'package:weather_app/widget/build_weatherDesc.dart';
import 'package:weather_app/widget/build_weatherCards.dart';

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
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
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
  }
}