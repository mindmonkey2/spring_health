# Spring Health — Design System Audit
**Generated:** 2026-03-15
**Audited by:** Jules (google-labs-jules)

## Executive Summary
This audit provides a comprehensive, exhaustive evaluation of the Spring Health Studio and Spring Health Member App codebases against their specified design systems. Foundational theme files exist, but execution is extremely inconsistent. The audit identified hundreds of hardcoded colors, arbitrary typography sizing, and hardcoded spacing that breaks the grid system. Reusable components exist but many generic UI patterns are duplicated across screens.

---

## 1. Design System Overview

### Spring Health Studio — Wellness & Balance Theme
**Colors**
*   `primary` (#667EEA) - Primary
*   `primaryDark` (#764BA2) - Primary Dark
*   `primaryLight` (#8B9FF7) - Primary Light
*   `turquoise` (#4ECDC4) - Accent
*   `turquoiseDark` (#44A08D) - Accent Dark
*   `coral` (#FF6B6B) - Accent
*   `coralDark` (#EE5A6F) - Accent Dark
*   `gold` (#FFE66D) - Accent
*   `goldDark` (#FFAA00) - Accent Dark
*   `pink` (#FF6B9D) - Accent
*   `pinkDark` (#C06C84) - Accent Dark
*   `skyBlue` (#4A90E2) - Accent
*   `skyBlueDark` (#2563EB) - Accent Dark
*   `violet` (#8B5CF6) - Accent
*   `violetDark` (#6B21A8) - Accent Dark
*   `success` (#10B981) - Semantic
*   `warning` (#FCD34D) - Semantic
*   `error` (#DC2626) - Semantic
*   `info` (#3B82F6) - Semantic
*   `background` (#F5F7FA) - Surface
*   `surface` (#FFFFFF) - Surface
*   `textPrimary` (#1A1A2E) - Text
*   `textSecondary` (#64748B) - Text

**Typography**
*   Display (Large/Medium/Small): Poppins, Bold/SemiBold, 36/28/24
*   Headline (Large/Medium/Small): Poppins, Bold/SemiBold, 22/20/18
*   Title (Large/Medium/Small): Poppins, Bold/SemiBold, 16/14/12
*   Body (Large/Medium/Small): Inter, Regular, 16/14/12
*   Label (Large/Medium/Small): Inter, SemiBold/Medium, 14/12/10

**Dimensions**
*   `radius`: 16.0
*   `padding`: 16.0
*   `paddingSmall`: 8.0
*   `paddingLarge`: 24.0

### Spring Health Member App — Neon Dark Theme
**Colors**
*   `backgroundBlack` (#09090B) - Deepest black
*   `surfaceDark` (#18181B) - Secondary background
*   `cardSurface` (#27272A) - Card background
*   `neonLime` (#D0FD3E) - Electric Lime (Primary)
*   `neonTeal` (#2DD4BF) - Bright Teal (Secondary)
*   `neonOrange` (#FF6B35) - Vibrant Orange (Highlight)
*   `turquoise` (#14B8A6) - Custom Added Accent
*   `white` (#FAFAFA) - Text
*   `textPrimary` (#FFFFFF) - White text
*   `gray400` (#A1A1AA) - Gray
*   `gray600` (#52525B) - Gray
*   `gray800` (#27272A) - Gray
*   `success` (#4ADE80) - Semantic Neon Green
*   `warning` (#FACC15) - Semantic Neon Yellow
*   `error` (#EF4444) - Semantic Bright Red
*   `info` (#38BDF8) - Semantic Neon Blue

**Typography**
*   `heading1`: Poppins, Bold, 28, spacing -0.5
*   `heading2`: Poppins, SemiBold, 24
*   `heading3`: Poppins, SemiBold, 20
*   `bodyLarge`: Poppins, Regular, 16
*   `bodyMedium`: Poppins, Regular, 14
*   `caption`: Poppins, Regular, 12
*   `button`: Poppins, SemiBold, 16
*   `link`: Poppins, SemiBold, 14

**Dimensions**
*   `radius`: 16.0
*   `padding`: 16.0
*   `paddingSmall`: 8.0
*   `paddingLarge`: 24.0

---

## 2. Color Compliance Report
### Studio Color Violations
| File | Line | Hardcoded Value | Should Be |
|---|---|---|---|
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 21 | `static const green = Color(0xFF10B981);` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 22 | `static const teal = Color(0xFF14B8A6);` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 23 | `static const orange = Color(0xFFF59E0B);` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 24 | `static const bg = Color(0xFFF1F5F9);` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 26 | `static const textDark = Color(0xFF1E293B);` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 27 | `static const textMid = Color(0xFF64748B);` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 295 | `color: Colors.grey.shade600, fontSize: 11)),` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 347 | `color: active ? green : Colors.grey.shade300,` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 418 | `size: 64, color: Colors.grey.shade300),` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 421 | `style: TextStyle(color: Colors.grey.shade500)),` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 425 | `color: Colors.grey.shade400, fontSize: 12)),` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 469 | `if (rank == 1) return const Color(0xFFFFD700);` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 470 | `if (rank == 2) return const Color(0xFFC0C0C0);` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 471 | `if (rank == 3) return const Color(0xFFCD7F32);` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 515 | `color: Colors.grey.shade500, fontSize: 12)),` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 532 | `color: Colors.grey.shade600, fontSize: 11)),` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 538 | `color: Colors.grey.shade400, size: 20),` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 555 | `color: Colors.red.shade400, size: 18),` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 573 | `color: Colors.red.shade400, size: 18),` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 582 | `color: Colors.grey.shade600, size: 18),` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 623 | `style: TextStyle(color: add ? orange : Colors.red)),` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 628 | `style: TextStyle(color: Colors.grey.shade600)),` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 650 | `backgroundColor: add ? orange : Colors.red),` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 674 | `backgroundColor: add ? orange : Colors.red,` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 730 | `: Colors.grey.shade50,` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 733 | `color: isSelected ? green : Colors.grey.shade200,` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 762 | `style: TextStyle(color: Colors.grey)),` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 768 | `disabledBackgroundColor: Colors.grey.shade300,` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 818 | `ElevatedButton.styleFrom(backgroundColor: Colors.red),` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 833 | `backgroundColor: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 891 | `color: Colors.grey.shade300,` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 922 | `color: Colors.grey.shade500, fontSize: 13)),` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 952 | `('Current Streak', '${entry.currentStreak} days', Colors.deepOrange),` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 955 | `('Check-ins', '${entry.totalCheckIns}', Colors.indigo),` | AppColors |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 956 | `('Badges', '${entry.badgeCount}', const Color(0xFFFFD700)),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 31 | `static const Color sageGreen = Color(0xFF10B981);` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 32 | `static const Color tealAqua  = Color(0xFF14B8A6);` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 33 | `static const Color navyBlue  = Color(0xFF1E3A8A);` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 35 | `static const Color warmYellow = Color(0xFFFCD34D);` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 146 | `backgroundColor: Colors.green,` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 152 | `backgroundColor: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 172 | `backgroundColor: Colors.red),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 185 | `backgroundColor: Colors.orange,` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 191 | `backgroundColor: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 213 | `trainer.isActive ? Colors.orange : sageGreen),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 228 | `backgroundColor: Colors.green,` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 234 | `backgroundColor: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 244 | `backgroundColor: Colors.grey.shade50,` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 253 | `backgroundColor: Colors.grey.shade50,` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 302 | `trainer.isActive ? Colors.orange : sageGreen,` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 380 | `? Colors.green` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 381 | `: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 455 | `: Colors.red.withValues(alpha: 0.1),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 458 | `color: trainer.isActive ? sageGreen : Colors.red,` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 467 | `color: trainer.isActive ? sageGreen : Colors.red,` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 474 | `trainer.isActive ? sageGreen : Colors.red,` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 537 | `color: Colors.grey)),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 564 | `color: const Color(0xFF25D366),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 682 | `size: 64, color: Colors.grey.shade400),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 687 | `color: Colors.grey.shade600)),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 714 | `: Colors.red.withValues(alpha: 0.1),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 722 | `: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 743 | `: Colors.red` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 755 | `: Colors.red),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 761 | `color: Colors.red),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 851 | `size: 64, color: Colors.grey.shade400),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 856 | `color: Colors.grey.shade600)),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 943 | `color: Colors.grey.shade700,` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 1018 | `style: const TextStyle(fontSize: 12, color: Colors.grey)),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 1075 | `Icon(icon, size: 18, color: Colors.grey.shade600),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 1083 | `fontSize: 12, color: Colors.grey.shade600)),` | AppColors |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 40 | `static const Color sageGreen = Color(0xFF10B981);` | AppColors |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 41 | `static const Color tealAqua = Color(0xFF14B8A6);` | AppColors |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 185 | `backgroundColor: Colors.green,` | AppColors |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 195 | `backgroundColor: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 384 | `fillColor: Colors.grey[100],` | AppColors |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 534 | `fillColor: enabled ? null : Colors.grey[100],` | AppColors |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 25 | `static const Color sageGreen = Color(0xFF10B981);` | AppColors |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 26 | `static const Color tealAqua = Color(0xFF14B8A6);` | AppColors |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 27 | `static const Color warmYellow = Color(0xFFFCD34D);` | AppColors |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 48 | `backgroundColor: Colors.grey[50],` | AppColors |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 97 | `borderSide: BorderSide(color: Colors.grey[300]!),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 101 | `borderSide: BorderSide(color: Colors.grey[300]!),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 108 | `fillColor: Colors.grey[50],` | AppColors |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 153 | `Icon(Icons.error_outline, size: 64, color: Colors.red[300]),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 157 | `style: TextStyle(fontSize: 16, color: Colors.grey[600]),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 172 | `Icon(Icons.person_off, size: 64, color: Colors.grey[400]),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 176 | `style: TextStyle(fontSize: 16, color: Colors.grey[600]),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 183 | `style: TextStyle(fontSize: 14, color: Colors.grey[500]),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 241 | `color: isSelected ? sageGreen : Colors.grey[700],` | AppColors |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 244 | `color: isSelected ? sageGreen : Colors.grey[300]!,` | AppColors |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 327 | `: Colors.red.withValues(alpha: 0.1),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 335 | `color: trainer.isActive ? sageGreen : Colors.red,` | AppColors |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 344 | `Icon(Icons.fitness_center, size: 14, color: Colors.grey[600]),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 348 | `style: TextStyle(fontSize: 12, color: Colors.grey[600]),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 351 | `Icon(Icons.timeline, size: 14, color: Colors.grey[600]),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 355 | `style: TextStyle(fontSize: 12, color: Colors.grey[600]),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 362 | `Icon(Icons.phone, size: 14, color: Colors.grey[600]),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 366 | `style: TextStyle(fontSize: 12, color: Colors.grey[600]),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 392 | `const Icon(Icons.people, size: 12, color: Colors.orange),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 399 | `color: Colors.orange,` | AppColors |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 413 | `Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_dashboard_screen.dart | 84 | `unselectedItemColor: Colors.grey,` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_dashboard_screen.dart | 213 | `const Icon(Icons.star, color: Colors.amber, size: 16),` | AppColors |
| spring_health_studio/lib/screens/trainers/trainer_dashboard_screen.dart | 228 | `color: Colors.grey.shade100,` | AppColors |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 28 | `static const Color primaryPurple = Color(0xFF6366F1);` | AppColors |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 29 | `static const Color accentPink = Color(0xFFEC4899);` | AppColors |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 62 | `backgroundColor: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 141 | `color: Colors.grey.shade100,` | AppColors |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 143 | `border: Border.all(color: Colors.grey.shade300),` | AppColors |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 160 | `valueColor: newDueAmount > 0 ? Colors.orange : Colors.green,` | AppColors |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 169 | `color: Colors.blue.withValues(alpha: 0.1),` | AppColors |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 171 | `border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),` | AppColors |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 178 | `Icon(Icons.receipt_long, color: Colors.blue, size: 20),` | AppColors |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 189 | `style: TextStyle(fontSize: 12, color: Colors.grey[600]),` | AppColors |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 207 | `backgroundColor: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 225 | `style: const TextStyle(fontSize: 13, color: Colors.grey),` | AppColors |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 249 | `colors: [primaryPurple, Color(0xFF8B5CF6), accentPink],` | AppColors |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 288 | `color: Colors.red[50],` | AppColors |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 306 | `color: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 333 | `fillColor: Colors.grey[50],` | AppColors |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 385 | `fillColor: Colors.grey[50],` | AppColors |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 403 | `fillColor: Colors.grey[50],` | AppColors |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 415 | `color: Colors.orange[50],` | AppColors |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 420 | `Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),` | AppColors |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 425 | `style: TextStyle(fontSize: 12, color: Colors.orange[700]),` | AppColors |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 438 | `color: Colors.blue[50],` | AppColors |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 440 | `border: Border.all(color: Colors.blue[200]!),` | AppColors |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 453 | `color: Colors.blue,` | AppColors |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 469 | `? Colors.red` | AppColors |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 470 | `: Colors.green,` | AppColors |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 18 | `static const Color _green  = Color(0xFF10B981);` | AppColors |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 19 | `static const Color _teal   = Color(0xFF14B8A6);` | AppColors |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 297 | `Icon(icon, size: 48, color: Colors.grey.shade400),` | AppColors |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 306 | `color: Colors.grey.shade600, fontSize: 13)),` | AppColors |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 331 | `static const Color _green = Color(0xFF10B981);` | AppColors |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 332 | `static const Color _teal  = Color(0xFF14B8A6);` | AppColors |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 381 | `color: const Color(0xFFFCD34D).withValues(alpha: 0.2),` | AppColors |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 384 | `color: const Color(0xFFFCD34D),` | AppColors |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 389 | `color: Color(0xFFD97706),` | AppColors |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 401 | `color: Colors.grey.shade600, fontSize: 12),` | AppColors |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 437 | `fontSize: 10, color: Colors.grey.shade600)),` | AppColors |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 463 | `color: Color(0xFF10B981)),` | AppColors |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 467 | `style: const TextStyle(color: Colors.grey)),` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 42 | `static const Color sageGreen = Color(0xFF10B981);` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 43 | `static const Color tealAqua = Color(0xFF14B8A6);` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 44 | `static const Color warmYellow = Color(0xFFFCD34D);` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 327 | `color: Colors.green.withAlpha(25),` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 330 | `child: const Icon(Icons.check_circle, color: Colors.green, size: 32),` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 354 | `_buildSummaryRow('Due Amount', '₹${_dueAmount.toStringAsFixed(0)}', valueColor: Colors.red),` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 370 | `backgroundColor: Colors.green,` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 383 | `color: Colors.grey.shade100,` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 385 | `border: Border.all(color: Colors.grey.shade300),` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 398 | `color: Colors.orange.withValues(alpha: 0.1),` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 400 | `border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 407 | `Icon(Icons.picture_as_pdf, color: Colors.orange, size: 20),` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 418 | `style: TextStyle(fontSize: 12, color: Colors.grey),` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 452 | `backgroundColor: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 463 | `backgroundColor: Colors.green,` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 492 | `Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 558 | `backgroundColor: Colors.red.withValues(alpha: 0.2),` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 564 | `color: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 582 | `style: TextStyle(color: Colors.grey[600]),` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 590 | `color: Colors.red.withValues(alpha: 0.2),` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 598 | `color: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 613 | `style: TextStyle(fontSize: 12, color: Colors.grey[600]),` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 628 | `style: TextStyle(fontSize: 12, color: Colors.grey[600]),` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 634 | `color: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 717 | `color: Colors.grey[600],` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 762 | `style: TextStyle(fontSize: 12, color: Colors.grey[700]),` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 786 | `style: TextStyle(fontSize: 12, color: Colors.grey),` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 822 | `fillColor: Colors.grey[100],` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 946 | `Icon(Icons.warning, color: Color(0xFFF59E0B)),` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 959 | `color: Color(0xFFF59E0B),` | AppColors |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 978 | `disabledBackgroundColor: Colors.grey,` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 37 | `static const Color sageGreen  = Color(0xFF10B981);` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 38 | `static const Color tealAqua   = Color(0xFF14B8A6);` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 39 | `static const Color warmYellow = Color(0xFFFCD34D);` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 40 | `static const Color coralRed   = Color(0xFFEF4444);` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 85 | `color: Colors.grey.shade300,` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 96 | `_optionTile(Icons.message_rounded,    'Send WhatsApp Reminder', const Color(0xFF25D366), 'whatsapp'),` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 148 | `trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 220 | `style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 295 | `const wa = Color(0xFF25D366);` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 401 | `color: Colors.blue.withValues(alpha: 0.1),` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 403 | `border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 407 | `Icon(Icons.picture_as_pdf, color: Colors.blue, size: 20),` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 414 | `style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 422 | `color: Colors.grey.shade600,` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 462 | `color: _isActive ? Colors.greenAccent : coralRed,` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 465 | `color: (_isActive ? Colors.greenAccent : coralRed)` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 544 | `: [coralRed, const Color(0xFFFF8E53)],` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 565 | `style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 574 | `: [coralRed, const Color(0xFFFF8E53)],` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 608 | `icon: const Icon(Icons.chat_rounded, color: Color(0xFF25D366)),` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 610 | `style: TextStyle(color: Color(0xFF25D366))),` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 612 | `side: const BorderSide(color: Color(0xFF25D366)),` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 646 | `? [warmYellow, const Color(0xFFF59E0B)]` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 648 | `: [coralRed, const Color(0xFFFF8E53)],` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 711 | `color: Colors.grey.shade600,` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 745 | `Icon(Icons.payment_rounded, size: 64, color: Colors.grey.shade400),` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 748 | `style: TextStyle(fontSize: 16, color: Colors.grey)),` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 803 | `color: isInitial ? tealAqua : const Color(0xFFF59E0B),` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 817 | `color: Colors.grey.shade600, fontSize: 12)),` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 826 | `fontSize: 11, color: Colors.grey.shade600),` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 839 | `color: (isInitial ? tealAqua : const Color(0xFFF59E0B))` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 843 | `color: isInitial ? tealAqua : const Color(0xFFF59E0B),` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 851 | `color: isInitial ? tealAqua : const Color(0xFFF59E0B),` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 927 | `Icon(Icons.event_busy_rounded, size: 64, color: Colors.grey.shade400),` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 930 | `style: TextStyle(fontSize: 16, color: Colors.grey)),` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1043 | `Icon(Icons.article_outlined, size: 64, color: Colors.grey.shade400),` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1046 | `style: TextStyle(fontSize: 16, color: Colors.grey)),` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1064 | `color = Colors.green;` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1068 | `color = Colors.orange;` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1072 | `color = Colors.blue;` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1080 | `color = Colors.grey;` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1110 | `size: 13, color: Colors.grey.shade600,` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1115 | `fontSize: 11, color: Colors.grey.shade600)),` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1118 | `size: 13, color: Colors.grey.shade600),` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1123 | `fontSize: 11, color: Colors.grey.shade600),` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1130 | `color: Colors.grey.shade500,` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1138 | `color: (doc.success ? Colors.green : coralRed)` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1148 | `color: doc.success ? Colors.green : coralRed,` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1156 | `color: doc.success ? Colors.green : coralRed,` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1190 | `Icon(icon, size: 20, color: Colors.grey.shade600),` | AppColors |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1194 | `style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),` | AppColors |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 215 | `backgroundColor: Colors.orange,` | AppColors |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 291 | `color: Colors.grey.shade100,` | AppColors |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 293 | `border: Border.all(color: Colors.grey.shade300),` | AppColors |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 307 | `valueColor: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 316 | `color: Colors.green.withValues(alpha: 0.1),` | AppColors |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 318 | `border: Border.all(color: Colors.green.withValues(alpha: 0.3)),` | AppColors |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 325 | `Icon(Icons.picture_as_pdf, color: Colors.green, size: 20),` | AppColors |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 336 | `style: TextStyle(fontSize: 12, color: Colors.grey[600]),` | AppColors |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 355 | `backgroundColor: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 363 | `backgroundColor: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 544 | `fillColor: Colors.grey[100],` | AppColors |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 738 | `Icon(Icons.warning, color: Color(0xFFF59E0B)),` | AppColors |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 754 | `color: Color(0xFFF59E0B),` | AppColors |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 867 | `fillColor: enabled ? null : Colors.grey[100],` | AppColors |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 882 | `style: const TextStyle(fontSize: 13, color: Colors.grey),` | AppColors |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 147 | `color: Colors.grey[100],` | AppColors |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 224 | `const Icon(Icons.error, size: 64, color: Colors.red),` | AppColors |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 242 | `Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),` | AppColors |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 246 | `style: TextStyle(fontSize: 18, color: Colors.grey[600]),` | AppColors |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 251 | `style: TextStyle(color: Colors.grey[500]),` | AppColors |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 266 | `Icon(Icons.search_off, size: 64, color: Colors.grey[400]),` | AppColors |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 270 | `style: TextStyle(fontSize: 18, color: Colors.grey[600]),` | AppColors |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 275 | `style: TextStyle(color: Colors.grey[500]),` | AppColors |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 353 | `: Colors.red.withValues(alpha: 0.2),` | AppColors |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 359 | `color: isActive ? sageGreen : Colors.red,` | AppColors |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 409 | `color: Colors.grey[600],` | AppColors |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 415 | `Icon(Icons.phone, size: 12, color: Colors.grey[500]),` | AppColors |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 421 | `color: Colors.grey[600],` | AppColors |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 432 | `color: isActive ? sageGreen : Colors.red, // ✅ Updated` | AppColors |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 439 | `color: isActive ? sageGreen : Colors.red[700], // ✅ Updated` | AppColors |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 449 | `const Icon(Icons.warning, size: 12, color: Colors.red),` | AppColors |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 455 | `color: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 477 | `: Colors.red.withValues(alpha: 0.2),` | AppColors |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 485 | `color: isActive ? sageGreen : Colors.red[700],` | AppColors |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 493 | `color: Colors.grey,` | AppColors |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 177 | `backgroundColor: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 253 | `backgroundColor: Colors.green,` | AppColors |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 261 | `SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),` | AppColors |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 278 | `colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],` | AppColors |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 296 | `color: Colors.blue[50],` | AppColors |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 298 | `border: Border.all(color: Colors.blue[200]!),` | AppColors |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 302 | `Icon(Icons.info_outline, color: Colors.blue),` | AppColors |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 328 | `fillColor: Colors.grey[50],` | AppColors |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 342 | `fillColor: Colors.grey[50],` | AppColors |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 356 | `fillColor: Colors.grey[50],` | AppColors |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 401 | `fillColor: Colors.blue[50],` | AppColors |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 420 | `color: Colors.blue[50],` | AppColors |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 432 | `color: Colors.blue,` | AppColors |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 451 | `fillColor: Colors.grey[50],` | AppColors |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 466 | `fillColor: Colors.grey[50],` | AppColors |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 478 | `color: Colors.green[50],` | AppColors |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 493 | `color: Colors.green,` | AppColors |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 550 | `backgroundColor: const Color(0xFF6366F1),` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 52 | `static const Color sageGreen = Color(0xFF10B981);` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 53 | `static const Color tealAqua = Color(0xFF14B8A6);` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 54 | `static const Color warmYellow = Color(0xFFFCD34D);` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 55 | `static const Color softCoral = Color(0xFFF87171);` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 246 | `backgroundColor: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 374 | `color: Colors.grey.shade300,` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 386 | `style: const TextStyle(color: Colors.grey, fontSize: 13),` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 498 | `color: Colors.grey.shade50,` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 519 | `Icons.account_balance_wallet, Colors.deepOrange),` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 581 | `backgroundColor: Colors.grey.shade100,` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 638 | `backgroundColor: Colors.grey,` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 669 | `size: 16, color: isSelected ? color : Colors.grey.shade600),` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 789 | `color: Color(0xFFF59E0B)),` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 796 | `color: Color(0xFFF59E0B),` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 828 | `fontSize: 12, color: Colors.grey),` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 896 | `Colors.orange)),` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 906 | `Colors.deepPurple)),` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 920 | `color: Colors.grey.shade400),` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 926 | `color: Colors.grey.shade600),` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 965 | `color: Colors.grey.shade600),` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 997 | `: Colors.purple` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1009 | `? const Color(0xFFF59E0B)` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1010 | `: Colors.purple.shade700,` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1076 | `size: 64, color: Colors.grey.shade400),` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1081 | `fontSize: 16, color: Colors.grey.shade600),` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1125 | `color: Colors.grey.shade600)),` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1181 | `size: 64, color: Colors.grey.shade400),` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1186 | `fontSize: 16, color: Colors.grey.shade600),` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1209 | `: Colors.red.withValues(alpha: 0.2),` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1215 | `color: isActive ? sageGreen : Colors.red),` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1230 | `color: Colors.grey.shade600),` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1237 | `color: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1249 | `: Colors.red.withValues(alpha: 0.15),` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1257 | `color: isActive ? sageGreen : Colors.red.shade700,` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1293 | `style: TextStyle(fontSize: 11, color: Colors.grey.shade600),` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1323 | `colors: [PdfColors.green, PdfColors.teal]),` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1382 | `content: Text('Error: $e'), backgroundColor: Colors.red));` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1418 | `const pw.BoxDecoration(color: PdfColors.grey300),` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1448 | `const pw.BoxDecoration(color: PdfColors.grey300),` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1476 | `const pw.BoxDecoration(color: PdfColors.grey300),` | AppColors |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1503 | `fontSize: 9, color: PdfColors.grey600),` | AppColors |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 107 | `backgroundColor: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 138 | `backgroundColor: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 145 | `const Icon(Icons.error, size: 64, color: Colors.red),` | AppColors |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 154 | `style: TextStyle(color: Colors.grey),` | AppColors |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 160 | `backgroundColor: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 209 | `color: Colors.grey[100],` | AppColors |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 353 | `[sageGreen, const Color(0xFF44A08D)],` | AppColors |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 369 | `[tealAqua, const Color(0xFF667EEA)],` | AppColors |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 600 | `leading: Icon(icon, color: isActive ? sageGreen : Colors.grey[600]),` | AppColors |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 604 | `color: isActive ? sageGreen : Colors.grey[800],` | AppColors |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 101 | `backgroundColor: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 143 | `backgroundColor: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 150 | `const Icon(Icons.error, size: 64, color: Colors.red),` | AppColors |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 159 | `style: TextStyle(color: Colors.grey),` | AppColors |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 165 | `backgroundColor: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 614 | `color: Colors.grey[600],` | AppColors |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 620 | `const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),` | AppColors |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 34 | `static const Color sageGreen = Color(0xFF10B981);` | AppColors |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 35 | `static const Color tealAqua = Color(0xFF14B8A6);` | AppColors |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 115 | `SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),` | AppColors |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 291 | `fillColor: Colors.grey[100],` | AppColors |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 23 | `static const Color sageGreen = Color(0xFF10B981);` | AppColors |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 24 | `static const Color tealAqua = Color(0xFF14B8A6);` | AppColors |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 26 | `static const Color softCoral = Color(0xFFF87171);` | AppColors |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 99 | `color: Colors.grey[50],` | AppColors |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 137 | `backgroundColor: Colors.grey[100],` | AppColors |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 173 | `Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),` | AppColors |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 177 | `style: TextStyle(fontSize: 18, color: Colors.grey[600]),` | AppColors |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 195 | `colors: [softCoral, Colors.deepOrange],` | AppColors |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 288 | `style: TextStyle(fontSize: 11, color: Colors.grey[600]), // ✅ Smaller font` | AppColors |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 313 | `color: Colors.grey[200],` | AppColors |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 391 | `color: Colors.grey[600],` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 34 | `static const Color primaryGreen = Color(0xFF00BFA5);` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 35 | `static const Color deepGreen = Color(0xFF00897B);` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 36 | `static const Color accentOrange = Color(0xFFFF6B6B);` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 37 | `static const Color accentYellow = Color(0xFFFFB74D);` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 38 | `static const Color accentPink = Color(0xFFFF6B9D);` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 39 | `static const Color accentGray = Color(0xFF9E9E9E);` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 73 | `backgroundColor: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 107 | `backgroundColor: const Color(0xFFF5F7FA),` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 189 | `gradient: [accentPink, const Color(0xFFC06C84)],` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 198 | `gradient: [accentYellow, const Color(0xFFFFAA00)],` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 207 | `gradient: [accentOrange, const Color(0xFFEE5A6F)],` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 257 | `color: Colors.grey,` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 277 | `gradient: [accentPink, const Color(0xFFC06C84)],` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 301 | `gradient: [accentYellow, const Color(0xFFFFAA00)],` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 326 | `gradient: [accentOrange, const Color(0xFFEE5A6F)],` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 348 | `gradient: [accentGray, const Color(0xFF757575)],` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 415 | `color: Colors.grey,` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 445 | `Icon(Icons.check_circle_outline, size: 48, color: Colors.grey[400]),` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 449 | `style: TextStyle(color: Colors.grey[600]),` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 545 | `backgroundColor: Colors.green,` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 557 | `backgroundColor: Colors.orange,` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 569 | `backgroundColor: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 581 | `backgroundColor: Colors.purple,` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 619 | `Icon(Icons.celebration, color: Colors.orange),` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 635 | `color: Colors.orange.withValues(alpha: 0.1),` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 637 | `border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 641 | `const Icon(Icons.info_outline, color: Colors.orange, size: 20),` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 648 | `color: Colors.grey[700],` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 667 | `backgroundColor: Colors.orange,` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 718 | `const Icon(Icons.check_circle, color: Colors.green),` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 728 | `_buildResultRow('Sent', result['sent']!, Colors.green),` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 730 | `_buildResultRow('Failed', result['failed']!, Colors.red),` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 737 | `backgroundColor: Colors.green,` | AppColors |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 20 | `static const _green = Color(0xFF10B981);` | AppColors |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 21 | `static const _teal = Color(0xFF14B8A6);` | AppColors |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 22 | `static const _orange = Color(0xFFF59E0B);` | AppColors |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 23 | `static const _bg = Color(0xFFF1F5F9);` | AppColors |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 68 | `_showSnack('Search and select a member first', Colors.red);` | AppColors |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 105 | `_showSnack('Error: $e', Colors.red);` | AppColors |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 166 | `style: TextStyle(color: Colors.grey.shade600),` | AppColors |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 283 | `style: const TextStyle(color: Colors.red, fontSize: 12)),` | AppColors |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 316 | `color: Colors.grey.shade500,` | AppColors |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 344 | `_typeChip('🎁', 'Offer', 'offer', Colors.purple),` | AppColors |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 345 | `_typeChip('⚔️', 'Challenge', 'challenge', Colors.indigo),` | AppColors |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 367 | `TextStyle(color: Colors.grey.shade400, fontSize: 11),` | AppColors |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 383 | `TextStyle(color: Colors.grey.shade400, fontSize: 11),` | AppColors |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 448 | `color: selected ? color : Colors.grey.shade300,` | AppColors |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 453 | `color: selected ? color : Colors.grey.shade600,` | AppColors |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 473 | `color: selected ? color : Colors.grey.shade300,` | AppColors |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 479 | `color: selected ? color : Colors.grey.shade600,` | AppColors |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 558 | `color: selected ? color.withValues(alpha: 0.08) : Colors.grey.shade50,` | AppColors |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 561 | `color: selected ? color : Colors.grey.shade200,` | AppColors |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 567 | `color: selected ? color : Colors.grey.shade400,` | AppColors |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 574 | `color: selected ? color : Colors.grey.shade700)),` | AppColors |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 577 | `fontSize: 11, color: Colors.grey.shade500)),` | AppColors |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 600 | `color: Colors.grey.shade900,` | AppColors |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 622 | `style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),` | AppColors |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 632 | `style: TextStyle(color: Colors.grey.shade400, fontSize: 12),` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_screen.dart | 17 | `static const Color sageGreen = Color(0xFF10B981);` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_screen.dart | 18 | `static const Color tealAqua = Color(0xFF14B8A6);` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_screen.dart | 19 | `static const Color warmYellow = Color(0xFFFCD34D);` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_screen.dart | 43 | `style: TextStyle(fontSize: 12, color: Colors.grey),` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_screen.dart | 63 | `color: Colors.orange,` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_screen.dart | 71 | `color: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_screen.dart | 121 | `color: Colors.grey[600],` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_screen.dart | 272 | `color: success ? Colors.green : Colors.orange,` | AppColors |
| spring_health_studio/lib/screens/notifications/notifications_screen.dart | 297 | `Icon(Icons.error, color: Colors.red, size: 32),` | AppColors |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 21 | `static const Color primaryPurple = Color(0xFF667EEA);` | AppColors |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 22 | `static const Color deepPurple = Color(0xFF764BA2);` | AppColors |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 23 | `static const Color accentOrange = Color(0xFFFF6B6B);` | AppColors |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 24 | `static const Color accentYellow = Color(0xFFFFE66D);` | AppColors |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 25 | `static const Color accentPink = Color(0xFFFF6B9D);` | AppColors |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 42 | `backgroundColor: const Color(0xFFF5F7FA),` | AppColors |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 117 | `[accentOrange, const Color(0xFFEE5A6F)],` | AppColors |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 126 | `color: Color(0xFF1A1A2E),` | AppColors |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 170 | `[accentYellow, const Color(0xFFFFAA00)],` | AppColors |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 180 | `[accentOrange, const Color(0xFFEE5A6F)],` | AppColors |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 193 | `color: Color(0xFF1A1A2E),` | AppColors |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 238 | `[accentPink, const Color(0xFFC06C84)],` | AppColors |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 247 | `color: Color(0xFF1A1A2E),` | AppColors |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 291 | `color: Color(0xFF1A1A2E),` | AppColors |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 297 | `style: TextStyle(color: Colors.grey),` | AppColors |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 414 | `style: TextStyle(fontSize: 12, color: Colors.grey[600]),` | AppColors |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 438 | `Icon(Icons.check_circle, size: 64, color: Colors.grey[300]),` | AppColors |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 442 | `style: TextStyle(fontSize: 16, color: Colors.grey[600]),` | AppColors |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 457 | `border: Border.all(color: Colors.grey.shade200),` | AppColors |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 495 | `color: Colors.grey[800],` | AppColors |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 528 | `backgroundColor: success ? Colors.green : Colors.red,` | AppColors |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 586 | `Icon(Icons.check_circle, color: Colors.green),` | AppColors |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 597 | `_buildResultRow('Successfully Sent', results['sent']!, Colors.green),` | AppColors |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 599 | `_buildResultRow('Failed', results['failed']!, Colors.red),` | AppColors |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 28 | `static const Color _yellow = Color(0xFFF59E0B);` | AppColors |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 29 | `static const Color _red    = Color(0xFFEF4444);` | AppColors |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 49 | `return Colors.grey.shade400;` | AppColors |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 254 | `_priorityTile('normal',    'Normal',    Icons.info_outline_rounded,  Colors.grey.shade600),` | AppColors |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 268 | `_priorityRow('normal',    'Normal',    'General information for members',  Colors.grey.shade700),` | AppColors |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 292 | `: Colors.grey.shade100,` | AppColors |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 295 | `color: selected ? color : Colors.grey.shade300,` | AppColors |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 301 | `color: selected ? color : Colors.grey.shade400,` | AppColors |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 310 | `color: selected ? color : Colors.grey.shade500,` | AppColors |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 336 | `color: selected ? color : Colors.grey.shade400,` | AppColors |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 370 | `fontSize: 12, color: Colors.grey.shade500),` | AppColors |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 414 | `color: Colors.grey.shade600,` | AppColors |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 439 | `? [Colors.grey.shade400, Colors.grey.shade400]` | AppColors |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 20 | `static const Color sageGreen  = Color(0xFF10B981);` | AppColors |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 21 | `static const Color tealAqua   = Color(0xFF14B8A6);` | AppColors |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 22 | `static const Color warmYellow = Color(0xFFFCD34D);` | AppColors |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 23 | `static const Color coralRed   = Color(0xFFEF4444);` | AppColors |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 24 | `static const Color softBlue   = Color(0xFF3B82F6);` | AppColors |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 109 | `size: 72, color: Colors.grey.shade400),` | AppColors |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 112 | `style: TextStyle(fontSize: 18, color: Colors.grey)),` | AppColors |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 115 | `style: TextStyle(color: Colors.grey)),` | AppColors |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 133 | `Colors.grey),` | AppColors |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 166 | `? const Color(0xFFF59E0B)` | AppColors |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 167 | `: Colors.grey.shade400;` | AppColors |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 224 | `color: Colors.grey.shade600, fontSize: 13)),` | AppColors |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 228 | `size: 14, color: Colors.grey.shade500),` | AppColors |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 232 | `fontSize: 12, color: Colors.grey.shade500)),` | AppColors |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 236 | `fontSize: 11, color: Colors.grey.shade400)),` | AppColors |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 428 | `color: Colors.grey.shade500)),` | AppColors |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 541 | `backgroundColor: Colors.grey,` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 116 | `backgroundColor: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 258 | `style: TextStyle(fontSize: 16, color: Colors.grey),` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 547 | `'gradient': const [Color(0xFF667EEA), Color(0xFF764BA2)],` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 554 | `'gradient': const [Color(0xFF4ECDC4), Color(0xFF44A08D)],` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 561 | `'gradient': const [Color(0xFFFFE66D), Color(0xFFFFAA00)],` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 569 | `'gradient': const [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 666 | `color: Colors.grey,` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 862 | `? [teal, const Color(0xFF44A08D)]` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 863 | `: [coral, const Color(0xFFEE5A6F)];` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 950 | `'gradient': const [Color(0xFF4ECDC4), Color(0xFF44A08D)],` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 957 | `'gradient': const [Color(0xFF667EEA), Color(0xFF764BA2)],` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 964 | `'gradient': const [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 971 | `'gradient': const [Color(0xFFFFE66D), Color(0xFFFFAA00)],` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 978 | `'gradient': const [Color(0xFFFF6B9D), Color(0xFFC06C84)],` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 986 | `'gradient': const [Color(0xFF06B6D4), Color(0xFF0891B2)],` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 993 | `'gradient': const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1000 | `'gradient': const [Color(0xFF8B5CF6), Color(0xFF6B21A8)],` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1008 | `'gradient': const [Color(0xFF10B981), Color(0xFF14B8A6)],` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1178 | `const Color(0xFFF87171),` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1179 | `const Color(0xFFDC2626),` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1185 | `color: Colors.grey.withValues(alpha: 0.1),` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1192 | `const Color(0xFF2563EB),` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1233 | `style: const TextStyle(fontSize: 12, color: Colors.grey)),` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 78 | `colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 91 | `color: Colors.grey[100],` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 120 | `color: Colors.grey,` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 162 | `color: Colors.blue,` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 176 | `color: Colors.green,` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 193 | `color: Colors.orange,` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 210 | `color: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 237 | `colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 367 | `color: Colors.blue.withAlpha(25),` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 370 | `child: const Icon(Icons.location_on, color: Colors.blue, size: 32),` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 387 | `style: TextStyle(color: Colors.grey[600]),` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 409 | `leading: Icon(icon, color: isActive ? const Color(0xFF6366F1) : Colors.grey[600]),` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 413 | `color: isActive ? const Color(0xFF6366F1) : Colors.grey[800],` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 417 | `tileColor: isActive ? const Color(0xFF6366F1).withAlpha(25) : null,` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 428 | `color: isSelected ? const Color(0xFF6366F1) : Colors.grey[700],` | AppColors |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 433 | `tileColor: isSelected ? const Color(0xFF6366F1).withAlpha(25) : null,` | AppColors |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 21 | `static const Color sageGreen = Color(0xFF10B981);` | AppColors |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 22 | `static const Color tealAqua = Color(0xFF14B8A6);` | AppColors |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 23 | `static const Color warmYellow = Color(0xFFFCD34D);` | AppColors |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 24 | `static const Color softCoral = Color(0xFFF87171);` | AppColors |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 25 | `static const Color navyBlue = Color(0xFF1E3A8A);` | AppColors |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 91 | `color: Colors.grey[50],` | AppColors |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 131 | `backgroundColor: Colors.grey[100],` | AppColors |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 317 | `: [softCoral, Colors.deepOrange],` | AppColors |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 395 | `color: Colors.grey[600],` | AppColors |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 463 | `color: Colors.grey[300]!,` | AppColors |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 602 | `color: Colors.grey[300]!,` | AppColors |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 798 | `color: Colors.grey[600],` | AppColors |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 896 | `color: Colors.grey[300]!,` | AppColors |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 941 | `Icon(icon, size: 48, color: Colors.grey[400]),` | AppColors |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 945 | `style: TextStyle(color: Colors.grey[600]),` | AppColors |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 24 | `static const Color sageGreen = Color(0xFF10B981);` | AppColors |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 25 | `static const Color tealAqua = Color(0xFF14B8A6);` | AppColors |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 63 | `backgroundColor: Colors.grey[50],` | AppColors |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 69 | `colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],` | AppColors |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 146 | `color: Colors.grey,` | AppColors |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 173 | `prefixIcon: const Icon(Icons.search, color: Colors.grey),` | AppColors |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 176 | `icon: const Icon(Icons.clear, color: Colors.grey),` | AppColors |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 186 | `fillColor: Colors.grey[100],` | AppColors |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 475 | `Icon(Icons.badge, size: 14, color: Colors.grey[600]),` | AppColors |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 481 | `color: Colors.grey[600],` | AppColors |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 490 | `Icon(Icons.access_time, size: 14, color: Colors.grey[600]),` | AppColors |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 496 | `color: Colors.grey[600],` | AppColors |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 594 | `color: Colors.grey[100],` | AppColors |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 600 | `color: Colors.grey[400],` | AppColors |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 609 | `color: Colors.grey[700],` | AppColors |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 617 | `color: Colors.grey[600],` | AppColors |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 631 | `Icon(Icons.search_off, size: 60, color: Colors.grey[400]),` | AppColors |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 638 | `color: Colors.grey[700],` | AppColors |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 646 | `color: Colors.grey[600],` | AppColors |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 147 | `Icon(Icons.info_outline, color: Colors.blue.shade600),` | AppColors |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 224 | `color: Colors.grey.shade100,` | AppColors |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 226 | `border: Border.all(color: Colors.grey.shade300),` | AppColors |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 249 | `valueColor: Colors.orange,` | AppColors |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 273 | `color: Colors.orange.shade800,` | AppColors |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 322 | `Icon(Icons.error_outline, color: Colors.red.shade700),` | AppColors |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 349 | `style: TextStyle(fontSize: 13, color: Colors.grey.shade600),` | AppColors |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 529 | `color: Colors.red,` | AppColors |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 581 | `..color = const Color(0xFFD0FD3E)` | AppColors |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 587 | `..color = const Color(0xFFD0FD3E)` | AppColors |
| spring_health_studio/lib/widgets/document_send_dialog.dart | 62 | `backgroundColor: const Color(0xFF25D366),` | AppColors |
| spring_health_studio/lib/widgets/recent_members_card.dart | 27 | `Icon(Icons.people, color: Colors.purple[700]),` | AppColors |
| spring_health_studio/lib/widgets/recent_members_card.dart | 45 | `style: TextStyle(color: Colors.grey),` | AppColors |
| spring_health_studio/lib/widgets/recent_members_card.dart | 67 | `? Colors.green.withValues(alpha: 0.2)` | AppColors |
| spring_health_studio/lib/widgets/recent_members_card.dart | 68 | `: Colors.red.withValues(alpha: 0.2),` | AppColors |
| spring_health_studio/lib/widgets/recent_members_card.dart | 73 | `color: member.isActive ? Colors.green : Colors.red,` | AppColors |
| spring_health_studio/lib/widgets/recent_members_card.dart | 94 | `color: Colors.grey[600],` | AppColors |
| spring_health_studio/lib/widgets/recent_members_card.dart | 104 | `color: Colors.grey[500],` | AppColors |
| spring_health_studio/lib/widgets/photo_picker_widget.dart | 69 | `color: Colors.grey.shade300,` | AppColors |
| spring_health_studio/lib/widgets/photo_picker_widget.dart | 101 | `color: Colors.red),` | AppColors |
| spring_health_studio/lib/widgets/photo_picker_widget.dart | 103 | `style: TextStyle(color: Colors.red)),` | AppColors |
| spring_health_studio/lib/widgets/photo_picker_widget.dart | 142 | `backgroundColor: Colors.red,` | AppColors |
| spring_health_studio/lib/widgets/photo_picker_widget.dart | 207 | `color: _isPicking ? Colors.grey : widget.accentColor,` | AppColors |
| spring_health_studio/lib/widgets/quick_action_card.dart | 78 | `color: _gradientColors.first.withValues(alpha: 0.25),` | AppColors |
| spring_health_studio/lib/widgets/quick_action_card.dart | 100 | `color: _gradientColors.first.withValues(alpha: 0.4),` | AppColors |
| spring_health_studio/lib/widgets/payment_mode_selector.dart | 33 | `Colors.green,` | AppColors |
| spring_health_studio/lib/widgets/payment_mode_selector.dart | 42 | `Colors.blue,` | AppColors |
| spring_health_studio/lib/widgets/payment_mode_selector.dart | 51 | `Colors.orange,` | AppColors |
| spring_health_studio/lib/widgets/payment_mode_selector.dart | 74 | `color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey[100],` | AppColors |
| spring_health_studio/lib/widgets/payment_mode_selector.dart | 76 | `color: isSelected ? color : Colors.grey[300]!,` | AppColors |
| spring_health_studio/lib/widgets/payment_mode_selector.dart | 85 | `color: isSelected ? color : Colors.grey[600],` | AppColors |
| spring_health_studio/lib/widgets/payment_mode_selector.dart | 94 | `color: isSelected ? color : Colors.grey[700],` | AppColors |
| spring_health_studio/lib/widgets/custom_dropdown.dart | 32 | `fillColor: Colors.grey[50],` | AppColors |
| spring_health_studio/lib/widgets/pdf_preview_dialog.dart | 64 | `backgroundColor: Colors.green,` | AppColors |

### Member App Color Violations
| File | Line | Hardcoded Value | Should Be |
|---|---|---|---|
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 291 | `Colors.amber,` | AppColors |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 609 | `color: Colors.amber,` | AppColors |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 17 | `_Rank('E',   Color(0xFF9E9E9E), 0),` | AppColors |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 18 | `_Rank('D',   Color(0xFF66BB6A), 500),` | AppColors |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 19 | `_Rank('C',   Color(0xFF29B6F6), 1500),` | AppColors |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 20 | `_Rank('B',   Color(0xFFAB47BC), 3500),` | AppColors |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 21 | `_Rank('A',   Color(0xFFFFCA28), 7000),` | AppColors |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 22 | `_Rank('S',   Color(0xFFFF7043), 13000),` | AppColors |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 23 | `_Rank('SS',  Color(0xFFFF1744), 25000),` | AppColors |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 24 | `_Rank('SSS', Color(0xFFD500F9), 50000),` | AppColors |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 342 | `? [const Color(0xFFFFD700).withValues(alpha: 0.2), const Color(0xFFFF8C00).withValues(alpha: 0.1)]` | AppColors |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 347 | `color: isComplete ? const Color(0xFFFFD700) : accentColor.withValues(alpha: 0.4),` | AppColors |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 678 | `_StatChip(label: 'XP', value: '${record.totalXpEarned}', color: const Color(0xFFFFD700)),` | AppColors |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 852 | `? const Color(0xFFFFD700)` | AppColors |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 279 | `color: Colors.amber, size: 28)` | AppColors |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 299 | `color: const Color(0xFFC0C0C0), // silver` | AppColors |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 311 | `color: Colors.amber,` | AppColors |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 323 | `color: const Color(0xFFCD7F32), // bronze` | AppColors |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 483 | `size: 10, color: Colors.amber),` | AppColors |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 487 | `color: Colors.amber,` | AppColors |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 706 | `size: 10, color: Colors.amber),` | AppColors |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 710 | `color: Colors.amber,` | AppColors |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 264 | `color: isExpired ? Colors.red : Colors.orange,` | AppColors |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 272 | `color: isExpired ? Colors.red : Colors.orange,` | AppColors |
| spring_health_member_app/lib/screens/trainers/trainer_feedback_screen.dart | 77 | `backgroundColor: Colors.red),` | AppColors |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 21 | `if (s.contains('zumba') \|\| s.contains('dance')) return const Color(0xFFFF4081);` | AppColors |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 22 | `if (s.contains('cross') \|\| s.contains('hiit')) return const Color(0xFFFF5252);` | AppColors |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 28 | `case 'breakfast':   return Colors.amber;` | AppColors |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 32 | `case 'post-workout':return const Color(0xFFAB47BC);` | AppColors |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 33 | `case 'snack':       return const Color(0xFFFF4081);` | AppColors |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 55 | `case DietGoal.bulking:     return const Color(0xFF42A5F5);` | AppColors |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 56 | `case DietGoal.cutting:     return const Color(0xFFFF5252);` | AppColors |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 455 | `color: const Color(0xFF25D366),` | AppColors |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 738 | `_macro('🌾', meal.carbs!, 'carbs', Colors.amber),` | AppColors |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 982 | `color: Colors.red.withValues(alpha: 0.15),` | AppColors |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 985 | `color: Colors.red.withValues(alpha: 0.4)),` | AppColors |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 989 | `size: 12, color: Colors.redAccent),` | AppColors |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 993 | `color: Colors.redAccent,` | AppColors |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1374 | `backgroundColor: const Color(0xFF25D366),` | AppColors |
| spring_health_member_app/lib/screens/fitness/health_permission_screen.dart | 101 | `_PermRow(icon: Icons.favorite_rounded, color: Colors.red, label: 'Heart Rate (BPM)'),` | AppColors |
| spring_health_member_app/lib/screens/fitness/widgets/workout_card_widget.dart | 37 | `return Colors.purple;` | AppColors |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 185 | `if (t.contains('power') \|\| t.contains('strength')) return Colors.purpleAccent;` | AppColors |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 187 | `if (t.contains('yoga')) return Colors.blueAccent;` | AppColors |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 568 | `const Icon(Icons.favorite_rounded, size: 16, color: Colors.redAccent),` | AppColors |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 804 | `if (bmi < 18.5) return Colors.blueAccent;` | AppColors |
| spring_health_member_app/lib/screens/home/home_screen.dart | 518 | `color: Colors.amber,` | AppColors |
| spring_health_member_app/lib/screens/home/home_screen.dart | 792 | `Colors.deepOrange.withValues(alpha: 0.08),` | AppColors |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 207 | `color: Colors.redAccent,` | AppColors |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 19 | `return Colors.red;` | AppColors |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 121 | `backgroundColor: const Color(0xFF1A1F3A),` | AppColors |
| spring_health_member_app/lib/screens/notifications/widgets/notification_tile.dart | 24 | `NotificationType.announcement => const Color(0xFF7C83FD),` | AppColors |
| spring_health_member_app/lib/screens/notifications/widgets/notification_tile.dart | 48 | `color: Colors.red.withValues(alpha: 0.12),` | AppColors |
| spring_health_member_app/lib/screens/notifications/widgets/notification_tile.dart | 52 | `color: Colors.redAccent, size: 26),` | AppColors |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 351 | `Colors.purpleAccent,` | AppColors |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 618 | `Colors.redAccent,` | AppColors |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 865 | `case 'arms':       return Colors.purpleAccent;` | AppColors |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 866 | `case 'core':       return Colors.amber;` | AppColors |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 867 | `case 'cardio':     return Colors.redAccent;` | AppColors |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 144 | `color: Colors.redAccent.withValues(alpha: 0.1),` | AppColors |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 147 | `color: Colors.redAccent.withValues(alpha: 0.2),` | AppColors |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 154 | `color: Colors.redAccent, size: 16),` | AppColors |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 159 | `color: Colors.redAccent,` | AppColors |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 336 | `color: Colors.amber.withValues(alpha: 0.1),` | AppColors |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 339 | `color: Colors.amber.withValues(alpha: 0.3),` | AppColors |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 346 | `size: 12, color: Colors.amber),` | AppColors |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 351 | `color: Colors.amber,` | AppColors |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 503 | `case 'arms':       return Colors.purpleAccent;` | AppColors |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 504 | `case 'core':       return Colors.amber;` | AppColors |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 505 | `case 'cardio':     return Colors.redAccent;` | AppColors |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 291 | `Colors.redAccent,` | AppColors |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 1049 | `Colors.redAccent,` | AppColors |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 1090 | `color: Colors.amber,` | AppColors |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 1340 | `return Colors.purpleAccent;` | AppColors |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 1342 | `return Colors.amber;` | AppColors |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 1344 | `return Colors.redAccent;` | AppColors |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 159 | `color: Colors.purpleAccent,` | AppColors |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 349 | `color: Colors.amber,` | AppColors |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 595 | `_legendDot(Colors.amber.withValues(alpha: 0.2),` | AppColors |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 596 | `Colors.amber, 'Today'),` | AppColors |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 637 | `? Colors.amber.withValues(alpha: 0.2)` | AppColors |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 645 | `? Colors.amber` | AppColors |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 663 | `? Colors.amber` | AppColors |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 734 | `'Early Bird': Colors.purpleAccent,` | AppColors |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 735 | `'Morning': Colors.amber,` | AppColors |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 738 | `'Night Owl': Colors.blueAccent,` | AppColors |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 1163 | `case 'Early Bird':  return Colors.purpleAccent;` | AppColors |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 1164 | `case 'Morning':     return Colors.amber;` | AppColors |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 1167 | `case 'Night Owl':   return Colors.blueAccent;` | AppColors |
| spring_health_member_app/lib/screens/splash/splash_screen.dart | 63 | `Color(0xFF1A2E05), // Very dark lime glow` | AppColors |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 559 | `color: Colors.amber.withValues(alpha: 0.08),` | AppColors |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 562 | `color: Colors.amber.withValues(alpha: 0.4),` | AppColors |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 573 | `color: Colors.amber,` | AppColors |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 587 | `color: Colors.amber.withValues(alpha: 0.4),` | AppColors |


---

## 3. Typography Compliance Report
### Studio Typography Violations
| File | Line | Hardcoded Value | Should Be |
|---|---|---|---|
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 94 | `fontSize: 22,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 95 | `fontWeight: FontWeight.w800)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 99 | `color: Colors.white70, fontSize: 13)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 117 | `fontWeight: FontWeight.w700, fontSize: 13),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 295 | `color: Colors.grey.shade600, fontSize: 11)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 299 | `fontSize: 18, fontWeight: FontWeight.w800)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 360 | `fontWeight: active` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 363 | `fontSize: 13)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 425 | `color: Colors.grey.shade400, fontSize: 12)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 505 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 506 | `fontSize: entry.rank <= 3 ? 18 : 13),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 510 | `style: const TextStyle(fontWeight: FontWeight.w700)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 515 | `color: Colors.grey.shade500, fontSize: 12)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 525 | `fontWeight: FontWeight.w800,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 527 | `fontSize: 13)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 532 | `color: Colors.grey.shade600, fontSize: 11)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 708 | `style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 739 | `style: const TextStyle(fontSize: 22)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 744 | `fontWeight: isSelected` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 747 | `fontSize: 14)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 907 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 908 | `fontSize: 20),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 918 | `fontSize: 17, fontWeight: FontWeight.w800)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 922 | `color: Colors.grey.shade500, fontSize: 13)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 928 | `color: green, fontWeight: FontWeight.w700)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 980 | `style: const TextStyle(fontSize: 12)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 983 | `fontWeight: FontWeight.w800,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 984 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 1001 | `TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 1010 | `style: const TextStyle(fontSize: 13))),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 1013 | `color: orange, fontWeight: FontWeight.w700)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 111 | `fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 116 | `style: const TextStyle(fontSize: 12)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 320 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 405 | `fontWeight: FontWeight.bold, fontSize: 13),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 429 | `fontSize: 36,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 430 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 475 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 476 | `fontSize: 14),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 529 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 530 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 536 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 655 | `fontSize: 16, fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 686 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 723 | `fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 728 | `fontWeight: FontWeight.w600)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 732 | `const TextStyle(fontSize: 12)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 751 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 752 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 818 | `fontSize: 48,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 819 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 837 | `color: Colors.white70, fontSize: 13),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 855 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 893 | `fontWeight:` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 907 | `fontWeight:` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 909 | `fontSize: 14),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 916 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 942 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 985 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 986 | `fontSize: 13)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 1013 | `fontSize: 18, fontWeight: FontWeight.bold, color: color),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 1018 | `style: const TextStyle(fontSize: 12, color: Colors.grey)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 1056 | `fontSize: 18, fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 1083 | `fontSize: 12, color: Colors.grey.shade600)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 1087 | `fontSize: 14, fontWeight: FontWeight.w500)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 389 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 390 | `fontWeight: FontWeight.w500,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 460 | `style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 490 | `fontSize: 20,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 491 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 157 | `style: TextStyle(fontSize: 16, color: Colors.grey[600]),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 176 | `style: TextStyle(fontSize: 16, color: Colors.grey[600]),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 183 | `style: TextStyle(fontSize: 14, color: Colors.grey[500]),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 239 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 240 | `fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 286 | `fontSize: 24,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 287 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 297 | `fontSize: 24,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 298 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 316 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 317 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 333 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 334 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 348 | `style: TextStyle(fontSize: 12, color: Colors.grey[600]),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 355 | `style: TextStyle(fontSize: 12, color: Colors.grey[600]),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 366 | `style: TextStyle(fontSize: 12, color: Colors.grey[600]),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 378 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 380 | `fontWeight: FontWeight.w500,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 397 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 398 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/trainers/trainer_dashboard_screen.dart | 209 | `style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 135 | `style: const TextStyle(fontSize: 15),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 182 | `style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 189 | `style: TextStyle(fontSize: 12, color: Colors.grey[600]),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 225 | `style: const TextStyle(fontSize: 13, color: Colors.grey),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 230 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 231 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 276 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 277 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 297 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 298 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 304 | `fontSize: 20,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 305 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 321 | `style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 425 | `style: TextStyle(fontSize: 12, color: Colors.orange[700]),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 451 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 452 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 466 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 467 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 122 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 123 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 129 | `fontSize: 13)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 139 | `fontSize: 36,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 140 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 142 | `letterSpacing: 1)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 183 | `fontWeight: FontWeight.w600)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 197 | `Text(emoji, style: const TextStyle(fontSize: 20)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 201 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 202 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 207 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 251 | `fontSize: 18, fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 264 | `fontWeight: FontWeight.w600,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 265 | `fontSize: 12)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 301 | `fontWeight: FontWeight.bold, fontSize: 15)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 306 | `color: Colors.grey.shade600, fontSize: 13)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 369 | `fontWeight: FontWeight.w700,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 370 | `fontSize: 15),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 390 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 391 | `fontSize: 12)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 401 | `color: Colors.grey.shade600, fontSize: 12),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 434 | `fontWeight: FontWeight.bold, fontSize: 13)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 437 | `fontSize: 10, color: Colors.grey.shade600)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 334 | `child: Text('Membership Renewed!', style: TextStyle(fontSize: 20)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 344 | `style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 411 | `style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 418 | `style: TextStyle(fontSize: 12, color: Colors.grey),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 492 | `Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 496 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 497 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 562 | `fontSize: 28,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 563 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 576 | `fontSize: 20,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 577 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 596 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 597 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 613 | `style: TextStyle(fontSize: 12, color: Colors.grey[600]),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 617 | `style: const TextStyle(fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 628 | `style: TextStyle(fontSize: 12, color: Colors.grey[600]),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 633 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 716 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 718 | `fontWeight: FontWeight.w500,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 725 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 726 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 762 | `style: TextStyle(fontSize: 12, color: Colors.grey[700]),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 786 | `style: TextStyle(fontSize: 12, color: Colors.grey),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 792 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 793 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 877 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 878 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 885 | `fontSize: 28,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 886 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 894 | `const Text('Payment Mode', style: TextStyle(fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 950 | `style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 957 | `fontSize: 24,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 958 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 998 | `style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 1020 | `style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 146 | `style: const TextStyle(fontWeight: FontWeight.w600)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 202 | `style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 218 | `style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 220 | `style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 279 | `style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 301 | `subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 396 | `style: const TextStyle(fontSize: 15)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 410 | `style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 414 | `style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 421 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 475 | `style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 556 | `fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 562 | `style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 565 | `style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 584 | `color: Colors.white, fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 660 | `fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 677 | `color: Colors.white.withValues(alpha: 0.9), fontSize: 12),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 697 | `style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 710 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 748 | `style: TextStyle(fontSize: 16, color: Colors.grey)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 813 | `fontWeight: FontWeight.bold, fontSize: 18)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 817 | `color: Colors.grey.shade600, fontSize: 12)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 826 | `fontSize: 11, color: Colors.grey.shade600),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 849 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 850 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 882 | `color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 885 | `color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 905 | `fontSize: 10, fontWeight: FontWeight.bold, color: c)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 930 | `style: TextStyle(fontSize: 16, color: Colors.grey)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 984 | `color: sageGreen, fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 988 | `style: const TextStyle(fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1046 | `style: TextStyle(fontSize: 16, color: Colors.grey)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1098 | `fontWeight: FontWeight.bold, fontSize: 15)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1115 | `fontSize: 11, color: Colors.grey.shade600)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1123 | `fontSize: 11, color: Colors.grey.shade600),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1129 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1154 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1155 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1194 | `style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1199 | `fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1200 | `fontSize: isHighlighted ? 16 : 14,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 285 | `style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 329 | `style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 336 | `style: TextStyle(fontSize: 12, color: Colors.grey[600]),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 549 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 550 | `fontWeight: FontWeight.w500,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 583 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 652 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 653 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 660 | `fontSize: 28,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 661 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 673 | `style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 743 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 744 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 752 | `fontSize: 24,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 753 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 791 | `style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 821 | `fontSize: 20,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 822 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 882 | `style: const TextStyle(fontSize: 13, color: Colors.grey),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 887 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 888 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 118 | `style: const TextStyle(fontSize: 12),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 246 | `style: TextStyle(fontSize: 18, color: Colors.grey[600]),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 270 | `style: TextStyle(fontSize: 18, color: Colors.grey[600]),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 294 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 295 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 357 | `fontSize: 24,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 358 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 376 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 377 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 397 | `fontSize: 9,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 398 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 408 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 420 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 438 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 440 | `fontWeight: FontWeight.w500,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 454 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 456 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 483 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 484 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 307 | `style: TextStyle(fontWeight: FontWeight.w600),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 317 | `style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 366 | `style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 405 | `style: const TextStyle(fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 413 | `style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 426 | `const Text('Total Fee:', style: TextStyle(fontSize: 16)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 430 | `fontSize: 20,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 431 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 486 | `style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 491 | `fontSize: 24,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 492 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 381 | `fontSize: 18, fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 386 | `style: const TextStyle(color: Colors.grey, fontSize: 13),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 405 | `style: TextStyle(fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 426 | `style: TextStyle(fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 479 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 480 | `fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 488 | `color: Colors.white70, fontSize: 14),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 504 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 505 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 547 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 548 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 583 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 584 | `fontWeight: isSelected` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 616 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 617 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 682 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 683 | `fontWeight:` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 734 | `fontSize: 20,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 735 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 742 | `fontSize: 40,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 743 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 792 | `style: TextStyle(fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 797 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 798 | `fontSize: 16),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 819 | `fontSize: 14, fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 828 | `fontSize: 12, color: Colors.grey),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 847 | `color: Colors.white70, fontSize: 12)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 852 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 853 | `fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 925 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 952 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 953 | `fontSize: 16)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 964 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 972 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 984 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 985 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1004 | `fontSize: 9,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1005 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1050 | `fontSize: 16, color: Colors.white70)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1061 | `fontSize: 48,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1062 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1081 | `fontSize: 16, color: Colors.grey.shade600),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1107 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1108 | `fontSize: 20,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1114 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1115 | `fontSize: 16)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1124 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1156 | `fontSize: 16, fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1169 | `color: Colors.white, fontSize: 12)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1186 | `fontSize: 16, color: Colors.grey.shade600),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1213 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1214 | `fontSize: 20,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1220 | `fontWeight: FontWeight.bold, fontSize: 16)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1229 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1238 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1239 | `fontSize: 13),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1255 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1256 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1293 | `style: TextStyle(fontSize: 11, color: Colors.grey.shade600),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1300 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1301 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1331 | `fontSize: 24,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1332 | `fontWeight: pw.FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1336 | `color: PdfColors.white, fontSize: 16)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1394 | `fontSize: 18, fontWeight: pw.FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1411 | `fontSize: 16, fontWeight: pw.FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1441 | `fontSize: 16, fontWeight: pw.FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1469 | `fontSize: 16, fontWeight: pw.FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1503 | `fontSize: 9, color: PdfColors.grey600),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1516 | `fontSize: isHeader ? 11 : 9,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1517 | `fontWeight:` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 149 | `style: TextStyle(fontSize: 18),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 179 | `style: const TextStyle(fontSize: 12),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 290 | `fontSize: 24,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 291 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 299 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 318 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 326 | `fontSize: 36,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 327 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 342 | `fontSize: 24,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 343 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 388 | `fontSize: 24,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 389 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 494 | `fontSize: 24,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 495 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 505 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 513 | `fontSize: 48,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 514 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 529 | `style: TextStyle(color: Colors.white70, fontSize: 14),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 536 | `fontSize: 20,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 537 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 549 | `style: TextStyle(color: Colors.white70, fontSize: 14),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 556 | `fontSize: 20,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 557 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 569 | `style: TextStyle(color: Colors.white70, fontSize: 14),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 576 | `fontSize: 20,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 577 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 605 | `fontWeight: isActive ? FontWeight.bold : FontWeight.normal,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 653 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 654 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 154 | `style: TextStyle(fontSize: 18),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 184 | `style: const TextStyle(fontSize: 12),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 252 | `fontSize: 20,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 253 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 261 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 288 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 297 | `fontSize: 28,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 298 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 313 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 314 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 359 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 360 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 446 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 447 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 560 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 561 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 605 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 606 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 613 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 154 | `style: const TextStyle(fontSize: 24),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 164 | `Text(icon, style: const TextStyle(fontSize: 20)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 244 | `style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 296 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 297 | `fontWeight: FontWeight.w500,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 334 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 335 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 365 | `fontSize: 20,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 366 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 110 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 111 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 177 | `style: TextStyle(fontSize: 18, color: Colors.grey[600]),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 206 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 207 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 214 | `fontSize: 28,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 215 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 266 | `style: const TextStyle(fontSize: 24),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 272 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 273 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 288 | `style: TextStyle(fontSize: 11, color: Colors.grey[600]), // ✅ Smaller font` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 302 | `fontSize: 16, // ✅ Reduced from 18` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 303 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 319 | `fontSize: 9, // ✅ Reduced from 10` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 320 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 344 | `style: const TextStyle(fontSize: 24),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 350 | `style: const TextStyle(fontSize: 18),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 390 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 392 | `fontWeight: FontWeight.w500,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 399 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 400 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 111 | `style: TextStyle(fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 247 | `fontSize: 24,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 248 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 256 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 405 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 406 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 414 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 474 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 515 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 521 | `style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 523 | `subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 629 | `style: TextStyle(fontSize: 15),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 647 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 754 | `style: TextStyle(fontWeight: FontWeight.bold, color: color),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 283 | `style: const TextStyle(color: Colors.red, fontSize: 12)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 302 | `color: _green, fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 312 | `fontWeight: FontWeight.w700)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 317 | `fontSize: 12)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 367 | `TextStyle(color: Colors.grey.shade400, fontSize: 11),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 383 | `TextStyle(color: Colors.grey.shade400, fontSize: 11),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 423 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 424 | `letterSpacing: 1),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 454 | `fontWeight:` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 456 | `fontSize: 13)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 480 | `fontWeight:` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 525 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 526 | `fontWeight: FontWeight.w800,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 527 | `letterSpacing: 1.5)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 573 | `fontWeight: FontWeight.w700,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 577 | `fontSize: 11, color: Colors.grey.shade500)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 618 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 619 | `fontWeight: FontWeight.w600)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 622 | `style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 628 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 629 | `fontSize: 14)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 632 | `style: TextStyle(color: Colors.grey.shade400, fontSize: 12),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 639 | `fontSize: 9,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 640 | `fontWeight: FontWeight.w700,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 641 | `letterSpacing: 1.5)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/notifications_screen.dart | 43 | `style: TextStyle(fontSize: 12, color: Colors.grey),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/notifications_screen.dart | 112 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/notifications_screen.dart | 113 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/notifications/notifications_screen.dart | 120 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 46 | `style: TextStyle(fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 124 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 125 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 191 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 192 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 245 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 246 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 289 | `fontSize: 20,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 290 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 343 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 344 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 358 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 359 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 403 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 404 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 414 | `style: TextStyle(fontSize: 12, color: Colors.grey[600]),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 442 | `style: TextStyle(fontSize: 16, color: Colors.grey[600]),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 483 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 484 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 494 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 624 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 119 | `style: TextStyle(fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 202 | `style: TextStyle(fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 307 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 308 | `fontWeight:` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 362 | `fontWeight: FontWeight.w600,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 363 | `fontSize: 15,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 370 | `fontSize: 12, color: Colors.grey.shade500),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 413 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 415 | `fontWeight: FontWeight.w500),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 421 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 423 | `fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 465 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 466 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 467 | `letterSpacing: 1),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 513 | `fontSize: 18, fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 54 | `style: TextStyle(fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 112 | `style: TextStyle(fontSize: 18, color: Colors.grey)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 147 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 148 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 150 | `letterSpacing: 0.5)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 198 | `fontWeight: FontWeight.bold, fontSize: 16),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 214 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 215 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 224 | `color: Colors.grey.shade600, fontSize: 13)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 232 | `fontSize: 12, color: Colors.grey.shade500)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 236 | `fontSize: 11, color: Colors.grey.shade400)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 332 | `fontSize: 16, fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 354 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 361 | `fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 371 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 381 | `fontSize: 16, fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 422 | `fontWeight: FontWeight.w600,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 427 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 454 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 455 | `fontSize: 18)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 459 | `fontSize: 11)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 482 | `color: color, fontWeight: FontWeight.w600)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 173 | `style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 225 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 226 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 258 | `style: TextStyle(fontSize: 16, color: Colors.grey),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 359 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 360 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 468 | `fontSize: 20,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 469 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 522 | `style: const TextStyle(fontSize: 28)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 526 | `fontSize: 26,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 527 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 532 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 534 | `fontWeight: FontWeight.w500)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 659 | `fontSize: 24,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 660 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 665 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 667 | `fontWeight: FontWeight.w600)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 734 | `fontSize: 22,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 735 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 751 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 752 | `fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 764 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 773 | `fontSize: 36,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 774 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 776 | `letterSpacing: 1),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 836 | `color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 841 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 842 | `fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 856 | `fontSize: 22,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 857 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 906 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 907 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 914 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 917 | `fontWeight: FontWeight.w500),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1021 | `fontSize: 22,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1022 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1110 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1111 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1133 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1134 | `fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1154 | `fontSize: 22,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1155 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1231 | `fontWeight: FontWeight.bold, fontSize: 16)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1233 | `style: const TextStyle(fontSize: 12, color: Colors.grey)),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 118 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 119 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 143 | `fontSize: 28,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 144 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 251 | `fontSize: 24,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 252 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 262 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 270 | `fontSize: 48,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 271 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 286 | `style: TextStyle(color: Colors.white70, fontSize: 14),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 293 | `fontSize: 20,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 294 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 306 | `style: TextStyle(color: Colors.white70, fontSize: 14),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 313 | `fontSize: 20,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 314 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 326 | `style: TextStyle(color: Colors.white70, fontSize: 14),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 333 | `fontSize: 20,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 334 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 352 | `fontSize: 24,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 353 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 380 | `fontSize: 20,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 381 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 414 | `fontWeight: isActive ? FontWeight.bold : FontWeight.normal,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 429 | `fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 430 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 102 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 103 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 338 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 339 | `fontWeight: FontWeight.w500,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 354 | `fontSize: 36,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 355 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 363 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 394 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 402 | `fontSize: 24,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 403 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 446 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 447 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 476 | `style: const TextStyle(fontSize: 10),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 497 | `style: const TextStyle(fontSize: 10),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 586 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 587 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 615 | `style: const TextStyle(fontSize: 10),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 636 | `style: const TextStyle(fontSize: 10),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 713 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 714 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 735 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 736 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 790 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 791 | `fontWeight: FontWeight.w500,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 797 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 832 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 833 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 853 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 867 | `return const Text('Revenue', style: TextStyle(fontWeight: FontWeight.bold));` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 869 | `return const Text('Expenses', style: TextStyle(fontWeight: FontWeight.bold));` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 883 | `style: const TextStyle(fontSize: 10),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 145 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 152 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 153 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 351 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 352 | `fontWeight: FontWeight.w500,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 369 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 370 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 403 | `fontSize: 24,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 404 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 411 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 455 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 457 | `fontSize: 20,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 465 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 466 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 480 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 495 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 513 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 515 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 550 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 551 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 567 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 607 | `fontSize: 20,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 608 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 616 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 636 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 637 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 645 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 154 | `style: TextStyle(fontSize: 15),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 167 | `style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 206 | `fontSize: 24,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 207 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 215 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 216 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 272 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 298 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 299 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 329 | `style: const TextStyle(fontSize: 16),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 349 | `style: TextStyle(fontSize: 13, color: Colors.grey.shade600),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 354 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 355 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 424 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 425 | `fontWeight: FontWeight.w500,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 444 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 445 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 465 | `style: TextStyle(color: Colors.white, fontSize: 16),` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 501 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 502 | `fontWeight: FontWeight.w500,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 509 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 510 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 541 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 542 | `fontWeight: FontWeight.w500,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/auth/login_screen.dart | 182 | `fontSize: 28,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/auth/login_screen.dart | 183 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/auth/login_screen.dart | 185 | `letterSpacing: 1,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/auth/login_screen.dart | 193 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/auth/login_screen.dart | 195 | `fontWeight: FontWeight.w500,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/auth/login_screen.dart | 221 | `fontSize: 24,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/auth/login_screen.dart | 222 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/auth/login_screen.dart | 231 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/auth/login_screen.dart | 324 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/auth/login_screen.dart | 325 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/auth/login_screen.dart | 327 | `letterSpacing: 1,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/auth/login_screen.dart | 363 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/auth/login_screen.dart | 364 | `fontWeight: FontWeight.w600,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/auth/login_screen.dart | 382 | `fontSize: 15,` | Theme/AppTextStyles |
| spring_health_studio/lib/screens/auth/login_screen.dart | 388 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/recent_members_card.dart | 32 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/recent_members_card.dart | 33 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/recent_members_card.dart | 72 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/recent_members_card.dart | 85 | `fontWeight: FontWeight.w600,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/recent_members_card.dart | 86 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/recent_members_card.dart | 93 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/recent_members_card.dart | 103 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/photo_picker_widget.dart | 76 | `style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/photo_picker_widget.dart | 193 | `fontSize: widget.radius * 0.6,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/photo_picker_widget.dart | 194 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/quick_action_card.dart | 121 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/quick_action_card.dart | 122 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/quick_action_card.dart | 154 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/quick_action_card.dart | 155 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/stat_card.dart | 91 | `fontSize: 30,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/stat_card.dart | 92 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/stat_card.dart | 101 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/stat_card.dart | 103 | `fontWeight: FontWeight.w600,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/stat_card.dart | 104 | `letterSpacing: 0.3,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/member_card.dart | 78 | `fontSize: 22,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/member_card.dart | 79 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/member_card.dart | 98 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/member_card.dart | 99 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/member_card.dart | 113 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/member_card.dart | 115 | `fontWeight: FontWeight.w500,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/member_card.dart | 130 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/member_card.dart | 150 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/member_card.dart | 154 | `fontWeight:` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/member_card.dart | 172 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/member_card.dart | 173 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/member_card.dart | 204 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/member_card.dart | 206 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/member_card.dart | 269 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/member_card.dart | 270 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/payment_mode_selector.dart | 21 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/payment_mode_selector.dart | 22 | `fontWeight: FontWeight.w600,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/payment_mode_selector.dart | 92 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/payment_mode_selector.dart | 93 | `fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/pdf_preview_dialog.dart | 30 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_studio/lib/widgets/pdf_preview_dialog.dart | 31 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |

