import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0B0F19);
  static const Color cardBg = Color(0xFF161C2A);
  static const Color cardBgTranslucent = Color(0xAA161C2A);
  static const Color border = Color(0x22FFFFFF);
  
  static const Color primary = Color(0xFF10B981); // Emerald Green
  static const Color secondary = Color(0xFF06B6D4); // Cyan Blue
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color danger = Color(0xFFEF4444); // Red
  static const Color textMain = Color(0xFFF3F4F6);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textBright = Color(0xFFFFFFFF);

  static const Color primaryGlow = Color(0x3D10B981);
  static const Color secondaryGlow = Color(0x3D06B6D4);
}

class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 16.0;
}
class AppStyles {
  static const TextStyle titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textBright,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 14,
    color: AppColors.textMuted,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    color: AppColors.textMain,
  );

  static const TextStyle monoStyle = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    color: AppColors.textMain,
  );
}
