import 'habit_rewards.dart';
import 'habit_validators.dart';

/// Plantilla de hábito sugerido que el usuario puede adoptar.
///
/// Reemplaza la lista de `Map<String, dynamic>` que vivía dentro de la
/// pantalla, evitando claves escritas a mano y errores por typos.
class HabitTemplate {
  const HabitTemplate({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;
  int get pointsReward => HabitRewards.basePoints;
}

/// Catálogo de recomendaciones de buenos hábitos financieros.
const List<HabitTemplate> habitTemplates = [
  HabitTemplate(
    id: 'registrar_gastos',
    title: 'Registrar gastos diarios',
    description: 'Ingresar todo lo gastado antes de dormir.',
  ),
  HabitTemplate(
    id: 'ahorro_diario',
    title: 'Ahorrar S/ 5 diarios',
    description: 'Desviar S/ 5 diarios directamente a tu alcancía.',
  ),
  HabitTemplate(
    id: 'cocinar_en_casa',
    title: 'Cocinar en casa',
    description: 'Preparar almuerzo o cena en casa para ahorrar.',
  ),
  HabitTemplate(
    id: 'levantarse_temprano',
    title: 'Levantarme a las 6:00 AM',
    description: 'Aprovechar las primeras horas del día.',
  ),
  HabitTemplate(
    id: 'revisar_presupuesto',
    title: 'Revisar presupuesto semanal',
    description: 'Evaluar si vas por buen camino con tu dinero.',
  ),
  HabitTemplate(
    id: 'lectura_diaria',
    title: 'Leer 15 minutos',
    description: 'Aprender algo nuevo o leer un libro financiero.',
  ),
];

/// Compatibilidad para hábitos anteriores que aún conservan el título original.
String? templateIdForTitle(String title) {
  final normalized = HabitValidators.normalizeTitle(title);
  for (final template in habitTemplates) {
    if (HabitValidators.normalizeTitle(template.title) == normalized) {
      return template.id;
    }
  }
  return null;
}
