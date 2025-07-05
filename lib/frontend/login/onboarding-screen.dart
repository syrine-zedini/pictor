import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../login/login-screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Variables pour optimiser les performances
  late final ThemeData _theme;
  late final double _screenHeight;
  bool _assetsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pré-charger les données nécessaires
    _theme = Theme.of(context);
    _screenHeight = MediaQuery.of(context).size.height;

    // Simuler le chargement des assets
    Future.delayed(Duration.zero, () {
      precacheImage(const AssetImage('assets/images/welcome_illustration.jpg'), context);
      setState(() => _assetsLoaded = true);
    });
  }

  void _navigateToLogin() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _assetsLoaded ? _buildContent() : _buildLoader(),
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration optimisée
          Image.asset(
            'assets/images/welcome_illustration.jpg',
            height: _screenHeight * 0.4,
            filterQuality: FilterQuality.medium, // Meilleur compromis qualité/performance
            cacheWidth: (MediaQuery.of(context).size.width * 0.8).toInt(), // Optimisation mémoire
          )
              .animate()
              .fadeIn(duration: 600.ms, curve: Curves.easeOutCubic)
              .slideY(begin: 0.1, end: 0, curve: Curves.easeOutBack),

          const SizedBox(height: 32),

          // Titre avec animation simplifiée
          Text(
            'Resolv-IT — You click it, we fix it!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 28, // Légèrement réduit pour mieux s'adapter
              fontWeight: FontWeight.bold,
              color: _theme.primaryColor,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

          const SizedBox(height: 16),

          // Sous-titre
          Text(
            'Let\'s fix it together — sign in to begin.',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 500.ms),

          const SizedBox(height: 48),

          // Bouton optimisé
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _navigateToLogin,
              style: ElevatedButton.styleFrom(
                elevation: 2, // Réduit pour un look plus moderne
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Border radius plus subtil
                ),
                backgroundColor: _theme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'Sign In',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, // Semi-bold au lieu de bold
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 600.ms)
              .slideY(begin: 0.2, end: 0, duration: 500.ms),
        ],
      ),
    );
  }
}