// lib/screens/members/member_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../models/member_model.dart';
import '../../../models/attendance_model.dart';
import '../../../models/payment_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/pdf_service.dart';
import '../../../utils/date_utils.dart' as app_date_utils;
import 'edit_member_screen.dart';
import 'collect_dues_screen.dart';
import 'rejoin_member_screen.dart';
import 'member_fitness_tab.dart'; // NEW
import '../../../services/whatsapp_service.dart';
import '../../../widgets/document_send_dialog.dart';
import '../../../theme/app_colors.dart';

class MemberDetailScreen extends StatefulWidget {
  final MemberModel member;
  const MemberDetailScreen({super.key, required this.member});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen>
    with SingleTickerProviderStateMixin {
  final firestoreService = FirestoreService();
  final pdfService       = PDFService();

  late TabController _tabController;
  MemberModel? currentMember;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadMemberData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _isActive =>
      currentMember != null &&
      DateTime.now().isBefore(currentMember!.expiryDate);

  // ── Data ─────────────────────────────────────────────────────────

  Future<void> _loadMemberData() async {
    try {
      final m = await firestoreService.getMemberById(widget.member.id);
      if (mounted) setState(() { currentMember = m ?? widget.member; isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { currentMember = widget.member; isLoading = false; });
    }
  }

  // ── Options menu ─────────────────────────────────────────────────

  Future<void> _showOptionsMenu() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            _optionTile(Icons.edit_rounded,       'Edit Member',           AppColors.turquoise,   'edit'),
            if ((currentMember?.dueAmount ?? 0) > 0)
              _optionTile(Icons.currency_rupee,   'Collect Dues',          AppColors.success,  'collectdues',
                  subtitle: 'Due: Rs. ${currentMember!.dueAmount.toStringAsFixed(0)}'),
            if (!_isActive)
              _optionTile(Icons.refresh_rounded,  'Rejoin Membership',     AppColors.success,  'rejoin',
                  subtitle: 'Renew expired membership'),
            _optionTile(Icons.message_rounded,    'Send WhatsApp Reminder', AppColors.whatsApp, 'whatsapp'),
            _optionTile(
              currentMember?.isArchived == true ? Icons.unarchive_rounded : Icons.archive_rounded,
              currentMember?.isArchived == true ? 'Restore Member' : 'Archive Member',
              AppColors.warning, 'archive',
            ),
            _optionTile(Icons.qr_code_rounded,    'Show QR Code',          AppColors.turquoise,   'showqr'),
            _optionTile(Icons.share_rounded,      'Share Membership Card', AppColors.success,  'sharecard'),
            _optionTile(Icons.picture_as_pdf,     'Download Invoice',      AppColors.error,   'downloadinvoice'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (result == null || !mounted) return;
    switch (result) {
      case 'edit':
        final updated = await Navigator.push<bool>(context,
            MaterialPageRoute(builder: (_) => EditMemberScreen(member: currentMember!)));
        if (updated == true) _loadMemberData();
      case 'collectdues':
        final updated = await Navigator.push<bool>(context,
            MaterialPageRoute(builder: (_) => CollectDuesScreen(member: currentMember!)));
        if (updated == true) _loadMemberData();
      case 'rejoin':
        final updated = await Navigator.push<bool>(context,
            MaterialPageRoute(builder: (_) => RejoinMemberScreen(member: currentMember!)));
        if (updated == true) _loadMemberData();
      case 'whatsapp':
        _showWhatsAppOptions();
      case 'archive':
        _toggleArchive();
      case 'showqr':
        _showQRCode();
      case 'sharecard':
        _shareMembershipCard();
      case 'downloadinvoice':
        _downloadInvoice();
    }
  }

  Widget _optionTile(IconData icon, String title, Color color, String value,
      {String? subtitle}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: () => Navigator.pop(context, value),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────

  Future<void> _toggleArchive() async {
    if (currentMember == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(currentMember!.isArchived ? 'Restore Member?' : 'Archive Member?'),
        content: Text(currentMember!.isArchived
            ? 'This will restore the member to active status.'
            : 'This will archive the member. You can restore them later.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      final updated = currentMember!.copyWith(isArchived: !currentMember!.isArchived);
      await firestoreService.updateMember(updated);
      if (!mounted) return;
      _loadMemberData();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(updated.isArchived ? 'Member archived.' : 'Member restored.'),
        backgroundColor: AppColors.success,
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  Future<void> _showQRCode() async {
    if (currentMember == null || !mounted) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Membership QR Code',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.turquoise.withValues(alpha: 0.4), width: 2),
              ),
              child: QrImageView(
                  data: currentMember!.qrCode,
                  version: QrVersions.auto,
                  size: 200),
            ),
            const SizedBox(height: 16),
            Text(currentMember!.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('ID: ${currentMember!.id}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                child: const Text('Close'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _shareMembershipCard() async {
    if (currentMember == null) return;
    try {
      final pdf  = await pdfService.generateMembershipCard(currentMember!);
      final file = await pdfService.savePDF(pdf, 'membershipcard_${currentMember!.id}');
      await Share.shareXFiles([XFile(file.path)]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing card: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  Future<void> _downloadInvoice() async {
    if (currentMember == null) return;
    try {
      final pdf  = await pdfService.generateInvoice(currentMember!);
      final file = await pdfService.savePDF(pdf, 'invoice_${currentMember!.id}');
      await Share.shareXFiles([XFile(file.path)]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice downloaded!'), backgroundColor: AppColors.success));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  // ── WhatsApp ─────────────────────────────────────────────────────

  void _showWhatsAppOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Send WhatsApp Message',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _waOption(Icons.picture_as_pdf,  'Resend Documents',    'Invoice & Membership Card PDFs', () { Navigator.pop(context); _resendDocuments(); }),
          _waOption(Icons.waving_hand,     'Welcome Message',     'Send welcome message to member', () { Navigator.pop(context); _sendWhatsApp('welcome'); }),
          _waOption(Icons.receipt_long,    'Payment Receipt',     'Send latest payment receipt',   () { Navigator.pop(context); _sendWhatsApp('receipt'); }),
          if ((currentMember?.expiryDate.difference(DateTime.now()).inDays ?? 999) < 7)
            _waOption(Icons.alarm_rounded, 'Expiry Reminder',     'Send membership expiry reminder', () { Navigator.pop(context); _sendWhatsApp('expiry'); }),
          if ((currentMember?.dueAmount ?? 0) > 0)
            _waOption(Icons.payment,       'Due Payment Reminder','Send pending payment reminder',  () { Navigator.pop(context); _sendWhatsApp('due'); }),
          _waOption(Icons.message_rounded, 'Custom Message',      'Send a custom message',          () { Navigator.pop(context); _sendWhatsApp('custom'); }),
        ]),
      ),
    );
  }

  Widget _waOption(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: CircleAvatar(
          backgroundColor: AppColors.whatsApp.withValues(alpha: 0.1),
          child: Icon(icon, color: AppColors.whatsApp)),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Future<void> _sendWhatsApp(String type) async {
    if (type == 'custom') { _showCustomMessageDialog(); return; }
    setState(() => isLoading = true);
    try {
      bool sent = false;
      switch (type) {
        case 'welcome':
          sent = await WhatsAppService.instance.sendWelcomeMessage(currentMember!);
        case 'receipt':
          final payments = await firestoreService.getPaymentsByMember(currentMember!.id).first;
          if (payments.isNotEmpty) {
            sent = await WhatsAppService.instance.sendPaymentReceipt(
                member: currentMember!, payment: payments.first);
          }
        case 'expiry':
          final d = currentMember!.expiryDate.difference(DateTime.now()).inDays;
          sent = await WhatsAppService.instance.sendExpiryReminder(currentMember!, d);
        case 'due':
          sent = await WhatsAppService.instance.sendDuePaymentReminder(currentMember!);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(sent ? 'WhatsApp opened successfully!' : 'Could not open WhatsApp'),
        backgroundColor: sent ? AppColors.success : AppColors.error,
      ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showCustomMessageDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Send Custom Message'),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          decoration: const InputDecoration(
              hintText: 'Enter your message…', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              Navigator.pop(context);
              final sent = await WhatsAppService.instance.sendCustomMessage(
                phoneNumber: currentMember!.phone,
                memberName: currentMember!.name,
                customMessage: ctrl.text.trim(),
                branch: currentMember!.branch,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(sent ? 'WhatsApp opened!' : 'Could not open WhatsApp'),
                backgroundColor: sent ? AppColors.success : AppColors.error,
              ));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _resendDocuments() async {
    if (currentMember == null) return;
    final sent = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DocumentSendDialog(
        member: currentMember!,
        documentType: 'resend',
        title: 'Resend Documents',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send documents to ${currentMember!.name}',
                style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Icon(Icons.picture_as_pdf, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text('Documents to Send',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ]),
                const SizedBox(height: 8),
                Text('• Payment Invoice\n• Membership Card with QR Code',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ]),
            ),
            if (currentMember!.documentHistory.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Last sent: ${currentMember!.documentHistory.last.displayText}',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic)),
            ],
          ],
        ),
      ),
    );
    if (sent == true && mounted) _loadMemberData();
  }

  // ── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Member Details'),
          flexibleSpace: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.success, AppColors.turquoise]))),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.success)),
      );
    }
    if (currentMember == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Member Details')),
        body: const Center(child: Text('Member not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          // Status dot
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(
              color: _isActive ? AppColors.success : AppColors.error,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                  color: (_isActive ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.6),
                  blurRadius: 6)],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              currentMember!.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ]),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.success, AppColors.turquoise]),
          ),
        ),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_rounded),
            onPressed: _showWhatsAppOptions,
            tooltip: 'Send WhatsApp',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showOptionsMenu,
            tooltip: 'More options',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(icon: Icon(Icons.person_rounded,      size: 18), text: 'Info'),
            Tab(icon: Icon(Icons.card_membership,     size: 18), text: 'Membership'),
            Tab(icon: Icon(Icons.payments_rounded,    size: 18), text: 'Payments'),
            Tab(icon: Icon(Icons.event_available,     size: 18), text: 'Attendance'),
            Tab(icon: Icon(Icons.fitness_center,      size: 18), text: 'Fitness'),
            Tab(icon: Icon(Icons.description_rounded, size: 18), text: 'Documents'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicInfoTab(),
          _buildMembershipTab(),
          _buildPaymentsTab(),
          _buildAttendanceTab(),
          MemberFitnessTab(memberId: currentMember!.id),  // NEW
          _buildDocumentHistoryTab(),
        ],
      ),
    );
  }

  // ── Tab 1 : Basic Info ───────────────────────────────────────────

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Avatar + name hero
        Center(
          child: Column(children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isActive
                      ? [AppColors.success, AppColors.turquoise]
                      : [AppColors.error, AppColors.warning],
                ),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(
                  color: (_isActive ? AppColors.success : AppColors.error).withValues(alpha: 0.4),
                  blurRadius: 20, offset: const Offset(0, 8),
                )],
              ),
              child: Center(
                child: Text(
                  currentMember!.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                      fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(currentMember!.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('ID: ${currentMember!.id}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 8),
            // Status chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isActive
                      ? [AppColors.success, AppColors.turquoise]
                      : [AppColors.error, AppColors.warning],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_isActive ? Icons.verified_rounded : Icons.error_rounded,
                    color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(_isActive ? 'Active Member' : 'Expired',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 24),

        // Contact card
        _buildInfoCard([
          _buildInfoRow(Icons.phone_rounded,    'Phone',    currentMember!.phone),
          _buildInfoRow(Icons.email_rounded,    'Email',    currentMember!.email.isEmpty ? '—' : currentMember!.email),
          _buildInfoRow(Icons.wc_rounded,       'Gender',   currentMember!.gender),
          if (currentMember!.dateOfBirth != null)
            _buildInfoRow(Icons.cake_rounded,   'Birthday', app_date_utils.DateUtils.formatDate(currentMember!.dateOfBirth!)),
          _buildInfoRow(Icons.location_on_rounded, 'Branch', currentMember!.branch),
        ]),

        const SizedBox(height: 16),

        // WhatsApp quick action
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showWhatsAppOptions,
            icon: const Icon(Icons.chat_rounded, color: AppColors.whatsApp),
            label: const Text('Send WhatsApp Message',
                style: TextStyle(color: AppColors.whatsApp)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.whatsApp),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Tab 2 : Membership ───────────────────────────────────────────

  Widget _buildMembershipTab() {
    final now         = DateTime.now();
    final daysLeft    = currentMember!.expiryDate.difference(now).inDays;
    final totalDays   = currentMember!.expiryDate
        .difference(currentMember!.joiningDate)
        .inDays
        .clamp(1, 99999);
    final elapsed     = now.difference(currentMember!.joiningDate).inDays.clamp(0, totalDays);
    final progress    = elapsed / totalDays;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Expiry countdown banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isActive
                  ? (daysLeft <= 7
                      ? [AppColors.warning, AppColors.warningDark]
                      : [AppColors.success, AppColors.turquoise])
                  : [AppColors.error, AppColors.warning],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              _isActive
                  ? daysLeft == 0
                      ? 'Expires today!'
                      : '$daysLeft day${daysLeft == 1 ? '' : 's'} remaining'
                  : 'Expired ${-daysLeft} day${daysLeft == -1 ? '' : 's'} ago',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.toDouble(),
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${app_date_utils.DateUtils.formatDate(currentMember!.joiningDate)} → '
              '${app_date_utils.DateUtils.formatDate(currentMember!.expiryDate)}',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        _buildInfoCard([
          _buildInfoRow(Icons.fitness_center_rounded, 'Category', currentMember!.category),
          _buildInfoRow(Icons.calendar_today_rounded, 'Plan',     currentMember!.plan),
          _buildInfoRow(Icons.event_rounded,     'Joining Date', app_date_utils.DateUtils.formatDate(currentMember!.joiningDate)),
          _buildInfoRow(Icons.event_busy_rounded, 'Expiry Date', app_date_utils.DateUtils.formatDate(currentMember!.expiryDate),
              valueColor: _isActive ? AppColors.success : AppColors.error),
          _buildInfoRow(Icons.verified_rounded,   'Status',
              _isActive ? 'Active' : 'Expired',
              valueColor: _isActive ? AppColors.success : AppColors.error),
        ]),
        const SizedBox(height: 16),

        // Fee details
        const Text('Fee Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildInfoCard([
          _buildInfoRow(Icons.currency_rupee, 'Total Fee', currentMember!.totalFee.toStringAsFixed(2)),
          if (currentMember!.discount > 0) ...[
            _buildInfoRow(Icons.discount_rounded, 'Discount',
                '- Rs. ${currentMember!.discount.toStringAsFixed(2)}',
                valueColor: AppColors.success),
            if (currentMember!.discountDescription.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 48, top: 2, bottom: 4),
                child: Text(currentMember!.discountDescription,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic)),
              ),
          ],
          const Divider(),
          _buildInfoRow(Icons.payments_rounded, 'Final Amount',
              'Rs. ${currentMember!.finalAmount.toStringAsFixed(2)}',
              isHighlighted: true),
          _buildInfoRow(Icons.check_circle_rounded, 'Paid',
              'Rs. ${(currentMember!.finalAmount - currentMember!.dueAmount).toStringAsFixed(2)}',
              valueColor: AppColors.turquoise),
          if (currentMember!.dueAmount > 0)
            _buildInfoRow(Icons.warning_rounded, 'Due',
                'Rs. ${currentMember!.dueAmount.toStringAsFixed(2)}',
                valueColor: AppColors.error),
        ]),
      ]),
    );
  }

  // ── Tab 3 : Payments ─────────────────────────────────────────────

  Widget _buildPaymentsTab() {
    return StreamBuilder<List<PaymentModel>>(
      stream: firestoreService.getPaymentsByMember(
          currentMember!.id, branch: currentMember!.branch),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.success));
        }
        final payments = snapshot.data ?? [];
        if (payments.isEmpty) {
          return Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.payment_rounded, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text('No payment history',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            ]),
          );
        }

        // Summary strip
        final totalPaid = payments.fold<double>(0, (sum, p) => sum + p.amount);
        final due = currentMember!.dueAmount;

        return Column(children: [
          // Header summary
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.success, AppColors.turquoise]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _paymentStat('${payments.length}', 'Transactions',
                    Icons.receipt_long_rounded),
                Container(width: 1, height: 40,
                    color: Colors.white.withValues(alpha: 0.3)),
                _paymentStat('Rs. ${totalPaid.toStringAsFixed(0)}', 'Total Paid',
                    Icons.currency_rupee),
                Container(width: 1, height: 40,
                    color: Colors.white.withValues(alpha: 0.3)),
                _paymentStat('Rs. ${due.toStringAsFixed(0)}', 'Due',
                    Icons.warning_rounded),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: payments.length,
              itemBuilder: (_, i) {
                final p = payments[i];
                final isInitial = p.type.toLowerCase() == 'initial';
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(children: [
                      CircleAvatar(
                        backgroundColor: (isInitial ? AppColors.turquoise : AppColors.warning)
                            .withValues(alpha: 0.2),
                        child: Icon(
                          isInitial ? Icons.person_add_rounded : Icons.refresh_rounded,
                          color: isInitial ? AppColors.turquoise : AppColors.warningDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('Rs. ${p.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 2),
                          Text(app_date_utils.DateUtils.formatDateTime(p.paymentDate),
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12)),
                          const SizedBox(height: 4),
                          Row(children: [
                            _modeBadge(p.paymentMode),
                            if (p.paymentMode.toLowerCase() == 'mixed') ...[
                              const SizedBox(width: 6),
                              Text(
                                'Cash ${p.cashAmount.toStringAsFixed(0)} + UPI ${p.upiAmount.toStringAsFixed(0)}',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ]),
                        ]),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (isInitial ? AppColors.turquoise : AppColors.warningDark)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: isInitial ? AppColors.turquoise : AppColors.warningDark,
                                  width: 1.2),
                            ),
                            child: Text(
                              p.type.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isInitial ? AppColors.turquoise : AppColors.warningDark,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _PaymentReceiptButton(
                            payment: p,
                            member: currentMember!,
                            pdfService: pdfService,
                            tealAqua: AppColors.turquoise,
                            coralRed: AppColors.error,
                          ),
                        ],
                      ),
                    ]),
                  ),
                );
              },
            ),
          ),
        ]);
      },
    );
  }

  Widget _paymentStat(String value, String label, IconData icon) {
    return Column(children: [
      Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 18),
      const SizedBox(height: 4),
      Text(value,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      Text(label,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
    ]);
  }

  Widget _modeBadge(String mode) {
    Color c;
    switch (mode.toLowerCase()) {
      case 'cash':  c = AppColors.success; break;
      case 'upi':   c = AppColors.turquoise;  break;
      default:      c = AppColors.warning;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.withValues(alpha: 0.5)),
      ),
      child: Text(mode.toUpperCase(),
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.bold, color: c)),
    );
  }

  // ── Tab 4 : Attendance ───────────────────────────────────────────

  Widget _buildAttendanceTab() {
    return StreamBuilder<List<AttendanceModel>>(
      stream: firestoreService.getAttendanceByMember(
          currentMember!.id, branch: currentMember!.branch),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.success));
        }

        final records = snapshot.data ?? [];
        // Sort newest first
        records.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));

        if (records.isEmpty) {
          return Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.event_busy_rounded, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text('No attendance history',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            ]),
          );
        }

        final now       = DateTime.now();
        final thisMonth = records.where((r) =>
          r.checkInTime.month == now.month && r.checkInTime.year == now.year).length;

        return Column(children: [
          // Summary strip
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.success, AppColors.turquoise]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _paymentStat('${records.length}', 'Total Visits',
                    Icons.check_circle_rounded),
                Container(width: 1, height: 40,
                    color: Colors.white.withValues(alpha: 0.3)),
                _paymentStat('$thisMonth', 'This Month',
                    Icons.calendar_month_rounded),
                Container(width: 1, height: 40,
                    color: Colors.white.withValues(alpha: 0.3)),
                _paymentStat(
                  app_date_utils.DateUtils.formatDate(records.first.checkInTime),
                  'Last Visit',
                  Icons.access_time_rounded,
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: records.length,
              itemBuilder: (_, i) {
                final r = records[i];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.success.withValues(alpha: 0.15),
                      child: Text('${i + 1}',
                          style: const TextStyle(
                              color: AppColors.success, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(
                      app_date_utils.DateUtils.formatDateTime(r.checkInTime),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(r.branch),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.turquoise.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.login_rounded,
                          color: AppColors.turquoise, size: 18),
                    ),
                  ),
                );
              },
            ),
          ),
        ]);
      },
    );
  }

  // ── Tab 6 : Documents ────────────────────────────────────────────

  Widget _buildDocumentHistoryTab() {
    if (currentMember == null) {
      return const Center(child: Text('No data available'));
    }

    return Column(children: [
      // Send Documents button at top
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _resendDocuments,
            icon: const Icon(Icons.send_rounded),
            label: const Text('Send Documents via WhatsApp'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),

      if (currentMember!.documentHistory.isEmpty)
        Expanded(
          child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.article_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text('No documents sent yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            ]),
          ),
        )
      else
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: currentMember!.documentHistory.length,
            itemBuilder: (_, i) {
              final doc = currentMember!.documentHistory.reversed.toList()[i];

              IconData icon;
              Color color;
              String displayType;
              switch (doc.type) {
                case 'welcome':
                  icon = Icons.celebration_rounded;
                  color = AppColors.success;
                  displayType = 'Welcome Package';
                case 'rejoin':
                  icon = Icons.refresh_rounded;
                  color = AppColors.warning;
                  displayType = 'Rejoin Package';
                case 'receipt':
                  icon = Icons.receipt_long_rounded;
                  color = AppColors.info;
                  displayType = 'Payment Receipt';
                case 'resend':
                  icon = Icons.send_rounded;
                  color = AppColors.turquoise;
                  displayType = 'Documents Resent';
                default:
                  icon = Icons.description_rounded;
                  color = AppColors.textSecondary;
                  displayType = doc.type;
              }

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (doc.success ? color : AppColors.error)
                        .withValues(alpha: 0.15),
                    child: Icon(icon,
                        color: doc.success ? color : AppColors.error, size: 22),
                  ),
                  title: Text(displayType,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(children: [
                        Icon(
                          doc.method == 'whatsapp'
                              ? Icons.chat_rounded
                              : doc.method == 'email'
                                  ? Icons.email_rounded
                                  : Icons.share_rounded,
                          size: 13, color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(doc.method.toUpperCase(),
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade600)),
                        const SizedBox(width: 10),
                        Icon(Icons.access_time_rounded,
                            size: 13, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          app_date_utils.DateUtils.formatDateTime(doc.sentAt),
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ]),
                      const SizedBox(height: 2),
                      Text('Sent by ${doc.sentBy}',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (doc.success ? AppColors.success : AppColors.error)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(
                        doc.success
                            ? Icons.check_circle_rounded
                            : Icons.error_rounded,
                        size: 14,
                        color: doc.success ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        doc.success ? 'Sent' : 'Failed',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: doc.success ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
    ]);
  }

  // ── Shared widgets ───────────────────────────────────────────────

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon, String label, String value, {
    Color? valueColor,
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            fontSize: isHighlighted ? 16 : 14,
            color: valueColor,
          ),
        ),
      ]),
    );
  }
}

