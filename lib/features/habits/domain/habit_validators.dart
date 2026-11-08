/// Error de validación lanzado al crear o editar un hábito con datos inválidos.
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

  static String cleanTitle(String title) =>
      title.trim().replaceAll(RegExp(r'\s+'), ' ');

  static String normalizeTitle(String title) => cleanTitle(title).toLowerCase();

  static String? validateUniqueTitle(String title, Iterable<String> titles) {
    final normalized = normalizeTitle(title);
    if (titles.any((existing) => normalizeTitle(existing) == normalized)) {
      return 'Ya tienes un hábito con ese nombre';
    }
    return null;
  }

  /// Valida el nombre del hábito. Devuelve null si es válido.
  static String? validateTitle(String? raw) {
    final text = cleanTitle(raw ?? '');
    if (text.isEmpty) return 'Ingresa un nombre para el hábito';
    if (text.length < minTitleLength) {
      return 'Escribe al menos $minTitleLength caracteres';
    }
    if (text.length > maxTitleLength) {
      return 'Máximo $maxTitleLength caracteres';
    }
    return null;
  }

  static String? validateDescription(String? raw) {
    if ((raw ?? '').trim().length > maxDescriptionLength) {
      return 'Máximo $maxDescriptionLength caracteres';
    }
    return null;
  }

  /// Validación completa usada en la capa de aplicación (defensa en profundidad).
  static String? validateHabit({
    required String title,
    required String description,
  }) {
    return validateTitle(title) ?? validateDescription(description);
  }
}
