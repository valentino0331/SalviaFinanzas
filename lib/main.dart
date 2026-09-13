import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/providers.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'features/home/presentation/home_shell.dart';
import 'features/auth/presentation/splash_screen.dart';

void main() {
  // Aseguramos la inicialización de Flutter antes de SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _hasFinishedSplash = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Salvia Finanzas',
      theme: RusticTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: !_hasFinishedSplash
          ? SplashScreen(
              onFinish: () {
                setState(() {
                  _hasFinishedSplash = true;
                });
              },
            )
          : authState.isLoading
              ? const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: RusticTheme.primaryGreen),
                  ),
                )
              : authState.user != null
                  ? const HomeShell()
                  : const AuthGate(),
    );
  }
}
