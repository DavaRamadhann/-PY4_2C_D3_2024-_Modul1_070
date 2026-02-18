import 'package:flutter/material.dart';
import 'package:logbook_app_070/features/auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int step = 1;

  final List<String> _titles = [
    "Selamat Datang di Logbook App",
    "Catat Aktivitasmu dengan Mudah",
    "Pantau Progres Setiap Hari",
  ];

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

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = (index + 1) == step;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: isActive ? 14 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? Colors.indigo : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
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
              _titles[step - 1],
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Indicator (poin 2)
            _buildIndicator(),

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
