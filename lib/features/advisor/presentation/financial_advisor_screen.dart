import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../core/providers.dart';
import '../../expenses/presentation/expense_form.dart';
import '../../savings/presentation/savings_screen.dart';

class FinancialAdvisorScreen extends ConsumerWidget {
  const FinancialAdvisorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final advisorState = ref.watch(advisorProvider);
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
        child: advisorState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: RusticTheme.primaryGreen),
          ),
          error: (err, _) => Center(child: Text("Error al cargar reporte: $err")),
          data: (report) {
            final score = report['score'] as int? ?? 100;
            final status = report['status'] as String? ?? 'Excelente';
            final totalSpent = double.tryParse(report['total_spent_30_days']?.toString() ?? '0') ?? 0.0;
            final List<dynamic> tips = report['tips'] ?? [];
            final int streak = (user?['streak'] as int?) ?? 7;

            // Determinar descripción del estado
            String statusDescription = "Tus finanzas están en excelente estado.\nMantienes un buen equilibrio financiero.";
            if (status == 'Crítico') {
              statusDescription = "Tus finanzas requieren atención inmediata.\nIntenta reducir gastos superfluos.";
            } else if (status == 'Moderado') {
              statusDescription = "Buen camino, pero hay detalles por pulir.\nRevisa tus gastos recurrentes.";
            }

            return RefreshIndicator(
              onRefresh: () async => ref.read(advisorProvider.notifier).loadReport(),
              color: RusticTheme.primaryGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOP BAR: "SALVIA" + "Asesor Financiero" + Avatar Badge
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
                              "Asesor Financiero",
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

                    // HERO CARD: Verde Oscuro Gradiente con Dial de Puntaje
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
                            color: const Color(0xFF1B3828).withOpacity(0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Tag superior: "CONSEJERO FINANCIERO"
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Color(0xFFA5D6A7),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "CONSEJERO FINANCIERO",
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

                          // DIAL CIRCULAR DE PUNTAJE (Glow verde y radio)
                          SizedBox(
                            width: 170,
                            height: 170,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Línea exterior punteada o tenue
                                Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.08),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                // Anillo de progreso con glow verde
                                SizedBox(
                                  width: 140,
                                  height: 140,
                                  child: CircularProgressIndicator(
                                    value: score / 100.0,
                                    strokeWidth: 9,
                                    backgroundColor: Colors.white.withOpacity(0.09),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "$score",
                                      style: GoogleFonts.outfit(
                                        fontSize: 46,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        height: 1.0,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "/ 100 PTS",
                                      style: GoogleFonts.outfit(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white.withOpacity(0.65),
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Pill badge: "Salud: Excelente"
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.15)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.eco, color: Color(0xFF69F0AE), size: 15),
                                const SizedBox(width: 6),
                                Text(
                                  "Salud: $status",
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
                              color: Colors.white.withOpacity(0.85),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Métricas inferiores: PUNTAJE | NIVEL | RACHA
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _metricColumn("PUNTAJE", "$score/100", Colors.white),
                                Container(width: 1, height: 26, color: Colors.white.withOpacity(0.12)),
                                _metricColumn("NIVEL", "Premium", const Color(0xFF69F0AE)),
                                Container(width: 1, height: 26, color: Colors.white.withOpacity(0.12)),
                                _metricColumn("RACHA", "$streak días", const Color(0xFFFFD54F)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),

                    // SECCIÓN: "Notas del Asesor Salvia" (con badge '1 nuevo')
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
                            "1 nuevo",
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
                            color: Colors.black.withOpacity(0.02),
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
                                  Icons.error_outline,
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
                                      "Consejo financiero",
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
                            tips.isNotEmpty
                                ? tips[0]
                                : "Aún no tienes metas de ahorro activas. Crear una meta puede ayudarte a organizar mejor tus finanzas y alcanzar tus objetivos.",
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: const Color(0xFF4A5D4F),
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Botón: "Crear una meta"
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const SavingsScreen()),
                              );
                            },
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

                    // SECCIÓN: "Diagnóstico de Gastos" (con badge '30 días')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Diagnóstico de Gastos",
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
                            "30 días",
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

                    // TARJETA DE DIAGNÓSTICO DE GASTOS
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE7ECE7)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // GASTO DEL MES y número grande
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "GASTO DEL MES",
                                    style: GoogleFonts.outfit(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.4,
                                      color: const Color(0xFF758A7A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currencyFormat.format(totalSpent),
                                    style: GoogleFonts.outfit(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF132A1D),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE4EDE5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.show_chart,
                                  color: Color(0xFF2E513C),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 26),

                          // Empty State / Contenido con Icono de tarjeta centrado
                          Center(
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
                                        Icons.credit_card_outlined,
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
                                  "Aún no hay suficientes registros",
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF132A1D),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Registra tus gastos para recibir\nrecomendaciones y análisis\npersonalizados.",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12.5,
                                    color: const Color(0xFF758A7A),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Botón: "+ Registrar gasto"
                                ElevatedButton.icon(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.white,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                                      ),
                                      builder: (context) => const ExpenseForm(),
                                    );
                                  },
                                  icon: const Icon(Icons.add, size: 18),
                                  label: Text(
                                    "Registrar gasto",
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
                          const SizedBox(height: 10),
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
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

