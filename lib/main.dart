import 'package:flutter/material.dart';
import 'features/onboarding/onboarding_view.dart';
import 'features/auth/login_view.dart';
import 'features/logbook/log_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logbook App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),

      // Entry point pertama aplikasi
      home: const OnboardingView(),

      // Routing terpusat (opsional tapi rapi)
      routes: {
        '/login': (context) => const LoginView(),
        '/logbook': (context) => const LogView(),
      },
    );
  }
}