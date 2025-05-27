import 'package:flutter/material.dart';
import 'build_weatherCard.dart';

class BuildWeathercards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: BuildWeathercard(
              title: 'Hari ini',
              temp: '22°/30°',
              description: 'Cerah',
              icon: Icons.wb_sunny,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: BuildWeathercard(
              title: 'Hari ini',
              temp: '22°/30°',
              description: 'Cerah',
              icon: Icons.wb_sunny,
            ),
          ),
        ],
      ),
    );
  }
}
