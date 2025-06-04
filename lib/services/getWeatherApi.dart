import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/services/getLocationApi.dart';

class ApiService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  static Future<Map<String, dynamic>> fetchWeatherData({
    String daily = 'weather_code,sunset,sunrise,temperature_2m_min,temperature_2m_max,rain_sum,wind_speed_10m_mean,wind_gusts_10m_mean,cloud_cover_mean',
    String hourly = 'temperature_2m,weather_code,wind_speed_10m,wind_direction_10m,relative_humidity_2m,cloud_cover,precipitation,precipitation_probability,uv_index',
    String current = 'weather_code,is_day,temperature_2m',
    String timezone = 'auto',
  }) async {
    final lokasi = await LocationService.getLocation(); // Ambil lat & lon otomatis
    final latitude = lokasi.latitude;
    final longitude = lokasi.longitude;

    final url = Uri.parse(
      '$_baseUrl?latitude=$latitude&longitude=$longitude'
      '&daily=$daily&hourly=$hourly&current=$current&timezone=$timezone',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
