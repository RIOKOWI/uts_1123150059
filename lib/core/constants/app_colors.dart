import 'package:flutter/material.dart';

class AppColors {
  // Primary Blue
  static const Color primary = Color.fromARGB(255, 105, 145, 197);
  static const Color primaryLight = Color(0xFFABC9E8);
  static const Color primaryDark = Color(0xFF688EBC);
  static const Color primarySurface = Color(0xFFF0F5FA);
  static const Color primaryBorder = Color(0xFFD0E0F0);

  // Semantic
  static const Color green = Color(0xFF16A571);
  static const Color greenSurface = Color(0xFFE8F8F2);
  static const Color amber = Color(0xFFD98512);
  static const Color amberSurface = Color(0xFFFDF3E3);
  static const Color red = Color(0xFFE5484D);
  static const Color redSurface = Color(0xFFFDECED);
  static const Color violet = Color(0xFF7A5AF8);
  static const Color violetSurface = Color(0xFFF0EEFF);

  // Neutral
  static const Color ink = Color(0xFF0E1726);
  static const Color slate600 = Color(0xFF4B5E78);
  static const Color slate500 = Color(0xFF6B7A90);
  static const Color slate400 = Color(0xFF9DABBE);
  static const Color slate300 = Color(0xFFCBD2DD);
  static const Color line = Color(0xFFE0E5EC);
  static const Color line2 = Color(0xFFE0E5EC);
  static const Color bg = Color(0xFFE0E5EC); // Neumorphism background
  static const Color white = Color(0xFFE0E5EC); // Surface
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.55, 1.0],
    colors: [primaryLight, primary, primaryDark],
  );

  // Neumorphism Shadows
  static const Color shadowDark = Color(0xFFA3B1C6);
  static const Color shadowLight = Color(0xFFFFFFFF);

  static List<BoxShadow> shadowCard = [
    BoxShadow(
      color: shadowDark.withOpacity(0.5),
      blurRadius: 10,
      spreadRadius: 1,
      offset: const Offset(4, 4),
    ),
    const BoxShadow(
      color: shadowLight,
      blurRadius: 10,
      spreadRadius: 1,
      offset: Offset(-4, -4),
    ),
  ];
  static List<BoxShadow> shadowSoft = shadowCard;
  static List<BoxShadow> shadowPrimary = [
    BoxShadow(
      color: primary.withOpacity(0.4),
      blurRadius: 10,
      spreadRadius: 1,
      offset: const Offset(4, 4),
    ),
  ];

  // Tone map for FeatureIcon
  static Map<String, List<Color>> tones = {
    'blue': [primarySurface, primary],
    'green': [greenSurface, green],
    'amber': [amberSurface, amber],
    'red': [redSurface, red],
    'violet': [violetSurface, violet],
    'slate': [bg, slate600],
  };

  static List<Color> tone(String name) => tones[name] ?? tones['blue']!;
}
