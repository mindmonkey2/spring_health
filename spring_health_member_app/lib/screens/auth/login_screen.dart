import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/firebase_auth_service.dart';
import '../../widgets/spring_health_logo_animated.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _authService = FirebaseAuthService();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0);
    HapticFeedback.mediumImpact();
  }

  Future<void> _onSendOtp() async {
    if (!_formKey.currentState!.validate()) {
      _triggerShake();
      return;
    }

    setState(() => _isLoading = true);

    final phone = _phoneController.text.trim();

    // ── Send OTP directly — member validation happens after OTP verify ──
    // Pre-checking checkMemberExists() here fails because the user is
    // not yet authenticated and Firestore rules block the read.
    await _authService.sendOTP(
      phoneNumber: phone,
      onCodeSent: (verificationId) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
            OtpVerificationScreen(
              phoneNumber: phone,
              verificationId: verificationId,
            ),
            transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
          ),
        );
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _triggerShake();
        _showError(error);
      },
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final logoSize = screenH * 0.20;

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenH),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    _buildLogoSection(logoSize),
                    Expanded(child: _buildFormCard()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(double logoSize) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: logoSize * 0.15),
      color: AppColors.backgroundBlack,
      child: Center(
        child: SpringHealthLogoAnimated(
          size: logoSize,
          showText: true,
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WELCOME BACK', style: AppTextStyles.heading1)
              .animate()
              .fadeIn(delay: 300.ms)
              .slideX(begin: -0.2, end: 0),

              const SizedBox(height: 6),

              Text(
                'Enter your registered mobile number\nto access your membership.',
                style: AppTextStyles.bodyMedium,
              ).animate().fadeIn(delay: 450.ms).slideX(begin: -0.2, end: 0),

              const SizedBox(height: 36),

              // Shake wrapper on invalid input
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  final dx = _shakeController.isAnimating
                  ? 8 *
                  (0.5 - _shakeAnimation.value).abs() *
                  (1 - _shakeAnimation.value)
                  : 0.0;
                  return Transform.translate(
                    offset: Offset(dx * 4, 0),
                    child: child,
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MOBILE NUMBER',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neonLime,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                        letterSpacing: 3,
                      ),
                      cursorColor: AppColors.neonLime,
                      decoration: InputDecoration(
                        counterText: '',
                        prefixIcon: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 18),
                            child: Text(
                              '+91',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.neonLime,
                              ),
                            ),
                        ),
                        prefixIconConstraints:
                        const BoxConstraints(minWidth: 0, minHeight: 0),
                        filled: true,
                        fillColor: AppColors.surfaceDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.neonLime, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.error, width: 1.5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                          BorderSide(color: AppColors.error, width: 2),
                        ),
                        hintText: '98765 43210',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 18,
                          color: AppColors.gray800,
                          letterSpacing: 2,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                    if (v.isEmpty) {
                      return 'Please enter your mobile number';
                    }
                    if (v.length != 10) {
                      return 'Enter a valid 10-digit number';
                    }
                    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v)) {
                      return 'Enter a valid Indian mobile number';
                    }
                    return null;
                      },
                    )
                    .animate()
                    .fadeIn(delay: 600.ms)
                    .slideY(begin: 0.1, end: 0),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onSendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonLime,
                    foregroundColor: Colors.black,
                      disabledBackgroundColor:
                      AppColors.neonLime.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                  ),
                  child: _isLoading
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'SENDING OTP...',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black.withValues(alpha: 0.6),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  )
                  : Text(
                    'SEND OTP',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: 1.5,
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 750.ms)
                .slideY(begin: 0.2, end: 0),
              ),

              const SizedBox(height: 28),

              Center(
                child: Text(
                  'Only registered Spring Health members can log in.\nContact your branch for access.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.gray800,
                    height: 1.6,
                  ),
                ),
              ).animate().fadeIn(delay: 900.ms),
            ],
          ),
        ),
      ),
    );
  }
}
