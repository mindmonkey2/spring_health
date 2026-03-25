import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/member_model.dart';

class EditProfileScreen extends StatefulWidget {
  final MemberModel member;

  const EditProfileScreen({super.key, required this.member});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late final TextEditingController _emailCtrl;
  late final TextEditingController _emergencyNameCtrl;
  late final TextEditingController _emergencyPhoneCtrl;

  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  String? _newPhotoUrl;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.member.email);
    _emergencyNameCtrl =
        TextEditingController(text: widget.member.emergencyContactName ?? '');
    _emergencyPhoneCtrl =
        TextEditingController(text: widget.member.emergencyContactPhone ?? '');
    _newPhotoUrl = widget.member.photoUrl;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _emergencyNameCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    super.dispose();
  }

  // ── Photo ─────────────────────────────────────────────────────────────────

  void _showPhotoSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.neonLime.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_rounded,
                      color: AppColors.neonLime),
                ),
                title: const Text('Choose from Gallery'),
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
                  child: const Icon(Icons.camera_alt_rounded,
                      color: AppColors.neonTeal),
                ),
                title: const Text('Take a Photo'),
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
    final XFile? picked =
        await _picker.pickImage(source: source, imageQuality: 75, maxWidth: 800);
    if (picked == null || !mounted) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final ref = FirebaseStorage.instance
          .ref()
          .child('memberphotos')
          .child('$uid.jpg');
      await ref.putFile(
        File(picked.path),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final url = await ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('members')
          .doc(uid)
          .update({'photoUrl': url});
      if (!mounted) return;
      setState(() {
        _newPhotoUrl = url;
        _isUploadingPhoto = false;
      });
      _showSnack('Profile photo updated!');
    } on FirebaseException catch (e) {
      debugPrint('Photo upload error: ${e.code} ${e.message}');
      if (!mounted) return;
      setState(() => _isUploadingPhoto = false);
      _showSnack('Upload failed: ${e.message}');
    } catch (_) {
      if (!mounted) return;
      setState(() => _isUploadingPhoto = false);
      _showSnack('Upload failed. Please try again.');
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final updates = <String, dynamic>{
      'email': _emailCtrl.text.trim(),
      'emergencyContactName': _emergencyNameCtrl.text.trim(),
      'emergencyContactPhone': _emergencyPhoneCtrl.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('members')
          .doc(widget.member.id)
          .update(updates);
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnack('Profile saved!');
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      debugPrint('Save error: ${e.code}');
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnack('Save failed: ${e.message}');
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlack,
        elevation: 0,
        title: Text('Edit Profile',
            style: AppTextStyles.heading3
                .copyWith(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.neonLime),
                  )
                : Text('SAVE',
                    style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.neonLime,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPhotoSection,
              const SizedBox(height: 28),
              _buildReadOnlySection,
              const SizedBox(height: 20),
              _buildEditableSection,
              const SizedBox(height: 20),
              _buildEmergencySection,
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── Photo section ─────────────────────────────────────────────────────────

  Widget get _buildPhotoSection => Center(
        child: Column(
          children: [
            GestureDetector(
              onTap: _isUploadingPhoto ? null : _showPhotoSheet,
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
                          color: AppColors.neonLime.withValues(alpha: 0.25),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _newPhotoUrl != null
                          ? Image.network(_newPhotoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, e, s) =>
                                  _defaultAvatar)
                          : _defaultAvatar,
                    ),
                  ),
                  if (_isUploadingPhoto)
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundBlack.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.neonLime, strokeWidth: 3),
                      ),
                    ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.neonLime,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.backgroundBlack, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          size: 14, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text('Tap to change photo',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.gray400)),
          ],
        ),
      ).animate().fadeIn().scaleXY(begin: 0.9);

  Widget get _defaultAvatar => Container(
        color: AppColors.cardSurface,
        child: Center(
          child: Text(
            widget.member.name.isNotEmpty
                ? widget.member.name[0].toUpperCase()
                : '?',
            style: AppTextStyles.heading1
                .copyWith(color: AppColors.neonLime, fontSize: 36),
          ),
        ),
      );

  // ── Read-only section (name, phone, plan) ─────────────────────────────────

  Widget get _buildReadOnlySection => _sectionCard(
        title: 'MEMBERSHIP INFO',
        color: AppColors.gray400,
        children: [
          _readOnlyRow('Full Name', widget.member.name,
              Icons.person_rounded, AppColors.neonLime),
          const SizedBox(height: 12),
          _readOnlyRow('Phone', widget.member.phone,
              Icons.phone_rounded, AppColors.neonTeal),
          const SizedBox(height: 12),
          _readOnlyRow('Plan', widget.member.membershipPlan,
              Icons.fitness_center_rounded, AppColors.neonOrange),
          const SizedBox(height: 12),
          _readOnlyRow('Branch', widget.member.branch.toUpperCase(),
              Icons.location_on_rounded, AppColors.turquoise),
        ],
      );

  // ── Editable fields ───────────────────────────────────────────────────────

  Widget get _buildEditableSection => _sectionCard(
        title: 'CONTACT INFO',
        color: AppColors.neonTeal,
        children: [
          _buildField(
            label: 'Email Address',
            hint: 'your@email.com',
            controller: _emailCtrl,
            icon: Icons.email_rounded,
            color: AppColors.neonTeal,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return null;
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
        ],
      );

  // ── Emergency contact ─────────────────────────────────────────────────────

  Widget get _buildEmergencySection => _sectionCard(
        title: 'EMERGENCY CONTACT',
        color: AppColors.neonOrange,
        children: [
          _buildField(
            label: 'Contact Name',
            hint: 'Emergency contact person',
            controller: _emergencyNameCtrl,
            icon: Icons.person_outline_rounded,
            color: AppColors.neonOrange,
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'Contact Phone',
            hint: '+91 XXXXX XXXXX',
            controller: _emergencyPhoneCtrl,
            icon: Icons.phone_outlined,
            color: AppColors.neonOrange,
            keyboardType: TextInputType.phone,
          ),
        ],
      );

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionCard({
    required String title,
    required Color color,
    required List<Widget> children,
  }) =>
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: AppTextStyles.caption.copyWith(
                        color: color,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0);

  Widget _readOnlyRow(
      String label, String value, IconData icon, Color color) =>
      Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.gray400)),
                const SizedBox(height: 2),
                Text(value,
                    style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray400)),
              ],
            ),
          ),
          const Icon(Icons.lock_outline_rounded,
              size: 14, color: AppColors.gray600),
        ],
      );

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required Color color,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.gray400)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.gray600),
              prefixIcon: Icon(icon, color: color, size: 20),
              filled: true,
              fillColor: AppColors.backgroundBlack,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: AppColors.gray800),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.error),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.gray800),
              ),
            ),
          ),
        ],
      );

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.cardSurface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
  }
}
