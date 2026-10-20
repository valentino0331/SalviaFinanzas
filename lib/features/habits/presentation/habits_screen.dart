import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../core/providers.dart';
import '../application/habits_providers.dart';
import '../domain/habit_template.dart';
import 'dialogs/add_habit_dialog.dart';
import 'dialogs/habit_completed_dialog.dart';
import 'widgets/habits_top_bar.dart';
import 'widgets/hero_habits_card.dart';
import 'widgets/habit_card.dart';
import 'widgets/recommendation_card.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  void _completeHabit(BuildContext context, WidgetRef ref, int habitId, String title) async {
    try {
      await HapticFeedback.mediumImpact();
      final points = await ref.read(habitsActionsProvider).completeHabit(habitId);

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
    final habitsState = ref.watch(habitsViewProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final userName = (user?['name'] ?? 'Usuario').toString();
    final initials = userName.isNotEmpty
        ? userName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'MR';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F3),
      body: SafeArea(
        child: habitsState.when(
          loading: () => const Center(child: CircularProgressIndicator(color: RusticTheme.primaryGreen)),
          error: (err, _) => Center(child: Text("Error al cargar hábitos: $err")),
          data: (habits) {
            final activeTitles = habits.map((h) => h.title).toSet();
            final pendingRecommendations = habitTemplates.where((t) => !activeTitles.contains(t.title)).toList();

            return RefreshIndicator(
              onRefresh: () async => ref.read(habitsActionsProvider).refresh(),
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
                        onPressed: () => showAddHabitDialog(context),
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
                        final habit = habits[index];

                        return HabitCard(
                          habit: habit,
                          onTap: habit.isCompletedToday
                              ? null
                              : () => _completeHabit(context, ref, habit.id, habit.title),
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
                            try {
                              await ref.read(habitsActionsProvider).addHabit(
                                    title: template.title,
                                    description: template.description,
                                    pointsReward: template.pointsReward,
                                  );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("¡Hábito \"${template.title}\" adoptado! 🌿")),
                                );
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
