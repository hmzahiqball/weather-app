import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class SunPathProgress extends StatefulWidget {
  const SunPathProgress({super.key});

  @override
  State<SunPathProgress> createState() => _SunPathProgressState();
}

class _SunPathProgressState extends State<SunPathProgress> {
  DateTime? sunrise;
  DateTime? sunset;

  @override
  void initState() {
    super.initState();
    loadSunData();
  }

  Future<void> loadSunData() async {
    final jsonString = await rootBundle.loadString('assets/json/dummy2.json');
    final jsonData = json.decode(jsonString);

    final todayIndex = 0;
    final sunriseStr = jsonData['daily']['sunrise'][todayIndex];
    final sunsetStr = jsonData['daily']['sunset'][todayIndex];

    setState(() {
      sunrise = DateTime.parse(sunriseStr);
      sunset = DateTime.parse(sunsetStr);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (sunrise == null || sunset == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.5), width: 3))),
      child: CustomPaint(
        size: const Size(double.infinity, 80),
        painter: SunPathPainter(
          sunrise: TimeOfDay.fromDateTime(sunrise!),
          sunset: TimeOfDay.fromDateTime(sunset!),
          now: TimeOfDay.fromDateTime(DateTime.now())
        ),
      )
    );
  }
}

class SunPathPainter extends CustomPainter {
  final TimeOfDay sunrise;
  final TimeOfDay sunset;
  final TimeOfDay now;

  SunPathPainter({
    required this.sunrise,
    required this.sunset,
    required this.now,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2.2; // dikecilin dikit biar gak mentok ke atas
    final center = Offset(size.width / 2, radius); // digeser ke bawah
  
    final path = Path()
      ..moveTo(center.dx - radius, center.dy)
      ..arcToPoint(
        Offset(center.dx + radius, center.dy),
        radius: Radius.circular(radius),
        clockwise: true,
      );
  
    _drawDashedArc(
      canvas,
      path,
      Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  
    final sunriseMinutes = sunrise.hour * 60 + sunrise.minute;
    final sunsetMinutes = sunset.hour * 60 + sunset.minute;
    final nowMinutes = now.hour * 60 + now.minute;
  
    final totalDuration = sunsetMinutes - sunriseMinutes;
    final passedDuration = (nowMinutes - sunriseMinutes).clamp(0, totalDuration);
    final progress = passedDuration / totalDuration;
  
    final angle = progress * pi;
    final adjustedAngle = pi - angle;
  
    final sunX = center.dx + radius * cos(adjustedAngle);
    final sunY = center.dy - radius * sin(adjustedAngle); // arah Y dibalik
  
    final sunPaint = Paint()..color = Colors.orangeAccent;
    canvas.drawCircle(Offset(sunX, sunY), 10, sunPaint);
  
    canvas.drawCircle(
      Offset(sunX, sunY),
      16,
      Paint()
        ..color = Colors.orangeAccent.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  void _drawDashedArc(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 6;
    const dashSpace = 4;

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final extractPath = metric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}