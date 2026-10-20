import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_theme.dart';
import '../../expenses/application/gestor_gastos.dart';
import '../../expenses/presentation/expense_form.dart';
import 'balance_card.dart';
import 'category_chart_card.dart';
import 'health_card.dart';
import 'recent_expenses_section.dart';


final userInitialsProvider = Provider<String>((ref) => 'MR');


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(expenseSummaryProvider);
    final hasExpenses = ref.watch(gestorGastosProvider).valueOrNull?.isNotEmpty ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      // Con gastos registrados aparece el botón flotante; sin gastos, el botón
      // vive dentro de la tarjeta "Tu jardín financiero".
      floatingActionButton: hasExpenses
          ? FloatingActionButton.extended(
              onPressed: () => showExpenseForm(context),
              backgroundColor: AppColors.actionGreen,
              foregroundColor: Colors.white,
              elevation: 2,
              icon: const Icon(Icons.add_rounded),
              label: Text('Registrar Gasto',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
            )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.brandGreen,
          onRefresh: () => ref.read(gestorGastosProvider.notifier).cargar(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 90),
            children: [
              _Header(initials: ref.watch(userInitialsProvider)),
              const SizedBox(height: 18),
              BalanceCard(summary: summary),
              const SizedBox(height: 14),
              const HealthCard(),
              const SizedBox(height: 14),
              CategoryChartCard(summary: summary),
              const SizedBox(height: 24),
              const RecentExpensesSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SALVIA',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
                color: AppColors.brandGreen,
              ),
            ),
            Text(
              'Inicio',
              style: GoogleFonts.outfit(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppColors.brandGreen, shape: BoxShape.circle),
          child: Text(
            initials,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
