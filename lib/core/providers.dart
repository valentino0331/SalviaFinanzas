import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';

// === AUTH PROVIDER ===
class AuthState {
  final Map<String, dynamic>? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({Map<String, dynamic>? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  AuthNotifier(this.ref) : super(AuthState()) {
    checkLocalSession();
  }

  Future<void> checkLocalSession() async {
    state = state.copyWith(isLoading: true);
    try {
      await ApiService.init();
      final profile = await ApiService.getProfile();
      state = AuthState(user: profile);
    } catch (_) {
      state = AuthState(user: null); // Sin sesión iniciada
    }
  }

  Future<void> login(String id, String email, String name, {String? avatarUrl, double? monthlyIncome}) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await ApiService.loginWithGoogle(
        id: id,
        email: email,
        name: name,
        avatarUrl: avatarUrl,
        monthlyIncome: monthlyIncome,
      );

      // Limpiar estados cacheados en memoria de otros providers al iniciar sesión
      ref.invalidate(expensesProvider);
      ref.invalidate(savingsProvider);
      ref.invalidate(habitsProvider);
      ref.invalidate(advisorProvider);
      ref.invalidate(unlockedPlantsProvider);

      state = AuthState(user: user);
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await ApiService.logout();

    // Limpiar estados cacheados en memoria de otros providers al cerrar sesión
    ref.invalidate(expensesProvider);
    ref.invalidate(savingsProvider);
    ref.invalidate(habitsProvider);
    ref.invalidate(advisorProvider);
    ref.invalidate(unlockedPlantsProvider);

    state = AuthState(user: null);
  }

  Future<void> updateMonthlyIncome(double income) async {
    if (state.user != null) {
      try {
        final updatedUser = await ApiService.updateMonthlyIncome(income);
        state = AuthState(user: updatedUser);
      } catch (_) {}
    }
  }

  Future<void> updateUserName(String name) async {
    if (state.user != null) {
      try {
        final updatedUser = Map<String, dynamic>.from(state.user!);
        updatedUser['name'] = name;
        // Re-guardar en la DB local usando updateMonthlyIncome que ya maneja la persistencia completa
        final incomeVal = double.tryParse(updatedUser['monthly_income'].toString()) ?? 2000.00;
        final res = await ApiService.loginWithGoogle(
          id: updatedUser['id'] ?? 'offline_user_id',
          email: updatedUser['email'] ?? 'offline_user@salvia.local',
          name: name,
          avatarUrl: updatedUser['avatar_url'],
          monthlyIncome: incomeVal,
        );
        state = AuthState(user: res);
      } catch (_) {}
    }
  }

  void updateLocalPoints(int points) {
    if (state.user != null) {
      final updatedUser = Map<String, dynamic>.from(state.user!);
      updatedUser['points'] = points;
      state = AuthState(user: updatedUser);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref));

// === EXPENSES PROVIDER ===
class ExpensesNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  ExpensesNotifier() : super(const AsyncValue.loading()) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    try {
      final list = await ApiService.getExpenses();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addExpense(double amount, String category, String subcategory, String description, {String? date, String? recurrence}) async {
    try {
      final newExp = await ApiService.addExpense({
        'amount': amount,
        'category': category,
        'subcategory': subcategory,
        'description': description,
        if (date != null) 'date': date,
        if (recurrence != null) 'recurrence': recurrence,
      });
      state.whenData((list) {
        state = AsyncValue.data([newExp, ...list]);
      });
    } catch (e) {
      // Re-throw or handle error
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await ApiService.deleteExpense(id);
      state.whenData((list) {
        state = AsyncValue.data(list.where((e) => e['id'] != id).toList());
      });
    } catch (_) {}
  }
}

final expensesProvider = StateNotifierProvider<ExpensesNotifier, AsyncValue<List<dynamic>>>((ref) => ExpensesNotifier());

// === SAVINGS MISSION PROVIDER ===
class SavingsNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final Ref ref;
  SavingsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadMissions();
  }

