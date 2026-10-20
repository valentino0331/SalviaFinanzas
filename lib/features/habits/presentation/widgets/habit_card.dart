import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.isCompletedToday,
    this.onTap,
  });

  final Map<String, dynamic> habit;
  final bool isCompletedToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final int streak = habit['streak'] ?? 0;
    final int pts = habit['points_reward'] ?? 10;
    final String title = habit['title'] ?? "";
    final String desc = habit['description'] ?? "";

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: isCompletedToday
              ? const Color(0xFFEAF4EC)
              : Colors.white,
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
                Icon(
                  isCompletedToday ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isCompletedToday ? const Color(0xFF009668) : const Color(0xFF8B9E8F),
                  size: 20,
                ),
                if (streak > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: isCompletedToday ? const Color(0xFF6B7A6F) : const Color(0xFF132A1D),
                      decoration: isCompletedToday ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
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
