import 'package:flutter_test/flutter_test.dart';
import 'package:appdegastos/features/savings/domain/savings_mission_model.dart';

void main() {
  group('SavingsMission Domain Model', () {
    test('fromMap parses JSON correctly with numeric string inputs', () {
      final map = {
        'id': 1,
        'title': 'Viaje a Cusco',
        'target_amount': '1200.00',
        'current_amount': '600.00',
        'icon_name': 'flight',
        'deadline': '2026-12-31',
        'is_completed': false,
      };

      final mission = SavingsMission.fromMap(map);

      expect(mission.id, 1);
      expect(mission.title, 'Viaje a Cusco');
      expect(mission.targetAmount, 1200.0);
      expect(mission.currentAmount, 600.0);
      expect(mission.iconName, 'flight');
      expect(mission.deadline, '2026-12-31');
      expect(mission.isCompleted, false);
    });

    test('progressFraction calculates ratio and clamps between 0.0 and 1.0', () {
      final zeroTarget = SavingsMission(
        id: 1, title: 'Zero', targetAmount: 0.0, currentAmount: 50.0, isCompleted: false);
      expect(zeroTarget.progressFraction, 0.0);

      final half = SavingsMission(
        id: 2, title: 'Half', targetAmount: 200.0, currentAmount: 100.0, isCompleted: false);
      expect(half.progressFraction, 0.5);
      expect(half.progressPercent, 50);

      final overflow = SavingsMission(
        id: 3, title: 'Overflow', targetAmount: 100.0, currentAmount: 150.0, isCompleted: true);
      expect(overflow.progressFraction, 1.0);
      expect(overflow.progressPercent, 100);
    });

    test('remainingAmount never returns negative numbers', () {
      final normal = SavingsMission(
        id: 1, title: 'Laptop', targetAmount: 3000.0, currentAmount: 1000.0, isCompleted: false);
      expect(normal.remainingAmount, 2000.0);

      final overfunded = SavingsMission(
        id: 2, title: 'Laptop Pro', targetAmount: 3000.0, currentAmount: 3500.0, isCompleted: true);
      expect(overfunded.remainingAmount, 0.0);
    });

    test('monthlySavingRequired returns null when completed or without deadline', () {
      final noDeadline = SavingsMission(
        id: 1, title: 'Fondo', targetAmount: 1000.0, currentAmount: 200.0, isCompleted: false);
      expect(noDeadline.monthlySavingRequired, isNull);

      final completedWithDeadline = SavingsMission(
        id: 2, title: 'Completada', targetAmount: 500.0, currentAmount: 500.0,
        deadline: '2027-01-01', isCompleted: true);
      expect(completedWithDeadline.monthlySavingRequired, isNull);
    });

    test('monthlySavingRequired computes valid monthly projection for future deadline', () {
      final futureDate = DateTime.now().add(const Duration(days: 95));
      final futureStr = '${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}';

      final mission = SavingsMission(
        id: 1, title: 'Certificación Cloud', targetAmount: 800.0, currentAmount: 200.0,
        deadline: futureStr, isCompleted: false);

      expect(mission.monthsRemaining, isNotNull);
      expect(mission.monthsRemaining! >= 3, true);
      expect(mission.monthlySavingRequired, isNotNull);
      expect(mission.monthlySavingRequired! > 0, true);
    });

    test('plantState reflects gamification stages accurately', () {
      final seed = SavingsMission(
        id: 1, title: 'Semilla', targetAmount: 100.0, currentAmount: 20.0, isCompleted: false);
      expect(seed.plantState, PlantState.seed);

      final sprout = SavingsMission(
        id: 2, title: 'Brote', targetAmount: 100.0, currentAmount: 40.0, isCompleted: false);
      expect(sprout.plantState, PlantState.sprouting);

      final growing = SavingsMission(
        id: 3, title: 'Crecimiento', targetAmount: 100.0, currentAmount: 75.0, isCompleted: false);
      expect(growing.plantState, PlantState.growing);

      final bloomed = SavingsMission(
        id: 4, title: 'Florecida', targetAmount: 100.0, currentAmount: 100.0, isCompleted: true);
      expect(bloomed.plantState, PlantState.bloomed);
    });

    test('toMap serializes properly for API persistence', () {
      final mission = SavingsMission(
        id: 99,
        title: 'Bicicleta',
        targetAmount: 500.0,
        currentAmount: 250.0,
        iconName: 'sports_car',
        deadline: '2026-11-30',
        isCompleted: false,
      );

      final map = mission.toMap();
      expect(map['id'], 99);
      expect(map['title'], 'Bicicleta');
      expect(map['target_amount'], 500.0);
      expect(map['current_amount'], 250.0);
      expect(map['icon_name'], 'sports_car');
      expect(map['deadline'], '2026-11-30');
      expect(map['is_completed'], false);
    });
  });
}