  Future<void> loadMissions() async {
    try {
      final list = await ApiService.getSavingsMissions();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addMission(String title, double targetAmount, {String? deadline, String? iconName}) async {
    try {
      final newMission = await ApiService.addSavingsMission({
        'title': title,
        'target_amount': targetAmount,
        if (deadline != null) 'deadline': deadline,
        if (iconName != null) 'icon_name': iconName,
      });
      state.whenData((list) {
        state = AsyncValue.data([newMission, ...list]);
      });
    } catch (_) {}
  }

  Future<bool> saveFunds(int id, double amount) async {
    try {
      final result = await ApiService.saveToMission(id, amount);
      final updatedMission = result['mission'];
      final pointsAwarded = result['points_awarded'] as int;

      state.whenData((list) {
        state = AsyncValue.data(list.map((m) => m['id'] == id ? updatedMission : m).toList());
      });

      if (pointsAwarded > 0) {
        // Actualizar puntos de usuario en AuthState
        final currentPoints = ref.read(authProvider).user?['points'] ?? 0;
        ref.read(authProvider.notifier).updateLocalPoints(currentPoints + pointsAwarded);
        ref.read(leaderboardProvider.notifier).loadLeaderboard();
      }
      return updatedMission['is_completed'] == true;
    } catch (_) {
      return false;
    }
  }
}

final savingsProvider = StateNotifierProvider<SavingsNotifier, AsyncValue<List<dynamic>>>((ref) => SavingsNotifier(ref));

// === HABITS PROVIDER ===
class HabitsNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final Ref ref;
  HabitsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadHabits();
  }

  Future<void> loadHabits() async {
    try {
      final list = await ApiService.getHabits();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addHabit(String title, String description, int pointsReward) async {
    try {
      final newHabit = await ApiService.addHabit({
        'title': title,
        'description': description,
        'points_reward': pointsReward,
      });
      state.whenData((list) {
        state = AsyncValue.data([...list, newHabit]);
      });
    } catch (_) {}
  }

  Future<int> completeHabit(int id) async {
    try {
      final result = await ApiService.completeHabit(id);
      final updatedHabit = result['habit'];
      final pointsAwarded = result['points_awarded'] as int;
      final newTotalPoints = result['current_user_points'] as int;

      state.whenData((list) {
        state = AsyncValue.data(list.map((h) => h['id'] == id ? updatedHabit : h).toList());
      });

      ref.read(authProvider.notifier).updateLocalPoints(newTotalPoints);
      ref.read(leaderboardProvider.notifier).loadLeaderboard();
      
      return pointsAwarded;
    } catch (e) {
      rethrow;
    }
  }
}

final habitsProvider = StateNotifierProvider<HabitsNotifier, AsyncValue<List<dynamic>>>((ref) => HabitsNotifier(ref));

// === LEADERBOARD PROVIDER ===
class LeaderboardNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  LeaderboardNotifier() : super(const AsyncValue.loading()) {
    loadLeaderboard();
  }

  Future<void> loadLeaderboard() async {
    try {
      final list = await ApiService.getLeaderboard();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final leaderboardProvider = StateNotifierProvider<LeaderboardNotifier, AsyncValue<List<dynamic>>>((ref) => LeaderboardNotifier());

// === ADVISOR PROVIDER ===
class AdvisorNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  AdvisorNotifier() : super(const AsyncValue.loading()) {
    loadReport();
  }

  Future<void> loadReport() async {
    try {
      final report = await ApiService.getFinancialAdvisorReport();
      state = AsyncValue.data(report);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final advisorProvider = StateNotifierProvider<AdvisorNotifier, AsyncValue<Map<String, dynamic>>>((ref) => AdvisorNotifier());

final unlockedPlantsProvider = StateNotifierProvider<UnlockedPlantsNotifier, List<String>>((ref) => UnlockedPlantsNotifier());

class UnlockedPlantsNotifier extends StateNotifier<List<String>> {
  UnlockedPlantsNotifier() : super(['school']); // Inicialmente desbloqueado: Solo Bonsai Salvia

  void unlockPlant(String plantId) {
    if (!state.contains(plantId)) {
      state = [...state, plantId];
    }
  }
}
