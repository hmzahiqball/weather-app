import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:weather_app/widget/build_shimmerEffect.dart';

class BuildIndexUV extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  const BuildIndexUV({super.key, required this.weatherData});

  Future<int> loadUvIndex() async {
    try {
      final data = weatherData;

      final now = DateFormat("yyyy-MM-ddTHH:00").format(DateTime.now());
      final hourlyTimes = List<String>.from(data["hourly"]["time"]);
      final indexNow = hourlyTimes.indexOf(now);

      final uvIndex = data["hourly"]["uv_index"][indexNow];
      return uvIndex.toInt();
    } catch (e) {
      print(e);
      return 0;
    }
  }

  String getDescription(int uv) {
    if (uv < 3) return "Indeks UV rendah";
    if (uv < 6) return "Indeks UV sedang";
    if (uv < 8) return "Indeks UV tinggi";
    if (uv < 11) return "Indeks UV sangat tinggi";
    return "Indeks UV ekstrem";
  }

  String getSuggestion(int uv) {
    if (uv < 3) return "Indeks UV rendah - Tidak perlu tindakan pencegahan khusus.";
    if (uv < 6) return "Indeks UV sedang - Disarankan menggunakan sunscreen.";
    if (uv < 8) return "Indeks UV tinggi - Gunakan sunscreen, topi, dan kacamata hitam.";
    if (uv < 11) return "Indeks UV sangat tinggi - Hindari sinar matahari langsung, gunakan sunscreen, payung, atau cari tempat teduh.";
    return "Indeks UV ekstrem - Sangat berbahaya, hindari keluar rumah jika memungkinkan.";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: loadUvIndex(),
      builder: (context, snapshot) {
        final uvIndex = snapshot.data ?? 0;
        final desc = ' | ${getDescription(uvIndex)}';
        final subtitle = getSuggestion(uvIndex);

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
                  const SizedBox(height: 20),
                  // Data utama
                  if (snapshot.connectionState == ConnectionState.waiting)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          shimmerBox(width: MediaQuery.of(context).size.width * 0.7, height: 20),
                          const SizedBox(height: 16),
                          shimmerBox(width: double.infinity, height: 60),
                        ],
                      ),
                    )
                  else if (snapshot.hasError)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Gagal memuat data hujan',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  else if (snapshot.hasData && snapshot.data != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: uvIndex.toString(),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 24,
                              ),
                            ),
                            TextSpan(
                              text: desc,
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
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