class _PaymentReceiptButton extends StatefulWidget {
  final PaymentModel payment;
  final MemberModel member;
  final PDFService pdfService;
  final Color tealAqua;
  final Color coralRed;

  const _PaymentReceiptButton({
    required this.payment,
    required this.member,
    required this.pdfService,
    required this.tealAqua,
    required this.coralRed,
  });

  @override
  State<_PaymentReceiptButton> createState() => _PaymentReceiptButtonState();
}

class _PaymentReceiptButtonState extends State<_PaymentReceiptButton> {
  final ValueNotifier<bool> _isGenerating = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isGenerating.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isGenerating,
      builder: (context, isGenerating, child) {
        return IconButton(
          icon: isGenerating
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: widget.tealAqua,
                  ),
                )
              : Icon(Icons.receipt_long, color: widget.tealAqua),
          onPressed: isGenerating
              ? null
              : () async {
                  _isGenerating.value = true;
                  try {
                    final pdfData = await widget.pdfService.generatePaymentReceipt(
                      member: widget.member,
                      payment: widget.payment,
                    );
                    if (context.mounted) {
                      await widget.pdfService.printPDF(pdfData);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: widget.coralRed,
                        ),
                      );
                    }
                  } finally {
                    _isGenerating.value = false;
                  }
                },
          tooltip: 'Generate Receipt',
        );
      },
    );
  }
}
