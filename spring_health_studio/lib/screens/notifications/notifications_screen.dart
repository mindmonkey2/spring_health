import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  final String? branch;

  const NotificationsScreen({super.key, this.branch});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notificationService = NotificationService();
  bool _isProcessing = false;

  static const Color sageGreen = Color(0xFF10B981);
  static const Color tealAqua = Color(0xFF14B8A6);
  static const Color warmYellow = Color(0xFFFCD34D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Notifications'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [sageGreen, tealAqua]),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: _isProcessing
      ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Sending messages...'),
            Text(
              'Please wait, this may take a few minutes',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      )
      : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationCard(
            icon: Icons.cake,
            title: 'Birthday Wishes',
            subtitle: 'Send birthday wishes to members celebrating today',
            color: warmYellow,
            onTap: _sendBirthdayWishes,
          ),
          const SizedBox(height: 16),
          _buildNotificationCard(
            icon: Icons.alarm,
            title: 'Expiry Reminders',
            subtitle: 'Send reminders to members whose membership is expiring soon',
            color: Colors.orange,
            onTap: _sendExpiryReminders,
          ),
          const SizedBox(height: 16),
          _buildNotificationCard(
            icon: Icons.payment,
            title: 'Due Payment Reminders',
            subtitle: 'Send payment reminders to members with pending dues',
            color: Colors.red,
            onTap: _sendDueReminders,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendBirthdayWishes() async {
    final confirm = await _showConfirmDialog(
      'Send Birthday Wishes?',
      'This will send birthday wishes to all members celebrating their birthday today.',
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    try {
      final sentTo = await _notificationService.sendBirthdayWishes(
        branch: widget.branch,
      );

      if (!mounted) return;

      _showResultDialog(
        'Birthday Wishes Sent!',
        sentTo.isEmpty
        ? 'No birthdays today!'
      : 'Sent to ${sentTo.length} member(s):\n\n${sentTo.join('\n')}',
      sentTo.isNotEmpty,
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Error sending birthday wishes: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _sendExpiryReminders() async {
    final confirm = await _showConfirmDialog(
      'Send Expiry Reminders?',
      'This will send reminders to members whose membership is expiring in 7 days, 3 days, or 1 day.',
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    try {
      final results = await _notificationService.sendExpiryReminders(
        branch: widget.branch,
      );

      if (!mounted) return;

      final total = results.total;

      _showResultDialog(
        'Expiry Reminders Sent!',
        total == 0
        ? 'No members expiring soon!'
      : '7 days: ${results.sevenDays.length}\n'
      '3 days: ${results.threeDays.length}\n'
      '1 day: ${results.oneDay.length}\n\n'
      'Total sent: $total',
      total > 0,
      );

    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Error sending expiry reminders: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _sendDueReminders() async {
    final confirm = await _showConfirmDialog(
      'Send Due Payment Reminders?',
      'This will send payment reminders to all members with pending dues.',
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    try {
      final sentTo = await _notificationService.sendDuePaymentReminders(
        branch: widget.branch,
      );

      if (!mounted) return;

      _showResultDialog(
        'Due Reminders Sent!',
        sentTo.isEmpty
        ? 'No members with pending dues!'
      : 'Sent to ${sentTo.length} member(s):\n\n${sentTo.join('\n')}',
      sentTo.isNotEmpty,
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Error sending due reminders: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: sageGreen),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(String title, String message, bool success) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.info,
              color: success ? Colors.green : Colors.orange,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: sageGreen),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
