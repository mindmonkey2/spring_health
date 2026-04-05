import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/member_model.dart';
import '../../theme/app_colors.dart';
import '../../services/session_service.dart';
import 'trainer_warmup_screen.dart';

class TrainerReadinessScreen extends StatefulWidget {
  final String sessionId;
  final MemberModel member;
  final String trainerId;
  final Map<String, dynamic> sessionData;
  final Map<String, dynamic>? flexibilityData;

  const TrainerReadinessScreen({
    super.key,
    required this.sessionId,
    required this.member,
    required this.trainerId,
    required this.sessionData,
    this.flexibilityData,
  });

  @override
  State<TrainerReadinessScreen> createState() => _TrainerReadinessScreenState();
}

class _TrainerReadinessScreenState extends State<TrainerReadinessScreen> {
  bool _isLoading = true;
  bool _isProcessing = false;

  Map<String, dynamic>? _yesterdaySession;
  String _aiRecoveryStatus = 'No data yet';
  List<String> _healthFlags = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final memberDoc = await FirebaseFirestore.instance.collection('members').doc(widget.member.id).get();
      final memberAuthUid = memberDoc.data()?['uid'] as String? ?? '';

      final sessionQuery = await FirebaseFirestore.instance
          .collection('sessions')
          .where('memberId', isEqualTo: widget.member.id)
          .orderBy('date', descending: true)
          .limit(2)
          .get();

      if (sessionQuery.docs.length > 1) {
        _yesterdaySession = sessionQuery.docs[1].data();
      }

      if (memberAuthUid.isNotEmpty) {
        final aiPlanDoc = await FirebaseFirestore.instance
            .collection('aiPlans')
            .doc(memberAuthUid)
            .collection('current')
            .doc('current')
            .get();
        if (aiPlanDoc.exists) {
          _aiRecoveryStatus = aiPlanDoc.data()?['recoveryStatus'] as String? ?? 'No data yet';
        }
      }

      final healthProfileDoc = await FirebaseFirestore.instance
          .collection('healthProfiles')
          .doc(widget.member.id)
          .get();

      if (healthProfileDoc.exists) {
        final data = healthProfileDoc.data()!;
        final conditions = data['medicalConditions'] as List<dynamic>? ?? [];
        final allergies = data['allergies'] as List<dynamic>? ?? [];
        _healthFlags = [...conditions.map((e) => e.toString()), ...allergies.map((e) => e.toString())];
      }
    } catch (e) {
      debugPrint('Error fetching readiness data: \$e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _buildWarmupList() {
    return [
      { 'name': 'Jump Rope', 'durationSeconds': 120, 'status': 'pending' },
      { 'name': 'Arm Circles', 'durationSeconds': 60, 'status': 'pending' },
      { 'name': 'Hip Rotations', 'durationSeconds': 60, 'status': 'pending' },
      { 'name': 'Leg Swings', 'durationSeconds': 60, 'status': 'pending' },
      { 'name': 'Bodyweight Squats', 'durationSeconds': 90, 'status': 'pending' },
    ];
  }

  Future<void> _handleGoodToGo() async {
    setState(() => _isProcessing = true);
    final warmupList = _buildWarmupList();
    await SessionService.instance.writeWarmup(widget.sessionId, warmupList);
    _navigateToWarmup();
  }

  Future<void> _handleLighterLoad() async {
    setState(() => _isProcessing = true);
    await FirebaseFirestore.instance.collection('sessions').doc(widget.sessionId).update({
      'lighterLoad': true,
    });
    final warmupList = _buildWarmupList();
    await SessionService.instance.writeWarmup(widget.sessionId, warmupList);
    _navigateToWarmup();
  }

  Future<void> _handleRestDay() async {
    setState(() => _isProcessing = true);
    await SessionService.instance.updateStatus(widget.sessionId, 'cancelled');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session cancelled — rest day recorded')),
    );
    Navigator.popUntil(context, (r) => r.isFirst);
  }

  void _navigateToWarmup() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TrainerWarmupScreen(
          sessionId: widget.sessionId,
          member: widget.member,
          trainerId: widget.trainerId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Session Prep'),
            Text(widget.member.name, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 220),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMemberInfoCard(),
                const SizedBox(height: 12),
                _buildYesterdaySessionCard(),
                const SizedBox(height: 12),
                _buildAiRecoveryCard(),
                const SizedBox(height: 12),
                _buildHealthFlagsCard(),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isProcessing)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    ElevatedButton(
                      onPressed: _handleGoodToGo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Good to Go', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _handleLighterLoad,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.warning,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Needs Lighter Load', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _handleRestDay,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Rest Day', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.member.name, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Plan: ${widget.member.plan}', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
            Text('Category: ${widget.member.category}', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildYesterdaySessionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Yesterday's Session", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            if (_yesterdaySession == null)
              Text('First session this week', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary))
            else ...[
              Text('Exercises: ${(_yesterdaySession!['exercises'] as List?)?.length ?? 0}', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
              Text('Duration: ${_yesterdaySession!['durationSeconds'] ?? 0}s', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
              Text('Muscles Worked: ${((_yesterdaySession!['musclesWorked'] as List?) ?? []).join(', ')}', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAiRecoveryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recovery Status', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Chip(
              label: Text(_aiRecoveryStatus),
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              labelStyle: const TextStyle(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthFlagsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Health Flags', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            if (_healthFlags.isEmpty)
              Text('No health flags', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _healthFlags.map((flag) => Chip(
                  label: Text(flag),
                  backgroundColor: AppColors.error.withValues(alpha: 0.1),
                  labelStyle: const TextStyle(color: AppColors.error),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
