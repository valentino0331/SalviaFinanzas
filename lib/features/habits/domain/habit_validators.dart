/// Error de validación lanzado al intentar crear un hábito con datos inválidos.
class HabitValidationException implements Exception {
  HabitValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Reglas de validación del formulario de hábitos.
///
/// Se usan tanto en el diálogo (feedback temprano) como en la capa de
/// aplicación (defensa en profundidad).
class HabitValidators {
  HabitValidators._();

  static const int minTitleLength = 3;
  static const int maxTitleLength = 40;
  static const int maxDescriptionLength = 80;
  static const int maxPoints = 999;
  static const int defaultPoints = 15;

  /// Valida el nombre del hábito. Devuelve null si es válido.
  static String? validateTitle(String? raw) {
    final text = (raw ?? '').trim();
    if (text.isEmpty) return 'Ingresa un nombre para el hábito';
    if (text.length < minTitleLength) {
      return 'Escribe al menos $minTitleLength caracteres';
    }
    if (text.length > maxTitleLength) {
      return 'Máximo $maxTitleLength caracteres';
    }
    return null;
  }

  /// Valida el texto del campo de puntos. Devuelve null si es válido.
  static String? validatePoints(String? raw) {
    final text = (raw ?? '').trim();
    if (text.isEmpty) return 'Ingresa los puntos';
    final value = int.tryParse(text);
    if (value == null) return 'Solo se permiten números enteros';
    return validatePointsValue(value);
  }

  /// Valida un valor numérico de puntos ya parseado.
  static String? validatePointsValue(int value) {
    if (value <= 0) return 'Los puntos deben ser mayores a 0';
    if (value > maxPoints) return 'El máximo es $maxPoints puntos';
    return null;
  }

  /// Convierte el texto del campo a entero, usando [defaultPoints] si no es válido.
  static int parsePoints(String raw) {
    return int.tryParse(raw.trim()) ?? defaultPoints;
  }

  /// Validación completa usada en la capa de aplicación (defensa en profundidad).
  static String? validateHabit({required String title, required int points}) {
    return validateTitle(title) ?? validatePointsValue(points);
  }
}
