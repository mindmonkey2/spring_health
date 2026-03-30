// lib/screens/announcements/create_announcement_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/constants.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() =>
  _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState
extends State<CreateAnnouncementScreen> {
  final _formKey          = GlobalKey<FormState>();
  final _titleController  = TextEditingController();
  final _messageController = TextEditingController();

  List<String> _selectedBranches = ['all'];
  String       _priority          = 'normal';
  bool         _isLoading         = false;

  // Only colours actually used in this file
  static const Color _yellow = Color(0xFFF59E0B);
  static const Color _red    = Color(0xFFEF4444);

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // ── Computed helpers ─────────────────────────────────────────────

  String get _primaryBranch {
    if (_selectedBranches.contains('all')) return 'All';
    if (_selectedBranches.length == 1) return _selectedBranches.first;
    return 'All';
  }

  Color get _priorityColor {
    if (_priority == 'urgent')    return _red;
    if (_priority == 'important') return _yellow;
    return Colors.grey.shade400;
  }

  IconData get _priorityIcon {
    if (_priority == 'urgent')    return Icons.warning_rounded;
    if (_priority == 'important') return Icons.priority_high_rounded;
    return Icons.campaign_rounded;
  }

  // ── Save ─────────────────────────────────────────────────────────

  Future<void> _createAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBranches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one branch'),
          backgroundColor: _red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('announcements').add({
        'title':          _titleController.text.trim(),
        'message':        _messageController.text.trim(),
        'content':        _messageController.text.trim(), // backward-compat
        'targetBranches': _selectedBranches,
        'branch':         _primaryBranch,
        'priority':       _priority,
        'isActive':       true,
        'createdAt':      FieldValue.serverTimestamp(),
        'createdByUid':   user?.uid ?? '',
        'createdBy':      user?.displayName ??
        user?.email?.split('@').first ??
        'Admin',
        'readBy':         [],
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(' Announcement sent successfully!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: _red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Announcement',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                          flexibleSpace: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryDark]),
                            ),
                          ),
                     foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildTitleField(),
            const SizedBox(height: 20),
            _buildMessageField(),
            const SizedBox(height: 24),
            _buildBranchSection(),
            const SizedBox(height: 24),
            _buildPrioritySection(),
            const SizedBox(height: 24),
            _buildPreviewBanner(),
            const SizedBox(height: 28),
            _buildSendButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Title field ──────────────────────────────────────────────────

  Widget _buildTitleField() {
    return _card(
      child: TextFormField(
        controller: _titleController,
        textCapitalization: TextCapitalization.words,
        decoration: _inputDeco(
          label: 'Announcement Title',
          hint: 'e.g., Gym Maintenance Notice',
          icon: Icons.title_rounded,
        ),
        validator: (v) =>
        (v?.trim().isEmpty ?? true) ? 'Please enter a title' : null,
      ),
    );
  }

  // ── Message field ────────────────────────────────────────────────

  Widget _buildMessageField() {
    return _card(
      child: TextFormField(
        controller: _messageController,
        maxLines: 5,
        textCapitalization: TextCapitalization.sentences,
        decoration: _inputDeco(
          label: 'Message',
          hint: 'Enter announcement details...',
          icon: Icons.message_rounded,
          alignLabelWithHint: true,
        ),
        validator: (v) =>
        (v?.trim().isEmpty ?? true) ? 'Please enter a message' : null,
      ),
    );
  }

  // ── Branch section ───────────────────────────────────────────────

  Widget _buildBranchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Target Branches', Icons.location_on_rounded),
        const SizedBox(height: 12),
        _card(
          child: Column(
            children: [
              CheckboxListTile(
                title: const Text('All Branches',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: const Text('Send to all gym locations'),
                                  value: _selectedBranches.contains('all'),
                                  onChanged: (v) => setState(() {
                                    _selectedBranches =
                                    (v == true) ? ['all'] : [];
                                  }),
                               activeColor: AppColors.primary,
              ),
              if (!_selectedBranches.contains('all')) ...[
                const Divider(height: 1),
                ...AppConstants.branches.map((branch) {
                  return CheckboxListTile(
                    title: Text(branch),
                    value: _selectedBranches.contains(branch),
                    onChanged: (v) => setState(() {
                      if (v == true) {
                        _selectedBranches.add(branch);
                      } else {
                        _selectedBranches.remove(branch);
                      }
                    }),
                    activeColor: AppColors.primary,
                    secondary: CircleAvatar(
                      radius: 14,
                      backgroundColor:
                      AppColors.primary.withValues(alpha: 0.12),
                      child: const Icon(Icons.store_rounded,
                                  size: 16, color: AppColors.primary),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── Priority section ─────────────────────────────────────────────

  Widget _buildPrioritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Priority', Icons.flag_rounded),
        const SizedBox(height: 12),

        // Visual tile row
        Row(
          children: [
            _priorityTile('normal',    'Normal',    Icons.info_outline_rounded,  Colors.grey.shade600),
            const SizedBox(width: 10),
            _priorityTile('important', 'Important', Icons.priority_high_rounded, _yellow),
            const SizedBox(width: 10),
            _priorityTile('urgent',    'Urgent',    Icons.warning_rounded,       _red),
          ],
        ),

        const SizedBox(height: 12),

        // Custom radio rows (no deprecated RadioListTile)
        _card(
          child: Column(
            children: [
              _priorityRow('normal',    'Normal',    'General information for members',  Colors.grey.shade700),
              const Divider(height: 1),
              _priorityRow('important', 'Important', 'Members should see this soon',     _yellow),
              const Divider(height: 1),
              _priorityRow('urgent',    'Urgent',    'Immediate attention required',     _red),
            ],
          ),
        ),
      ],
    );
  }

  Widget _priorityTile(
    String value, String label, IconData icon, Color color) {
    final selected = _priority == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
            ? color.withValues(alpha: 0.1)
            : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(children: [
            Icon(icon,
                 color: selected ? color : Colors.grey.shade400,
                 size: 22),
                 const SizedBox(height: 6),
                 Text(
                   label,
                   style: TextStyle(
                     fontSize: 12,
                     fontWeight:
                     selected ? FontWeight.bold : FontWeight.normal,
                     color: selected ? color : Colors.grey.shade500,
                   ),
                 ),
          ]),
        ),
      ),
    );
    }

    /// Custom radio row — replaces deprecated RadioListTile
    Widget _priorityRow(
      String value, String label, String subtitle, Color color) {
      final selected = _priority == value;
      return InkWell(
        onTap: () => setState(() => _priority = value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            // Custom radio circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? color : Colors.grey.shade400,
                  width: selected ? 2 : 1.5,
                ),
                color: selected
                ? color.withValues(alpha: 0.1)
                : Colors.transparent,
              ),
              child: selected
              ? Center(
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: color, shape: BoxShape.circle),
                ),
              )
              : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: selected ? color : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500),
                  ),
                ]),
            ),
          ]),
        ),
      );
      }

      // ── Preview banner ───────────────────────────────────────────────

      Widget _buildPreviewBanner() {
        final branchText = _selectedBranches.contains('all')
        ? 'All Branches'
        : _selectedBranches.isEmpty
        ? 'No branch selected'
        : _selectedBranches.join(', ');

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _priorityColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _priorityColor.withValues(alpha: 0.35)),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _priorityColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(_priorityIcon, color: _priorityColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location $branchText',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_priority[0].toUpperCase()}${_priority.substring(1)} priority · visible immediately',
                    style: TextStyle(
                      fontSize: 12,
                      color: _priorityColor,
                      fontWeight: FontWeight.bold),
                  ),
                ]),
            ),
          ]),
        );
      }

      // ── Send button ──────────────────────────────────────────────────

      Widget _buildSendButton() {
        return Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isLoading
              ? [Colors.grey.shade400, Colors.grey.shade400]
              : [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isLoading
            ? []
            : [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _createAnnouncement,
            icon: _isLoading
            ? const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2),
            )
            : const Icon(Icons.send_rounded),
            label: Text(
              _isLoading ? 'SENDING...' : 'SEND ANNOUNCEMENT',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        );
      }

      // ── Shared helpers ───────────────────────────────────────────────

      Widget _card({required Widget child}) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        );
      }

      Widget _sectionHeader(String label, IconData icon) {
        return Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark]),
                borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Text(label,
               style: const TextStyle(
                 fontSize: 18, fontWeight: FontWeight.bold)),
        ]);
      }

      InputDecoration _inputDeco({
        required String label,
        required String hint,
        required IconData icon,
        bool alignLabelWithHint = false,
      }) {
        return InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primary),
          alignLabelWithHint: alignLabelWithHint,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16))),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(20),
        );
      }
}
