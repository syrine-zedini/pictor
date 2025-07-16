import 'package:flutter/material.dart';
import 'frontend/login/splash-screen.dart';
import 'frontend/login/login-screen.dart';
import 'frontend/login/dashboard_screen.dart';
import 'frontend/login/mestickets.dart'; // Assure-toi que ce fichier existe
import 'frontend/login/profil.dart';
import 'frontend/login/password_reset_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resolv-IT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF6C63FF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          primary: const Color(0xFF6C63FF),
          secondary: const Color(0xFF4A45B1),
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/', // Affiche SplashScreen en premier
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/mes_tickets': (context) => const MesTicketsPage(),
        '/profile': (context) => ProfilPage(),
        '/password_reset': (context) => const PasswordResetScreen(),
      },
    );
  }
}
