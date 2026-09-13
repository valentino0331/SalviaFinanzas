import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appdegastos/features/savings/presentation/savings_screen.dart';
import 'package:appdegastos/core/providers.dart';

class TestSavingsNotifier extends StateNotifier<AsyncValue<List<dynamic>>> implements SavingsNotifier {
  TestSavingsNotifier()
      : super(
          const AsyncValue.data([
            {
              'id': 1,
              'title': 'Fondo de Emergencia',
              'target_amount': 1000.0,
              'current_amount': 500.0,
              'is_completed': false,
              'icon_name': 'savings',
            }
          ]),
        );

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
  testWidgets('SavingsScreen renders top bar, hero card and mission list', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          savingsProvider.overrideWith((ref) => TestSavingsNotifier()),
        ],
        child: const MaterialApp(
          home: SavingsScreen(),
        ),
      ),
    );

    await tester.pump();

    // Top Bar
    expect(find.text('SALVIA'), findsOneWidget);
    expect(find.text('Ahorros & Metas'), findsOneWidget);

    // Hero Dial Card
    expect(find.text('BÓVEDA DE AHORROS'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);

    // Mission Card
    expect(find.text('Fondo de Emergencia'), findsOneWidget);
    expect(find.text('+ Aportar'), findsOneWidget);
  });
}
