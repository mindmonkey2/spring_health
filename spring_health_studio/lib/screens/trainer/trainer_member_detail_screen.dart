import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../members/member_ai_plan_screen.dart';
import '../members/trainer_set_goal_screen.dart';
import 'trainer_scan_screen.dart';

class TrainerMemberDetailScreen extends StatefulWidget {
  final String memberId;
  final String currentTrainerId;

  const TrainerMemberDetailScreen({
    super.key,
    required this.memberId,
    required this.currentTrainerId,
  });

  @override
  State<TrainerMemberDetailScreen> createState() =>
      _TrainerMemberDetailScreenState();
}

class _TrainerMemberDetailScreenState extends State<TrainerMemberDetailScreen> {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('members').doc(widget.memberId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: const Text('Member Details')),
            body: const Center(child: Text('Member not found.')),
          );
        }

        final memberData = snapshot.data!.data() as Map<String, dynamic>;
        final memberName = memberData['name'] ?? 'Unknown Member';
        final authUid = memberData['user_id'] ?? '';

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text('$memberName Details',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),
              bottom: const TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: 'Overview'),
                  Tab(text: 'Sessions'),
                  Tab(text: 'AI Plan'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildOverviewTab(memberData, authUid),
                _buildSessionsTab(authUid),
                _buildAiPlanTab(memberName, authUid),
              ],
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TrainerScanScreen(
                          prefillMemberId: widget.memberId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('START SESSION'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(Map<String, dynamic> memberData, String authUid) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMembershipCard(memberData),
          const SizedBox(height: 16),
          _buildGoalCard(authUid, memberData['name'] ?? ''),
          const SizedBox(height: 16),
          _buildBodyMetricsCard(authUid),
          const SizedBox(height: 16),
          _buildFlexibilityCard(authUid),
          const SizedBox(height: 16),
          _buildMemberIntelligenceCard(authUid),
        ],
      ),
    );
  }

  Widget _buildMembershipCard(Map<String, dynamic> memberData) {
    final plan = memberData['plan'] ?? 'No Plan';
    final branch = memberData['branch'] ?? 'Unknown Branch';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Membership',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Plan:'),
                Text(plan, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Branch:'),
                Text(branch,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(String authUid, String memberName) {
    if (authUid.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('memberGoals')
          .doc(authUid)
          .collection('goals')
          .where('status', isEqualTo: 'active')
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Active Goal',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const Divider(),
                  const Text('No active goal set.'),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TrainerSetGoalScreen(
                              memberAuthUid: authUid,
                              memberName: memberName,
                            ),
                          ),
                        );
                      },
                      child: const Text('Set Goal'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final goalDoc = snapshot.data!.docs.first;
        final goalData = goalDoc.data() as Map<String, dynamic>;
        final targetValue = (goalData['targetValue'] as num?)?.toDouble() ?? 0.0;
        final currentValue =
            (goalData['currentValue'] as num?)?.toDouble() ?? 0.0;
        final type = goalData['type'] as String? ?? 'Unknown';
        final targetDateTimestamp = goalData['targetDate'] as Timestamp?;
        final createdAtTimestamp = goalData['createdAt'] as Timestamp?;

        final progress = targetValue != 0 ? currentValue / targetValue : 0.0;

        int weeksRemaining = 0;
        String paceText = 'On Track';
        IconData paceIcon = Icons.check_circle;
        Color paceColor = AppColors.success;

        if (targetDateTimestamp != null && createdAtTimestamp != null) {
          final targetDate = targetDateTimestamp.toDate();
          final createdAt = createdAtTimestamp.toDate();
          final now = DateTime.now();

          final daysRemaining = targetDate.difference(now).inDays;
          weeksRemaining = (daysRemaining / 7).ceil();
          if (weeksRemaining < 0) weeksRemaining = 0;

          final totalDays = targetDate.difference(createdAt).inDays;
          final elapsedDays = now.difference(createdAt).inDays;

          if (totalDays > 0) {
            final expectedProgress = elapsedDays / totalDays;

            if (progress >= expectedProgress + 0.05) {
              paceText = 'Ahead';
              paceIcon = Icons.trending_up;
              paceColor = AppColors.primary;
            } else if (progress < expectedProgress - 0.05) {
              paceText = 'Behind';
              paceIcon = Icons.warning;
              paceColor = AppColors.error;
            }
          }
        }

        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Active Goal',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    Chip(
                      label: Text(type),
                      backgroundColor: AppColors.primaryLight,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Current: $currentValue'),
                    Text('Target: $targetValue'),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.shade300,
                  color: AppColors.turquoise,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$weeksRemaining Weeks Remaining',
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    Row(
                      children: [
                        Icon(paceIcon, color: paceColor, size: 16),
                        const SizedBox(width: 4),
                        Text(paceText,
                            style: TextStyle(
                                color: paceColor, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TrainerSetGoalScreen(
                            memberAuthUid: authUid,
                            memberName: memberName,
                          ),
                        ),
                      );
                    },
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

  Widget _buildBodyMetricsCard(String authUid) {
    if (authUid.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('bodyMetricsLogs')
          .doc(authUid)
          .collection('logs')
          .orderBy('date', descending: true)
          .limit(2)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Body Metrics',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const Divider(),
                  const Text('No body metrics logged yet.'),
                ],
              ),
            ),
          );
        }

        final logs = snapshot.data!.docs;
        final latestLog = logs.first.data() as Map<String, dynamic>;
        final previousLog = logs.length > 1
            ? logs[1].data() as Map<String, dynamic>
            : null;

        final weight = (latestLog['weightKg'] as num?)?.toDouble() ?? 0.0;
        final prevWeight = (previousLog?['weightKg'] as num?)?.toDouble() ?? weight;
        final bmi = (latestLog['bmi'] as num?)?.toDouble() ?? 0.0;
        final bodyFat = (latestLog['bodyFatPercentage'] as num?)?.toDouble() ?? 0.0;

        IconData trendIcon = Icons.trending_flat;
        Color trendColor = Colors.grey;

        if (weight < prevWeight) {
          trendIcon = Icons.trending_down;
          trendColor = AppColors.success;
        } else if (weight > prevWeight) {
          trendIcon = Icons.trending_up;
          trendColor = AppColors.error;
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Body Metrics',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Weight: $weight kg',
                        style: const TextStyle(fontSize: 16)),
                    Icon(trendIcon, color: trendColor),
                  ],
                ),
                const SizedBox(height: 8),
                Text('BMI: $bmi', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Body Fat: $bodyFat %', style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFlexibilityCard(String authUid) {
    if (authUid.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('fitnessTests')
          .doc(authUid)
          .collection('tests')
          .orderBy('date', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final score = (data['overallScore'] as num?)?.toInt() ?? 0;
        final tightAreas = List<String>.from(data['tightAreas'] ?? []);
        final date = (data['date'] as Timestamp?)?.toDate();

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Flexibility',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const Divider(),
                Text('Overall Score: $score/100',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (date != null)
                  Text('Last Assessed: ${date.day}/${date.month}/${date.year}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 12),
                if (tightAreas.isNotEmpty) ...[
                  const Text('Tight Areas:',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: tightAreas
                        .map((area) => Chip(
                              label: Text(area,
                                  style: const TextStyle(color: Colors.white)),
                              backgroundColor: Colors.red,
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMemberIntelligenceCard(String authUid) {
    if (authUid.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('memberIntelligence').doc(authUid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final strongLifts = List<String>.from(data['strongLifts'] ?? []);
        final weakLifts = List<String>.from(data['weakLifts'] ?? []);
        final injuries = List<String>.from(data['injuries'] ?? []);
        final totalSessions = (data['totalSessionsCount'] as num?)?.toInt() ?? 0;

        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Member Intelligence',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    Text('Sessions: $totalSessions',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(),
                if (strongLifts.isNotEmpty) ...[
                  const Text('Strong Lifts',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success)),
                  Wrap(
                    spacing: 8,
                    children: strongLifts
                        .map((lift) => Chip(
                              label: Text(lift,
                                  style: const TextStyle(color: Colors.white)),
                              backgroundColor: AppColors.success,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                ],
                if (weakLifts.isNotEmpty) ...[
                  const Text('Weak Lifts',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.warningDark)),
                  Wrap(
                    spacing: 8,
                    children: weakLifts
                        .map((lift) => Chip(
                              label: Text(lift,
                                  style: const TextStyle(color: Colors.white)),
                              backgroundColor: AppColors.warningDark,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                ],
                if (injuries.isNotEmpty) ...[
                  const Text('Injuries',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error)),
                  Wrap(
                    spacing: 8,
                    children: injuries
                        .map((injury) => Chip(
                              label: Text(injury,
                                  style: const TextStyle(color: Colors.white)),
                              backgroundColor: AppColors.error,
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSessionsTab(String authUid) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('trainingSessions')
          .where('memberId', isEqualTo: widget.memberId)
          .where('trainerId', isEqualTo: widget.currentTrainerId)
          .orderBy('date', descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading sessions: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No sessions recorded yet.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final sessionDoc = snapshot.data!.docs[index];
            final sessionData = sessionDoc.data() as Map<String, dynamic>;
            final date = (sessionData['date'] as Timestamp?)?.toDate() ?? DateTime.now();
            final duration = sessionData['durationMinutes'] ?? 0;
            final rpe = sessionData['rpeScore'] ?? '-';
            final goalDelta = sessionData['goalDelta'] ?? '';
            final intensity = sessionData['intensity'] ?? 'Medium';
            final exercises = List<String>.from(sessionData['exercises'] ?? []);

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
                        Text('${date.day}/${date.month}/${date.year}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Chip(
                          label: Text(intensity),
                          backgroundColor: AppColors.primaryLight,
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const Divider(),
                    Text('Duration: $duration mins',
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text('RPE: $rpe',
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    if (goalDelta.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Goal Delta: $goalDelta',
                          style: const TextStyle(
                              color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ],
                    if (exercises.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text('Exercises:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(exercises.join(', '),
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAiPlanTab(String memberName, String authUid) {
    if (authUid.isEmpty) {
      return const Center(child: Text('No AI Plan available.'));
    }

    return MemberAiPlanScreen(
      memberName: memberName,
      memberDocId: widget.memberId,
      currentUserRole: 'Trainer',
    );
  }
}
