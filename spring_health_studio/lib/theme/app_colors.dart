import 'package:flutter/material.dart';

/// Centralized color palette for Spring Health Studio
/// Unified vibrant gradient-based design system
class AppColors {
  AppColors._();

  // ══════════════════════════════════════════════════════════════════════════
  // PRIMARY COLORS - Purple Gradient Theme
  // ══════════════════════════════════════════════════════════════════════════
  static const Color primary = Color(0xFF667EEA);
  static const Color primaryDark = Color(0xFF764BA2);
  static const Color primaryLight = Color(0xFF8B9FF7);
  
  // ══════════════════════════════════════════════════════════════════════════
  // ACCENT COLORS - Vibrant accents for cards and highlights
  // ══════════════════════════════════════════════════════════════════════════
  static const Color turquoise = Color(0xFF4ECDC4);
  static const Color turquoiseDark = Color(0xFF44A08D);
  
  static const Color coral = Color(0xFFFF6B6B);
  static const Color coralDark = Color(0xFFEE5A6F);
  
  static const Color gold = Color(0xFFFFD700);
  static const Color silver   = Color(0xFFC0C0C0);
  static const Color bronze   = Color(0xFFCD7F32);
  static const Color whatsApp = Color(0xFF25D366);
  static const Color goldDark = Color(0xFFFFAA00);
  
  static const Color pink = Color(0xFFFF6B9D);
  static const Color pinkDark = Color(0xFFC06C84);
  
  static const Color skyBlue = Color(0xFF4A90E2);
  static const Color skyBlueDark = Color(0xFF2563EB);
  
  static const Color violet = Color(0xFF8B5CF6);
  static const Color violetDark = Color(0xFF6B21A8);

  // ══════════════════════════════════════════════════════════════════════════
  // SEMANTIC COLORS
  // ══════════════════════════════════════════════════════════════════════════
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  
  static const Color warning = Color(0xFFFCD34D);
  static const Color warningDark = Color(0xFFF59E0B);
  
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ══════════════════════════════════════════════════════════════════════════
  // SURFACE COLORS
  // ══════════════════════════════════════════════════════════════════════════
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFAFBFC);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // ══════════════════════════════════════════════════════════════════════════
  // TEXT COLORS
  // ══════════════════════════════════════════════════════════════════════════
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ══════════════════════════════════════════════════════════════════════════
  // DIVIDER & BORDER
  // ══════════════════════════════════════════════════════════════════════════
  static const Color divider = Color(0xFFE2E8F0);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // ══════════════════════════════════════════════════════════════════════════
  // GRADIENT DEFINITIONS
  // ══════════════════════════════════════════════════════════════════════════
  
  /// Primary app gradient (Purple theme)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Login screen gradient
  static const LinearGradient loginGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Success/Active gradient
  static const LinearGradient successGradient = LinearGradient(
    colors: [turquoise, turquoiseDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Warning gradient
  static const LinearGradient warningGradient = LinearGradient(
    colors: [gold, goldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Error/Alert gradient
  static const LinearGradient errorGradient = LinearGradient(
    colors: [coral, coralDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Pink accent gradient
  static const LinearGradient pinkGradient = LinearGradient(
    colors: [pink, pinkDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Sky blue gradient
  static const LinearGradient blueGradient = LinearGradient(
    colors: [skyBlue, skyBlueDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Violet gradient
  static const LinearGradient violetGradient = LinearGradient(
    colors: [violet, violetDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Card white gradient (subtle)
  static LinearGradient cardGradient = LinearGradient(
    colors: [surface, surface.withValues(alpha: 0.95)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glass effect overlay
  static Color glassOverlay = Colors.white.withValues(alpha: 0.25);
  static Color glassBorder = Colors.white.withValues(alpha: 0.3);

  // ══════════════════════════════════════════════════════════════════════════
  // SHADOW COLORS
  // ══════════════════════════════════════════════════════════════════════════
  static Color primaryShadow = primary.withValues(alpha: 0.3);
  static Color turquoiseShadow = turquoise.withValues(alpha: 0.3);
  static Color coralShadow = coral.withValues(alpha: 0.3);
  static Color goldShadow = gold.withValues(alpha: 0.3);
  static Color pinkShadow = pink.withValues(alpha: 0.3);
  static Color cardShadow = Colors.black.withValues(alpha: 0.08);

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ══════════════════════════════════════════════════════════════════════════
  
  /// Get gradient for quick action items by index
  static List<Color> getQuickActionGradient(int index) {
    final gradients = [
      [turquoise, turquoiseDark],
      [primary, primaryDark],
      [coral, coralDark],
      [gold, goldDark],
      [pink, pinkDark],
      [coral, const Color(0xFFFF8E53)],
      [violet, violetDark],
      [skyBlue, skyBlueDark],
    ];
    return gradients[index % gradients.length];
  }

  /// Get shadow color for a gradient
  static Color getShadowForGradient(List<Color> gradient) {
    return gradient.first.withValues(alpha: 0.3);
  }
}
