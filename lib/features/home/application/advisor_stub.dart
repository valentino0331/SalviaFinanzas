import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../expenses/application/gestor_gastos.dart';


class AdvisorHealth {
  const AdvisorHealth({
    required this.score,
    required this.status,
    required this.tip,
  });

  final int score;
  final String status;
  final String tip;

  Color get color {
    if (score >= 70) return const Color(0xFF2DB84D);
    if (score >= 40) return const Color(0xFFE3A857);
    return const Color(0xFFD94841);
  }
}

final advisorHealthProvider = Provider<AdvisorHealth>((ref) {
  final summary = ref.watch(expenseSummaryProvider);

  if (summary.isEmpty || summary.income <= 0) {
    return const AdvisorHealth(
      score: 100,
      status: 'Excelente',
      tip: 'Aún no tienes misiones activas. Añade una para dar dirección a tus finanzas.',
    );
  }

  final ratio = summary.total / summary.income;
  final score = (100 - ratio * 100).clamp(0, 100).round();

  if (score >= 70) {
    return AdvisorHealth(
      score: score,
      status: 'Excelente',
      tip: 'Vas muy bien: tus gastos están bajo control este mes.',
    );
  }
  if (score >= 40) {
    return AdvisorHealth(
      score: score,
      status: 'Moderado',
      tip: 'Ya usaste más de la mitad de tus ingresos. Revisa tus gastos hormiga.',
    );
  }
  return AdvisorHealth(
    score: score,
    status: 'Crítico',
    tip: 'Estás cerca de agotar tus ingresos del mes. Prioriza lo esencial.',
  );
});
