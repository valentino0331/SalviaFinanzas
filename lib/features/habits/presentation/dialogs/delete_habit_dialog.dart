import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../application/habits_providers.dart';
import '../../domain/habit.dart';

void showDeleteHabitDialog(BuildContext context, Habit habit) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => DeleteHabitDialog(habit: habit),
  );
}

class DeleteHabitDialog extends ConsumerStatefulWidget {
  const DeleteHabitDialog({super.key, required this.habit});

  final Habit habit;

  @override
  ConsumerState<DeleteHabitDialog> createState() => _DeleteHabitDialogState();
}

class _DeleteHabitDialogState extends ConsumerState<DeleteHabitDialog> {
  bool _deleting = false;

  Future<void> _delete() async {
    if (_deleting) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _deleting = true);
    try {
      await ref.read(habitsActionsProvider).deleteHabit(widget.habit.id);
      if (!mounted) return;
      navigator.pop();
      messenger
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(content: Text('Hábito eliminado')));
    } catch (error) {
      if (!mounted) return;
      setState(() => _deleting = false);
      messenger
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceAll('Exception: ', '')),
            backgroundColor: const Color(0xFFD94841),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_deleting,
      child: AlertDialog(
        title: Text(
          '¿Eliminar hábito?',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Text(
            'Se eliminará "${widget.habit.title}". '
            'Esta acción no se puede deshacer.\n\n'
            'Los puntos ya ganados se conservarán.',
            style: GoogleFonts.outfit(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _deleting ? null : () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _deleting ? null : _delete,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD94841),
              foregroundColor: Colors.white,
            ),
            child: _deleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
