import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HabitsTopBar extends StatelessWidget {
  const HabitsTopBar({super.key, required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "SALVIA",
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
                color: const Color(0xFF526E5D),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Hábitos",
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF132A1D),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF355240),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: GoogleFonts.outfit(
                  color: const Color(0xFFC3E7C9),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF3F6F3), width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
