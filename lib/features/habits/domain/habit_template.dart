import 'habit_rewards.dart';

/// Plantilla de hábito sugerido que el usuario puede adoptar.
///
/// Reemplaza la lista de `Map<String, dynamic>` que vivía dentro de la
/// pantalla, evitando claves escritas a mano y errores por typos.
class HabitTemplate {
  const HabitTemplate({required this.title, required this.description});

  final String title;
  final String description;
  int get pointsReward => HabitRewards.basePoints;
}

/// Catálogo de recomendaciones de buenos hábitos financieros.
const List<HabitTemplate> habitTemplates = [
  HabitTemplate(
    title: 'Registrar gastos diarios',
    description: 'Ingresar todo lo gastado antes de dormir.',
  ),
  HabitTemplate(
    title: 'Ahorrar S/ 5 diarios',
    description: 'Desviar S/ 5 diarios directamente a tu alcancía.',
  ),
  HabitTemplate(
    title: 'Cocinar en casa',
    description: 'Preparar almuerzo o cena en casa para ahorrar.',
  ),
  HabitTemplate(
    title: 'Levantarme a las 6:00 AM',
    description: 'Aprovechar las primeras horas del día.',
  ),
  HabitTemplate(
    title: 'Revisar presupuesto semanal',
    description: 'Evaluar si vas por buen camino con tu dinero.',
  ),
  HabitTemplate(
    title: 'Leer 15 minutos',
    description: 'Aprender algo nuevo o leer un libro financiero.',
  ),
];
