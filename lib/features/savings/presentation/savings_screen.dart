import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../core/providers.dart';
import '../domain/savings_mission_model.dart';
import 'savings_widgets.dart';

// Pantalla principal del modulo de Ahorros y Metas

class SavingsScreen extends ConsumerStatefulWidget {
  const SavingsScreen({super.key});
  @override
  ConsumerState<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends ConsumerState<SavingsScreen> {
  SavingsFilter _filter = SavingsFilter.all;

  static IconData _missionIcon(String? name) {
    const map = {
      'school': Icons.school_outlined,
      'fitness_center': Icons.fitness_center_outlined,
      'flight': Icons.flight_takeoff_outlined,
      'laptop': Icons.laptop_chromebook_outlined,
      'sports_car': Icons.directions_car_outlined,
      'home': Icons.home_outlined,
      'restaurant': Icons.restaurant_outlined,
      'card_giftcard': Icons.card_giftcard_outlined,
    };
    return map[name] ?? Icons.savings_outlined;
  }

  // Dialog: nueva meta de ahorro con selector de fecha limite
  void _showAddMissionDialog() {
    final titleCtrl  = TextEditingController();
    final targetCtrl = TextEditingController();
    String selectedIcon   = 'savings';
    DateTime? selectedDate;
    const allIcons = [
      'savings', 'school', 'fitness_center', 'flight',
      'laptop', 'sports_car', 'home', 'restaurant', 'card_giftcard',
    ];
    const iconData = {
      'savings'      : Icons.savings,
      'school'       : Icons.school,
      'fitness_center': Icons.fitness_center,
      'flight'       : Icons.flight,
      'laptop'       : Icons.laptop,
      'sports_car'   : Icons.directions_car,
      'home'         : Icons.home,
      'restaurant'   : Icons.restaurant,
      'card_giftcard': Icons.card_giftcard,
    };
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFE4EDE5), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.add_task, color: Color(0xFF285038), size: 20)),
            const SizedBox(width: 12),
            Text('Nueva Meta de Ahorro',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF132A1D))),
          ]),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              SavingsDialogHelper.label('Que deseas financiar?'),
              const SizedBox(height: 6),
              SavingsDialogHelper.textField(controller: titleCtrl, hint: 'Ej. Fondo de emergencia, Viaje a Cusco'),
              const SizedBox(height: 16),
              SavingsDialogHelper.label('Monto Objetivo (S/)'),
              const SizedBox(height: 6),
              SavingsDialogHelper.textField(controller: targetCtrl, hint: '500.00', prefix: 'S/ ', numeric: true),
              const SizedBox(height: 16),
              SavingsDialogHelper.label('Fecha limite (opcional)'),
              const SizedBox(height: 6),
              // Selector de fecha limite - NUEVO
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    builder: (c, child) => Theme(
                      data: ThemeData.light().copyWith(
                          colorScheme: const ColorScheme.light(primary: Color(0xFF009668))),
                      child: child!),
                  );
                  if (picked != null) setS(() => selectedDate = picked);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F6F3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selectedDate != null ? const Color(0xFF009668) : Colors.transparent,
                      width: 1.5)),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF526E5D)),
                    const SizedBox(width: 10),
                    Text(
                      selectedDate != null
                          ? DateFormat('d MMM yyyy', 'es').format(selectedDate!)
                          : 'Sin fecha limite',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: selectedDate != null ? const Color(0xFF132A1D) : const Color(0xFF9EABA1))),
                    if (selectedDate != null) ...[
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setS(() => selectedDate = null),
                        child: const Icon(Icons.close, size: 16, color: Color(0xFF758A7A))),
                    ],
                  ]))),
              const SizedBox(height: 18),
              SavingsDialogHelper.label('Selecciona un icono:'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10, runSpacing: 10,
                children: allIcons.map((pid) {
                  final isSel = selectedIcon == pid;
                  return GestureDetector(
                    onTap: () => setS(() => selectedIcon = pid),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFF1E3A2B) : const Color(0xFFE4EDE5),
                        shape: BoxShape.circle,
                        border: Border.all(color: isSel ? const Color(0xFF00E676) : Colors.transparent, width: 2),
                        boxShadow: isSel ? [BoxShadow(color: const Color(0xFF00E676).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))] : null),
                      child: Icon(iconData[pid] ?? Icons.savings,
                          color: isSel ? Colors.white : const Color(0xFF285038), size: 18)));
                }).toList()),
            ])),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: const Color(0xFF758A7A)))),
            ElevatedButton(
              onPressed: () async {
                final title  = titleCtrl.text.trim();
                final target = double.tryParse(targetCtrl.text) ?? 0.0;
                if (title.isEmpty || target <= 0) return;
                await HapticFeedback.mediumImpact();
                final deadlineStr = selectedDate != null
                    ? selectedDate!.toIso8601String().split('T').first
                    : null;
                // ignore: use_build_context_synchronously
                ref.read(savingsProvider.notifier).addMission(
                  title, target, deadline: deadlineStr, iconName: selectedIcon);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text('Meta creada con exito!', style: GoogleFonts.outfit()),
                    backgroundColor: const Color(0xFF009668),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF009668), foregroundColor: Colors.white, elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: Text('Crear meta', style: GoogleFonts.outfit(fontWeight: FontWeight.w700))),
          ]))));
  }

  // Dialog: aportar fondos a una meta existente
  void _showSaveFundsDialog(int missionId, String title) {
    final amountCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: Colors.white, surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Row(children: [
            Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFE4EDE5), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.savings_outlined, color: Color(0xFF285038), size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Aportar Ahorro', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF132A1D))),
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF758A7A))),
            ])),
          ]),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Accesos rapidos:', style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF526E5D))),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [10, 20, 50, 100].map((amt) => InkWell(
                onTap: () { amountCtrl.text = amt.toString(); setS(() {}); },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFE4EDE5), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFD3E0D4))),
                  child: Text('+S/ $amt', style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF285038)))))
              ).toList()),
            const SizedBox(height: 16),
            Text('O escribe el monto exacto:', style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF526E5D))),
            const SizedBox(height: 6),
            SavingsDialogHelper.textField(controller: amountCtrl, hint: '0.00', prefix: 'S/ ', numeric: true, autofocus: true),
          ]),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: const Color(0xFF758A7A)))),
            ElevatedButton(
              onPressed: () async {
                final amt = double.tryParse(amountCtrl.text) ?? 0.0;
                if (amt <= 0) return;
                await HapticFeedback.mediumImpact();
                if (ctx.mounted) Navigator.pop(ctx);
                final isCompleted = await ref.read(savingsProvider.notifier).saveFunds(missionId, amt);
                ref.read(advisorProvider.notifier).loadReport();
                if (mounted) {
                  if (isCompleted) {
                    _showSuccessDialog(title);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Aporte de S/ $amt realizado. Paso a paso!', style: GoogleFonts.outfit()),
                      backgroundColor: const Color(0xFF009668), behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF009668), foregroundColor: Colors.white, elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: Text('Aportar', style: GoogleFonts.outfit(fontWeight: FontWeight.w700))),
          ])));
  }

  // Dialog: meta completada - animacion de exito
  void _showSuccessDialog(String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white, surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 80, height: 80,
            decoration: BoxDecoration(color: const Color(0xFFFFF8E1), shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: const Color(0xFFFFB300).withValues(alpha: 0.25), blurRadius: 18, offset: const Offset(0, 6))]),
            child: const Icon(Icons.emoji_events, color: Color(0xFFFFB300), size: 46)),
          const SizedBox(height: 18),
          Text('Meta Florecida!', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF132A1D)), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Has completado tu objetivo: "$title". Ganaste +100 puntos!',
              style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF4A5D4F), height: 1.45), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF009668), foregroundColor: Colors.white, elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: Text('Excelente!', style: GoogleFonts.outfit(fontWeight: FontWeight.w700))),
        ])));
  }

  // Dialog: confirmacion de eliminacion de meta
  void _showDeleteDialog(int missionId, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white, surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Eliminar meta', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: const Color(0xFF132A1D))),
        content: Text('Estas seguro de eliminar la meta "$title"?', style: GoogleFonts.outfit(fontSize: 13.5, color: const Color(0xFF526E5D))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancelar', style: GoogleFonts.outfit(color: const Color(0xFF758A7A)))),
          ElevatedButton(
            onPressed: () {
              ref.read(savingsProvider.notifier).deleteMission(missionId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Meta eliminada', style: GoogleFonts.outfit()),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD94841), foregroundColor: Colors.white, elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('Eliminar', style: GoogleFonts.outfit(fontWeight: FontWeight.w700))),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    final savingsRaw = ref.watch(savingsProvider);
    final authState  = ref.watch(authProvider);
    final user       = authState.user;
    final userName   = (user?['name'] ?? 'Usuario').toString();
    final initials   = userName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
    final userPoints = (user?['points'] as int?) ?? 0;
    final fmt        = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ', decimalDigits: 2);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F3),
      body: SafeArea(
        child: savingsRaw.when(
          loading: () => const Center(child: CircularProgressIndicator(color: RusticTheme.primaryGreen)),
          error: (err, _) => Center(child: Text('Error al cargar metas: $err')),
          data: (rawList) {
            // Mapear a modelos tipados usando SavingsMission.fromMap
            final allMissions = rawList
                .map((m) => SavingsMission.fromMap(m as Map<String, dynamic>))
                .toList();

            // Aplicar filtro activo
            final missions = switch (_filter) {
              SavingsFilter.active    => allMissions.where((m) => !m.isCompleted).toList(),
              SavingsFilter.completed => allMissions.where((m) => m.isCompleted).toList(),
              SavingsFilter.all       => allMissions,
            };

            // Calculos agregados para el Hero Dial
            final totalSaved   = allMissions.fold(0.0, (s, m) => s + m.currentAmount);
            final totalTarget  = allMissions.fold(0.0, (s, m) => s + m.targetAmount);
            final completedCnt = allMissions.where((m) => m.isCompleted).length;
            final activeCnt    = allMissions.length - completedCnt;
            final globalPct    = totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0;
            final displayPct   = (globalPct * 100).toInt();

            String statusTitle = 'Salud: Excelente';
            String statusDesc  = 'Tus ahorros avanzan a paso firme.';
            if (allMissions.isEmpty) {
              statusTitle = 'Salud: Por Iniciar';
              statusDesc  = 'Aun no tienes metas activas. Comienza hoy.';
            } else if (displayPct >= 100) {
              statusTitle = 'Salud: Metas Cumplidas!';
              statusDesc  = 'Has completado el 100% de tus metas!';
            } else if (displayPct < 30) {
              statusTitle = 'Salud: Brote Inicial';
              statusDesc  = 'Cada sol que apartas fortalece tu futuro.';
            }

            return RefreshIndicator(
              onRefresh: () async => ref.read(savingsProvider.notifier).loadMissions(),
              color: RusticTheme.primaryGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Top bar con nombre de app e iniciales del usuario
                  SavingsTopBar(initials: initials),
                  const SizedBox(height: 18),

                  // Hero card con dial circular de progreso
                  _HeroSavingsCard(
                    displayPercent: displayPct, globalProgress: globalPct,
                    statusTitle: statusTitle, statusDescription: statusDesc,
                    totalSaved: totalSaved, totalTarget: totalTarget,
                    activeCnt: activeCnt, fmt: fmt, isEmpty: allMissions.isEmpty,
                    onCreateTap: _showAddMissionDialog),
                  const SizedBox(height: 26),

                  // Nota del asesor Salvia con tip personalizado
                  _AdvisorNoteCard(missions: allMissions, onCreateTap: _showAddMissionDialog),
                  const SizedBox(height: 26),

                  // Encabezado de seccion con filtros activos/completadas
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Tus Metas de Ahorro', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF132A1D))),
                    SavingsFilterChips(current: _filter, onChanged: (f) => setState(() => _filter = f), allCnt: allMissions.length),
                  ]),
                  const SizedBox(height: 12),

                  // Lista filtrada de metas o estado vacio
                  if (missions.isEmpty)
                    EmptyMissionsCard(filter: _filter, onCreateTap: _showAddMissionDialog)
                  else
                    ...missions.map((m) => SavingsMissionCard(
                          mission: m, fmt: fmt, iconData: _missionIcon(m.iconName),
                          onSave: () => _showSaveFundsDialog(m.id, m.title),
                          onDelete: () => _showDeleteDialog(m.id, m.title))),
                  const SizedBox(height: 26),

                  // Semillero y vivero de gamificacion
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Semillero & Vivero', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF132A1D))),
                    SavingsPill(text: '$userPoints pts'),
                  ]),
                  const SizedBox(height: 12),
                  SizedBox(height: 108, child: ListView(scrollDirection: Axis.horizontal, children: [
                    _shopItem('school', 'Bonsai Salvia', 0),
                    _shopItem('savings', 'Flor de Loto', 20),
                    _shopItem('fitness_center', 'Cactus', 40),
                    _shopItem('flight', 'Palmera', 75),
                    _shopItem('laptop', 'Bambu', 120),
                  ])),
                  const SizedBox(height: 30),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }

  // Nombres y emojis de plantas del vivero
  static const _shopEmoji = {
    'school'       : '🌲',
    'savings'      : '🌸',
    'fitness_center': '🌵',
    'flight'       : '🌴',
    'laptop'       : '🎋',
  };

  Widget _shopItem(String plantId, String name, int cost) {
    final unlocked   = ref.watch(unlockedPlantsProvider);
    final pts        = (ref.watch(authProvider).user?['points'] as int?) ?? 0;
    final isUnlocked = unlocked.contains(plantId) || cost == 0;
    final emoji      = _shopEmoji[plantId] ?? '🌱';
    return Container(
      width: 108, margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isUnlocked ? const Color(0xFFEAF2EB) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isUnlocked ? const Color(0xFF009668).withValues(alpha: 0.3) : const Color(0xFFE7ECE7), width: 1.2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 3))]),
      child: InkWell(
        onTap: isUnlocked ? null : () => _confirmUnlock(plantId, name, cost, pts),
        borderRadius: BorderRadius.circular(20),
        child: Padding(padding: const EdgeInsets.all(8),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF132A1D))),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
              decoration: BoxDecoration(
                color: isUnlocked ? const Color(0xFF009668).withValues(alpha: 0.12) : const Color(0xFFD97757).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8)),
              child: Text(isUnlocked ? 'Listo' : '$cost pts',
                  style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold,
                      color: isUnlocked ? const Color(0xFF009668) : const Color(0xFFD97757)))),
          ]))));
  }

  void _confirmUnlock(String plantId, String name, int cost, int userPoints) {
    if (userPoints < cost) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Puntos insuficientes para desbloquear $name.', style: GoogleFonts.outfit()),
        backgroundColor: const Color(0xFFD97757), behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))); return;
    }
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white, surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text('Desbloquear Planta', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: const Color(0xFF132A1D))),
      content: Text('Deseas canjear $cost puntos para desbloquear el $name?', style: GoogleFonts.outfit(fontSize: 13.5, color: const Color(0xFF526E5D))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancelar', style: GoogleFonts.outfit(color: const Color(0xFF758A7A)))),
        ElevatedButton(
          onPressed: () {
            ref.read(authProvider.notifier).updateLocalPoints(userPoints - cost);
            ref.read(unlockedPlantsProvider.notifier).unlockPlant(plantId);
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Desbloqueaste $name!', style: GoogleFonts.outfit()),
              backgroundColor: const Color(0xFF009668), behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF009668), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: Text('Desbloquear', style: GoogleFonts.outfit(fontWeight: FontWeight.w700))),
      ]));
  }
}

