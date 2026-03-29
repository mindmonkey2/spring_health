import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../models/member_model.dart';
import '../members/member_ai_plan_screen.dart';
import 'trainer_scan_screen.dart';

class TrainerMemberDetailScreen extends StatefulWidget {
  final MemberModel member;
  final String trainerId;
  final String currentUserRole;

  const TrainerMemberDetailScreen({
    super.key,
    required this.member,
    required this.trainerId,
    required this.currentUserRole,
  });

  @override
  State<TrainerMemberDetailScreen> createState() =>
      _TrainerMemberDetailScreenState();
}

class _TrainerMemberDetailScreenState extends State<TrainerMemberDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _memberAuthUid;
  bool _isLoadingUid = true;

  @override
  void initState() {
    super.initState();
    _fetchMemberAuthUid();
  }

  Future<void> _fetchMemberAuthUid() async {
    // According to instructions, read member.uid to get memberAuthUid.
    // However, MemberModel uses `id` for its document ID, but the database might store `uid` inside the document map.
    // We will attempt to get it directly if possible, else fallback to user lookup.
    try {
      final doc = await _firestore.collection('members').doc(widget.member.id).get();
      if (doc.exists && doc.data()!.containsKey('uid') && doc.data()!['uid'] != null && doc.data()!['uid'].toString().isNotEmpty) {
         setState(() {
          _memberAuthUid = doc.data()!['uid'].toString();
        });
      } else {
        // Fallback per prior implementation if 'uid' is not strictly found in 'members' doc
        final snapshot = await _firestore
            .collection('users')
            .where('phone', isEqualTo: widget.member.phone)
            .limit(1)
            .get();
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            _memberAuthUid = snapshot.docs.first.id;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching member auth uid: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUid = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),
          title: Text(
            widget.member.name,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Sessions'),
              Tab(text: 'AI Plan'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(),
            _buildSessionsTab(),
            _buildAiPlanTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_isLoadingUid) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_memberAuthUid == null || _memberAuthUid!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.link_off, size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    'Member has not linked their app account yet. Cannot show AI data.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMembershipCard(),
          const SizedBox(height: 16),
          _buildGoalCard(),
          const SizedBox(height: 16),
          _buildBodyMetricsCard(),
          const SizedBox(height: 16),
          _buildFlexibilityCard(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TrainerScanScreen(
                      trainerId: widget.trainerId,
                      prefilledMember: widget.member,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'START SESSION',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Membership',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Chip(
                  label: Text(
                    widget.member.isActive ? 'Active' : 'Inactive',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.member.isActive ? AppColors.success : AppColors.error,
                    ),
                  ),
                  backgroundColor: (widget.member.isActive ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.member.plan} - ${widget.member.branch}',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Expires: ${DateFormat('dd MMM yyyy').format(widget.member.expiryDate)}',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard() {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('memberGoals').doc(_memberAuthUid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (!snapshot.data!.exists) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'No goal set yet.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('MemberGoalScreen coming soon')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Set Goal',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final goalData = snapshot.data!.data() as Map<String, dynamic>;
        final targetDate = (goalData['targetDate'] as Timestamp).toDate();
        final weeksRemaining = targetDate.difference(DateTime.now()).inDays ~/ 7;
        final currentValue = goalData['currentValue'] ?? 0;
        final targetValue = goalData['targetValue'] ?? 0;
        final unit = goalData['unit'] ?? '';
        final label = goalData['primaryGoalType'] ?? 'Goal';
        final paceStatus = goalData['paceStatus'] ?? 'not_started';

        Color paceColor;
        String paceText;
        switch (paceStatus) {
          case 'on_track':
            paceColor = AppColors.success;
            paceText = 'On Track';
            break;
          case 'ahead':
            paceColor = AppColors.turquoiseDark;
            paceText = 'Ahead';
            break;
          case 'behind':
            paceColor = AppColors.warningDark;
            paceText = 'Behind';
            break;
          case 'not_started':
          default:
            paceColor = AppColors.textSecondary;
            paceText = 'Not Started';
            break;
        }

        // simple progress
        double progress = 0;
        final startValue = goalData['startValue'] ?? 0;
        if (targetValue != startValue) {
          progress = (currentValue - startValue) / (targetValue - startValue);
          if (progress < 0) progress = 0;
          if (progress > 1) progress = 1;
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      side: BorderSide.none,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                    Chip(
                      label: Text(
                        paceText,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: paceColor,
                        ),
                      ),
                      backgroundColor: paceColor.withValues(alpha: 0.1),
                      side: BorderSide.none,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$currentValue → $targetValue $unit',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${weeksRemaining > 0 ? weeksRemaining : 0} weeks remaining',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('MemberGoalScreen coming soon')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Edit Goal'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBodyMetricsCard() {
    return FutureBuilder<QuerySnapshot>(
      future: _firestore
          .collection('bodyMetrics')
          .where('memberId', isEqualTo: widget.member.id)
          .orderBy('recordedAt', descending: true)
          .limit(1)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'No body metrics recorded yet.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final recordedAt = (data['recordedAt'] as Timestamp).toDate();
        final weight = data['weight'];
        final bmi = data['bmi'];
        final bodyFat = data['bodyFatPercentage'];

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Latest Body Metrics',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy').format(recordedAt),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (weight != null) _buildMetricItem('Weight', '$weight kg'),
                    if (bmi != null) _buildMetricItem('BMI', (bmi as num).toStringAsFixed(1)),
                    if (bodyFat != null) _buildMetricItem('Body Fat', '$bodyFat %'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFlexibilityCard() {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('memberIntelligence').doc(_memberAuthUid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (!snapshot.data!.exists) {
           return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Flexibility not yet assessed.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final latestFlexibilityScore = data['latestFlexibilityScore'];

        if (latestFlexibilityScore == null) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Flexibility not yet assessed.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        final tightAreas = List<String>.from(data['tightAreas'] ?? []);
        final totalSessionsLogged = data['totalSessionsLogged'] ?? 0;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flexibility Assessment',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$latestFlexibilityScore/100',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                if (tightAreas.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tightAreas.map((area) {
                      return Chip(
                        label: Text(
                          area,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                        backgroundColor: AppColors.error.withValues(alpha: 0.1),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 12),
                Text(
                  'Total sessions: $totalSessionsLogged',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSessionsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('trainingSessions')
          .where('memberId', isEqualTo: widget.member.id)
          .where('trainerId', isEqualTo: widget.trainerId)
          .orderBy('date', descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No sessions found.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final date = (data['date'] as Timestamp).toDate();
            final totalDurationMinutes = data['totalDurationMinutes'] ?? 0;
            final selectedIntensity = data['selectedIntensity'] ?? 'Medium';
            final sessionRpe = data['sessionRpe'] ?? 0;
            final sessionFocus = data['sessionFocus'] ?? 'General Training';

            Color rpeColor;
            if (sessionRpe <= 3) { rpeColor = AppColors.success; }
            else if (sessionRpe <= 6) { rpeColor = AppColors.info; }
            else if (sessionRpe <= 9) { rpeColor = AppColors.warningDark; }
            else { rpeColor = AppColors.error; }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd MMM yyyy, HH:mm').format(date),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Chip(
                          label: Text(
                            selectedIntensity,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          side: BorderSide.none,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$totalDurationMinutes min',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'RPE $sessionRpe/10',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: rpeColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sessionFocus,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAiPlanTab() {
    if (_isLoadingUid) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_memberAuthUid == null || _memberAuthUid!.isEmpty) {
      return Center(
        child: Text(
          'Member has not linked their account.',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return MemberAiPlanScreen(
      memberName: widget.member.name,
      memberDocId: widget.member.id,
      currentUserRole: widget.currentUserRole,
    );
  }
}
