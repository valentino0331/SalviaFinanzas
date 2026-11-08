import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/providers.dart';
import '../data/habits_api.dart';
import '../domain/habit.dart';
import '../domain/habit_calendar.dart';
import '../domain/habit_rewards.dart';
import '../domain/habit_template.dart';
import '../domain/habit_validators.dart';

final habitsClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final habitsApiProvider = Provider<HabitsApi>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return HabitsApi(client, now: ref.watch(habitsClockProvider));
});

/// Reconstruye la pantalla al llegar la medianoche de Perú, sin hacer peticiones.
final habitsTodayProvider = Provider.autoDispose<DateTime>((ref) {
  final now = ref.watch(habitsClockProvider)();
  final timer = Timer(
    HabitCalendar.nextMidnight(now).difference(now.toUtc()),
    ref.invalidateSelf,
  );
  ref.onDispose(timer.cancel);
  return HabitCalendar.dayFor(now);
});

final habitsPendingProvider = StateProvider<Set<int>>((ref) {
  ref.watch(authProvider.select((state) => state.user?['id']));
  return {};
});

/// Estado propio de la feature; se descarta al cambiar la cuenta.
final habitsViewProvider =
    StateNotifierProvider<HabitsController, AsyncValue<List<Habit>>>((ref) {
      ref.watch(authProvider.select((state) => state.user?['id']));
      return HabitsController(ref, ref.watch(habitsApiProvider));
    });

class HabitsController extends StateNotifier<AsyncValue<List<Habit>>> {
  HabitsController(this._ref, this._api) : super(const AsyncValue.loading()) {
    refresh();
  }

  final Ref _ref;
  final HabitsApi _api;
  int _revision = 0;

  Future<void> refresh() async {
    if (_ref.read(habitsPendingProvider).isNotEmpty) return;
    final revision = ++_revision;
    if (!state.hasValue) state = const AsyncValue.loading();
    try {
      final habits = await _api.getHabits();
      final points = await _api.getLocalPoints();
      if (mounted && revision == _revision) {
        state = AsyncValue.data(habits);
        if (points != null) _syncPoints(points);
      }
    } catch (error, stack) {
      if (mounted && revision == _revision) {
        state = AsyncValue.error(error, stack);
      }
    }
  }

  Future<T> _mutate<T>(int id, Future<T> Function() action) async {
    if (_ref.read(habitsPendingProvider).isNotEmpty) {
      throw const HabitsApiException(
        'Espera a que termine la operación actual',
      );
    }
    if (!state.hasValue) {
      throw const HabitsApiException('Espera a que se carguen tus hábitos');
    }
    ++_revision;
    _ref.read(habitsPendingProvider.notifier).state = {id};
    try {
      final recoveredPoints = await _api.recoverPendingCompletion();
      if (recoveredPoints != null && mounted) {
        final habits = await _api.getHabits();
        if (mounted) {
          state = AsyncValue.data(habits);
          _syncPoints(recoveredPoints);
        }
      }
      if (!mounted) {
        throw const HabitsApiException(
          'La sesión cambió. Vuelve a abrir hábitos.',
        );
      }
      return await action();
    } finally {
      if (mounted) _ref.read(habitsPendingProvider.notifier).state = {};
    }
  }

  void _replace(Habit habit) {
    if (!mounted) return;
    state = AsyncValue.data(
      state.requireValue.map((h) => h.id == habit.id ? habit : h).toList(),
    );
  }

  void _syncPoints(int points) {
    if (_ref.read(authProvider).user?['points'] == points) return;
    _ref.read(authProvider.notifier).updateLocalPoints(points);
    _ref.invalidate(leaderboardProvider);
  }

  Future<void> addHabit(Map<String, dynamic> data) => _mutate(0, () async {
    final habit = await _api.addHabit(data);
    if (mounted) state = AsyncValue.data([...state.requireValue, habit]);
  });

  Future<void> updateHabit(int id, Map<String, dynamic> data) =>
      _mutate(id, () async => _replace(await _api.updateHabit(id, data)));

  Future<void> deleteHabit(int id) => _mutate(id, () async {
    await _api.deleteHabit(id);
    if (mounted) {
      state = AsyncValue.data(
        state.requireValue.where((habit) => habit.id != id).toList(),
      );
    }
  });

  Future<int> completeHabit(int id) => _mutate(id, () async {
    final result = await _api.completeHabit(id);
    if (mounted) {
      _replace(
        Habit.fromMap(Map<String, dynamic>.from(result['habit'] as Map)),
      );
      _ref
          .read(authProvider.notifier)
          .updateLocalPoints((result['current_user_points'] as num).toInt());
      _ref.invalidate(leaderboardProvider);
    }
    return (result['points_awarded'] as num).toInt();
  });
}

/// Fachada compartida por los formularios y la pantalla.
final habitsActionsProvider = Provider<HabitsActions>(
  (ref) => HabitsActions(ref),
);

class HabitsActions {
  HabitsActions(this._ref);

  final Ref _ref;

  Future<void> refresh() => _ref.read(habitsViewProvider.notifier).refresh();

  Future<void> addHabit({required String title, required String description}) {
    return _ref
        .read(habitsViewProvider.notifier)
        .addHabit(_validatedData(title, description));
  }

  Future<void> updateHabit({
    required int id,
    required String title,
    required String description,
  }) => _ref
      .read(habitsViewProvider.notifier)
      .updateHabit(id, _validatedData(title, description, excludingId: id));

  Future<void> adoptHabit(HabitTemplate template) {
    final habits = _ref.read(habitsViewProvider).valueOrNull ?? const <Habit>[];
    if (habits.any((habit) => habit.templateId == template.id)) {
      throw HabitValidationException('Ya adoptaste esta recomendación');
    }
    return _ref.read(habitsViewProvider.notifier).addHabit({
      ..._validatedData(template.title, template.description),
      'template_id': template.id,
    });
  }

  Future<void> deleteHabit(int id) =>
      _ref.read(habitsViewProvider.notifier).deleteHabit(id);

  Future<int> completeHabit(int id) =>
      _ref.read(habitsViewProvider.notifier).completeHabit(id);

  Map<String, dynamic> _validatedData(
    String title,
    String description, {
    int? excludingId,
  }) {
    final error = HabitValidators.validateHabit(
      title: title,
      description: description,
    );
    if (error != null) throw HabitValidationException(error);
    final habits = _ref.read(habitsViewProvider).valueOrNull ?? const <Habit>[];
    final duplicateError = HabitValidators.validateUniqueTitle(
      title,
      habits
          .where((habit) => habit.id != excludingId)
          .map((habit) => habit.title),
    );
    if (duplicateError != null) throw HabitValidationException(duplicateError);
    return {
      'title': HabitValidators.cleanTitle(title),
      'description': description.trim(),
      'points_reward': HabitRewards.basePoints,
    };
  }
}
