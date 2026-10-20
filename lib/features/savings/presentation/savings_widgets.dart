import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../domain/savings_mission_model.dart';

// Componentes reutilizables del modulo de ahorros

/// Enum para filtrar la vista de metas por estado.
enum SavingsFilter { all, active, completed }

class SavingsTopBar extends StatelessWidget {
  const SavingsTopBar({super.key, required this.initials});
  final String initials;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('SALVIA', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.8, color: const Color(0xFF526E5D))),
        const SizedBox(height: 2),
        Text('Ahorros & Metas', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF132A1D), letterSpacing: -0.3)),
      ]),
      Stack(clipBehavior: Clip.none, children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(color: const Color(0xFF355240), borderRadius: BorderRadius.circular(14)),
          alignment: Alignment.center,
          child: Text(initials, style: GoogleFonts.outfit(color: const Color(0xFFC3E7C9), fontWeight: FontWeight.bold, fontSize: 15))),
        Positioned(bottom: -2, right: -2, child: Container(width: 12, height: 12,
          decoration: BoxDecoration(color: const Color(0xFF00E676), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFF3F6F3), width: 2)))),
      ]),
    ],
  );
}

class SavingsPill extends StatelessWidget {
  const SavingsPill({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(color: const Color(0xFFE2EBE3), borderRadius: BorderRadius.circular(12)),
    child: Text(text, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF386641))));
}

class SavingsDialogHelper {
  SavingsDialogHelper._();

  static Widget label(String text) => Text(text,
      style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF526E5D)));

  static Widget textField({
    required TextEditingController controller,
    required String hint,
    String? prefix,
    bool numeric = false,
    bool autofocus = false,
  }) => TextField(
    controller: controller, autofocus: autofocus,
    keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
    inputFormatters: numeric ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))] : null,
    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF132A1D)),
    decoration: InputDecoration(
      prefixText: prefix,
      prefixStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF009668)),
      hintText: hint, hintStyle: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF9EABA1)),
      filled: true, fillColor: const Color(0xFFF3F6F3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF009668), width: 1.5))));
}

class SavingsFilterChips extends StatelessWidget {
  const SavingsFilterChips({super.key, required this.current, required this.onChanged, required this.allCnt});
  final SavingsFilter current;
  final ValueChanged<SavingsFilter> onChanged;
  final int allCnt;

  Widget _chip(String label, SavingsFilter tab, {String? badge}) {
    final sel = current == tab;
    return GestureDetector(
      onTap: () => onChanged(tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: sel ? const Color(0xFF009668) : const Color(0xFFE2EBE3), borderRadius: BorderRadius.circular(12)),
        child: Text(badge != null ? '$label $badge' : label,
            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: sel ? Colors.white : const Color(0xFF386641)))));
  }

  @override
  Widget build(BuildContext context) => Row(children: [
    _chip('Todas', SavingsFilter.all, badge: '$allCnt'),
    const SizedBox(width: 6),
    _chip('Activas', SavingsFilter.active),
    const SizedBox(width: 6),
    _chip('Hechas', SavingsFilter.completed),
  ]);
}

class EmptyMissionsCard extends StatelessWidget {
  const EmptyMissionsCard({super.key, required this.filter, required this.onCreateTap});
  final SavingsFilter filter;
  final VoidCallback onCreateTap;
  @override
  Widget build(BuildContext context) {
    final isComp = filter == SavingsFilter.completed;
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7ECE7)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(children: [
        Stack(clipBehavior: Clip.none, children: [
          Container(width: 68, height: 68,
            decoration: BoxDecoration(color: const Color(0xFFE5EDE6), borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.savings_outlined, size: 32, color: Color(0xFF285038))),
          Positioned(top: -2, right: -2,
            child: Container(padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Color(0xFF00A86B), shape: BoxShape.circle),
              child: const Icon(Icons.add, size: 12, color: Colors.white))),
        ]),
        const SizedBox(height: 16),
        Text(isComp ? 'Aun no has completado ninguna meta' : 'Aun no hay metas de ahorro',
            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF132A1D))),
        const SizedBox(height: 6),
        Text(isComp ? 'Sigue aportando a tus metas activas.' : 'Registra tus metas para cultivar tu patrimonio.',
            textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 12.5, color: const Color(0xFF758A7A), height: 1.4)),
        const SizedBox(height: 20),
        if (!isComp) ElevatedButton.icon(
          onPressed: onCreateTap,
          icon: const Icon(Icons.add, size: 18),
          label: Text('Crear meta de ahorro', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF009668), foregroundColor: Colors.white, elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
      ]));
  }
}

