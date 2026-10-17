import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_theme.dart';
import '../application/advisor_stub.dart';


class HealthCard extends ConsumerWidget {
  const HealthCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(advisorHealthProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Row(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: health.score / 100,
                    strokeWidth: 5,
                    backgroundColor: AppColors.ringTrack,
                    color: health.color,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '${health.score}',
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: 'Salud Financiera: ',
                    style: GoogleFonts.outfit(fontSize: 14.5, fontWeight: FontWeight.w800),
                    children: [
                      TextSpan(
                        text: health.status,
                        style: TextStyle(color: health.color),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  health.tip,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    height: 1.3,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final BoxDecoration _cardDecoration = BoxDecoration(
  color: AppColors.card,
  borderRadius: BorderRadius.circular(22),
  border: Border.all(color: AppColors.border),
);
