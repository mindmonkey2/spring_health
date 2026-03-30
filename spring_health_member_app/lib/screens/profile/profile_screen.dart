import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/member_model.dart';
import '../../services/firebase_auth_service.dart';
import '../auth/login_screen.dart';
import '../attendance/member_attendance_screen.dart';
import '../fitness/body_metrics_screen.dart';
import '../gamification/personal_best_screen.dart';
import '../payments/payment_history_screen.dart';
import '../settings/settings_screen.dart';
import '../health/health_profile_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final MemberModel member;

  const ProfileScreen({super.key, required this.member});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();
  bool _isUploadingPhoto = false;
  late MemberModel _member;

  @override
  void initState() {
    super.initState();
    _member = widget.member;
  }

  // ─── Photo Upload ──────────────────────────────────────────────────────────

  void _showPhotoSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.gray600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text('Update Profile Photo', style: AppTextStyles.heading3),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.neonLime.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.neonLime,
                  ),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: AppTextStyles.bodyLarge,
                ),
                subtitle: Text(
                  'Pick an existing photo',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray400,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUpload(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.neonTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.neonTeal,
                  ),
                ),
                title: Text('Take a Photo', style: AppTextStyles.bodyLarge),
                subtitle: Text(
                  'Use your camera',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray400,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUpload(ImageSource.camera);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 75,
      maxWidth: 800,
    );
    if (picked == null || !mounted) return;
    await _uploadProfilePhoto(File(picked.path));
  }

  Future<void> _uploadProfilePhoto(File imageFile) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      setState(() => _isUploadingPhoto = true);

      final ref = FirebaseStorage.instance
          .ref()
          .child('member_photos')
          .child('$uid.jpg');

      await ref.putFile(imageFile, SettableMetadata(contentType: 'image/jpeg'));
      final downloadUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('members').doc(uid).update({
        'photoUrl': downloadUrl,
      });

      if (!mounted) return;
      setState(() {
        _isUploadingPhoto = false;
        _member = MemberModel.fromMap({
          ..._member.toMap(),
          'photoUrl': downloadUrl,
        }, id: _member.id);
      });
      _showSuccess('Profile photo updated');
    } on FirebaseException catch (e) {
      debugPrint('Storage upload failed: ${e.code} — ${e.message}');
      if (!mounted) return;
      setState(() => _isUploadingPhoto = false);
      _showError('Upload failed. Please try again.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _isUploadingPhoto = false);
      _showError('Upload failed. Please try again.');
    }
  }

  // ─── Snack helpers ─────────────────────────────────────────────────────────

  void _showSuccess(String msg) => _showSnack(msg, AppColors.success);
  void _showError(String msg) => _showSnack(msg, AppColors.error);

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─── Navigation ────────────────────────────────────────────────────────────

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.neonLime.withValues(alpha: 0.3)),
        ),
        title: Text('Logout', style: AppTextStyles.heading3),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.gray400)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
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
      await FirebaseAuthService.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _push(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
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

  // ─── Profile Header ────────────────────────────────────────────────────────

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonLime.withValues(alpha: 0.15),
            AppColors.turquoise.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonLime.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _showPhotoSourceSheet,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Hero(
                  tag: '${_member.id}_avatar',
                  child: Container(
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
                      child: _member.photoUrl != null
                          ? Image.network(
                              _member.photoUrl!,
                              fit: BoxFit.cover,
                              // fix: single underscores → no unnecessary_underscores lint
                              errorBuilder: (_, e, s) => _buildDefaultAvatar(),
                            )
                          : _buildDefaultAvatar(),
                    ),
                  ),
                ),
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
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.neonLime,
                      size: 16,
                    ),
                  ),
                ),
                if (_isUploadingPhoto)
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundBlack.withValues(alpha: 0.65),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.neonLime,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
              ],
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
          const SizedBox(height: 16),
          Text(
            _member.name.toUpperCase(),
            style: AppTextStyles.heading2.copyWith(color: AppColors.neonLime),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.gray400.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'ID: ${_member.id}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.gray400,
                letterSpacing: 1.2,
              ),
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
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
          _member.name.isNotEmpty ? _member.name[0].toUpperCase() : '?',
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.neonLime,
            fontSize: 40,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final Color badgeColor;
    final String text;
    final IconData icon;

    if (_member.isExpired) {
      badgeColor = AppColors.error;
      text = 'EXPIRED';
      icon = Icons.cancel_rounded;
    } else if (_member.isExpiringSoon) {
      badgeColor = AppColors.warning;
      text = 'EXPIRING SOON';
      icon = Icons.warning_rounded;
    } else {
      badgeColor = AppColors.success;
      text = 'ACTIVE';
      icon = Icons.check_circle_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: badgeColor, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
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

  // ─── Membership Info Card ──────────────────────────────────────────────────

  Widget _buildMembershipInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonLime.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            'MEMBERSHIP DETAILS',
            Icons.card_membership,
            AppColors.neonLime,
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            'Plan',
            _member.membershipPlan,
            Icons.fitness_center_rounded,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Branch',
            _member.branch.toUpperCase(),
            Icons.location_on_rounded,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Start Date',
            DateFormat('dd MMM yyyy').format(_member.membershipStartDate),
            Icons.calendar_today_rounded,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Expiry Date',
            DateFormat('dd MMM yyyy').format(_member.membershipEndDate),
            Icons.event_rounded,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Days Remaining',
            _member.daysRemaining > 0
                ? '${_member.daysRemaining} days'
                : 'Expired',
            Icons.timelapse_rounded,
            valueColor: _member.isExpired
                ? AppColors.error
                : _member.isExpiringSoon
                ? AppColors.warning
                : AppColors.success,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  // ─── Personal Info Card ────────────────────────────────────────────────────

  Widget _buildPersonalInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.turquoise.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            'PERSONAL INFORMATION',
            Icons.person_rounded,
            AppColors.turquoise,
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Phone', _member.phone, Icons.phone_rounded),
          const SizedBox(height: 16),
          // email is non-nullable String — no null check needed
          _buildInfoRow(
            'Email',
            _member.email.isNotEmpty ? _member.email : 'Not provided',
            Icons.email_rounded,
          ),
          if (_member.address != null && _member.address!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoRow('Address', _member.address!, Icons.home_rounded),
          ],
          if (_member.emergencyContactName != null &&
              _member.emergencyContactName!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoRow(
              'Emergency Contact',
              _member.emergencyContactName!,
              Icons.emergency_rounded,
              valueColor: AppColors.neonOrange,
            ),
          ],
          if (_member.emergencyContactPhone != null &&
              _member.emergencyContactPhone!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoRow(
              'Emergency Phone',
              _member.emergencyContactPhone!,
              Icons.phone_forwarded_rounded,
              valueColor: AppColors.neonOrange,
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  // ─── Account Actions ───────────────────────────────────────────────────────

  Widget _buildAccountActions() {
    return Column(
      children: [
        // Edit Profile navigates with the full MemberModel object
        _buildActionTile(
          'Edit Profile',
          Icons.edit_rounded,
          AppColors.neonLime,
          subtitle: 'Update email & emergency contact',
          onTap: () => _push(EditProfileScreen(member: _member)),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          'Health Profile & AI Goals',
          Icons.monitor_heart_outlined,
          AppColors.neonOrange,
          subtitle: 'Metrics, BP, goals — powers your AI coach',
          onTap: () => _push(HealthProfileScreen(memberId: _member.id)),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          'Payment History',
          Icons.receipt_long_rounded,
          AppColors.neonLime,
          subtitle: 'View transactions & receipts',
          onTap: () => _push(
            PaymentHistoryScreen(
              memberId: _member.id,
              memberName: _member.name,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          'Personal Bests Trophy',
          Icons.emoji_events_rounded,
          AppColors.warning,
          subtitle: 'Track your reps, beat your limits',
          onTap: () => _push(const PersonalBestScreen()),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          'Body Metrics',
          Icons.monitor_weight_rounded,
          AppColors.neonTeal,
          subtitle: 'Track weight, BMI & measurements',
          onTap: () => _push(BodyMetricsScreen(memberId: _member.id)),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          'Attendance History',
          Icons.calendar_month_rounded,
          AppColors.turquoise,
          subtitle: 'View your check-in records',
          onTap: () => _push(
            MemberAttendanceScreen(
              memberId: _member.id,
              memberName: _member.name,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          'Settings',
          Icons.settings_rounded,
          AppColors.gray400,
          subtitle: 'Notifications & preferences',
          onTap: () => _push(SettingsScreen(member: _member)),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          'Logout',
          Icons.logout_rounded,
          AppColors.error,
          subtitle: 'Sign out of your account',
          onTap: _handleLogout,
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  // ─── Shared helpers ────────────────────────────────────────────────────────

  Widget _buildCardHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.heading3.copyWith(
            fontSize: 15,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

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
                style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
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

  Widget _buildActionTile(
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
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.gray400,
                          ),
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
