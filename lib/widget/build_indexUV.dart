import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

class BuildIndexUV extends StatelessWidget {
  Future<Map<String, dynamic>> loadAllWeatherData() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/dummy2.json',
      );
      final data = json.decode(response);

      // ambil waktu lokal sekarang dalam format yang cocok dengan hourly time
      final now = DateFormat("yyyy-MM-ddTHH:00").format(DateTime.now());
      final hourlyTimes = data["hourly"]["time"] as List;
      final indexNow = hourlyTimes.indexOf(now);

      // ambil data hourly
      final uvIndex = data["hourly"]["uv_index"][indexNow];

      return {
        "uvIndex": uvIndex,
      };
    } catch (e) {
      print(e);
      return {};
    }
  }

  String getIndexUvDescription(int uvIndex) { 
    if (uvIndex < 3) { 
      return "Indeks UV rendah"; 
    } else if (uvIndex < 6) { 
      return "Indeks UV sedang"; 
    } else if (uvIndex < 8) { 
      return "Indeks UV tinggi"; 
    } else if (uvIndex < 11) { 
      return "Indeks UV sangat tinggi"; 
    } else { 
      return "Indeks UV ekstrem"; 
    } 
  }

  String getIndexUvSuggestion(int uvIndex) {
    if (uvIndex < 3) {
      return "Indeks UV rendah - Tidak perlu tindakan pencegahan khusus.";
    } else if (uvIndex < 6) {
      return "Indeks UV sedang - Disarankan menggunakan sunscreen.";
    } else if (uvIndex < 8) {
      return "Indeks UV tinggi - Gunakan sunscreen, topi, dan kacamata hitam.";
    } else if (uvIndex < 11) {
      return "Indeks UV sangat tinggi - Hindari sinar matahari langsung, gunakan sunscreen, payung, atau cari tempat teduh.";
    } else {
      return "Indeks UV ekstrem - Sangat berbahaya, hindari keluar rumah jika memungkinkan.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadAllWeatherData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading rain data',
              style: TextStyle(color: Colors.white),
            ),
          );
        } else {
          final uvIndex = snapshot.data?["uvIndex"] ?? 0;
          return ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(40, 58, 58, 58),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Icon(
                              Icons.wb_sunny,
                              color: Colors.white.withOpacity(0.8),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Indeks UV',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${uvIndex}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 24,
                              ),
                            ),
                            TextSpan(
                              text: ' | ${getIndexUvDescription(uvIndex)}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        getIndexUvSuggestion(uvIndex),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}