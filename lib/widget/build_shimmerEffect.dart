import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget shimmerBox({required double width, required double height}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey[600]!,
    highlightColor: Colors.grey[400]!,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color.fromARGB(83, 58, 58, 58),
        borderRadius: BorderRadius.circular(5),
      ),
    ),
  );
}