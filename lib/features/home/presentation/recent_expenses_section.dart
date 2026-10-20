import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_theme.dart';
import '../../../core/formatters.dart';
import '../../expenses/application/gestor_gastos.dart';
import '../../expenses/domain/expense.dart';
import '../../expenses/presentation/expense_form.dart';

class RecentExpensesSection extends ConsumerStatefulWidget {
  const RecentExpensesSection({super.key});

  @override
  ConsumerState<RecentExpensesSection> createState() => _RecentExpensesSectionState();
}

class _RecentExpensesSectionState extends ConsumerState<RecentExpensesSection> {
  static const int _recentLimit = 5;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(gestorGastosProvider);
    final count = expensesAsync.valueOrNull?.length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gastos Recientes',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            GestureDetector(
              onTap: count > _recentLimit
                  ? () => setState(() => _showAll = !_showAll)
                  : null,
              child: Text(
                _showAll ? 'Ver menos ↑' : 'Ver todo →',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandGreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        expensesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator(color: AppColors.brandGreen)),
          ),
          error: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: TextButton(
                onPressed: () => ref.read(gestorGastosProvider.notifier).cargar(),
                child: const Text('No se pudieron cargar los gastos. Reintentar'),
              ),
            ),
          ),
          data: (expenses) {
            if (expenses.isEmpty) return const _EmptyExpensesCard();
            final visible = _showAll ? expenses : expenses.take(_recentLimit).toList();
            return Column(
              children: [for (final e in visible) _ExpenseTile(expense: e)],
            );
          },
        ),
      ],
    );
  }
}

class _EmptyExpensesCard extends StatelessWidget {
  const _EmptyExpensesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(color: AppColors.ringTrack, shape: BoxShape.circle),
            child: const Icon(Icons.eco_rounded, color: AppColors.actionGreen, size: 28),
          ),
          const SizedBox(height: 14),
          Text('Tu jardín financiero',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            'está libre de gastos. Registra tu\nprimer gasto para empezar.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 12.5, height: 1.35, color: AppColors.textMuted),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () => showExpenseForm(context),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text('Registrar Gasto',
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.actionGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
              shape: const StadiumBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseTile extends ConsumerWidget {
  const _ExpenseTile({required this.expense});

  final Expense expense;

  Future<bool?> _confirmarEliminacion(BuildContext context) {
    final nombre = expense.detail.isNotEmpty ? expense.detail : expense.category.label;
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '¿Eliminar este gasto?',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        content: Text(
          '$nombre · S/ ${formatMoney(expense.amount)}',
          style: GoogleFonts.outfit(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Eliminar',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w800,
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminar(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(gestorGastosProvider.notifier).eliminarGasto(expense.id);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gasto eliminado · S/ ${formatMoney(expense.amount)} devueltos a tu balance'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar el gasto. Intenta de nuevo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = expense.category;
    final title = expense.detail.isNotEmpty ? expense.detail : category.label;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: ValueKey('gasto-${expense.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => _confirmarEliminacion(context),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 22),
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
        ),
        onDismissed: (_) => _eliminar(context, ref),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(category.icon, color: category.color, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${category.label} · ${formatExpenseDate(expense.date)}',
                      style: GoogleFonts.outfit(fontSize: 11.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Text(
                '-S/ ${formatMoney(expense.amount)}',
                style: GoogleFonts.outfit(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
