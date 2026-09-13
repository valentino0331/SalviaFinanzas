import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/providers.dart';
import '../../../core/theme.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _handleStartOnboarding() async {
    final name = _nameController.text.trim();
    final incomeStr = _incomeController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, introduce tu nombre para tu diario 🌿")),
      );
      return;
    }
    final income = double.tryParse(incomeStr);
    if (income == null || income <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, introduce un monto de ingresos válido superior a S/. 0 🌿")),
      );
      return;
    }
    
    // Guardar estado de onboarding completado localmente
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    final cleanId = "offline_user_${name.toLowerCase().replaceAll(' ', '_')}";
    final email = "${name.toLowerCase().replaceAll(' ', '')}@salvia.local";

    await ref.read(authProvider.notifier).login(
      cleanId,
      email,
      name,
      avatarUrl: "https://api.dicebear.com/7.x/bottts/png?seed=$name",
      monthlyIncome: income,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icono rústico / logotipo circular suave
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: RusticTheme.primaryGreen.withOpacity(0.09),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.spa_outlined,
                    size: 64,
                    color: RusticTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Títulos
                Text(
                  "Salvia Finanzas",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: RusticTheme.primaryGreen,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Tu diario rústico de finanzas autónomo y 100% offline.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 36),

                // Card de Onboarding rústica
                Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE4E2DC)),
                    boxShadow: [
                      BoxShadow(
                        color: RusticTheme.primaryGreen.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Comienza tu Jardín Financiero",
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: RusticTheme.darkText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          "Tus datos se guardarán de forma segura en este dispositivo.",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: RusticTheme.lightText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Campo de Nombre
                      Text(
                        "¿Cómo te llamas?",
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: RusticTheme.darkText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: "Tu nombre o apodo",
                          prefixIcon: Icon(Icons.person_outline, size: 20),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Campo de Presupuesto Inicial
                      Text(
                        "¿Cuánto dinero ingresas al mes en Soles (S/.)?",
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: RusticTheme.darkText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _incomeController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        decoration: const InputDecoration(
                          hintText: "Ej. 2000",
                          prefixText: "S/. ",
                          prefixIcon: Icon(Icons.payments_outlined, size: 20),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Botón para comenzar
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : _handleStartOnboarding,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: RusticTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: authState.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  "Iniciar mi Diario Financiero 🌿",
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (authState.error != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    "Error: ${authState.error}",
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 48),
                Text(
                  "Autónomo • Privado • Seguro",
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: RusticTheme.lightText.withOpacity(0.6),
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
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
