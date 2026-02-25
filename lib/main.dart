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
        // --- PENGATURAN TEMA BARU (Midnight Indigo) ---
        brightness: Brightness.dark, 
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo, // Warna dasar
          brightness: Brightness.dark,
          primary: const Color(0xFF5C6BC0), // Indigo 400
          secondary: const Color(0xFF26A69A), // Teal 400
          surface: const Color(0xFF1E1E2C), // Background kartu/dialog gelap
          background: const Color(0xFF121212), // Background utama gelap
        ),
        
        // Styling Global untuk AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
            color: Colors.white
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),

        // Styling Global untuk TextField
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C3E), // Warna isi textfield
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF5C6BC0), width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIconColor: Colors.grey,
        ),

        // Styling Global untuk Tombol
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5C6BC0),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      
      // Routing
      home: const OnboardingView(), // Atau LoginView() jika ingin langsung tes login
      routes: {
        '/login': (context) => const LoginView(),
        '/logbook': (context) => const LogView(),
      },
    );
  }
}