import 'package:flutter/material.dart';
import 'package:logbook_app_070/features/auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int step = 1;

  void _next() {
    if (step < 3) {
      setState(() => step++);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                'assets/images/onboarding_$step.jpg',
                height: 220,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              step == 1
                  ? "Selamat datang di Logbook App"
                  : step == 2
                      ? "Catat aktivitasmu dengan mudah"
                      : "Pantau progresmu setiap hari",
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                child: Text(step < 3 ? "Next" : "Mulai"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
