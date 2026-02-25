import 'dart:ui'; // Diperlukan untuk ImageFilter (Blur effect)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../logbook/log_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    
    // Simulasi delay agar terasa seperti loading asli
    await Future.delayed(const Duration(seconds: 1));

    if (_usernameController.text == "admin" && _passwordController.text == "123") {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _usernameController.text);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LogView()),
      );
    } else {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text("Username atau Password salah!")),
            ],
          ),
          backgroundColor: Colors.redAccent.shade200,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Gradient (Full Screen)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F2027), // Deep Dark Blue
                  Color(0xFF203A43), // Mid Dark
                  Color(0xFF2C5364), // Lighter Blue/Teal hint
                ],
              ),
            ),
          ),

          // 2. Background Ornaments (Lingkaran samar untuk estetika)
          // Lingkaran Ungu (Kiri Atas)
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purpleAccent.withOpacity(0.4),
                // PERBAIKAN: Gunakan boxShadow untuk efek blur/glow
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.4),
                    blurRadius: 100, // Semakin besar, semakin samar
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          
          // Lingkaran Biru (Kanan Bawah)
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withOpacity(0.4),
                // PERBAIKAN: Gunakan boxShadow untuk efek blur/glow
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.4),
                    blurRadius: 100, // Semakin besar, semakin samar
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          // 3. Main Content (Glassmorphism Card)
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo & Header Text
                  const Icon(
                    Icons.auto_stories_rounded, // Ikon Buku/Jurnal
                    size: 80,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Daily Journal",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      fontFamily: 'Serif', // Memberikan kesan elegan seperti buku
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tulis cerita, simpan kenangan.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // GLASS CARD FORM
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Efek Blur Kaca
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1), // Transparan
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Input Username
                            TextField(
                              controller: _usernameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Username",
                                labelStyle: const TextStyle(color: Colors.white70),
                                prefixIcon: const Icon(Icons.person_outline, color: Colors.white70),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(color: Colors.white),
                                ),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.2),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Input Password
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Password",
                                labelStyle: const TextStyle(color: Colors.white70),
                                prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(color: Colors.white),
                                ),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.2),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white, // Tombol Putih Kontras
                                  foregroundColor: Colors.indigo.shade900, // Text Gelap
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "MULAI MENULIS",
                                            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_forward_rounded),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Lupa Password?",
                      style: TextStyle(color: Colors.white.withOpacity(0.6)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}