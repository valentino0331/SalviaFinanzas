/// Reglas comunes para hábitos personalizados y sugeridos.
class HabitRewards {
  HabitRewards._();

  static const basePoints = 10;
  static const streakBonus = 15;
  static const bonusInterval = 7;

  // Los registros de recuperación v1 podían contener hasta 999 + 15 puntos.
  // Se respetan esos premios ya calculados, aunque cambie la regla actual.
  static const maxLegacyPendingPoints = 1014;

  static int pointsForStreak(int streak) =>
      basePoints +
      (streak > 0 && streak % bonusInterval == 0 ? streakBonus : 0);
}
