import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/member_model.dart';
import '../../services/reminder_service.dart';
import '../../services/whatsapp_service.dart';
import 'package:intl/intl.dart';

class NotificationsDashboard extends StatefulWidget {
  final String? branch;

  const NotificationsDashboard({super.key, this.branch});

  @override
  State<NotificationsDashboard> createState() => _NotificationsDashboardState();
}

class _NotificationsDashboardState extends State<NotificationsDashboard> {
  final _reminderService = ReminderService();

  // Cached data - No re-fetching on expand/collapse
  List<MemberModel>? _birthdayMembers;
  List<MemberModel>? _expiringMembers;
  List<MemberModel>? _duesMembers;
  List<MemberModel>? _expiredMembers;
  bool _isLoading = true;

  // Expansion states
  bool _expiringExpanded = false;
  bool _duesExpanded = false;
  bool _birthdaysExpanded = false;
  bool _expiredExpanded = false;

  // Color Palette
  static const Color primaryGreen = Color(0xFF00BFA5);
  static const Color deepGreen = Color(0xFF00897B);
  static const Color accentOrange = Color(0xFFFF6B6B);
  static const Color accentYellow = Color(0xFFFFB74D);
  static const Color accentPink = Color(0xFFFF6B9D);
  static const Color accentGray = Color(0xFF9E9E9E);

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  // Load all data once - cached in state
  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    try {
      // Load all data in parallel for better performance
      final results = await Future.wait([
        _reminderService.getTodayBirthdays(branch: widget.branch),
        _reminderService.getMembersExpiringSoon(days: 7, branch: widget.branch),
        _reminderService.getMembersWithDues(branch: widget.branch),
        _loadExpiredMembers(),
      ]);

      setState(() {
        _birthdayMembers = results[0];
        _expiringMembers = results[1];
        _duesMembers = results[2];
        _expiredMembers = results[3];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Load expired members
  Future<List<MemberModel>> _loadExpiredMembers() async {
    final snapshot = await FirebaseFirestore.instance
    .collection('members')
    .where('isActive', isEqualTo: true)
    .get();

    final allMembers = snapshot.docs
    .map((doc) => MemberModel.fromMap(doc.data(), id: doc.id))
    .toList();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return allMembers.where((member) {
      final expiryDate = DateTime(
        member.expiryDate.year,
        member.expiryDate.month,
        member.expiryDate.day,
      );
      return expiryDate.isBefore(today);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryGreen, deepGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loadAllData,
              tooltip: 'Refresh',
            ),
          ],
      ),
      body: _isLoading
      ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading notifications...'),
          ],
        ),
      )
      : RefreshIndicator(
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards Row
              _buildSummaryCards(),
              const SizedBox(height: 24),

              // Birthday Wishes Section
              _buildBirthdaySection(),
              const SizedBox(height: 16),

              // Expiring Soon Section
              _buildExpiringSection(),
              const SizedBox(height: 16),

              // Pending Dues Section
              _buildDuesSection(),
              const SizedBox(height: 16),

              // Expired Memberships Section
              _buildExpiredSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // UI COMPONENTS
  // ═══════════════════════════════════════════════════════════════

  // Summary Cards
  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.cake_rounded,
            count: _birthdayMembers?.length ?? 0,
            label: 'Today',
            gradient: [accentPink, const Color(0xFFC06C84)],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.warning_rounded,
            count: _expiringMembers?.length ?? 0,
            label: 'Expiring',
            gradient: [accentYellow, const Color(0xFFFFAA00)],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.account_balance_wallet_rounded,
            count: _duesMembers?.length ?? 0,
            label: 'Dues',
            gradient: [accentOrange, const Color(0xFFEE5A6F)],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required int count,
    required String label,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: gradient[0],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // NOTIFICATION SECTIONS
  // ═══════════════════════════════════════════════════════════════

  // Birthday Section
  Widget _buildBirthdaySection() {
    final members = _birthdayMembers ?? [];
    return _buildExpandableSection(
      title: '🎂 Birthday Wishes',
      subtitle: '${members.length} member${members.length != 1 ? 's' : ''}',
      members: members,
      emptyMessage: 'No birthdays today',
      gradient: [accentPink, const Color(0xFFC06C84)],
      isExpanded: _birthdaysExpanded,
      onExpand: () => setState(() => _birthdaysExpanded = !_birthdaysExpanded),
      onSendAll: members.isNotEmpty ? () => _sendBulkBirthdays(members) : null,
      memberBuilder: (member) => _buildMemberTile(
        member: member,
        subtitle: member.dateOfBirth != null
        ? 'Birthday: ${DateFormat('MMM dd').format(member.dateOfBirth!)}'
      : 'Birthday today',
      color: accentPink,
      icon: Icons.cake_rounded,
      onSend: () => _sendSingleBirthday(member),
      ),
    );
  }

  // Expiring Soon Section
  Widget _buildExpiringSection() {
    final members = _expiringMembers ?? [];
    return _buildExpandableSection(
      title: '⚠️ Expiring Soon (7 days)',
      subtitle: '${members.length} member${members.length != 1 ? 's' : ''}',
      members: members,
      emptyMessage: 'No memberships expiring soon! 👍',
      gradient: [accentYellow, const Color(0xFFFFAA00)],
      isExpanded: _expiringExpanded,
      onExpand: () => setState(() => _expiringExpanded = !_expiringExpanded),
      onSendAll: members.isNotEmpty ? () => _sendBulkExpiring(members) : null,
      memberBuilder: (member) {
        final daysLeft = member.expiryDate.difference(DateTime.now()).inDays;
        return _buildMemberTile(
          member: member,
          subtitle: 'Expires in $daysLeft day${daysLeft != 1 ? 's' : ''}',
          color: daysLeft <= 1 ? accentOrange : accentYellow,
          icon: daysLeft <= 1 ? Icons.error_rounded : Icons.warning_rounded,
          onSend: () => _sendSingleExpiring(member, daysLeft),
        );
      },
    );
  }

  // Dues Section
  Widget _buildDuesSection() {
    final members = _duesMembers ?? [];
    return _buildExpandableSection(
      title: '💰 Pending Dues',
      subtitle: '${members.length} member${members.length != 1 ? 's' : ''}',
      members: members,
      emptyMessage: 'No pending dues! 🎉',
      gradient: [accentOrange, const Color(0xFFEE5A6F)],
      isExpanded: _duesExpanded,
      onExpand: () => setState(() => _duesExpanded = !_duesExpanded),
      onSendAll: members.isNotEmpty ? () => _sendBulkDues(members) : null,
      memberBuilder: (member) => _buildMemberTile(
        member: member,
        subtitle: 'Due: ₹${member.dueAmount.toStringAsFixed(0)}',
        color: accentOrange,
        icon: Icons.account_balance_wallet_rounded,
        onSend: () => _sendSingleDue(member),
      ),
    );
  }

  // Expired Section
  Widget _buildExpiredSection() {
    final members = _expiredMembers ?? [];
    return _buildExpandableSection(
      title: '🚫 Expired Memberships',
      subtitle: '${members.length} member${members.length != 1 ? 's' : ''}',
      members: members,
      emptyMessage: 'No expired memberships',
      gradient: [accentGray, const Color(0xFF757575)],
      isExpanded: _expiredExpanded,
      onExpand: () => setState(() => _expiredExpanded = !_expiredExpanded),
      onSendAll: members.isNotEmpty ? () => _sendBulkRejoin(members) : null,
      memberBuilder: (member) => _buildMemberTile(
        member: member,
        subtitle: 'Expired on ${DateFormat('dd/MM/yyyy').format(member.expiryDate)}',
        color: accentGray,
        icon: Icons.cancel_rounded,
        onSend: () => _sendSingleRejoin(member),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // REUSABLE WIDGETS
  // ═══════════════════════════════════════════════════════════════

  // Expandable Section Widget
  Widget _buildExpandableSection({
    required String title,
    required String subtitle,
    required List<MemberModel> members,
    required String emptyMessage,
    required List<Color> gradient,
    required bool isExpanded,
    required VoidCallback onExpand,
    required VoidCallback? onSendAll,
    required Widget Function(MemberModel) memberBuilder,
  }) {
    final displayCount = isExpanded ? members.length : (members.length > 5 ? 5 : members.length);
    final hasMore = members.length > 5;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradient[0].withValues(alpha: 0.1), gradient[1].withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gradient[0].withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: gradient[0],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onSendAll != null)
                  ElevatedButton.icon(
                    onPressed: onSendAll,
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Send All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gradient[0],
                      foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                    ),
                  ),
              ],
            ),
          ),

