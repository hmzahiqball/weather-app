import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:weather_app/widget/build_header.dart';
import 'package:weather_app/widget/build_sunIlustration.dart';
import 'package:weather_app/widget/build_temperature.dart';
import 'package:weather_app/widget/build_weatherDesc.dart';
import 'package:weather_app/widget/build_weatherCards.dart';
import 'package:weather_app/widget/build_hourlyForecast.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6B73FF),
              Color(0xFF9DCEFF),
              Color(0xFFE8F4FD),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              BuildHeader(),
              
              // Main weather content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Sun illustration
                    BuildSun(),
                    
                    const SizedBox(height: 40),
                    
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
      ),
    );
  }
}