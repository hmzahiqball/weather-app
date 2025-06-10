import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:weather_app/widget/build_shimmerEffect.dart';

class BuildWeathercard extends StatelessWidget {
  final String? title;
  final String? temp;
  final String? description;
  final IconData? icon;
  final bool isLoading;

  const BuildWeathercard({
    this.title,
    this.temp,
    this.description,
    this.icon,
    this.isLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  isLoading
                      ? shimmerBox(width: 18, height: 18)
                      : Icon(
                          icon,
                          color: Colors.white.withOpacity(0.9),
                          size: 18,
                        ),
                  const SizedBox(width: 8),
                  isLoading
                      ? shimmerBox(width: 80, height: 14)
                      : Text(
                          title ?? '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 8),
              isLoading
                  ? shimmerBox(width: 60, height: 17)
                  : Text(
                      temp ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              const SizedBox(height: 4),
              isLoading
                  ? shimmerBox(width: 100, height: 12)
                  : Text(
                      description ?? '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

