import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../domain/savings_mission_model.dart';

// Componentes reutilizables del modulo de ahorros

/// Enum para filtrar la vista de metas por estado.
enum SavingsFilter { all, active, completed, shared }

class SavingsTopBar extends StatelessWidget {
  const SavingsTopBar({
    super.key,
    required this.initials,
    this.onAiAdviceTap,
  });

  final String initials;
  final VoidCallback? onAiAdviceTap;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'SALVIA',
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
            color: const Color(0xFF526E5D),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Ahorros & Metas',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF132A1D),
            letterSpacing: -0.3,
          ),
        ),
      ]),
      Row(
        children: [
          if (onAiAdviceTap != null) ...[
            InkWell(
              onTap: onAiAdviceTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF009668).withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFF009668), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'IA Asesor',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF009668),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Stack(clipBehavior: Clip.none, children: [
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
          ]),
        ],
      ),
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
    ValueChanged<String>? onChanged,
  }) => TextField(
    controller: controller,
    autofocus: autofocus,
    onChanged: onChanged,
    keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
    inputFormatters: numeric
        ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d{0,2}'))]
        : null,
    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF132A1D)),
    decoration: InputDecoration(
      prefixText: prefix,
      prefixStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF009668)),
      hintText: hint,
      hintStyle: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF9EABA1)),
      filled: true,
      fillColor: const Color(0xFFF3F6F3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF009668), width: 1.5),
      ),
    ),
  );
}

class SavingsFilterChips extends StatelessWidget {
  const SavingsFilterChips({
    super.key,
    required this.current,
    required this.onChanged,
    required this.allCnt,
  });

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
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF009668) : const Color(0xFFE2EBE3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          badge != null ? '$label $badge' : label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: sel ? Colors.white : const Color(0xFF386641),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(children: [
      _chip('Todas', SavingsFilter.all, badge: '$allCnt'),
      const SizedBox(width: 6),
      _chip('Activas', SavingsFilter.active),
      const SizedBox(width: 6),
      _chip('Hechas', SavingsFilter.completed),
      const SizedBox(width: 6),
      _chip('Compartidas', SavingsFilter.shared),
    ]),
  );
}

/// Selector desplegable para ordenar las metas de ahorro por prioridad o avance.
class SavingsSortButton extends StatelessWidget {
  const SavingsSortButton({
    super.key,
    required this.current,
    required this.onChanged,
  });

  final SavingsSortOrder current;
  final ValueChanged<SavingsSortOrder> onChanged;

  @override
  Widget build(BuildContext context) => PopupMenuButton<SavingsSortOrder>(
    key: const Key('btn_ordenar_metas'),
    initialValue: current,
    onSelected: onChanged,
    color: Colors.white,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    itemBuilder: (ctx) => SavingsSortOrder.values.map((order) {
      final isSel = order == current;
      return PopupMenuItem<SavingsSortOrder>(
        value: order,
        child: Row(
          children: [
            Icon(
              isSel ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 16,
              color: isSel ? const Color(0xFF009668) : const Color(0xFF9EABA1),
            ),
            const SizedBox(width: 8),
            Text(
              order.label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                color: isSel ? const Color(0xFF132A1D) : const Color(0xFF526E5D),
              ),
            ),
          ],
        ),
      );
    }).toList(),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD3E0D4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sort_rounded, size: 14, color: Color(0xFF285038)),
          const SizedBox(width: 4),
          Text(
            current.label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF285038),
            ),
          ),
        ],
      ),
    ),
  );
}

class EmptyMissionsCard extends StatelessWidget {
  const EmptyMissionsCard({super.key, required this.filter, required this.onCreateTap});
  final SavingsFilter filter;
  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    final isComp = filter == SavingsFilter.completed;
    final isShared = filter == SavingsFilter.shared;

    String title = 'Aun no hay metas de ahorro';
    String desc = 'Crea una meta con monto y fecha limite para comenzar.';
    if (isComp) {
      title = 'Sin metas completadas';
      desc = 'Cuando alcances el 100% de una meta aparecera aqui con su flor dorada.';
    } else if (isShared) {
      title = 'Sin metas compartidas';
      desc = 'Puedes crear una meta grupal (en pareja o familia) e invitar a colaboradores.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7ECE7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: [
        Stack(clipBehavior: Clip.none, children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFE5EDE6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isShared ? Icons.group_outlined : Icons.savings_outlined,
              size: 32,
              color: const Color(0xFF285038),
            ),
          ),
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Color(0xFF009668), shape: BoxShape.circle),
              child: const Icon(Icons.add, size: 14, color: Colors.white),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        Text(
          title,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF132A1D)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          desc,
          style: GoogleFonts.outfit(fontSize: 12.5, color: const Color(0xFF526E5D), height: 1.4),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onCreateTap,
          icon: const Icon(Icons.add_circle_outline, size: 18),
          label: Text('Crear meta de ahorro', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF009668),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ]),
    );
  }
}

