import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color backgroundBlack = Color(
    0xFF09090B,
  ); // Deepest black/charcoal
  static const Color surfaceDark = Color(0xFF18181B); // Secondary background
  static const Color cardSurface = Color(0xFF27272A); // Card background

  // Primary Accents (Neon)
  static const Color neonLime = Color(0xFFD0FD3E); // Electric Lime (Primary)
  static const Color neonTeal = Color(0xFF2DD4BF); // Bright Teal (Secondary)
  static const Color neonOrange = Color(
    0xFFFF6B35,
  ); // Vibrant Orange (Highlight)

  static const Color turquoise = Color(0xFF14B8A6); // ⬅️ ADD THIS
  static const Color textPrimary = Color(0xFFFFFFFF); // ⬅️ ADD THIS

  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);
  static const Color rankSSS = Color(0xFFFF6B35);
  static const Color rankSS = Color(0xFFFF9500);
  static const Color rankS = Color(0xFFFFD700);
  static const Color rankA = Color(0xFF4ADE80);
  static const Color rankB = Color(0xFF38BDF8);
  static const Color rankC = Color(0xFF818CF8);
  static const Color rankD = Color(0xFFA1A1AA);
  static const Color rankE = Color(0xFF52525B);
  static const Color whatsApp = Color(0xFF25D366);

  // Functional Colors
  static const Color white = Color(0xFFFAFAFA); // Off-white for text
  static const Color gray100 = Color(0xFFF4F4F5);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color gray400 = Color(0xFFA1A1AA);
  static const Color gray600 = Color(0xFF52525B);
  static const Color gray800 = Color(0xFF27272A);

  static const Color success = Color(0xFF4ADE80); // Neon Green
  static const Color warning = Color(0xFFFACC15); // Neon Yellow
  static const Color error = Color(0xFFEF4444); // Bright Red
  static const Color info = Color(0xFF38BDF8); // Neon Blue

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [neonLime, Color(0xFFB4E61E)], // Lime to slightly darker lime
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [backgroundBlack, surfaceDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x1FFFFFFF), // White with very low opacity
      Color(0x05FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
