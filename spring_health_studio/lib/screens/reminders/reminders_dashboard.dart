import 'package:flutter/material.dart';
import '../../services/reminder_service.dart';
import '../../models/member_model.dart';
import 'package:intl/intl.dart';

class RemindersDashboard extends StatefulWidget {
  final String? branch;

  const RemindersDashboard({super.key, this.branch});

  @override
  State<RemindersDashboard> createState() => _RemindersDashboardState();
}

class _RemindersDashboardState extends State<RemindersDashboard>
with SingleTickerProviderStateMixin {
  final _reminderService = ReminderService();
  bool _isLoading = false;
  late TabController _tabController;

  static const Color primaryPurple = Color(0xFF667EEA);
  static const Color deepPurple = Color(0xFF764BA2);
  static const Color accentOrange = Color(0xFFFF6B6B);
  static const Color accentYellow = Color(0xFFFFE66D);
  static const Color accentPink = Color(0xFFFF6B9D);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Payment Reminders',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryPurple, deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Dues'),
              Tab(text: 'Expiring'),
              Tab(text: 'Birthdays'),
              Tab(text: 'Templates'),
            ],
          ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildDuesTab(),
              _buildExpiringTab(),
              _buildBirthdaysTab(),
              _buildTemplatesTab(),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Sending reminders...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDuesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickAction(
            'Send All Dues Reminders',
            Icons.send_rounded,
            [accentOrange, const Color(0xFFEE5A6F)],
            () => _sendBulkReminders('dues'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Members with Pending Dues',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<MemberModel>>(
            future: _reminderService.getMembersWithDues(branch: widget.branch),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState('No pending dues! ');
              }

              return Column(
                children: snapshot.data!.map((member) {
                  return _buildMemberCard(
                    member: member,
                    subtitle: 'Dues: Rs.${member.dueAmount.toStringAsFixed(0)}',
                    color: accentOrange,
                    onSend: () => _sendSingleReminder(member, 'dues'),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpiringTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  '3 Days',
                  Icons.warning_rounded,
                  [accentYellow, const Color(0xFFFFAA00)],
                  () => _sendBulkReminders('expiry_3'),
                  compact: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  '1 Day',
                  Icons.error_rounded,
                  [accentOrange, const Color(0xFFEE5A6F)],
                  () => _sendBulkReminders('expiry_1'),
                  compact: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Expiring in Next 3 Days',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<MemberModel>>(
            future: _reminderService.getMembersExpiringSoon(
              days: 3,
              branch: widget.branch,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState('No memberships expiring soon! ');
              }

              return Column(
                children: snapshot.data!.map((member) {
                  final daysLeft = member.expiryDate.difference(DateTime.now()).inDays;
                  return _buildMemberCard(
                    member: member,
                    subtitle: 'Expires in $daysLeft day${daysLeft > 1 ? 's' : ''}',
                    color: daysLeft <= 1 ? accentOrange : accentYellow,
                    onSend: () => _sendSingleReminder(member, 'expiry'),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBirthdaysTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickAction(
            'Send All Birthday Wishes',
            Icons.cake_rounded,
            [accentPink, const Color(0xFFC06C84)],
            () => _sendBulkReminders('birthday'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Birthdays Today',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<MemberModel>>(
            future: _reminderService.getTodayBirthdays(branch: widget.branch),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState('No birthdays today!');
              }

              return Column(
                children: snapshot.data!.map((member) {
                  return _buildMemberCard(
                    member: member,
                    subtitle: 'Birthday: ${DateFormat('MMM dd').format(member.dateOfBirth!)}',
                    color: accentPink,
                    onSend: () => _sendSingleReminder(member, 'birthday'),
                    icon: Icons.cake_rounded,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesTab() {
    final templates = _reminderService.getMessageTemplates();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Message Templates',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Preview of automated messages sent to members',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        ...templates.entries.map((entry) {
          return _buildTemplateCard(entry.key, entry.value);
        }),
      ],
    );
  }

  Widget _buildQuickAction(
    String title,
    IconData icon,
    List<Color> gradient,
    VoidCallback onTap, {
      bool compact = false,
    }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(compact ? 16 : 20),
            child: compact
            ? Column(
              children: [
                Icon(icon, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            )
            : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    }

    Widget _buildMemberCard({
      required MemberModel member,
      required String subtitle,
      required Color color,
      required VoidCallback onSend,
      IconData icon = Icons.person,
    }) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          title: Text(
            member.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(subtitle),
              Text(
                member.phone,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.send_rounded),
            color: primaryPurple,
            onPressed: onSend,
            tooltip: 'Send reminder',
          ),
        ),
      );
    }

    Widget _buildEmptyState(String message) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.check_circle, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildTemplateCard(String title, String template) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryPurple, deepPurple],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    title.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              template,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    Future<void> _sendSingleReminder(MemberModel member, String type) async {
      setState(() => _isLoading = true);

      bool success = false;
      if (type == 'dues') {
        success = await _reminderService.sendDuesReminder(member);
      } else if (type == 'expiry') {
        final daysLeft = member.expiryDate.difference(DateTime.now()).inDays;
        success = await _reminderService.sendExpiryReminder(member, daysLeft: daysLeft);
      } else if (type == 'birthday') {
        success = await _reminderService.sendBirthdayWish(member);
      }

      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
            ? 'Reminder sent to ${member.name}'
          : 'Failed to send reminder',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }

    Future<void> _sendBulkReminders(String type) async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Send Bulk Reminders'),
          content: Text(
            'Send ${_getReminderTypeName(type)} reminders to all members?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Send All'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      setState(() => _isLoading = true);

      Map<String, int> results;
      if (type == 'dues') {
        results = await _reminderService.sendBulkDuesReminders(branch: widget.branch);
      } else if (type == 'expiry_3' || type == 'expiry_1') {
        final days = type == 'expiry_3' ? 3 : 1;
        results = await _reminderService.sendBulkExpiryReminders(
          days: days,
          branch: widget.branch,
        );
      } else {
        results = await _reminderService.sendBulkBirthdayWishes(branch: widget.branch);
      }

      setState(() => _isLoading = false);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 12),
              Text('Reminders Sent'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResultRow('Total Members', results['total']!),
              const SizedBox(height: 8),
              _buildResultRow('Successfully Sent', results['sent']!, Colors.green),
              const SizedBox(height: 8),
              _buildResultRow('Failed', results['failed']!, Colors.red),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      );
    }

    String _getReminderTypeName(String type) {
      switch (type) {
        case 'dues':
          return 'payment dues';
        case 'expiry_3':
          return 'membership expiry (3 days)';
        case 'expiry_1':
          return 'membership expiry (1 day)';
        case 'birthday':
          return 'birthday';
        default:
          return 'reminder';
      }
    }
}
