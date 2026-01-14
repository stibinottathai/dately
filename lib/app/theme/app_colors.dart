import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFEE2B7C);
  static const Color backgroundLight = Color(0xFFF8F6F7);
  static const Color backgroundDark = Color(0xFF221018);
  static const Color white = Colors.white;

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEE2B7C), Color(0xFF632C90)],
  );
}
