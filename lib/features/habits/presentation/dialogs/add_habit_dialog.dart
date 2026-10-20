import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme.dart';
import '../../../../core/providers.dart';

void showAddHabitDialog(BuildContext context, WidgetRef ref) {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final pointsController = TextEditingController(text: "15");

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Crear Hábito Saludable", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Hábito",
                  hintText: "Ej. Leer 15 mins, Hacer ejercicio",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: "Descripción corta",
                  hintText: "Ej. Para cultivar mi mente y bienestar",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pointsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Recompensa de Puntos",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar", style: GoogleFonts.outfit(color: RusticTheme.lightText)),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final desc = descController.text.trim();
              final pts = int.tryParse(pointsController.text) ?? 10;

              if (title.isNotEmpty) {
                await HapticFeedback.lightImpact();
                ref.read(habitsProvider.notifier).addHabit(title, desc, pts);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("¡Nuevo hábito sembrado! 🌱")),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF009668),
              foregroundColor: Colors.white,
            ),
            child: Text("Crear", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );
}
