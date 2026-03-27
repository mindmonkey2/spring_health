import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/member_model.dart';
import '../../core/config/app_config.dart';
import '../../services/firebase_auth_service.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final MemberModel member;

  const SettingsScreen({super.key, required this.member});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _storage = FlutterSecureStorage();

  bool pushNotifications = true;
  bool announcementAlerts = true;
  bool expiryReminders = true;
  bool checkInConfirmations = true;
  bool promotionalOffers = false;
  bool biometricLock = false;
  bool hapticFeedback = true;
  bool _loadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final push = await _storage.read(key: 'pref_push');
    final ann = await _storage.read(key: 'pref_announcements');
    final expiry = await _storage.read(key: 'pref_expiry');
    final checkin = await _storage.read(key: 'pref_checkin');
    final promo = await _storage.read(key: 'pref_promo');
    final haptic = await _storage.read(key: 'pref_haptic');
    if (!mounted) return;
    setState(() {
      if (push != null) pushNotifications = push == 'true';
      if (ann != null) announcementAlerts = ann == 'true';
      if (expiry != null) expiryReminders = expiry == 'true';
      if (checkin != null) checkInConfirmations = checkin == 'true';
      if (promo != null) promotionalOffers = promo == 'true';
      if (haptic != null) hapticFeedback = haptic == 'true';
      _loadingPrefs = false;
    });
  }

  Future<void> _savePref(String key, bool value) =>
      _storage.write(key: key, value: value.toString());

  Future<void> _sub(String topic) =>
      FirebaseMessaging.instance.subscribeToTopic(topic);
  Future<void> _unsub(String topic) =>
      FirebaseMessaging.instance.unsubscribeFromTopic(topic);

  Future<void> _handlePushToggle(bool val) async {
    setState(() {
      pushNotifications = val;
      if (!val) {
        announcementAlerts = false;
        expiryReminders = false;
        checkInConfirmations = false;
      }
    });
    await _savePref('pref_push', val);
    if (!val) {
      await _unsub('announcements_all');
      await _unsub('announcements_${widget.member.branch}');
      await _unsub('expiry_reminders_${widget.member.id}');
      await _unsub('checkin_${widget.member.id}');
    }
  }

  Future<void> _handleAnnouncementToggle(bool val) async {
    setState(() => announcementAlerts = val);
    await _savePref('pref_announcements', val);
    if (val) {
      await _sub('announcements_all');
      await _sub('announcements_${widget.member.branch}');
    } else {
      await _unsub('announcements_all');
      await _unsub('announcements_${widget.member.branch}');
    }
  }

  Future<void> _handleExpiryToggle(bool val) async {
    setState(() => expiryReminders = val);
    await _savePref('pref_expiry', val);
    val
        ? await _sub('expiry_reminders_${widget.member.id}')
        : await _unsub('expiry_reminders_${widget.member.id}');
  }

  Future<void> _handleCheckinToggle(bool val) async {
    setState(() => checkInConfirmations = val);
    await _savePref('pref_checkin', val);
    val
        ? await _sub('workout_reminders_${widget.member.id}')
        : await _unsub('workout_reminders_${widget.member.id}');
  }

  Future<void> _handlePromoToggle(bool val) async {
    setState(() => promotionalOffers = val);
    await _savePref('pref_promo', val);
  }

  Future<void> _handleHapticToggle(bool val) async {
    setState(() => hapticFeedback = val);
    await _savePref('pref_haptic', val);
    if (val) HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingPrefs) {
      return Scaffold(
        backgroundColor: AppColors.backgroundBlack,
        body: Center(
          child: const CircularProgressIndicator(color: AppColors.neonLime),
        ),
      );
    }

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
            _buildMemberCard,
            const SizedBox(height: 24),
            _buildSectionHeader(
              'NOTIFICATIONS',
              Icons.notifications_rounded,
              AppColors.neonLime,
            ),
            const SizedBox(height: 12),
            _buildToggle(
              'Push Notifications',
              'Receive all app notifications',
              Icons.notifications_active_rounded,
              AppColors.neonLime,
              pushNotifications,
              _handlePushToggle,
              isMain: true,
            ),
            const SizedBox(height: 8),
            _buildToggle(
              'Announcements',
              'Gym updates and news',
              Icons.campaign_rounded,
              AppColors.neonTeal,
              announcementAlerts && pushNotifications,
              (v) {
                if (pushNotifications) _handleAnnouncementToggle(v);
              },
              disabled: !pushNotifications,
            ),
            const SizedBox(height: 8),
            _buildToggle(
              'Expiry Reminders',
              '7 days before membership expires',
              Icons.event_rounded,
              AppColors.neonOrange,
              expiryReminders && pushNotifications,
              (v) {
                if (pushNotifications) _handleExpiryToggle(v);
              },
              disabled: !pushNotifications,
            ),
            const SizedBox(height: 8),
            _buildToggle(
              'Check-in Confirmations',
              'Notify when QR is scanned',
              Icons.qr_code_scanner_rounded,
              AppColors.turquoise,
              checkInConfirmations && pushNotifications,
              (v) {
                if (pushNotifications) _handleCheckinToggle(v);
              },
              disabled: !pushNotifications,
            ),
            const SizedBox(height: 8),
            _buildToggle(
              'Offers & Promotions',
              'Special deals and discounts',
              Icons.local_offer_rounded,
              AppColors.gray400,
              promotionalOffers && pushNotifications,
              (v) {
                if (pushNotifications) _handlePromoToggle(v);
              },
              disabled: !pushNotifications,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(
              'APP PREFERENCES',
              Icons.tune_rounded,
              AppColors.neonTeal,
            ),
            const SizedBox(height: 12),
            _buildToggle(
              'Haptic Feedback',
              'Vibration on button taps',
              Icons.vibration_rounded,
              AppColors.neonTeal,
              hapticFeedback,
              _handleHapticToggle,
            ),
            const SizedBox(height: 8),
            _buildToggle(
              'Biometric Lock',
              'Use fingerprint to open app',
              Icons.fingerprint_rounded,
              AppColors.neonLime,
              biometricLock,
              (v) => setState(() => biometricLock = v),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(
              'ACCOUNT',
              Icons.manage_accounts_rounded,
              AppColors.neonOrange,
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              'Member ID',
              widget.member.id,
              Icons.badge_rounded,
              AppColors.neonLime,
              onTap: () {
                Clipboard.setData(ClipboardData(text: widget.member.id));
                _showSnack('Member ID copied!');
              },
              trailing: const Icon(
                Icons.copy_rounded,
                size: 16,
                color: AppColors.gray400,
              ),
            ),
            const SizedBox(height: 8),
            _buildActionTile(
              'Phone',
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
            _buildSectionHeader(
              'ABOUT',
              Icons.info_rounded,
              AppColors.turquoise,
            ),
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
              onTap: () => _showSnack('Privacy Policy coming soon!'),
              trailing: const Icon(
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
              onTap: () => _showSnack('Terms of Service coming soon!'),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.gray400,
              ),
            ),
            const SizedBox(height: 8),
            _buildActionTile(
              'Contact Support',
              'Get help from our team',
              Icons.headset_mic_outlined,
              AppColors.neonTeal,
              onTap: () => _showContactSupport(context),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.gray400,
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(
              'DANGER ZONE',
              Icons.warning_rounded,
              AppColors.error,
            ),
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
                    'Version 1.0.0  ·  Built with ❤',
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

  // ── Widgets ───────────────────────────────────────────────────────────────

  Widget get _buildMemberCard => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.neonLime.withValues(alpha: 0.1),
          AppColors.neonTeal.withValues(alpha: 0.05),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.neonLime.withValues(alpha: 0.2)),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
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

  Widget _buildSectionHeader(String title, IconData icon, Color color) => Row(
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
        child: Container(height: 1, color: color.withValues(alpha: 0.2)),
      ),
    ],
  );

  Widget _buildToggle(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool value,
    ValueChanged<bool> onChanged, {
    bool isMain = false,
    bool disabled = false,
  }) => AnimatedOpacity(
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
                    color: disabled ? AppColors.gray600 : AppColors.textPrimary,
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

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
    Widget? trailing,
  }) => GestureDetector(
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
          // null-aware spread - fixes use_null_aware_elements lint
          ?trailing,
        ],
      ),
    ),
  );

  Widget _buildDangerButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) => Material(
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

  // ── Actions ───────────────────────────────────────────────────────────────

  void _handleClearCache() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.neonOrange.withValues(alpha: 0.3)),
        ),
        title: Text('Clear Cache', style: AppTextStyles.heading3),
        content: Text(
          'This will clear temporary files. Your data is safe.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.gray400)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnack('Cache cleared!');
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
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        title: Text('Logout', style: AppTextStyles.heading3),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.gray400)),
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
      await FirebaseAuthService.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
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
      builder: (_) => Padding(
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
            Icon(
              Icons.headset_mic_outlined,
              color: AppColors.neonTeal,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'Contact Support',
              style: AppTextStyles.heading3.copyWith(color: AppColors.neonTeal),
            ),
            const SizedBox(height: 24),
            _contactRow(
              Icons.location_on_rounded,
              'Hanamkonda & Warangal Branches',
            ),
            const SizedBox(height: 14),
            _contactRow(
              Icons.access_time_rounded,
              'Mon-Sat: 6:00 AM – 10:00 PM',
            ),
            const SizedBox(height: 14),
            _contactRow(Icons.phone_rounded, AppConfig.supportPhone),
            const SizedBox(height: 14),
            _contactRow(Icons.email_rounded, AppConfig.supportEmail),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonTeal,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'CLOSE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) => Row(
    children: [
      Icon(icon, color: AppColors.neonTeal, size: 18),
      const SizedBox(width: 12),
      Text(text, style: AppTextStyles.bodyMedium),
    ],
  );

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }
}
