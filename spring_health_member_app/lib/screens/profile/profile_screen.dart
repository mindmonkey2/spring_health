import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/member_model.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../auth/login_screen.dart';
import '../payments/payment_history_screen.dart';
import '../settings/settings_screen.dart';
import '../fitness/body_metrics_screen.dart';            // ✅ already existed
import '../attendance/member_attendance_screen.dart';    // ✅ NEW — fixes Attendance nav

class ProfileScreen extends StatefulWidget {
  final MemberModel member;

  const ProfileScreen({
    super.key,
    required this.member,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState(); // ✅ FIXED generic
}

class _ProfileScreenState extends State<ProfileScreen> { // ✅ FIXED generic
  final FirebaseAuthService _authService = FirebaseAuthService();
  final StorageService _storageService = StorageService();
  final FirestoreService _firestoreService = FirestoreService();
  final ImagePicker _imagePicker = ImagePicker();

  final ValueNotifier<bool> _isUploading = ValueNotifier<bool>(false);
  late MemberModel _currentMember;

  @override
  void initState() {
    super.initState();
    _currentMember = widget.member;
  }

  @override
  void dispose() {
    _isUploading.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (image == null) return;

      _isUploading.value = true;
      final File imageFile = File(image.path);

      final String? downloadUrl = await _storageService.uploadProfileImage(_currentMember.id, imageFile);

      if (downloadUrl != null) {
        await _firestoreService.updateProfileImageUrl(_currentMember.id, downloadUrl);

        // Update local member object
        if (mounted) {
          setState(() {
            _currentMember = MemberModel.fromMap({
              ..._currentMember.toMap(),
              'photoUrl': downloadUrl,
            }, id: _currentMember.id);
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking or uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to update profile picture.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        _isUploading.value = false;
      }
    }
  }

  // ─── Navigation Methods ──────────────────────────────────────────────────

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.neonLime.withValues(alpha: 0.3),
          ),
        ),
        title: Text('Logout', style: AppTextStyles.heading3),
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
              backgroundColor: AppColors.neonLime,
              foregroundColor: AppColors.backgroundBlack,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _openPaymentHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentHistoryScreen(
          memberId: widget.member.id,
          memberName: widget.member.name,
        ),
      ),
    );
  }

  // ✅ NEW — was showing a SnackBar before
  void _openAttendance() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberAttendanceScreen(
          memberId: widget.member.id,
          memberName: widget.member.name,
        ),
      ),
    );
  }

  // ✅ NEW — Body Metrics navigation
  void _openBodyMetrics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        BodyMetricsScreen(memberId: widget.member.id),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(member: widget.member),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        // ✅ REMOVED redundant logout IconButton from AppBar
        // (Logout is already a button in the actions list below)
        title: Text(
          'PROFILE',
          style: AppTextStyles.heading2.copyWith(letterSpacing: 2),
        ),
        backgroundColor: AppColors.backgroundBlack,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildMembershipInfoCard(),
            const SizedBox(height: 16),
            _buildPersonalInfoCard(),
            const SizedBox(height: 16),
            _buildAccountActions(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─── Profile Header ───────────────────────────────────────────────────────

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonLime.withValues(alpha: 0.2),
            AppColors.turquoise.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonLime.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Profile Picture
          GestureDetector(
            onTap: _pickAndUploadImage,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.neonLime, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonLime.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _currentMember.photoUrl != null
                    ? Image.network(
                      _currentMember.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      _buildDefaultAvatar(),
                    )
                    : _buildDefaultAvatar(),
                  ),
                ),
                // Camera Icon Overlay
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundBlack,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.neonLime, width: 1.5),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: AppColors.neonLime,
                      size: 16,
                    ),
                  ),
                ),
                // Uploading State Overlay
                ValueListenableBuilder<bool>(
                  valueListenable: _isUploading,
                  builder: (context, isUploading, child) {
                    if (isUploading) {
                      return Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundBlack.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.neonLime,
                            strokeWidth: 3,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          )
          .animate()
          .fadeIn()
          .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1)),
            const SizedBox(height: 16),

            // Name
            Text(
              _currentMember.name.toUpperCase(),
              style:
              AppTextStyles.heading2.copyWith(color: AppColors.neonLime),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 8),

            // Member ID badge
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gray400.withValues(alpha: 0.3)),
              ),
              child: Text(
                'ID: ${_currentMember.id}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.gray400,
                  letterSpacing: 1.2,
                ),
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 16),

            // Status Badge
            _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppColors.cardSurface,
      child: Center(
        child: Text(
          _currentMember.name.isNotEmpty
          ? _currentMember.name[0].toUpperCase()
          : '?',
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.neonLime,
            fontSize: 40,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isExpired = _currentMember.isExpired;
    final isExpiringSoon = _currentMember.isExpiringSoon;

    Color badgeColor;
    String statusText;
    IconData icon;

    if (isExpired) {
      badgeColor = AppColors.error;
      statusText = 'EXPIRED';
      icon = Icons.cancel;
    } else if (isExpiringSoon) {
      badgeColor = AppColors.warning;
      statusText = 'EXPIRING SOON';
      icon = Icons.warning;
    } else {
      badgeColor = AppColors.success;
      statusText = 'ACTIVE';
      icon = Icons.check_circle;
    }

    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: badgeColor, size: 20),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: AppTextStyles.bodyLarge.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0);
  }

  // ─── Membership Info Card ─────────────────────────────────────────────────

  Widget _buildMembershipInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border:
        Border.all(color: AppColors.neonLime.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_membership,
                   color: AppColors.neonLime, size: 24),
              const SizedBox(width: 12),
              Text(
                'MEMBERSHIP DETAILS',
                style: AppTextStyles.heading3.copyWith(
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            'Plan', _currentMember.membershipPlan, Icons.fitness_center),
            const SizedBox(height: 16),
            _buildInfoRow('Branch',
                          _currentMember.branch.toUpperCase(), Icons.location_on),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            'Start Date',
                            DateFormat('dd MMM yyyy')
                            .format(_currentMember.membershipStartDate),
                            Icons.calendar_today,
                          ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Expiry Date',
                      DateFormat('dd MMM yyyy')
                      .format(_currentMember.membershipEndDate),
                      Icons.event,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Days Remaining',
                      _currentMember.daysRemaining > 0
                      ? '${_currentMember.daysRemaining} days'
                    : 'Expired',
                    Icons.timelapse,
                    valueColor: _currentMember.isExpired
                    ? AppColors.error
                    : _currentMember.isExpiringSoon
                    ? AppColors.warning
                    : AppColors.success,
                    ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  // ─── Personal Info Card ───────────────────────────────────────────────────

  Widget _buildPersonalInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.turquoise.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: AppColors.turquoise, size: 24),
              const SizedBox(width: 12),
              Text(
                'PERSONAL INFORMATION',
                style: AppTextStyles.heading3.copyWith(
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            'Phone', _currentMember.phone, Icons.phone),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Email',
              _currentMember.email.isNotEmpty
              ? _currentMember.email
              : 'Not provided',
              Icons.email,
            ),
            if (_currentMember.address != null &&
              _currentMember.address!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildInfoRow(
                  'Address', _currentMember.address!, Icons.home),
              ],
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  // ─── Info Row Helper ──────────────────────────────────────────────────────

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
      Color? valueColor,
    }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.backgroundBlack,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.gray400, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption
                .copyWith(color: AppColors.gray400),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
    }

    // ─── Account Actions ──────────────────────────────────────────────────────

    Widget _buildAccountActions() {
      return Column(
        children: [
          // ✅ Payment History — real navigation
          _buildActionButton(
            'Payment History',
            Icons.receipt_long_rounded,
            AppColors.neonLime,
            subtitle: 'View transactions & receipts',
            onTap: _openPaymentHistory,
          ),
          const SizedBox(height: 12),

          // ✅ NEW — Body Metrics
          _buildActionButton(
            'Body Metrics',
            Icons.monitor_weight_rounded,
            AppColors.neonTeal,
            subtitle: 'Track weight, BMI & measurements',
            onTap: _openBodyMetrics,
          ),
          const SizedBox(height: 12),

          // ✅ FIXED — Attendance History now navigates (was SnackBar)
          _buildActionButton(
            'Attendance History',
            Icons.calendar_month_rounded,
            AppColors.turquoise,
            subtitle: 'View your check-in records',
            onTap: _openAttendance,
          ),
          const SizedBox(height: 12),

          // Edit Profile (coming soon)
          _buildActionButton(
            'Edit Profile',
            Icons.edit_rounded,
            AppColors.neonOrange,
            subtitle: 'Update your information',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Edit Profile — Coming soon!'),
                backgroundColor: AppColors.cardSurface,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ✅ Settings — real navigation
          _buildActionButton(
            'Settings',
            Icons.settings_rounded,
            AppColors.gray400,
            subtitle: 'Notifications & preferences',
            onTap: _openSettings,
          ),
          const SizedBox(height: 12),

          // ✅ Logout — functional
          _buildActionButton(
            'Logout',
            Icons.logout_rounded,
            AppColors.error,
            subtitle: 'Sign out of your account',
            onTap: _handleLogout,
          ),
        ],
      ).animate().fadeIn(delay: 300.ms);
    }

    // ─── Action Button Helper ─────────────────────────────────────────────────

    Widget _buildActionButton(
      String label,
      IconData icon,
      Color color, {
        required VoidCallback onTap,
        String? subtitle,
      }) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: AppTextStyles.caption
                            .copyWith(color: AppColors.gray400),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.gray400,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      }
}
