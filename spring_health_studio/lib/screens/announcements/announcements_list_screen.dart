

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import 'create_announcement_screen.dart';

class AnnouncementsListScreen extends StatefulWidget {
  const AnnouncementsListScreen({super.key});

  @override
  State<AnnouncementsListScreen> createState() =>
  _AnnouncementsListScreenState();
}

class _AnnouncementsListScreenState extends State<AnnouncementsListScreen>
with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color sageGreen  = Color(0xFF10B981);
  static const Color tealAqua   = Color(0xFF14B8A6);
  static const Color warmYellow = Color(0xFFFCD34D);
  static const Color coralRed   = Color(0xFFEF4444);
  static const Color softBlue   = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<List<Map<String, dynamic>>> _getAnnouncements() {
    return FirebaseFirestore.instance
    .collection('announcements')
    .orderBy('createdAt', descending: true)
    .snapshots()
    .map((s) => s.docs
    .map((d) => {'id': d.id, ...d.data()})
    .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Announcements',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                          flexibleSpace: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryDark]),
                            ),
                          ),
                     foregroundColor: Colors.white,
                       bottom: TabBar(
                         controller: _tabController,
                         indicatorColor: Colors.white,
                         labelColor: Colors.white,
                         unselectedLabelColor: Colors.white70,
                         tabs: const [
                           Tab(icon: Icon(Icons.list_alt_rounded),  text: 'All'),
                           Tab(icon: Icon(Icons.bar_chart_rounded), text: 'Analytics'),
                         ],
                       ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildListTab(), _buildAnalyticsTab()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context,
                               MaterialPageRoute(
                                 builder: (_) => const CreateAnnouncementScreen()));
          setState(() {}); // refresh after create
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Announcement'),
      ),
    );
  }

  // ── Tab 1 : List ─────────────────────────────────────────────────

  Widget _buildListTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getAnnouncements(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: sageGreen));
        }
        final all = snapshot.data ?? [];
        if (all.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.campaign_outlined,
                     size: 72, color: Colors.grey.shade400),
                     const SizedBox(height: 16),
                     const Text('No announcements yet',
                                style: TextStyle(fontSize: 18, color: Colors.grey)),
                                const SizedBox(height: 8),
                                const Text('Tap + to create your first one',
                                           style: TextStyle(color: Colors.grey)),
              ]),
          );
        }

        final active   = all.where((a) => a['isActive'] != false).toList();
        final archived = all.where((a) => a['isActive'] == false).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            if (active.isNotEmpty) ...[
              _sectionLabel('Ready Active (${active.length})', sageGreen),
              ...active.map(_announcementCard),
            ],
            if (archived.isNotEmpty) ...[
              const SizedBox(height: 8),
              _sectionLabel(' Archived (${archived.length})',
              Colors.grey),
              ...archived.map(_announcementCard),
            ],
          ],
        );
      },
    );
  }

  Widget _sectionLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(text,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.5)),
    );
  }

  Widget _announcementCard(Map<String, dynamic> a) {
    final isActive   = a['isActive'] != false;
    final priority   = a['priority'] as String? ?? 'normal';
    final readBy     = (a['readBy'] as List?)?.length ?? 0;
    final branch     = a['branch'] as String? ??
    ((a['targetBranches'] as List?)?.contains('all') == true
    ? 'All'
    : (a['targetBranches'] as List?)?.join(', ') ?? 'All');

    final priorityColor = priority == 'urgent'
    ? coralRed
    : priority == 'important'
    ? const Color(0xFFF59E0B)
    : Colors.grey.shade400;

    final branchColor = branch == 'All'
    ? softBlue
    : branch.contains('Hanamkonda')
    ? sageGreen
    : tealAqua;

    final createdAt = a['createdAt'] != null
    ? (a['createdAt'] as dynamic).toDate() as DateTime
    : DateTime.now();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                            width: 10, height: 10,
                            decoration: BoxDecoration(
                              color: priorityColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(a['title'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                          ),
                          // Branch chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: branchColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: branchColor.withValues(alpha: 0.4)),
                              ),
                              child: Text(branch,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: branchColor)),
                          ),
                        ]),
                      const SizedBox(height: 6),
                      Text(a['message'] ?? a['content'] ?? '',
                           maxLines: 2,
                           overflow: TextOverflow.ellipsis,
                           style: TextStyle(
                             color: Colors.grey.shade600, fontSize: 13)),
                      const SizedBox(height: 10),
                      Row(children: [
                        Icon(Icons.visibility_rounded,
                             size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text('$readBy read',
                               style: TextStyle(
                                 fontSize: 12, color: Colors.grey.shade500)),
                          const Spacer(),
                          Text(_formatDate(createdAt),
                          style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade400)),
                          const SizedBox(width: 12),
                          if (isActive)
                            _iconBtn(Icons.archive_rounded, warmYellow,
                                     () => _setActive(a['id'], false))
                            else ...[
                              _iconBtn(Icons.unarchive_rounded, sageGreen,
                                       () => _setActive(a['id'], true)),
                                       const SizedBox(width: 4),
                                       _iconBtn(Icons.delete_rounded, coralRed,
                                                () => _confirmDelete(a['id'], a['title'] ?? '')),
                            ],
                      ]),
                      ]),
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  // ── Tab 2 : Analytics ────────────────────────────────────────────

  Widget _buildAnalyticsTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getAnnouncements(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: sageGreen));
        }
        final all = snapshot.data ?? [];
        if (all.isEmpty) {
          return const Center(child: Text('No data yet'));
        }

        final active      = all.where((a) => a['isActive'] != false).length;
        final archived    = all.where((a) => a['isActive'] == false).length;
        // AFTER — rename accumulator from 'sum' to 'acc'
        final totalReads = all.fold<int>(
          0, (acc, a) => acc + ((a['readBy'] as List?)?.length ?? 0));
        final urgentCount = all
        .where((a) =>
        a['priority'] == 'urgent' && a['isActive'] != false)
        .length;

        final sorted = [...all]..sort((a, b) =>
        ((b['readBy'] as List?)?.length ?? 0)
        .compareTo((a['readBy'] as List?)?.length ?? 0));
        final top5 = sorted.take(5).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Summary strip
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryDark]),
                                borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _stat('${all.length}', 'Total'),
                                _vDiv(),
                                _stat('$active', 'Active'),
                                _vDiv(),
                                _stat('$archived', 'Archived'),
                                _vDiv(),
                                _stat('$totalReads', 'Reads'),
                              ]),
                          ),
                        const SizedBox(height: 12),

                        if (urgentCount > 0)
                          _alertBanner(Icons.warning_rounded,
                                       '$urgentCount urgent active', coralRed),

                        const SizedBox(height: 8),
                        const Text('Top by Read Count',
                                   style: TextStyle(
                                     fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),

                        ...top5.asMap().entries.map((e) {
                          final a      = e.value;
                          final reads  = (a['readBy'] as List?)?.length ?? 0;
                          final branch = a['branch'] as String? ?? 'All';
                        final createdAt = a['createdAt'] != null
                        ? (a['createdAt'] as dynamic).toDate() as DateTime
                        : DateTime.now();

                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                AppColors.primary.withValues(alpha: 0.15),
                                child: Text('${e.key + 1}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary)),
                              ),
                              title: Text(a['title'] ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                            subtitle: Text(
                                              '$branch • ${_formatDate(createdAt)}'),
                                              trailing: Row(mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              const Icon(Icons.visibility_rounded,
                                                                         size: 14, color: sageGreen),
                                                            const SizedBox(width: 4),
                                                            Text('$reads',
                                                                 style: const TextStyle(
                                                                   fontWeight: FontWeight.bold,
                                                                   color: sageGreen)),
                                                            ]),
                            ),
                        );
                        }),

                        const SizedBox(height: 16),
                        const Text('Branch Distribution',
                                   style: TextStyle(
                                     fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _branchBars(all),
                        ]),
        );
      },
    );
  }

  Widget _branchBars(List<Map<String, dynamic>> all) {
    final branches = ['All', 'Hanamkonda', 'Warangal'];
    final colors   = [softBlue, sageGreen, tealAqua];

    return Card(
      elevation: 2,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: branches.asMap().entries.map((e) {
            final branch = e.value;
            final color  = colors[e.key];
            final count  = all.where((a) {
              final b = a['branch'] as String? ?? '';
            final tb = a['targetBranches'] as List? ?? [];
            return b == branch ||
            tb.contains(branch.toLowerCase()) ||
            (branch == 'All' &&
            (b == 'All' || tb.contains('all')));
            }).length;
            final pct = all.isEmpty ? 0.0 : count / all.length;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(branch,
                         style: TextStyle(
                           fontWeight: FontWeight.w600,
                           color: color)),
                      const Spacer(),
                      Text('$count',
                           style: TextStyle(
                             fontSize: 12,
                             color: Colors.grey.shade500)),
                  ]),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor:
                      color.withValues(alpha: 0.12),
                      valueColor:
                      AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                    ),
                  ),
                ]),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _stat(String v, String l) => Column(children: [
    Text(v,
         style: const TextStyle(
           color: Colors.white,
           fontWeight: FontWeight.bold,
           fontSize: 18)),
           Text(l,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 11)),
  ]);

  Widget _vDiv() => Container(
    width: 1, height: 36,
    color: Colors.white.withValues(alpha: 0.3));

  Widget _alertBanner(IconData icon, String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border:
        Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(text,
             style: TextStyle(
               color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  // ── Firestore Actions ────────────────────────────────────────────

  Future<void> _setActive(String id, bool active) async {
    try {
      await FirebaseFirestore.instance
      .collection('announcements')
      .doc(id)
      .update({'isActive': active});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(active
          ? 'Announcement restored'
          : 'Announcement archived'),
          backgroundColor: active ? sageGreen : warmYellow,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: coralRed));
      }
    }
  }

  Future<void> _confirmDelete(String id, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Announcement?'),
        content: Text(
          'Permanently delete "$title"? This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: coralRed),
                  child: const Text('Delete'),
              ),
          ],
      ),
    );
    if (confirm != true) return;
    try {
      await FirebaseFirestore.instance
      .collection('announcements')
      .doc(id)
      .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Deleted'),
          backgroundColor: Colors.grey,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: coralRed));
      }
    }
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