          // Members List
          if (members.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    emptyMessage,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
            else
              Column(
                children: [
                  ...members.take(displayCount).map(memberBuilder),

                  // Expand/Collapse Button
                  if (hasMore)
                    InkWell(
                      onTap: onExpand,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isExpanded
                              ? 'Show less'
                            : '+${members.length - displayCount} more',
                            style: TextStyle(
                              color: gradient[0],
                              fontWeight: FontWeight.bold,
                            ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: gradient[0],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
        ],
      ),
    );
  }

  // Member Tile (Text-only reminders)
  Widget _buildMemberTile({
    required MemberModel member,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback? onSend,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Text(
            member.name[0].toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          member.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: onSend != null
        ? IconButton(
          icon: const Icon(Icons.send_rounded, size: 20),
          color: color,
          onPressed: onSend,
        )
        : null,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SEND ACTIONS (Text-only WhatsApp Messages)
  // ═══════════════════════════════════════════════════════════════

  Future<void> _sendSingleBirthday(MemberModel member) async {
    await WhatsAppService.instance.sendBirthdayWish(member);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Birthday wish sent to ${member.name} 🎂'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _sendSingleExpiring(MemberModel member, int daysLeft) async {
    await WhatsAppService.instance.sendExpiryReminder(member, daysLeft);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Expiry reminder sent to ${member.name} ⚠️'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _sendSingleDue(MemberModel member) async {
    await WhatsAppService.instance.sendDuePaymentReminder(member);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Due reminder sent to ${member.name} 💰'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendSingleRejoin(MemberModel member) async {
    await WhatsAppService.instance.sendRejoinMessage(member);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rejoin message sent to ${member.name} 🎉'),
          backgroundColor: Colors.purple,
        ),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // BULK SEND ACTIONS
  // ═══════════════════════════════════════════════════════════════

  Future<void> _sendBulkBirthdays(List<MemberModel> members) async {
    final result = await _reminderService.sendBulkBirthdayWishes(branch: widget.branch);
    if (mounted) {
      _showResultDialog('Birthday Wishes 🎂', result);
    }
  }

  Future<void> _sendBulkExpiring(List<MemberModel> members) async {
    final result = await _reminderService.sendBulkExpiryReminders(days: 7, branch: widget.branch);
    if (mounted) {
      _showResultDialog('Expiry Reminders ⚠️', result);
    }
  }

  Future<void> _sendBulkDues(List<MemberModel> members) async {
    final result = await _reminderService.sendBulkDuesReminders(branch: widget.branch);
    if (mounted) {
      _showResultDialog('Due Payment Reminders 💰', result);
    }
  }

  Future<void> _sendBulkRejoin(List<MemberModel> members) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.orange),
            SizedBox(width: 12),
            Text('Send Rejoin Messages?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Send witty & fun messages to all expired members encouraging them to rejoin?',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Messages are personalized based on expiry duration!',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.send_rounded),
            label: const Text('Send All'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Sending rejoin messages...'),
              ],
            ),
          ),
        ),
      ),
    );

    final result = await _reminderService.sendBulkRejoinMessages(branch: widget.branch);

    if (mounted) {
      Navigator.pop(context); // Close loading dialog
      _showResultDialog('Rejoin Messages 🎉', result);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // RESULT DIALOG
  // ═══════════════════════════════════════════════════════════════

  void _showResultDialog(String title, Map<String, int> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildResultRow('Total', result['total']!),
            const SizedBox(height: 8),
            _buildResultRow('Sent', result['sent']!, Colors.green),
            const SizedBox(height: 8),
            _buildResultRow('Failed', result['failed']!, Colors.red),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, int value, [Color? color]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          '$value',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
