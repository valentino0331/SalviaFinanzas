import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../core/providers.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  IconData _getMissionIcon(String iconName) {
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
              title: Text("Nueva Meta de Ahorro", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "¿Qué deseas financiar?",
                        hintText: "Ej. Fondo de emergencia, Viaje",
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: targetController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      decoration: const InputDecoration(
                        labelText: "Monto Objetivo (S/.)",
                        hintText: "Ej. 500",
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "Selecciona un ícono representativo:",
                      style: GoogleFonts.outfit(fontSize: 13, color: RusticTheme.lightText),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: availableIcons.map((plantId) {
                        final isSelected = selectedIcon == plantId;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIcon = plantId;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFE4EDE5) : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? const Color(0xFF1E3A2B) : const Color(0xFFD4D2CC),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              allIconMapping[plantId] ?? Icons.help_outline, 
                              color: isSelected ? const Color(0xFF1E3A2B) : RusticTheme.lightText,
                              size: 20,
                            ),
                          ),
                        );
                      }).toList(),
                    )
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
                    final target = double.tryParse(targetController.text) ?? 0.0;
                    if (title.isNotEmpty && target > 0) {
                      await HapticFeedback.mediumImpact();
                      ref.read(savingsProvider.notifier).addMission(title, target, iconName: selectedIcon);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("¡Meta de ahorro creada con éxito! 🌿")),
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
      },
    );
  }

  void _showSaveFundsDialog(BuildContext context, WidgetRef ref, int missionId, String title) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Aportar a: $title", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "¿Cuánto dinero deseas abonar a tu meta de ahorro?",
                style: GoogleFonts.outfit(fontSize: 13, color: RusticTheme.lightText),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: "Monto de Ahorro (S/.)",
                  prefixIcon: Icon(Icons.savings_outlined),
                  prefixText: "S/ ",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: GoogleFonts.outfit(color: RusticTheme.lightText)),
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
                          content: Text("Ahorro de S/ $amt aportado. ¡Paso a paso! 🌻"),
                          backgroundColor: const Color(0xFF009668),
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF009668), foregroundColor: Colors.white),
              child: Text("Ahorrar", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessAnimationDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events,
                color: Color(0xFFFFB300),
                size: 80,
              ),
              const SizedBox(height: 18),
              Text(
                "¡Meta Cumplida!",
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A2B)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Has completado tu meta:\n\"$title\"\n\n¡Ganaste +100 puntos de experiencia! 🏆",
                style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF132A1D)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF009668), foregroundColor: Colors.white),
                child: Text("¡Genial!", style: GoogleFonts.outfit()),
              ),
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
    final currencyFormat = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ', decimalDigits: 2);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F3),
      body: SafeArea(
        child: savingsState.when(
          loading: () => const Center(child: CircularProgressIndicator(color: RusticTheme.primaryGreen)),
          error: (err, _) => Center(child: Text("Error al cargar metas: $err")),
          data: (missions) {
            return RefreshIndicator(
              onRefresh: () async => ref.read(savingsProvider.notifier).loadMissions(),
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
                            "Ahorros",
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

                  // Hero Card de Ahorros
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
                              "METAS DE AHORRO 🎯",
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
                                "${missions.length} activas",
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
                          "Cultiva tus metas",
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Divide tus grandes objetivos en pequeños aportes diarios y celebra cada logro financiero.",
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

                  // Sección Semillero & Vivero
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
                          "${ref.watch(authProvider).user?['points'] ?? 0} pts",
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
                    height: 105,
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
                  const SizedBox(height: 24),

                  // Lista de Metas
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
                      TextButton.icon(
                        onPressed: () => _showAddMissionDialog(context, ref),
                        icon: const Icon(Icons.add, size: 16),
                        label: Text("Nueva meta", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF009668)),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (missions.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      alignment: Alignment.center,
                      child: Text(
                        "No tienes metas de ahorro activas.",
                        style: GoogleFonts.outfit(fontStyle: FontStyle.italic, color: const Color(0xFF7A8B7E)),
                      ),
                    )
                  else
                    ...missions.map((m) {
                      final target = double.parse(m['target_amount'].toString());
                      final current = double.parse(m['current_amount'].toString());
                      final double pct = target > 0 ? (current / target) : 0.0;
                      final isCompleted = m['is_completed'] == true;

                      String plantEmoji = '🌱';
                      String plantState = 'Semilla sembrada';
                      if (isCompleted || pct >= 1.0) {
                        plantEmoji = '🌸';
                        plantState = 'Meta Florecida';
                      } else if (pct > 0.60) {
                        plantEmoji = '🍀';
                        plantState = 'Planta creciendo';
                      } else if (pct > 0.25) {
                        plantEmoji = '🌿';
                        plantState = 'Brote saliendo';
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isCompleted ? const Color(0xFF00C853).withOpacity(0.3) : const Color(0xFFE7ECE7),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? const Color(0xFFE4EDE5)
                                        : const Color(0xFFF3F6F3),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    _getMissionIcon(m['icon_name']),
                                    color: isCompleted ? const Color(0xFF1E3A2B) : const Color(0xFF6B7A6F),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m['title'],
                                        style: GoogleFonts.outfit(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: isCompleted ? const Color(0xFF009668) : const Color(0xFF132A1D),
                                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Objetivo: ${currencyFormat.format(target)}",
                                        style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF7A8B7E)),
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
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: Text("Ahorrar", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE4EDE5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check, color: Color(0xFF009668), size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Completado",
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFF009668),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
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
                                        fontWeight: FontWeight.w600,
                                        color: isCompleted ? const Color(0xFF009668) : const Color(0xFF6B7A6F),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "${currencyFormat.format(current)} / ${currencyFormat.format(target)}",
                                  style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF132A1D), fontWeight: FontWeight.bold),
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _shopItemCard(BuildContext context, WidgetRef ref, String plantId, String name, String emoji, int cost) {
    final unlocked = ref.watch(unlockedPlantsProvider);
    final userPoints = ref.watch(authProvider).user?['points'] ?? 0;
    final isUnlocked = unlocked.contains(plantId) || cost == 0;

    return Container(
      width: 105,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isUnlocked ? const Color(0xFFEAF2EB) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUnlocked ? const Color(0xFF009668).withOpacity(0.3) : const Color(0xFFE7ECE7),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: isUnlocked ? null : () => _confirmUnlock(context, ref, plantId, name, cost, userPoints),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
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
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isUnlocked 
                      ? const Color(0xFF009668).withOpacity(0.12) 
                      : const Color(0xFFD97757).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isUnlocked ? "Listo" : "$cost pts",
                  style: GoogleFonts.outfit(
                    fontSize: 9.5,
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
          content: Text("Puntos insuficientes para desbloquear $name. ¡Sigue completando hábitos! 💪"),
          backgroundColor: const Color(0xFFD97757),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Desbloquear Planta", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Text("¿Deseas canjear $cost puntos de racha para desbloquear el $name?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: GoogleFonts.outfit(color: RusticTheme.lightText)),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(authProvider.notifier).updateLocalPoints(userPoints - cost);
                ref.read(unlockedPlantsProvider.notifier).unlockPlant(plantId);
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("¡Desbloqueaste $name! 🌱 Ya puedes usarla en tus metas."),
                    backgroundColor: const Color(0xFF009668),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF009668), foregroundColor: Colors.white),
              child: Text("Desbloquear", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

