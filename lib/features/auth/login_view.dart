import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logbook_app_070/features/auth/login_controller.dart';
import 'package:logbook_app_070/features/logbook/counter_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController _controller = LoginController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _obscurePassword = true;
  int _failedAttempts = 0;
  bool _isLocked = false;

  void _handleLogin() {
    if (_isLocked) return;

    final user = _userController.text.trim();
    final pass = _passController.text.trim();

    // Validasi kosong
    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username dan Password tidak boleh kosong")),
      );
      return;
    }

    final isSuccess = _controller.login(user, pass);

    if (isSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CounterView(username: user),
        ),
      );
    } else {
      _failedAttempts++;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login gagal! Username / Password salah")),
      );

      if (_failedAttempts >= 3) {
        setState(() => _isLocked = true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Terlalu banyak percobaan. Tunggu 10 detik.")),
        );

        Timer(const Duration(seconds: 10), () {
          setState(() {
            _failedAttempts = 0;
            _isLocked = false;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Gatekeeper")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _passController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isLocked ? null : _handleLogin,
              child: Text(_isLocked ? "Terkunci (10 detik)" : "Masuk"),
            ),
          ],
        ),
      ),
    );
  }
}
