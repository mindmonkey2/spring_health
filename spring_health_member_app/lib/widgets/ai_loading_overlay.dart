import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class AiLoadingOverlay extends StatelessWidget {
  final String message;

  const AiLoadingOverlay({super.key, required this.message});

  static void show(BuildContext context, {required String message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      barrierColor: AppColors.backgroundBlack.withValues(alpha: 0.8),
      builder: (context) => AiLoadingOverlay(message: message),
    );
  }

  static void hide(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.neonLime.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonLime.withValues(alpha: 0.1),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lottie animation or pulsing circle
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonLime.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppColors.neonLime.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.smart_toy_rounded,
                    color: AppColors.neonLime,
                    size: 48,
                  ),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
                duration: 1.seconds,
                curve: Curves.easeInOut,
              )
              .then()
              .shimmer(
                color: AppColors.neonLime.withValues(alpha: 0.5),
                duration: 1.seconds,
              ),
              const SizedBox(height: 24),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(delay: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
}
