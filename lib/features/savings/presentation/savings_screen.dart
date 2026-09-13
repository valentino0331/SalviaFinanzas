import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../core/providers.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  IconData _getMissionIcon(String? iconName) {
    switch (iconName) {
      case 'school':
        return Icons.school_outlined;
      case 'fitness_center':
        return Icons.fitness_center_outlined;
      case 'flight':
        return Icons.flight_takeoff_outlined;
      case 'laptop':
        return Icons.laptop_chromebook_outlined;
      case 'sports_car':
        return Icons.directions_car_outlined;
      case 'home':
        return Icons.home_outlined;
      case 'restaurant':
        return Icons.restaurant_outlined;
      case 'card_giftcard':
        return Icons.card_giftcard_outlined;
      default:
        return Icons.savings_outlined;
    }
  }

  void _showAddMissionDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    String selectedIcon = 'savings';

    final List<String> availableIcons = [
      'savings',
      'school',
      'fitness_center',
      'flight',
      'laptop',
      'sports_car',
      'home',
      'restaurant',
      'card_giftcard'
    ];

    final Map<String, IconData> allIconMapping = {
      'savings': Icons.savings,
      'school': Icons.school,
      'fitness_center': Icons.fitness_center,
      'flight': Icons.flight,
      'laptop': Icons.laptop,
      'sports_car': Icons.directions_car,
      'home': Icons.home,
      'restaurant': Icons.restaurant,
      'card_giftcard': Icons.card_giftcard,
    };

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4EDE5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_task, color: Color(0xFF285038), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Nueva Meta de Ahorro",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF132A1D),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "¿Qué deseas financiar?",
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF526E5D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF132A1D)),
                      decoration: InputDecoration(
                        hintText: "Ej. Fondo de emergencia, Viaje a Cusco",
                        hintStyle: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF9EABA1)),
                        filled: true,
                        fillColor: const Color(0xFFF3F6F3),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF009668), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Monto Objetivo (S/)",
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF526E5D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: targetController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF132A1D)),
                      decoration: InputDecoration(
                        prefixText: "S/ ",
                        prefixStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF009668)),
                        hintText: "500.00",
                        hintStyle: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF9EABA1)),
                        filled: true,
                        fillColor: const Color(0xFFF3F6F3),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF009668), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "Selecciona un ícono:",
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF526E5D),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: availableIcons.map((plantId) {
                        final isSelected = selectedIcon == plantId;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIcon = plantId;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF1E3A2B) : const Color(0xFFE4EDE5),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? const Color(0xFF00E676) : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF00E676).withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              allIconMapping[plantId] ?? Icons.savings,
                              color: isSelected ? Colors.white : const Color(0xFF285038),
                              size: 18,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancelar",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF758A7A),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final target = double.tryParse(targetController.text) ?? 0.0;
                    if (title.isNotEmpty && target > 0) {
                      await HapticFeedback.mediumImpact();
                      ref.read(savingsProvider.notifier).addMission(title, target, iconName: selectedIcon);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("¡Meta '$title' creada con éxito! 🌿", style: GoogleFonts.outfit()),
                            backgroundColor: const Color(0xFF009668),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009668),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    "Crear meta",
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSaveFundsDialog(BuildContext context, WidgetRef ref, int missionId, String title) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4EDE5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.savings_outlined, color: Color(0xFF285038), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Aportar Ahorro",
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF132A1D),
                          ),
                        ),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: const Color(0xFF758A7A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Accesos rápidos:",
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF526E5D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [10, 20, 50, 100].map((amt) {
                      return InkWell(
                        onTap: () {
                          amountController.text = amt.toString();
                          setState(() {});
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4EDE5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFD3E0D4)),
                          ),
                          child: Text(
                            "+S/ $amt",
                            style: GoogleFonts.outfit(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF285038),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "O escribe el monto exacto:",
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF526E5D),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    autofocus: true,
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF132A1D)),
                    decoration: InputDecoration(
                      prefixText: "S/ ",
                      prefixStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF009668)),
                      hintText: "0.00",
                      hintStyle: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF9EABA1)),
                      filled: true,
                      fillColor: const Color(0xFFF3F6F3),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF009668), width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancelar",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF758A7A),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final amt = double.tryParse(amountController.text) ?? 0.0;
                    if (amt > 0) {
                      await HapticFeedback.mediumImpact();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                      final isCompleted = await ref.read(savingsProvider.notifier).saveFunds(missionId, amt);
                      ref.read(advisorProvider.notifier).loadReport();

                      if (context.mounted) {
                        if (isCompleted) {
                          _showSuccessAnimationDialog(context, title);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Aporte de S/ $amt realizado a '$title'. ¡Paso a paso! 🌻", style: GoogleFonts.outfit()),
                              backgroundColor: const Color(0xFF009668),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009668),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    "Aportar",
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSuccessAnimationDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Color(0xFFFFB300),
                  size: 46,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                "¡Meta Florecida!",
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF132A1D),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Has completado tu objetivo con éxito:\n\"$title\"\n\n¡Ganaste +100 puntos de experiencia! 🏆",
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: const Color(0xFF4A5D4F),
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009668),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text("¡Excelente!", style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, int missionId, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            "Eliminar meta",
            style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: const Color(0xFF132A1D)),
          ),
          content: Text(
            "¿Estás seguro de que deseas eliminar la meta \"$title\"?",
            style: GoogleFonts.outfit(fontSize: 13.5, color: const Color(0xFF526E5D)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: GoogleFonts.outfit(color: const Color(0xFF758A7A))),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(savingsProvider.notifier).deleteMission(missionId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Meta eliminada", style: GoogleFonts.outfit()),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD94841),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Eliminar", style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savingsState = ref.watch(savingsProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final userName = (user?['name'] ?? 'Usuario').toString();
    final initials = userName.isNotEmpty
        ? userName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'MR';
    final userPoints = (user?['points'] as int?) ?? 0;
    final currencyFormat = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ', decimalDigits: 2);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F3),
      body: SafeArea(
        child: savingsState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: RusticTheme.primaryGreen),
          ),
          error: (err, _) => Center(child: Text("Error al cargar metas: $err")),
          data: (missions) {
            // Cálculos agregados para el Hero Dial y Métricas
            double totalSaved = 0.0;
            double totalTarget = 0.0;
            int completedCount = 0;

            for (final m in missions) {
              final cur = double.tryParse(m['current_amount']?.toString() ?? '0') ?? 0.0;
              final tgt = double.tryParse(m['target_amount']?.toString() ?? '0') ?? 0.0;
              totalSaved += cur;
              totalTarget += tgt;
              if (m['is_completed'] == true || (tgt > 0 && cur >= tgt)) {
                completedCount++;
              }
            }

            final activeCount = missions.length - completedCount;
            final double globalProgress = totalTarget > 0 ? (totalSaved / totalTarget) : 0.0;
            final int displayPercent = (globalProgress * 100).clamp(0, 100).toInt();

            // Determinar descripción del estado
            String statusTitle = "Salud: Excelente 🌿";
            String statusDescription = "Tus ahorros avanzan a paso firme.\nMantienes un ritmo admirable hacia tus sueños.";

            if (missions.isEmpty) {
              statusTitle = "Salud: Por Iniciar 🌱";
              statusDescription = "Aún no tienes metas activas registradas.\nComienza hoy a sembrar tus objetivos.";
            } else if (displayPercent >= 100) {
              statusTitle = "Salud: ¡Metas Cumplidas! 🎉";
              statusDescription = "¡Felicidades! Has completado el 100% de tus metas.\nEs momento de plantearte nuevos horizontes.";
            } else if (displayPercent < 30) {
              statusTitle = "Salud: Brote Inicial 🍀";
              statusDescription = "Cada sol que apartas fortalece tu futuro.\nPequeños aportes diarios hacen una gran diferencia.";
            }

            return RefreshIndicator(
              onRefresh: () async => ref.read(savingsProvider.notifier).loadMissions(),
              color: RusticTheme.primaryGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOP BAR: "SALVIA" + "Ahorros & Metas" + Avatar Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                              "Ahorros & Metas",
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF132A1D),
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        // Avatar con círculo y badge verde
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

                    // HERO CARD: Verde Oscuro Gradiente con Dial de Ahorro
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF2E513C),
                            Color(0xFF1B3828),
                            Color(0xFF132A1C),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1B3828).withValues(alpha: 0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Tag superior: "BÓVEDA DE AHORROS"
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.savings_outlined,
                                  size: 14,
                                  color: Color(0xFFA5D6A7),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "BÓVEDA DE AHORROS",
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.4,
                                  color: const Color(0xFFA5D6A7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // DIAL CIRCULAR DE PROGRESO DE AHORRO (Glow verde y radio)
                          SizedBox(
                            width: 170,
                            height: 170,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Línea exterior tenue
                                Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.08),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                // Anillo de progreso con glow verde neón
                                SizedBox(
                                  width: 140,
                                  height: 140,
                                  child: CircularProgressIndicator(
                                    value: missions.isEmpty ? 0.0 : globalProgress.clamp(0.0, 1.0),
                                    strokeWidth: 9,
                                    backgroundColor: Colors.white.withValues(alpha: 0.09),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "$displayPercent%",
                                      style: GoogleFonts.outfit(
                                        fontSize: 42,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        height: 1.0,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      missions.isEmpty ? "/ META" : "/ OBJETIVO",
                                      style: GoogleFonts.outfit(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white.withValues(alpha: 0.65),
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Pill badge: "Salud: ..."
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.eco, color: Color(0xFF69F0AE), size: 15),
                                const SizedBox(width: 6),
                                Text(
                                  statusTitle,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFC8E6C9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Descripción corta
                          Text(
                            statusDescription,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              color: Colors.white.withValues(alpha: 0.85),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Métricas inferiores: AHORRADO | OBJETIVO | METAS
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _metricColumn("AHORRADO", currencyFormat.format(totalSaved), Colors.white),
                                Container(width: 1, height: 26, color: Colors.white.withValues(alpha: 0.12)),
                                _metricColumn("OBJETIVO", currencyFormat.format(totalTarget), const Color(0xFF69F0AE)),
                                Container(width: 1, height: 26, color: Colors.white.withValues(alpha: 0.12)),
                                _metricColumn("METAS", "$activeCount activas", const Color(0xFFFFD54F)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),

                    // SECCIÓN: "Notas del Asesor Salvia" / Consejos de Ahorro (con badge 'Recomendado')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Notas del Asesor Salvia",
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF132A1D),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2EBE3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Recomendado",
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF386641),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // TARJETA DE NOTA/CONSEJO ESTILO SALVIA
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE7ECE7)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE4EDE5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.lightbulb_outline,
                                  color: Color(0xFF285038),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Estrategia de ahorro",
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF132A1D),
                                      ),
                                    ),
                                    Text(
                                      "Personalizado para ti",
                                      style: GoogleFonts.outfit(
                                        fontSize: 11.5,
                                        color: const Color(0xFF758A7A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00E676),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            missions.isNotEmpty
                                ? "Regla 50/30/20: Separa tus aportes al inicio de cada mes en lugar de esperar lo que sobre. Con pequeños hábitos diarios, aceleras tu meta '${missions.first['title']}'."
                                : "Aún no tienes metas de ahorro activas. Crear una meta con monto definido te ayuda a mantener el foco y evitar fugas de dinero hormiga.",
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: const Color(0xFF4A5D4F),
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Botón: "Crear una meta"
                          InkWell(
                            onTap: () => _showAddMissionDialog(context, ref),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2B4434),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Crear una meta",
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF41614C),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),

                    // SECCIÓN: "Tus Metas Activas"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tus Metas Activas",
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF132A1D),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2EBE3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${missions.length} en total",
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF386641),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Si no hay metas: Estado Vacío Moderno
                    if (missions.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(26),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE7ECE7)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 68,
                                    height: 68,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE5EDE6),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.savings_outlined,
                                      size: 32,
                                      color: Color(0xFF285038),
                                    ),
                                  ),
                                  Positioned(
                                    top: -2,
                                    right: -2,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF00A86B),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Aún no hay metas de ahorro",
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF132A1D),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Registra tus metas de ahorro para cultivar\ntu patrimonio y recibir recomendaciones\npersonalizadas.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: 12.5,
                                  color: const Color(0xFF758A7A),
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () => _showAddMissionDialog(context, ref),
                                icon: const Icon(Icons.add, size: 18),
                                label: Text(
                                  "Crear meta de ahorro",
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF009668),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...missions.map((m) {
                        final target = double.tryParse(m['target_amount']?.toString() ?? '0') ?? 0.0;
                        final current = double.tryParse(m['current_amount']?.toString() ?? '0') ?? 0.0;
                        final double pct = target > 0 ? (current / target) : 0.0;
                        final isCompleted = m['is_completed'] == true || (target > 0 && current >= target);

                        String plantEmoji = '🌱';
                        String plantState = 'Semilla sembrada';
                        if (isCompleted || pct >= 1.0) {
                          plantEmoji = '🌸';
                          plantState = '¡Meta Florecida!';
                        } else if (pct > 0.60) {
                          plantEmoji = '🍀';
                          plantState = 'Creciendo fuerte';
                        } else if (pct > 0.25) {
                          plantEmoji = '🌿';
                          plantState = 'Brote activo';
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isCompleted
                                  ? const Color(0xFF00C853).withValues(alpha: 0.3)
                                  : const Color(0xFFE7ECE7),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: isCompleted ? const Color(0xFFE4EDE5) : const Color(0xFFF0F5F1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      _getMissionIcon(m['icon_name']),
                                      color: isCompleted ? const Color(0xFF009668) : const Color(0xFF285038),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          m['title'] ?? 'Meta de ahorro',
                                          style: GoogleFonts.outfit(
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF132A1D),
                                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "Objetivo: ${currencyFormat.format(target)}",
                                          style: GoogleFonts.outfit(
                                            fontSize: 12,
                                            color: const Color(0xFF758A7A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isCompleted)
                                    ElevatedButton(
                                      onPressed: () => _showSaveFundsDialog(context, ref, m['id'], m['title']),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF009668),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: Text(
                                        "+ Aportar",
                                        style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE4EDE5),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.check_circle, color: Color(0xFF009668), size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Completada",
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFF009668),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    onPressed: () => _showDeleteConfirmDialog(context, ref, m['id'], m['title'] ?? ''),
                                    icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFA0B0A3)),
                                    splashRadius: 18,
                                    tooltip: "Eliminar meta",
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(plantEmoji, style: const TextStyle(fontSize: 16)),
                                      const SizedBox(width: 6),
                                      Text(
                                        plantState,
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isCompleted ? const Color(0xFF009668) : const Color(0xFF526E5D),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "${currencyFormat.format(current)} / ${currencyFormat.format(target)}",
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: const Color(0xFF132A1D),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: pct > 1.0 ? 1.0 : pct,
                                  minHeight: 8,
                                  color: const Color(0xFF009668),
                                  backgroundColor: const Color(0xFFE4EDE5),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    const SizedBox(height: 26),

                    // SECCIÓN: Semillero & Vivero (Gamificación / Recompensas)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Semillero & Vivero",
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF132A1D),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2EBE3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "$userPoints pts",
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF386641),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 108,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _shopItemCard(context, ref, 'school', 'Bonsai Salvia', '🌲', 0),
                          _shopItemCard(context, ref, 'savings', 'Flor de Loto', '🌸', 20),
                          _shopItemCard(context, ref, 'fitness_center', 'Cactus', '🌵', 40),
                          _shopItemCard(context, ref, 'flight', 'Palmera', '🌴', 75),
                          _shopItemCard(context, ref, 'laptop', 'Bambú', '🎋', 120),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _metricColumn(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _shopItemCard(BuildContext context, WidgetRef ref, String plantId, String name, String emoji, int cost) {
    final unlocked = ref.watch(unlockedPlantsProvider);
    final userPoints = ref.watch(authProvider).user?['points'] ?? 0;
    final isUnlocked = unlocked.contains(plantId) || cost == 0;

    return Container(
      width: 108,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isUnlocked ? const Color(0xFFEAF2EB) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnlocked ? const Color(0xFF009668).withValues(alpha: 0.3) : const Color(0xFFE7ECE7),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: isUnlocked ? null : () => _confirmUnlock(context, ref, plantId, name, cost, userPoints),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF132A1D),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? const Color(0xFF009668).withValues(alpha: 0.12)
                      : const Color(0xFFD97757).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isUnlocked ? "Listo" : "$cost pts",
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? const Color(0xFF009668) : const Color(0xFFD97757),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmUnlock(BuildContext context, WidgetRef ref, String plantId, String name, int cost, int userPoints) {
    if (userPoints < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Puntos insuficientes para desbloquear $name. ¡Sigue completando hábitos! 💪", style: GoogleFonts.outfit()),
          backgroundColor: const Color(0xFFD97757),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text("Desbloquear Planta", style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: const Color(0xFF132A1D))),
          content: Text("¿Deseas canjear $cost puntos para desbloquear el $name?", style: GoogleFonts.outfit(fontSize: 13.5, color: const Color(0xFF526E5D))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: GoogleFonts.outfit(color: const Color(0xFF758A7A))),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(authProvider.notifier).updateLocalPoints(userPoints - cost);
                ref.read(unlockedPlantsProvider.notifier).unlockPlant(plantId);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("¡Desbloqueaste $name! 🌱 Ya puedes usarla en tus metas.", style: GoogleFonts.outfit()),
                    backgroundColor: const Color(0xFF009668),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009668),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Desbloquear", style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }
}
