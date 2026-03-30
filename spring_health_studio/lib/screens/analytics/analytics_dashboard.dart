import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/firestore_service.dart';

class AnalyticsDashboard extends StatefulWidget {
  final String? branch;

  const AnalyticsDashboard({super.key, this.branch});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  final _firestoreService = FirestoreService();
  String _selectedPeriod = 'This Month';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  // Colors
  static const Color sageGreen = Color(0xFF10B981);
  static const Color tealAqua = Color(0xFF14B8A6);
  static const Color warmYellow = Color(0xFFFCD34D);
  static const Color softCoral = Color(0xFFF87171);
  static const Color navyBlue = Color(0xFF1E3A8A);

  @override
  void initState() {
    super.initState();
    _setPeriod('This Month');
  }

  void _setPeriod(String period) {
    final today = DateTime.now();
    setState(() {
      _selectedPeriod = period;
      switch (period) {
        case 'Today':
          _startDate = DateTime(today.year, today.month, today.day, 0, 0, 0);
          _endDate = DateTime(today.year, today.month, today.day, 23, 59, 59);
          break;
        case 'This Week':
          final weekday = today.weekday;
          _startDate = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: weekday - 1));
          _endDate = DateTime(today.year, today.month, today.day, 23, 59, 59);
          break;
        case 'This Month':
          _startDate = DateTime(today.year, today.month, 1);
          _endDate = DateTime(today.year, today.month, today.day, 23, 59, 59);
          break;
        case 'Last Month':
          final lastMonth = DateTime(today.year, today.month - 1, 1);
          _startDate = lastMonth;
          _endDate = DateTime(today.year, today.month, 0, 23, 59, 59);
          break;
        case 'Last 3 Months':
          _startDate = DateTime(today.year, today.month - 3, 1);
          _endDate = DateTime(today.year, today.month, today.day, 23, 59, 59);
          break;
        case 'This Year':
          _startDate = DateTime(today.year, 1, 1);
          _endDate = DateTime(today.year, today.month, today.day, 23, 59, 59);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.branch != null
        ? 'Analytics - ${widget.branch}'
        : 'Analytics Dashboard'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [sageGreen, tealAqua],
            ),
          ),
        ),
        foregroundColor: Colors.white,
          elevation: 0,
      ),
      body: Column(
        children: [
          // Period Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.date_range, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Time Period',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'Today',
                      'This Week',
                      'This Month',
                      'Last Month',
                      'Last 3 Months',
                      'This Year',
                    ].map((period) {
                      final isSelected = _selectedPeriod == period;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(period),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) _setPeriod(period);
                          },
                          selectedColor: sageGreen.withValues(alpha: 0.2),
                          checkmarkColor: sageGreen,
                          backgroundColor: Colors.grey[100],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Analytics Content
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              key: ValueKey('$_selectedPeriod-${widget.branch}'),
              future: _loadAnalytics(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: softCoral),
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

                final data = snapshot.data ?? {};

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Profit/Loss Summary
                      _buildProfitLossCard(data['profitLoss'] ?? {}),

                      const SizedBox(height: 16),

                      // Revenue & Expenses Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              'Revenue',
                              'Rs.${(data['profitLoss']?['revenue'] ?? 0).toStringAsFixed(0)}',
                              Icons.trending_up,
                              sageGreen,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildMetricCard(
                              'Expenses',
                              'Rs.${(data['profitLoss']?['expenses'] ?? 0).toStringAsFixed(0)}',
                              Icons.trending_down,
                              softCoral,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Member Stats
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              'Total Members',
                              '${data['totalMembers'] ?? 0}',
                              Icons.people,
                              tealAqua,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildMetricCard(
                              'Active Members',
                              '${data['activeMembers'] ?? 0}',
                              Icons.verified_user,
                              sageGreen,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Daily Revenue Chart
                      _buildDailyRevenueChart(data['dailyRevenue'] ?? {}),

                      const SizedBox(height: 24),

                      // Member Growth Chart
                      _buildMemberGrowthChart(data['memberGrowth'] ?? {}),

                      const SizedBox(height: 24),

                      // Expense Breakdown
                      _buildExpenseBreakdown(data['expensesByCategory'] ?? {}),

                      const SizedBox(height: 24),

                      // Revenue vs Expenses Comparison
                      _buildRevenueVsExpensesChart(
                        data['profitLoss']?['revenue'] ?? 0,
                        data['profitLoss']?['expenses'] ?? 0,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _loadAnalytics() async {
    try {
      final profitLoss = await _firestoreService.getProfitLoss(
        widget.branch,
        _startDate,
        _endDate,
      );

      final expensesByCategory = await _firestoreService.getExpensesByCategory(
        widget.branch,
        _startDate,
        _endDate,
      );

      final dailyRevenue = await _firestoreService.getDailyRevenue(
        widget.branch,
        _startDate,
        _endDate,
      );

      final memberGrowth = await _firestoreService.getMemberGrowth(
        widget.branch,
        _startDate,
        _endDate,
      );

      final stats = await _firestoreService.getStatistics(widget.branch);

      return {
        'profitLoss': profitLoss,
        'expensesByCategory': expensesByCategory,
        'dailyRevenue': dailyRevenue,
        'memberGrowth': memberGrowth,
        'totalMembers': stats['totalMembers'],
        'activeMembers': stats['activeMembers'],
      };
    } catch (e) {
      debugPrint('Error loading analytics: $e');
      rethrow;
    }
  }

  Widget _buildProfitLossCard(Map<String, dynamic> data) {
    final profit = data['profit'] ?? 0;
    final profitMargin = data['profitMargin'] ?? 0;
    final isProfit = profit >= 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isProfit
          ? [sageGreen, tealAqua]
          : [softCoral, Colors.deepOrange],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isProfit ? sageGreen : softCoral).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Net Profit/Loss',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                isProfit ? Icons.trending_up : Icons.trending_down,
                color: Colors.white,
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Rs.${profit.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${isProfit ? '+' : ''}${profitMargin.toStringAsFixed(1)}% Margin',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRevenueChart(Map<String, double> dailyRevenue) {
    if (dailyRevenue.isEmpty) {
      return _buildEmptyChart('No revenue data', Icons.attach_money);
    }

    // Sort by date and limit to show recent data
    final sortedEntries = dailyRevenue.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

    // Take last 30 days max for better visualization
    final displayEntries = sortedEntries.length > 30
    ? sortedEntries.sublist(sortedEntries.length - 30)
    : sortedEntries;

    final spots = <FlSpot>[];
    for (var i = 0; i < displayEntries.length; i++) {
      spots.add(FlSpot(i.toDouble(), displayEntries[i].value));
    }

    final maxY = displayEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.show_chart, color: sageGreen, size: 24),
                SizedBox(width: 12),
                Text(
                  'Daily Revenue Trend',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            'Rs.${(value / 1000).toStringAsFixed(0)}k',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: displayEntries.length > 10
                        ? (displayEntries.length / 5).ceilToDouble()
                        : 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= displayEntries.length) {
                            return const Text('');
                          }
                          final date = DateTime.parse(displayEntries[value.toInt()].key);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${date.day}/${date.month}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: sageGreen,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: displayEntries.length <= 10,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: sageGreen,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            sageGreen.withValues(alpha: 0.3),
                            sageGreen.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  minY: 0,
                  maxY: maxY * 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildMemberGrowthChart(Map<String, int> memberGrowth) {
    if (memberGrowth.isEmpty) {
      return _buildEmptyChart('No member growth data', Icons.people);
    }

    // Sort by date
    final sortedEntries = memberGrowth.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

    // Calculate cumulative growth
    var cumulative = 0;
    final cumulativeData = <MapEntry<String, int>>[];
    for (var entry in sortedEntries) {
      cumulative += entry.value;
      cumulativeData.add(MapEntry(entry.key, cumulative));
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < cumulativeData.length; i++) {
      spots.add(FlSpot(i.toDouble(), cumulativeData[i].value.toDouble()));
    }

    final maxY = cumulativeData.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.trending_up, color: tealAqua, size: 24),
                SizedBox(width: 12),
                Text(
                  'Member Growth',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: cumulativeData.length > 10
                        ? (cumulativeData.length / 5).ceilToDouble()
                        : 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= cumulativeData.length) {
                            return const Text('');
                          }
                          final date = DateTime.parse(cumulativeData[value.toInt()].key);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${date.day}/${date.month}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: tealAqua,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: cumulativeData.length <= 10,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: tealAqua,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            tealAqua.withValues(alpha: 0.3),
                            tealAqua.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  minY: 0,
                  maxY: maxY * 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseBreakdown(Map<String, double> expensesByCategory) {
    if (expensesByCategory.isEmpty) {
      return _buildEmptyChart('No expenses recorded', Icons.receipt_long);
    }

    final total = expensesByCategory.values.fold(0.0, (sum, val) => sum + val);
    final sortedCategories = expensesByCategory.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

    // Take top 5 categories
    final topCategories = sortedCategories.take(5).toList();

    // Create pie chart sections
    final sections = <PieChartSectionData>[];
    final colors = [sageGreen, tealAqua, warmYellow, softCoral, navyBlue];

    for (var i = 0; i < topCategories.length; i++) {
      final entry = topCategories[i];
      final percentage = (entry.value / total) * 100;

      sections.add(
        PieChartSectionData(
          value: entry.value,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          color: colors[i % colors.length],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.pie_chart, color: tealAqua, size: 24),
                SizedBox(width: 12),
                Text(
                  'Expense Breakdown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Pie Chart
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Legend
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: topCategories.asMap().entries.map((item) {
                      final index = item.key;
                      final entry = item.value;
                      final percentage = (entry.value / total) * 100;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Rs.${entry.value.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueVsExpensesChart(double revenue, double expenses) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bar_chart, color: navyBlue, size: 24),
                SizedBox(width: 12),
                Text(
                  'Revenue vs Expenses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (revenue > expenses ? revenue : expenses) * 1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          'Rs.${rod.toY.toStringAsFixed(0)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Revenue', style: TextStyle(fontWeight: FontWeight.bold));
                            case 1:
                              return const Text('Expenses', style: TextStyle(fontWeight: FontWeight.bold));
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            'Rs.${(value / 1000).toStringAsFixed(0)}k',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: revenue,
                          color: sageGreen,
                          width: 40,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: expenses,
                          color: softCoral,
                          width: 40,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart(String message, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
