import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RusticTheme {
  // Paleta de Colores Salvia Moderno
  static const Color background = Color(0xFFF2F5F2);     // Fondo suave orgánico y fresco
  static const Color cardBg = Color(0xFFFFFFFF);         // Blanco puro para tarjetas
  static const Color primaryGreen = Color(0xFF1E3A2B);    // Verde esmeralda oscuro / bosque
  static const Color accentGreen = Color(0xFF00C853);     // Verde brillante de acento / online
  static const Color secondaryGreen = Color(0xFF386641);  // Verde medio elegante
  static const Color mintGreen = Color(0xFFA7C957);       // Menta suave
  static const Color softPillBg = Color(0xFFE3EBE4);      // Fondo suave para cápsulas e iconos
  static const Color darkCardBg = Color(0xFF1B3828);      // Fondo para Hero Cards oscuras
  static const Color terracotta = Color(0xFFD97757);      // Acento cálido
  static const Color darkText = Color(0xFF1A261D);        // Texto casi negro estilizado
  static const Color lightText = Color(0xFF6B7A6F);       // Gris salvia para subtítulos
  static const Color alertRed = Color(0xFFD94841);        // Rojo de advertencia moderno
  static const Color borderLight = Color(0xFFE5EAE5);     // Bordes sutiles

  static TextStyle get handwrittenStyle {
    return GoogleFonts.caveat(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: darkText,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primaryGreen,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: secondaryGreen,
        surface: cardBg,
        error: alertRed,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: darkText,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          color: lightText,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE4E2DC), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD4D2CC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE4E2DC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        hintStyle: GoogleFonts.outfit(color: lightText.withOpacity(0.7)),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: primaryGreen,
        textTheme: ButtonTextTheme.primary,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
    );
  }
}
