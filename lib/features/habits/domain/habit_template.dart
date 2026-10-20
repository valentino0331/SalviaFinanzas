/// Plantilla de hábito sugerido que el usuario puede adoptar.
///
/// Reemplaza la lista de `Map<String, dynamic>` que vivía dentro de la
/// pantalla, evitando claves escritas a mano y errores por typos.
class HabitTemplate {
  const HabitTemplate({
    required this.title,
    required this.description,
    required this.pointsReward,
  });

  final String title;
  final String description;
  final int pointsReward;
}

/// Catálogo de recomendaciones de buenos hábitos financieros.
const List<HabitTemplate> habitTemplates = [
  HabitTemplate(
    title: 'Registrar gastos diarios',
    description: 'Ingresar todo lo gastado antes de dormir.',
    pointsReward: 10,
  ),
  HabitTemplate(
    title: 'Ahorrar S/ 5 diarios',
    description: 'Desviar S/ 5 diarios directamente a tu alcancía.',
    pointsReward: 20,
  ),
  HabitTemplate(
    title: 'Cocinar en casa',
    description: 'Preparar almuerzo o cena en casa para ahorrar.',
    pointsReward: 10,
  ),
  HabitTemplate(
    title: 'Levantarme a las 6:00 AM',
    description: 'Aprovechar las primeras horas del día.',
    pointsReward: 15,
  ),
  HabitTemplate(
    title: 'Revisar presupuesto semanal',
    description: 'Evaluar si vas por buen camino con tu dinero.',
    pointsReward: 20,
  ),
  HabitTemplate(
    title: 'Leer 15 minutos',
    description: 'Aprender algo nuevo o leer un libro financiero.',
    pointsReward: 15,
  ),
];
