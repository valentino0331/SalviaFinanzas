/// Modelo de dominio para una misión (meta) de ahorro.
///
/// Centraliza toda la lógica de cálculo de progreso, proyección temporal
/// y estados de la meta en un único lugar autorizado.
class SavingsMission {
  final int id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String? iconName;
  final String? deadline; // ISO8601 date string, e.g. "2026-12-31"
  final bool isCompleted;

  const SavingsMission({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    this.iconName,
    this.deadline,
    required this.isCompleted,
  });

  // ── Fábrica ──────────────────────────────────────────────────────────────

  /// Construye un [SavingsMission] desde el mapa JSON que devuelve la API.
  factory SavingsMission.fromMap(Map<String, dynamic> map) {
    final cur = double.tryParse(map['current_amount']?.toString() ?? '0') ?? 0.0;
    final tgt = double.tryParse(map['target_amount']?.toString() ?? '0') ?? 0.0;
    final completed = map['is_completed'] == true || (tgt > 0 && cur >= tgt);

    return SavingsMission(
      id: map['id'] as int,
      title: (map['title'] as String?) ?? 'Meta de ahorro',
      targetAmount: tgt,
      currentAmount: cur,
      iconName: map['icon_name'] as String?,
      deadline: map['deadline'] as String?,
      isCompleted: completed,
    );
  }

  /// Convierte el modelo a un mapa compatible con la API.
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'target_amount': targetAmount,
        'current_amount': currentAmount,
        if (iconName != null) 'icon_name': iconName,
        if (deadline != null) 'deadline': deadline,
        'is_completed': isCompleted,
      };

  // ── Cálculos de dominio ──────────────────────────────────────────────────

  /// Porcentaje de progreso entre 0.0 y 1.0.
  double get progressFraction =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  /// Porcentaje de progreso en entero (0 – 100).
  int get progressPercent => (progressFraction * 100).toInt();

  /// Monto restante para completar la meta (nunca negativo).
  double get remainingAmount => (targetAmount - currentAmount).clamp(0.0, double.infinity);

  /// Devuelve cuántos meses completos faltan hasta [deadline].
  /// Retorna null si no hay fecha límite o si ya pasó.
  int? get monthsRemaining {
    if (deadline == null) return null;
    final due = DateTime.tryParse(deadline!);
    if (due == null) return null;
    final now = DateTime.now();
    if (due.isBefore(now)) return 0;
    final diff = due.difference(now);
    final months = (diff.inDays / 30).ceil();
    return months > 0 ? months : 0;
  }

  /// Monto mensual sugerido para llegar a la meta a tiempo.
  /// Retorna null si no hay deadline o si la meta está completa.
  double? get monthlySavingRequired {
    if (isCompleted) return null;
    final months = monthsRemaining;
    if (months == null || months == 0) return null;
    return remainingAmount / months;
  }

  /// Fecha límite parseada como DateTime. null si no aplica.
  DateTime? get deadlineDate => deadline != null ? DateTime.tryParse(deadline!) : null;

  /// Estado gamificado de la planta según el progreso.
  PlantState get plantState {
    if (isCompleted || progressFraction >= 1.0) return PlantState.bloomed;
    if (progressFraction > 0.60) return PlantState.growing;
    if (progressFraction > 0.25) return PlantState.sprouting;
    return PlantState.seed;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SavingsMission && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'SavingsMission(id: $id, title: $title, progress: $progressPercent%)';
}

// ── Enumeración de estado de planta ────────────────────────────────────────

/// Estado visual (gamificado) de una meta de ahorro.
enum PlantState {
  seed,      // 🌱 0–25 %
  sprouting, // 🌿 25–60 %
  growing,   // 🍀 60–100 %
  bloomed,   // 🌸 completada
}

extension PlantStateX on PlantState {
  String get emoji {
    switch (this) {
      case PlantState.seed:      return '🌱';
      case PlantState.sprouting: return '🌿';
      case PlantState.growing:   return '🍀';
      case PlantState.bloomed:   return '🌸';
    }
  }

  String get label {
    switch (this) {
      case PlantState.seed:      return 'Semilla sembrada';
      case PlantState.sprouting: return 'Brote activo';
      case PlantState.growing:   return 'Creciendo fuerte';
      case PlantState.bloomed:   return '¡Meta Florecida!';
    }
  }
}
