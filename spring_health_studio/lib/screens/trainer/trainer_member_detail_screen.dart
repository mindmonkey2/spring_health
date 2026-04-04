import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/member_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/member_card.dart';
import '../members/member_ai_plan_screen.dart';
import 'trainer_scan_screen.dart';

class TrainerMemberDetailScreen extends StatefulWidget {
  final MemberModel member;
  final String trainerId;
  final String trainerName;
  final String trainerBranch;

  const TrainerMemberDetailScreen({
    super.key,
    required this.member,
    required this.trainerId,
    required this.trainerName,
    required this.trainerBranch,
  });

  @override
  State<TrainerMemberDetailScreen> createState() =>
      _TrainerMemberDetailScreenState();
}

class _TrainerMemberDetailScreenState extends State<TrainerMemberDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _memberAuthUid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchMemberAuthUid();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchMemberAuthUid() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('members')
          .doc(widget.member.id)
          .get();
      if (!doc.exists) return;
      final data = doc.data()!;
      final uid = data['uid'] as String? ?? data['user_id'] as String?;
      if (mounted && uid != null && uid.isNotEmpty) {
        setState(() {
          _memberAuthUid = uid;
        });
      }
    } catch (e) {
      // Ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.member.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Sessions'),
            Tab(text: 'AjAX Plan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildSessionsTab(),
          _buildAiPlanTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MemberCard(
            member: widget.member,
            onTap: () {},
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildGoalCard(),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildBodyMetricsCard(),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildFlexibilityCard(),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildMemberIntelligenceCard(),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TrainerScanScreen(
                      trainerId: widget.trainerId,
                      trainerBranch: widget.trainerBranch,
                      prefilledMemberId: widget.member.id,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'START SESSION',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildGoalCard() {
    if (_memberAuthUid == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No Firebase Auth UID linked yet.'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goal',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('memberGoals')
                  .doc(_memberAuthUid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return ElevatedButton(
                    onPressed: () {
                      // GoalSetSheet placeholder
                    },
                    child: const Text('Set Goal'),
                  );
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final displayName = data['primaryGoal'] ?? 'Goal';
                final currentValue = data['currentValue'] ?? 0;
                final targetValue = data['targetValue'] ?? 0;
                final unit = data['unit'] ?? '';
                final weeksRemaining = data['weeksRemaining'] ?? 0;

                // Simple pace logic mock
                String paceText = 'Not Started';
                Color paceColor = Colors.grey;
                if (currentValue > 0 && targetValue > 0) {
                  paceText = 'On Track';
                  paceColor = AppColors.success;
                }

                double progress = 0;
                if (targetValue > 0) {
                  progress = (currentValue / targetValue).clamp(0.0, 1.0);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Chip(
                      label: Text(displayName,
                          style: const TextStyle(color: Colors.white)),
                      backgroundColor: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      color: AppColors.primaryDark,
                    ),
                    const SizedBox(height: 12),
                    Text('$currentValue $unit → $targetValue $unit',
                        style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    Text('$weeksRemaining weeks remaining',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(
                          label: Text(paceText,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                          backgroundColor: paceColor,
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Edit Goal'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyMetricsCard() {
    if (_memberAuthUid == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Body Metrics',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('bodyMetricsLogs')
                  .doc(_memberAuthUid)
                  .collection('logs')
                  .orderBy('date', descending: true)
                  .limit(4)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Text('No body metrics logged yet.');
                }

                final latest = docs.first.data() as Map<String, dynamic>;
                final weight = (latest['weight'] as num?)?.toDouble() ?? 0.0;
                final heightCm = (latest['height'] as num?)?.toDouble() ?? 0.0;
                final bodyFat = (latest['bodyFat'] as num?)?.toDouble();

                double bmi = 0;
                if (heightCm > 0) {
                  final heightM = heightCm / 100;
                  bmi = weight / (heightM * heightM);
                }

                double delta = 0;
                if (docs.length > 1) {
                  final oldest = docs.last.data() as Map<String, dynamic>;
                  final oldestWeight = (oldest['weight'] as num?)?.toDouble() ?? 0.0;
                  delta = weight - oldestWeight;
                }
                final arrow = delta > 0 ? '↑' : (delta < 0 ? '↓' : '→');

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Weight: ${weight.toStringAsFixed(1)}kg',
                        style: GoogleFonts.inter(fontSize: 14)),
                    Text('BMI: ${bmi.toStringAsFixed(1)}',
                        style: GoogleFonts.inter(fontSize: 14)),
                    Text(
                        'Body fat: ${bodyFat != null ? '${bodyFat.toStringAsFixed(1)}%' : 'not tracked'}',
                        style: GoogleFonts.inter(fontSize: 14)),
                    if (docs.length > 1)
                      Text(
                          'Trend: $arrow ${delta.abs().toStringAsFixed(1)}kg over ${docs.length} entries',
                          style: GoogleFonts.inter(fontSize: 14)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlexibilityCard() {
    if (_memberAuthUid == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flexibility',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('memberIntelligence')
                  .doc(_memberAuthUid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data?.data() as Map<String, dynamic>?;
                if (data == null || data['latestFlexibilityScore'] == null) {
                  return const Text('Flexibility not yet assessed.');
                }

                final score = data['latestFlexibilityScore'] ?? 0;
                final tightAreas = (data['tightAreas'] as List<dynamic>?)
                        ?.cast<String>() ??
                    [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Flexibility score: $score/100',
                        style: GoogleFonts.inter(fontSize: 14)),
                    if (tightAreas.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tightAreas
                            .map((area) => Chip(
                                  label: Text(area,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12)),
                                  backgroundColor: AppColors.error,
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberIntelligenceCard() {
    if (_memberAuthUid == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Member Intelligence',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('memberIntelligence')
                  .doc(_memberAuthUid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data?.data() as Map<String, dynamic>?;
                if (data == null) {
                  return const Text('No intelligence data found.');
                }

                final totalSessionsLogged =
                    data['totalSessionsLogged'] ?? 0;
                final strongLifts = (data['strongLifts'] as List<dynamic>?)
                        ?.cast<String>() ??
                    [];
                final weakLifts = (data['weakLifts'] as List<dynamic>?)
                        ?.cast<String>() ??
                    [];
                final injuryHistory = (data['injuryHistory'] as List<dynamic>?)
                        ?.cast<String>() ??
                    [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total sessions: $totalSessionsLogged',
                        style: GoogleFonts.inter(fontSize: 14)),
                    const SizedBox(height: 12),
                    if (strongLifts.isNotEmpty) ...[
                      Text('Strong Lifts',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.textSecondary)),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: strongLifts
                            .map((l) => Chip(
                                  label: Text(l,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12)),
                                  backgroundColor: AppColors.success,
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (weakLifts.isNotEmpty) ...[
                      Text('Weak Lifts',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.textSecondary)),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: weakLifts
                            .map((l) => Chip(
                                  label: Text(l,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12)),
                                  backgroundColor: AppColors.warning,
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (injuryHistory.isNotEmpty) ...[
                      Text('Injury History',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.textSecondary)),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: injuryHistory
                            .map((l) => Chip(
                                  label: Text(l,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12)),
                                  backgroundColor: AppColors.error,
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trainingSessions')
          .where('memberId', isEqualTo: widget.member.id)
          .where('trainerId', isEqualTo: widget.trainerId)
          .where('status', isEqualTo: 'complete')
          .orderBy('date', descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No sessions recorded yet.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final date = (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();
            final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);
            final duration = data['totalDurationMinutes'] ?? 0;
            final intensity = data['intensity'] ?? 'medium';
            final rpe = data['rpe'] ?? 5;
            final exercises = (data['exercises'] as List<dynamic>?) ?? [];
            final notes = data['trainerNotes'] ?? '';

            Color intensityColor = AppColors.warning;
            if (intensity == 'low') intensityColor = AppColors.success;
            if (intensity == 'high') intensityColor = AppColors.error;

            return Card(
              elevation: 0,
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('$formattedDate · $duration min',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text(intensity.toString().toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10)),
                        backgroundColor: intensityColor,
                        padding: EdgeInsets.zero,
                      ),
                      Chip(
                        label: Text('RPE $rpe/10',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10)),
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${exercises.length} exercises',
                      style: GoogleFonts.inter(fontSize: 13)),
                  if (notes.isNotEmpty)
                    Text(
                      notes,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAiPlanTab() {
    return MemberAiPlanScreen(
      memberName: widget.member.name,
      memberDocId: widget.member.id,
      currentUserRole: 'Trainer',
    );
  }
}
