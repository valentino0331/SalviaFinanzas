/// Día calendario de Perú, igual que el backend (UTC-5, sin horario de verano).
///
/// Se devuelve una fecha UTC a medianoche como representación del día, no como
/// instante de realización del hábito. Así no depende de la zona del dispositivo.
class HabitCalendar {
  HabitCalendar._();

  static const offset = Duration(hours: -5);

  static DateTime dayFor(DateTime instant) {
    final peru = instant.toUtc().add(offset);
    return DateTime.utc(peru.year, peru.month, peru.day);
  }

  static DateTime today() => dayFor(DateTime.now());

  static DateTime nextMidnight(DateTime instant) =>
      dayFor(instant).add(const Duration(days: 1)).subtract(offset);
}
