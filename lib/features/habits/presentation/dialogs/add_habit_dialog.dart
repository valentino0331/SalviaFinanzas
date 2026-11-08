import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme.dart';
import '../../application/habits_providers.dart';
import '../../domain/habit.dart';
import '../../domain/habit_rewards.dart';
import '../../domain/habit_validators.dart';

/// Abre el diálogo para crear un hábito saludable.
void showAddHabitDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const AddHabitDialog(),
  );
}

void showEditHabitDialog(BuildContext context, Habit habit) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AddHabitDialog(habit: habit),
  );
}

class AddHabitDialog extends ConsumerStatefulWidget {
  const AddHabitDialog({super.key, this.habit});

  final Habit? habit;

  @override
  ConsumerState<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends ConsumerState<AddHabitDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit?.title ?? '');
    _descController = TextEditingController(
      text: widget.habit?.description ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);

    try {
      final actions = ref.read(habitsActionsProvider);
      final habit = widget.habit;
      final title = _titleController.text.trim();
      final description = _descController.text.trim();
      if (habit == null) {
        await actions.addHabit(title: title, description: description);
      } else {
        await actions.updateHabit(
          id: habit.id,
          title: title,
          description: description,
        );
      }
      await HapticFeedback.lightImpact();
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            habit == null ? "Nuevo hábito creado" : "Hábito actualizado",
          ),
        ),
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
    final isEditing = widget.habit != null;
    return PopScope(
      canPop: !_saving,
      child: AlertDialog(
        title: Text(
          isEditing ? "Editar Hábito" : "Crear Hábito Saludable",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
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
                  validator: HabitValidators.validateDescription,
                ),
                const SizedBox(height: 12),
                Text(
                  '${HabitRewards.basePoints} puntos por completado. '
                  '+${HabitRewards.streakBonus} extra cada '
                  '${HabitRewards.bonusInterval} días de racha.',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: RusticTheme.lightText,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: Text(
              "Cancelar",
              style: GoogleFonts.outfit(color: RusticTheme.lightText),
            ),
          ),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF009668),
              foregroundColor: Colors.white,
            ),
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    isEditing ? "Guardar cambios" : "Crear",
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}
