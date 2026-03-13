import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/member_model.dart';
import '../../services/firebase_auth_service.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final MemberModel member;

  const SettingsScreen({
    super.key,
    required this.member,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ✅ Notification toggles
  bool _pushNotifications = true;
  bool _announcementAlerts = true;
  bool _expiryReminders = true;
  bool _checkInConfirmations = true;
  bool _promotionalOffers = false;

  // ✅ App preferences
  bool _biometricLock = false;
  bool _hapticFeedback = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.backgroundBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Member Quick Info
            _buildMemberCard(),
            const SizedBox(height: 24),

            // ✅ Notifications Section
            _buildSectionHeader(
              'NOTIFICATIONS', Icons.notifications_rounded, AppColors.neonLime),
              const SizedBox(height: 12),
              _buildToggleCard(
                'Push Notifications',
                'Receive all app notifications',
                Icons.notifications_active_rounded,
                AppColors.neonLime,
                _pushNotifications,
                (val) => setState(() => _pushNotifications = val),
                isMain: true,
              ),
              const SizedBox(height: 8),
              _buildToggleCard(
                'Announcements',
                'Gym updates and news',
                Icons.campaign_rounded,
                AppColors.neonTeal,
                _announcementAlerts && _pushNotifications,
                (val) => _pushNotifications
                ? setState(() => _announcementAlerts = val)
                : null,
                disabled: !_pushNotifications,
              ),
              const SizedBox(height: 8),
              _buildToggleCard(
                'Expiry Reminders',
                '7 days before membership expires',
                Icons.event_rounded,
                AppColors.neonOrange,
                _expiryReminders && _pushNotifications,
                (val) => _pushNotifications
                ? setState(() => _expiryReminders = val)
                : null,
                disabled: !_pushNotifications,
              ),
              const SizedBox(height: 8),
              _buildToggleCard(
                'Check-in Confirmations',
                'Notify when QR is scanned',
                Icons.qr_code_scanner_rounded,
                AppColors.turquoise,
                _checkInConfirmations && _pushNotifications,
                (val) => _pushNotifications
                ? setState(() => _checkInConfirmations = val)
                : null,
                disabled: !_pushNotifications,
              ),
              const SizedBox(height: 8),
              _buildToggleCard(
                'Offers & Promotions',
                'Special deals and discounts',
                Icons.local_offer_rounded,
                AppColors.gray400,
                _promotionalOffers && _pushNotifications,
                (val) => _pushNotifications
                ? setState(() => _promotionalOffers = val)
                : null,
                disabled: !_pushNotifications,
              ),

              const SizedBox(height: 24),

              // ✅ App Preferences Section
              _buildSectionHeader(
                'APP PREFERENCES', Icons.tune_rounded, AppColors.neonTeal),
                const SizedBox(height: 12),
                _buildToggleCard(
                  'Haptic Feedback',
                  'Vibration on button taps',
                  Icons.vibration_rounded,
                  AppColors.neonTeal,
                  _hapticFeedback,
                  (val) {
                    setState(() => _hapticFeedback = val);
                    if (val) HapticFeedback.lightImpact();
                  },
                ),
                const SizedBox(height: 8),
                _buildToggleCard(
                  'Biometric Lock',
                  'Use fingerprint to open app',
                  Icons.fingerprint_rounded,
                  AppColors.neonLime,
                  _biometricLock,
                  (val) => setState(() => _biometricLock = val),
                ),

                const SizedBox(height: 24),

                // ✅ Account Section
                _buildSectionHeader(
                  'ACCOUNT', Icons.manage_accounts_rounded, AppColors.neonOrange),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    'Member ID',
                    widget.member.id,
                    Icons.badge_rounded,
                    AppColors.neonLime,
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: widget.member.id));
                      _showSnack('Member ID copied to clipboard!');
                    },
                    trailing: Icon(
                      Icons.copy_rounded,
                      size: 16,
                      color: AppColors.gray400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildActionTile(
                    'Phone Number',
                    widget.member.phone,
                    Icons.phone_rounded,
                    AppColors.neonTeal,
                  ),
                  const SizedBox(height: 8),
                  _buildActionTile(
                    'Branch',
                    widget.member.branch.toUpperCase(),
                    Icons.location_on_rounded,
                    AppColors.neonOrange,
                  ),

                  const SizedBox(height: 24),

                  // ✅ About Section
                  _buildSectionHeader('ABOUT', Icons.info_rounded, AppColors.turquoise),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    'App Version',
                    '1.0.0',
                    Icons.system_update_rounded,
                    AppColors.turquoise,
                  ),
                  const SizedBox(height: 8),
                  _buildActionTile(
                    'Privacy Policy',
                    'View our privacy terms',
                    Icons.privacy_tip_rounded,
                    AppColors.gray400,
                    onTap: () => _showComingSoon('Privacy Policy'),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.gray400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildActionTile(
                    'Terms of Service',
                    'Read terms and conditions',
                    Icons.description_rounded,
                    AppColors.gray400,
                    onTap: () => _showComingSoon('Terms of Service'),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.gray400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildActionTile(
                    'Contact Support',
                    'Get help from our team',
                    Icons.headset_mic_rounded,
                    AppColors.neonTeal,
                    onTap: () => _showContactSupport(context),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.gray400,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ✅ Danger Zone
                  _buildSectionHeader(
                    'DANGER ZONE', Icons.warning_rounded, AppColors.error),
                    const SizedBox(height: 12),
                    _buildDangerButton(
                      'Clear App Cache',
                      Icons.cleaning_services_rounded,
                      AppColors.neonOrange,
                      _handleClearCache,
                    ),
                    const SizedBox(height: 8),
                    _buildDangerButton(
                      'Logout',
                      Icons.logout_rounded,
                      AppColors.error,
                      _handleLogout,
                    ),

                    const SizedBox(height: 40),

                    // ✅ Footer
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'SPRING HEALTH',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.neonLime,
                              letterSpacing: 3,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Version 1.0.0 • Built with ❤️',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // WIDGETS
  // ─────────────────────────────────────────────

  Widget _buildMemberCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonLime.withValues(alpha: 0.1),
            AppColors.neonTeal.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neonLime.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.neonLime, width: 2),
              color: AppColors.cardSurface,
            ),
            child: Center(
              child: Text(
                widget.member.name.isNotEmpty
                ? widget.member.name[0].toUpperCase()
                : '?',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.neonLime,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.member.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.member.membershipPlan,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.neonTeal,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.4)),
            ),
            child: Text(
              widget.member.isExpired
              ? 'EXPIRED'
            : widget.member.isExpiringSoon
            ? 'EXPIRING'
            : 'ACTIVE',
            style: TextStyle(
              color: widget.member.isExpired
              ? AppColors.error
              : widget.member.isExpiringSoon
              ? AppColors.neonOrange
              : AppColors.success,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.caption.copyWith(
            color: color,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: color.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool value,
    ValueChanged<bool>? onChanged, {
      bool isMain = false,
      bool disabled = false,
    }) {
    return AnimatedOpacity(
      opacity: disabled ? 0.4 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isMain && value
            ? color.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: value ? 0.15 : 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: value ? color : AppColors.gray600,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: disabled
                      ? AppColors.gray600
                      : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gray400,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: disabled ? null : onChanged,
              activeThumbColor: color,
              activeTrackColor: color.withValues(alpha: 0.3),
              inactiveThumbColor: AppColors.gray600,
              inactiveTrackColor: AppColors.gray800,
            ),
          ],
        ),
      ),
    );
    }

    Widget _buildActionTile(
      String title,
      String subtitle,
      IconData icon,
      Color color, {
        VoidCallback? onTap,
        Widget? trailing = const SizedBox.shrink(),
      }) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray400,
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      );
      }

      Widget _buildDangerButton(
        String label, IconData icon, Color color, VoidCallback onTap) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        }

        // ─────────────────────────────────────────────
        // ACTIONS
        // ─────────────────────────────────────────────

        void _handleClearCache() {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.cardSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: AppColors.neonOrange.withValues(alpha: 0.3)),
              ),
              title: Row(
                children: [
                  Icon(Icons.cleaning_services_rounded,
                       color: AppColors.neonOrange, size: 22),
                       const SizedBox(width: 10),
                       Text('Clear Cache',
                            style: AppTextStyles.heading3
                            .copyWith(color: AppColors.neonOrange)),
                ],
              ),
              content: Text(
                'This will clear temporary files. Your data will not be lost.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child:
                  Text('Cancel', style: TextStyle(color: AppColors.gray400)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSnack('Cache cleared successfully!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonOrange,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('CLEAR'),
                ),
              ],
            ),
          );
        }

        Future<void> _handleLogout() async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.cardSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              title:
              Text('Logout', style: AppTextStyles.heading3),
              content: Text(
                'Are you sure you want to logout?',
                style:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel',
                              style: TextStyle(color: AppColors.gray400)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('LOGOUT'),
                ),
              ],
            ),
          );

          if (confirmed == true && mounted) {
            await FirebaseAuthService().signOut();
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          }
        }

        void _showContactSupport(BuildContext context) {
          showModalBottomSheet(
            context: context,
            backgroundColor: AppColors.cardSurface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.gray600,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Icon(Icons.headset_mic_rounded,
                       color: AppColors.neonTeal, size: 40),
                       const SizedBox(height: 12),
                       Text('Contact Support',
                            style: AppTextStyles.heading3
                            .copyWith(color: AppColors.neonTeal)),
                            const SizedBox(height: 24),
                            _buildContactRow(Icons.location_on_rounded,
                                             'Hanamkonda & Warangal Branches'),
                            const SizedBox(height: 14),
                            _buildContactRow(
                              Icons.access_time_rounded, 'Mon–Sat: 6:00 AM – 10:00 PM'),
                            const SizedBox(height: 14),
                            _buildContactRow(Icons.phone_rounded, '+91 XXXXX XXXXX'),
                            const SizedBox(height: 14),
                            _buildContactRow(
                              Icons.email_rounded, 'support@springhealth.in'),
                            const SizedBox(height: 28),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.neonTeal,
                                  foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text('CLOSE',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                              ),
                            ),
                ],
              ),
            ),
          );
        }

        Widget _buildContactRow(IconData icon, String text) {
          return Row(
            children: [
              Icon(icon, color: AppColors.neonTeal, size: 18),
              const SizedBox(width: 12),
              Text(text,
                   style: AppTextStyles.bodyMedium.copyWith(
                     color: AppColors.white,
                   )),
            ],
          );
        }

        void _showSnack(String msg) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.cardSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }

        void _showComingSoon(String feature) {
          _showSnack('$feature — Coming soon!');
        }
}
