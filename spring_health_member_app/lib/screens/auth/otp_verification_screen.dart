import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/spring_health_logo_animated.dart';
import 'package:pinput/pinput.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/firebase_auth_service.dart';
import '../main_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // ✅ FIXED — singleton, not new instance
  final _authService = FirebaseAuthService.instance;

  bool _isLoading = false;
  bool _isResending = false;

  // Track latest verificationId locally — updated on resend
  late String _currentVerificationId;

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onVerifyPressed() async {
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      _showError('Please enter the complete 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.verifyOTP(otp, verificationId: _currentVerificationId);

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Verification failed. Please try again.');
    }
  }

  Future<void> _onResendPressed() async {
    if (_isResending) return;
    setState(() => _isResending = true);
    _otpController.clear();

    try {
      await _authService.sendOTP(
        phoneNumber: widget.phoneNumber,
        onCodeSent: (newVerificationId) {
          if (!mounted) return;
          setState(() {
            _currentVerificationId = newVerificationId;
            _isResending = false;
          });
          _showSuccess('New OTP sent to +91 ${widget.phoneNumber}');
          _focusNode.requestFocus();
        },
        onCodeAutoRetrievalTimeout: (newVerificationId) {
          if (!mounted) return;
          setState(() {
            _currentVerificationId = newVerificationId;
          });
        },
        onAutoVerify: () {
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        },
        onError: (error) {
          if (!mounted) return;
          setState(() => _isResending = false);
          _showError('Failed to resend OTP: $error');
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isResending = false);
      _showError('Failed to resend OTP');
    }
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
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.black,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.black)),
            ),
          ],
        ),
        backgroundColor: AppColors.neonLime,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 60,
      textStyle: AppTextStyles.heading2.copyWith(color: AppColors.white),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray800),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.neonLime, width: 2),
      color: AppColors.surfaceDark,
      boxShadow: [
        BoxShadow(
          color: AppColors.neonLime.withValues(alpha: 0.2),
          blurRadius: 8,
          spreadRadius: 2,
        ),
      ],
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      color: AppColors.neonLime.withValues(alpha: 0.1),
      border: Border.all(color: AppColors.neonLime),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated running logo (icon only, no text)
              Center(child: SpringHealthLogoAnimated(size: 80, showText: false))
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(
                    begin: const Offset(0.7, 0.7),
                    end: const Offset(1.0, 1.0),
                    curve: Curves.elasticOut,
                  ),

              const SizedBox(height: 20),

              Text(
                'VERIFY IDENTITY',
                style: AppTextStyles.heading1,
              ).animate().fadeIn().slideX(begin: -0.2, end: 0),

              const SizedBox(height: 8),

              Text(
                'Enter the 6-digit code sent to',
                style: AppTextStyles.bodyMedium,
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 4),

              Text(
                '+91 ${widget.phoneNumber}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.neonLime,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 150.ms),

              const SizedBox(height: 24),

              Center(
                child: Pinput(
                  length: 6,
                  controller: _otpController,
                  focusNode: _focusNode,
                  autofocus: true,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  showCursor: true,
                  keyboardType: TextInputType.number,
                  onCompleted: (pin) => _onVerifyPressed(),
                ),
              ).animate().fadeIn(delay: 300.ms).scale(),

              const SizedBox(height: 32),

              Center(
                child: TextButton(
                  onPressed: _isResending ? null : _onResendPressed,
                  child: _isResending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.neonLime,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('Resend OTP', style: AppTextStyles.link),
                ),
              ).animate().fadeIn(delay: 500.ms),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonLime,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isLoading ? null : _onVerifyPressed,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'VERIFY & CONTINUE',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
