import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

class BuildIndexUV extends StatelessWidget {
  const BuildIndexUV({super.key});

  Future<int> loadUvIndex() async {
    try {
      final String response = await rootBundle.loadString('assets/json/dummy2.json');
      final data = json.decode(response);
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Gagal load data UV', style: TextStyle(color: Colors.white)));
        }

        final uvIndex = snapshot.data ?? 0;

        return _InfoCard(
          icon: Icons.wb_sunny,
          title: 'Indeks UV',
          value: '$uvIndex',
          desc: ' | ${getDescription(uvIndex)}',
          subtitle: getSuggestion(uvIndex),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String desc;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.desc,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
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
                    Icon(icon, color: Colors.white.withOpacity(0.8), size: 16),
                    const SizedBox(width: 8),
                    Text(title, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: value,
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
                child: Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
