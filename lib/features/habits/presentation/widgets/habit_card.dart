import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/habit.dart';
import '../../domain/habit_calendar.dart';

enum HabitCardAction { edit, delete }

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isBusy = false,
    this.enabled = true,
    this.day,
  });

  final Habit habit;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isBusy;
  final bool enabled;
  final DateTime? day;

  @override
  Widget build(BuildContext context) {
    final today = day ?? HabitCalendar.today();
    final isCompletedToday = habit.isCompletedOn(today);
    final int streak = habit.streakOn(today);
    final int pts = habit.pointsReward;

    return InkWell(
      onTap: enabled && !isBusy ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: isCompletedToday ? const Color(0xFFEAF4EC) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCompletedToday
                ? const Color(0xFF009668).withValues(alpha: 0.4)
                : const Color(0xFFE7ECE7),
            width: isCompletedToday ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isBusy)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF009668),
                    ),
                  )
                else
                  Icon(
                    isCompletedToday
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isCompletedToday
                        ? const Color(0xFF009668)
                        : const Color(0xFF8B9E8F),
                    size: 20,
                  ),
                if (streak > 0)
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD54F).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "$streak 🔥",
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: const Color(0xFFB37400),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (onEdit != null || onDelete != null)
                  PopupMenuButton<HabitCardAction>(
                    tooltip: 'Opciones de ${habit.title}',
                    enabled: enabled && !isBusy,
                    icon: const Icon(Icons.more_horiz, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 140),
                    onSelected: (action) {
                      switch (action) {
                        case HabitCardAction.edit:
                          onEdit?.call();
                        case HabitCardAction.delete:
                          onDelete?.call();
                      }
                    },
                    itemBuilder: (_) => [
                      if (onEdit != null)
                        const PopupMenuItem(
                          value: HabitCardAction.edit,
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 10),
                              Text('Editar'),
                            ],
                          ),
                        ),
                      if (onDelete != null)
                        const PopupMenuItem(
                          value: HabitCardAction.delete,
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Color(0xFFD94841),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Eliminar',
                                style: TextStyle(color: Color(0xFFD94841)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: isCompletedToday
                          ? const Color(0xFF6B7A6F)
                          : const Color(0xFF132A1D),
                      decoration: isCompletedToday
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    habit.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 10.5,
                      color: const Color(0xFF7A8B7E),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isCompletedToday
                    ? const Color(0xFF009668).withValues(alpha: 0.1)
                    : const Color(0xFFF3F6F3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "+$pts pts",
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isCompletedToday
                      ? const Color(0xFF009668)
                      : const Color(0xFF2E513C),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
