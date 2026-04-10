import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WarAdminScreen extends StatefulWidget {
  final String branch;
  const WarAdminScreen({super.key, required this.branch});

  @override
  State<WarAdminScreen> createState() => _WarAdminScreenState();
}

class _WarAdminScreenState extends State<WarAdminScreen> {
  Map<String, dynamic>? _activeWar;
  String? _activeWarId;
  bool _isLoading = true;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _loadActiveWar();
  }

  Future<void> _loadActiveWar() async {
    setState(() => _isLoading = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('weeklywars')
          .where('branchId', isEqualTo: widget.branch)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        final doc = snap.docs.first;
        _activeWar = doc.data();
        _activeWarId = doc.id;
      } else {
        _activeWar = null;
        _activeWarId = null;
      }
    } catch (e) {
      debugPrint('Error loading active war: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(Timestamp ts) {
    final dt = ts.toDate();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}';
  }

  Future<void> _startWar() async {
    final now = DateTime.now();

    final existingWarsSnap = await FirebaseFirestore.instance
        .collection('weeklywars')
        .where('branchId', isEqualTo: widget.branch.toLowerCase())
        .get();
    final warCount = existingWarsSnap.docs.length;

    const warSchedule = [
      {'category': 'Upper Body', 'exercise': 'Push-ups', 'unit': 'reps'},
      {'category': 'Lower Body', 'exercise': 'Squats', 'unit': 'reps'},
      {'category': 'Core', 'exercise': 'Plank', 'unit': 'seconds'},
      {'category': 'Full Body', 'exercise': 'Burpees', 'unit': 'reps'},
      {'category': 'Cardio', 'exercise': 'High Knees', 'unit': 'reps'},
      {'category': 'Gym Equip', 'exercise': 'Deadlift', 'unit': 'reps'},
      {'category': 'Upper Body', 'exercise': 'Pull-ups', 'unit': 'reps'},
    ];
    final slot = warSchedule[warCount % 7];

    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(monday.year, monday.month, monday.day, 6, 0);
    final friday = monday.add(const Duration(days: 4));
    final endDate = DateTime(friday.year, friday.month, friday.day, 23, 59);

    try {
      await FirebaseFirestore.instance.collection('weeklywars').add({
        'branchId': widget.branch,
        'weekNumber': warCount + 1,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'exercise': slot['exercise'],
        'unit': slot['unit'],
        'category': slot['category'],
        'status': 'active',
        'prizePool': {'rank1': 500, 'rank2': 300, 'rank3': 150, 'participation': 20},
        'createdAt': Timestamp.now(),
      });

      await _loadActiveWar();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('War started! ${slot['exercise']} week is live ⚔️')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start war: $e')),
        );
      }
    }
  }

  Future<void> _completeWar() async {
    if (_activeWarId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete War?'),
        content: const Text(
            'This will lock the war, assign final ranks, and distribute XP to all participants. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Complete', style: TextStyle(color: Colors.amber))),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isCompleting = true);

    try {
      final entriesSnap = await FirebaseFirestore.instance
          .collection('weeklywars')
          .doc(_activeWarId)
          .collection('entries')
          .get();

      final entries = entriesSnap.docs
          .map((d) => {'id': d.id, ...d.data()})
          .toList()
        ..sort((a, b) => (b['totalReps'] as int).compareTo(a['totalReps'] as int));

      final batch = FirebaseFirestore.instance.batch();
      for (int i = 0; i < entries.length; i++) {
        final entryRef = FirebaseFirestore.instance
            .collection('weeklywars')
            .doc(_activeWarId)
            .collection('entries')
            .doc(entries[i]['id'] as String);
        batch.update(entryRef, {'rank': i + 1});
      }
      await batch.commit();

      for (int i = 0; i < entries.length; i++) {
        final memberId = entries[i]['memberId'] as String;
        final rank = i + 1;
        String event;
        int? customXP;

        if (rank == 1) {
          event = 'war_winner';
        } else if (rank == 2) {
          event = 'war_top3';
          customXP = 300;
        } else if (rank == 3) {
          event = 'war_top3';
          customXP = 150;
        } else if (rank <= 10) {
          event = 'war_top3';
          customXP = 50;
        } else {
          event = 'war_participate';
        }

        await FirebaseFirestore.instance.collection('gamification_events').add({
          'memberId': memberId,
          'event': event,
          if (customXP != null) 'customXP': customXP,
          'timestamp': Timestamp.now(),
          'processed': false,
        });

        await FirebaseFirestore.instance.collection('gamification_events').add({
          'memberId': memberId,
          'event': 'war_participate',
          'timestamp': Timestamp.now(),
          'processed': false,
        });

        if (rank == 1) {
          await FirebaseFirestore.instance
              .collection('gamification')
              .doc(memberId)
              .update({'warWins': FieldValue.increment(1)});
        }
      }

      final winnerId = entries.isNotEmpty ? entries[0]['memberId'] as String : null;
      final winnerName = entries.isNotEmpty ? entries[0]['memberName'] as String : null;

      await FirebaseFirestore.instance.collection('weeklywars').doc(_activeWarId).update({
        'status': 'completed',
        'winnerId': winnerId,
        'winnerName': winnerName,
      });

      await _loadActiveWar();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('War complete! Winner: ${winnerName ?? 'N/A'} 🏆')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error completing war: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Spring Wars Admin'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildActiveWarSection(),
                  const SizedBox(height: 24),
                  if (_activeWar == null) _buildStartWarButton(),
                  if (_activeWar != null) _buildCompleteWarButton(),
                ],
              ),
            ),
          if (_isCompleting)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveWarSection() {
    final data = _activeWar;

    if (data == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          children: [
            Text('No active war this week',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text('Start a new war to kick off competition',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Chip(
                label: Text('WEEK ${data['weekNumber']}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                backgroundColor: Colors.green,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 8),
              const Chip(
                label: Text('ACTIVE', style: TextStyle(color: Colors.white, fontSize: 12)),
                backgroundColor: Colors.green,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(data['exercise'] ?? '',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
          Text('${data['category']}  •  ${data['unit']}',
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 8),
          if (data['endDate'] != null)
            Text('Ends: ${_formatDate(data['endDate'] as Timestamp)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStartWarButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: _startWar,
        child: const Text('⚔️  Start This Week\'s War',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCompleteWarButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: _completeWar,
        child: const Text('🏆  Complete War & Distribute XP',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
