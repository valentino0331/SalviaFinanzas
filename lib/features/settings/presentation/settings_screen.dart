import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../../core/theme.dart';
import '../../../core/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final currencyFormat = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ', decimalDigits: 2);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
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
                    "Ajustes",
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF132A1D),
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "Personaliza y gestiona las preferencias de tu diario financiero.",
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: const Color(0xFF7A8B7E),
                ),
              ),
              const SizedBox(height: 20),

              // Sección 1: Perfil de Diario
              _sectionHeader("Mi Diario Financiero"),
              const SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE4E2DC)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline, color: RusticTheme.primaryGreen),
                      title: Text("Nombre del Diario", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: Text(user?['name'] ?? 'Usuario', style: GoogleFonts.outfit(fontSize: 13)),
                      trailing: const Icon(Icons.chevron_right, size: 18),
                      onTap: () => _showEditNameDialog(context, ref, user?['name'] ?? ''),
                    ),
                    const Divider(height: 1, color: Color(0xFFE4E2DC)),
                    ListTile(
                      leading: const Icon(Icons.payments_outlined, color: RusticTheme.primaryGreen),
                      title: Text("Ingresos Mensuales", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        currencyFormat.format(double.tryParse((user?['monthly_income'] ?? 2000.00).toString()) ?? 2000.00),
                        style: GoogleFonts.outfit(fontSize: 13),
                      ),
                      trailing: const Icon(Icons.chevron_right, size: 18),
                      onTap: () => _showEditIncomeDialog(context, ref, double.tryParse((user?['monthly_income'] ?? 2000.00).toString()) ?? 2000.00),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sección 2: Ayuda & Sistema
              _sectionHeader("Guía del Jardín"),
              const SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE4E2DC)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _guideRow("🎯", "Completa tus hábitos diarios para ganar puntos de racha."),
                      const SizedBox(height: 12),
                      _guideRow("🪴", "Usa tus puntos en el Vivero de Ahorros para desbloquear nuevas plantas (Cactus, Palmera, Bambú)."),
                      const SizedBox(height: 12),
                      _guideRow("🌸", "Aporta dinero a tus metas activas para ver crecer y florecer tus plantas de ahorro."),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Sección 3: Acciones Peligrosas
              _sectionHeader("Restablecer & Privacidad"),
              const SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE4E2DC)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.delete_forever_outlined, color: RusticTheme.alertRed),
                  title: Text(
                    "Reiniciar Diario (Cerrar Sesión)",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: RusticTheme.alertRed,
                    ),
                  ),
                  subtitle: Text(
                    "Borra toda la base de datos de gastos, ahorros y hábitos de este dispositivo.",
                    style: GoogleFonts.outfit(fontSize: 12, color: RusticTheme.lightText),
                  ),
                  onTap: () => _showResetDialog(context, ref),
                ),
              ),
              const SizedBox(height: 40),

              // Créditos
              Center(
                child: Column(
                  children: [
                    Text(
                      "Salvia Finanzas v1.0.0",
                      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: RusticTheme.lightText.withOpacity(0.6)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "100% Privado • Datos Locales",
                      style: GoogleFonts.outfit(fontSize: 10, color: RusticTheme.lightText.withOpacity(0.5)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: RusticTheme.primaryGreen,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _guideRow(String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.outfit(fontSize: 12.5, color: RusticTheme.darkText, height: 1.4),
          ),
        ),
      ],
    );
  }

  void _showEditNameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Editar Nombre del Diario", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: "Nombre de Usuario",
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: GoogleFonts.outfit(color: RusticTheme.lightText)),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  await ref.read(authProvider.notifier).updateUserName(name);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("¡Nombre de usuario actualizado! 🌿")),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: RusticTheme.primaryGreen, foregroundColor: Colors.white),
              child: Text("Guardar", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showEditIncomeDialog(BuildContext context, WidgetRef ref, double currentIncome) {
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
                "Configura tu presupuesto mensual en Soles para recalcular tu diagnóstico financiero.",
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
                  labelText: "Ingresos Mensuales (S/.)",
                  prefixText: "S/. ",
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
              style: ElevatedButton.styleFrom(backgroundColor: RusticTheme.primaryGreen, foregroundColor: Colors.white),
              child: Text("Guardar", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("¡Atención! 🚨", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: RusticTheme.alertRed)),
          content: Text(
            "¿Estás seguro de que deseas restablecer el diario? Esto eliminará para siempre todos tus gastos, metas y hábitos guardados localmente.",
            style: GoogleFonts.outfit(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: GoogleFonts.outfit(color: RusticTheme.lightText)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await ref.read(authProvider.notifier).logout();
              },
              style: ElevatedButton.styleFrom(backgroundColor: RusticTheme.alertRed, foregroundColor: Colors.white),
              child: Text("Restablecer Todo", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
