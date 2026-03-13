import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/attendance_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/date_utils.dart' as app_date_utils;

class AttendanceHistoryScreen extends StatefulWidget {
  final String? branch;

  const AttendanceHistoryScreen({super.key, this.branch});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final _firestoreService = FirestoreService();
  final _searchController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _searchQuery = '';

  // Colors
  static const Color sageGreen = Color(0xFF10B981);
  static const Color tealAqua = Color(0xFF14B8A6);
  //static const Color warmYellow = Color(0xFFFCD34D);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: sageGreen,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Attendance History'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
            ),
          ),
        ),
        foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            // Today button
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedDate = DateTime.now();
                });
              },
              icon: const Icon(Icons.today, color: Colors.white, size: 20),
              label: const Text(
                'Today',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
      ),
      body: Column(
        children: [
          // Date Selector & Search
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Date Picker
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [sageGreen.withValues(alpha: 0.1), tealAqua.withValues(alpha: 0.1)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: sageGreen.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: sageGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Selected Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  app_date_utils.DateUtils.formatDate(_selectedDate),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_drop_down, color: sageGreen),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by member name or ID...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                    : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: widget.branch != null
            ? _buildBranchAttendance()
            : _buildAllAttendance(),
          ),
        ],
      ),
    );
  }

  // ✅ ENHANCED: Branch Attendance with Stats
  Widget _buildBranchAttendance() {
    return StreamBuilder<List<AttendanceModel>>(
      stream: _firestoreService.getAttendanceByBranch(widget.branch!, _selectedDate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final allAttendance = snapshot.data!;

        // Apply search filter
        final filteredAttendance = _searchQuery.isEmpty
        ? allAttendance
        : allAttendance.where((record) {
          return record.memberName.toLowerCase().contains(_searchQuery) ||
          record.memberId.toLowerCase().contains(_searchQuery);
        }).toList();

        return Column(
          children: [
            // Statistics Card
            _buildStatsCard(filteredAttendance, allAttendance.length),

            // List
            Expanded(
              child: filteredAttendance.isEmpty
              ? _buildNoSearchResults()
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredAttendance.length,
                itemBuilder: (context, index) {
                  final record = filteredAttendance[index];
                  return _buildAttendanceCard(record, index);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ✅ NEW: All Branches Attendance (Owner View)
  Widget _buildAllAttendance() {
    final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final endOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);

    return StreamBuilder<List<AttendanceModel>>(
      stream: _firestoreService.getAttendanceForDateRange(null, startOfDay, endOfDay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final allAttendance = snapshot.data!;

        // Apply search filter
        final filteredAttendance = _searchQuery.isEmpty
        ? allAttendance
        : allAttendance.where((record) {
          return record.memberName.toLowerCase().contains(_searchQuery) ||
          record.memberId.toLowerCase().contains(_searchQuery);
        }).toList();

        // Group by branch
        final Map<String, List<AttendanceModel>> branchGroups = {};
        for (var record in filteredAttendance) {
          branchGroups.putIfAbsent(record.branch, () => []).add(record);
        }

        return Column(
          children: [
            // Overall Stats
            _buildStatsCard(filteredAttendance, allAttendance.length),

            // Branch-wise List
            Expanded(
              child: filteredAttendance.isEmpty
              ? _buildNoSearchResults()
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: branchGroups.length,
                itemBuilder: (context, branchIndex) {
                  final branch = branchGroups.keys.elementAt(branchIndex);
                  final records = branchGroups[branch]!;

                  return _buildBranchSection(branch, records);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ✅ NEW: Statistics Card
  Widget _buildStatsCard(List<AttendanceModel> filtered, int total) {
    final peakHour = _getPeakHour(filtered);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [sageGreen, tealAqua],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: sageGreen.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s Check-ins',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _selectedDate.day == DateTime.now().day &&
                  _selectedDate.month == DateTime.now().month &&
                  _selectedDate.year == DateTime.now().year
                  ? 'LIVE'
                : 'HISTORY',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', total.toString(), Icons.people),
              Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
              _buildStatItem('Showing', filtered.length.toString(), Icons.filter_list),
              if (peakHour != null) ...[
                Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
                _buildStatItem('Peak', peakHour, Icons.trending_up),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ✅ NEW: Enhanced Attendance Card
  Widget _buildAttendanceCard(AttendanceModel record, int index) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: sageGreen.withValues(alpha: 0.2)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [sageGreen.withValues(alpha: 0.2), tealAqua.withValues(alpha: 0.2)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                record.memberName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: sageGreen,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          title: Text(
            record.memberName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.badge, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    record.memberId,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('hh:mm a').format(record.checkInTime),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: sageGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: sageGreen.withValues(alpha: 0.3)),
            ),
            child: Text(
              record.branch,
              style: const TextStyle(
                fontSize: 12,
                color: sageGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ NEW: Branch Section for Owner View
  Widget _buildBranchSection(String branch, List<AttendanceModel> records) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branch Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [sageGreen.withValues(alpha: 0.1), tealAqua.withValues(alpha: 0.1)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: sageGreen, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      branch,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: sageGreen,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: sageGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${records.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Records
          ...records.asMap().entries.map((entry) {
            return _buildAttendanceCard(entry.value, entry.key);
          }),
        ],
      ),
    );
  }

  // ✅ NEW: Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Check-ins Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No attendance records for this date',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NEW: No Search Results
  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NEW: Calculate Peak Hour
  String? _getPeakHour(List<AttendanceModel> attendance) {
    if (attendance.isEmpty) return null;

    final Map<int, int> hourCounts = {};
    for (var record in attendance) {
      final hour = record.checkInTime.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    if (hourCounts.isEmpty) return null;

    final peakHour = hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    return '${peakHour.toString().padLeft(2, '0')}:00';
  }
}
