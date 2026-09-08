import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../core/providers.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardState = ref.watch(leaderboardProvider);
    final currentUser = ref.watch(authProvider).user;

    return Scaffold(
      body: leaderboardState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: RusticTheme.primaryGreen)),
        error: (err, _) => Center(child: Text("Error al cargar clasificación: $err")),
        data: (rankings) {
          return RefreshIndicator(
            onRefresh: () async => ref.read(leaderboardProvider.notifier).loadLeaderboard(),
            color: RusticTheme.primaryGreen,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(18.0),
              children: [
                // Cabecera explicativa
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: RusticTheme.terracotta.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: RusticTheme.terracotta.withOpacity(0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tabla de Clasificación 🏆",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: RusticTheme.terracotta,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Compite sanamente con otros estudiantes y ahorradores. Sube peldaños en la tabla registrando tus gastos y cumpliendo tus rutinas de ahorro.",
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: RusticTheme.darkText.withOpacity(0.8),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  "Clasificación Global",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),

                // Lista de puestos
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rankings.length,
                  itemBuilder: (context, index) {
                    final competitor = rankings[index];
                    final rank = index + 1;
                    final isMe = competitor['id'] == currentUser?['id'];
                    final points = competitor['points'] ?? 0;
                    final streak = competitor['streak'] ?? 0;

                    // Estilo de podio
                    Widget? rankBadge;
                    if (rank == 1) {
                      rankBadge = const Icon(Icons.emoji_events, color: Color(0xFFD4AF37), size: 28);
                    } else if (rank == 2) {
                      rankBadge = const Icon(Icons.emoji_events, color: Color(0xFFC0C0C0), size: 26);
                    } else if (rank == 3) {
                      rankBadge = const Icon(Icons.emoji_events, color: Color(0xFFCD7F32), size: 24);
                    } else {
                      rankBadge = Text(
                        "#$rank",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: RusticTheme.lightText,
                        ),
                      );
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: isMe ? RusticTheme.primaryGreen.withOpacity(0.06) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isMe ? RusticTheme.primaryGreen : const Color(0xFFE4E2DC),
                          width: isMe ? 1.5 : 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 32,
                              alignment: Alignment.center,
                              child: rankBadge,
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 18,
                              backgroundImage: competitor['avatar_url'] != null
                                  ? NetworkImage(competitor['avatar_url'])
                                  : null,
                              backgroundColor: RusticTheme.primaryGreen.withOpacity(0.1),
                              child: competitor['avatar_url'] == null
                                  ? const Icon(Icons.person, color: RusticTheme.primaryGreen)
                                  : null,
                            ),
                          ],
                        ),
                        title: Text(
                          competitor['name'] ?? 'Usuario',
                          style: GoogleFonts.outfit(
                            fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                            fontSize: 14.5,
                            color: isMe ? RusticTheme.primaryGreen : RusticTheme.darkText,
                          ),
                        ),
                        subtitle: Text(
                          "Racha: $streak🔥",
                          style: GoogleFonts.outfit(fontSize: 12, color: RusticTheme.lightText),
                        ),
                        trailing: Text(
                          "$points pts",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                            color: RusticTheme.darkText,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
