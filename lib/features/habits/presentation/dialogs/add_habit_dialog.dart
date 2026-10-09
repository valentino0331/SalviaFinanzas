import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme.dart';
import '../../application/habits_providers.dart';
import '../../domain/habit_validators.dart';

/// Abre el diálogo para crear un hábito saludable.
void showAddHabitDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => const AddHabitDialog(),
  );
}

class AddHabitDialog extends ConsumerStatefulWidget {
  const AddHabitDialog({super.key});

  @override
  ConsumerState<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends ConsumerState<AddHabitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _pointsController = TextEditingController(
    text: HabitValidators.defaultPoints.toString(),
  );

  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);

    try {
      await ref.read(habitsActionsProvider).addHabit(
            title: _titleController.text.trim(),
            description: _descController.text.trim(),
            pointsReward: HabitValidators.parsePoints(_pointsController.text),
          );
      await HapticFeedback.lightImpact();
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text("¡Nuevo hábito sembrado! 🌱")),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: const Color(0xFFD94841),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Crear Hábito Saludable", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                enabled: !_saving,
                textCapitalization: TextCapitalization.sentences,
                maxLength: HabitValidators.maxTitleLength,
                decoration: const InputDecoration(
                  labelText: "Hábito",
                  hintText: "Ej. Leer 15 mins, Hacer ejercicio",
                ),
                validator: HabitValidators.validateTitle,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                enabled: !_saving,
                maxLength: HabitValidators.maxDescriptionLength,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: "Descripción corta",
                  hintText: "Ej. Para cultivar mi mente y bienestar",
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pointsController,
                enabled: !_saving,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: "Recompensa de Puntos",
                ),
                validator: HabitValidators.validatePoints,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: Text("Cancelar", style: GoogleFonts.outfit(color: RusticTheme.lightText)),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _create,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF009668),
            foregroundColor: Colors.white,
          ),
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text("Crear", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
