import 'package:flutter/material.dart';

IconData getIconDataFromString(String iconName) {
  switch (iconName) {
    case 'Icons.wb_sunny':
      return Icons.wb_sunny;
    case 'Icons.wb_cloudy':
      return Icons.wb_cloudy;
    case 'Icons.foggy':
      return Icons.foggy;
    case 'Icons.cloudy_snowing':
      return Icons.cloudy_snowing;
    case 'Icons.ac_unit':
      return Icons.ac_unit;
    case 'Icons.thunderstorm':
      return Icons.thunderstorm;
    default:
      return Icons.wb_sunny;
  }
}
