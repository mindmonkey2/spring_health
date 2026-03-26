import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.neonLime,
      scaffoldBackgroundColor: AppColors.backgroundBlack,
      fontFamily: GoogleFonts.poppins().fontFamily,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonLime,
        secondary: AppColors.neonTeal,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
        onPrimary: Colors.black, // Text on neon lime should be black
        onSurface: AppColors.white,
      ),

      textTheme: TextTheme(
        headlineLarge: AppTextStyles.heading1.copyWith(color: AppColors.white),
        headlineMedium: AppTextStyles.heading2.copyWith(color: AppColors.white),
        headlineSmall: AppTextStyles.heading3.copyWith(color: AppColors.white),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.gray400),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
        labelMedium: AppTextStyles.caption.copyWith(color: AppColors.gray600),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonLime,
          foregroundColor: Colors.black, // Dark text on lime button
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              30,
            ), // Pill shape for premium feel
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 0,
          shadowColor: AppColors.neonLime.withValues(alpha: 0.4),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        hintStyle: TextStyle(color: AppColors.gray600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.gray800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.neonLime),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
      ),

      iconTheme: const IconThemeData(color: AppColors.white),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
    );
  }
}
