import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class AppColors {
  static const Color background = Color(0xFFEEEAE1); 
  static const Color card = Color(0xFFFFFFFF);
  static const Color heroStart = Color(0xFF3E6E22);
  static const Color heroEnd = Color(0xFF2F5A1B);
  static const Color brandGreen = Color(0xFF2B5A17); 
  static const Color actionGreen = Color(0xFF2DB84D);
  static const Color pillGreen = Color(0xFFCFE8C2); 
  static const Color ringTrack = Color(0xFFE3F1DD); 
  static const Color textDark = Color(0xFF1B2A14);
  static const Color textMuted = Color(0xFF6C7468);
  static const Color border = Color(0xFFE8E4DA);
  static const Color danger = Color(0xFFD94841);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.brandGreen,
      surface: AppColors.card,
    ),
  );
  return base.copyWith(
    textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textDark,
      displayColor: AppColors.textDark,
    ),
  );
}
