import 'package:flutter/material.dart';
import 'package:weather_app/services/getLocationApi.dart';
import 'package:weather_app/widget/build_shimmerEffect.dart';

class BuildHeader extends StatelessWidget {
  const BuildHeader({super.key});

  Future<String> _getCityName() async {
    final lokasi = await LocationService.getLocation();
    return lokasi.city;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FutureBuilder<String>(
            future: _getCityName(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return shimmerBox(width: 120, height: 20);
              } else if (snapshot.hasData) {
                return Text(
                  snapshot.data!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                );
              } else {
                return const Text(
                  'Lokasi tidak ditemukan',
                  style: TextStyle(color: Colors.white),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
