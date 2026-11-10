import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/habit_rewards.dart';

class HeroHabitsCard extends StatelessWidget {
  const HeroHabitsCard({
    super.key,
    required this.habitsCount,
    required this.totalPoints,
    required this.completedToday,
  });

  final int habitsCount;
  final int totalPoints;
  final int completedToday;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E513C), Color(0xFF1B3828), Color(0xFF132A1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B3828).withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 8,
            children: [
              Text(
                "RUTINAS DIARIAS ✨",
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: const Color(0xFFA5D6A7),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$habitsCount configurados",
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFC8E6C9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Cultiva tu disciplina",
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${HabitRewards.basePoints} puntos por cada hábito completado y '
            '${HabitRewards.streakBonus} extra cada '
            '${HabitRewards.bonusInterval} días de racha.',
            style: GoogleFonts.outfit(
              fontSize: 12.5,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _summaryPill(Icons.stars_outlined, '$totalPoints puntos'),
              _summaryPill(
                Icons.task_alt,
                habitsCount == 0
                    ? 'Sin hábitos para hoy'
                    : '$completedToday de $habitsCount completados hoy',
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: habitsCount == 0 ? 0 : completedToday / habitsCount,
            minHeight: 6,
            borderRadius: BorderRadius.circular(6),
            color: const Color(0xFFC8E6C9),
            backgroundColor: Colors.white.withValues(alpha: 0.14),
            semanticsLabel:
                'Hábitos completados hoy: $completedToday de $habitsCount',
          ),
        ],
      ),
    );
  }

  Widget _summaryPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFC8E6C9)),
          Text(
            text,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
