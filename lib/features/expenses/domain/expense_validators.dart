import 'expense_category.dart';

/// Lanzada por el Gestor de Gastos cuando los datos no son válidos.
class ExpenseValidationException implements Exception {
  ExpenseValidationException(this.message);
  final String message;

  @override
  String toString() => message;
}


class ExpenseValidators {
  static const double maxAmount = 99999.99;
  static const int minDetailLength = 3;
  static const int maxDetailLength = 60;

  /// Valida el texto escrito en el campo de monto. Devuelve null si es válido.
  static String? validateAmount(String? raw) {
    final text = (raw ?? '').trim().replaceAll(',', '.');
    if (text.isEmpty) return 'Ingresa un monto';

    final value = double.tryParse(text);
    if (value == null || value.isNaN || value.isInfinite) {
      return 'Monto inválido';
    }
    if (value <= 0) return 'El monto debe ser mayor a 0';
    if (value > maxAmount) return 'El monto máximo es S/ 99,999.99';
    if (RegExp(r'\.\d{3,}$').hasMatch(text)) return 'Usa máximo 2 decimales';
    return null;
  }

  static String? validateCategory(ExpenseCategory? category) {
    return category == null ? 'Selecciona una categoría' : null;
  }


  static String? validateDetail(String? raw, {ExpenseCategory? category}) {
    final text = (raw ?? '').trim();
    if (text.isEmpty) {
      return category == ExpenseCategory.otros
          ? 'Describe el gasto en "Otros"'
          : null;
    }
    if (text.length < minDetailLength) {
      return 'Escribe al menos $minDetailLength caracteres';
    }
    if (text.length > maxDetailLength) {
      return 'Máximo $maxDetailLength caracteres';
    }
    return null;
  }

 
  static double parseAmount(String raw) {
    return double.parse(raw.trim().replaceAll(',', '.'));
  }

  
  static String? validateExpense({
    required double amount,
    required ExpenseCategory? category,
    String? detail,
  }) {
    if (amount.isNaN || amount.isInfinite) return 'Monto inválido';
    if (amount <= 0) return 'El monto debe ser mayor a 0';
    if (amount > maxAmount) return 'El monto máximo es S/ 99,999.99';
    final categoryError = validateCategory(category);
    if (categoryError != null) return categoryError;
    return validateDetail(detail, category: category);
  }
}
