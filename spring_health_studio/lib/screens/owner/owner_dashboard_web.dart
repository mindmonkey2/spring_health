import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../widgets/stat_card.dart';
import '../members/members_list_screen.dart';
import '../reports/reports_screen.dart';

class OwnerDashboardWeb extends StatefulWidget {
  const OwnerDashboardWeb({super.key});

  @override
  State<OwnerDashboardWeb> createState() => _OwnerDashboardWebState();
}

class _OwnerDashboardWebState extends State<OwnerDashboardWeb> {
  final _firestoreService = FirestoreService();
  String? _selectedBranch;
  Map<String, dynamic> _stats = {};
  Map<String, Map<String, dynamic>> _branchWiseStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      if (_selectedBranch == null) {
        final stats = await _firestoreService.getDashboardStats(null);
        final branchStats = await _firestoreService.getBranchWiseStats();
        final monthlyRevenue = await _firestoreService.getMonthlyRevenue(null);

        // ✅ Updated: Get monthly revenue data including discount
        stats['monthlyRevenue'] = monthlyRevenue['total'];
        stats['monthlyCash'] = monthlyRevenue['cash'];
        stats['monthlyUpi'] = monthlyRevenue['upi'];
        stats['totalDiscount'] = monthlyRevenue['discount']; // ✅ Add monthly discount

        setState(() {
          _stats = stats;
          _branchWiseStats = branchStats;
        });
      } else {
        final stats = await _firestoreService.getDashboardStats(_selectedBranch);
        final monthlyRevenue = await _firestoreService.getMonthlyRevenue(_selectedBranch);

        // ✅ Updated: Get monthly revenue data including discount
        stats['monthlyRevenue'] = monthlyRevenue['total'];
        stats['monthlyCash'] = monthlyRevenue['cash'];
        stats['monthlyUpi'] = monthlyRevenue['upi'];
        stats['totalDiscount'] = monthlyRevenue['discount']; // ✅ Add monthly discount

        setState(() {
          _stats = stats;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
      ? const Center(child: CircularProgressIndicator())
      : Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.grey[100],
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildSidebarItem(Icons.dashboard, 'Dashboard', true),
                _buildSidebarItem(Icons.people, 'Members', false, onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MembersListScreen(branch: _selectedBranch),
                    ),
                  );
                }),
                _buildSidebarItem(Icons.analytics, 'Reports', false, onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportsScreen(branch: _selectedBranch),
                    ),
                  );
                }),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'BRANCHES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                _buildBranchItem('All Branches', null),
                _buildBranchItem('Hanamkonda', 'Hanamkonda'),
                _buildBranchItem('Warangal', 'Warangal'),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedBranch == null
                    ? 'All Branches (Combined)'
                  : '$_selectedBranch Branch',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  ),
                  const SizedBox(height: 24),

                  // Stats Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      StatCard(
                        title: 'Total Members',
                        value: '${_stats['totalMembers'] ?? 0}',
                        icon: Icons.people,
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MembersListScreen(branch: _selectedBranch),
                            ),
                          );
                        },
                      ),
                      StatCard(
                        title: 'Active Members',
                        value: '${_stats['activeMembers'] ?? 0}',
                        icon: Icons.verified_user,
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MembersListScreen(
                                branch: _selectedBranch,
                                initialFilter: 'Active',
                              ),
                            ),
                          );
                        },
                      ),
                      StatCard(
                        title: 'Near Expiry',
                        value: '${_stats['nearExpiry'] ?? 0}',
                        icon: Icons.warning,
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MembersListScreen(
                                branch: _selectedBranch,
                                initialFilter: 'Near Expiry',
                              ),
                            ),
                          );
                        },
                      ),
                      StatCard(
                        title: 'Pending Dues',
                        value: 'Rs.${(_stats['totalDues'] ?? 0).toStringAsFixed(0)}',
                        icon: Icons.account_balance_wallet,
                        color: Colors.red,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MembersListScreen(
                                branch: _selectedBranch,
                                initialFilter: 'Pending Dues',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Revenue Card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.currency_rupee, color: Colors.white, size: 32),
                              SizedBox(width: 12),
                              Text(
                                'Revenue Summary',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_getMonthName(DateTime.now().month)} ${DateTime.now().year}', // ✅ Dynamic month
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Rs.${(_stats['monthlyRevenue'] ?? 0).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Divider(color: Colors.white24),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Cash',
                                      style: TextStyle(color: Colors.white70, fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rs.${(_stats['monthlyCash'] ?? 0).toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'UPI',
                                      style: TextStyle(color: Colors.white70, fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rs.${(_stats['monthlyUpi'] ?? 0).toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Discount', // ✅ Changed from "Total Discount"
                                      style: TextStyle(color: Colors.white70, fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rs. ${(_stats['totalDiscount'] ?? 0).toStringAsFixed(0)}', // ✅ Now shows monthly discount
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_selectedBranch == null) ...[
                    const SizedBox(height: 32),
                    const Text(
                      'Branch-wise Statistics',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._branchWiseStats.entries.map((entry) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withAlpha(25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.location_on, color: Colors.blue, size: 32),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Members: ${entry.value['totalMembers']} | Revenue: Rs.${(entry.value['totalRevenue'] ?? 0).toStringAsFixed(0)}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, bool isActive, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: isActive ? const Color(0xFF6366F1) : Colors.grey[600]),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? const Color(0xFF6366F1) : Colors.grey[800],
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isActive ? const Color(0xFF6366F1).withAlpha(25) : null,
      onTap: onTap,
    );
  }

  Widget _buildBranchItem(String title, String? branch) {
    final isSelected = _selectedBranch == branch;
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF6366F1) : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      tileColor: isSelected ? const Color(0xFF6366F1).withAlpha(25) : null,
      onTap: () {
        setState(() {
          _selectedBranch = branch;
        });
        _loadData();
      },
    );
  }

  // ✅ Added helper method for dynamic month name
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
