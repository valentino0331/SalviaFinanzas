import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showHabitCompletedDialog(BuildContext context, String title, int points) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.stars,
              color: Color(0xFFFFB300),
              size: 60,
            ),
            const SizedBox(height: 14),
            Text(
              "¡Buen Trabajo!",
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E3A2B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Has completado: \"$title\".\n\n¡Ganaste +$points puntos! 🌻",
              style: GoogleFonts.outfit(fontSize: 13.5, color: const Color(0xFF132A1D)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009668),
                foregroundColor: Colors.white,
              ),
              child: Text("Continuar", style: GoogleFonts.outfit()),
            ),
          ),
        ],
      );
    },
  );
}
