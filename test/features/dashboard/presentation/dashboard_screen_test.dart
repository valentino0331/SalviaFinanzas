import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appdegastos/features/dashboard/presentation/dashboard_screen.dart';
import 'package:appdegastos/core/providers.dart';

class MockExpensesNotifier extends StateNotifier<AsyncValue<List<dynamic>>> implements ExpensesNotifier {
  MockExpensesNotifier(List<dynamic> initialData) : super(AsyncValue.data(initialData));

  @override
  Future<void> loadExpenses() async {}

  @override
  Future<void> addExpense(
    double amount,
    String category,
    String subcategory,
    String description, {
    String? date,
    String? recurrence,
  }) async {}

  @override
  Future<void> deleteExpense(int id) async {}
}

class MockAdvisorNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> implements AdvisorNotifier {
  MockAdvisorNotifier()
      : super(
          const AsyncValue.data({
            'score': 85,
            'status': 'Excelente',
            'tips': ['Tus finanzas se mantienen en equilibrio.'],
          }),
        );

  @override
  Future<void> loadReport() async {}
}

void main() {
  final now = DateTime.now();
  final thisMonthDate = DateTime(now.year, now.month, 1).toIso8601String();
  final oldDate = DateTime(now.year, now.month - 1, 1).toIso8601String();

  final sampleExpenses = [
    {
      'id': 1,
      'amount': 45.0,
      'category': 'Comida',
      'subcategory': 'Almuerzo universitario',
      'description': 'Menú ejecutivo',
      'date': thisMonthDate,
    },
    {
      'id': 2,
      'amount': 20.0,
      'category': 'Transporte',
      'subcategory': 'Bus',
      'description': 'Recarga de tarjeta',
      'date': thisMonthDate,
    },
    {
      'id': 3,
      'amount': 150.0,
      'category': 'Universidad',
      'subcategory': 'Libros',
      'description': 'Libro de algoritmos',
      'date': oldDate,
    },
  ];

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        expensesProvider.overrideWith((ref) => MockExpensesNotifier(sampleExpenses)),
        advisorProvider.overrideWith((ref) => MockAdvisorNotifier()),
      ],
      child: const MaterialApp(
        home: DashboardScreen(),
      ),
    );
  }

  testWidgets('DashboardScreen renders top bar, period chips, hero card and breakdown', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Validar Top Bar
    expect(find.text('SALVIA'), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);

    // Validar Selector de Periodos (Chips)
    expect(find.text('Este Mes'), findsOneWidget);
    expect(find.text('Esta Semana'), findsOneWidget);
    expect(find.text('Histórico'), findsOneWidget);

    // Validar Hero Card
    expect(find.text('GASTO TOTAL DEL MES'), findsOneWidget);
    expect(find.byKey(const Key('total_spent_text')), findsOneWidget);

    // Validar Asesor Card
    expect(find.textContaining('Salud: Excelente (85/100)'), findsOneWidget);

    // Validar Gráfica y Categorías
    expect(find.text('Distribución por Categorías'), findsOneWidget);
    expect(find.text('Comida'), findsWidgets);
    expect(find.text('Transporte'), findsWidgets);

    // Validar Listado de Gastos
    expect(find.text('Gastos Recientes'), findsOneWidget);
    expect(find.text('Almuerzo universitario'), findsOneWidget);
  });

  testWidgets('DashboardScreen allows switching period filter to Histórico', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Inicialmente en Este Mes
    expect(find.text('GASTO TOTAL DEL MES'), findsOneWidget);

    // Tap en chip Histórico
    final historicoChip = find.byKey(const Key('period_filter_all'));
    expect(historicoChip, findsOneWidget);
    await tester.tap(historicoChip);
    await tester.pumpAndSettle();

    // Ahora muestra Gasto Total Histórico
    expect(find.text('GASTO TOTAL HISTÓRICO'), findsOneWidget);
    expect(find.text('Libros'), findsOneWidget);
  });
}