### Member App Typography Violations
| File | Line | Hardcoded Value | Should Be |
|---|---|---|---|
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 154 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 155 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 156 | `letterSpacing: 1,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 177 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 178 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 179 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 215 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 244 | `.copyWith(color: AppColors.gray600, fontSize: 10),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 249 | `.copyWith(color: AppColors.gray600, fontSize: 10),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 320 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 390 | `fontWeight: isCurrent` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 410 | `fontSize: 9,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 411 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 412 | `letterSpacing: 1,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 508 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 509 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 521 | `fontSize: 9,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 522 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 602 | `fontWeight: FontWeight.w600,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 619 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 620 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 695 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 803 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 804 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 185 | `fontWeight: FontWeight.w900,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 186 | `fontSize: rank.name.length > 1 ? 16 : 24,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 200 | `fontSize: 22,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 201 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 208 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 234 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 245 | `style: TextStyle(fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 354 | `style: const TextStyle(fontSize: 28),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 365 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 366 | `fontSize: 15,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 375 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 386 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 387 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 429 | `Text(widget.exercise.emoji, style: const TextStyle(fontSize: 24)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 433 | `style: TextStyle(color: AppColors.textPrimary, fontSize: 18),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 446 | `style: TextStyle(color: AppColors.gray400, fontSize: 13),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 474 | `style: TextStyle(color: AppColors.gray400, fontSize: 11),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 520 | `style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 521 | `Text('+$xp XP', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 563 | `child: Text(widget.exercise.emoji, style: const TextStyle(fontSize: 22)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 570 | `fontWeight: FontWeight.w600,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 577 | `style: TextStyle(color: AppColors.gray400, fontSize: 12),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 581 | `style: TextStyle(color: AppColors.gray400, fontSize: 12),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 604 | `child: const Text('Log', style: TextStyle(fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 658 | `fontWeight: selected ? FontWeight.bold : FontWeight.normal,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 691 | `Text(_selected.emoji, style: const TextStyle(fontSize: 48)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 733 | `color: color, fontWeight: FontWeight.bold, fontSize: 16)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 735 | `style: TextStyle(color: AppColors.gray400, fontSize: 11)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 774 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 123 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 124 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 125 | `letterSpacing: 1.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 161 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 399 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 400 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 415 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 416 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 428 | `fontSize: 9,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 429 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 464 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 465 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 473 | `fontSize: 9,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 488 | `fontSize: 9,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 489 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 556 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 557 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 571 | `letterSpacing: 1.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 572 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 573 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 580 | `fontWeight: FontWeight.w600,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 593 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 594 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 634 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 680 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 699 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 700 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 711 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 731 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 738 | `fontSize: 9,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 759 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 760 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/renewal/renewal_confirmation_screen.dart | 65 | `fontSize: 24,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/renewal/renewal_confirmation_screen.dart | 66 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/renewal/renewal_confirmation_screen.dart | 73 | `color: Colors.white60, fontSize: 14),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/renewal/renewal_confirmation_screen.dart | 98 | `fontWeight: FontWeight.bold, fontSize: 16),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/renewal/renewal_confirmation_screen.dart | 149 | `color: Colors.white54, fontSize: 13)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/renewal/renewal_confirmation_screen.dart | 155 | `fontSize: valueFontSize,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/renewal/renewal_confirmation_screen.dart | 156 | `fontWeight: FontWeight.w600,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 131 | `style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 158 | `color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 188 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 189 | `fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 202 | `TextStyle(color: Colors.white38, fontSize: 12),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 241 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 242 | `fontSize: 20),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 253 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 254 | `fontSize: 16)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 257 | `color: Colors.white60, fontSize: 12)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 273 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 274 | `fontWeight: FontWeight.w500,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 342 | `fontWeight: FontWeight.w600,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 343 | `fontSize: 15)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 346 | `color: Colors.white54, fontSize: 12)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 354 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 355 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 386 | `fontWeight: FontWeight.bold, fontSize: 16),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_feedback_screen.dart | 102 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_feedback_screen.dart | 103 | `fontSize: 16)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_feedback_screen.dart | 106 | `color: Colors.white54, fontSize: 11)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_feedback_screen.dart | 142 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_feedback_screen.dart | 143 | `fontWeight: FontWeight.w600,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_feedback_screen.dart | 144 | `letterSpacing: 0.5),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_feedback_screen.dart | 176 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_feedback_screen.dart | 177 | `fontWeight: isSelected` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_feedback_screen.dart | 217 | `hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_feedback_screen.dart | 271 | `fontWeight: FontWeight.bold, fontSize: 16),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 165 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 166 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 167 | `letterSpacing: 1.5),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 229 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 230 | `fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 305 | `fontSize: 32,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 306 | `fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 348 | `fontSize: 9,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 349 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 350 | `letterSpacing: 1),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 355 | `.copyWith(fontSize: 20)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 370 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 371 | `fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 381 | `color: AppColors.gray400, fontSize: 11)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 432 | `color: color, fontWeight: FontWeight.bold, fontSize: 13)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 435 | `.copyWith(color: AppColors.gray400, fontSize: 10)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 512 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 513 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 514 | `letterSpacing: 1)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 519 | `fontSize: 8,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 520 | `letterSpacing: 0.5)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 567 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 568 | `fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 573 | `fontSize: 8)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 598 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 599 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 600 | `letterSpacing: 1),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 614 | `color: AppColors.gray400, fontSize: 10),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 684 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 685 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 686 | `letterSpacing: 1),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 700 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 701 | `fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 724 | `fontSize: 11)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 754 | `color: AppColors.gray400, fontSize: 11),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 776 | `Text(emoji, style: const TextStyle(fontSize: 10)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 781 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 782 | `fontSize: 11)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 786 | `.copyWith(color: AppColors.gray400, fontSize: 9)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 803 | `const Text('🥗', style: TextStyle(fontSize: 48))` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 826 | `const Text('🏋️', style: TextStyle(fontSize: 72))` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 853 | `color: AppColors.neonLime, letterSpacing: 1)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 875 | `const Text('🤷', style: TextStyle(fontSize: 64)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 935 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 936 | `fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 994 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 995 | `fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1027 | `fontWeight: isSelected` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1030 | `fontSize: 12),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1047 | `color: AppColors.gray400, fontSize: 11),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1121 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1122 | `fontSize: 18),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1137 | `.copyWith(fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1154 | `fontSize: 8,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1155 | `fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1173 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1174 | `fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1193 | `.copyWith(color: sc, fontSize: 18),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1198 | `.copyWith(color: AppColors.gray400, fontSize: 10),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1272 | `fontSize: 36,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1273 | `fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1293 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1294 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1295 | `letterSpacing: 1),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1313 | `color: sc, fontWeight: FontWeight.bold, fontSize: 12),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1365 | `fontWeight: FontWeight.bold, letterSpacing: 1)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1383 | `fontWeight: FontWeight.bold, letterSpacing: 1)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1394 | `color: AppColors.gray400, letterSpacing: 1)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1407 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1408 | `fontSize: 12),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1413 | `.copyWith(color: AppColors.gray400, fontSize: 10)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 262 | `letterSpacing: 3,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 263 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 319 | `fontSize: 24,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 332 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 366 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 367 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 368 | `letterSpacing: 1,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 386 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 387 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 448 | `fontWeight: FontWeight.w600,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 513 | `fontWeight: FontWeight.w600,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 555 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 556 | `letterSpacing: 1,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 713 | `fontWeight: FontWeight.bold, letterSpacing: 1.5)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/main_screen.dart | 324 | `fontSize: 9,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/main_screen.dart | 325 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/main_screen.dart | 344 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/main_screen.dart | 345 | `fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/main_screen.dart | 346 | `letterSpacing: isSelected ? 0.5 : 0,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/main_screen.dart | 400 | `letterSpacing: 4,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/main_screen.dart | 401 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/main_screen.dart | 409 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/main_screen.dart | 448 | `letterSpacing: 1.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/profile/widgets/profile_header_widget.dart | 63 | `fontSize: 36,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/profile/widgets/profile_header_widget.dart | 64 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/profile/widgets/profile_header_widget.dart | 141 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/profile/widgets/profile_header_widget.dart | 142 | `letterSpacing: 1.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/profile/widgets/membership_info_card.dart | 62 | `letterSpacing: 1.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/profile/widgets/membership_info_card.dart | 63 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/profile/widgets/membership_info_card.dart | 193 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/profile/widgets/membership_info_card.dart | 194 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/profile/widgets/membership_info_card.dart | 195 | `letterSpacing: 0.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/profile/widgets/membership_info_card.dart | 235 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/profile/widgets/settings_tile_widget.dart | 63 | `fontWeight: FontWeight.w600,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 346 | `letterSpacing: 1.2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 369 | `fontSize: 40,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 415 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 416 | `letterSpacing: 1.2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 446 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 447 | `letterSpacing: 1.2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 511 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 512 | `letterSpacing: 1.2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 573 | `fontWeight: FontWeight.w600,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 699 | `fontWeight: FontWeight.w600,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 91 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 160 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 173 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 184 | `fontSize: 42,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 220 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 263 | `fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 312 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 347 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 348 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 372 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 386 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 400 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 401 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 443 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 481 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 489 | `fontSize: 38,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 558 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 559 | `letterSpacing: 1.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 585 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 644 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/health_permission_screen.dart | 121 | `style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/widgets/weekly_chart_widget.dart | 40 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/widgets/weekly_chart_widget.dart | 56 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/widgets/weekly_chart_widget.dart | 57 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/widgets/weekly_chart_widget.dart | 90 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/widgets/weekly_chart_widget.dart | 126 | `fontWeight: isToday` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/widgets/stats_card_widget.dart | 75 | `fontSize: 28,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/widgets/fitness_chart_widget.dart | 64 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/widgets/workout_card_widget.dart | 86 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/widgets/workout_card_widget.dart | 118 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 231 | `fontSize: 9,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 232 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 233 | `letterSpacing: 1,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 292 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 293 | `letterSpacing: 1.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 342 | `fontSize: 9,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 343 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 344 | `letterSpacing: 1.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 491 | `fontSize: 48,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 502 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 526 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 527 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 574 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 598 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 698 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 699 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 768 | `style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 841 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 855 | `color: AppColors.gray600, fontSize: 10),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 864 | `color: AppColors.gray600, fontSize: 10),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 103 | `color: AppColors.gray400, letterSpacing: 2))` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 131 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 132 | `letterSpacing: 1.5)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 165 | `color: AppColors.neonLime, letterSpacing: 2)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 207 | `color: AppColors.gray400, fontSize: 10)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 211 | `.copyWith(color: AppColors.gray400, fontSize: 9, letterSpacing: 1.5)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 251 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 252 | `fontWeight: FontWeight.w600)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 276 | `.copyWith(color: AppColors.gray400, letterSpacing: 2)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 300 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 301 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 302 | `letterSpacing: 1),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 409 | `color: AppColors.gray400, fontSize: 10),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 429 | `color: AppColors.gray400, fontSize: 9)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 473 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 474 | `fontSize: 12),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 580 | `.copyWith(fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 596 | `fontSize: 9,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 597 | `fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 685 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 686 | `letterSpacing: 1)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 691 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 692 | `fontSize: 12)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 710 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 711 | `fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 729 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 730 | `fontWeight: FontWeight.w600)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 774 | `fontWeight: FontWeight.bold, letterSpacing: 1.5)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 1151 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 1152 | `letterSpacing: 1.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 1153 | `fontSize: 16)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 1170 | `.copyWith(color: AppColors.gray400, letterSpacing: 2));` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 1211 | `TextStyle(color: color, fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/home_screen.dart | 124 | `color: badge.color, letterSpacing: 2, fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/home_screen.dart | 155 | `color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 18,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/home_screen.dart | 170 | `style: TextStyle(fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/home_screen.dart | 199 | `color: AppColors.gray400, letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/home_screen.dart | 319 | `color: AppColors.gray400, letterSpacing: 1.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/home_screen.dart | 331 | `letterSpacing: 1.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/home_screen.dart | 332 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/home_screen.dart | 406 | `color: level.color, fontSize: 9, fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/home_screen.dart | 423 | `color: level.color, fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/home_screen.dart | 424 | `fontWeight: FontWeight.bold, letterSpacing: 1.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/home_screen.dart | 430 | `color: AppColors.gray400, fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/home_screen.dart | 459 | `color: AppColors.gray400, fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/home_screen.dart | 466 | `color: level.color, fontSize: 10, fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/home_screen.dart | 649 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/home_screen.dart | 651 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/home_screen.dart | 652 | `letterSpacing: 1,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/home_screen.dart | 734 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/home_screen.dart | 735 | `letterSpacing: 1.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/home_screen.dart | 753 | `fontSize: 9,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/home_screen.dart | 754 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/home_screen.dart | 755 | `letterSpacing: 1,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/home_screen.dart | 821 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/home_screen.dart | 822 | `letterSpacing: 1,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/home_screen.dart | 834 | `const Text('🔥', style: TextStyle(fontSize: 28)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 231 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 232 | `letterSpacing: 1.2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 323 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 324 | `letterSpacing: 1.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 502 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 503 | `letterSpacing: 1,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 52 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 153 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 154 | `letterSpacing: 1.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 155 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 181 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 233 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 262 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 263 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 264 | `letterSpacing: 1,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 289 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 311 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 332 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 333 | `letterSpacing: 1.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 70 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 71 | `fontWeight: FontWeight.w800,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 72 | `letterSpacing: 0.2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 80 | `fontSize: 11.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 104 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 105 | `fontWeight: FontWeight.w800,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 147 | `fontSize: 18,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 148 | `fontWeight: FontWeight.w800,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 149 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 180 | `fontWeight: FontWeight.bold, letterSpacing: 2),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 207 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 208 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 221 | `fontSize: 13.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/notifications/widgets/notification_tile.dart | 105 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/notifications/widgets/notification_tile.dart | 106 | `fontWeight: isUnread` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/notifications/widgets/notification_tile.dart | 136 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/notifications/widgets/notification_tile.dart | 144 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/notifications/widgets/notification_tile.dart | 145 | `fontWeight: FontWeight.w600),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/notifications/notifications_screen.dart | 92 | `fontSize: 22,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/notifications/notifications_screen.dart | 93 | `fontWeight: FontWeight.w800,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/notifications/notifications_screen.dart | 94 | `letterSpacing: 0.3,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/notifications/notifications_screen.dart | 121 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/notifications/notifications_screen.dart | 122 | `fontWeight: FontWeight.w700,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/notifications/notifications_screen.dart | 190 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/notifications/notifications_screen.dart | 191 | `fontWeight: FontWeight.w700,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/notifications/notifications_screen.dart | 194 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/notifications/notifications_screen.dart | 195 | `fontWeight: FontWeight.w500,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/notifications/notifications_screen.dart | 257 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/notifications/notifications_screen.dart | 258 | `fontWeight: FontWeight.w600,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/notifications/notifications_screen.dart | 267 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 202 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 203 | `letterSpacing: 1,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 248 | `letterSpacing: 1.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 249 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 266 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 267 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 319 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 320 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 376 | `fontSize: 9,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 432 | `fontWeight: isSelected` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 435 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 465 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 466 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 481 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 567 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 579 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 674 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 675 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 705 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 706 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 728 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 160 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 161 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 184 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 185 | `fontSize: 15,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 193 | `fontSize: 9,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 289 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 296 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 297 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 311 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 312 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 319 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 352 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 353 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 397 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 398 | `letterSpacing: 1,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 425 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 426 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 440 | `fontWeight: FontWeight.w600,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 452 | `fontWeight: FontWeight.w600,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 460 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 461 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 482 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 483 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 205 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 206 | `letterSpacing: 1.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 309 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 310 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 317 | `fontSize: 9,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 396 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 397 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 398 | `letterSpacing: 1,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 407 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 426 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 427 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 476 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 477 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 478 | `letterSpacing: 1,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 508 | `letterSpacing: 1,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 509 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 561 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 620 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 661 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 702 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 703 | `letterSpacing: 1.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 761 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 828 | `fontWeight: isSelected` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 831 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 874 | `fontWeight: FontWeight.w600,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 971 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 1018 | `letterSpacing: 1.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 1076 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 1077 | `fontSize: 16,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 1091 | `letterSpacing: 1.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 1092 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 1136 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 1137 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 1161 | `.copyWith(color: AppColors.gray400, fontSize: 10),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 78 | `letterSpacing: 4,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 88 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 89 | `letterSpacing: 1,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 131 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 132 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 190 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 231 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 50 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 114 | `fontSize: 24,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 115 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 189 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 190 | `letterSpacing: 1.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 220 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 221 | `letterSpacing: 1.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 258 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 296 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 330 | `fontWeight: FontWeight.bold, letterSpacing: 1.5),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 358 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 359 | `fontSize: 13,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 199 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 200 | `letterSpacing: 1.2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 219 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 220 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 308 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 309 | `letterSpacing: 1.2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 340 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 341 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 342 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 368 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 270 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 271 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 389 | `fontSize: 36,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 390 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 420 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 421 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 483 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 484 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 510 | `.copyWith(fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 545 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 546 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 575 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 576 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 667 | `fontWeight:` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 671 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 715 | `.copyWith(color: AppColors.gray400, fontSize: 10),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 768 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 769 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 797 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 838 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 839 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 880 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 881 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 888 | `color: AppColors.gray600, fontSize: 10),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 924 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 991 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 1008 | `fontSize: 9,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 1009 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 1047 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 1071 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 1072 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 178 | `Text(team.emoji, style: const TextStyle(fontSize: 26)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 186 | `color: color, fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 282 | `color: AppColors.gray400, letterSpacing: 2))` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 328 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 329 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 330 | `letterSpacing: 1)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 344 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 345 | `fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 350 | `.copyWith(color: tc, fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 387 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 421 | `style: const TextStyle(fontSize: 26)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 426 | `fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 431 | `.copyWith(color: AppColors.neonLime, fontSize: 20)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 449 | `style: TextStyle(fontSize: 20)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 454 | `.copyWith(color: AppColors.gray400, letterSpacing: 2)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 462 | `style: const TextStyle(fontSize: 26)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 467 | `fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 472 | `color: AppColors.neonOrange, fontSize: 20)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 488 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 489 | `fontSize: 12)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 493 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 494 | `fontSize: 12)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 561 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 562 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 597 | `Text(team.emoji, style: const TextStyle(fontSize: 20)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 602 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 603 | `fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 623 | `.copyWith(color: color, fontSize: 22)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 643 | `.copyWith(color: color, fontSize: 22)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 669 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 670 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 671 | `letterSpacing: 1)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 694 | `const Text('⚔️', style: TextStyle(fontSize: 40)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 719 | `fontWeight: FontWeight.bold, letterSpacing: 1.5)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 765 | `Text(team.emoji, style: const TextStyle(fontSize: 18)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 769 | `color: color, fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 781 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 782 | `fontSize: 12)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 809 | `rankWidget = const Text('🥇', style: TextStyle(fontSize: 18));` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 811 | `rankWidget = const Text('🥈', style: TextStyle(fontSize: 18));` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 813 | `rankWidget = const Text('🥉', style: TextStyle(fontSize: 18));` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 819 | `color: AppColors.gray400, fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 853 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 854 | `fontSize: 14),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 865 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 881 | `fontSize: 9,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 882 | `fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 890 | `color: color, fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 903 | `const Text('⚔️', style: TextStyle(fontSize: 72)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 936 | `TextStyle(color: AppColors.neonLime, letterSpacing: 1)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 1077 | `style: const TextStyle(fontSize: 24)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 1087 | `fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 1122 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 1123 | `fontWeight: FontWeight.bold)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 1135 | `.copyWith(color: _color, fontSize: 40),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 1148 | `labelStyle: TextStyle(color: AppColors.gray400, fontSize: 14),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 1152 | `fontSize: 40),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 1157 | `color: _color, fontWeight: FontWeight.bold),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 1194 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 1195 | `letterSpacing: 1.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 1196 | `fontSize: 16)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/splash/splash_screen.dart | 117 | `letterSpacing: 4,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/splash/splash_screen.dart | 130 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 184 | `letterSpacing: 3,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 185 | `fontWeight: FontWeight.w800,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 255 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 256 | `fontWeight: FontWeight.w800,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 257 | `letterSpacing: 1.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 272 | `fontSize: 12,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 273 | `fontWeight: FontWeight.w700,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 317 | `letterSpacing: 2.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 318 | `fontWeight: FontWeight.w800,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 384 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 385 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 397 | `fontWeight: FontWeight.w800,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 398 | `letterSpacing: 0.4,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 425 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 426 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 499 | `letterSpacing: 2,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 532 | `const Text('⚡', style: TextStyle(fontSize: 16)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 538 | `fontSize: 14,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 539 | `fontWeight: FontWeight.w800,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 540 | `letterSpacing: 1,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 568 | `const Text('🏅', style: TextStyle(fontSize: 14)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 574 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 575 | `fontWeight: FontWeight.w800,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 576 | `letterSpacing: 0.5,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 655 | `Text(emoji, style: const TextStyle(fontSize: 20)),` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 661 | `fontSize: 15,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 662 | `fontWeight: FontWeight.w800,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 669 | `fontSize: 10,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 696 | `fontSize: 11,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/auth/otp_verification_screen.dart | 212 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/auth/otp_verification_screen.dart | 278 | `fontWeight: FontWeight.bold,` | Theme/AppTextStyles |
| spring_health_member_app/lib/screens/auth/otp_verification_screen.dart | 279 | `letterSpacing: 1,` | Theme/AppTextStyles |


---

## 4. Spacing Compliance Report
### Studio Spacing Violations
| File | Line | Hardcoded Value | Should Be |
|---|---|---|---|
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 96 | `SizedBox(height: 2),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 147 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 214 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 224 | `const SizedBox(height: 10),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 237 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 277 | `padding: const EdgeInsets.all(14),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 288 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 296 | `const SizedBox(height: 2),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 331 | `padding: const EdgeInsets.symmetric(horizontal: 16),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 333 | `separatorBuilder: (_, __) => const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 342 | `const EdgeInsets.symmetric(horizontal: 16, vertical: 6),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 406 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 419 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 422 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 496 | `const EdgeInsets.symmetric(horizontal: 14, vertical: 6),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 528 | `const SizedBox(height: 2),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 535 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 547 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 556 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 565 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 574 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 583 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 629 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 725 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 740 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 911 | `const SizedBox(width: 14),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 936 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 939 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 968 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 1002 | `const SizedBox(height: 10),` | AppDimensions |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 1007 | `const SizedBox(width: 6),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 83 | `SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 90 | `padding: EdgeInsets.all(20),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 304 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 346 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 445 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 449 | `margin: const EdgeInsets.symmetric(horizontal: 16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 450 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 469 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 480 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 484 | `padding: const EdgeInsets.symmetric(horizontal: 16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 491 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 497 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 504 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 523 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 533 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 544 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 548 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 559 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 570 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 635 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 642 | `padding: const EdgeInsets.all(8),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 651 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 665 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 683 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 688 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 699 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 709 | `const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 737 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 801 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 833 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 852 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 861 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 871 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 897 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 938 | `const SizedBox(height: 10),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 971 | `padding: const EdgeInsets.symmetric(vertical: 12),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 981 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 996 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 1010 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 1016 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 1026 | `margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 1042 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 1045 | `padding: const EdgeInsets.all(8),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 1053 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 1061 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 1076 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | 1084 | `const SizedBox(height: 2),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 223 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 227 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 239 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 256 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 272 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 289 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 312 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 319 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 323 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 336 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 349 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 361 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 395 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 409 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 413 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 429 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 457 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 466 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 477 | `padding: const EdgeInsets.all(8),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 486 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | 494 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 65 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 114 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 154 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 173 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 178 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 191 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 268 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 303 | `const SizedBox(width: 16),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 323 | `padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 341 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 345 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 350 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 352 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 359 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 363 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 370 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 374 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 385 | `padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 393 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | 410 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_dashboard_screen.dart | 198 | `margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_dashboard_screen.dart | 214 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_dashboard_screen.dart | 220 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_dashboard_screen.dart | 223 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/trainers/trainer_dashboard_screen.dart | 226 | `padding: const EdgeInsets.all(8),` | AppDimensions |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 137 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 139 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 165 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 167 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 179 | `SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 186 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 219 | `padding: const EdgeInsets.symmetric(vertical: 4),` | AppDimensions |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 260 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 269 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 280 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 284 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 286 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 316 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 323 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 355 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 368 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 391 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 411 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 413 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 421 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 432 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 436 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | 478 | `const SizedBox(height: 100),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 45 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 48 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 101 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 108 | `padding: const EdgeInsets.all(10),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 116 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 134 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 144 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 149 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 168 | `const SizedBox(height: 14),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 170 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 179 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 198 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 204 | `const SizedBox(height: 2),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 239 | `padding: const EdgeInsets.all(8),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 248 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 255 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 269 | `const SizedBox(height: 14),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 294 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 298 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 302 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 342 | `padding: const EdgeInsets.all(14),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 353 | `padding: const EdgeInsets.all(8),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 364 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 378 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 396 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 404 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 431 | `const SizedBox(height: 3),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 454 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | 465 | `const SizedBox(width: 14),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 284 | `padding: EdgeInsets.all(24),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 289 | `SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 325 | `padding: const EdgeInsets.all(8),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 332 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 346 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 356 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 381 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 396 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 408 | `SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 415 | `SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 488 | `padding: const EdgeInsets.symmetric(vertical: 4),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 528 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 531 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 533 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 535 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 537 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 550 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 568 | `const SizedBox(width: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 588 | `padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 653 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 671 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 690 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 704 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 721 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 739 | `padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 747 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 749 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 758 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 772 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 776 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 780 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 788 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 812 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 834 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 850 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 864 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 866 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 893 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 895 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 908 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 920 | `if (_paymentMode == 'Mixed') const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 933 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 935 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 947 | `SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 995 | `SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 1010 | `padding: const EdgeInsets.all(8),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 1017 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | 1022 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 81 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 88 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 105 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 199 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 203 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 205 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 216 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 221 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 276 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 280 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 397 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 399 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 408 | `SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 412 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 418 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 470 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 533 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 560 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 563 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 566 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 569 | `padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 581 | `const SizedBox(width: 6),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 589 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 601 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 615 | `padding: const EdgeInsets.symmetric(vertical: 12),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 636 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 641 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 662 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 672 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 681 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 693 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 698 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 746 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 760 | `margin: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 761 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 796 | `padding: const EdgeInsets.all(14),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 806 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 814 | `const SizedBox(height: 2),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 818 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 822 | `const SizedBox(width: 6),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 836 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 855 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 879 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 897 | `padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 928 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 942 | `margin: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 943 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 992 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1031 | `padding: const EdgeInsets.symmetric(vertical: 12),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1044 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1102 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1112 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1116 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1119 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1126 | `const SizedBox(height: 2),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1135 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1150 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1176 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1188 | `padding: const EdgeInsets.symmetric(vertical: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 1191 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 287 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 289 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 312 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 314 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 326 | `SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 333 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 391 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 395 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 411 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 428 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 435 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 452 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 475 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 479 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 497 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 516 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 554 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 570 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 591 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 595 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 612 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 624 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 635 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 639 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 668 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 675 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 702 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 713 | `if (_paymentMode == 'Mixed') const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 722 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 727 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 739 | `SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 760 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 788 | `SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 797 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 808 | `padding: const EdgeInsets.all(8),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 817 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 825 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/add_member_screen.dart | 876 | `padding: const EdgeInsets.symmetric(vertical: 4),` | AppDimensions |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 146 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 167 | `contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),` | AppDimensions |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 174 | `padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 225 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 227 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 243 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 248 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 267 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 272 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 286 | `padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 320 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 345 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 363 | `const SizedBox(width: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 385 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 404 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 412 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 416 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 426 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 434 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 446 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 450 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 470 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 489 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 289 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 293 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 303 | `SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 319 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 333 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 347 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 361 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 368 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 380 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 392 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 410 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 415 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 418 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 438 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 456 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 473 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 476 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 499 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 507 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 524 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | 540 | `const SizedBox(height: 100),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 365 | `padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 383 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 388 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 396 | `padding: const EdgeInsets.all(10),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 417 | `padding: const EdgeInsets.all(10),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 431 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 474 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 483 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 497 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 507 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 537 | `const EdgeInsets.symmetric(horizontal: 16, vertical: 12),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 544 | `SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 551 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 597 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 610 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 709 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 717 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 731 | `SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 738 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 746 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 748 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 774 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 783 | `padding: const EdgeInsets.all(10),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 802 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 809 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 816 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 822 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 844 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 848 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 875 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 883 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 891 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 897 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 902 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 921 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 932 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 942 | `contentPadding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 957 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 988 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 990 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1031 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1051 | `SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1057 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1077 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1087 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1097 | `contentPadding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1119 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1145 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1152 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1161 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1182 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1192 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1204 | `contentPadding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1224 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1244 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1273 | `padding: const EdgeInsets.all(14),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1290 | `const SizedBox(width: 6),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1297 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1320 | `padding: const pw.EdgeInsets.all(20),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1333 | `pw.SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1340 | `pw.SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1360 | `pw.SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1362 | `pw.SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1395 | `pw.SizedBox(height: 10),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1412 | `pw.SizedBox(height: 10),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1442 | `pw.SizedBox(height: 10),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1470 | `pw.SizedBox(height: 10),` | AppDimensions |
| spring_health_studio/lib/screens/reports/reports_screen.dart | 1512 | `padding: const pw.EdgeInsets.all(8),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 146 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 151 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 156 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 212 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 253 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 259 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 282 | `const SizedBox(width: 20),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 295 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 307 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 321 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 336 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 346 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 364 | `const SizedBox(width: 16),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 382 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 392 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 468 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 477 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 490 | `SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 501 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 509 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 518 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 520 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 531 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 551 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 571 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 637 | `padding: const EdgeInsets.all(32),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 642 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | 649 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 151 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 156 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 161 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 214 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 218 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 244 | `const SizedBox(width: 16),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 257 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 270 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 272 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 283 | `SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 307 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 317 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 335 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 353 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 363 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 440 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 450 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 465 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 480 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 498 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 529 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 549 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 556 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 586 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 590 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 597 | `const SizedBox(width: 16),` | AppDimensions |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | 609 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 142 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 146 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 165 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 178 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 201 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 220 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 235 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 239 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 246 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 264 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 302 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 330 | `SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 352 | `padding: const EdgeInsets.all(8),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 361 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | 369 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 98 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 106 | `SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 116 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 174 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 191 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 192 | `margin: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 225 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 260 | `contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // ✅ Reduced padding` | AppDimensions |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 279 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 285 | `const SizedBox(height: 2), // ✅ Reduced spacing` | AppDimensions |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 309 | `const SizedBox(height: 2), // ✅ Reduced spacing` | AppDimensions |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 311 | `padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // ✅ Reduced padding` | AppDimensions |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 346 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 360 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 362 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 364 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 367 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | 395 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 138 | `SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 147 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 153 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 157 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 161 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 165 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 192 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 201 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 221 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 236 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 243 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 252 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 395 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 410 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 429 | `padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 442 | `padding: const EdgeInsets.all(32),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 446 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 464 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 477 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 502 | `margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 508 | `contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 620 | `SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 631 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 633 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 642 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 685 | `padding: EdgeInsets.all(24),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 690 | `SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 719 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 727 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | 729 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 159 | `SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 203 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 220 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 229 | `const SizedBox(height: 10),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 233 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 238 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 248 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 263 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 267 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 281 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 286 | `const SizedBox(height: 10),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 288 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 305 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 331 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 350 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 372 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 389 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 400 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 429 | `const SizedBox(height: 30),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 443 | `padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 468 | `padding: const EdgeInsets.symmetric(vertical: 10),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 517 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 521 | `const SizedBox(width: 6),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 529 | `const SizedBox(height: 14),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 556 | `padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 569 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 598 | `padding: const EdgeInsets.all(14),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 613 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 624 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 630 | `const SizedBox(height: 2),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 635 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_screen.dart | 39 | `SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_screen.dart | 49 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_screen.dart | 58 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_screen.dart | 66 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_screen.dart | 93 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_screen.dart | 97 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_screen.dart | 104 | `const SizedBox(width: 16),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_screen.dart | 116 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_screen.dart | 275 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/notifications/notifications_screen.dart | 298 | `SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 90 | `padding: EdgeInsets.all(24),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 95 | `SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 110 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 120 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 129 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 160 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 175 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 187 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 196 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 231 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 241 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 250 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 284 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 294 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 299 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 337 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 353 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 391 | `contentPadding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 393 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 410 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 430 | `padding: const EdgeInsets.all(40),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 439 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 453 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 472 | `padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 490 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 587 | `SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 596 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | 598 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 131 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 134 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 136 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 138 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 140 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 142 | `const SizedBox(height: 28),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 144 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 196 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 249 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 255 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 257 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 262 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 288 | `padding: const EdgeInsets.symmetric(vertical: 12),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 303 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 326 | `padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 354 | `const SizedBox(width: 14),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 389 | `padding: const EdgeInsets.all(14),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 398 | `padding: const EdgeInsets.all(8),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 405 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 417 | `const SizedBox(height: 2),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 502 | `padding: const EdgeInsets.all(6),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 510 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | 534 | `contentPadding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 110 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 113 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 131 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 185 | `padding: const EdgeInsets.all(14),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 194 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 204 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 219 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 225 | `const SizedBox(height: 10),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 229 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 237 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 244 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 259 | `padding: const EdgeInsets.all(6),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 300 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 305 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 323 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 329 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 333 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 368 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 378 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 382 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 399 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 430 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 470 | `const EdgeInsets.symmetric(horizontal: 12, vertical: 8),` | AppDimensions |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | 479 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 206 | `padding: const EdgeInsets.all(4),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 255 | `SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 292 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 297 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 299 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 303 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 306 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 308 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 310 | `const SizedBox(height: 40),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 326 | `padding: const EdgeInsets.symmetric(horizontal: 20),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 343 | `padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 349 | `padding: const EdgeInsets.all(8),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 369 | `SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 386 | `SizedBox(width: 10),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 389 | `SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 406 | `SizedBox(width: 10),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 409 | `SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 432 | `padding: const EdgeInsets.symmetric(horizontal: 20),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 450 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 456 | `padding: const EdgeInsets.all(10),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 464 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 474 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 486 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 494 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 512 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 523 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 529 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 575 | `padding: const EdgeInsets.symmetric(horizontal: 20),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 634 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 640 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 662 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 681 | `padding: const EdgeInsets.symmetric(horizontal: 20),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 713 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 723 | `padding: const EdgeInsets.all(10),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 731 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 739 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 753 | `SizedBox(width: 4),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 760 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 767 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 778 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 789 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 833 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 837 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 866 | `const EdgeInsets.symmetric(horizontal: 20, vertical: 8),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 888 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 891 | `padding: const EdgeInsets.all(14),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 899 | `const SizedBox(width: 16),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 909 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 923 | `padding: const EdgeInsets.all(8),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1026 | `padding: const EdgeInsets.symmetric(horizontal: 20),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1084 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1089 | `padding: const EdgeInsets.all(14),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1103 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1123 | `padding: const EdgeInsets.all(6),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1159 | `padding: const EdgeInsets.symmetric(horizontal: 20),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1184 | `margin: const EdgeInsets.symmetric(horizontal: 20),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1213 | `const EdgeInsets.symmetric(horizontal: 20, vertical: 8),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1215 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 1235 | `padding: const EdgeInsets.all(8),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 94 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 114 | `padding: EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 134 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 147 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 225 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 234 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 247 | `SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 258 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 266 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 275 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 277 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 288 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 308 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 328 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 348 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 356 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 361 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 365 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 372 | `const SizedBox(width: 20),` | AppDimensions |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | 384 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 90 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 98 | `SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 108 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 157 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 159 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 176 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 181 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 194 | `const SizedBox(width: 16),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 206 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 219 | `const SizedBox(width: 16),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 231 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 236 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 241 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 246 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 312 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 349 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 358 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 373 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 390 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 398 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 435 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 442 | `SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 452 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 575 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 582 | `SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 592 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 724 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 731 | `SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 741 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 759 | `const SizedBox(width: 20),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 782 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 821 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 828 | `SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 838 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 938 | `padding: const EdgeInsets.all(40),` | AppDimensions |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 942 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 95 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 113 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 127 | `padding: const EdgeInsets.all(8),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 138 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 166 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 191 | `contentPadding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 250 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 306 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 327 | `margin: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 328 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 356 | `padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 376 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 398 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 441 | `contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 472 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 476 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 487 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 491 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 504 | `padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 533 | `padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 546 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 558 | `padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 574 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 603 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 612 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 632 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 641 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 148 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 185 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 202 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 211 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 220 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 222 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 256 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 258 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 267 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 281 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 290 | `padding: const EdgeInsets.symmetric(vertical: 14),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 323 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 406 | `margin: const EdgeInsets.symmetric(horizontal: 40),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 407 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 419 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 430 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 432 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 462 | `SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 477 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 491 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 527 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | 535 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/screens/auth/login_screen.dart | 150 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_studio/lib/screens/auth/login_screen.dart | 176 | `const SizedBox(height: 40),` | AppDimensions |
| spring_health_studio/lib/screens/auth/login_screen.dart | 189 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/auth/login_screen.dart | 198 | `const SizedBox(height: 48),` | AppDimensions |
| spring_health_studio/lib/screens/auth/login_screen.dart | 227 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/auth/login_screen.dart | 236 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_studio/lib/screens/auth/login_screen.dart | 255 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_studio/lib/screens/auth/login_screen.dart | 287 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_studio/lib/screens/auth/login_screen.dart | 307 | `padding: const EdgeInsets.symmetric(vertical: 18),` | AppDimensions |
| spring_health_studio/lib/screens/auth/login_screen.dart | 368 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/screens/auth/login_screen.dart | 394 | `contentPadding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/widgets/recent_members_card.dart | 21 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/widgets/recent_members_card.dart | 28 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_studio/lib/widgets/recent_members_card.dart | 38 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/widgets/recent_members_card.dart | 42 | `padding: EdgeInsets.all(20),` | AppDimensions |
| spring_health_studio/lib/widgets/recent_members_card.dart | 61 | `padding: const EdgeInsets.symmetric(vertical: 4),` | AppDimensions |
| spring_health_studio/lib/widgets/recent_members_card.dart | 77 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/widgets/photo_picker_widget.dart | 64 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/widgets/photo_picker_widget.dart | 73 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/widgets/photo_picker_widget.dart | 78 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/widgets/photo_picker_widget.dart | 109 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/widgets/photo_picker_widget.dart | 205 | `padding: const EdgeInsets.all(6),` | AppDimensions |
| spring_health_studio/lib/widgets/quick_action_card.dart | 88 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/widgets/quick_action_card.dart | 94 | `padding: const EdgeInsets.all(14),` | AppDimensions |
| spring_health_studio/lib/widgets/quick_action_card.dart | 112 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/widgets/quick_action_card.dart | 137 | `padding: const EdgeInsets.all(6),` | AppDimensions |
| spring_health_studio/lib/widgets/stat_card.dart | 47 | `padding: const EdgeInsets.all(18),` | AppDimensions |
| spring_health_studio/lib/widgets/stat_card.dart | 57 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_studio/lib/widgets/stat_card.dart | 74 | `padding: const EdgeInsets.all(6),` | AppDimensions |
| spring_health_studio/lib/widgets/stat_card.dart | 87 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_studio/lib/widgets/stat_card.dart | 97 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_studio/lib/widgets/member_card.dart | 27 | `margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),` | AppDimensions |
| spring_health_studio/lib/widgets/member_card.dart | 58 | `padding: const EdgeInsets.all(14),` | AppDimensions |
| spring_health_studio/lib/widgets/member_card.dart | 63 | `padding: const EdgeInsets.all(2),` | AppDimensions |
| spring_health_studio/lib/widgets/member_card.dart | 85 | `const SizedBox(width: 14),` | AppDimensions |
| spring_health_studio/lib/widgets/member_card.dart | 109 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_studio/lib/widgets/member_card.dart | 118 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/widgets/member_card.dart | 126 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_studio/lib/widgets/member_card.dart | 136 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_studio/lib/widgets/member_card.dart | 146 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_studio/lib/widgets/member_card.dart | 159 | `const SizedBox(width: 6),` | AppDimensions |
| spring_health_studio/lib/widgets/member_card.dart | 161 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/widgets/member_card.dart | 182 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_studio/lib/widgets/member_card.dart | 184 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/widgets/member_card.dart | 200 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_studio/lib/widgets/member_card.dart | 219 | `padding: const EdgeInsets.all(8),` | AppDimensions |
| spring_health_studio/lib/widgets/member_card.dart | 240 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_studio/lib/widgets/payment_mode_selector.dart | 25 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_studio/lib/widgets/payment_mode_selector.dart | 36 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/widgets/payment_mode_selector.dart | 45 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_studio/lib/widgets/payment_mode_selector.dart | 72 | `padding: const EdgeInsets.symmetric(vertical: 16),` | AppDimensions |
| spring_health_studio/lib/widgets/payment_mode_selector.dart | 88 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_studio/lib/widgets/pdf_preview_dialog.dart | 21 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_studio/lib/widgets/pdf_preview_dialog.dart | 51 | `const SizedBox(height: 16),` | AppDimensions |

### Member App Spacing Violations
| File | Line | Hardcoded Value | Should Be |
|---|---|---|---|
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 42 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 48 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 52 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 56 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 61 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 63 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 71 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 75 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 83 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 85 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 91 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 100 | `const SizedBox(height: 40),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 117 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 162 | `const SizedBox(width: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 172 | `const SizedBox(height: 2),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 182 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 194 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 220 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 237 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 272 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 279 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 286 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 301 | `padding: const EdgeInsets.symmetric(vertical: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 311 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 335 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 377 | `const SizedBox(width: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 396 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 398 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 469 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 503 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 516 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 538 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 548 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 572 | `padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 594 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 640 | `padding: const EdgeInsets.all(28),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 663 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 670 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 678 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 680 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 700 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 713 | `padding: const EdgeInsets.symmetric(vertical: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 736 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 759 | `const SizedBox(width: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 770 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 798 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 807 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 161 | `const SizedBox(height: 40),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 191 | `const SizedBox(width: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 216 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 227 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 287 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 298 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 338 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 356 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 430 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 469 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 554 | `contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 639 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 668 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 675 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 677 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 682 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 688 | `padding: const EdgeInsets.all(40),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 692 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 723 | `padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 765 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 156 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 176 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 180 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 202 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 226 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 232 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 240 | `padding: const EdgeInsets.symmetric(horizontal: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 258 | `const SizedBox(height: 40),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 274 | `padding: const EdgeInsets.symmetric(horizontal: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 287 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 304 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 316 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 408 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 434 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 478 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 525 | `padding: const EdgeInsets.all(14),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 562 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 588 | `const SizedBox(width: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 613 | `padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 666 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 694 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 704 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/renewal/renewal_confirmation_screen.dart | 43 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_member_app/lib/screens/renewal/renewal_confirmation_screen.dart | 60 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/renewal/renewal_confirmation_screen.dart | 69 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/renewal/renewal_confirmation_screen.dart | 76 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_member_app/lib/screens/renewal/renewal_confirmation_screen.dart | 78 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_member_app/lib/screens/renewal/renewal_confirmation_screen.dart | 111 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/renewal/renewal_confirmation_screen.dart | 143 | `padding: const EdgeInsets.symmetric(vertical: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 139 | `margin: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 170 | `SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 178 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 183 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 191 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 195 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 197 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 217 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 245 | `const SizedBox(width: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 258 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 266 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 296 | `padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 332 | `const SizedBox(width: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 382 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_feedback_screen.dart | 113 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_feedback_screen.dart | 118 | `const SizedBox(height: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_feedback_screen.dart | 120 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_feedback_screen.dart | 122 | `const SizedBox(height: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_feedback_screen.dart | 124 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_feedback_screen.dart | 126 | `const SizedBox(height: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_feedback_screen.dart | 128 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_feedback_screen.dart | 159 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 210 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 216 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 220 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 224 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 233 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 239 | `padding: EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 254 | `const SizedBox(height: 40),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 264 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 328 | `const SizedBox(width: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 337 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 356 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 358 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 374 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 378 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 388 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 390 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 429 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 450 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 459 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 491 | `padding: const EdgeInsets.symmetric(vertical: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 508 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 537 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 580 | `const SizedBox(width: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 587 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 604 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 617 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 632 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 668 | `padding: const EdgeInsets.all(14),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 679 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 691 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 705 | `const SizedBox(height: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 712 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 728 | `const SizedBox(height: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 745 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 749 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 777 | `const SizedBox(width: 3),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 783 | `const SizedBox(width: 2),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 794 | `padding: const EdgeInsets.all(28),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 806 | `const SizedBox(height: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 808 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 829 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 831 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 838 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 846 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 876 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 878 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 923 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 958 | `contentPadding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 969 | `padding: const EdgeInsets.symmetric(horizontal: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 977 | `margin: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 979 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 990 | `SizedBox(width: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1008 | `margin: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1010 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1042 | `const EdgeInsets.symmetric(horizontal: 16, vertical: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1061 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1069 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1093 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1127 | `const SizedBox(width: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1143 | `const SizedBox(width: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1145 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1159 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1162 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1177 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1200 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1234 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1249 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1278 | `const SizedBox(height: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1283 | `const EdgeInsets.symmetric(horizontal: 12, vertical: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1298 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1301 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1304 | `const EdgeInsets.symmetric(horizontal: 12, vertical: 5),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1316 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1320 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1348 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1360 | `padding: const EdgeInsets.symmetric(vertical: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1368 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1378 | `padding: const EdgeInsets.symmetric(vertical: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1387 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 1410 | `const SizedBox(height: 2),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 48 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 54 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 59 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 69 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 81 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 93 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 105 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 118 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 123 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 135 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 145 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 150 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 166 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 173 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 181 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 185 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 192 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 205 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 218 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 232 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 237 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 244 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 252 | `const SizedBox(height: 40),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 266 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 276 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 289 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 324 | `const SizedBox(width: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 335 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 347 | `const EdgeInsets.symmetric(horizontal: 10, vertical: 5),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 381 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 390 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 415 | `padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 440 | `const SizedBox(width: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 488 | `padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 505 | `const SizedBox(width: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 540 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 550 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 584 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 669 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 681 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 684 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 688 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 691 | `const SizedBox(height: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 694 | `const SizedBox(height: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 696 | `const SizedBox(height: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 699 | `const SizedBox(height: 28),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 709 | `padding: const EdgeInsets.symmetric(vertical: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 726 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/main_screen.dart | 244 | `padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/main_screen.dart | 275 | `padding: const EdgeInsets.symmetric(vertical: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/main_screen.dart | 311 | `padding: const EdgeInsets.all(3),` | AppDimensions |
| spring_health_member_app/lib/screens/main_screen.dart | 339 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/main_screen.dart | 395 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/main_screen.dart | 404 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/main_screen.dart | 423 | `padding: const EdgeInsets.all(32),` | AppDimensions |
| spring_health_member_app/lib/screens/main_screen.dart | 443 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/main_screen.dart | 451 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/main_screen.dart | 457 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_member_app/lib/screens/main_screen.dart | 465 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/main_screen.dart | 497 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/main_screen.dart | 501 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/main_screen.dart | 505 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/main_screen.dart | 513 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/profile/widgets/profile_header_widget.dart | 19 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/widgets/profile_header_widget.dart | 78 | `padding: const EdgeInsets.all(8),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/widgets/profile_header_widget.dart | 97 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/widgets/profile_header_widget.dart | 105 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/widgets/profile_header_widget.dart | 116 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/widgets/profile_header_widget.dart | 125 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/widgets/profile_header_widget.dart | 136 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/widgets/membership_info_card.dart | 18 | `margin: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/widgets/membership_info_card.dart | 19 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/widgets/membership_info_card.dart | 42 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/widgets/membership_info_card.dart | 53 | `const SizedBox(width: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/widgets/membership_info_card.dart | 66 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/widgets/membership_info_card.dart | 81 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/widgets/membership_info_card.dart | 89 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/widgets/membership_info_card.dart | 116 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/widgets/membership_info_card.dart | 171 | `padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/widgets/membership_info_card.dart | 188 | `const SizedBox(width: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/widgets/membership_info_card.dart | 219 | `const SizedBox(width: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/widgets/membership_info_card.dart | 228 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/widgets/settings_tile_widget.dart | 33 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/profile/widgets/settings_tile_widget.dart | 41 | `padding: const EdgeInsets.all(10),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/widgets/settings_tile_widget.dart | 53 | `const SizedBox(width: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/widgets/settings_tile_widget.dart | 67 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 202 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 206 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 208 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 210 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 212 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 223 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 277 | `padding: const EdgeInsets.all(6),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 321 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 330 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 335 | `const EdgeInsets.symmetric(horizontal: 16, vertical: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 350 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 400 | `const EdgeInsets.symmetric(horizontal: 20, vertical: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 410 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 428 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 442 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 452 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 455 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 458 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 465 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 472 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 494 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 507 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 517 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 520 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 530 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 558 | `const SizedBox(width: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 568 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 596 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 606 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 616 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 634 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 644 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 679 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 691 | `const SizedBox(width: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 703 | `const SizedBox(height: 2),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 116 | `const SliverToBoxAdapter(child: SizedBox(height: 24)),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 133 | `margin: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 134 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 164 | `padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 179 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 187 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 189 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 197 | `const SizedBox(width: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 215 | `const SizedBox(width: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 230 | `padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 234 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 236 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 249 | `padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 278 | `margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 279 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 303 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 315 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 335 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 337 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 356 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 358 | `const SizedBox(height: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 367 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 381 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 395 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 431 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 455 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 462 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 467 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 484 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 495 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 518 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 520 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 550 | `padding: const EdgeInsets.symmetric(vertical: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 573 | `padding: const EdgeInsets.symmetric(vertical: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 639 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 658 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 661 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 688 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 691 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 707 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | 710 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/health_permission_screen.dart | 53 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/health_permission_screen.dart | 64 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/health_permission_screen.dart | 80 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/health_permission_screen.dart | 87 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/health_permission_screen.dart | 95 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/health_permission_screen.dart | 104 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/health_permission_screen.dart | 113 | `padding: const EdgeInsets.symmetric(vertical: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/health_permission_screen.dart | 117 | `? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/health_permission_screen.dart | 126 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/health_permission_screen.dart | 148 | `padding: const EdgeInsets.symmetric(vertical: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/health_permission_screen.dart | 152 | `padding: const EdgeInsets.all(8),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/health_permission_screen.dart | 156 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/widgets/weekly_chart_widget.dart | 20 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/widgets/weekly_chart_widget.dart | 44 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/widgets/weekly_chart_widget.dart | 63 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/widgets/weekly_chart_widget.dart | 79 | `padding: const EdgeInsets.symmetric(horizontal: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/widgets/weekly_chart_widget.dart | 93 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/widgets/weekly_chart_widget.dart | 117 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/widgets/stats_card_widget.dart | 26 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/widgets/stats_card_widget.dart | 42 | `padding: const EdgeInsets.all(8),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/widgets/stats_card_widget.dart | 53 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/widgets/stats_card_widget.dart | 66 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/widgets/stats_card_widget.dart | 79 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/widgets/stats_card_widget.dart | 94 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/widgets/fitness_chart_widget.dart | 12 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/widgets/fitness_chart_widget.dart | 32 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/widgets/workout_card_widget.dart | 52 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/widgets/workout_card_widget.dart | 65 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/widgets/workout_card_widget.dart | 76 | `const SizedBox(width: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/widgets/workout_card_widget.dart | 89 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/widgets/workout_card_widget.dart | 97 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/widgets/workout_card_widget.dart | 122 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/widgets/workout_card_widget.dart | 130 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 150 | `insetPadding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 210 | `padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 226 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 272 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 299 | `padding: const EdgeInsets.symmetric(vertical: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 306 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 314 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 324 | `const EdgeInsets.symmetric(horizontal: 8, vertical: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 350 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 357 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 363 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 375 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 387 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 400 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 424 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 448 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 454 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 466 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 495 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 510 | `const EdgeInsets.symmetric(horizontal: 12, vertical: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 519 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 535 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 545 | `const SizedBox(width: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 547 | `const SizedBox(width: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 569 | `const SizedBox(width: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 593 | `const SizedBox(width: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 609 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 619 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 624 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 649 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 663 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 687 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 689 | `padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 707 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 730 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 739 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 745 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 752 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 760 | `padding: const EdgeInsets.symmetric(vertical: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 794 | `padding: const EdgeInsets.all(8),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 816 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 825 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 832 | `const SizedBox(width: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 844 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 846 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 851 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 857 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 860 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 87 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 95 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 100 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 106 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 113 | `const SizedBox(height: 90),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 143 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 171 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 202 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 208 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 221 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 223 | `const SizedBox(height: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 241 | `const EdgeInsets.symmetric(horizontal: 10, vertical: 5),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 261 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 282 | `const SizedBox(height: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 310 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 489 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 558 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 576 | `const SizedBox(width: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 585 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 605 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 661 | `const SizedBox(width: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 687 | `const SizedBox(height: 3),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 719 | `padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 753 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 755 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 760 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 766 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 787 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 791 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 959 | `padding: const EdgeInsets.symmetric(horizontal: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 977 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 987 | `padding: const EdgeInsets.all(14),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 999 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 1012 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 1016 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 1021 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 1025 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 1029 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 1036 | `padding: const EdgeInsets.all(14),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 1048 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 1063 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 1067 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 1071 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 1075 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 1083 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 1092 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 1096 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 1118 | `contentPadding: const EdgeInsets.all(14),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 1123 | `const SizedBox(height: 28),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 1156 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 1225 | `contentPadding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 111 | `padding: const EdgeInsets.all(28),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 127 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 141 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 144 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 151 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 159 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 195 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 217 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 222 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 247 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 254 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 259 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 267 | `const SizedBox(height: 28),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 274 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 276 | `const SizedBox(height: 28),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 283 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 285 | `const SizedBox(height: 28),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 290 | `const SizedBox(height: 28),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 295 | `const SizedBox(height: 20), // ✅ FIX 5: breathing room at bottom` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 379 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 412 | `const SizedBox(width: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 435 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 450 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 455 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 631 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 645 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 674 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 701 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 722 | `const SizedBox(width: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 738 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 740 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 761 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 787 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/home/home_screen.dart | 812 | `const SizedBox(width: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 165 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 179 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 196 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 218 | `const SizedBox(height: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 226 | `const SizedBox(width: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 248 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 281 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 286 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 295 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 305 | `padding: const EdgeInsets.symmetric(vertical: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 331 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 355 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 359 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 363 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 399 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 409 | `const SizedBox(width: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 417 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 443 | `padding: const EdgeInsets.all(18),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 463 | `padding: const EdgeInsets.all(8),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 487 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 492 | `const SizedBox(height: 2),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 43 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 61 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 68 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 72 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 100 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 104 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 121 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 123 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 133 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 143 | `padding: const EdgeInsets.symmetric(vertical: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 196 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 236 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 244 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 270 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 285 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 305 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 321 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | 339 | `padding: const EdgeInsets.symmetric(vertical: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 39 | `padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 59 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 75 | `const SizedBox(height: 2),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 86 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 91 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 139 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 142 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 152 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 155 | `const SizedBox(height: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 158 | `const SizedBox(height: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 161 | `const SizedBox(height: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 164 | `const SizedBox(height: 28),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 172 | `padding: const EdgeInsets.symmetric(vertical: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 213 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 215 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/notifications/widgets/notification_tile.dart | 65 | `padding: const EdgeInsets.all(14),` | AppDimensions |
| spring_health_member_app/lib/screens/notifications/widgets/notification_tile.dart | 92 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/notifications/widgets/notification_tile.dart | 129 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/notifications/widgets/notification_tile.dart | 139 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/notifications/notifications_screen.dart | 87 | `const SizedBox(width: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/notifications/notifications_screen.dart | 106 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/notifications/notifications_screen.dart | 172 | `padding: const EdgeInsets.all(4),` | AppDimensions |
| spring_health_member_app/lib/screens/notifications/notifications_screen.dart | 252 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/notifications/notifications_screen.dart | 261 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 166 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 252 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 255 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 284 | `child: SizedBox(height: 100),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 296 | `margin: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 297 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 323 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 366 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 399 | `padding: const EdgeInsets.symmetric(horizontal: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 417 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 469 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 476 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 495 | `padding: const EdgeInsets.symmetric(horizontal: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 531 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 548 | `padding: const EdgeInsets.all(10),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 559 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 573 | `const SizedBox(height: 2),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 592 | `const SizedBox(height: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 602 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 608 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 614 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 625 | `const SizedBox(height: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 631 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 636 | `const SizedBox(width: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 659 | `padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 669 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 696 | `const EdgeInsets.symmetric(horizontal: 8, vertical: 3),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 723 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 743 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 749 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 785 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 791 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 797 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 814 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 828 | `padding: const EdgeInsets.all(40),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 834 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 40 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 46 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 52 | `const SizedBox(height: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 54 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 63 | `const SizedBox(height: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 69 | `const SizedBox(height: 30),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 81 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 106 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 139 | `const SizedBox(height: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 141 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 155 | `const SizedBox(width: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 179 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 214 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 227 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 270 | `padding: const EdgeInsets.all(8),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 281 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 333 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 347 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 365 | `padding: const EdgeInsets.all(14),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 377 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 477 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 486 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 229 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 254 | `const EdgeInsets.symmetric(horizontal: 20, vertical: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 304 | `const SizedBox(height: 3),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 353 | `contentPadding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 386 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 402 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 415 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 444 | `padding: const EdgeInsets.symmetric(horizontal: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 451 | `const SizedBox(width: 28),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 488 | `padding: const EdgeInsets.symmetric(vertical: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 532 | `padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 673 | `contentPadding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 709 | `padding: const EdgeInsets.symmetric(vertical: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 747 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 756 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 764 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 768 | `padding: const EdgeInsets.symmetric(horizontal: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 786 | `contentPadding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 791 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 798 | `padding: const EdgeInsets.symmetric(horizontal: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 809 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 840 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 846 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 926 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 932 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 938 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 957 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 998 | `padding: const EdgeInsets.all(28),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 1013 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 1021 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 1055 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 1057 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 1071 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 1086 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 1095 | `const SizedBox(height: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 1102 | `margin: const EdgeInsets.symmetric(horizontal: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 1103 | `padding: const EdgeInsets.all(10),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 1117 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 1128 | `padding: const EdgeInsets.symmetric(vertical: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 1153 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 28 | `padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),` | AppDimensions |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 32 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 36 | `padding: const EdgeInsets.all(28),` | AppDimensions |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 71 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 82 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 93 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 104 | `const SizedBox(height: 40),` | AppDimensions |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 109 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 135 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 142 | `const SizedBox(height: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 149 | `const SizedBox(height: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 156 | `const SizedBox(height: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 167 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 172 | `const EdgeInsets.symmetric(horizontal: 16, vertical: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 185 | `const SizedBox(width: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 197 | `const SizedBox(height: 40),` | AppDimensions |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 215 | `padding: const EdgeInsets.all(8),` | AppDimensions |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 222 | `const SizedBox(width: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 234 | `const SizedBox(height: 2),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 24 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 34 | `padding: const EdgeInsets.all(8),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 45 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 107 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 120 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 131 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 136 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 178 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 196 | `padding: const EdgeInsets.symmetric(vertical: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 204 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 225 | `padding: const EdgeInsets.symmetric(vertical: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 248 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 273 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 286 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 290 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 299 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 303 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 306 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 309 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 313 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 322 | `padding: const EdgeInsets.symmetric(vertical: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 334 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 364 | `const SizedBox(width: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 366 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 391 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 402 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 405 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 428 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 130 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 133 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 168 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 207 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 226 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 235 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 246 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 255 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 281 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 303 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 312 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 322 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 332 | `padding: const EdgeInsets.symmetric(vertical: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 363 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 386 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 393 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 415 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 422 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 204 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 223 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 228 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 230 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 232 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 234 | `if (_records.isNotEmpty) const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 236 | `const SizedBox(height: 40),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 248 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 274 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 300 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 343 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 365 | `padding: const EdgeInsets.all(18),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 384 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 398 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 404 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 407 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 411 | `const EdgeInsets.symmetric(horizontal: 10, vertical: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 464 | `padding: const EdgeInsets.all(18),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 478 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 489 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 534 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 553 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 556 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 561 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 581 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 589 | `const SizedBox(width: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 594 | `const SizedBox(width: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 711 | `const SizedBox(width: 5),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 749 | `padding: const EdgeInsets.all(18),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 763 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 774 | `const SizedBox(height: 18),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 790 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 831 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 875 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 892 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 932 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 954 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 981 | `const SizedBox(width: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 995 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 997 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 1016 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 1021 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 1028 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 1031 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 1039 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 1042 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 1058 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 1089 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 1105 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 1111 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 1118 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 1138 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 1140 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 119 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 121 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 170 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 179 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 266 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 273 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 276 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 279 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 284 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 287 | `const SizedBox(height: 80),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 303 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 319 | `padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 332 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 334 | `padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 353 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 357 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 364 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 366 | `padding: const EdgeInsets.symmetric(vertical: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 377 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 406 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 422 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 441 | `padding: const EdgeInsets.all(10),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 451 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 463 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 481 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 497 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 533 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 537 | `const EdgeInsets.symmetric(horizontal: 14, vertical: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 583 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 598 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 606 | `const SizedBox(height: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 609 | `const SizedBox(height: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 614 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 631 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 634 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 651 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 655 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 665 | `const SizedBox(height: 2),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 685 | `padding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 695 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 698 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 704 | `const SizedBox(height: 18),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 712 | `padding: const EdgeInsets.symmetric(vertical: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 759 | `padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 766 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 772 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 789 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 799 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 824 | `margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 825 | `padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 836 | `SizedBox(width: 34, child: rankWidget),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 837 | `const SizedBox(width: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 858 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 871 | `const SizedBox(width: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 873 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 904 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 906 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 913 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 930 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 1056 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 1073 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 1078 | `const SizedBox(width: 10),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 1098 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 1101 | `padding: const EdgeInsets.all(12),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 1112 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 1127 | `const SizedBox(height: 14),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 1169 | `contentPadding: const EdgeInsets.all(20),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 1172 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 1199 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/splash/splash_screen.dart | 77 | `padding: const EdgeInsets.all(32),` | AppDimensions |
| spring_health_member_app/lib/screens/splash/splash_screen.dart | 112 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_member_app/lib/screens/splash/splash_screen.dart | 125 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 197 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 213 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 216 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 240 | `padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),` | AppDimensions |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 250 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 264 | `margin: const EdgeInsets.symmetric(horizontal: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 292 | `padding: const EdgeInsets.all(24),` | AppDimensions |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 321 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 326 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 330 | `padding: const EdgeInsets.all(16),` | AppDimensions |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 357 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 361 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 389 | `const SizedBox(width: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 410 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 445 | `padding: const EdgeInsets.all(28),` | AppDimensions |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 493 | `const SizedBox(height: 16),` | AppDimensions |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 508 | `const SizedBox(height: 20),` | AppDimensions |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 513 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 533 | `const SizedBox(width: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 554 | `padding: const EdgeInsets.symmetric(` | AppDimensions |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 569 | `const SizedBox(width: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 592 | `const SizedBox(height: 18),` | AppDimensions |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 601 | `const SizedBox(width: 5),` | AppDimensions |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 627 | `padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 656 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 691 | `const SizedBox(width: 6),` | AppDimensions |
| spring_health_member_app/lib/screens/auth/login_screen.dart | 171 | `padding: const EdgeInsets.symmetric(horizontal: 24.0),` | AppDimensions |
| spring_health_member_app/lib/screens/auth/login_screen.dart | 188 | `const SizedBox(height: 24),` | AppDimensions |
| spring_health_member_app/lib/screens/auth/login_screen.dart | 199 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/auth/login_screen.dart | 218 | `padding: const EdgeInsets.all(32),` | AppDimensions |
| spring_health_member_app/lib/screens/auth/login_screen.dart | 235 | `const SizedBox(height: 12),` | AppDimensions |
| spring_health_member_app/lib/screens/auth/login_screen.dart | 253 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_member_app/lib/screens/auth/otp_verification_screen.dart | 118 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/auth/otp_verification_screen.dart | 137 | `const SizedBox(width: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/auth/otp_verification_screen.dart | 199 | `const SizedBox(height: 8),` | AppDimensions |
| spring_health_member_app/lib/screens/auth/otp_verification_screen.dart | 206 | `const SizedBox(height: 4),` | AppDimensions |
| spring_health_member_app/lib/screens/auth/otp_verification_screen.dart | 216 | `const SizedBox(height: 48),` | AppDimensions |
| spring_health_member_app/lib/screens/auth/otp_verification_screen.dart | 234 | `const SizedBox(height: 32),` | AppDimensions |
| spring_health_member_app/lib/screens/auth/otp_verification_screen.dart | 285 | `const SizedBox(height: 16),` | AppDimensions |


---

## 5. Component Inventory
### Existing Shared Widgets
#### Studio Widgets:
* `spring_health_studio/lib/widgets/document_send_dialog.dart`
* `spring_health_studio/lib/widgets/recent_members_card.dart`
* `spring_health_studio/lib/widgets/photo_picker_widget.dart`
* `spring_health_studio/lib/widgets/quick_action_card.dart`
* `spring_health_studio/lib/widgets/stat_card.dart`
* `spring_health_studio/lib/widgets/member_card.dart`
* `spring_health_studio/lib/widgets/payment_mode_selector.dart`
* `spring_health_studio/lib/widgets/custom_dropdown.dart`
* `spring_health_studio/lib/widgets/pdf_preview_dialog.dart`

#### Member App Widgets:
* `spring_health_member_app/lib/screens/profile/widgets/profile_header_widget.dart`
* `spring_health_member_app/lib/screens/profile/widgets/membership_info_card.dart`
* `spring_health_member_app/lib/screens/profile/widgets/settings_tile_widget.dart`
* `spring_health_member_app/lib/screens/fitness/widgets/weekly_chart_widget.dart`
* `spring_health_member_app/lib/screens/fitness/widgets/stats_card_widget.dart`
* `spring_health_member_app/lib/screens/fitness/widgets/fitness_chart_widget.dart`
* `spring_health_member_app/lib/screens/fitness/widgets/workout_card_widget.dart`
* `spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart`
* `spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart`
* `spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart`
* `spring_health_member_app/lib/screens/notifications/widgets/notification_tile.dart`


### Duplication Opportunities
1.  **SharedEmptyState (Both Apps):** Repeated "No Data Found" centering logic (Icon + Text) should be extracted into a universal empty state widget.
2.  **GlassListTile (Studio App):** The pattern of wrapping a `ListTile` inside a semi-transparent container with a specific border radius is duplicated across member, trainer, and expense lists.
3.  **NeonButton (Member App):** Repeated explicit setups of `ElevatedButton.styleFrom` for the neon lime style. Should be extracted or strictly rely on `AppTheme.elevatedButtonTheme`.

---

## 6. Animation & Motion Inventory
### Studio Animation & Motion
| File | Line | Animation Element |
|---|---|---|
| spring_health_studio/lib/widgets/quick_action_card.dart | 29 | `late AnimationController _animationController;` |
| spring_health_studio/lib/widgets/quick_action_card.dart | 35 | `_animationController = AnimationController(` |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | 4 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | 6 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 38 | `late AnimationController animationController;` |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | 55 | `animationController = AnimationController(` |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | 420 | `return TweenAnimationBuilder(` |
| spring_health_studio/lib/screens/auth/login_screen.dart | 25 | `late AnimationController _floatController;` |
| spring_health_studio/lib/screens/auth/login_screen.dart | 26 | `late AnimationController _fadeController;` |
| spring_health_studio/lib/screens/auth/login_screen.dart | 38 | `_floatController = AnimationController(` |
| spring_health_studio/lib/screens/auth/login_screen.dart | 48 | `_fadeController = AnimationController(` |

### Member App Animation & Motion
| File | Line | Animation Element |
|---|---|---|
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 2 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | 223 | `child: TweenAnimationBuilder<double>(` |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | 2 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 3 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 2 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_member_app/lib/screens/main_screen.dart | 6 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 4 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | 244 | `Hero(` |
| spring_health_member_app/lib/screens/fitness/health_permission_screen.dart | 3 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | 3 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 3 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_member_app/lib/screens/home/home_screen.dart | 3 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_member_app/lib/screens/home/home_screen.dart | 438 | `child: TweenAnimationBuilder<double>(` |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 2 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | 473 | `child: TweenAnimationBuilder<double>(` |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | 2 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_member_app/lib/screens/notifications/widgets/notification_tile.dart | 2 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_member_app/lib/screens/notifications/notifications_screen.dart | 2 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | 2 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | 2 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | 3 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 2 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | 2 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | 2 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | 2 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_member_app/lib/screens/clash/clash_screen.dart | 5 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_member_app/lib/screens/splash/splash_screen.dart | 2 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 3 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 37 | `late final AnimationController _pulseController;` |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | 42 | `_pulseController = AnimationController(` |
| spring_health_member_app/lib/screens/auth/login_screen.dart | 4 | `import 'package:flutter_animate/flutter_animate.dart';` |
| spring_health_member_app/lib/screens/auth/otp_verification_screen.dart | 2 | `import 'package:flutter_animate/flutter_animate.dart';` |


### Missing/Broken Lottie Assets
No `Lottie.asset` files were detected in the codebase during the sweep.

---

## 7. Accessibility Report
*   **Missing Semantics:** Interactive custom containers (e.g. `GestureDetector` acting as buttons) lack `Semantics(label: '...')` across both apps.
*   **Tap Targets:** Action icons in lists (e.g., WhatsApp icon, Edit icon) frequently lack 44x44 padding, relying on the raw `Icon` size (24px).
*   **Contrast Issues (Studio):** The widespread use of `Colors.grey.shade400` and `shade300` for subtitles on white backgrounds fails WCAG AA standards.
*   **Contrast Issues (Member):** Neon Orange (#FF6B35) text on the #18181B background borders on insufficient contrast for smaller font weights. Images are correctly rendered but lack `ExcludeSemantics` where decorative.

---

## 8. Asset & Font Audit
*   **Declared Fonts:** `Poppins` and `Inter` via the `google_fonts` package.
*   **Fonts Verification:** The apps load fonts dynamically via `google_fonts` rather than local asset folders, circumventing local missing font issues.
*   **Assets:** Directories like `assets/images/` exist and valid images are present. No missing image paths that cause instant runtime crashes were found, though Hero transition tags must be managed strictly.

---

## 9. Improvement Suggestions

### Visual Consistency Fixes (Priority Order)
1.  **Global Color Purge:** Perform a global find-and-replace to eliminate all `Colors.*`, `Colors.*.shade*`, and `Color(0x...)` references, replacing them with explicit `AppColors` equivalents.
2.  **Typography Standardization:** Delete all inline `TextStyle(fontSize: ...)` overrides. Bind all `Text` widgets to `Theme.of(context).textTheme` (Studio) or `AppTextStyles` (Member).
3.  **Spacing Grid:** Enforce an 8px layout grid. Replace arbitrary padding like `10`, `12`, `15`, and `20` with `AppDimensions.paddingSmall` (8) and `AppDimensions.padding` (16).

### Component Extraction Plan
1.  Extract `EmptyStateIndicator(icon, message)`
2.  Extract `GlassmorphicCard(child)` for the Studio App to standardize the semi-transparent card look.
3.  Extract `AvatarImage(url, fallback, size)` to handle profile image loading and error states uniformly across screens.

### Animation Quality Improvements
1.  **Studio App Polish:** Introduce `flutter_animate` to the `members_list_screen.dart` and `trainers_list_screen.dart` to stagger list items (`.animate(delay: ...).fadeIn().slideY()`).
2.  **Curves:** Ensure all animations specify standard non-linear easing curves (e.g., `Curves.easeOutCubic`).
3.  **Hero Transitions:** Standardize `Hero` tags on all list-to-detail profile picture transitions in the Studio app to match the Member app.

### Typography Refinements
1.  **Line Heights:** Enforce consistent `height: 1.5` on all body text in the Studio app to improve readability on complex data forms.
2.  **Member Heading Scale:** The Member App's `heading1` (28px) might be too small for high-level empty states; consider a `display` size equivalent to the Studio app.

### Spacing Grid Fixes
1.  Audit `SizedBox(height: X)` across all 1800+ spacing violations and ensure X is always a multiple of 4 (preferably 8). Avoid completely arbitrary values like `height: 13`.

### Neon Dark Theme Polish
1.  **Glow Shadows:** Add `BoxShadow(color: AppColors.neonLime.withValues(alpha: 0.2), blurRadius: 10)` to primary call-to-action buttons to cement the cyber-organic theme.
2.  **Black Text:** Ensure all text overlaid on `neonLime` backgrounds explicitly uses `Colors.black` for legibility.

### Wellness & Balance Theme Polish
1.  **BackdropFilter:** Apply `BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10))` strictly behind the semi-transparent cards to achieve true glassmorphism.
2.  **Elevation Consistency:** Standardize shadows using `AppColors.cardShadow` to prevent visually conflicting shadow depths on varying cards.

---

## 10. Design Debt Score
*   **Spring Health Studio:** 4/10 (Severe fragmentation; extremely heavy reliance on hardcoded `Colors` and `TextStyle` overrides).
*   **Spring Health Member App:** 6.5/10 (Better theme setup, excellent animation baseline, but significant spacing grid breaks).
*   **Overall Recommendation:** A "Design Debt Sprint" is mandatory. No new UI features should be merged until all `Colors.*` and hardcoded `fontSize` values are replaced with Theme equivalents.