// Widgets privados inline para Hero y Advisor (reutilizados solo en esta pantalla)

class _HeroSavingsCard extends StatelessWidget {
  const _HeroSavingsCard({
    required this.displayPercent, required this.globalProgress,
    required this.statusTitle, required this.statusDescription,
    required this.totalSaved, required this.totalTarget,
    required this.activeCnt, required this.fmt,
    required this.isEmpty, required this.onCreateTap,
  });
  final int displayPercent;
  final double globalProgress;
  final String statusTitle, statusDescription;
  final double totalSaved, totalTarget;
  final int activeCnt;
  final NumberFormat fmt;
  final bool isEmpty;
  final VoidCallback onCreateTap;

  Widget _metric(String label, String value, Color valueColor) => Column(children: [
    Text(label, style: GoogleFonts.outfit(fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: Colors.white.withValues(alpha: 0.5))),
    const SizedBox(height: 4),
    Text(value, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: valueColor)),
  ]);

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF2E513C), Color(0xFF1B3828), Color(0xFF132A1C)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      borderRadius: BorderRadius.circular(28),
      boxShadow: [BoxShadow(color: const Color(0xFF1B3828).withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 10))]),
    child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.savings_outlined, size: 14, color: Color(0xFFA5D6A7))),
        const SizedBox(width: 8),
        Text('BOVEDA DE AHORROS', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: const Color(0xFFA5D6A7))),
      ]),
      const SizedBox(height: 24),
      SizedBox(width: 170, height: 170, child: Stack(alignment: Alignment.center, children: [
        Container(width: 160, height: 160, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1))),
        SizedBox(width: 140, height: 140,
          child: CircularProgressIndicator(value: isEmpty ? 0.0 : globalProgress, strokeWidth: 9, backgroundColor: Colors.white.withValues(alpha: 0.09), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E676)), strokeCap: StrokeCap.round)),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('$displayPercent%', style: GoogleFonts.outfit(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white, height: 1.0, letterSpacing: -1)),
          const SizedBox(height: 4),
          Text(isEmpty ? '/ META' : '/ OBJETIVO', style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.65), letterSpacing: 1.2)),
        ]),
      ])),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.15))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.eco, color: Color(0xFF69F0AE), size: 15),
          const SizedBox(width: 6),
          Text(statusTitle, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFC8E6C9))),
        ])),
      const SizedBox(height: 14),
      Text(statusDescription, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.85), height: 1.4)),
      const SizedBox(height: 22),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(18)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _metric('AHORRADO', fmt.format(totalSaved), Colors.white),
          Container(width: 1, height: 26, color: Colors.white.withValues(alpha: 0.12)),
          _metric('OBJETIVO', fmt.format(totalTarget), const Color(0xFF69F0AE)),
          Container(width: 1, height: 26, color: Colors.white.withValues(alpha: 0.12)),
          _metric('METAS', '$activeCnt activas', const Color(0xFFFFD54F)),
        ])),
    ]),
  );
}

