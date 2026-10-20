import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/expense_repository.dart';
import '../domain/expense.dart';
import '../domain/expense_category.dart';
import '../domain/expense_validators.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>(
  (ref) => LocalExpenseRepository(),
);

final monthlyIncomeProvider = StateProvider<double>((ref) => 5000.0);

final gestorGastosProvider =
    StateNotifierProvider<GestorGastos, AsyncValue<List<Expense>>>(
  (ref) => GestorGastos(ref.watch(expenseRepositoryProvider)),
);

class ExpenseSummary {
  const ExpenseSummary({
    required this.total,
    required this.byCategory,
    required this.income,
  });

  final double total;
  final Map<ExpenseCategory, double> byCategory;
  final double income;

  double get balance => income - total;
  bool get isEmpty => total <= 0;

  double percentOf(ExpenseCategory category) =>
      total > 0 ? (byCategory[category] ?? 0) / total * 100 : 0;

  List<MapEntry<ExpenseCategory, double>> get sortedCategories {
    final list = byCategory.entries.toList();
    list.sort((a, b) => b.value.compareTo(a.value));
    return list;
  }
}

final expenseSummaryProvider = Provider<ExpenseSummary>((ref) {
  final expenses = ref.watch(gestorGastosProvider).valueOrNull ?? const [];
  final income = ref.watch(monthlyIncomeProvider);
  final now = DateTime.now();

  final byCategory = <ExpenseCategory, double>{};
  var total = 0.0;
  for (final e in expenses) {
    if (e.date.year != now.year || e.date.month != now.month) continue;
    total += e.amount;
    byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
  }
  return ExpenseSummary(
    total: double.parse(total.toStringAsFixed(2)),
    byCategory: byCategory,
    income: income,
  );
});

class GestorGastos extends StateNotifier<AsyncValue<List<Expense>>> {
  GestorGastos(this._repo) : super(const AsyncValue.loading()) {
    cargar();
  }

  final ExpenseRepository _repo;

  Future<void> cargar() async {
    try {
      final lista = await _repo.obtenerTodos();
      if (!mounted) return;
      state = AsyncValue.data(lista);
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncValue.error(e, st);
    }
  }

  Future<Expense> agregarGasto({
    required double monto,
    required ExpenseCategory categoria,
    String detalle = '',
  }) async {
    final error = ExpenseValidators.validateExpense(
      amount: monto,
      category: categoria,
      detail: detalle,
    );
    if (error != null) throw ExpenseValidationException(error);

    final nuevo = await _repo.insertar(
      amount: double.parse(monto.toStringAsFixed(2)),
      category: categoria,
      detail: detalle.trim(),
      date: DateTime.now(),
    );

    final actuales = state.valueOrNull ?? const <Expense>[];
    final lista = [nuevo, ...actuales]..sort((a, b) => b.date.compareTo(a.date));
    state = AsyncValue.data(lista);
    return nuevo;
  }

  Future<void> eliminarGasto(int idGasto) async {
    final actuales = state.valueOrNull ?? const <Expense>[];
    if (!actuales.any((e) => e.id == idGasto)) return;
    final respaldo = List<Expense>.of(actuales);
    state = AsyncValue.data(actuales.where((e) => e.id != idGasto).toList());

    try {
      await _repo.eliminarPorId(idGasto);
    } catch (_) {
      if (mounted) state = AsyncValue.data(respaldo);
      rethrow;
    }
  }
}
