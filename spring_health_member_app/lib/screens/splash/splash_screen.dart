import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/spring_health_logo_animated.dart';
import '../../services/firebase_auth_service.dart';
import '../auth/login_screen.dart';
import '../main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final _authService = FirebaseAuthService();

  // Two conditions must BOTH be true before navigating:
  // 1. Logo animation has completed its entrance cycle
  // 2. Minimum display time has passed (prevents flash on fast devices)
  bool _logoComplete = false;
  bool _minTimeElapsed = false;

  // Glow orb floating animation
  late AnimationController _orbController;
  late Animation<double> _orbAnim;

  // Loading dots
  late AnimationController _dotsController;

  @override
  void initState() {
    super.initState();

    // ── Floating glow orb ────────────────────────────────
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _orbAnim = CurvedAnimation(
      parent: _orbController,
      curve: Curves.easeInOut,
    );

    // ── Loading dots ─────────────────────────────────────
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Minimum display time — 2.5s
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() => _minTimeElapsed = true);
        _maybeNavigate();
      }
    });
  }

  @override
  void dispose() {
    _orbController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  // Called by logo's onComplete AND by min-time timer.
  // Only navigates when BOTH flags are true.
  void _onLogoComplete() {
    if (!mounted) return;
    setState(() => _logoComplete = true);
    _maybeNavigate();
  }

  void _maybeNavigate() {
    if (!_logoComplete || !_minTimeElapsed) return;
    _navigate();
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    final user = _authService.currentUser;
    final destination =
        user != null ? const MainScreen() : const LoginScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, _) => destination,
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Stack(
        children: [
          // ── Layer 1: Deep radial background ─────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.3),
                  radius: 1.6,
                  colors: [
                    Color(0xFF1C3306), // deep lime core
                    Color(0xFF0D1A03), // dark middle
                    AppColors.backgroundBlack,
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // ── Layer 2: Floating glow orbs ──────────────────
          AnimatedBuilder(
            animation: _orbAnim,
            builder: (context, _) {
              return Stack(
                children: [
                  // Top-left orb
                  Positioned(
                    left: size.width * 0.05 +
                        _orbAnim.value * size.width * 0.06,
                    top: size.height * 0.08 +
                        _orbAnim.value * size.height * 0.04,
                    child: _GlowOrb(
                      radius: 80,
                      color: AppColors.neonLime,
                      opacity: 0.06 + _orbAnim.value * 0.04,
                    ),
                  ),
                  // Right orb
                  Positioned(
                    right: size.width * 0.04 +
                        (1 - _orbAnim.value) * size.width * 0.05,
                    top: size.height * 0.25 +
                        _orbAnim.value * size.height * 0.03,
                    child: _GlowOrb(
                      radius: 60,
                      color: const Color(0xFF00E5FF),
                      opacity: 0.05 + (1 - _orbAnim.value) * 0.03,
                    ),
                  ),
                  // Bottom orb
                  Positioned(
                    left: size.width * 0.3,
                    bottom: size.height * 0.12 +
                        _orbAnim.value * size.height * 0.02,
                    child: _GlowOrb(
                      radius: 50,
                      color: AppColors.neonLime,
                      opacity: 0.04 + _orbAnim.value * 0.03,
                    ),
                  ),
                ],
              );
            },
          ),

          // ── Layer 3: Main content ────────────────────────
          Column(
            children: [
              // Logo takes upper 60% of screen
              Expanded(
                flex: 6,
                child: Center(
                  child: SpringHealthLogoAnimated(
                    size: size.width * 0.52,
                    showText: true,
                    onComplete: _onLogoComplete,
                  ),
                ),
              ),

              // Lower 40% — tagline + dots + version
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Tagline ────────────────────────────
                    Text(
                      'UNLEASH YOUR POTENTIAL',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.85),
                        letterSpacing: 3.5,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 900.ms, duration: 700.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 48),

                    // ── Pulsing loading dots ───────────────
                    _LoadingDots(controller: _dotsController)
                        .animate()
                        .fadeIn(delay: 1200.ms),

                    const SizedBox(height: 20),

                    // ── Version tag ────────────────────────
                    Text(
                      'v1.0.0  ·  Member App',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.gray800.withValues(alpha: 0.6),
                        letterSpacing: 1,
                      ),
                    ).animate().fadeIn(delay: 1400.ms),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Glow Orb — soft radial light blob
// ═══════════════════════════════════════════════════════════

class _GlowOrb extends StatelessWidget {
  final double radius;
  final Color color;
  final double opacity;

  const _GlowOrb({
    required this.radius,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Loading Dots — 3 pulsing neon lime dots
// ═══════════════════════════════════════════════════════════

class _LoadingDots extends StatelessWidget {
  final AnimationController controller;

  const _LoadingDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Each dot is offset by 1/3 of the cycle
            final phase = (controller.value - i / 3) % 1.0;
            final scale = 0.6 + 0.6 * sin(phase * pi).clamp(0.0, 1.0);
            final opacity = 0.3 + 0.7 * sin(phase * pi).clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neonLime.withValues(alpha: opacity),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonLime
                            .withValues(alpha: opacity * 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
