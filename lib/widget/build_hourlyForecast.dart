import 'package:flutter/material.dart';
import 'package:weather_app/painter/TemperaturePainter.dart';

class BuildForecastWithTemperatureDiagram extends StatelessWidget {
  final List<String> hours = ['11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00'];
  final List<IconData> weatherIcons = [
    Icons.wb_sunny,
    Icons.wb_sunny,
    Icons.wb_sunny,
    Icons.wb_sunny,
    Icons.wb_sunny,
    Icons.wb_sunny,
    Icons.wb_sunny,
  ];
  final List<int> temperatures = [29, 29, 30, 30, 29, 28, 26];

  @override
  Widget build(BuildContext context) {
    final double itemWidth = 60.0;
    final double totalWidth = itemWidth * temperatures.length;

    return Container(
      height: 200,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: totalWidth,
          child: Stack(
            children: [
              // Background temperature diagram (garis dan titik dengan suhu)
              Positioned(
                top: 0,
                left: 0,
                child: CustomPaint(
                  size: Size(totalWidth, 100),
                  painter: ImprovedTemperaturePainter(
                    temperatures: temperatures,
                    itemWidth: itemWidth,
                  ),
                ),
              ),
              
              // Overlay forecast items - sejajar dengan dots
              ...List.generate(temperatures.length, (index) {
                return Positioned(
                  left: index * itemWidth, // Sejajar dengan calculation di painter
                  top: 104, // Posisi di bawah grafik
                  child: SizedBox(
                    width: itemWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          weatherIcons[index],
                          color: Colors.yellow,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cerah',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hours[index],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}