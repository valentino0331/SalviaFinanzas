import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/expense.dart';
import '../domain/expense_category.dart';


abstract class ExpenseRepository {
  Future<List<Expense>> obtenerTodos();

  Future<Expense> insertar({
    required double amount,
    required ExpenseCategory category,
    required String detail,
    required DateTime date,
  });

  Future<void> eliminarPorId(int id);
}


class LocalExpenseRepository implements ExpenseRepository {
  static const String _storageKey = 'salvia_expenses_v1';

  Future<List<Expense>> _leer() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => Expense.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _escribir(List<Expense> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(items.map((e) => e.toMap()).toList()),
    );
  }

  @override
  Future<List<Expense>> obtenerTodos() async {
    final items = await _leer();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  @override
  Future<Expense> insertar({
    required double amount,
    required ExpenseCategory category,
    required String detail,
    required DateTime date,
  }) async {
    final items = await _leer();
    
    final nextId = items.fold<int>(0, (m, e) => e.id > m ? e.id : m) + 1;
    final nuevo = Expense(
      id: nextId,
      amount: amount,
      category: category,
      detail: detail,
      date: date,
    );
    items.add(nuevo);
    await _escribir(items);
    return nuevo;
  }

  @override
  Future<void> eliminarPorId(int id) async {
    final items = await _leer();
    items.removeWhere((e) => e.id == id);
    await _escribir(items);
  }
}


class InMemoryExpenseRepository implements ExpenseRepository {
  final List<Expense> _items = [];

  @override
  Future<List<Expense>> obtenerTodos() async => List.of(_items);

  @override
  Future<Expense> insertar({
    required double amount,
    required ExpenseCategory category,
    required String detail,
    required DateTime date,
  }) async {
    final nextId = _items.fold<int>(0, (m, e) => e.id > m ? e.id : m) + 1;
    final nuevo = Expense(
      id: nextId,
      amount: amount,
      category: category,
      detail: detail,
      date: date,
    );
    _items.add(nuevo);
    return nuevo;
  }

  @override
  Future<void> eliminarPorId(int id) async {
    _items.removeWhere((e) => e.id == id);
  }
}
