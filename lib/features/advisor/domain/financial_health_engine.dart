import 'dart:math';

/// Semáforo de salud financiera
enum FinancialStatus {
  excelente,
  moderado,
  critico,
}

extension FinancialStatusExtension on FinancialStatus {
  String get label {
    switch (this) {
      case FinancialStatus.excelente:
        return 'Excelente';
      case FinancialStatus.moderado:
        return 'Moderado';
      case FinancialStatus.critico:
        return 'Crítico';
    }
  }

  String get description {
    switch (this) {
      case FinancialStatus.excelente:
        return 'Tus finanzas están en excelente estado.\nMantienes un equilibrio óptimo según la regla 50/30/20.';
      case FinancialStatus.moderado:
        return 'Buen camino, pero hay detalles por pulir.\nRevisa tus gastos recurrentes y ocio.';
      case FinancialStatus.critico:
        return 'Tus finanzas requieren atención inmediata.\nIntenta reducir gastos superfluos para no caer en déficit.';
    }
  }
}

/// Reporte inmutable del motor de salud financiera
class FinancialHealthReport {
  final int score;
  final FinancialStatus status;
  final double monthlyIncome;
  final double totalSpent;
  final double needsSpent;
  final double wantsSpent;
  final double savingsAllocated;
  final double needsPercentage;
  final double wantsPercentage;
  final double savingsPercentage;
  final bool isOverBudget;
  final List<String> tips;
  final Map<String, double> categoryBreakdown;

  const FinancialHealthReport({
    required this.score,
    required this.status,
    required this.monthlyIncome,
    required this.totalSpent,
    required this.needsSpent,
    required this.wantsSpent,
    required this.savingsAllocated,
    required this.needsPercentage,
    required this.wantsPercentage,
    required this.savingsPercentage,
    required this.isOverBudget,
    required this.tips,
    required this.categoryBreakdown,
  });

  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'status': status.label,
      'monthly_income': monthlyIncome,
      'total_spent_30_days': totalSpent,
      'needs_spent': needsSpent,
      'wants_spent': wantsSpent,
      'savings_allocated': savingsAllocated,
      'needs_percentage': needsPercentage,
      'wants_percentage': wantsPercentage,
      'savings_percentage': savingsPercentage,
      'is_over_budget': isOverBudget,
      'tips': tips,
      'category_summary': categoryBreakdown,
    };
  }
}

/// Motor de Asesoría Financiera Algorítmica basado en la regla 50/30/20
class FinancialHealthEngine {
  static const double defaultIncomeFallback = 1500.0;

  // Clasificación de categorías estándar
  static const Set<String> needsCategories = {
    'Comida',
    'Transporte',
    'Vivienda',
    'Servicios',
    'Salud',
    'Educación',
    'Universidad',
  };

  static const Set<String> wantsCategories = {
    'Ocio',
    'Restaurantes',
    'Salidas',
    'Entretenimiento',
    'Compras',
    'Suscripciones',
  };

