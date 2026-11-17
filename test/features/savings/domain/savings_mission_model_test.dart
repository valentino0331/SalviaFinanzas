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
        'is_shared': true,
        'collaborators': ['Valentino', 'Eduardo'],
      };

      final mission = SavingsMission.fromMap(map);

      expect(mission.id, 1);
      expect(mission.title, 'Viaje a Cusco');
      expect(mission.targetAmount, 1200.0);
      expect(mission.currentAmount, 600.0);
      expect(mission.iconName, 'flight');
      expect(mission.deadline, '2026-12-31');
      expect(mission.isCompleted, false);
      expect(mission.isShared, true);
      expect(mission.collaborators, ['Valentino', 'Eduardo']);
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

    test('dailySavingSuggested calculates daily target and handles edge cases', () {
      final futureDate = DateTime.now().add(const Duration(days: 30));
      final futureStr = '${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}';

      final mission = SavingsMission(
        id: 1, title: 'Pensión Universidad', targetAmount: 600.0, currentAmount: 0.0,
        deadline: futureStr, isCompleted: false);

      expect(mission.dailySavingSuggested, isNotNull);
      expect(mission.dailySavingSuggested! >= 18.0, true);

      final completed = mission.copyWith(isCompleted: true);
      expect(completed.dailySavingSuggested, isNull);
    });

    test('smartAdvice provides contextual recommendations across stages', () {
      final almostDone = SavingsMission(
        id: 1, title: 'Curso de Flutter', targetAmount: 100.0, currentAmount: 90.0, isCompleted: false);
      expect(almostDone.smartAdvice.contains('recta final'), true);

      final completed = almostDone.copyWith(isCompleted: true);
      expect(completed.smartAdvice.contains('florecida'), true);
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

    test('toMap serializes properly for API persistence including shared fields', () {
      final mission = SavingsMission(
        id: 99,
        title: 'Bicicleta',
        targetAmount: 500.0,
        currentAmount: 250.0,
        iconName: 'sports_car',
        deadline: '2026-11-30',
        isCompleted: false,
        isShared: true,
        collaborators: ['Valentino', 'Astrid'],
      );

      final map = mission.toMap();
      expect(map['id'], 99);
      expect(map['title'], 'Bicicleta');
      expect(map['target_amount'], 500.0);
      expect(map['current_amount'], 250.0);
      expect(map['icon_name'], 'sports_car');
      expect(map['deadline'], '2026-11-30');
      expect(map['is_completed'], false);
      expect(map['is_shared'], true);
      expect(map['collaborators'], ['Valentino', 'Astrid']);
    });

    test('sortMissions orders correctly by urgent, progress and highestTarget without mutating input', () {
      final soonDate = DateTime.now().add(const Duration(days: 10)).toIso8601String().split('T').first;
      final laterDate = DateTime.now().add(const Duration(days: 90)).toIso8601String().split('T').first;

      final m1 = SavingsMission(
        id: 1, title: 'Lejana Alta', targetAmount: 5000.0, currentAmount: 500.0,
        deadline: laterDate, isCompleted: false,
      ); // 10%, 90d, S/5000
      final m2 = SavingsMission(
        id: 2, title: 'Urgente Media', targetAmount: 1000.0, currentAmount: 750.0,
        deadline: soonDate, isCompleted: false,
      ); // 75%, 10d, S/1000
      final m3 = SavingsMission(
        id: 3, title: 'Completada', targetAmount: 2000.0, currentAmount: 2000.0,
        deadline: soonDate, isCompleted: true,
      ); // 100%, completed

      final original = [m1, m2, m3];

      final byUrgent = SavingsMission.sortMissions(original, SavingsSortOrder.urgent);
      expect(byUrgent.map((m) => m.id).toList(), [2, 1, 3]);

      final byProgress = SavingsMission.sortMissions(original, SavingsSortOrder.progress);
      expect(byProgress.map((m) => m.id).toList(), [3, 2, 1]);

      final byTarget = SavingsMission.sortMissions(original, SavingsSortOrder.highestTarget);
      expect(byTarget.map((m) => m.id).toList(), [1, 3, 2]);

      // Original list must remain untouched
      expect(original.map((m) => m.id).toList(), [1, 2, 3]);
    });
  });
}
