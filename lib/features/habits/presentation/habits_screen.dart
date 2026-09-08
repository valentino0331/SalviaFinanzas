import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../core/providers.dart';

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

  void _showAddHabitDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final pointsController = TextEditingController(text: "15");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Crear Hábito Saludable", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Hábito",
                    hintText: "Ej. Leer 15 mins, Hacer ejercicio",
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: "Descripción corta",
                    hintText: "Ej. Para cultivar mi mente y bienestar",
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pointsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Recompensa de Puntos",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: GoogleFonts.outfit(color: RusticTheme.lightText)),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final desc = descController.text.trim();
                final pts = int.tryParse(pointsController.text) ?? 10;
                
                if (title.isNotEmpty) {
                  await HapticFeedback.lightImpact();
                  ref.read(habitsProvider.notifier).addHabit(title, desc, pts);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("¡Nuevo hábito sembrado! 🌱")),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF009668), foregroundColor: Colors.white),
              child: Text("Crear", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _completeHabit(BuildContext context, WidgetRef ref, int habitId, String title) async {
    try {
      await HapticFeedback.mediumImpact();
      final points = await ref.read(habitsProvider.notifier).completeHabit(habitId);
      
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.stars,
                    color: Color(0xFFFFB300),
                    size: 60,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "¡Buen Trabajo!",
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A2B)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Has completado: \"$title\".\n\n¡Ganaste +$points puntos! 🌻",
                    style: GoogleFonts.outfit(fontSize: 13.5, color: const Color(0xFF132A1D)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF009668), foregroundColor: Colors.white),
                    child: Text("Continuar", style: GoogleFonts.outfit()),
                  ),
                )
              ],
            );
          },
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "SALVIA",
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.8,
                              color: const Color(0xFF526E5D),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Hábitos",
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF132A1D),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF355240),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFC3E7C9),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E676),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFF3F6F3), width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Hero Card de Hábitos
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF2E513C),
                          Color(0xFF1B3828),
                          Color(0xFF132A1C),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1B3828).withOpacity(0.35),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "RUTINAS DIARIAS ✨",
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.4,
                                color: const Color(0xFFA5D6A7),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${habits.length} configurados",
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFC8E6C9),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Cultiva tu disciplina",
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Mantener rutinas diarias te otorga bonos especiales de racha y puntos para tu vivero.",
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            color: Colors.white.withOpacity(0.8),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                        onPressed: () => _showAddHabitDialog(context, ref),
                        icon: const Icon(Icons.add, size: 16),
                        label: Text("Crear Hábito", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF009668)),
                      )
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
                        final int streak = h['streak'] ?? 0;
                        final int pts = h['points_reward'] ?? 10;
                        final String title = h['title'] ?? "";
                        final String desc = h['description'] ?? "";

                        return InkWell(
                          onTap: isCompletedToday ? null : () => _completeHabit(context, ref, h['id'], title),
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.all(14.0),
                            decoration: BoxDecoration(
                              color: isCompletedToday 
                                  ? const Color(0xFFEAF4EC) 
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isCompletedToday 
                                    ? const Color(0xFF009668).withOpacity(0.4) 
                                    : const Color(0xFFE7ECE7),
                                width: isCompletedToday ? 1.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      isCompletedToday ? Icons.check_circle : Icons.radio_button_unchecked,
                                      color: isCompletedToday ? const Color(0xFF009668) : const Color(0xFF8B9E8F),
                                      size: 20,
                                    ),
                                    if (streak > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFD54F).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          "$streak 🔥",
                                          style: GoogleFonts.outfit(
                                            fontSize: 11,
                                            color: const Color(0xFFB37400),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13.5,
                                          color: isCompletedToday ? const Color(0xFF6B7A6F) : const Color(0xFF132A1D),
                                          decoration: isCompletedToday ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        desc,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.outfit(
                                          fontSize: 10.5,
                                          color: const Color(0xFF7A8B7E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isCompletedToday 
                                        ? const Color(0xFF009668).withOpacity(0.1) 
                                        : const Color(0xFFF3F6F3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "+$pts pts",
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: isCompletedToday 
                                          ? const Color(0xFF009668) 
                                          : const Color(0xFF2E513C),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE7ECE7)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE4EDE5),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.eco_outlined, color: Color(0xFF285038), size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      template['title'],
                                      style: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.w700, color: const Color(0xFF132A1D)),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "${template['description']} • +${template['points_reward']} pts",
                                      style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF7A8B7E)),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF009668),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text("Adoptar", style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
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

