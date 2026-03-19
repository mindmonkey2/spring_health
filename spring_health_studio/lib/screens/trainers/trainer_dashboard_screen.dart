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
              return _MyClientsTab(
                  trainer: _trainerProfile!, firestoreService: _firestoreService);
            case 1:
              return _DietPlansTab(
                  trainer: _trainerProfile!, firestoreService: _firestoreService);
            case 2:
              return _FeedbackTab(
                  trainer: _trainerProfile!, firestoreService: _firestoreService);
            default:
              return _MyClientsTab(
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
                        content: Text('Reply submitted ✅'),
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
