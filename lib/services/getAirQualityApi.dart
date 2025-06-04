import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/services/getLocationApi.dart';

class AirApiService {
  static const String _baseUrl = 'https://air-quality-api.open-meteo.com/v1/air-quality';

  static Future<Map<String, dynamic>> fetchWeatherData({
    String hourly = 'us_aqi_pm2_5',
    String timezone = 'auto',
  }) async {
    final lokasi = await LocationService.getLocation(); // Ambil lat & lon otomatis
    final latitude = lokasi.latitude;
    final longitude = lokasi.longitude;

    final url = Uri.parse(
      '$_baseUrl?latitude=$latitude&longitude=$longitude'
      '&hourly=$hourly&timezone=$timezone',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load air quality data');
    }
  }
}
