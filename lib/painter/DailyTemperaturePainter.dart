import 'package:flutter/material.dart';
import 'dart:math' as math;

class DailyTemperaturePainter extends CustomPainter {
  final List<int> minTemperatures;
  final List<int> maxTemperatures;
  final double itemWidth;

  const DailyTemperaturePainter({
    required this.minTemperatures,
    required this.maxTemperatures,
    required this.itemWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dashedLinePaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );

    final maxTemp = maxTemperatures.reduce(math.max);
    final minTemp = minTemperatures.reduce(math.min);
    final tempRange = maxTemp - minTemp;

    final minPoints = <Offset>[];
    final maxPoints = <Offset>[];

    for (int i = 0; i < minTemperatures.length; i++) {
      final x = (i * itemWidth) + (itemWidth / 2);

      double normalize(int t) => tempRange > 0 ? (t - minTemp) / tempRange : 0.5;

      final yMin = size.height * 0.8 - (normalize(minTemperatures[i]) * size.height * 0.5);
      final yMax = size.height * 0.8 - (normalize(maxTemperatures[i]) * size.height * 0.5);

      minPoints.add(Offset(x, yMin));
      maxPoints.add(Offset(x, yMax));
    }

    // 🔹 Draw smooth line for max points
    final maxPath = _generateSmoothPath(maxPoints);
    canvas.drawPath(maxPath, linePaint);

    // 🔹 Draw smooth line for min points
    final minPath = _generateSmoothPath(minPoints);
    canvas.drawPath(minPath, linePaint);

    // 🔹 Draw dashed lines from max to min at each index
    for (int i = 0; i < minPoints.length; i++) {
      drawDashedLine(canvas, maxPoints[i], minPoints[i], dashedLinePaint);
    }

    // 🔹 Draw circles and texts
    for (int i = 0; i < maxPoints.length; i++) {
      canvas.drawCircle(maxPoints[i], 4, pointPaint);
      canvas.drawCircle(minPoints[i], 4, pointPaint);

      final maxText = TextPainter(
        text: TextSpan(text: '${maxTemperatures[i]}°', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      final minText = TextPainter(
        text: TextSpan(text: '${minTemperatures[i]}°', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      // Tambahin margin antara teks dan titik
      const maxTextMargin = 12.0;
      const minTextMargin = 12.0;

      maxText.paint(
        canvas,
        Offset(maxPoints[i].dx - maxText.width / 2, maxPoints[i].dy - maxTextMargin - maxText.height),
      );
      minText.paint(
        canvas,
        Offset(minPoints[i].dx - minText.width / 2, minPoints[i].dy + minTextMargin),
      );
    }
  }

  void drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    final delta = end - start;
    final distance = delta.distance;
    final direction = delta / distance;

    double current = 0;
    while (current < distance) {
      final from = start + direction * current;
      final to = start + direction * math.min(current + dashWidth, distance);
      canvas.drawLine(from, to, paint);
      current += dashWidth + dashSpace;
    }
  }

  // 🔹 Smooth path using Catmull-Rom spline logic
  Path _generateSmoothPath(List<Offset> points) {
    final path = Path();

    if (points.length < 2) return path;

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i < points.length - 2 ? points[i + 2] : p2;

      final controlPoint1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );
      final controlPoint2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p2.dx,
        p2.dy,
      );
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
