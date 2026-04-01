// lib/screens/trainer/trainer_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../models/trainer_model.dart';
import '../../../../models/member_model.dart';
import '../../../../services/firestore_service.dart';
import '../../../../utils/date_utils.dart' as appdateutils;
import 'add_trainer_screen.dart';
import '../../../../services/trainer_feedback_service.dart';
import '../../models/trainer_feedback_model.dart';
import '../../theme/app_colors.dart';

class TrainerDetailScreen extends StatefulWidget {
  final String trainerId;
  const TrainerDetailScreen({super.key, required this.trainerId});

  @override
  State<TrainerDetailScreen> createState() => _TrainerDetailScreenState();
}

class _TrainerDetailScreenState extends State<TrainerDetailScreen>
    with SingleTickerProviderStateMixin {
  final firestoreService = FirestoreService();
  final feedbackService = TrainerFeedbackService();

  late TabController _tabController;
  TrainerModel? _cachedTrainer; // FIX: cache so setState doesn't re-fetch
  bool _salaryVisible = false;  // FIX: salary privacy toggle

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTrainer();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTrainer() async {
    final trainer =
        await firestoreService.getTrainerById(widget.trainerId);
    if (mounted) setState(() => _cachedTrainer = trainer);
  }

  // ── Quick Contact ─────────────────────────────────────────────────
  Future<void> _callTrainer(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsappTrainer(String phone) async {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('https://wa.me/91$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Assign / Remove / Toggle ──────────────────────────────────────
  Future<void> showAssignMemberDialog(TrainerModel trainer) async {
    final allMembers = await firestoreService.getAllMembers().first;
    final availableMembers = allMembers
        .where((m) => m.trainerId == null || m.trainerId!.isEmpty)
        .toList();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.person_add, color: AppColors.success),
          SizedBox(width: 12),
          Text('Assign Member'),
        ]),
        content: SizedBox(
          width: double.maxFinite,
          child: availableMembers.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No available members to assign.\nAll members are already assigned to trainers.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableMembers.length,
                  itemBuilder: (_, index) {
                    final member = availableMembers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.success.withValues(alpha: 0.1),
                          child: Text(
                            member.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(member.name),
                        subtitle: Text('${member.category} · ${member.plan}',
                            style: const TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.add_circle,
                            color: AppColors.success),
                        onTap: () async {
                          Navigator.pop(ctx);
                          await assignMember(trainer, member);
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> assignMember(
      TrainerModel trainer, MemberModel member) async {
    try {
      await firestoreService.assignMemberToTrainer(
          trainer.id, member.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${member.name} assigned to ${trainer.name}'),
        backgroundColor: AppColors.success,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  Future<void> removeMember(
      TrainerModel trainer, MemberModel member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Member?'),
        content: Text(
            'Remove ${member.name} from ${trainer.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await firestoreService.removeMemberFromTrainer(
          trainer.id, member.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${member.name} removed from ${trainer.name}'),
        backgroundColor: AppColors.warning,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  Future<void> toggleTrainerStatus(TrainerModel trainer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
            trainer.isActive ? 'Deactivate Trainer?' : 'Activate Trainer?'),
        content: Text(trainer.isActive
            ? 'This will mark the trainer as inactive.'
            : 'This will reactivate the trainer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    trainer.isActive ? AppColors.warning : AppColors.success),
            child: Text(trainer.isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final updated = trainer.copyWith(isActive: !trainer.isActive);
      await firestoreService.updateTrainer(updated);
      if (!mounted) return;
      setState(() => _cachedTrainer = updated); // update cache
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Trainer ${trainer.isActive ? 'deactivated' : 'activated'}'),
        backgroundColor: AppColors.success,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_cachedTrainer == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.success),
        ),
      );
    }
    final trainer = _cachedTrainer!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          // ── Sliver App Bar ─────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            actions: [
              // Quick call
              IconButton(
                icon: const Icon(Icons.call_rounded),
                tooltip: 'Call',
                onPressed: () => _callTrainer(trainer.phone),
              ),
              // Quick WhatsApp
              IconButton(
                icon: const Icon(Icons.chat_rounded),
                tooltip: 'WhatsApp',
                onPressed: () => _whatsappTrainer(trainer.phone),
              ),
              // Edit
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddTrainerScreen(trainer: trainer),
                    ),
                  );
                  if (result == true) _loadTrainer();
                },
              ),
              // More menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'status',
                    child: Row(children: [
                      Icon(
                        trainer.isActive
                            ? Icons.block
                            : Icons.check_circle,
                        size: 20,
                        color:
                            trainer.isActive ? AppColors.warning : AppColors.success,
                      ),
                      const SizedBox(width: 12),
                      Text(trainer.isActive ? 'Deactivate' : 'Activate'),
                    ]),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'status') toggleTrainerStatus(trainer);
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 60, bottom: 64),
              title: Text(
                trainer.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(blurRadius: 4, color: Colors.black45)
                    ]),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.success, AppColors.turquoise],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // subtle geometric overlay instead of broken asset
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _CirclePatternPainter(),
                      ),
                    ),
                    // Avatar + status badge
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 24),
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 46,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.9),
                                  child: trainer.photoUrl != null
                                      ? ClipOval(
                                          child: Image.network(
                                            trainer.photoUrl!,
                                            width: 92,
                                            height: 92,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                _avatarInitials(
                                                    trainer.name),
                                          ),
                                        )
                                      : _avatarInitials(trainer.name),
                                ),
                              ),
                              // Active/Inactive dot
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: trainer.isActive
                                        ? AppColors.success
                                        : AppColors.error,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                ),
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
            // ── TabBar pinned below app bar ──────────────────────
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(icon: Icon(Icons.info_outline), text: 'Overview'),
                Tab(icon: Icon(Icons.people), text: 'Members'),
                Tab(icon: Icon(Icons.star_outline), text: 'Reviews'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(trainer),
            _buildMembersTab(trainer),
            _buildReviewsTab(trainer),
          ],
        ),
      ),
    );
  }

  Widget _avatarInitials(String name) => Text(
        name.substring(0, 1).toUpperCase(),
        style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.success),
      );

  // ── Tab 1: Overview ───────────────────────────────────────────────
  Widget _buildOverviewTab(TrainerModel trainer) {
    return StreamBuilder<List<MemberModel>>(
      stream: firestoreService.getMembersByTrainer(trainer.id),
      builder: (context, snapshot) {
        final memberCount = snapshot.data?.length ?? 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Status badge
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: trainer.isActive
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: trainer.isActive ? AppColors.success : AppColors.error,
                    width: 2,
                  ),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                      trainer.isActive
                          ? Icons.check_circle
                          : Icons.block,
                      color: trainer.isActive ? AppColors.success : AppColors.error,
                      size: 20),
                  const SizedBox(width: 8),
                  Text(
                    trainer.isActive ? 'Active Trainer' : 'Inactive',
                    style: TextStyle(
                        color:
                            trainer.isActive ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ]),
              ),
              const SizedBox(height: 16),

              // Quick stats row — member count from stream (live)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  Expanded(
                    child: buildStatCard(
                        'Members', '$memberCount',
                        Icons.people, AppColors.success),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildStatCard(
                        'Experience', trainer.experience,
                        Icons.timeline, AppColors.turquoise),
                  ),
                  const SizedBox(width: 12),
                  // Salary with eye toggle
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(
                          () => _salaryVisible = !_salaryVisible),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(children: [
                          Icon(
                              _salaryVisible
                                  ? Icons.currency_rupee
                                  : Icons.visibility_off,
                              color: AppColors.info,
                              size: 28),
                          const SizedBox(height: 8),
                          Text(
                            _salaryVisible
                                ? trainer.salary.toStringAsFixed(0)
                                : '••••',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.info),
                          ),
                          const SizedBox(height: 4),
                          const Text('Salary',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ]),
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 8),

              // Quick contact row
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Row(children: [
                  Expanded(
                    child: _contactButton(
                      icon: Icons.call_rounded,
                      label: 'Call',
                      color: AppColors.success,
                      onTap: () => _callTrainer(trainer.phone),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _contactButton(
                      icon: Icons.chat_rounded,
                      label: 'WhatsApp',
                      color: AppColors.whatsApp,
                      onTap: () => _whatsappTrainer(trainer.phone),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 8),

              // Personal info
              buildInfoSection(
                'Personal Information',
                Icons.person,
                [
                  buildInfoRow('Phone', trainer.phone, Icons.phone),
                  buildInfoRow('Email', trainer.email, Icons.email),
                  buildInfoRow('Gender', trainer.gender, Icons.wc),
                  if (trainer.dateOfBirth != null)
                    buildInfoRow(
                        'Date of Birth',
                        appdateutils.DateUtils.formatDate(
                            trainer.dateOfBirth!),
                        Icons.cake),
                  if (trainer.address != null &&
                      trainer.address!.isNotEmpty)
                    buildInfoRow(
                        'Address', trainer.address!, Icons.home),
                ],
              ),

              // Professional details
              buildInfoSection(
                'Professional Details',
                Icons.work,
                [
                  buildInfoRow('Specialization',
                      trainer.specialization, Icons.fitness_center),
                  buildInfoRow('Experience', trainer.experience,
                      Icons.timeline),
                  buildInfoRow('Qualification',
                      trainer.qualification, Icons.school),
                  buildInfoRow(
                      'Branch', trainer.branch, Icons.location_on),
                  buildInfoRow(
                      'Joining Date',
                      appdateutils.DateUtils.formatDate(
                          trainer.joiningDate),
                      Icons.event),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Tab 2: Members ────────────────────────────────────────────────
  Widget _buildMembersTab(TrainerModel trainer) {
    return StreamBuilder<List<MemberModel>>(
      stream: firestoreService.getMembersByTrainer(trainer.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.success));
        }
        final members = snapshot.data ?? [];

        return Column(
          children: [
            // Header bar
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.success.withValues(alpha: 0.06),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [AppColors.success, AppColors.turquoise]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.people,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${members.length} Member${members.length == 1 ? '' : 's'} Assigned',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ]),
                  ElevatedButton.icon(
                    onPressed: () => showAssignMemberDialog(trainer),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Assign'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ],
              ),
            ),
            // Member list
            Expanded(
              child: members.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off_outlined,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text('No members assigned yet',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600)),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () =>
                                showAssignMemberDialog(trainer),
                            icon: const Icon(Icons.add),
                            label: const Text('Assign Members'),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: members.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final member = members[index];
                        final isActive = DateTime.now()
                            .isBefore(member.expiryDate);
                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                          leading: CircleAvatar(
                            backgroundColor: isActive
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.error.withValues(alpha: 0.1),
                            child: Text(
                              member.name
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: TextStyle(
                                  color: isActive
                                      ? AppColors.success
                                      : AppColors.error,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(member.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              '${member.category} · ${member.plan}',
                              style:
                                  const TextStyle(fontSize: 12)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.success
                                          .withValues(alpha: 0.1)
                                      : AppColors.error
                                          .withValues(alpha: 0.1),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isActive ? 'Active' : 'Expired',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isActive
                                          ? AppColors.success
                                          : AppColors.error),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                    Icons.remove_circle,
                                    color: AppColors.error),
                                iconSize: 20,
                                onPressed: () =>
                                    removeMember(trainer, member),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  // ── Tab 3: Reviews / Feedback ──────────────────────────────────────
  Widget _buildReviewsTab(TrainerModel trainer) {
    return StreamBuilder<List<TrainerFeedbackModel>>(
      stream: feedbackService.getFeedbackForTrainer(trainer.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.success));
        }
        final feedbacks = snapshot.data ?? [];

        // Compute average rating
        double avgRating = 0;
        if (feedbacks.isNotEmpty) {
          avgRating = feedbacks.fold(0.0, (acc, f) => acc + f.rating) /
              feedbacks.length;
        }

        return Column(
          children: [
            // Rating summary banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.success, AppColors.turquoise],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(children: [
                    Text(
                      avgRating > 0
                          ? avgRating.toStringAsFixed(1)
                          : '—',
                      style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < avgRating.round()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: AppColors.warning,
                          size: 24,
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${feedbacks.length} review${feedbacks.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                  ]),
                ],
              ),
            ),
            // Review list
            Expanded(
              child: feedbacks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.reviews_outlined,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text('No reviews yet',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: feedbacks.length,
                      itemBuilder: (context, index) {
                        final fb = feedbacks[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: AppColors.success
                                            .withValues(alpha: 0.1),
                                        child: Text(
                                          (fb.memberName.isNotEmpty
                                                  ? fb.memberName
                                                  : '?')
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: const TextStyle(
                                              color: AppColors.success,
                                              fontWeight:
                                                  FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            fb.memberName.isNotEmpty
                                                ? fb.memberName
                                                : 'Anonymous',
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                          Text(
                                            appdateutils.DateUtils
                                                .formatDate(
                                                    fb.createdAt),
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors
                                                    .grey.shade500),
                                          ),
                                        ],
                                      ),
                                    ]),
                                    // Star chips
                                    Row(
                                      children: List.generate(5, (i) {
                                        return Icon(
                                          i < fb.rating
                                              ? Icons.star_rounded
                                              : Icons.star_outline_rounded,
                                          color: AppColors.warning,
                                          size: 16,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                                if (fb.comment != null && fb.comment!.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    fb.comment!,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                        height: 1.4),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  // ── Shared Widgets ────────────────────────────────────────────────
  Widget _contactButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(label,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ]),
    );
  }

  Widget buildInfoSection(
      String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.success, AppColors.turquoise]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ]),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Subtle background pattern painter (replaces broken asset) ────────
class _CirclePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (double x = 0; x <= size.width + 80; x += 80) {
      for (double y = 0; y <= size.height + 80; y += 80) {
        canvas.drawCircle(Offset(x, y), 30, paint);
        canvas.drawCircle(Offset(x, y), 55, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
