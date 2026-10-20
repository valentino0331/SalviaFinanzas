import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_theme.dart';
import '../application/gestor_gastos.dart';
import '../domain/expense_category.dart';
import '../domain/expense_validators.dart';


Future<void> showExpenseForm(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const ExpenseForm(),
  );
}


class ExpenseForm extends ConsumerStatefulWidget {
  const ExpenseForm({super.key});

  @override
  ConsumerState<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends ConsumerState<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _detailCtrl = TextEditingController();

  ExpenseCategory? _category;
  String? _categoryError;
  bool _saving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _detailCtrl.dispose();
    super.dispose();
  }

  /// [TAREA 7 · S8–S9] Conexión del formulario con el Gestor de Gastos.
  /// Pasos 4–6 y 14 del diagrama: "Confirmar Registro" → valida →
  /// agregarGasto(monto, categoria, detalle) → cierra y muestra mensaje.
  Future<void> _confirmarRegistro() async {
    // [TAREA 8 · S9–S10] Paso 5: "Valida que los datos sean correctos".
    final camposOk = _formKey.currentState!.validate();
    final categoriaError = ExpenseValidators.validateCategory(_category);
    setState(() => _categoryError = categoriaError);
    if (!camposOk || categoriaError != null) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);

    try {
      await ref.read(gestorGastosProvider.notifier).agregarGasto(
            monto: ExpenseValidators.parseAmount(_amountCtrl.text),
            categoria: _category!,
            detalle: _detailCtrl.text,
          );
      HapticFeedback.mediumImpact();
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Gasto registrado con éxito 🌿'),
          backgroundColor: AppColors.brandGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ExpenseValidationException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar el gasto. Intenta de nuevo.'),
        ),
      );
    }
  }

  InputDecoration _decoration({required String label, String? hint, String? prefix}) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefix,
      filled: true,
      fillColor: AppColors.background.withValues(alpha: 0.55),
      enabledBorder: border(AppColors.border),
      focusedBorder: border(AppColors.brandGreen, 1.6),
      errorBorder: border(AppColors.danger),
      focusedErrorBorder: border(AppColors.danger, 1.6),
      labelStyle: GoogleFonts.outfit(color: AppColors.textMuted),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 22,
        right: 22,
        top: 14,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Registrar gasto',
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                'Anótalo en segundos y cuida tu jardín financiero.',
                style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),

              // MONTO
              TextFormField(
                controller: _amountCtrl,
                autofocus: true,
                enabled: !_saving,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d{0,5}([.,]\d{0,2})?')),
                ],
                style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w800),
                decoration: _decoration(label: 'Monto', hint: '0.00', prefix: 'S/ '),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: ExpenseValidators.validateAmount,
              ),
              const SizedBox(height: 18),

              // CATEGORÍA
              Text(
                'Categoría',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ExpenseCategory.values.map((cat) {
                  final selected = _category == cat;
                  return ChoiceChip(
                    avatar: Icon(
                      cat.icon,
                      size: 18,
                      color: selected ? Colors.white : cat.color,
                    ),
                    label: Text(cat.label),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: cat.color,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: selected ? cat.color : AppColors.border),
                    labelStyle: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.textDark,
                    ),
                    onSelected: _saving
                        ? null
                        : (_) => setState(() {
                              _category = cat;
                              _categoryError = null;
                            }),
                  );
                }).toList(),
              ),
              if (_categoryError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    _categoryError!,
                    style: GoogleFonts.outfit(fontSize: 12, color: AppColors.danger),
                  ),
                ),
              const SizedBox(height: 18),

              // DETALLE / NOTAS
              TextFormField(
                controller: _detailCtrl,
                enabled: !_saving,
                maxLength: ExpenseValidators.maxDetailLength,
                textCapitalization: TextCapitalization.sentences,
                decoration: _decoration(
                  label: 'Notas (opcional)',
                  hint: 'Ej. Menú del día, pasaje a la UTP',
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (v) => ExpenseValidators.validateDetail(v, category: _category),
              ),
              const SizedBox(height: 8),

              // CONFIRMAR
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saving ? null : _confirmarRegistro,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.actionGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          'Confirmar Registro',
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
