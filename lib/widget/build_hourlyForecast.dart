import 'package:flutter/material.dart';
import 'dart:ui';
import 'build_hourlyItem.dart';

class BuildHourlyForecast extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const BuildHourlyitem(temp: '29°', isActive: true),
                const BuildHourlyitem(temp: '29°', isActive: false),
                const BuildHourlyitem(temp: '30°', isActive: false),
                const BuildHourlyitem(temp: '30°', isActive: false),
                const BuildHourlyitem(temp: '29°', isActive: false),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
