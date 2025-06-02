import 'package:flutter/material.dart';
import 'dart:math' as math;

class ImprovedTemperaturePainter extends CustomPainter {
  final List<int> temperatures;
  final double itemWidth;

  const ImprovedTemperaturePainter({
    required this.temperatures,
    required this.itemWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );

    final path = Path();
    final points = <Offset>[];

    final maxTemp = temperatures.reduce(math.max);
    final minTemp = temperatures.reduce(math.min);
    final tempRange = maxTemp - minTemp;

    // Calculate points dengan center alignment
    for (int i = 0; i < temperatures.length; i++) {
      final x = (i * itemWidth) + (itemWidth / 2); // Center di setiap item
      final normalizedTemp =
          tempRange > 0 ? (temperatures[i] - minTemp) / tempRange : 0.5;
      final y = size.height * 0.7 - (normalizedTemp * size.height * 0.4);
      points.add(Offset(x, y));
    }

    // Draw smooth curve
    if (points.length > 1) {
      for (int i = 0; i < points.length - 1; i++) {
        final p0 = i > 0 ? points[i - 1] : points[i];
        final p1 = points[i];
        final p2 = points[i + 1];
        final p3 = i + 2 < points.length ? points[i + 2] : p2;

        final controlPoint1 = Offset(
          p1.dx + (p2.dx - p0.dx) / 6,
          p1.dy + (p2.dy - p0.dy) / 6,
        );
        final controlPoint2 = Offset(
          p2.dx - (p3.dx - p1.dx) / 6,
          p2.dy - (p3.dy - p1.dy) / 6,
        );

        if (i == 0) {
          path.moveTo(p1.dx, p1.dy);
        }

        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          p2.dx,
          p2.dy,
        );
      }
      canvas.drawPath(path, linePaint);
    }

    // Draw points and temperature labels
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      
      // Draw point
      canvas.drawCircle(point, 4, pointPaint);

      // Draw temperature text
      final textSpan = TextSpan(
        text: '${temperatures[i]}°',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      
      final textOffset = Offset(
        point.dx - textPainter.width / 2,
        point.dy - textPainter.height - 8,
      );
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}