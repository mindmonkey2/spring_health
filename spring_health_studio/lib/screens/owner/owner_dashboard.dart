// lib/screens/owner/owner_dashboard.dart
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../utils/responsive.dart';
import '../../theme/app_colors.dart';
import '../members/members_list_screen.dart';
import '../members/add_member_screen.dart';
import '../attendance/qr_scanner_screen.dart';
import '../reports/reports_screen.dart';
import 'owner_dashboard_web.dart';
import '../expenses/expenses_screen.dart';
import '../analytics/analytics_dashboard.dart';
import '../trainers/trainers_list_screen.dart';
import '../notifications/notifications_dashboard.dart';
import '../reminders/reminders_dashboard.dart';
// ── TASK 1 FIX: replaced CreateAnnouncementScreen with AnnouncementsListScreen
import '../announcements/announcements_list_screen.dart';
import '../gamification/admin_gamification_dashboard_screen.dart';
import '../equipment/equipment_manager_screen.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard>
    with SingleTickerProviderStateMixin {
  final firestoreService = FirestoreService();
  String? selectedBranch;
  Map<String, dynamic> stats = {};
  Map<String, Map<String, dynamic>> branchWiseStats = {};
  bool isLoading = true;
  int todayBirthdays = 0;
  int expiringThisWeek = 0;
  int todayCheckIns = 0;

  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  // Palette aliases
  static const Color gradStart = AppColors.primary;
  static const Color gradEnd = AppColors.primaryDark;
  static const Color coral = AppColors.coral;
  static const Color teal = AppColors.turquoise;
  static const Color pink = AppColors.pink;
  static const Color sky = AppColors.skyBlue;
  static const Color dark = AppColors.textPrimary;
  static const Color bg = AppColors.background;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );
    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: animationController, curve: Curves.easeOut));
    loadData();
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  // ── Data Loading ────────────────────────────────────────────────
  Future<void> loadData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      if (selectedBranch == null) {
        final s = await firestoreService.getDashboardStats(null);
        final bw = await firestoreService.getBranchWiseStats();
        final mr = await firestoreService.getMonthlyRevenue(null);
        s['monthlyRevenue'] = mr['total'];
        s['monthlyCash'] = mr['cash'];
        s['monthlyUpi'] = mr['upi'];
        s['totalDiscount'] = mr['discount'];
        await loadTodaysHighlights(null);
        if (mounted) setState(() { stats = s; branchWiseStats = bw; });
      } else {
        final s = await firestoreService.getDashboardStats(selectedBranch);
        final mr = await firestoreService.getMonthlyRevenue(selectedBranch);
        final branchTotals = await firestoreService.getBranchMemberTotals(selectedBranch!);

        final paid = branchTotals['paid'] ?? 0.0;
        final cash = branchTotals['cash'] ?? 0.0;
        final upi = branchTotals['upi'] ?? 0.0;

        s['monthlyRevenue'] = ((mr['total'] as double?) ?? 0) > 0 ? mr['total'] : paid;
        s['monthlyCash']   = ((mr['cash']  as double?) ?? 0) > 0 ? mr['cash']  : cash;
        s['monthlyUpi']    = ((mr['upi']   as double?) ?? 0) > 0 ? mr['upi']   : upi;

        s['totalDiscount'] = mr['discount'] ?? 0;
        await loadTodaysHighlights(selectedBranch);
        if (mounted) setState(() { stats = s; branchWiseStats = {}; });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error loading dashboard: $e'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: loadData,
          ),
        ));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> loadTodaysHighlights(String? branch) async {
    try {
      final members =
          await firestoreService.getMembers(branch: branch).first;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      todayBirthdays = members.where((m) {
        if (m.dateOfBirth == null) return false;
        final bd =
            DateTime(now.year, m.dateOfBirth!.month, m.dateOfBirth!.day);
        return bd == today;
      }).length;
      expiringThisWeek = members.where((m) {
        final d = m.expiryDate.difference(now).inDays;
        return d >= 0 && d <= 7 && now.isBefore(m.expiryDate);
      }).length;
      final todayStart = today;
      final todayEnd = today.add(const Duration(days: 1));
      todayCheckIns = members.where((m) {
        final lc = m.lastCheckIn;
        if (lc == null) return false;
        return lc.isAfter(todayStart) && lc.isBefore(todayEnd);
      }).length;
    } catch (e) {
      debugPrint('Error loading highlights: $e');
    }
  }

  // ── Build ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: buildMobileLayout(),
      desktop: const OwnerDashboardWeb(),
    );
  }

  Widget buildMobileLayout() {
    return Scaffold(
      backgroundColor: bg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [gradStart, gradEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        actions: [
          // Notification bell with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 28),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        NotificationsDashboard(branch: selectedBranch),
                  ),
                ),
              ),
              if (todayBirthdays + expiringThisWeek > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [coral, pink]),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: coral.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                        minWidth: 18, minHeight: 18),
                    child: Text(
                      '${todayBirthdays + expiringThisWeek}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 24),
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed('/login'),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(gradStart),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Loading your dashboard...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: loadData,
              color: gradStart,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: SlideTransition(
                    position: slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gradient spacer behind app bar
                        Container(
                          height: 100,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [gradStart, gradEnd],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildBranchSelector(),
                              const SizedBox(height: 20),
                              if (todayBirthdays > 0 ||
                                  expiringThisWeek > 0 ||
                                  todayCheckIns > 0)
                                buildTodaysHighlights(),
                              const SizedBox(height: 20),
                              buildStatsCards(),
                              const SizedBox(height: 20),
                              buildRevenueSummary(),
                              if (selectedBranch == null &&
                                  branchWiseStats.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                buildBranchWiseStats(),
                              ],
                              const SizedBox(height: 20),
                              buildQuickActions(),
                              const SizedBox(height: 20),
                              buildMoreOptions(),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  // ── Branch Selector ──────────────────────────────────────────────
  Widget buildBranchSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFF8F9FA)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradStart.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: selectedBranch,
                isExpanded: true,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [gradStart, gradEnd]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_drop_down,
                      color: Colors.white),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: dark,
                ),
                items: const [
                  DropdownMenuItem(
                    value: null,
                    child: Row(children: [
                      Icon(Icons.dashboard_rounded,
                          color: gradStart, size: 20),
                      SizedBox(width: 12),
                      Text('All Branches'),
                    ]),
                  ),
                  DropdownMenuItem(
                    value: 'Hanamkonda',
                    child: Row(children: [
                      SizedBox(
                        width: 10,
                        height: 10,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: teal,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.location_on_rounded,
                          color: teal, size: 20),
                      SizedBox(width: 8),
                      Text('Hanamkonda Branch'),
                    ]),
                  ),
                  DropdownMenuItem(
                    value: 'Warangal',
                    child: Row(children: [
                      SizedBox(
                        width: 10,
                        height: 10,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: coral,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.location_on_rounded,
                          color: coral, size: 20),
                      SizedBox(width: 8),
                      Text('Warangal Branch'),
                    ]),
                  ),
                ],
                onChanged: (value) {
                  setState(() => selectedBranch = value);
                  loadData();
                  animationController
                    ..reset()
                    ..forward();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Today's Highlights ───────────────────────────────────────────
  Widget buildTodaysHighlights() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [pink, coral],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: pink.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.wb_sunny_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Today's Highlights",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (todayBirthdays > 0)
                    Expanded(
                      child: buildHighlightCard(
                        '🎂',
                        '$todayBirthdays',
                        'Birthday${todayBirthdays > 1 ? 's' : ''}',
                      ),
                    ),
                  if (todayBirthdays > 0 && expiringThisWeek > 0)
                    const SizedBox(width: 12),
                  if (expiringThisWeek > 0)
                    Expanded(
                      child: buildHighlightCard(
                          '⏰', '$expiringThisWeek', 'Expiring'),
                    ),
                  if ((todayBirthdays > 0 || expiringThisWeek > 0) &&
                      todayCheckIns > 0)
                    const SizedBox(width: 12),
                  if (todayCheckIns > 0)
                    Expanded(
                      child: buildHighlightCard(
                          '✅', '$todayCheckIns', 'Check-ins'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHighlightCard(
      String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        children: [
          Text(emoji,
              style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Stats Cards ──────────────────────────────────────────────────
  Widget buildStatsCards() {
    final cards = [
      {
        'title': 'Total Members',
        'value': '${stats['totalMembers'] ?? 0}',
        'icon': Icons.people_rounded,
        'gradient': const [Color(0xFF667EEA), Color(0xFF764BA2)],
        'filter': null,
      },
      {
        'title': 'Active',
        'value': '${stats['activeMembers'] ?? 0}',
        'icon': Icons.verified_user_rounded,
        'gradient': const [Color(0xFF4ECDC4), Color(0xFF44A08D)],
        'filter': 'Active',
      },
      {
        'title': 'Near Expiry',
        'value': '${stats['nearExpiry'] ?? 0}',
        'icon': Icons.warning_amber_rounded,
        'gradient': const [Color(0xFFFFE66D), Color(0xFFFFAA00)],
        'filter': 'Near Expiry',
      },
      {
        'title': 'Dues',
        'value':
            (stats['totalDues'] as double? ?? 0).toStringAsFixed(0),
        'icon': Icons.account_balance_wallet_rounded,
        'gradient': const [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
        'filter': 'Pending Dues',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
        ),
        itemCount: cards.length,
        itemBuilder: (context, i) {
          final c = cards[i];
          return buildStatCard(
            c['title'] as String,
            c['value'] as String,
            c['icon'] as IconData,
            c['gradient'] as List<Color>,
            c['filter'] as String?,
          );
        },
      ),
    );
  }

  Widget buildStatCard(
    String title,
    String value,
    IconData icon,
    List<Color> gradientColors,
    String? filter,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.white, Colors.white.withValues(alpha: 0.9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MembersListScreen(
                  branch: selectedBranch, initialFilter: filter),
            ),
          ),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradientColors),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: gradientColors[0])),
                    const SizedBox(height: 4),
                    Text(title,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Revenue Summary ──────────────────────────────────────────────
  Widget buildRevenueSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [gradStart, gradEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradStart.withValues(alpha: 0.4),
              blurRadius: 25,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReportsScreen(
                  branch: selectedBranch,
                  initialReportType: 'Revenue',
                  initialDateRange: 'This Month',
                ),
              ),
            ),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.currency_rupee,
                              color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 12),
                        const Text('Revenue',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ]),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: const Row(children: [
                          Text('View All',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios,
                              color: Colors.white, size: 12),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${monthName(DateTime.now().month)} ${DateTime.now().year}',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8)),
                  ),
                  const SizedBox(height: 16),
                  // Total
                  Text(
                    (stats['monthlyRevenue'] as double? ?? 0)
                        .toStringAsFixed(2),
                    style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.white.withValues(alpha: 0),
                        Colors.white.withValues(alpha: 0.5),
                        Colors.white.withValues(alpha: 0),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Breakdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      buildRevenueDetail(
                          'Cash',
                          (stats['monthlyCash'] as double? ?? 0)
                              .toStringAsFixed(0),
                          Icons.money_rounded),
                      Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withValues(alpha: 0.3)),
                      buildRevenueDetail(
                          'UPI',
                          (stats['monthlyUpi'] as double? ?? 0)
                              .toStringAsFixed(0),
                          Icons.qr_code_rounded),
                      Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withValues(alpha: 0.3)),
                      buildRevenueDetail(
                          'Disc.',
                          (stats['totalDiscount'] as double? ?? 0)
                              .toStringAsFixed(0),
                          Icons.discount_rounded),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRevenueDetail(
      String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 18),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ── Branch-wise Stats ────────────────────────────────────────────
  Widget buildBranchWiseStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Text('Branch Statistics',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: dark)),
        ),
        ...branchWiseStats.entries.map((entry) {
          final colors = entry.key == 'Hanamkonda'
              ? [teal, const Color(0xFF44A08D)]
              : [coral, const Color(0xFFEE5A6F)];
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colors[0].withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() => selectedBranch = entry.key);
                    loadData();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.location_on_rounded,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.key,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            const SizedBox(height: 6),
                            Text(
                              '${entry.value['totalMembers']} Members · '
                              'Rs. ${(entry.value['totalRevenue'] as double? ?? 0).toStringAsFixed(0)}',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white
                                      .withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.white),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Quick Actions ────────────────────────────────────────────────
  // TASK 1: Announcements → AnnouncementsListScreen (was CreateAnnouncementScreen)
  // Gamification tile already present in the original file ✅
  Widget buildQuickActions() {
    final actions = [
      {
        'title': 'Add Member',
        'icon': Icons.person_add_rounded,
        'gradient': const [Color(0xFF4ECDC4), Color(0xFF44A08D)],
        'route': const AddMemberScreen(),
        'badge': 0,
      },
      {
        'title': 'QR Scanner',
        'icon': Icons.qr_code_scanner_rounded,
        'gradient': const [Color(0xFF667EEA), Color(0xFF764BA2)],
        'route': const QRScannerScreen(),
        'badge': 0,
      },
      {
        'title': 'Reports',
        'icon': Icons.analytics_rounded,
        'gradient': const [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
        'route': ReportsScreen(branch: selectedBranch),
        'badge': 0,
      },
      {
        'title': 'All Members',
        'icon': Icons.people_rounded,
        'gradient': const [Color(0xFFFFE66D), Color(0xFFFFAA00)],
        'route': MembersListScreen(branch: selectedBranch),
        'badge': 0,
      },
      {
        'title': 'Notifications',
        'icon': Icons.notifications_active_rounded,
        'gradient': const [Color(0xFFFF6B9D), Color(0xFFC06C84)],
        'route': NotificationsDashboard(branch: selectedBranch),
        'badge': todayBirthdays + expiringThisWeek,
      },
      // ── TASK 1 FIX: was CreateAnnouncementScreen → now AnnouncementsListScreen
      {
        'title': 'Announcements',
        'icon': Icons.campaign_rounded,
        'gradient': const [Color(0xFF06B6D4), Color(0xFF0891B2)],
        'route': const AnnouncementsListScreen(),
        'badge': 0,
      },
      {
        'title': 'Reminders',
        'icon': Icons.send_rounded,
        'gradient': const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
        'route': RemindersDashboard(branch: selectedBranch),
        'badge': 0,
      },
      {
        'title': 'Trainers',
        'icon': Icons.fitness_center_rounded,
        'gradient': const [Color(0xFF8B5CF6), Color(0xFF6B21A8)],
        'route': TrainersListScreen(branch: selectedBranch),
        'badge': 0,
      },
      {
        'title': 'Gym Equipment',
        'icon': Icons.fitness_center,
        'gradient': const [Color(0xFF8B5CF6), Color(0xFF6B21A8)],
        'route': const EquipmentManagerScreen(),
        'badge': 0,
      },
      // Gamification — already in original file ✅
      {
        'title': 'Gamification',
        'icon': Icons.emoji_events_rounded,
        'gradient': const [Color(0xFF10B981), Color(0xFF14B8A6)],
        'route': const AdminGamificationDashboardScreen(),
        'badge': 0,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Text('Quick Actions',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: dark)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: actions.length,
            itemBuilder: (context, i) {
              final a = actions[i];
              return buildActionCard(
                a['title'] as String,
                a['icon'] as IconData,
                a['gradient'] as List<Color>,
                a['route'] as Widget,
                badge: a['badge'] as int,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildActionCard(
    String title,
    IconData icon,
    List<Color> gradientColors,
    Widget route, {
    int badge = 0,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white.withValues(alpha: 0.95)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => route)),
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradientColors),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors[0].withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: dark,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      gradient:
                          LinearGradient(colors: [coral, pink]),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── More Options ─────────────────────────────────────────────────
  Widget buildMoreOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Text('More Options',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: dark)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                buildMoreOptionTile(
                  'Expenses',
                  'Record & track expenses',
                  Icons.receipt_long_rounded,
                  const Color(0xFFF87171),
                  const Color(0xFFDC2626),
                  const ExpensesScreen(),
                ),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.grey.withValues(alpha: 0.1),
                ),
                buildMoreOptionTile(
                  'Analytics',
                  'Revenue trends & insights',
                  Icons.analytics_rounded,
                  sky,
                  const Color(0xFF2563EB),
                  const AnalyticsDashboard(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildMoreOptionTile(
    String title,
    String subtitle,
    IconData icon,
    Color colorA,
    Color colorB,
    Widget route,
  ) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [colorA, colorB]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: colorA.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorA.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.arrow_forward_ios_rounded,
            size: 16, color: colorA),
      ),
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => route)),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────
  String monthName(int month) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[month - 1];
  }
}