/// Tarjeta de meta con chips de deadline y proyeccion mensual.
class SavingsMissionCard extends StatelessWidget {
  const SavingsMissionCard({
    super.key, required this.mission, required this.fmt,
    required this.iconData, required this.onSave, required this.onDelete,
  });
  final SavingsMission mission;
  final NumberFormat fmt;
  final IconData iconData;
  final VoidCallback onSave, onDelete;

  @override
  Widget build(BuildContext context) {
    final m = mission;
    final isCompleted = m.isCompleted;
    final plant = m.plantState;
    final monthly = m.monthlySavingRequired;
    final daysLeft = m.deadlineDate?.difference(DateTime.now()).inDays;
    final isUrgent = daysLeft != null && daysLeft < 30;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isCompleted ? const Color(0xFF00C853).withValues(alpha: 0.3) : const Color(0xFFE7ECE7)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(width: 48, height: 48,
            decoration: BoxDecoration(
              color: isCompleted ? const Color(0xFFE4EDE5) : const Color(0xFFF0F5F1),
              borderRadius: BorderRadius.circular(16)),
            child: Icon(iconData,
              color: isCompleted ? const Color(0xFF009668) : const Color(0xFF285038), size: 24)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m.title, style: GoogleFonts.outfit(
              fontSize: 15.5, fontWeight: FontWeight.w800, color: const Color(0xFF132A1D),
              decoration: isCompleted ? TextDecoration.lineThrough : null)),
            const SizedBox(height: 2),
            Text('Objetivo: ${fmt.format(m.targetAmount)}',
                style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF758A7A))),
          ])),
          if (!isCompleted)
            ElevatedButton(onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009668), foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('+ Aportar', style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold)))
          else
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: const Color(0xFFE4EDE5), borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Icon(Icons.check_circle, color: Color(0xFF009668), size: 14),
                const SizedBox(width: 4),
                Text('Completada', style: GoogleFonts.outfit(color: const Color(0xFF009668), fontWeight: FontWeight.bold, fontSize: 11))])),
          const SizedBox(width: 4),
          IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFA0B0A3)), splashRadius: 18, tooltip: 'Eliminar meta'),
        ]),

        // Chips de deadline y proyeccion mensual
        if (m.deadline != null && !isCompleted) ...[  
          const SizedBox(height: 10),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isUrgent ? const Color(0xFFFFF3E0) : const Color(0xFFF0F5F1),
                borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.calendar_month_outlined, size: 12,
                    color: isUrgent ? const Color(0xFFE65100) : const Color(0xFF526E5D)),
                const SizedBox(width: 4),
                Text(
                  daysLeft != null
                      ? (daysLeft <= 0 ? 'Plazo vencido' : '$daysLeft dias restantes')
                      : 'Sin plazo',
                  style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700,
                      color: isUrgent ? const Color(0xFFE65100) : const Color(0xFF526E5D))),
              ])),
            if (monthly != null) ...[  
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.trending_up, size: 12, color: Color(0xFF009668)),
                  const SizedBox(width: 4),
                  Text('${fmt.format(monthly)}/mes',
                      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF009668))),
                ])),
            ],
          ]),
        ],

        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Text(plant.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(plant.label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700,
                color: isCompleted ? const Color(0xFF009668) : const Color(0xFF526E5D))),
          ]),
          Text('${fmt.format(m.currentAmount)} / ${fmt.format(m.targetAmount)}',
              style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF132A1D), fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: m.progressFraction, minHeight: 8,
              color: const Color(0xFF009668), backgroundColor: const Color(0xFFE4EDE5))),
      ]));
  }
}
