import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appdegastos/features/savings/presentation/savings_screen.dart';
import 'package:appdegastos/core/providers.dart';

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
  group('SavingsScreen Presentation Tests', () {
    testWidgets('filters missions between Todas, Activas and Completadas', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final sampleMissions = [
        {
          'id': 1,
          'title': 'Fondo de Emergencia Activo',
          'target_amount': 1000.0,
          'current_amount': 400.0,
          'is_completed': false,
          'icon_name': 'savings',
        },
        {
          'id': 2,
          'title': 'Laptop Completada',
          'target_amount': 3000.0,
          'current_amount': 3000.0,
          'is_completed': true,
          'icon_name': 'laptop',
        },
      ];

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

      await tester.pump();

      // Initially on 'Todas': both should be visible
      expect(find.text('Fondo de Emergencia Activo'), findsOneWidget);
      expect(find.text('Laptop Completada'), findsOneWidget);

      // Tap on 'Activas' filter chip
      await tester.tap(find.text('Activas'));
      await tester.pumpAndSettle();

      expect(find.text('Fondo de Emergencia Activo'), findsOneWidget);
      expect(find.text('Laptop Completada'), findsNothing);

      // Tap on 'Hechas' filter chip
      await tester.tap(find.text('Hechas'));
      await tester.pumpAndSettle();

      expect(find.text('Fondo de Emergencia Activo'), findsNothing);
      expect(find.text('Laptop Completada'), findsOneWidget);
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
  });
}
