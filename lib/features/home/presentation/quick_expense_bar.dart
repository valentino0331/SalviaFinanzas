import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_theme.dart';
import '../../../core/formatters.dart';
import '../../expenses/application/gestor_gastos.dart';
import '../../expenses/application/gestor_rapidos.dart';
import '../../expenses/domain/quick_expense.dart';

Future<bool> confirmarRegistroRapido(
  BuildContext context, {
  required String titulo,
  required String detalle,
  required String accion,
  required Color colorAccion,
}) async {
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        titulo,
        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      content: Text(
        detalle,
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
            accion,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w800,
              color: colorAccion,
            ),
          ),
        ),
      ],
    ),
  );
  return confirmado ?? false;
}

class QuickExpenseBar extends ConsumerStatefulWidget {
  const QuickExpenseBar({super.key});

  @override
  ConsumerState<QuickExpenseBar> createState() => _QuickExpenseBarState();
}

class _QuickExpenseBarState extends ConsumerState<QuickExpenseBar> {
  bool _busy = false;

  Future<void> _registrar(QuickExpense item) async {
    if (_busy) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);

    try {
      await ref.read(gestorGastosProvider.notifier).agregarGasto(
            monto: item.amount,
            categoria: item.category,
            detalle: item.label,
          );
      HapticFeedback.lightImpact();
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('${item.label} · S/ ${formatMoney(item.amount)} registrado 🌿'),
          backgroundColor: AppColors.brandGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo registrar el gasto. Intenta de nuevo.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _quitar(QuickExpense item) async {
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(quickExpensesProvider.notifier);
    final confirmado = await confirmarRegistroRapido(
      context,
      titulo: '¿Quitar de registro rápido?',
      detalle: '${item.label} · S/ ${formatMoney(item.amount)}',
      accion: 'Quitar',
      colorAccion: AppColors.danger,
    );
    if (!confirmado) return;
    await notifier.quitar(item);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('${item.label} quitado de registro rápido'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(quickExpensesProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Registro rápido',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Toca para registrar · mantén presionado para quitar',
              style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
          const SizedBox(height: 10),
          if (items.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app_rounded, size: 20, color: AppColors.textMuted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Aún no tienes gastos rápidos. Mantén presionado un gasto de la lista para añadirlo aquí.',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        height: 1.3,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _QuickChip(
                        item: item,
                        enabled: !_busy,
                        onTap: () => _registrar(item),
                        onLongPress: () => _quitar(item),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.item,
    required this.enabled,
    required this.onTap,
    required this.onLongPress,
  });

  final QuickExpense item;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final color = item.category.color;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled ? onTap : null,
          onLongPress: enabled ? onLongPress : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.category.icon, color: color, size: 17),
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'S/ ${formatMoney(item.amount)}',
                        style: GoogleFonts.outfit(fontSize: 11.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
