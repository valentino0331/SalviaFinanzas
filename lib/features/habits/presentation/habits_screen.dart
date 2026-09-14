import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../core/providers.dart';
import 'dialogs/add_habit_dialog.dart';
import 'dialogs/habit_completed_dialog.dart';
import 'widgets/habits_top_bar.dart';
import 'widgets/hero_habits_card.dart';
import 'widgets/habit_card.dart';
import 'widgets/recommendation_card.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  static const List<Map<String, dynamic>> recommendedTemplates = [
    { 'title': 'Registrar gastos diarios', 'description': 'Ingresar todo lo gastado antes de dormir.', 'points_reward': 10 },
    { 'title': 'Ahorrar S/ 5 diarios', 'description': 'Desviar S/ 5 diarios directamente a tu alcancía.', 'points_reward': 20 },
    { 'title': 'Cocinar en casa', 'description': 'Preparar almuerzo o cena en casa para ahorrar.', 'points_reward': 10 },
    { 'title': 'Levantarme a las 6:00 AM', 'description': 'Aprovechar las primeras horas del día.', 'points_reward': 15 },
    { 'title': 'Revisar presupuesto semanal', 'description': 'Evaluar si vas por buen camino con tu dinero.', 'points_reward': 20 },
    { 'title': 'Leer 15 minutos', 'description': 'Aprender algo nuevo o leer un libro financiero.', 'points_reward': 15 },
  ];

  void _completeHabit(BuildContext context, WidgetRef ref, int habitId, String title) async {
    try {
      await HapticFeedback.mediumImpact();
      final points = await ref.read(habitsProvider.notifier).completeHabit(habitId);

      if (context.mounted) {
        showHabitCompletedDialog(context, title, points);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: const Color(0xFFD94841),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsState = ref.watch(habitsProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final userName = (user?['name'] ?? 'Usuario').toString();
    final initials = userName.isNotEmpty
        ? userName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'MR';
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F3),
      body: SafeArea(
        child: habitsState.when(
          loading: () => const Center(child: CircularProgressIndicator(color: RusticTheme.primaryGreen)),
          error: (err, _) => Center(child: Text("Error al cargar hábitos: $err")),
          data: (habits) {
            final activeTitles = habits.map((h) => h['title'] as String).toSet();
            final pendingRecommendations = recommendedTemplates.where((t) => !activeTitles.contains(t['title'])).toList();

            return RefreshIndicator(
              onRefresh: () async => ref.read(habitsProvider.notifier).loadHabits(),
              color: RusticTheme.primaryGreen,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                children: [
                  // Top Bar
                  HabitsTopBar(initials: initials),
                  const SizedBox(height: 18),

                  // Hero Card de Hábitos
                  HeroHabitsCard(habitsCount: habits.length),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rutina de Hoy",
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF132A1D),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => showAddHabitDialog(context, ref),
                        icon: const Icon(Icons.add, size: 16),
                        label: Text(
                          "Crear Hábito",
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF009668)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (habits.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      alignment: Alignment.center,
                      child: Text(
                        "No has configurado ningún hábito diario aún.",
                        style: GoogleFonts.outfit(fontStyle: FontStyle.italic, color: const Color(0xFF7A8B7E)),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.15,
                      ),
                      itemCount: habits.length,
                      itemBuilder: (context, index) {
                        final h = habits[index];
                        final bool isCompletedToday = h['last_completed_at'] == todayStr;

                        return HabitCard(
                          habit: h,
                          isCompletedToday: isCompletedToday,
                          onTap: isCompletedToday
                              ? null
                              : () => _completeHabit(context, ref, h['id'], h['title'] ?? ""),
                        );
                      },
                    ),
                  const SizedBox(height: 28),
                  Text(
                    "Sugerencias de Buenos Hábitos 🌿",
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF132A1D),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (pendingRecommendations.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                      child: Text(
                        "¡Has adoptado todas las recomendaciones sugeridas! 🌟",
                        style: GoogleFonts.outfit(fontSize: 12.5, fontStyle: FontStyle.italic, color: const Color(0xFF7A8B7E)),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pendingRecommendations.length,
                      itemBuilder: (context, index) {
                        final template = pendingRecommendations[index];
                        return RecommendationCard(
                          template: template,
                          onAdopt: () async {
                            await HapticFeedback.lightImpact();
                            ref.read(habitsProvider.notifier).addHabit(
                              template['title'],
                              template['description'],
                              template['points_reward'],
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("¡Hábito \"${template['title']}\" adoptado! 🌿")),
                              );
                            }
                          },
                        );
                      },
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
