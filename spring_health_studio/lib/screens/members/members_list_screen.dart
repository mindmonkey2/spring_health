import 'package:flutter/material.dart';

import '../../models/member_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/date_utils.dart' as app_date_utils;
import '../../theme/app_colors.dart';
import 'member_detail_screen.dart';
import 'add_member_screen.dart';

class MembersListScreen extends StatefulWidget {
  final String? branch;
  final String? initialFilter;

  const MembersListScreen({
    super.key,
    this.branch,
    this.initialFilter,
  });

  @override
  State<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends State<MembersListScreen> {
  final _firestoreService = FirestoreService();
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialFilter != null) {
      _selectedFilter = widget.initialFilter!;
    }

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isCurrentlyActive(MemberModel member) {
    return DateTime.now().isBefore(member.expiryDate);
  }

  List<MemberModel> _filterMembers(List<MemberModel> members) {
    // Apply filter
    List<MemberModel> filtered = members;

    switch (_selectedFilter) {
      case 'Active':
        filtered = members.where((m) => _isCurrentlyActive(m)).toList();
        break;
      case 'Expired':
        filtered = members.where((m) => !_isCurrentlyActive(m)).toList();
        break;
      case 'Near Expiry':
        filtered = members.where((m) {
          final daysLeft = m.expiryDate.difference(DateTime.now()).inDays;
          return daysLeft >= 0 && daysLeft <= 7 && _isCurrentlyActive(m);
        }).toList();
        break;
      case 'Pending Dues':
        filtered = members.where((m) => m.dueAmount > 0).toList();
        break;
      case 'Archived':
        filtered = members.where((m) => m.isArchived).toList();
        break;
      default:
        filtered = members;
    }

    // Apply search with improved name matching
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((member) {
        // For phone, email, ID - exact contains (unchanged)
        if (member.phone.contains(_searchQuery) ||
          member.email.toLowerCase().contains(_searchQuery) ||
          member.id.toLowerCase().contains(_searchQuery)) {
          return true;
          }

          // For name - word boundary search (improved)
          // Split name into words and check if any word starts with search query
          final nameWords = member.name.toLowerCase().split(' ');
        return nameWords.any((word) => word.startsWith(_searchQuery));
      }).toList();
    }

    return filtered;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Members'),
            if (widget.branch != null)
              Text(
                '${widget.branch} Branch',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        // ✅ Updated gradient
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.success, AppColors.turquoise],
            ),
          ),
        ),
        foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export feature coming soon!')),
                );
              },
            ),
          ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, phone, email, or ID',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
                : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Filter Chips - ✅ Updated colors
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'All',
                  'Active',
                  'Expired',
                  'Near Expiry',
                  'Pending Dues',
                  'Archived',
                ].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        }
                      },
                      selectedColor: AppColors.success.withValues(alpha: 0.2), // ✅ Updated
                      checkmarkColor: AppColors.success, // ✅ Updated
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Members List
          Expanded(
            child: StreamBuilder<List<MemberModel>>(
              stream: _selectedFilter == 'Archived'  // ✅ NEW: Conditional stream
            ? _firestoreService.getArchivedMembers(branch: widget.branch)
            : _firestoreService.getMembers(branch: widget.branch),
            builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No members found',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first member to get started',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                final allMembers = snapshot.data!;
                final filteredMembers = _filterMembers(allMembers);

                if (filteredMembers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No members match your search',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try different keywords or filters',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Count Banner - ✅ Updated color
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: AppColors.success.withValues(alpha: 0.1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total: ${filteredMembers.length} ${filteredMembers.length == 1 ? 'member' : 'members'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (_selectedFilter != 'All' || _searchQuery.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedFilter = 'All';
                                _searchController.clear();
                                });
                              },
                              child: const Text('Clear filters'),
                            ),
                        ],
                      ),
                    ),

                    // Members ListView
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          setState(() {});
                        },
                        color: AppColors.success, // ✅ Updated
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredMembers.length,
                          itemBuilder: (context, index) {
                            final member = filteredMembers[index];
                            final isActive = _isCurrentlyActive(member);
                            final daysLeft = member.expiryDate.difference(DateTime.now()).inDays;
                            final isExpiringSoon = daysLeft >= 0 && daysLeft <= 7 && isActive;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MemberDetailScreen(member: member),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Avatar - ✅ Updated colors
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: isActive
                                        ? AppColors.success.withValues(alpha: 0.2)
                                        : AppColors.error.withValues(alpha: 0.2),
                                        child: Text(
                                          member.name.substring(0, 1).toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: isActive ? AppColors.success : AppColors.error,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      // Member Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    member.name,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (isExpiringSoon)
                                                  Container(
                                                    margin: const EdgeInsets.only(left: 8),
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.warning, // ✅ Updated
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: const Text(
                                                      'EXPIRING',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 9,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${member.category} • ${member.plan}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.phone, size: 12, color: Colors.grey[500]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  member.phone,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  size: 12,
                                                  color: isActive ? AppColors.success : AppColors.error, // ✅ Updated
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Expiry: ${app_date_utils.DateUtils.formatDate(member.expiryDate)}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isActive ? AppColors.success : AppColors.error, // ✅ Updated
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (member.dueAmount > 0) ...[
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.warning, size: 12, color: Colors.red),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Due: ₹${member.dueAmount.toStringAsFixed(0)}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.red,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),

                                      // Status Badge - ✅ Updated colors
                                      Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isActive
                                              ? AppColors.success.withValues(alpha: 0.2)
                                              : AppColors.error.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              isActive ? 'Active' : 'Expired',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: isActive ? AppColors.success : AppColors.error,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      // ✅ Updated FAB color
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddMemberScreen(branch: widget.branch),
            ),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Member'),
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
      ),
    );
  }
}
