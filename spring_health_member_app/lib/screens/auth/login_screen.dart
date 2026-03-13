import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/firebase_auth_service.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _authService = FirebaseAuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onLoginPressed() async {
    final phoneNumber = _phoneController.text.trim();

    // Validation
    if (phoneNumber.length != 10) {
      _showError('Please enter a valid 10-digit phone number');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if member exists in Firestore
      final memberData = await _authService.checkMemberExists(phoneNumber);

      if (memberData == null) {
        setState(() => _isLoading = false);
        _showError('Phone number not registered.\nPlease contact gym reception.');
        return;
      }

      // Check if app is enabled for this member
      if (memberData['app_enabled'] == false) {
        setState(() => _isLoading = false);
        _showError('Your app access is disabled.\nContact gym reception.');
        return;
      }

      // Send OTP via Firebase
      await _authService.sendOTP(
        phoneNumber: phoneNumber,
        onCodeSent: (verificationId) {
          setState(() => _isLoading = false);
          if (mounted) {
            // Navigate to OTP screen with verification ID
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpVerificationScreen(
                  phoneNumber: phoneNumber,
                  verificationId: verificationId,
                ),
              ),
            );
          }
        },
        onError: (error) {
          setState(() => _isLoading = false);
          _showError(error);
        },
        onAutoVerify: (credential) async {
          // Auto-verification (Android only)
          setState(() => _isLoading = false);
          _showSuccess('Phone verified automatically!');
          // Auto-verification will sign in automatically
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('An error occurred. Please try again.');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.neonLime,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            // Background Orbs
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonLime.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonLime.withValues(alpha: 0.2),
                      blurRadius: 100,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.2, 1.2),
                duration: 4.seconds,
              ),
            ),

            Positioned(
              bottom: 100,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonTeal.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonTeal.withValues(alpha: 0.2),
                      blurRadius: 80,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),

                  // Header
                  const Icon(
                    Icons.bolt_rounded,
                    size: 64,
                    color: AppColors.neonLime,
                  )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(),

                  const SizedBox(height: 24),

                  Text(
                    'WELCOME BACK',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading1,
                  )
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 8),

                  Text(
                    'Access your premium fitness hub',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  )
                  .animate()
                  .fadeIn(delay: 400.ms)
                  .slideY(begin: 0.2, end: 0),

                  const Spacer(),

                  // Glassmorphism Login Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Phone Number',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.gray400,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white),
                              maxLength: 10,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                hintText: 'Enter your phone number',
                                prefixIcon: Icon(
                                  Icons.phone_iphone_rounded,
                                  color: AppColors.neonLime,
                                ),
                                counterText: '', // Hide character counter
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Neon Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _onLoginPressed,
                                child: _isLoading
                                ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('GET ACCESS'),
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 600.ms)
                            .slideY(begin: 0.2, end: 0),
                          ],
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 400.ms)
                  .slideY(begin: 0.4, end: 0),

                  const Spacer(flex: 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
