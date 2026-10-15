import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appdegastos/features/advisor/presentation/financial_advisor_screen.dart';
import 'package:appdegastos/core/providers.dart';

class MockAdvisorNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> implements AdvisorNotifier {
  MockAdvisorNotifier(Map<String, dynamic> data) : super(AsyncValue.data(data));

  @override
  Future<void> loadReport() async {}
}

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier(super.ref) {
    state = AuthState(
      user: {
        'id': 'u1',
        'name': 'Valentino Marca',
        'email': 'valentino@example.com',
        'points': 150,
        'streak': 12,
        'monthly_income': 2500.00,
      },
    );
  }

  @override
  Future<void> checkLocalSession() async {}
}

void main() {
  testWidgets('FinancialAdvisorScreen renders score dial, status and 50/30/20 section', (tester) async {
    final mockReport = {
      'score': 88,
      'status': 'Excelente',
      'monthly_income': 2500.0,
      'total_spent_30_days': 1200.0,
      'needs_spent': 800.0,
      'wants_spent': 400.0,
      'savings_allocated': 500.0,
      'needs_percentage': 32.0,
      'wants_percentage': 16.0,
      'savings_percentage': 20.0,
      'is_over_budget': false,
      'tips': ['Mantienes un equilibrio óptimo según la regla 50/30/20.'],
      'category_summary': {'Comida': 600.0, 'Transporte': 200.0, 'Ocio': 400.0},
    };

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          advisorProvider.overrideWith((ref) => MockAdvisorNotifier(mockReport)),
          authProvider.overrideWith((ref) => FakeAuthNotifier(ref)),
        ],
        child: const MaterialApp(
          home: FinancialAdvisorScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Validar Top Bar
    expect(find.text('SALVIA'), findsOneWidget);
    expect(find.text('Asesor Financiero'), findsOneWidget);

    // Validar Puntaje y Salud
    expect(find.text('88'), findsOneWidget);
    expect(find.text('/ 100 PTS'), findsOneWidget);
    expect(find.text('Salud: Excelente'), findsOneWidget);

    // Validar Sección Regla 50 / 30 / 20
    expect(find.text('Regla Financiera 50 / 30 / 20'), findsOneWidget);
    expect(find.text('Necesidades (Techo 50%)'), findsOneWidget);
    expect(find.text('Deseos y Ocio (Techo 30%)'), findsOneWidget);
    expect(find.text('Ahorro e Inversión (Piso 20%)'), findsOneWidget);

    // Validar Consejos
    expect(find.text('Notas del Asesor Salvia'), findsOneWidget);
    expect(find.textContaining('regla 50/30/20'), findsOneWidget);
  });
}