/// Tarjeta de meta con chips de deadline, proyección y soporte colaborativo.
class SavingsMissionCard extends StatelessWidget {
  const SavingsMissionCard({
    super.key,
    required this.mission,
    required this.fmt,
    required this.iconData,
    required this.onSave,
    required this.onDelete,
    this.onViewAdvice,
  });

  final SavingsMission mission;
  final NumberFormat fmt;
  final IconData iconData;
  final VoidCallback onSave, onDelete;
  final VoidCallback? onViewAdvice;

  @override
  Widget build(BuildContext context) {
    final m = mission;
    final isCompleted = m.isCompleted;
    final plant = m.plantState;
    final monthly = m.monthlySavingRequired;
    final daily = m.dailySavingSuggested;
    final daysLeft = m.daysRemaining;
    final isUrgent = daysLeft != null && daysLeft < 30 && !isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF00C853).withValues(alpha: 0.3)
              : (m.isShared ? const Color(0xFF009668).withValues(alpha: 0.25) : const Color(0xFFE7ECE7)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCompleted ? const Color(0xFFE4EDE5) : const Color(0xFFF0F5F1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              iconData,
              color: isCompleted ? const Color(0xFF009668) : const Color(0xFF285038),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      m.title,
                      style: GoogleFonts.outfit(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF132A1D),
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (m.isShared) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people_alt, size: 10, color: Color(0xFF0369A1)),
                          const SizedBox(width: 2),
                          Text(
                            'Compartida',
                            style: GoogleFonts.outfit(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0369A1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Objetivo: ${fmt.format(m.targetAmount)}',
                style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF758A7A)),
              ),
            ]),
          ),
          if (!isCompleted)
            ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009668),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('+ Aportar', style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold)),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: const Color(0xFFE4EDE5), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF009668), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Completada',
                    style: GoogleFonts.outfit(color: const Color(0xFF009668), fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFA0B0A3)),
            splashRadius: 18,
            tooltip: 'Eliminar meta',
          ),
        ]),

        // Chips de deadline y proyección mensual/diaria
        if (m.deadline != null && !isCompleted) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isUrgent ? const Color(0xFFFFF3E0) : const Color(0xFFF0F5F1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 12,
                    color: isUrgent ? const Color(0xFFE65100) : const Color(0xFF526E5D),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    daysLeft != null
                        ? (daysLeft <= 0 ? 'Plazo vencido' : '$daysLeft días restantes')
                        : 'Sin plazo',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isUrgent ? const Color(0xFFE65100) : const Color(0xFF526E5D),
                    ),
                  ),
                ]),
              ),
              if (monthly != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.trending_up, size: 12, color: Color(0xFF009668)),
                    const SizedBox(width: 4),
                    Text(
                      '${fmt.format(monthly)}/mes',
                      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF009668)),
                    ),
                  ]),
                ),
              if (daily != null && daysLeft != null && daysLeft > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.bolt, size: 12, color: Color(0xFF0284C7)),
                    const SizedBox(width: 4),
                    Text(
                      '${fmt.format(daily)}/día',
                      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF0284C7)),
                    ),
                  ]),
                ),
            ],
          ),
        ],

        // Lista de colaboradores si es meta compartida
        if (m.isShared && m.collaborators.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Colaboradores: ',
                style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF758A7A)),
              ),
              Expanded(
                child: Text(
                  m.collaborators.join(', '),
                  style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF355240)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Text(plant.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              plant.label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isCompleted ? const Color(0xFF009668) : const Color(0xFF526E5D),
              ),
            ),
          ]),
          Text(
            '${fmt.format(m.currentAmount)} / ${fmt.format(m.targetAmount)}',
            style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF132A1D), fontWeight: FontWeight.bold),
          ),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: m.progressFraction,
            minHeight: 8,
            color: const Color(0xFF009668),
            backgroundColor: const Color(0xFFE4EDE5),
          ),
        ),

        // Recomendación rápida inteligente
        if (!isCompleted) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE4EDE5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.tips_and_updates_outlined, size: 14, color: Color(0xFF285038)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    m.smartAdvice,
                    style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF4A5D4F), height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ]),
    );
  }
}
