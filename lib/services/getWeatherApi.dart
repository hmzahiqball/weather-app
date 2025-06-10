import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/services/getLocationApi.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  static Future<Map<String, dynamic>> fetchWeatherData({
    String daily = 'weather_code,sunset,sunrise,temperature_2m_min,temperature_2m_max,rain_sum,wind_speed_10m_mean,wind_gusts_10m_mean,cloud_cover_mean',
    String hourly = 'temperature_2m,weather_code,wind_speed_10m,wind_direction_10m,relative_humidity_2m,cloud_cover,precipitation,precipitation_probability,uv_index',
    String current = 'weather_code,is_day,temperature_2m',
    String timezone = 'auto',
  }) async {
    final ({double latitude, double longitude, String city}) lokasi =
        await LocationService.getCachedLocation() ??
            await LocationService.getLocation();

    final url = Uri.parse(
      '$_baseUrl?latitude=${lokasi.latitude}&longitude=${lokasi.longitude}'
      '&daily=$daily&hourly=$hourly&current=$current&timezone=$timezone',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final weatherData = json.decode(response.body) as Map<String, dynamic>;
      await _saveToCache(weatherData);
      return weatherData;
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  static Future<void> _saveToCache(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('weatherData', json.encode(data));
  }

  static Future<Map<String, dynamic>?> getCachedWeatherData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? weatherDataString = prefs.getString('weatherData');
    if (weatherDataString != null) {
      return json.decode(weatherDataString) as Map<String, dynamic>;
    }
    return null;
  }
}
