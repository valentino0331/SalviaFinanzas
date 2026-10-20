import 'package:flutter_test/flutter_test.dart';
import 'package:appdegastos/features/expenses/domain/expense_aggregation.dart';

void main() {
  group('ExpensePeriod Enum and Extension Tests', () {
    test('returns correct labels and titles for each period', () {
      expect(ExpensePeriod.month.label, equals('Este Mes'));
      expect(ExpensePeriod.month.heroTitle, equals('GASTO TOTAL DEL MES'));
      expect(ExpensePeriod.month.badgeLabel, equals('Este mes'));

      expect(ExpensePeriod.week.label, equals('Esta Semana'));
      expect(ExpensePeriod.week.heroTitle, equals('GASTO DE ESTA SEMANA'));
      expect(ExpensePeriod.week.badgeLabel, equals('Esta semana'));

      expect(ExpensePeriod.all.label, equals('Histórico'));
      expect(ExpensePeriod.all.heroTitle, equals('GASTO TOTAL HISTÓRICO'));
      expect(ExpensePeriod.all.badgeLabel, equals('Todo'));
    });
  });

  group('ExpenseAggregation filterByPeriod Tests', () {
    final refDate = DateTime(2026, 10, 6, 12, 0); // Martes 06 de Octubre 2026

    final mockExpenses = [
      {'id': 1, 'amount': 25.50, 'category': 'Comida', 'date': '2026-10-06T10:00:00'}, // Misma semana y mes
      {'id': 2, 'amount': 14.00, 'category': 'Transporte', 'date': '2026-10-05T08:30:00'}, // Lunes misma semana
      {'id': 3, 'amount': 120.00, 'category': 'Universidad', 'date': '2026-10-01T15:00:00'}, // Mismo mes, semana anterior
      {'id': 4, 'amount': 85.00, 'category': 'Gym', 'date': '2026-09-28T18:00:00'}, // Mes anterior (Sep)
      {'id': 5, 'amount': 50.00, 'category': 'Ocio', 'date': 'invalid-date'}, // Fecha corrupta
    ];

    test('ExpensePeriod.all returns all expenses', () {
      final result = ExpenseAggregation.filterByPeriod(
        mockExpenses,
        ExpensePeriod.all,
        referenceDate: refDate,
      );
      expect(result.length, equals(5));
    });

    test('ExpensePeriod.month returns only expenses from October 2026', () {
      final result = ExpenseAggregation.filterByPeriod(
        mockExpenses,
        ExpensePeriod.month,
        referenceDate: refDate,
      );
      expect(result.length, equals(3));
      expect(result.map((e) => e['id']), containsAll([1, 2, 3]));
      expect(result.map((e) => e['id']), isNot(contains(4)));
      expect(result.map((e) => e['id']), isNot(contains(5)));
    });

    test('ExpensePeriod.week returns only expenses from Monday 05 to Sunday 11 Oct 2026', () {
      final result = ExpenseAggregation.filterByPeriod(
        mockExpenses,
        ExpensePeriod.week,
        referenceDate: refDate,
      );
      expect(result.length, equals(2));
      expect(result.map((e) => e['id']), containsAll([1, 2]));
      expect(result.map((e) => e['id']), isNot(contains(3)));
      expect(result.map((e) => e['id']), isNot(contains(4)));
    });
  });

  group('ExpenseAggregation calculateTotal & groupByCategory Tests', () {
    test('calculateTotal sums all positive numbers properly', () {
      final expenses = [
        {'amount': '30.50'},
        {'amount': 19.50},
        {'amount': 0},
        {'amount': -10},
      ];
      final total = ExpenseAggregation.calculateTotal(expenses);
      expect(total, equals(50.0));
    });

    test('calculateTotal returns 0.0 for empty list', () {
      expect(ExpenseAggregation.calculateTotal([]), equals(0.0));
    });

    test('groupByCategory aggregates by category and sorts descending', () {
      final expenses = [
        {'amount': 30.0, 'category': 'Comida'},
        {'amount': 50.0, 'category': 'Transporte'},
        {'amount': 70.0, 'category': 'Comida'},
        {'amount': 20.0, 'category': 'Ocio'},
      ];

      final grouped = ExpenseAggregation.groupByCategory(expenses);

      expect(grouped['Comida'], equals(100.0));
      expect(grouped['Transporte'], equals(50.0));
      expect(grouped['Ocio'], equals(20.0));

      final keys = grouped.keys.toList();
      expect(keys, equals(['Comida', 'Transporte', 'Ocio']));
    });
  });

  group('ExpenseAggregation calculateBreakdown & Daily Average Tests', () {
    test('calculateBreakdown returns percentage and sorts categories correctly', () {
      final expenses = [
        {'amount': 50.0, 'category': 'Comida'},
        {'amount': 50.0, 'category': 'Transporte'},
      ];

      final breakdown = ExpenseAggregation.calculateBreakdown(expenses);

      expect(breakdown.length, equals(2));
      expect(breakdown[0].category, equals('Comida'));
      expect(breakdown[0].percentage, equals(50.0));
      expect(breakdown[1].category, equals('Transporte'));
      expect(breakdown[1].percentage, equals(50.0));
    });

    test('calculateDailyAverage computes burn rate based on elapsed days', () {
      final refDate = DateTime(2026, 10, 6); // Día 6 del mes, Martes (día 2 de la semana)

      // Semana: S/ 100 gastados en 2 días (Lunes y Martes) = S/ 50.00 / día
      final avgWeek = ExpenseAggregation.calculateDailyAverage(
        100.0,
        ExpensePeriod.week,
        referenceDate: refDate,
      );
      expect(avgWeek, equals(50.0));

      // Mes: S/ 300 gastados en 6 días = S/ 50.00 / día
      final avgMonth = ExpenseAggregation.calculateDailyAverage(
        300.0,
        ExpensePeriod.month,
        referenceDate: refDate,
      );
      expect(avgMonth, equals(50.0));
    });

    test('calculateDailyAverage returns 0.0 when total is zero or negative', () {
      expect(ExpenseAggregation.calculateDailyAverage(0.0, ExpensePeriod.month), equals(0.0));
      expect(ExpenseAggregation.calculateDailyAverage(-20.0, ExpensePeriod.week), equals(0.0));
    });
  });
}
