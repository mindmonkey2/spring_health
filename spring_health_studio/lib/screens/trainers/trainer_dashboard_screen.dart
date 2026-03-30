import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../models/trainer_model.dart';
import '../../models/member_model.dart';
import '../../models/trainer_feedback_model.dart';
import '../auth/login_screen.dart';
import '../members/member_ai_plan_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../members/members_list_screen.dart';

class TrainerDashboardScreen extends StatefulWidget {
  final UserModel user;

  const TrainerDashboardScreen({super.key, required this.user});

  @override
  State<TrainerDashboardScreen> createState() =>
      _TrainerDashboardScreenState();
}

class _TrainerDashboardScreenState extends State<TrainerDashboardScreen> {
  final ValueNotifier<int> _tabNotifier = ValueNotifier(0);
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  TrainerModel? _trainerProfile;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadTrainerProfile();
  }

  @override
  void dispose() {
    _tabNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadTrainerProfile() async {
    // ✅ FIXED: use trainerId (TRN001), not authUid
    final trainer = await _firestoreService
        .getTrainerById(widget.user.trainerId!);
    if (!context.mounted) return;
                                      if (mounted) {
      setState(() {
        _trainerProfile = trainer;
        _loadingProfile = false;
      });
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Logout',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Logout',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
      if (!context.mounted) return;
                                      if (mounted) {
        // ✅ FIXED: Navigate back to login after logout
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingProfile) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text('Loading trainer profile...',
                  style: GoogleFonts.inter(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    if (_trainerProfile == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.error, size: 64),
              const SizedBox(height: 16),
              Text(
                'Trainer profile not found.\nContact admin to link your account.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    color: AppColors.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary),
                child: const Text('Logout',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: ValueListenableBuilder<int>(
        valueListenable: _tabNotifier,
        builder: (context, index, _) {
          switch (index) {
            case 0:
              return _HomeTab(
                  trainer: _trainerProfile!, firestoreService: _firestoreService);
            case 1:
              return _MyClientsTab(
                  trainer: _trainerProfile!, firestoreService: _firestoreService);
            case 2:
              return _DietPlansTab(
                  trainer: _trainerProfile!, firestoreService: _firestoreService);
            case 3:
              return _FeedbackTab(
                  trainer: _trainerProfile!, firestoreService: _firestoreService);
            default:
              return _HomeTab(
                  trainer: _trainerProfile!, firestoreService: _firestoreService);
          }
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _tabNotifier,
        builder: (context, index, _) {
          return BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textMuted,
            selectedLabelStyle:
                GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle:
                GoogleFonts.inter(fontSize: 11),
            currentIndex: index,
            onTap: (i) => _tabNotifier.value = i,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'My Clients',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_menu_outlined),
                activeIcon: Icon(Icons.restaurant_menu),
                label: 'Diet Plans',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star_outline),
                activeIcon: Icon(Icons.star),
                label: 'Feedback',
              ),
            ],
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _trainerProfile!.name,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '${_trainerProfile!.branch} · ${_trainerProfile!.specialization}',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      actions: [
        // Stats badge
        Container(
          margin: const EdgeInsets.only(right: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.people, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                '${_trainerProfile!.totalAssigned}',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: _logout,
          tooltip: 'Logout',
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  TAB 1 — MY CLIENTS
// ═══════════════════════════════════════════════════════════

class _MyClientsTab extends StatelessWidget {
  final TrainerModel trainer;
  final FirestoreService firestoreService;

  const _MyClientsTab(
      {required this.trainer, required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    if (trainer.assignedMembers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline,
                size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              'No clients assigned yet.',
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask admin to assign members to you.',
              style: GoogleFonts.inter(
                  color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    // ✅ FIXED: StreamBuilder for real-time updates
    return StreamBuilder<List<MemberModel>>(
      stream: firestoreService.getMembersByTrainer(trainer.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final clients = snapshot.data ?? [];

        return Column(
          children: [
            // Summary Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.primary.withValues(alpha: 0.05),
              child: Row(
                children: [
                  const Icon(Icons.people, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${clients.length} Active Clients · ${trainer.branch}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: clients.length,
                itemBuilder: (context, index) {
                  final client = clients[index];
                  return _ClientCard(client: client);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ClientCard extends StatelessWidget {
  final MemberModel client;
  const _ClientCard({required this.client});

  @override
  Widget build(BuildContext context) {
    final isExpired = client.isExpired;
    final isExpiringSoon = client.isExpiringSoon;
    final statusColor = isExpired
        ? AppColors.error
        : isExpiringSoon
            ? AppColors.warning
            : AppColors.success;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage:
                  client.photoUrl != null ? NetworkImage(client.photoUrl!) : null,
              child: client.photoUrl == null
                  ? Text(
                      client.name.isNotEmpty
                          ? client.name[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.poppins(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    client.phone,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          isExpired
                              ? 'EXPIRED'
                              : isExpiringSoon
                                  ? 'EXPIRING SOON'
                                  : 'ACTIVE',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        client.plan,
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('memberGoals').doc(client.id).get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const SizedBox.shrink();
                      }
                      final data = snapshot.data!.data() as Map<String, dynamic>?;
                      if (data == null) return const SizedBox.shrink();

                      final goalName = data['goalDisplayName'] ?? 'Goal';
                      final weeksRemaining = data['weeksRemaining'] ?? 0;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '$goalName · $weeksRemaining wks',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Expires',
                  style: GoogleFonts.inter(
                      fontSize: 10, color: AppColors.textMuted),
                ),
                Text(
                  DateFormat('dd MMM yy').format(client.expiryDate),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  TAB 2 — DIET PLANS
// ═══════════════════════════════════════════════════════════

class _DietPlansTab extends StatelessWidget {
  final TrainerModel trainer;
  final FirestoreService firestoreService;

  const _DietPlansTab(
      {required this.trainer, required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MemberModel>>(
      stream: firestoreService.getMembersByTrainer(trainer.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }

        final clients = snapshot.data ?? [];

        if (clients.isEmpty) {
          return Center(
            child: Text('No clients to assign diet plans.',
                style: GoogleFonts.inter(color: AppColors.textSecondary)),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select a client to view or edit their diet plan:',
                style: GoogleFonts.inter(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: clients.length,
                itemBuilder: (context, index) {
                  final client = clients[index];
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    leading: CircleAvatar(
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        client.name[0].toUpperCase(),
                        style: GoogleFonts.poppins(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(client.name,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600)),
                    subtitle: Text(client.plan,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary)),
                    trailing:
                        const Icon(Icons.chevron_right, color: AppColors.primary),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Diet plan for ${client.name} — Coming soon!'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  TAB 3 — FEEDBACK
// ═══════════════════════════════════════════════════════════

class _FeedbackTab extends StatelessWidget {
  final TrainerModel trainer;
  final FirestoreService firestoreService;

  const _FeedbackTab(
      {required this.trainer, required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TrainerFeedbackModel>>(
      stream: firestoreService.getTrainerFeedback(trainer.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final feedbacks = snapshot.data ?? [];

        if (feedbacks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_outline,
                    size: 64, color: AppColors.textMuted),
                const SizedBox(height: 16),
                Text('No feedback received yet.',
                    style: GoogleFonts.inter(
                        color: AppColors.textSecondary, fontSize: 15)),
              ],
            ),
          );
        }

        // Average rating header
        final avgRating =
            feedbacks.map((f) => f.rating).reduce((a, b) => a + b) /
                feedbacks.length;

        return Column(
          children: [
            // Avg Rating Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.warning.withValues(alpha: 0.08),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: AppColors.warning, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    '${avgRating.toStringAsFixed(1)} avg rating · ${feedbacks.length} reviews',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: feedbacks.length,
                itemBuilder: (context, index) {
                  return _FeedbackCard(
                    feedback: feedbacks[index],
                    firestoreService: firestoreService,
                    trainerId: trainer.id,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final TrainerFeedbackModel feedback;
  final FirestoreService firestoreService;
  final String trainerId;

  const _FeedbackCard({
    required this.feedback,
    required this.firestoreService,
    required this.trainerId,
  });

  void _showReplyDialog(BuildContext context) {
    final replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reply to ${feedback.memberName}',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: replyController,
          decoration: const InputDecoration(
            hintText: 'Write your reply...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final reply = replyController.text.trim();
              if (reply.isEmpty) return;
              try {
                await firestoreService.replyToFeedback(
                    trainerId, feedback.id, reply);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                        content: Text('Reply submitted Check'),
                        backgroundColor: AppColors.success),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                        content: Text('Failed: $e'),
                        backgroundColor: AppColors.error),
                  );
                }
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Submit',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  feedback.memberName,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < feedback.rating.round()
                          ? Icons.star
                          : Icons.star_border,
                      color: AppColors.warning,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd MMM yyyy').format(feedback.createdAt),
              style: GoogleFonts.inter(
                  fontSize: 11, color: AppColors.textMuted),
            ),

            if (feedback.comment != null &&
                feedback.comment!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                feedback.comment!,
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textPrimary),
              ),
            ],

            const SizedBox(height: 12),

            if (feedback.hasReply) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Reply:',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feedback.trainerReply!,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showReplyDialog(context),
                  icon: const Icon(Icons.reply, size: 16),
                  label: const Text('Write a Reply'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


// ═══════════════════════════════════════════════════════════
//  TAB 0 — HOME
// ═══════════════════════════════════════════════════════════

class _HomeTab extends StatefulWidget {
  final TrainerModel trainer;
  final FirestoreService firestoreService;

  const _HomeTab({
    required this.trainer,
    required this.firestoreService,
  });

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final Map<String, bool> _expandedFeedback = {};
  final Map<String, TextEditingController> _replyControllers = {};

  @override
  void dispose() {
    for (var controller in _replyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section A: Quick Stats Row
          _buildQuickStats(context),

          const SizedBox(height: 20),

          // Section B: My Assigned Members Card
          _buildMyMembersCard(context),

          const SizedBox(height: 20),

          // Section C: Today's Sessions Card
          _buildSessionsTodayCard(context),

          const SizedBox(height: 20),

          // Section D: Pending Trainer Feedback Card
          _buildPendingFeedbackCard(context),

          const SizedBox(height: 20),

          // Section E: Member AI Plan Quick Access
          _buildMemberAiPlanAccess(context),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return Row(
      children: [
        // Tile 1: Assigned Members
        Expanded(
          child: StreamBuilder<List<MemberModel>>(
            stream: widget.firestoreService.getMembersByTrainer(widget.trainer.id),
            builder: (context, snapshot) {
              final count = snapshot.data?.length ?? 0;
              return _buildStatTile('Assigned\nMembers', count.toString());
            },
          ),
        ),
        const SizedBox(width: 8),

        // Tile 2: Feedback Pending
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('trainerFeedback')
                .where('trainerId', isEqualTo: widget.trainer.id)
                .where('trainerReply', isNull: true)
                .snapshots(),
            builder: (context, snapshot) {
              final count = snapshot.data?.docs.length ?? 0;
              return _buildStatTile('Feedback\nPending', count.toString());
            },
          ),
        ),
        const SizedBox(width: 8),

        // Tile 3: Sessions Today
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('attendance')
                .where('branch', isEqualTo: widget.trainer.branch)
                .where('checkInTime',
                    isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
                .where('checkInTime',
                    isLessThanOrEqualTo: Timestamp.fromDate(todayEnd))
                .snapshots(),
            builder: (context, snapshot) {
              final count = snapshot.data?.docs.length ?? 0;
              return _buildStatTile('Sessions\nToday', count.toString());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile(String label, String value) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.primary, width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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

  Widget _buildMyMembersCard(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.primary, width: 2),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'My Members',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                StreamBuilder<List<MemberModel>>(
                  stream: widget.firestoreService.getMembersByTrainer(widget.trainer.id),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.length ?? 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        count.toString(),
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<MemberModel>>(
              stream: widget.firestoreService.getMembersByTrainer(widget.trainer.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                final members = snapshot.data ?? [];
                if (members.isEmpty) {
                  return Text(
                    'Showing all members. Assign trainer field not set.',
                    style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                  );
                }

                final displayMembers = members.take(5).toList();
                final remainingCount = members.length - 5;

                return SizedBox(
                  height: 80,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...displayMembers.map((m) => Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const MembersListScreen(),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                      child: Text(
                                        m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                                        style: GoogleFonts.poppins(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      m.name.split(' ').first,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                        if (remainingCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MembersListScreen(),
                                  ),
                                );
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                                    child: Text(
                                      '+$remainingCount',
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'more',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsTodayCard(BuildContext context) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Sessions",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('attendance')
                      .where('branch', isEqualTo: widget.trainer.branch)
                      .where('checkInTime',
                          isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
                      .where('checkInTime',
                          isLessThanOrEqualTo: Timestamp.fromDate(todayEnd))
                      .snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        count.toString(),
                        style: GoogleFonts.inter(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('attendance')
                  .where('branch', isEqualTo: widget.trainer.branch)
                  .where('checkInTime',
                      isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
                  .where('checkInTime',
                      isLessThanOrEqualTo: Timestamp.fromDate(todayEnd))
                  .orderBy('checkInTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    'Failed to load sessions: ${snapshot.error}',
                    style: GoogleFonts.inter(color: AppColors.error, fontSize: 13),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No sessions recorded today.',
                        style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index].data() as Map<String, dynamic>;
                    final memberName = doc['memberName'] as String? ?? 'Unknown';
                    final checkInTime = (doc['checkInTime'] as Timestamp).toDate();
                    final formattedTime = DateFormat('hh:mm a').format(checkInTime);

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          memberName.isNotEmpty ? memberName[0].toUpperCase() : '?',
                          style: GoogleFonts.poppins(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        memberName,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        formattedTime,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildPendingFeedbackCard(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pending Feedback',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('trainerFeedback')
                      .where('trainerId', isEqualTo: widget.trainer.id)
                      .where('trainerReply', isNull: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        count.toString(),
                        style: GoogleFonts.inter(
                          color: AppColors.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('trainerFeedback')
                  .where('trainerId', isEqualTo: widget.trainer.id)
                  .where('trainerReply', isNull: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'All caught up!',
                        style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final docId = doc.id;
                    final memberName = data['memberName'] as String? ?? 'Unknown';
                    final comment = data['comment'] as String? ?? 'No comment provided.';

                    final isExpanded = _expandedFeedback[docId] ?? false;

                    if (!_replyControllers.containsKey(docId)) {
                      _replyControllers[docId] = TextEditingController();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            memberName,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            comment.length > 60 ? '${comment.substring(0, 60)}...' : comment,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              isExpanded ? Icons.close : Icons.reply,
                              color: AppColors.primary,
                            ),
                            onPressed: () {
                              setState(() {
                                _expandedFeedback[docId] = !isExpanded;
                              });
                            },
                          ),
                        ),
                        if (isExpanded)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _replyControllers[docId],
                                    decoration: InputDecoration(
                                      hintText: 'Write your reply...',
                                      hintStyle: GoogleFonts.inter(fontSize: 12),
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                    ),
                                    style: GoogleFonts.inter(fontSize: 13),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    final text = _replyControllers[docId]?.text.trim() ?? '';
                                    if (text.isEmpty) return;

                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('trainerFeedback')
                                          .doc(docId)
                                          .update({
                                        'trainerReply': text,
                                        'repliedAt': Timestamp.now(),
                                      });

                                      if (!context.mounted) return;
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Reply sent'),
                                            backgroundColor: AppColors.success,
                                          ),
                                        );
                                        setState(() {
                                          _expandedFeedback[docId] = false;
                                          _replyControllers[docId]?.clear();
                                        });
                                      }
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Failed to send reply'),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text('Send', style: GoogleFonts.inter(fontSize: 12, color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildMemberAiPlanAccess(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Plans',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<MemberModel>>(
              stream: widget.firestoreService.getMembersByTrainer(widget.trainer.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                final members = snapshot.data ?? [];
                if (members.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No assigned members yet.',
                        style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                  );
                }

                // Take last 3 assigned members
                final displayMembers = members.length > 3
                    ? members.sublist(members.length - 3)
                    : members;

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayMembers.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final member = displayMembers[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                          style: GoogleFonts.poppins(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        member.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.article_outlined, color: AppColors.primary),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MemberAiPlanScreen(
                                memberName: member.name,
                                memberDocId: member.id,
                                currentUserRole: 'Trainer',
                              ),
                            ),
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MemberAiPlanScreen(
                              memberName: member.name,
                              memberDocId: member.id,
                              currentUserRole: 'Trainer',
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}