class _AdvisorNoteCard extends StatelessWidget {
  const _AdvisorNoteCard({required this.missions, required this.onCreateTap});
  final List<SavingsMission> missions;
  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text('Notas del Asesor Salvia', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF132A1D))),
      const SavingsPill(text: 'Recomendado'),
    ]),
    const SizedBox(height: 12),
    Container(width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE7ECE7)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFE4EDE5), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.lightbulb_outline, color: Color(0xFF285038), size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Estrategia de ahorro', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF132A1D))),
            Text('Personalizado para ti', style: GoogleFonts.outfit(fontSize: 11.5, color: const Color(0xFF758A7A))),
          ])),
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF00E676), shape: BoxShape.circle)),
        ]),
        const SizedBox(height: 16),
        Text(
          missions.isNotEmpty
              ? "Regla 50/30/20: Separa tus aportes al inicio de cada mes. Con habitos diarios aceleras tu meta '${missions.first.title}'."
              : 'Aun no tienes metas de ahorro activas. Crear una meta con monto definido te ayuda a mantener el foco.',
          style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF4A5D4F), height: 1.45)),
        const SizedBox(height: 18),
        InkWell(
          onTap: onCreateTap, borderRadius: BorderRadius.circular(16),
          child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(color: const Color(0xFF2B4434), borderRadius: BorderRadius.circular(16)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Crear una meta', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: const Color(0xFF41614C), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.arrow_forward, color: Colors.white, size: 14)),
            ]))),
      ])),
  ]);
}
