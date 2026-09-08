import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Animación de escala para el logotipo de hoja (de pequeño a tamaño normal con rebote suave)
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    );

    // Animación de opacidad para el logotipo
    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    // Animación de opacidad para los textos
    _textOpacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 0.9, curve: Curves.easeIn),
    );

    // Desplazamiento sutil hacia arriba para los textos
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic),
    ));

    // Iniciar la animación y redirigir
    _controller.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 400));
      widget.onFinish();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RusticTheme.background,
      body: Stack(
        children: [
          // Fondo decorativo con círculos muy suaves y orgánicos
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: RusticTheme.primaryGreen.withOpacity(0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: RusticTheme.terracotta.withOpacity(0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          // Contenido principal centrado
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logotipo de Salvia Animado
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: RusticTheme.primaryGreen.withOpacity(0.06),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFE4E2DC), width: 1.5),
                      ),
                      child: const Icon(
                        Icons.spa,
                        size: 72,
                        color: RusticTheme.primaryGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Títulos Animados
                SlideTransition(
                  position: _textSlideAnimation,
                  child: FadeTransition(
                    opacity: _textOpacityAnimation,
                    child: Column(
                      children: [
                        Text(
                          "Salvia Finanzas",
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: RusticTheme.primaryGreen,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tu diario de finanzas rústico y autónomo",
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: RusticTheme.lightText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Indicador de privacidad al pie
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _textOpacityAnimation,
              child: Column(
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(RusticTheme.primaryGreen),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "100% OFFLINE • PRIVADO & SEGURO",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: RusticTheme.lightText.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
