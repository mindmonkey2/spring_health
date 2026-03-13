import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/firebase_auth_service.dart';
import '../auth/login_screen.dart';
import '../main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for splash animation to complete
    await Future.delayed(const Duration(milliseconds: 3500));

    if (!mounted) return;

    // Check if user is logged in
    final user = _authService.currentUser;

    // Determine navigation destination
    final destination = user != null ? const MainScreen() : const LoginScreen();

    // Navigate with fade animation
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Stack(
        children: [
          // Background Gradient Glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.2),
                  radius: 1.5,
                  colors: [
                    Color(0xFF1A2E05), // Very dark lime glow
                    AppColors.backgroundBlack,
                  ],
                ),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.neonLime.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonLime.withValues(alpha: 0.2),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    size: 64,
                    color: AppColors.neonLime,
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                  duration: 1500.ms,
                  curve: Curves.easeInOut,
                )
                .then()
                .shimmer(
                  duration: 1200.ms,
                  color: Colors.white.withValues(alpha: 0.5),
                ),

                const SizedBox(height: 32),

                Text(
                  'SPRING HEALTH',
                  style: AppTextStyles.heading1.copyWith(
                    letterSpacing: 4,
                    color: AppColors.white,
                  ),
                )
                .animate()
                .fadeIn(duration: 800.ms, delay: 300.ms)
                .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 8),

                Text(
                  'UNLEASH YOUR POTENTIAL',
                  style: AppTextStyles.caption.copyWith(
                    letterSpacing: 2,
                    color: AppColors.neonTeal,
                  ),
                )
                .animate()
                .fadeIn(duration: 800.ms, delay: 600.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
