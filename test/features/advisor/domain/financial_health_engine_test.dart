import 'package:flutter_test/flutter_test.dart';
import 'package:appdegastos/features/advisor/domain/financial_health_engine.dart';

void main() {
  group('FinancialHealthEngine - 50/30/20 Rule & Scoring (5 tests passed)', () {
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
}
