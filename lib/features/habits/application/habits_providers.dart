import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../domain/habit.dart';
import '../domain/habit_validators.dart';

/// Vista tipada de los hábitos expuestos por el provider global.
///
/// Se apoya en el `habitsProvider` de core (una sola fuente de verdad) y solo
/// traduce `Map<String, dynamic>` a [Habit] para el resto de la feature.
final habitsViewProvider = Provider<AsyncValue<List<Habit>>>((ref) {
  return ref.watch(habitsProvider).whenData(
        (list) => list
            .map((e) => Habit.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
});

/// Fachada de acciones de hábitos.
///
/// Delega en el `HabitsNotifier` de core para no duplicar la lógica de red ni
/// la sincronización de puntos y tabla de clasificación.
final habitsActionsProvider =
    Provider<HabitsActions>((ref) => HabitsActions(ref));

class HabitsActions {
  HabitsActions(this._ref);

  final Ref _ref;

  Future<void> refresh() => _ref.read(habitsProvider.notifier).loadHabits();

  Future<void> addHabit({
    required String title,
    required String description,
    required int pointsReward,
  }) {
    final error = HabitValidators.validateHabit(
      title: title,
      points: pointsReward,
    );
    if (error != null) throw HabitValidationException(error);
    return _ref.read(habitsProvider.notifier).addHabit(
          title,
          description,
          pointsReward,
        );
  }

  Future<int> completeHabit(int id) =>
      _ref.read(habitsProvider.notifier).completeHabit(id);
}