  /// Calcula el diagnóstico de salud financiera evaluando los últimos 30 días
  static FinancialHealthReport calculate({
    required double monthlyIncome,
    required List<dynamic> expenses,
    required List<dynamic> savingsMissions,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    // Sanitizar ingresos mensuales para evitar división por cero
    final effectiveIncome = monthlyIncome > 0 ? monthlyIncome : defaultIncomeFallback;

    // Filtrar gastos de los últimos 30 días
    final recentExpenses = expenses.where((e) {
      final dateStr = e['date']?.toString();
      if (dateStr == null) return false;
      try {
        final d = DateTime.parse(dateStr);
        return d.isAfter(thirtyDaysAgo) || d.isAtSameMomentAs(thirtyDaysAgo);
      } catch (_) {
        return false;
      }
    }).toList();

    double totalSpent = 0.0;
    double needsSpent = 0.0;
    double wantsSpent = 0.0;
    final Map<String, double> categoryBreakdown = {};

    for (final exp in recentExpenses) {
      final amt = double.tryParse(exp['amount']?.toString() ?? '0') ?? 0.0;
      final cat = (exp['category'] ?? 'Otros').toString();

      totalSpent += amt;
      categoryBreakdown[cat] = (categoryBreakdown[cat] ?? 0.0) + amt;

      if (wantsCategories.contains(cat)) {
        wantsSpent += amt;
      } else {
        // Por defecto asumimos categoría de necesidad si no es ocio directo
        needsSpent += amt;
      }
    }

    // Calcular aportes o misiones de ahorro activas
    final activeMissions = savingsMissions.where((m) => m['is_completed'] == false).toList();
    double totalSavingsCurrent = 0.0;
    for (final m in activeMissions) {
      totalSavingsCurrent += double.tryParse(m['current_amount']?.toString() ?? '0') ?? 0.0;
    }

    // Porcentajes relativos al ingreso mensual (Regla 50/30/20)
    final needsPercentage = (needsSpent / effectiveIncome) * 100.0;
    final wantsPercentage = (wantsSpent / effectiveIncome) * 100.0;
    final savingsPercentage = (totalSavingsCurrent / effectiveIncome) * 100.0;
    final isOverBudget = totalSpent > effectiveIncome;

    // Algoritmo de puntaje (Base 100)
    double calculatedScore = 100.0;

    // Penalidad por exceso en necesidades (>50%)
    if (needsPercentage > 50.0) {
      final excess = needsPercentage - 50.0;
      calculatedScore -= min(30.0, 8.0 + (excess * 0.8));
    }

    // Penalidad por exceso en deseos/ocio (>30%)
    if (wantsPercentage > 30.0) {
      final excess = wantsPercentage - 30.0;
      calculatedScore -= min(35.0, 10.0 + (excess * 1.0));
    }

    // Penalidad severa por déficit presupuestario
    if (isOverBudget) {
      calculatedScore -= 25.0;
    }

    // Bonificación si el ahorro estimado cumple o supera el 20%
    if (savingsPercentage >= 20.0 && !isOverBudget) {
      calculatedScore = min(100.0, calculatedScore + 5.0);
    }

    // Ajuste de límites [0, 100]
    final score = calculatedScore.clamp(0.0, 100.0).round();

    // Determinar estado semafórico
    FinancialStatus status;
    if (score >= 85) {
      status = FinancialStatus.excelente;
    } else if (score >= 60) {
      status = FinancialStatus.moderado;
    } else {
      status = FinancialStatus.critico;
    }

    // Generar consejos inteligentes y accionables
    final List<String> tips = [];

    if (isOverBudget) {
      tips.add(
        '⚠️ Alerta: Tus gastos de este mes (S/ ${totalSpent.toStringAsFixed(2)}) superan tus ingresos sugeridos (S/ ${effectiveIncome.toStringAsFixed(2)}). Prioriza sólo necesidades esenciales.',
      );
    }

    if (wantsPercentage > 30.0) {
      tips.add(
        'Tus gastos en Ocio y Deseos (S/ ${wantsSpent.toStringAsFixed(2)}) representan el ${wantsPercentage.toStringAsFixed(0)}% de tus ingresos, superando el 30% sugerido por la regla 50/30/20.',
      );
    }

    if (needsPercentage > 65.0) {
      tips.add(
        'Tus costos fijos y necesidades básicas consumen el ${needsPercentage.toStringAsFixed(0)}% de tus ingresos. Evalúa renegociar servicios o preparar más comidas en casa.',
      );
    }

    // Consejo sinérgico con la Bóveda de Ahorros
    if (activeMissions.isNotEmpty) {
      final mainMission = activeMissions.first;
      final target = double.tryParse(mainMission['target_amount']?.toString() ?? '0') ?? 0.0;
      final current = double.tryParse(mainMission['current_amount']?.toString() ?? '0') ?? 0.0;
      final remaining = max(0.0, target - current);

      if (wantsSpent > 0 && remaining > 0) {
        final potentialSaving = min(wantsSpent * 0.35, remaining);
        tips.add(
          '💡 Consejo Salvia: Si recortas el 35% de tus gastos en Ocio de este mes, podrías acelerar tu meta \'${mainMission['title']}\' sumándole S/ ${potentialSaving.toStringAsFixed(2)}.',
        );
      }
    } else {
      tips.add(
        'Aún no tienes metas de ahorro activas en tu Bóveda. Crear una meta te ayudará a proteger tu excedente mensual.',
      );
    }

    if (tips.isEmpty) {
      tips.add(
        '¡Excelente disciplina! Tus gastos se mantienen alineados con la regla 50/30/20. Continúa fortaleciendo tus misiones de ahorro.',
      );
    }

    return FinancialHealthReport(
      score: score,
      status: status,
      monthlyIncome: effectiveIncome,
      totalSpent: totalSpent,
      needsSpent: needsSpent,
      wantsSpent: wantsSpent,
      savingsAllocated: totalSavingsCurrent,
      needsPercentage: needsPercentage,
      wantsPercentage: wantsPercentage,
      savingsPercentage: savingsPercentage,
      isOverBudget: isOverBudget,
      tips: tips,
      categoryBreakdown: categoryBreakdown,
    );
  }
}
