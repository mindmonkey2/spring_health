// lib/screens/notifications/send_push_notification_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SendPushNotificationScreen extends StatefulWidget {
  final String? branch; // null = Owner (all branches), set = Receptionist
  const SendPushNotificationScreen({super.key, this.branch});

  @override
  State<SendPushNotificationScreen> createState() =>
      _SendPushNotificationScreenState();
}

class _SendPushNotificationScreenState
    extends State<SendPushNotificationScreen> {
  // ── Theme ──────────────────────────────────────────────────────────────────
  static const _green = Color(0xFF10B981);
  static const _teal = Color(0xFF14B8A6);
  static const _orange = Color(0xFFF59E0B);
  static const _bg = Color(0xFFF1F5F9);

  // ── Form ───────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  // Target
  String _targetType = 'all'; // all | branch | member
  String _targetBranch = 'Hanamkonda';
  MemberSearchResult? _targetMember;

  // Type
  String _notifType = 'announcement'; // announcement|reminder|offer|challenge

  // State
  bool _isSending = false;
  bool _searchingMember = false;
  final _phoneCtrl = TextEditingController();
  String? _memberSearchError;

  final _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Receptionist locked to their branch
    if (widget.branch != null) {
      _targetType = 'branch';
      _targetBranch = widget.branch!;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ── Send ───────────────────────────────────────────────────────────────────
  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    if (_targetType == 'member' && _targetMember == null) {
      _showSnack('Search and select a member first', Colors.red);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnack('You must be logged in to send notifications', Colors.red);
      return;
    }

    setState(() => _isSending = true);
    try {
      final payload = <String, dynamic>{
        'title': _titleCtrl.text.trim(),
        'body': _bodyCtrl.text.trim(),
        'targetType': _targetType,
        'type': _notifType,
        'sentBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'sent': false,
        'sentAt': null,
      };

      if (_targetType == 'branch') {
        payload['targetBranch'] = _targetBranch;
      } else if (_targetType == 'member') {
        payload['targetId'] = _targetMember!.id;
        payload['targetName'] = _targetMember!.name;
      }

      // Write to notificationsQueue — Cloud Function picks this up
      await _db.collection('notificationsQueue').add(payload);

      // Also write to admin send history
      await _db.collection('notificationHistory').add({
        ...payload,
        'sentAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _showSuccess();
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // ── Member search ──────────────────────────────────────────────────────────
  Future<void> _searchMember() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) return;
    setState(() {
      _searchingMember = true;
      _memberSearchError = null;
      _targetMember = null;
    });
    try {
      final snap = await _db
          .collection('members')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        setState(() => _memberSearchError = 'No member found with this phone');
      } else {
        final d = snap.docs.first;
        setState(() => _targetMember = MemberSearchResult(
              id: d.id,
              name: d.data()['name'] as String? ?? 'Member',
              branch: d.data()['branch'] as String? ?? '',
              phone: phone,
            ));
      }
    } catch (e) {
      setState(() => _memberSearchError = 'Search failed: $e');
    } finally {
      if (mounted) setState(() => _searchingMember = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.check_circle_rounded, color: _green, size: 32),
          SizedBox(width: 12),
          Text('Notification Queued!'),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'Your push notification has been queued. '
            'Firebase will deliver it to the target ${_targetType == 'all' ? 'all members' : _targetType == 'branch' ? '$_targetBranch members' : _targetMember!.name} shortly.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ]),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _green),
            onPressed: () {
              Navigator.pop(context);
              _titleCtrl.clear();
              _bodyCtrl.clear();
              setState(() => _targetMember = null);
            },
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Send Push Notification'),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [_green, _teal]),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Target selector ──────────────────────────────────────────────
            _SectionCard(
              title: 'TARGET AUDIENCE',
              icon: Icons.people_rounded,
              color: _teal,
              child: Column(
                children: [
                  if (widget.branch == null) ...[
                    _TargetChip(
                      label: ' All Members',
                      subtitle: 'Both Hanamkonda & Warangal',
                      selected: _targetType == 'all',
                      color: _green,
                      onTap: () => setState(() => _targetType = 'all'),
                    ),
                    const SizedBox(height: 8),
                    _TargetChip(
                      label: 'Office Specific Branch',
                      subtitle: 'Hanamkonda or Warangal only',
                      selected: _targetType == 'branch',
                      color: _teal,
                      onTap: () => setState(() => _targetType = 'branch'),
                    ),
                    if (_targetType == 'branch') ...[
                      const SizedBox(height: 10),
                      Row(children: [
                        _branchBtn('Hanamkonda', _targetBranch == 'Hanamkonda',
                            _teal, () => setState(() => _targetBranch = 'Hanamkonda')),
                        const SizedBox(width: 8),
                        _branchBtn('Warangal', _targetBranch == 'Warangal',
                            _teal, () => setState(() => _targetBranch = 'Warangal')),
                      ]),
                    ],
                    const SizedBox(height: 8),
                  ],
                  _TargetChip(
                    label: ' Single Member',
                    subtitle: 'Search by phone number',
                    selected: _targetType == 'member',
                    color: _orange,
                    onTap: () => setState(() => _targetType = 'member'),
                  ),
                  if (_targetType == 'member') ...[
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Member phone number',
                            prefixIcon: const Icon(Icons.phone_rounded),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: _orange,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 13)),
                        onPressed: _searchingMember ? null : _searchMember,
                        child: _searchingMember
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Find',
                                style: TextStyle(color: Colors.white)),
                      ),
                    ]),
                    if (_memberSearchError != null) ...[
                      const SizedBox(height: 6),
                      Text(_memberSearchError!,
                          style: const TextStyle(color: Colors.red, fontSize: 12)),
                    ],
                    if (_targetMember != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _green.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: _green.withValues(alpha: 0.3)),
                        ),
                        child: Row(children: [
                          CircleAvatar(
                            backgroundColor: _green.withValues(alpha: 0.15),
                            radius: 18,
                            child: Text(
                              _targetMember!.name[0].toUpperCase(),
                              style: const TextStyle(
                                  color: _green, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_targetMember!.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                                Text(
                                    '${_targetMember!.branch} · ${_targetMember!.phone}',
                                    style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          const Icon(Icons.check_circle_rounded,
                              color: _green, size: 20),
                        ]),
                      ),
                    ],
                  ],
                ],
              ),
            ).animate().fadeIn(delay: 0.ms).slideY(begin: 0.04, end: 0),

            const SizedBox(height: 12),

            // ── Notification type ────────────────────────────────────────────
            _SectionCard(
              title: 'NOTIFICATION TYPE',
              icon: Icons.label_rounded,
              color: _orange,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _typeChip('Announcement', 'Announcement', 'announcement', _green),
                  _typeChip('', 'Reminder', 'reminder', _orange),
                  _typeChip('', 'Offer', 'offer', Colors.purple),
                  _typeChip('', 'Challenge', 'challenge', Colors.indigo),
                ],
              ),
            ).animate().fadeIn(delay: 60.ms).slideY(begin: 0.04, end: 0),

            const SizedBox(height: 12),

            // ── Message composer ─────────────────────────────────────────────
            _SectionCard(
              title: 'MESSAGE',
              icon: Icons.edit_rounded,
              color: _green,
              child: Column(children: [
                TextFormField(
                  controller: _titleCtrl,
                  maxLength: 60,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g. Gym Holiday Notice',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    counterStyle:
                        TextStyle(color: Colors.grey.shade400, fontSize: 11),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bodyCtrl,
                  maxLines: 4,
                  maxLength: 200,
                  decoration: InputDecoration(
                    labelText: 'Message',
                    hintText: 'Write your message here...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    counterStyle:
                        TextStyle(color: Colors.grey.shade400, fontSize: 11),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Message is required' : null,
                ),
                // Live preview
                const SizedBox(height: 12),
                if (_titleCtrl.text.isNotEmpty || _bodyCtrl.text.isNotEmpty)
                  _NotifPreview(
                    title: _titleCtrl.text,
                    body: _bodyCtrl.text,
                    type: _notifType,
                    green: _green,
                  ),
              ]),
            ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.04, end: 0),

            const SizedBox(height: 20),

            // ── Send button ──────────────────────────────────────────────────
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _isSending ? null : _send,
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_rounded, color: Colors.white),
                label: Text(
                  _isSending ? 'Sending...' : 'SEND NOTIFICATION',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
              ),
            ).animate().fadeIn(delay: 180.ms),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(
      String emoji, String label, String value, Color color) {
    final selected = _notifType == value;
    return GestureDetector(
      onTap: () => setState(() => _notifType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? color : Colors.grey.shade300,
              width: selected ? 1.5 : 1),
        ),
        child: Text('$emoji $label',
            style: TextStyle(
                color: selected ? color : Colors.grey.shade600,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13)),
      ),
    );
  }

  Widget _branchBtn(
      String label, bool selected, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.12) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: selected ? color : Colors.grey.shade300,
                width: selected ? 1.5 : 1),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: selected ? color : Colors.grey.shade600,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500)),
        ),
      ),
    );
  }
}

