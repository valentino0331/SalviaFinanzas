class FinancialScore {
  final int score;
  final String statusLabel;
  final String description;
  final bool insufficientData;

  const FinancialScore({
    required this.score,
    required this.statusLabel,
    required this.description,
    required this.insufficientData,
  });
}

class FinancialHealthEngine {
  FinancialHealthEngine._();

  static FinancialScore evaluate({
    required double totalIncome,
    required double totalExpense,
    required double totalSaved,
    required int activeMissionsCount,
  }) {
    if (totalIncome <= 0 || totalExpense == 0) {
      return const FinancialScore(
        score: 100,
        statusLabel: 'Excelente',
        description: 'Tus finanzas están en equilibrio orgánico.',
        insufficientData: true,
      );
    }

    double score = 100.0;
    final expenseRatio = totalExpense / totalIncome;

    if (expenseRatio > 0.80) {
      score -= 35;
    } else if (expenseRatio > 0.50) {
      score -= 15;
    }

    if (activeMissionsCount == 0 && totalSaved == 0) {
      score -= 10;
    }

    final finalScore = score.clamp(0.0, 100.0).round();

    String status;
    String desc;
    if (finalScore >= 80) {
      status = 'Excelente';
      desc = 'Tus finanzas están en equilibrio orgánico.';
    } else if (finalScore >= 50) {
      status = 'Estable';
      desc = 'Se sugiere moderar gastos discrecionales este mes.';
    } else {
      status = 'Riesgo';
      desc = 'Tus gastos superan los límites saludables para este ciclo.';
    }

    return FinancialScore(
      score: finalScore,
      statusLabel: status,
      description: desc,
      insufficientData: false,
    );
  }
}
