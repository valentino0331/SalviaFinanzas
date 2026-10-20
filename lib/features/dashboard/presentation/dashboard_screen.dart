import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../core/providers.dart';
import '../../expenses/presentation/expense_form.dart';
import '../../expenses/domain/expense_aggregation.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  ExpensePeriod _selectedPeriod = ExpensePeriod.month;
  int _touchedSectionIndex = -1;

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Comida':
        return const Color(0xFF2E513C);
      case 'Universidad':
        return const Color(0xFFD97757);
      case 'Gym':
        return const Color(0xFF4A7C59);
      case 'Transporte':
        return const Color(0xFFC59B27);
      case 'Ocio':
        return const Color(0xFFB05353);
      default:
        return const Color(0xFF7A8B7E);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Comida':
        return Icons.restaurant;
      case 'Universidad':
        return Icons.school;
      case 'Gym':
        return Icons.fitness_center;
      case 'Transporte':
        return Icons.directions_car;
      case 'Ocio':
        return Icons.theater_comedy;
      default:
        return Icons.widgets_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final expensesState = ref.watch(expensesProvider);
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
        child: expensesState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: RusticTheme.primaryGreen),
          ),
          error: (error, _) => Center(
            child: Text("Error al cargar datos: $error"),
          ),
          data: (rawExpenses) {
            // Filtrado reactivo por periodo seleccionado
            final filteredExpenses = ExpenseAggregation.filterByPeriod(rawExpenses, _selectedPeriod);
            final double totalSpent = ExpenseAggregation.calculateTotal(filteredExpenses);
            final breakdowns = ExpenseAggregation.calculateBreakdown(filteredExpenses, precomputedTotal: totalSpent);
            final double dailyAvg = ExpenseAggregation.calculateDailyAverage(totalSpent, _selectedPeriod);
            final double income = double.tryParse((user?['monthly_income'] ?? 2000.00).toString()) ?? 2000.00;
            final double remainingBalance = income - totalSpent;

            // Datos para la gráfica interactiva fl_chart
            List<PieChartSectionData> chartSections = [];
            if (breakdowns.isEmpty) {
              chartSections = [
                PieChartSectionData(
                  color: const Color(0xFFE4EDE5),
                  value: 100,
                  title: '',
                  radius: 28,
                )
              ];
            } else {
              chartSections = breakdowns.asMap().entries.map((mapEntry) {
                final index = mapEntry.key;
                final b = mapEntry.value;
                final isTouched = index == _touchedSectionIndex;
                final radius = isTouched ? 36.0 : 28.0;

                return PieChartSectionData(
                  color: _getCategoryColor(b.category),
                  value: b.amount,
                  title: b.percentage > 12 ? '${b.percentage.toStringAsFixed(0)}%' : '',
                  radius: radius,
                  titleStyle: GoogleFonts.outfit(
                    fontSize: isTouched ? 12 : 10.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList();
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.read(expensesProvider.notifier).loadExpenses();
                ref.read(advisorProvider.notifier).loadReport();
              },
              color: RusticTheme.primaryGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOP BAR: "SALVIA" + "Inicio" + Avatar
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
                              "Inicio",
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
                    const SizedBox(height: 16),

                    // SELECTOR DE RANGO TEMPORAL (CHIPS)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5EDE6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: ExpensePeriod.values.map((period) {
                          final isSelected = _selectedPeriod == period;
                          return Expanded(
                            child: GestureDetector(
                              key: Key('period_filter_${period.name}'),
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _selectedPeriod = period;
                                  _touchedSectionIndex = -1;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF2E513C) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF2E513C).withValues(alpha: 0.25),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : [],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  period.label,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12.5,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                    color: isSelected ? Colors.white : const Color(0xFF4A6352),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // HERO CARD: Balance y Gasto Total por Periodo
                    Container(
                      width: double.infinity,
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
                            color: const Color(0xFF1B3828).withValues(alpha: 0.35),
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
                                _selectedPeriod.heroTitle,
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.4,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _selectedPeriod.badgeLabel,
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
                            currencyFormat.format(totalSpent),
                            key: const Key('total_spent_text'),
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Píldora de Promedio Diario
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.speed, color: Color(0xFF81C784), size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  "Promedio: ${currencyFormat.format(dailyAvg)} / día",
                                  style: GoogleFonts.outfit(
                                    fontSize: 11.5,
                                    color: const Color(0xFFE8F5E9),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Sub barra: Ingresos mensuales y disponible
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF69F0AE), size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Ingresos: ${currencyFormat.format(income)}",
                                      style: GoogleFonts.outfit(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "|  Libre: ${currencyFormat.format(remainingBalance)}",
                                      style: GoogleFonts.outfit(
                                        color: remainingBalance >= 0 ? const Color(0xFFC8E6C9) : const Color(0xFFFFAB91),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () => _showEditIncomeDialog(context, income),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.edit, color: Colors.white, size: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ASESOR MINI CARD
                    advisorState.when(
                      loading: () => const SizedBox(),
                      error: (err, _) => const SizedBox(),
                      data: (report) {
                        final score = report['score'] as int? ?? 100;
                        final status = report['status'] as String? ?? 'Excelente';
                        final tips = (report['tips'] as List<dynamic>?) ?? [];

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE7ECE7)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE4EDE5),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.health_and_safety_outlined, color: Color(0xFF285038), size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Salud: $status ($score/100)",
                                          style: GoogleFonts.outfit(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF132A1D),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      tips.isNotEmpty ? tips[0] : "Tus finanzas se mantienen en equilibrio.",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.outfit(
                                        fontSize: 11.5,
                                        color: const Color(0xFF6B7A6F),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // GRÁFICA REACTIVA & DISTRIBUCIÓN
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFE7ECE7)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Distribución por Categorías",
                                style: GoogleFonts.outfit(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF132A1D),
                                ),
                              ),
                              Text(
                                "${breakdowns.length} categorías",
                                style: GoogleFonts.outfit(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF7A8B7E),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              SizedBox(
                                width: 110,
                                height: 110,
                                child: PieChart(
                                  PieChartData(
                                    pieTouchData: PieTouchData(
                                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                        setState(() {
                                          if (!event.isInterestedForInteractions ||
                                              pieTouchResponse == null ||
                                              pieTouchResponse.touchedSection == null) {
                                            _touchedSectionIndex = -1;
                                            return;
                                          }
                                          _touchedSectionIndex =
                                              pieTouchResponse.touchedSection!.touchedSectionIndex;
                                        });
                                      },
                                    ),
                                    sections: chartSections,
                                    centerSpaceRadius: 22,
                                    sectionsSpace: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: breakdowns.isEmpty
                                      ? [
                                          Text(
                                            "Sin gastos en ${_selectedPeriod.badgeLabel.toLowerCase()}",
                                            style: GoogleFonts.outfit(
                                              fontSize: 12.5,
                                              fontStyle: FontStyle.italic,
                                              color: const Color(0xFF7A8B7E),
                                            ),
                                          )
                                        ]
                                      : breakdowns.take(4).map((b) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 3.0),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 10,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                    color: _getCategoryColor(b.category),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    b.category,
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 12,
                                                      color: const Color(0xFF132A1D),
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFEDF2EE),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    "${b.percentage}%",
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 10.5,
                                                      fontWeight: FontWeight.w700,
                                                      color: const Color(0xFF2E513C),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  currencyFormat.format(b.amount),
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: const Color(0xFF132A1D),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // LISTADO DE GASTOS RECIENTES
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Gastos Recientes",
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF132A1D),
                          ),
                        ),
                        if (filteredExpenses.isNotEmpty)
                          Text(
                            "${filteredExpenses.length} movimientos",
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: const Color(0xFF6B7A6F),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (filteredExpenses.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 36),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            const Icon(Icons.receipt_long_outlined, color: Color(0xFF9FB0A3), size: 44),
                            const SizedBox(height: 10),
                            Text(
                              "No tienes gastos registrados en ${_selectedPeriod.badgeLabel.toLowerCase()}.",
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: const Color(0xFF7A8B7E),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredExpenses.length,
                        itemBuilder: (context, index) {
                          final e = filteredExpenses[index];
                          final amount = double.parse(e['amount'].toString());
                          final dateStr = e['date']?.toString();
                          final date = dateStr != null ? DateTime.tryParse(dateStr) ?? DateTime.now() : DateTime.now();
                          final category = e['category'] as String;
                          final subcategory = (e['subcategory'] ?? '').toString();
                          final desc = e['description'] as String?;

                          return Dismissible(
                            key: Key(e['id'].toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: RusticTheme.alertRed,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) {
                              ref.read(expensesProvider.notifier).deleteExpense(e['id']);
                              ref.read(advisorProvider.notifier).loadReport();
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                      color: _getCategoryColor(category).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      _getCategoryIcon(category),
                                      color: _getCategoryColor(category),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          subcategory.isNotEmpty ? subcategory : category,
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: const Color(0xFF132A1D),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          desc != null && desc.isNotEmpty
                                              ? desc
                                              : DateFormat('dd MMM, hh:mm a').format(date),
                                          style: GoogleFonts.outfit(
                                            fontSize: 11.5,
                                            color: const Color(0xFF7A8B7E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "-${currencyFormat.format(amount)}",
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14.5,
                                      color: const Color(0xFFD94841),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 70),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF009668),
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
        icon: const Icon(Icons.add),
        label: Text("Registrar Gasto", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showEditIncomeDialog(BuildContext context, double currentIncome) {
    final controller = TextEditingController(text: currentIncome.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Actualizar Ingresos", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ingresa tu presupuesto o ingresos mensuales en Soles para recalcular tu diagnóstico financiero.",
                style: GoogleFonts.outfit(fontSize: 13, color: RusticTheme.lightText),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: "Nuevos Ingresos (S/.)",
                  prefixText: "S/ ",
                  prefixIcon: Icon(Icons.payments_outlined),
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
              onPressed: () {
                final val = double.tryParse(controller.text) ?? 0.0;
                if (val > 0) {
                  ref.read(authProvider.notifier).updateMonthlyIncome(val);
                  ref.read(advisorProvider.notifier).loadReport();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("¡Ingresos mensuales actualizados! 🌿")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF009668), foregroundColor: Colors.white),
              child: Text("Guardar", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
