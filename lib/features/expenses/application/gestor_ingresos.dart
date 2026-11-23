import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/expense_validators.dart';

/// Ingreso mensual que se muestra en Inicio. Se guarda en el dispositivo.
final monthlyIncomeProvider = StateNotifierProvider<GestorIngresos, double>(
  (ref) => GestorIngresos(),
);

class GestorIngresos extends StateNotifier<double> {
  GestorIngresos() : super(defaultIncome) {
    _cargar();
  }

  static const double defaultIncome = 5000.0;
  static const String _storageKey = 'salvia_monthly_income_v1';

  Future<void> _cargar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final guardado = prefs.getDouble(_storageKey);
      if (guardado == null || !mounted) return;
      state = guardado;
    } catch (_) {
      return;
    }
  }

  /// Actualiza el ingreso mensual. Devuelve un mensaje de error o null si todo salió bien.
  Future<String?> actualizar(double monto) async {
    if (monto.isNaN || monto.isInfinite) return 'Monto inválido';
    if (monto <= 0) return 'El ingreso debe ser mayor a 0';
    if (monto > ExpenseValidators.maxAmount) {
      return 'El monto máximo es S/ 99,999.99';
    }
    final redondeado = double.parse(monto.toStringAsFixed(2));
    state = redondeado;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_storageKey, redondeado);
    } catch (_) {
      return 'No se pudo guardar en el dispositivo';
    }
    return null;
  }
}
