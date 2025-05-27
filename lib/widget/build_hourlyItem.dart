import 'package:flutter/material.dart';

class BuildHourlyitem extends StatelessWidget {
  final String temp;
  final bool isActive;

  const BuildHourlyitem({
    required this.temp,
    required this.isActive,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          temp,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
            fontSize: 16,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
