import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/quick_expense.dart';

final quickExpensesProvider =
    StateNotifierProvider<GestorRapidos, List<QuickExpense>>(
  (ref) => GestorRapidos(),
);

class GestorRapidos extends StateNotifier<List<QuickExpense>> {
  GestorRapidos() : super(const <QuickExpense>[]) {
    _cargar();
  }

  static const String _storageKey = 'salvia_quick_expenses_v2';
  static const int maxItems = 8;

  Future<void> _cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final lista = decoded
          .map((e) => QuickExpense.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      if (!mounted) return;
      state = lista;
    } catch (_) {
      return;
    }
  }

  Future<void> _guardar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(state.map((e) => e.toMap()).toList()),
    );
  }

  Future<String?> agregar(QuickExpense item) async {
    if (state.any((e) => e.isSameAs(item))) {
      return 'Ya está en registro rápido';
    }
    if (state.length >= maxItems) {
      return 'Máximo $maxItems gastos rápidos. Mantén presionado uno para quitarlo.';
    }
    state = [...state, item];
    await _guardar();
    return null;
  }

  Future<void> quitar(QuickExpense item) async {
    state = state.where((e) => !e.isSameAs(item)).toList();
    await _guardar();
  }
}
