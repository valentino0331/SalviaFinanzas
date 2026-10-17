import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_theme.dart';
import '../../expenses/application/gestor_gastos.dart';
import '../../expenses/domain/expense_category.dart';


class CategoryChartCard extends StatelessWidget {
  const CategoryChartCard({super.key, required this.summary});

  final ExpenseSummary summary;

 
  static const _placeholderLegend = [
    ExpenseCategory.alimentacion,
    ExpenseCategory.transporte,
    ExpenseCategory.otros,
  ];

  List<PieChartSectionData> _sections() {
    if (summary.isEmpty) {

      return [
        PieChartSectionData(value: 12, color: AppColors.actionGreen, title: '', radius: 14),
        PieChartSectionData(value: 70, color: AppColors.ringTrack, title: '', radius: 14),
        PieChartSectionData(
          value: 18,
          color: AppColors.actionGreen.withValues(alpha: 0.35),
          title: '',
          radius: 14,
        ),
      ];
    }
    return summary.sortedCategories
        .map((e) => PieChartSectionData(
              value: e.value,
              color: e.key.color,
              title: '',
              radius: 16,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final empty = summary.isEmpty;
    final legend = empty
        ? _placeholderLegend.map((c) => MapEntry(c, 0.0)).toList()
        : summary.sortedCategories;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 116,
            height: 116,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: _sections(),
                    centerSpaceRadius: 36,
                    sectionsSpace: empty ? 0 : 2,
                    startDegreeOffset: -90,
                    borderData: FlBorderData(show: false),
                  ),
                ),
                Text(
                  empty ? 'Sin\ngastos' : 'S/ ${summary.total.toStringAsFixed(0)}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: empty ? 11 : 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: AppColors.textDark.withValues(alpha: empty ? 0.65 : 1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  empty ? 'Sin gastos registrados' : 'Gastos por categoría',
                  style: GoogleFonts.outfit(fontSize: 14.5, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  empty
                      ? 'Registra tus gastos para ver tu distribución.'
                      : 'Distribución de este mes.',
                  style: GoogleFonts.outfit(
                    fontSize: 11.5,
                    height: 1.3,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                for (final entry in legend)
                  _LegendRow(
                    category: entry.key,
                    percentText: empty
                        ? '— %'
                        : '${summary.percentOf(entry.key).toStringAsFixed(0)}%',
                    muted: empty,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.category,
    required this.percentText,
    required this.muted,
  });

  final ExpenseCategory category;
  final String percentText;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final color = muted ? category.color.withValues(alpha: 0.45) : category.color;
    final textColor = muted ? AppColors.textMuted.withValues(alpha: 0.7) : AppColors.textDark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              category.label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          Text(
            percentText,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
