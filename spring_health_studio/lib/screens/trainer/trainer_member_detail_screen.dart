import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/member_model.dart';
import '../../models/user_model.dart';
import '../../models/member_goal_model.dart';
import '../../models/health_profile_model.dart';
import '../../models/member_intelligence_model.dart';
import '../../theme/app_colors.dart';
import '../members/member_ai_plan_screen.dart';
import 'trainer_scan_screen.dart';

class TrainerMemberDetailScreen extends StatefulWidget {
  final MemberModel member;
  final UserModel currentUser;

  const TrainerMemberDetailScreen({
    super.key,
    required this.member,
    required this.currentUser,
  });

  @override
  State<TrainerMemberDetailScreen> createState() => _TrainerMemberDetailScreenState();
}

class _TrainerMemberDetailScreenState extends State<TrainerMemberDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.member.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.successGradient,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Sessions'),
            Tab(text: 'AI Plan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildSessionsTab(),
          if (widget.member.userId != null && widget.member.userId!.isNotEmpty)
            MemberAiPlanScreen(
              memberName: widget.member.name,
              memberDocId: widget.member.userId!,
              currentUserRole: widget.currentUser.role,
            )
          else
            const Center(child: Text('No Auth UID linked for AI Plan.')),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Membership & Goal Card
          _buildMembershipGoalCard(),
          const SizedBox(height: 16),
          // 2. Body Metrics
          _buildBodyMetricsCard(),
          const SizedBox(height: 16),
          // 3. Flexibility
          _buildFlexibilityCard(),
          const SizedBox(height: 16),
          // 4. Member Intelligence
          _buildMemberIntelligenceCard(),
          const SizedBox(height: 32),
          // 5. START SESSION BUTTON
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TrainerScanScreen(user: widget.currentUser)),
              );
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('START SESSION'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMembershipGoalCard() {
    final authUid = widget.member.userId;
    if (authUid == null || authUid.isEmpty) {
      return _buildGoalFallbackCard('No Auth UID linked');
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('memberGoals').doc(authUid).get(),
      builder: (context, snapshot) {
        String primaryGoal = 'No goal set';
        String pace = 'N/A';
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final goal = MemberGoalModel.fromMap(data, authUid);
          primaryGoal = goal.primaryGoal;
          pace = goal.currentPace;
        }

        return Card(
          elevation: 2,
          shadowColor: AppColors.cardShadow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Membership', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.member.isActive ? AppColors.success.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.member.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.member.isActive ? AppColors.success : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Plan: ${widget.member.plan}', style: GoogleFonts.inter(fontSize: 14)),
                const Divider(height: 24),
                Text('Current Goal', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(primaryGoal, style: GoogleFonts.inter(fontSize: 16, color: AppColors.primary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.speed, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Pace: $pace', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700])),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: 0.5, // Placeholder progress
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  color: AppColors.primary,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoalFallbackCard(String msg) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(msg),
      ),
    );
  }

  Widget _buildBodyMetricsCard() {
    final authUid = widget.member.userId;
    if (authUid == null || authUid.isEmpty) {
      return const SizedBox();
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('healthProfiles').doc(authUid).get(),
      builder: (context, snapshot) {
        double? weight;
        double? bmi;
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final hp = HealthProfileModel.fromMap(data, authUid);
          weight = hp.weightKg;
          bmi = hp.bmi;
        }

        return Card(
          elevation: 2,
          shadowColor: AppColors.cardShadow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Body Metrics', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _metricStat('Weight', weight != null ? '${weight.toStringAsFixed(1)} kg' : '--'),
                    _metricStat('BMI', bmi != null ? bmi.toStringAsFixed(1) : '--'),
                    _metricStat('Trend', 'Stable'), // Placeholder
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _metricStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.turquoise)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildFlexibilityCard() {
    final authUid = widget.member.userId;
    if (authUid == null || authUid.isEmpty) {
      return const SizedBox();
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('memberIntelligence').doc(authUid).get(),
      builder: (context, snapshot) {
        int score = 0;
        List<String> tightAreas = [];
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final mi = MemberIntelligenceModel.fromMap(data, authUid);
          score = mi.latestFlexibilityScore;
          tightAreas = mi.tightAreas;
        }

        return Card(
          elevation: 2,
          shadowColor: AppColors.cardShadow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Flexibility', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    Text('$score/100', style: GoogleFonts.poppins(color: AppColors.coral, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Tight Areas:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tightAreas.isEmpty
                      ? [const Text('None reported', style: TextStyle(fontSize: 12))]
                      : tightAreas.map((area) => Chip(
                          label: Text(area, style: const TextStyle(fontSize: 11)),
                          backgroundColor: AppColors.coral.withValues(alpha: 0.1),
                          side: BorderSide.none,
                          padding: EdgeInsets.zero,
                        )).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMemberIntelligenceCard() {
    final authUid = widget.member.userId;
    if (authUid == null || authUid.isEmpty) {
      return const SizedBox();
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('memberIntelligence').doc(authUid).get(),
      builder: (context, snapshot) {
        List<String> strong = [];
        List<String> weak = [];
        List<String> injuries = [];

        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final mi = MemberIntelligenceModel.fromMap(data, authUid);
          strong = mi.strongLifts;
          weak = mi.weakLifts;
          injuries = mi.injuryHistory;
        }

        return Card(
          elevation: 2,
          shadowColor: AppColors.cardShadow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Intelligence', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildInfoRow('Strong Lifts', strong),
                const Divider(),
                _buildInfoRow('Needs Work', weak),
                const Divider(),
                _buildInfoRow('Injury History', injuries, isWarning: true),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String title, List<String> items, {bool isWarning = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(title, style: TextStyle(fontSize: 12, color: isWarning ? AppColors.error : Colors.grey[700], fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Text(
            items.isEmpty ? 'None' : items.join(', '),
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trainingSessions')
          .where('memberId', isEqualTo: widget.member.id)
          .orderBy('date', descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading sessions'));
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text('No previous sessions recorded.', style: TextStyle(color: Colors.grey)),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final date = data['date'] != null ? (data['date'] as Timestamp).toDate() : DateTime.now();
            final status = data['status'] as String? ?? 'completed';

            return Card(
              elevation: 2,
              shadowColor: AppColors.cardShadow,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: AppColors.success),
                ),
                title: Text(
                  'Session on ${date.day}/${date.month}/${date.year}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Status: $status'),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          },
        );
      },
    );
  }
}
