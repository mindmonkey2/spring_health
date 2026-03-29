import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../../services/firestore_service.dart';
import '../../models/member_model.dart';
import '../../models/trainer_model.dart';
import 'trainer_scan_screen.dart';
import 'trainer_member_detail_screen.dart';
import 'trainer_referee_screen.dart';
import '../trainers/trainer_detail_screen.dart';

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
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: Text(
          'MY DASHBOARD',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TrainerScanScreen(trainerId: widget.trainerId),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildActiveDuelsSection(),
              const SizedBox(height: 24),
              _buildThisWeekSection(),
              const SizedBox(height: 24),
              _buildTodaysMembersSection(),
              const SizedBox(height: 24),
              _buildMyProfileSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
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

        final int count = snapshot.data!.docs.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('Active Duels'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.warningDark, width: 2),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TrainerRefereeScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warningDark.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.sports_mma, color: AppColors.warningDark),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          '$count active duel(s) to referee',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThisWeekSection() {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('This Week'),
        FutureBuilder<QuerySnapshot>(
          future: _firestore
              .collection('trainingSessions')
              .where('trainerId', isEqualTo: widget.trainerId)
              .where('status', isEqualTo: 'complete')
              .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(monday))
              .get(),
          builder: (context, sessionSnapshot) {
            return FutureBuilder<QuerySnapshot>(
              future: _firestore
                  .collection('challenges')
                  .where('refereeTrainerId', isEqualTo: widget.trainerId)
                  .where('status', isEqualTo: 'active')
                  .get(),
              builder: (context, duelSnapshot) {
                int sessionsDone = 0;
                int membersTrained = 0;
                int duelsRefereed = 0;

                if (sessionSnapshot.hasData) {
                  sessionsDone = sessionSnapshot.data!.docs.length;
                  final memberIds = sessionSnapshot.data!.docs
                      .map((d) => d.get('memberId') as String)
                      .toSet();
                  membersTrained = memberIds.length;
                }

                if (duelSnapshot.hasData) {
                   duelsRefereed = duelSnapshot.data!.docs.length;
                }

                return Row(
                  children: [
                    Expanded(
                      child: _buildStatChip('Sessions done', sessionsDone.toString(), Icons.check_circle_outline, AppColors.success),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatChip('Members trained', membersTrained.toString(), Icons.people_outline, AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatChip('Duels refereed', duelsRefereed.toString(), Icons.sports_mma, AppColors.warningDark),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('Today\'s Members'),
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
              return Card(
                elevation: 0,
                color: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      'No members assigned yet.',
                      style: GoogleFonts.inter(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final memberMap = doc.data() as Map<String, dynamic>;
                // Use a default empty string for id since fromMap requires it
                final member = MemberModel.fromMap(memberMap, id: doc.id);

                return _buildMemberCard(member);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildMemberCard(MemberModel member) {
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TrainerMemberDetailScreen(
                member: member,
                trainerId: widget.trainerId,
                currentUserRole: 'Trainer',
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
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
                      member.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${member.plan} - ${member.branch}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Attendance Chip
                        StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('attendance')
                              .where('memberId', isEqualTo: member.id)
                              .where('checkInTime', isGreaterThanOrEqualTo: Timestamp.fromDate(todayMidnight))
                              .snapshots(),
                          builder: (context, attSnapshot) {
                            final bool isCheckedIn = attSnapshot.hasData && attSnapshot.data!.docs.isNotEmpty;

                            return Chip(
                              label: Text(
                                isCheckedIn ? 'Checked In' : 'Not Yet',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isCheckedIn ? AppColors.success : AppColors.textSecondary,
                                ),
                              ),
                              backgroundColor: isCheckedIn ? AppColors.success.withValues(alpha: 0.1) : AppColors.background,
                              side: BorderSide(
                                color: isCheckedIn ? AppColors.success.withValues(alpha: 0.3) : AppColors.border,
                              ),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            );
                          },
                        ),

                        // Goal Chip
                        // Member's uid isn't directly available in MemberModel, using id
                        // But MemberModel's UID is usually phone or another field.
                        // member.uid requires fetching from users collection or assuming member.id is uid.
                        // Often memberAuthUid is stored in users collection linked by phone,
                        // but let's assume member.id is used or try a fallback since 'memberGoals' doc
                        // requires auth uid.
                        FutureBuilder<QuerySnapshot>(
                          future: _firestore
                              .collection('users')
                              .where('phone', isEqualTo: member.phone)
                              .limit(1)
                              .get(),
                          builder: (context, userSnapshot) {
                             if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
                               return const SizedBox.shrink();
                             }
                             final memberAuthUid = userSnapshot.data!.docs.first.id;

                             return StreamBuilder<DocumentSnapshot>(
                              stream: _firestore.collection('memberGoals').doc(memberAuthUid).snapshots(),
                              builder: (context, goalSnapshot) {
                                if (!goalSnapshot.hasData || !goalSnapshot.data!.exists) {
                                  return const SizedBox.shrink();
                                }

                                final goalData = goalSnapshot.data!.data() as Map<String, dynamic>;
                                final targetDate = (goalData['targetDate'] as Timestamp).toDate();
                                final weeksLeft = targetDate.difference(DateTime.now()).inDays ~/ 7;
                                final label = goalData['primaryGoalType'] ?? 'Goal';

                                return Chip(
                                  avatar: const Icon(Icons.flag, size: 12, color: AppColors.primary),
                                  label: Text(
                                    '$label - ${weeksLeft > 0 ? weeksLeft : 0}w',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                  side: BorderSide.none,
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                );
                              },
                            );
                          }
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('My Profile'),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: FutureBuilder<TrainerModel?>(
              future: _firestoreService.getTrainerById(widget.trainerId),
              builder: (context, snapshot) {
                final TrainerModel? trainer = snapshot.data;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.trainerName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      trainer?.specialization ?? 'Trainer',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trainer?.phone ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit Profile'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                        ),
                        onPressed: () {
                           if (trainer != null) {
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                 builder: (_) => TrainerDetailScreen(trainerId: trainer.id),
                               ),
                             );
                           }
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
