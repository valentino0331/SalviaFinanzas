import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_theme.dart';
import '../../../core/formatters.dart';
import '../../expenses/application/gestor_gastos.dart';
import '../../expenses/application/gestor_ingresos.dart';
import '../../expenses/domain/expense_validators.dart';

Future<void> showEditIncomeSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (_) => const EditIncomeSheet(),
  );
}

class EditIncomeSheet extends ConsumerStatefulWidget {
  const EditIncomeSheet({super.key});

  @override
  ConsumerState<EditIncomeSheet> createState() => _EditIncomeSheetState();
}

class _EditIncomeSheetState extends ConsumerState<EditIncomeSheet> {
  late final TextEditingController _controller;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final actual = ref.read(monthlyIncomeProvider);
    _controller = TextEditingController(
      text: actual.toStringAsFixed(actual % 1 == 0 ? 0 : 2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? get _nuevoMonto {
    if (ExpenseValidators.validateAmount(_controller.text) != null) return null;
    return ExpenseValidators.parseAmount(_controller.text);
  }

  Future<void> _guardar() async {
    if (_saving) return;
    final error = ExpenseValidators.validateAmount(_controller.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);

    final monto = ExpenseValidators.parseAmount(_controller.text);
    final fallo = await ref.read(monthlyIncomeProvider.notifier).actualizar(monto);
    if (!mounted) return;

    if (fallo != null) {
      setState(() {
        _saving = false;
        _error = fallo;
      });
      return;
    }
    HapticFeedback.lightImpact();
    navigator.pop();
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Ingresos actualizados a S/ ${formatMoney(monto)} 🌿'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalGastado = ref.watch(expenseSummaryProvider).total;
    final nuevo = _nuevoMonto;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        20,
        22,
        22 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Editar ingresos',
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Tus ingresos del mes se usan para calcular cuánto te queda disponible.',
            style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _guardar(),
            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              labelText: 'Ingresos mensuales',
              prefixText: 'S/ ',
              errorText: _error,
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (nuevo != null)
            Text(
              'Disponible con este ingreso: S/ ${formatMoney(nuevo - totalGastado)}',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: nuevo - totalGastado < 0
                    ? AppColors.danger
                    : AppColors.brandGreen,
              ),
            ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: _saving ? null : _guardar,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.actionGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Guardar',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
