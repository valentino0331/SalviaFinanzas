import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appdegastos/core/providers.dart';
import 'package:appdegastos/features/savings/presentation/savings_screen.dart';

class MockSavingsNotifier extends StateNotifier<AsyncValue<List<dynamic>>> implements SavingsNotifier {
  MockSavingsNotifier(List<dynamic> initialData) : super(AsyncValue.data(initialData));

  @override
  Ref get ref => throw UnimplementedError();

  @override
  Future<void> loadMissions() async {}

  @override
  Future<void> addMission(String title, double targetAmount, {String? deadline, String? iconName}) async {}

  @override
  Future<bool> saveFunds(int id, double amount) async => false;

  @override
  Future<void> deleteMission(int id) async {}
}

void main() {
  final sampleMissions = [
    {
      'id': 1,
      'title': 'Fondo de Emergencia Activo',
      'target_amount': 1000.0,
      'current_amount': 300.0,
      'icon_name': 'savings',
      'deadline': '2026-12-31',
      'is_completed': false,
      'is_shared': false,
    },
    {
      'id': 2,
      'title': 'Laptop Completada',
      'target_amount': 2500.0,
      'current_amount': 2500.0,
      'icon_name': 'laptop',
      'deadline': '2026-10-01',
      'is_completed': true,
      'is_shared': false,
    },
    {
      'id': 3,
      'title': 'Viaje Familiar Grupal',
      'target_amount': 4000.0,
      'current_amount': 1200.0,
      'icon_name': 'flight',
      'deadline': '2027-02-15',
      'is_completed': false,
      'is_shared': true,
      'collaborators': ['Valentino', 'Eduardo'],
    },
  ];

  group('SavingsScreen Presentation Tests', () {
    setUp(() {
      // Configuración de viewport amplio para pruebas de integración de widgets
    });

    testWidgets('filters missions between Todas, Activas, Hechas and Compartidas', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            savingsProvider.overrideWith((ref) => MockSavingsNotifier(sampleMissions)),
          ],
          child: const MaterialApp(
            home: SavingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('BÓVEDA DE AHORROS'), findsOneWidget);
      expect(find.text('Fondo de Emergencia Activo'), findsOneWidget);
      expect(find.text('Laptop Completada'), findsOneWidget);
      expect(find.text('Viaje Familiar Grupal'), findsOneWidget);

      // Filtro: Activas
      await tester.tap(find.text('Activas'));
      await tester.pumpAndSettle();

      expect(find.text('Fondo de Emergencia Activo'), findsOneWidget);
      expect(find.text('Viaje Familiar Grupal'), findsOneWidget);
      expect(find.text('Laptop Completada'), findsNothing);

      // Filtro: Hechas
      await tester.tap(find.text('Hechas'));
      await tester.pumpAndSettle();

      expect(find.text('Fondo de Emergencia Activo'), findsNothing);
      expect(find.text('Viaje Familiar Grupal'), findsNothing);
      expect(find.text('Laptop Completada'), findsOneWidget);

      // Filtro: Compartidas
      await tester.tap(find.text('Compartidas'));
      await tester.pumpAndSettle();

      expect(find.text('Viaje Familiar Grupal'), findsOneWidget);
      expect(find.text('Fondo de Emergencia Activo'), findsNothing);
      expect(find.text('Laptop Completada'), findsNothing);
    });

    testWidgets('renders empty state card when there are no savings missions', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            savingsProvider.overrideWith((ref) => MockSavingsNotifier([])),
          ],
          child: const MaterialApp(
            home: SavingsScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Aun no hay metas de ahorro'), findsOneWidget);
      expect(find.text('Crear meta de ahorro'), findsOneWidget);
    });

    testWidgets('renders FloatingActionButton and opens add mission dialog on tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            savingsProvider.overrideWith((ref) => MockSavingsNotifier([])),
          ],
          child: const MaterialApp(
            home: SavingsScreen(),
          ),
        ),
      );

      await tester.pump();

      final fab = find.byKey(const Key('btn_nueva_meta_ahorro'));
      expect(fab, findsOneWidget);
      expect(find.text('Nueva Meta'), findsOneWidget);

      await tester.tap(fab);
      await tester.pumpAndSettle();

      expect(find.text('Nueva Meta de Ahorro'), findsOneWidget);
    });

    testWidgets('opens AI Advisor dialog on tapping IA Asesor pill', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            savingsProvider.overrideWith((ref) => MockSavingsNotifier(sampleMissions)),
          ],
          child: const MaterialApp(
            home: SavingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final aiButton = find.text('IA Asesor');
      expect(aiButton, findsOneWidget);

      await tester.tap(aiButton);
      await tester.pumpAndSettle();

      expect(find.text('Asesor Financiero IA'), findsOneWidget);
      expect(find.text('Diagnóstico de metas y optimización de ahorro'), findsOneWidget);
    });

    testWidgets('changes sort order using SavingsSortButton menu', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            savingsProvider.overrideWith((ref) => MockSavingsNotifier(sampleMissions)),
          ],
          child: const MaterialApp(
            home: SavingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final sortBtn = find.byKey(const Key('btn_ordenar_metas'));
      expect(sortBtn, findsOneWidget);
      expect(find.text('Recientes'), findsOneWidget);

      await tester.tap(sortBtn);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mayor objetivo'));
      await tester.pumpAndSettle();

      expect(find.text('Mayor objetivo'), findsOneWidget);
    });
  });
}
