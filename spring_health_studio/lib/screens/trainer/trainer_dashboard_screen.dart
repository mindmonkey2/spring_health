import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../../models/trainer_model.dart';
import '../../services/firestore_service.dart';
import 'trainer_scan_screen.dart';
import 'trainer_member_detail_screen.dart';
import 'trainer_referee_screen.dart';
import '../trainers/trainer_detail_screen.dart'; // Import existing detail screen

class TrainerDashboardScreen extends StatefulWidget {
  final String trainerId;
  final String trainerName;

  const TrainerDashboardScreen({
    super.key,
    required this.trainerId,
    required this.trainerName,
  });

  @override
  State<TrainerDashboardScreen> createState() => _TrainerDashboardScreenState();
}

class _TrainerDashboardScreenState extends State<TrainerDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Future<Map<String, dynamic>> _fetchWeeklyOverview() async {
    final now = DateTime.now();
    // Start of the week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    // Get training sessions
    final sessionsSnap = await _firestore
        .collection('trainingSessions')
        .where('trainerId', isEqualTo: widget.trainerId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();

    final sessionsDone = sessionsSnap.docs.length;

    // Get members trained (distinct members in those sessions)
    final memberIds = sessionsSnap.docs
        .map((doc) => doc.data()['memberId'] as String?)
        .where((id) => id != null)
        .toSet();

    final membersTrained = memberIds.length;

    // Get duels refereed
    final duelsSnap = await _firestore
        .collection('challenges')
        .where('refereeTrainerId', isEqualTo: widget.trainerId)
        .where('status', isEqualTo: 'completed')
        .where('updatedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();

    final duelsRefereed = duelsSnap.docs.length; // Simplified for now

    return {
      'sessionsDone': sessionsDone,
      'membersTrained': membersTrained,
      'duelsRefereed': duelsRefereed,
    };
  }

  Future<TrainerModel?> _fetchProfile() async {
    return _firestoreService.getTrainerById(widget.trainerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MY DASHBOARD',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TrainerScanScreen(
                    currentTrainerId: widget.trainerId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildActiveDuelsSection(),
            _buildWeeklyOverviewSection(),
            _buildTodaysMembersSection(),
            _buildMyProfileSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveDuelsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('challenges')
          .where('refereeTrainerId', isEqualTo: widget.trainerId)
          .where('status', isEqualTo: 'active')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final count = snapshot.data!.docs.length;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TrainerRefereeScreen()),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.warning),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.gavel, color: AppColors.warning),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Duels',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                        Text(
                          'You have $count active duel${count > 1 ? 's' : ''} to referee',
                          style: GoogleFonts.inter(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 16, color: AppColors.warning),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyOverviewSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEEKLY OVERVIEW',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<Map<String, dynamic>>(
            future: _fetchWeeklyOverview(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final stats = snapshot.data ??
                  {
                    'sessionsDone': 0,
                    'membersTrained': 0,
                    'duelsRefereed': 0,
                  };

              return Row(
                children: [
                  _buildStatCard(
                      'Sessions Done', stats['sessionsDone'].toString()),
                  const SizedBox(width: 8),
                  _buildStatCard(
                      'Members Trained', stats['membersTrained'].toString()),
                  const SizedBox(width: 8),
                  _buildStatCard(
                      'Duels Refereed', stats['duelsRefereed'].toString()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysMembersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TODAY\'S MEMBERS',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('members')
                .where('assignedTrainerId', isEqualTo: widget.trainerId)
                .where('isArchived', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No members assigned today.'),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final memberData = doc.data() as Map<String, dynamic>;
                  final memberId = doc.id;
                  final memberName = memberData['name'] ?? 'Unknown Member';
                  final plan = memberData['plan'] ?? 'No Plan';
                  final branch = memberData['branch'] ?? 'Unknown Branch';
                  final authUid = memberData['user_id'] ?? '';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TrainerMemberDetailScreen(
                              memberId: memberId,
                              currentTrainerId: widget.trainerId,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    memberName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                _buildAttendanceChip(memberId),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$plan · $branch',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildGoalChip(authUid),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceChip(String memberId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final docId = '${memberId}_${today.toIso8601String().split('T')[0]}';

    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('attendance').doc(docId).snapshots(),
      builder: (context, snapshot) {
        final hasCheckedIn = snapshot.hasData && snapshot.data!.exists;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: hasCheckedIn
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.textMuted.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasCheckedIn ? AppColors.success : AppColors.textMuted,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasCheckedIn ? Icons.check_circle : Icons.schedule,
                size: 14,
                color: hasCheckedIn ? AppColors.success : AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                hasCheckedIn ? 'Checked In' : 'Not yet',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: hasCheckedIn ? AppColors.success : AppColors.textMuted,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGoalChip(String authUid) {
    if (authUid.isEmpty) return const SizedBox.shrink();

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('memberGoals').doc(authUid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final goalType = data['type'] ?? 'Goal';
        final weeksLeft = data['weeksLeft'] ?? 0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.flag, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                '$goalType · ${weeksLeft}wks left',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyProfileSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MY PROFILE',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<TrainerModel?>(
            future: _fetchProfile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final trainer = snapshot.data;

              if (trainer == null) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Profile information unavailable.',
                      style: GoogleFonts.inter(color: AppColors.textSecondary),
                    ),
                  ),
                );
              }

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        child: Text(
                          trainer.name.isNotEmpty ? trainer.name[0] : '?',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trainer.name,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              trainer.specialization,
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              trainer.phone,
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TrainerDetailScreen(
                                trainerId: trainer.id,
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Edit'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
