/// Modelo de dominio para una misión (meta) de ahorro.
///
/// Centraliza toda la lógica de cálculo de progreso, proyección temporal,
/// asesoramiento inteligente y estados colaborativos/multi-usuario.
class SavingsMission {
  final int id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String? iconName;
  final String? deadline; // ISO8601 date string, e.g. "2026-12-31"
  final bool isCompleted;
  final bool isShared;
  final List<String> collaborators;
  final String? category;

  const SavingsMission({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    this.iconName,
    this.deadline,
    required this.isCompleted,
    this.isShared = false,
    this.collaborators = const [],
    this.category,
  });

  // ── Fábrica ──────────────────────────────────────────────────────────────

  /// Construye un [SavingsMission] desde el mapa JSON que devuelve la API.
  factory SavingsMission.fromMap(Map<String, dynamic> map) {
    // Protección contra valores no numéricos, comas o formatos inconsistentes
    final rawCur = map['current_amount']?.toString().replaceAll(',', '.') ?? '0';
    final rawTgt = map['target_amount']?.toString().replaceAll(',', '.') ?? '0';
    final cur = double.tryParse(rawCur) ?? 0.0;
    final tgt = double.tryParse(rawTgt) ?? 0.0;
    final completed = map['is_completed'] == true || (tgt > 0 && cur >= tgt);

    // Parseo de colaboradores
    List<String> parsedCollaborators = [];
    if (map['collaborators'] is List) {
      parsedCollaborators = (map['collaborators'] as List)
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (map['collaborators'] is String && (map['collaborators'] as String).isNotEmpty) {
      parsedCollaborators = (map['collaborators'] as String)
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final isSharedGoal = map['is_shared'] == true || parsedCollaborators.isNotEmpty;

    return SavingsMission(
      id: (map['id'] is int) ? map['id'] as int : int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      title: (map['title'] as String?)?.trim() ?? 'Meta de ahorro',
      targetAmount: tgt > 0 ? tgt : 0.0,
      currentAmount: cur > 0 ? cur : 0.0,
      iconName: map['icon_name'] as String?,
      deadline: map['deadline'] as String?,
      isCompleted: completed,
      isShared: isSharedGoal,
      collaborators: parsedCollaborators,
      category: map['category'] as String?,
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
        'is_shared': isShared,
        if (collaborators.isNotEmpty) 'collaborators': collaborators,
        if (category != null) 'category': category,
      };

  // ── Cálculos de dominio ──────────────────────────────────────────────────

  /// Porcentaje de progreso entre 0.0 y 1.0. Blindado contra división por cero.
  double get progressFraction =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  /// Porcentaje de progreso en entero (0 – 100).
  int get progressPercent => (progressFraction * 100).toInt();

  /// Monto restante para completar la meta (nunca negativo).
  double get remainingAmount => (targetAmount - currentAmount).clamp(0.0, double.infinity);

  /// Devuelve cuántos días completos faltan hasta [deadline].
  /// Retorna null si no hay fecha límite y 0 si ya expiró.
  int? get daysRemaining {
    if (deadline == null) return null;
    final due = DateTime.tryParse(deadline!);
    if (due == null) return null;
    final now = DateTime.now();
    if (due.isBefore(now)) return 0;
    return due.difference(now).inDays;
  }

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
    if (months == null || months <= 0) return null;
    return remainingAmount / months;
  }

  /// Monto diario sugerido para completar la meta a tiempo.
  double? get dailySavingSuggested {
    if (isCompleted) return null;
    final days = daysRemaining;
    if (days == null || days <= 0) return null;
    return remainingAmount / days;
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

  /// Recomendación contextual inteligente calculada localmente.
  String get smartAdvice {
    if (isCompleted) {
      return '¡Meta florecida! Has cumplido tu objetivo con éxito. ¡Felicitaciones!';
    }
    if (progressFraction >= 0.85) {
      return '¡Estás en la recta final! Te falta solo el ${(100 - progressPercent)}% para completar tu meta.';
    }
    if (daysRemaining != null && daysRemaining! > 0) {
      final daily = dailySavingSuggested?.toStringAsFixed(2) ?? '0.00';
      final monthly = monthlySavingRequired?.toStringAsFixed(2) ?? '0.00';
      return 'Para florecer a tiempo, ahorra aprox. S/ $daily al día (S/ $monthly al mes).';
    }
    return 'Paso a paso: cada sol que apartas hace crecer tu semilla de ahorro.';
  }

  /// Crea una copia inmutable modificando campos específicos.
  SavingsMission copyWith({
    int? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    String? iconName,
    String? deadline,
    bool? isCompleted,
    bool? isShared,
    List<String>? collaborators,
    String? category,
  }) {
    return SavingsMission(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      iconName: iconName ?? this.iconName,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      isShared: isShared ?? this.isShared,
      collaborators: collaborators ?? this.collaborators,
      category: category ?? this.category,
    );
  }

  /// Ordena una lista de metas sin mutar la original según el criterio elegido.
  static List<SavingsMission> sortMissions(
    List<SavingsMission> missions,
    SavingsSortOrder order,
  ) {
    final copy = List<SavingsMission>.from(missions);
    switch (order) {
      case SavingsSortOrder.recent:
        return copy;
      case SavingsSortOrder.urgent:
        copy.sort((a, b) {
          if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
          final da = a.daysRemaining;
          final db = b.daysRemaining;
          if (da == null && db == null) return 0;
          if (da == null) return 1;
          if (db == null) return -1;
          return da.compareTo(db);
        });
        return copy;
      case SavingsSortOrder.progress:
        copy.sort((a, b) => b.progressFraction.compareTo(a.progressFraction));
        return copy;
      case SavingsSortOrder.highestTarget:
        copy.sort((a, b) => b.targetAmount.compareTo(a.targetAmount));
        return copy;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SavingsMission && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'SavingsMission(id: $id, title: $title, progress: $progressPercent%, shared: $isShared)';
}

// ── Criterios de ordenamiento de metas ─────────────────────────────────────

/// Criterios disponibles para ordenar la lista de metas de ahorro.
enum SavingsSortOrder {
  recent,        // Orden por defecto
  urgent,        // Menor cantidad de días restantes primero
  progress,      // Mayor porcentaje completado primero
  highestTarget, // Mayor monto objetivo primero
}

extension SavingsSortOrderX on SavingsSortOrder {
  String get label {
    switch (this) {
      case SavingsSortOrder.recent:        return 'Recientes';
      case SavingsSortOrder.urgent:        return 'Más urgentes';
      case SavingsSortOrder.progress:      return 'Mayor progreso';
      case SavingsSortOrder.highestTarget: return 'Mayor objetivo';
    }
  }
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