// ── Data class ──────────────────────────────────────────────────────────────
class MemberSearchResult {
  final String id, name, branch, phone;
  const MemberSearchResult(
      {required this.id,
      required this.name,
      required this.branch,
      required this.phone});
}

// ── Section Card ─────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  const _SectionCard(
      {required this.title,
      required this.icon,
      required this.color,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(title,
                style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5)),
          ]),
          const SizedBox(height: 14),
          child,
        ]),
      ),
    );
  }
}

// ── Target Chip ──────────────────────────────────────────────────────────────
class _TargetChip extends StatelessWidget {
  final String label, subtitle;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _TargetChip(
      {required this.label,
      required this.subtitle,
      required this.selected,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? color : Colors.grey.shade200,
              width: selected ? 1.5 : 1),
        ),
        child: Row(children: [
          Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? color : Colors.grey.shade400,
              size: 20),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? color : Colors.grey.shade700)),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 11, color: Colors.grey.shade500)),
          ]),
        ]),
      ),
    );
  }
}

// ── Live Preview ──────────────────────────────────────────────────────────────
class _NotifPreview extends StatelessWidget {
  final String title, body, type;
  final Color green;
  const _NotifPreview(
      {required this.title,
      required this.body,
      required this.type,
      required this.green});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                color: green, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.fitness_center_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Spring Health',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
          Text('now',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
        ]),
        const SizedBox(height: 8),
        Text(title.isEmpty ? 'Notification Title' : title,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        const SizedBox(height: 2),
        Text(body.isEmpty ? 'Message body...' : body,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        Text('PREVIEW  ·  $type'.toUpperCase(),
            style: TextStyle(
                color: green,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5)),
      ]),
    );
  }
}
