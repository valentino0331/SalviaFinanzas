import 'package:flutter_test/flutter_test.dart';
import 'package:appdegastos/features/advisor/domain/financial_health_engine.dart';

void main() {
  group('FinancialHealthEngine - 50/30/20 Rule & Scoring (Astrid)', () {
    test('1. Retorna 100/100 cuando no hay gastos iniciales', () {
      final res = FinancialHealthEngine.evaluate(
        totalIncome: 5000.0,
        totalExpense: 0.0,
        totalSaved: 0.0,
        activeMissionsCount: 0,
      );
      expect(res.score, 100);
      expect(res.insufficientData, true);
      expect(res.statusLabel, 'Excelente');
    });

    test('2. Penaliza gastos superiores al 50%', () {
      final res = FinancialHealthEngine.evaluate(
        totalIncome: 5000.0,
        totalExpense: 3000.0,
        totalSaved: 500.0,
        activeMissionsCount: 1,
      );
      expect(res.score, 85);
      expect(res.statusLabel, 'Excelente');
    });

    test('3. Penaliza gastos severos superiores al 80%', () {
      final res = FinancialHealthEngine.evaluate(
        totalIncome: 5000.0,
        totalExpense: 4200.0,
        totalSaved: 200.0,
        activeMissionsCount: 1,
      );
      expect(res.score, 65);
      expect(res.statusLabel, 'Estable');
    });

    test('4. Penaliza ausencia de metas y falta de ahorro', () {
      final res = FinancialHealthEngine.evaluate(
        totalIncome: 5000.0,
        totalExpense: 2000.0,
        totalSaved: 0.0,
        activeMissionsCount: 0,
      );
      expect(res.score, 90);
    });

    test('5. Acota el valor de score entre 0 y 100', () {
      final res = FinancialHealthEngine.evaluate(
        totalIncome: 1000.0,
        totalExpense: 5000.0,
        totalSaved: 0.0,
        activeMissionsCount: 0,
      );
      expect(res.score, inInclusiveRange(0, 100));
    });
  });

  group('FinancialHealthEngine - 50/30/20 Rule & Scoring Tests (Valentino)', () {
    final referenceDate = DateTime(2026, 10, 15);

    test('calculates perfect score (100) when expenses align perfectly with 50/30/20 rule', () {
      final expenses = [
        // Necesidades (50% de 2000 = 1000)
        {'amount': 600.0, 'category': 'Comida', 'date': '2026-10-10T10:00:00'},
        {'amount': 400.0, 'category': 'Transporte', 'date': '2026-10-11T12:00:00'},
        // Deseos (30% de 2000 = 600)
        {'amount': 400.0, 'category': 'Ocio', 'date': '2026-10-12T15:00:00'},
      ];

      final savings = [
        {'id': 1, 'title': 'Laptop Pro', 'target_amount': 3000.0, 'current_amount': 500.0, 'is_completed': false}
      ];

      final report = FinancialHealthEngine.calculate(
        monthlyIncome: 2000.0,
        expenses: expenses,
        savingsMissions: savings,
        referenceDate: referenceDate,
      );

      expect(report.score, greaterThanOrEqualTo(85));
      expect(report.status, FinancialStatus.excelente);
      expect(report.needsSpent, 1000.0);
      expect(report.wantsSpent, 400.0);
      expect(report.needsPercentage, 50.0);
      expect(report.wantsPercentage, 20.0);
    });

    test('penalizes score and marks Moderado when wants/ocio exceeds 30%', () {
      final expenses = [
        {'amount': 500.0, 'category': 'Comida', 'date': '2026-10-10T10:00:00'},
        // Deseos excesivos: 800 de 2000 = 40% (supera el 30%)
        {'amount': 800.0, 'category': 'Ocio', 'date': '2026-10-12T15:00:00'},
      ];

      final report = FinancialHealthEngine.calculate(
        monthlyIncome: 2000.0,
        expenses: expenses,
        savingsMissions: [],
        referenceDate: referenceDate,
      );

      expect(report.score, lessThan(85));
      expect(report.wantsPercentage, 40.0);
      expect(report.tips.any((t) => t.contains('Ocio y Deseos') || t.contains('30%')), isTrue);
    });

    test('penalizes heavily and marks Crítico when total expenses exceed monthly income', () {
      final expenses = [
        {'amount': 1200.0, 'category': 'Comida', 'date': '2026-10-05T10:00:00'},
        {'amount': 700.0, 'category': 'Transporte', 'date': '2026-10-08T12:00:00'},
        {'amount': 500.0, 'category': 'Ocio', 'date': '2026-10-12T15:00:00'},
      ]; // Total = 2400 > 2000

      final report = FinancialHealthEngine.calculate(
        monthlyIncome: 2000.0,
        expenses: expenses,
        savingsMissions: [],
        referenceDate: referenceDate,
      );

      expect(report.score, lessThan(60));
      expect(report.status, FinancialStatus.critico);
      expect(report.isOverBudget, isTrue);
      expect(report.tips.any((t) => t.contains('superan tus ingresos') || t.contains('límite')), isTrue);
    });

    test('gracefully handles zero or negative monthly income with default fallback', () {
      final expenses = [
        {'amount': 300.0, 'category': 'Comida', 'date': '2026-10-10T10:00:00'},
      ];

      final report = FinancialHealthEngine.calculate(
        monthlyIncome: 0.0,
        expenses: expenses,
        savingsMissions: [],
        referenceDate: referenceDate,
      );

      expect(report.score, isNotNull);
      expect(report.score, inInclusiveRange(0, 100));
      expect(report.needsPercentage.isFinite, isTrue);
    });

    test('generates dynamic actionable tip linking leisure reduction to active savings goal', () {
      final expenses = [
        {'amount': 600.0, 'category': 'Comida', 'date': '2026-10-08T10:00:00'},
        {'amount': 500.0, 'category': 'Ocio', 'date': '2026-10-10T15:00:00'},
      ];

      final savings = [
        {'id': 1, 'title': 'Fondo de Emergencia', 'target_amount': 2000.0, 'current_amount': 400.0, 'is_completed': false}
      ];

      final report = FinancialHealthEngine.calculate(
        monthlyIncome: 2000.0,
        expenses: expenses,
        savingsMissions: savings,
        referenceDate: referenceDate,
      );

      final tipForSavings = report.tips.firstWhere(
        (t) => t.contains('Fondo de Emergencia'),
        orElse: () => '',
      );

      expect(tipForSavings, isNotEmpty);
      expect(tipForSavings, contains('Fondo de Emergencia'));
    });
  });
}
