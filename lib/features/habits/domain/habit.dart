/// Modelo de dominio inmutable que representa un hábito diario del usuario.
///
/// La feature venía manipulando `Map<String, dynamic>` sueltos en la UI, lo
/// que expone a fallos en runtime si una clave cambia de nombre o llega nula.
/// Este modelo aísla el formato del backend y ofrece acceso tipado.
class Habit {
  const Habit({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsReward,
    this.streak = 0,
    this.lastCompletedAt,
  });

  final int id;
  final String title;
  final String description;
  final int pointsReward;
  final int streak;

  /// Día de la última vez que se completó el hábito.
  /// El backend la entrega como texto `YYYY-MM-DD` en `last_completed_at`.
  final DateTime? lastCompletedAt;

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: (map['id'] as num?)?.toInt() ?? 0,
      title: (map['title'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      pointsReward: (map['points_reward'] as num?)?.toInt() ?? 10,
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      lastCompletedAt: _parseDate(map['last_completed_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'points_reward': pointsReward,
      'streak': streak,
      'last_completed_at': _formatDate(lastCompletedAt),
    };
  }

  /// Indica si el hábito fue completado en el día de [day].
  bool isCompletedOn(DateTime day) {
    final completed = lastCompletedAt;
    if (completed == null) return false;
    return completed.year == day.year &&
        completed.month == day.month &&
        completed.day == day.day;
  }

  /// Atajo para el día de hoy, usado por la capa de presentación.
  bool get isCompletedToday => isCompletedOn(DateTime.now());

  static DateTime? _parseDate(Object? raw) {
    if (raw == null) return null;
    final text = raw.toString().trim();
    if (text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  static String? _formatDate(DateTime? date) {
    if (date == null) return null;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
