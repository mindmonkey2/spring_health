import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';
import '../../models/member_model.dart';
import '../../models/trainer_model.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import 'trainer_scan_screen.dart';
import 'trainer_member_detail_screen.dart';

class TrainerDashboardScreen extends StatefulWidget {
  final UserModel user;

  const TrainerDashboardScreen({super.key, required this.user});

  @override
  State<TrainerDashboardScreen> createState() => _TrainerDashboardScreenState();
}

class _TrainerDashboardScreenState extends State<TrainerDashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    if (widget.user.trainerId == null) {
      return const Scaffold(
        body: Center(child: Text('No Trainer ID associated with this account.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'MY DASHBOARD',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.successGradient,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TrainerScanScreen(user: widget.user)),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Today\'s Members'),
              const SizedBox(height: 12),
              _buildTodaysMembers(),
              const SizedBox(height: 32),
              _buildSectionTitle('Active Duels (Referee)'),
              const SizedBox(height: 12),
              _buildActiveDuels(),
              const SizedBox(height: 32),
              _buildSectionTitle('Weekly Overview'),
              const SizedBox(height: 12),
              _buildWeeklyOverview(),
              const SizedBox(height: 32),
              _buildSectionTitle('My Profile'),
              const SizedBox(height: 12),
              _buildMyProfile(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyOverview() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekMidnight = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('trainingSessions')
          .where('trainerId', isEqualTo: widget.user.uid)
          .where('date', isGreaterThanOrEqualTo: startOfWeekMidnight)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final count = snapshot.data?.docs.length ?? 0;

        return Card(
          elevation: 2,
          shadowColor: AppColors.cardShadow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.fitness_center, color: AppColors.primary, size: 32),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Sessions this week',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMyProfile() {
    return FutureBuilder<TrainerModel?>(
      future: _firestoreService.getTrainerById(widget.user.trainerId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Could not load profile.'));
        }

        final trainer = snapshot.data!;

        return Card(
          elevation: 2,
          shadowColor: AppColors.cardShadow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.success.withValues(alpha: 0.1),
                  child: trainer.photoUrl != null
                      ? ClipOval(child: Image.network(trainer.photoUrl!, width: 60, height: 60, fit: BoxFit.cover))
                      : Text(
                          trainer.name.isNotEmpty ? trainer.name[0].toUpperCase() : 'T',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
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
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trainer.specialization,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Edit profile logic
                        },
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit Profile'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTodaysMembers() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('members')
          .where('assignedTrainerId', isEqualTo: widget.user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Failed to load members'));
        }

        final allMembers = snapshot.data?.docs.map((doc) {
          return MemberModel.fromMap(doc.data() as Map<String, dynamic>, id: doc.id);
        }).toList() ?? [];
        if (allMembers.isEmpty) {
          return Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text('No members assigned yet.', style: TextStyle(color: Colors.grey)),
              ),
            ),
          );
        }

        // Display up to 5 members inline, or a horizontal list
        return SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: allMembers.length,
            itemBuilder: (context, index) {
              final member = allMembers[index];
              return _buildMemberCard(member);
            },
          ),
        );
      },
    );
  }

  Widget _buildActiveDuels() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('challenges')
          .where('refereeTrainerId', isEqualTo: widget.user.uid)
          .where('status', isEqualTo: 'active')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading duels'));
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text('No active duels to referee.', style: TextStyle(color: Colors.grey)),
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final title = data['title'] as String? ?? 'Challenge';
            final desc = data['description'] as String? ?? '';

            return Card(
              elevation: 2,
              shadowColor: AppColors.cardShadow,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.coral.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_fire_department, color: AppColors.coral),
                ),
                title: Text(
                  title,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  desc,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
                onTap: () {
                  // TODO: View duel details
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMemberCard(MemberModel member) {
    // Determine attendance logic (checked in today)
    final now = DateTime.now();
    bool checkedInToday = false;
    if (member.lastCheckIn != null) {
      final lc = member.lastCheckIn!;
      checkedInToday = lc.year == now.year && lc.month == now.month && lc.day == now.day;
    }

    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        shadowColor: AppColors.cardShadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TrainerMemberDetailScreen(
                  member: member,
                  currentUser: widget.user,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            member.plan,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: checkedInToday
                            ? AppColors.success.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        checkedInToday ? 'Checked In' : 'Not Here',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: checkedInToday ? AppColors.success : Colors.grey[700],
                        ),
                      ),
                    ),
                    if (member.userId != null && member.userId!.isNotEmpty)
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('memberGoals').doc(member.userId).get(),
                        builder: (context, snap) {
                          String goalText = 'No Goal';
                          Color gColor = Colors.grey;

                          if (snap.hasData && snap.data != null && snap.data!.exists) {
                            final data = snap.data!.data() as Map<String, dynamic>;
                            goalText = data['primaryGoal']?.toString() ?? 'Goal Set';
                            gColor = AppColors.turquoise;
                          }

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: gColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              goalText,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: gColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'No Goal',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
