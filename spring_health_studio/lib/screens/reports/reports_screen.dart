// lib/screens/reports/reports_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../services/firestore_service.dart';
import '../../../../models/member_model.dart';
import '../../../../models/payment_model.dart';
import '../../../../models/attendance_model.dart';
import '../../../../utils/date_utils.dart' as appdateutils;


class ReportsScreen extends StatefulWidget {
  final String? branch;
  final String? initialReportType;
  final String? initialDateRange;

  const ReportsScreen({
    super.key,
    this.branch,
    this.initialReportType,
    this.initialDateRange,
  });

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final firestoreService = FirestoreService();

  String selectedReportType = 'Members';
  String selectedDateRange = 'Today';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  bool isGenerating = false;
  bool isExportingCsv = false;

  Map<String, dynamic> revenueData = {};
  List<MemberModel> filteredMembers = [];
  List<PaymentModel> payments = [];
  List<AttendanceModel> attendance = [];

  // Wellness & Balance Color Palette
  static const Color sageGreen = Color(0xFF10B981);
  static const Color tealAqua = Color(0xFF14B8A6);
  static const Color warmYellow = Color(0xFFFCD34D);
  static const Color softCoral = Color(0xFFF87171);

  @override
  void initState() {
    super.initState();
    if (widget.initialReportType != null) {
      selectedReportType = widget.initialReportType!;
    }
    if (widget.initialDateRange != null) {
      selectedDateRange = widget.initialDateRange!;
      setDateRange(widget.initialDateRange!);
    } else {
      setDateRange('Today');
    }
    loadData();
  }

  void setDateRange(String range) {
    final today = DateTime.now();
    setState(() {
      selectedDateRange = range;
      switch (range) {
        case 'Today':
          startDate = DateTime(today.year, today.month, today.day, 0, 0, 0);
          endDate = DateTime(today.year, today.month, today.day, 23, 59, 59);
        case 'Yesterday':
          final yesterday = today.subtract(const Duration(days: 1));
          startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
          endDate =
              DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
        case 'Last 7 Days':
          startDate = DateTime(today.year, today.month, today.day)
              .subtract(const Duration(days: 6));
          endDate =
              DateTime(today.year, today.month, today.day, 23, 59, 59);
        case 'This Week':
          final weekday = today.weekday;
          startDate = DateTime(today.year, today.month, today.day)
              .subtract(Duration(days: weekday - 1));
          endDate =
              DateTime(today.year, today.month, today.day, 23, 59, 59);
        case 'Last 30 Days':
          startDate = DateTime(today.year, today.month, today.day)
              .subtract(const Duration(days: 29));
          endDate =
              DateTime(today.year, today.month, today.day, 23, 59, 59);
        case 'This Month':
          startDate = DateTime(today.year, today.month, 1);
          endDate =
              DateTime(today.year, today.month, today.day, 23, 59, 59);
        case 'Last Month':
          final lastMonth = DateTime(today.year, today.month - 1, 1);
          startDate = lastMonth;
          endDate = DateTime(today.year, today.month, 0, 23, 59, 59);
      }
    });
    loadData();
  }

  Future<void> selectCustomDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: sageGreen,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        selectedDateRange = 'Custom';
        startDate =
            DateTime(picked.start.year, picked.start.month, picked.start.day);
        endDate = DateTime(
            picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
      });
      loadData();
    }
  }

  // ── Data Loading ─────────────────────────────────────────────────
  Future<void> loadData() async {
    if (selectedReportType == 'Revenue') {
      loadRevenueData();
    } else if (selectedReportType == 'Attendance') {
      loadAttendanceData();
    } else if (selectedReportType == 'Payments') {
      loadPaymentsData();
    } else {
      loadMembersData();
    }
  }

  Future<void> loadRevenueData() async {
    final revenue = await firestoreService.getRevenueForDateRange(
        widget.branch, startDate, endDate);
    if (mounted) setState(() => revenueData = revenue);
  }

  void loadAttendanceData() {
    firestoreService
        .getAttendanceForDateRange(widget.branch, startDate, endDate)
        .listen((a) {
      if (mounted) setState(() => attendance = a);
    });
  }

  void loadPaymentsData() {
    firestoreService
        .getPaymentsForDateRange(widget.branch, startDate, endDate)
        .listen((p) {
      if (mounted) setState(() => payments = p);
    });
  }

  Future<void> loadMembersData() async {
    final allMembers = widget.branch != null
        ? await firestoreService.getMembersByBranch(widget.branch!).first
        : await firestoreService.getAllMembers().first;
    if (mounted) {
      setState(() => filteredMembers = filterMembersByType(allMembers));
    }
  }

  List<MemberModel> filterMembersByType(List<MemberModel> members) {
    final now = DateTime.now();
    switch (selectedReportType) {
      case 'Active Members':
        return members.where((m) => now.isBefore(m.expiryDate)).toList();
      case 'Expired Members':
        return members.where((m) => now.isAfter(m.expiryDate)).toList();
      case 'Near Expiry':
        return members.where((m) {
          final daysLeft = m.expiryDate.difference(now).inDays;
          return daysLeft >= 0 && daysLeft <= 7 && now.isBefore(m.expiryDate);
        }).toList();
      case 'Pending Dues':
        return members.where((m) => m.dueAmount > 0).toList();
      default:
        return members;
    }
  }

  String getReportTitle() {
    if (selectedReportType == 'Revenue' ||
        selectedReportType == 'Payments' ||
        selectedReportType == 'Attendance') {
      return '$selectedReportType Report · $selectedDateRange';
    }
    return '$selectedReportType Report';
  }

  // ── CSV Export ───────────────────────────────────────────────────
  Future<void> exportCsv() async {
    setState(() => isExportingCsv = true);
    try {
      final rows = _buildCsvRows();
      final csvString = csv.encoder.convert(rows);
      final dir = await getTemporaryDirectory();
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          '${selectedReportType.replaceAll(' ', '_')}_Report_$stamp.csv';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(csvString);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject:
            'Spring Health · $selectedReportType Report · $selectedDateRange',
        text:
            'Exported on ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('CSV exported successfully!'),
          backgroundColor: sageGreen,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('CSV export failed: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => isExportingCsv = false);
    }
  }

  List<List<dynamic>> _buildCsvRows() {
    switch (selectedReportType) {
      case 'Revenue':
        return [
          ['Spring Health Studio — Revenue Report'],
          ['Period', selectedDateRange],
          ['Branch', widget.branch ?? 'All Branches'],
          ['Generated', DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())],
          [''],
          ['Metric', 'Amount (Rs.)'],
          ['Total Revenue', (revenueData['total'] ?? 0).toStringAsFixed(2)],
          ['Cash', (revenueData['cash'] ?? 0).toStringAsFixed(2)],
          ['UPI', (revenueData['upi'] ?? 0).toStringAsFixed(2)],
          ['Online', (revenueData['online'] ?? 0).toStringAsFixed(2)],
          ['Mixed', (revenueData['mixed'] ?? 0).toStringAsFixed(2)],
          ['Discounts Given', (revenueData['discount'] ?? 0).toStringAsFixed(2)],
          [''],
          ['Total Transactions', payments.length.toString()],
        ];

      case 'Payments':
        final rows = <List<dynamic>>[
          ['Spring Health Studio — Payments Report'],
          ['Period', selectedDateRange],
          ['Branch', widget.branch ?? 'All Branches'],
          ['Generated', DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())],
          [''],
          ['Member Name', 'Phone', 'Amount (Rs.)', 'Mode', 'Type', 'Cash', 'UPI', 'Date'],
        ];
        for (final p in payments) {
          rows.add([
            p.memberName,
            '',
            p.amount.toStringAsFixed(2),
            p.paymentMode,
            p.type,
            p.cashAmount.toStringAsFixed(2),
            p.upiAmount.toStringAsFixed(2),
            DateFormat('dd/MM/yyyy').format(p.paymentDate),
          ]);
        }
        final total = payments.fold(0.0, (acc, p) => acc + p.amount);
        rows.addAll([
          [''],
          ['TOTAL', '', total.toStringAsFixed(2)],
        ]);
        return rows;


      case 'Attendance':
        final rows = <List<dynamic>>[
          ['Spring Health Studio — Attendance Report'],
          ['Period', selectedDateRange],
          ['Branch', widget.branch ?? 'All Branches'],
          ['Generated', DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())],
          [''],
          ['Member Name', 'Branch', 'Check-In Time'],
        ];
        for (final a in attendance) {
          rows.add([
            a.memberName,
            a.branch,
            DateFormat('dd/MM/yyyy hh:mm a').format(a.checkInTime),
          ]);
        }
        rows.addAll([[''], ['Total Check-ins', attendance.length.toString()]]);
        return rows;

      default:
        // All member-type reports
        final rows = <List<dynamic>>[
          ['Spring Health Studio — $selectedReportType Report'],
          ['Branch', widget.branch ?? 'All Branches'],
          ['Generated', DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())],
          [''],
          [
            'Name', 'Phone', 'Category', 'Plan', 'Branch',
            'Joining Date', 'Expiry Date', 'Status',
            'Final Amount', 'Due Amount', 'Payment Mode'
          ],
        ];
        for (final m in filteredMembers) {
          final isActive = DateTime.now().isBefore(m.expiryDate);
          rows.add([
            m.name,
            m.phone,
            m.category,
            m.plan,
            m.branch,
            DateFormat('dd/MM/yyyy').format(m.joiningDate),
            DateFormat('dd/MM/yyyy').format(m.expiryDate),
            isActive ? 'Active' : 'Expired',
            m.finalAmount.toStringAsFixed(2),
            m.dueAmount.toStringAsFixed(2),
            m.paymentMode,
          ]);
        }
        rows.addAll([[''], ['Total Records', filteredMembers.length.toString()]]);
        return rows;
    }
  }

  // ── Export choice bottom sheet ───────────────────────────────────
  void showExportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Export Report',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                selectedReportType,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              // PDF
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  generateAndShareReport();
                },
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: softCoral.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.picture_as_pdf,
                      color: softCoral, size: 24),
                ),
                title: const Text('Export as PDF',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Formatted report with Spring Health branding'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              ),
              const Divider(height: 1),
              // CSV
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  exportCsv();
                },
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: sageGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.table_chart,
                      color: sageGreen, size: 24),
                ),
                title: const Text('Export as CSV',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text(
                    'Spreadsheet-compatible · Excel, Google Sheets'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [sageGreen, tealAqua]),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [sageGreen, tealAqua],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.branch != null) ...[
                    Row(children: [
                      const Icon(Icons.location_on,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.branch} Branch',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ]),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    getReportTitle(),
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // Report Type Chips
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Report Type',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    buildReportTypeChip('Members', Icons.people, sageGreen),
                    buildReportTypeChip(
                        'Active Members', Icons.verified_user, sageGreen),
                    buildReportTypeChip(
                        'Expired Members', Icons.person_off, softCoral),
                    buildReportTypeChip(
                        'Near Expiry', Icons.warning, warmYellow),
                    buildReportTypeChip('Pending Dues',
                        Icons.account_balance_wallet, Colors.deepOrange),
                    buildReportTypeChip(
                        'Revenue', Icons.currency_rupee, tealAqua),
                    buildReportTypeChip('Payments', Icons.payment, tealAqua),
                    buildReportTypeChip(
                        'Attendance', Icons.check_circle, sageGreen),
                  ]),
                ),
              ],
            ),
          ),

          // Date Range (only for time-based reports)
          if (selectedReportType == 'Revenue' ||
              selectedReportType == 'Payments' ||
              selectedReportType == 'Attendance')
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Icon(Icons.date_range, size: 18, color: Colors.black87),
                    SizedBox(width: 8),
                    Text('Date Range',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                  ]),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        'Today',
                        'Yesterday',
                        'Last 7 Days',
                        'This Week',
                        'This Month',
                        'Last Month',
                        'Custom',
                      ].map((range) {
                        final isSelected = selectedDateRange == range;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(range),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                if (range == 'Custom') {
                                  selectCustomDateRange();
                                } else {
                                  setDateRange(range);
                                }
                              }
                            },
                            selectedColor: sageGreen.withValues(alpha: 0.2),
                            checkmarkColor: sageGreen,
                            backgroundColor: Colors.grey.shade100,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (selectedDateRange == 'Custom')
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: sageGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: sageGreen.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 14, color: sageGreen),
                            const SizedBox(width: 8),
                            Text(
                              '${DateFormat('MMM dd, yyyy').format(startDate)}'
                              ' – '
                              '${DateFormat('MMM dd, yyyy').format(endDate)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: sageGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

          const Divider(height: 1),
          Expanded(child: buildReportContent()),
        ],
      ),

      // ── Unified Export FAB ──────────────────────────────────────
      floatingActionButton: (isGenerating || isExportingCsv)
          ? FloatingActionButton.extended(
              onPressed: null,
              backgroundColor: Colors.grey,
              icon: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white)),
              ),
              label: Text(
                isExportingCsv ? 'Exporting CSV...' : 'Generating PDF...',
                style: const TextStyle(color: Colors.white),
              ),
            )
          : FloatingActionButton.extended(
              onPressed: showExportOptions,
              backgroundColor: sageGreen,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.ios_share),
              label: const Text('Export'),
            ),
    );
  }

  Widget buildReportTypeChip(
      String type, IconData icon, Color color) {
    final isSelected = selectedReportType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(icon,
            size: 16, color: isSelected ? color : Colors.grey.shade600),
        label: Text(type),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() => selectedReportType = type);
            loadData();
          }
        },
        selectedColor: color.withValues(alpha: 0.2),
        checkmarkColor: color,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight:
              isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        elevation: isSelected ? 2 : 0,
      ),
    );
  }

  // ── Report Content Router ────────────────────────────────────────
  Widget buildReportContent() {
    if (selectedReportType == 'Revenue') return buildRevenueReport();
    if (selectedReportType == 'Attendance') return buildAttendanceReport();
    if (selectedReportType == 'Payments') return buildPaymentsReport();
    return buildMembersReport();
  }

  // ── Revenue Report ───────────────────────────────────────────────
  Widget buildRevenueReport() {
    final total = (revenueData['total'] as double?) ?? 0;
    final cash = (revenueData['cash'] as double?) ?? 0;
    final upi = (revenueData['upi'] as double?) ?? 0;
    final online = (revenueData['online'] as double?) ?? 0;
    final mixed = (revenueData['mixed'] as double?) ?? 0;
    final discount = (revenueData['discount'] as double?) ?? 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Total Revenue Card
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [sageGreen, tealAqua],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.account_balance_wallet,
                      color: Colors.white, size: 32),
                  SizedBox(width: 12),
                  Text('Total Revenue',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ]),
                const SizedBox(height: 20),
                Text(
                  'Rs. ${NumberFormat('#,##,###.##').format(total)}',
                  style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white24, thickness: 1),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buildRevenueBreakdown(
                        'Cash', cash.toStringAsFixed(0), Icons.money),
                    Container(
                        width: 1, height: 60, color: Colors.white24),
                    buildRevenueBreakdown(
                        'UPI', upi.toStringAsFixed(0), Icons.qr_code_2),
                    Container(
                        width: 1, height: 60, color: Colors.white24),
                    buildRevenueBreakdown(
                        'Online', online.toStringAsFixed(0),
                        Icons.language),
                    Container(
                        width: 1, height: 60, color: Colors.white24),
                    buildRevenueBreakdown(
                        'Mixed', mixed.toStringAsFixed(0),
                        Icons.compare_arrows),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Discount Card
        if (discount > 0)
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: warmYellow.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.discount,
                    color: Color(0xFFF59E0B)),
              ),
              title: const Text('Total Discounts Given',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text(
                'Rs. ${discount.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: Color(0xFFF59E0B),
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ),
        const SizedBox(height: 16),

        // Period Info Card
        Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.info_outline,
                      size: 20, color: tealAqua),
                  const SizedBox(width: 8),
                  Text('Period: $selectedDateRange',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                ]),
                if (selectedDateRange == 'Custom') ...[
                  const SizedBox(height: 8),
                  Text(
                    '${DateFormat('MMM dd, yyyy').format(startDate)}'
                    ' to '
                    '${DateFormat('MMM dd, yyyy').format(endDate)}',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildRevenueBreakdown(
      String label, String amount, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(
                color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(amount,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ── Payments Report ──────────────────────────────────────────────
  Widget buildPaymentsReport() {
    // LINT FIX: renamed sum → acc in all folds
    final totalAmount =
        payments.fold(0.0, (acc, p) => acc + p.amount);
    final cashAmount =
        payments.fold(0.0, (acc, p) => acc + p.cashAmount);
    final upiAmount =
        payments.fold(0.0, (acc, p) => acc + p.upiAmount);
    final onlineAmount = payments
        .where((p) => p.paymentMode == 'online')
        .fold(0.0, (acc, p) => acc + p.amount);

    return Column(
      children: [
        // Summary Cards
        Container(
          padding: const EdgeInsets.all(16),
          color: sageGreen.withValues(alpha: 0.05),
          child: Column(
            children: [
              Row(children: [
                Expanded(
                    child: buildSummaryCard('Transactions',
                        '${payments.length}', Icons.receipt_long, tealAqua)),
                const SizedBox(width: 12),
                Expanded(
                    child: buildSummaryCard(
                        'Total Amount',
                        totalAmount.toStringAsFixed(0),
                        Icons.currency_rupee,
                        sageGreen)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: buildSummaryCard('Cash',
                        cashAmount.toStringAsFixed(0), Icons.money,
                        Colors.orange)),
                const SizedBox(width: 12),
                Expanded(
                    child: buildSummaryCard('UPI',
                        upiAmount.toStringAsFixed(0), Icons.qr_code,
                        tealAqua)),
                const SizedBox(width: 12),
                Expanded(
                    child: buildSummaryCard('Online',
                        onlineAmount.toStringAsFixed(0), Icons.language,
                        Colors.deepPurple)),
              ]),
            ],
          ),
        ),
        // Payment List
        Expanded(
          child: payments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payment_outlined,
                          size: 64,
                          color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No payments for selected range',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final payment = payments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              sageGreen.withValues(alpha: 0.2),
                          child: const Icon(Icons.currency_rupee,
                              color: sageGreen, size: 24),
                        ),
                        title: Text(payment.memberName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                                'Type: ${payment.type}  ·  Mode: ${payment.paymentMode}'),
                            Text(
                              appdateutils.DateUtils.formatDateTime(
                                  payment.paymentDate),
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600),
                            ),
                            if (payment.paymentMode == 'Mixed')
                              Text(
                                'Cash: ${payment.cashAmount.toStringAsFixed(0)}'
                                ' · UPI: ${payment.upiAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic),
                              ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Rs. ${payment.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: sageGreen),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: payment.type == 'initial'
                                    ? tealAqua.withValues(alpha: 0.2)
                                    : payment.type == 'due'
                                        ? warmYellow.withValues(alpha: 0.2)
                                        : Colors.purple
                                            .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                payment.type.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: payment.type == 'initial'
                                      ? tealAqua
                                      : payment.type == 'due'
                                          ? const Color(0xFFF59E0B)
                                          : Colors.purple.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ── Attendance Report ────────────────────────────────────────────
  Widget buildAttendanceReport() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [sageGreen, tealAqua]),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Check-ins',
                      style: TextStyle(
                          fontSize: 16, color: Colors.white70)),
                  SizedBox(height: 4),
                ],
              ),
              Row(children: [
                const Icon(Icons.check_circle,
                    color: Colors.white, size: 32),
                const SizedBox(width: 8),
                Text(
                  '${attendance.length}',
                  style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ]),
            ],
          ),
        ),
        Expanded(
          child: attendance.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No attendance records for selected range',
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: attendance.length,
                  itemBuilder: (context, index) {
                    final record = attendance[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              sageGreen.withValues(alpha: 0.2),
                          child: Text(
                            record.memberName
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: sageGreen),
                          ),
                        ),
                        title: Text(record.memberName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(appdateutils.DateUtils.formatDateTime(
                                record.checkInTime)),
                            Text(record.branch,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600)),
                          ],
                        ),
                        trailing: const Icon(Icons.check_circle,
                            color: sageGreen, size: 28),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ── Members Report ───────────────────────────────────────────────
  Widget buildMembersReport() {
    return Column(
      children: [
        // Header bar
        Container(
          padding: const EdgeInsets.all(16),
          color: sageGreen.withValues(alpha: 0.08),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.people, color: sageGreen),
                const SizedBox(width: 8),
                Text(
                  'Total Records: ${filteredMembers.length}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ]),
              if (widget.branch != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sageGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(widget.branch!,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12)),
                ),
            ],
          ),
        ),
        Expanded(
          child: filteredMembers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No members found for this report',
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredMembers.length,
                  itemBuilder: (context, index) {
                    final member = filteredMembers[index];
                    final isActive =
                        DateTime.now().isBefore(member.expiryDate);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: isActive
                              ? sageGreen.withValues(alpha: 0.2)
                              : Colors.red.withValues(alpha: 0.2),
                          child: Text(
                            member.name.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: isActive ? sageGreen : Colors.red),
                          ),
                        ),
                        title: Text(member.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('${member.category}  ·  ${member.plan}'),
                            Text(
                              'Expiry: ${appdateutils.DateUtils.formatDate(member.expiryDate)}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600),
                            ),
                            if (selectedReportType == 'Pending Dues' &&
                                member.dueAmount > 0)
                              Text(
                                'Due: Rs. ${member.dueAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                              ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isActive
                                ? sageGreen.withValues(alpha: 0.15)
                                : Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isActive ? 'Active' : 'Expired',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isActive ? sageGreen : Colors.red.shade700,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(title,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }

  // ── PDF Generation ───────────────────────────────────────────────
  Future<void> generateAndShareReport() async {
    setState(() => isGenerating = true);
    try {
      final pdf = pw.Document();
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: const pw.BoxDecoration(
                gradient: pw.LinearGradient(
                    colors: [PdfColors.green, PdfColors.teal]),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('SPRING HEALTH STUDIO',
                      style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  pw.Text('$selectedReportType Report',
                      style: const pw.TextStyle(
                          color: PdfColors.white, fontSize: 16)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            // Metadata
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                        'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}'),
                    if (widget.branch != null)
                      pw.Text('Branch: ${widget.branch}'),
                    if (selectedReportType == 'Revenue' ||
                        selectedReportType == 'Payments' ||
                        selectedReportType == 'Attendance')
                      pw.Text('Period: $selectedDateRange'),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 20),
            ..._buildPdfContent(),
          ],
        ),
      ));

      final pdfBytes = await pdf.save();
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename:
            '${selectedReportType.replaceAll(' ', '_')}_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('PDF generated successfully!'),
        backgroundColor: sageGreen,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => isGenerating = false);
    }
  }

  List<pw.Widget> _buildPdfContent() {
    if (selectedReportType == 'Revenue') {
      return [
        pw.Text(
            'Total Revenue: Rs. ${(revenueData['total'] ?? 0).toStringAsFixed(2)}',
            style: pw.TextStyle(
                fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Text(
            'Cash: Rs. ${(revenueData['cash'] ?? 0).toStringAsFixed(2)}'),
        pw.Text(
            'UPI: Rs. ${(revenueData['upi'] ?? 0).toStringAsFixed(2)}'),
        pw.Text(
            'Online: Rs. ${(revenueData['online'] ?? 0).toStringAsFixed(2)}'),
        pw.Text(
            'Mixed: Rs. ${(revenueData['mixed'] ?? 0).toStringAsFixed(2)}'),
        pw.Text(
            'Discounts: Rs. ${(revenueData['discount'] ?? 0).toStringAsFixed(2)}'),
      ];
    } else if (selectedReportType == 'Payments') {
      return [
        pw.Text('Total Payments: ${payments.length}',
            style: pw.TextStyle(
                fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              decoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                _pdfCell('Member', isHeader: true),
                _pdfCell('Amount', isHeader: true),
                _pdfCell('Mode', isHeader: true),
                _pdfCell('Type', isHeader: true),
                _pdfCell('Date', isHeader: true),
              ],
            ),
            ...payments.map((p) => pw.TableRow(children: [
                  _pdfCell(p.memberName),
                  _pdfCell('Rs. ${p.amount.toStringAsFixed(2)}'),
                  _pdfCell(p.paymentMode),
                  _pdfCell(p.type),
                  _pdfCell(DateFormat('dd/MM/yyyy').format(p.paymentDate)),
                ])),
          ],
        ),
      ];
    } else if (selectedReportType == 'Attendance') {
      return [
        pw.Text('Total Check-ins: ${attendance.length}',
            style: pw.TextStyle(
                fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              decoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                _pdfCell('Member', isHeader: true),
                _pdfCell('Check-in Time', isHeader: true),
                _pdfCell('Branch', isHeader: true),
              ],
            ),
            ...attendance.map((a) => pw.TableRow(children: [
                  _pdfCell(a.memberName),
                  _pdfCell(DateFormat('dd/MM/yyyy hh:mm a')
                      .format(a.checkInTime)),
                  _pdfCell(a.branch),
                ])),
          ],
        ),
      ];
    } else {
      // Members report — cap at 50 rows for PDF page limit
      return [
        pw.Text('Total Members: ${filteredMembers.length}',
            style: pw.TextStyle(
                fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              decoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                _pdfCell('Name', isHeader: true),
                _pdfCell('Phone', isHeader: true),
                _pdfCell('Category', isHeader: true),
                _pdfCell('Status', isHeader: true),
                _pdfCell('Expiry', isHeader: true),
              ],
            ),
            ...filteredMembers.take(50).map((m) {
              final isActive = DateTime.now().isBefore(m.expiryDate);
              return pw.TableRow(children: [
                _pdfCell(m.name),
                _pdfCell(m.phone),
                _pdfCell(m.category),
                _pdfCell(isActive ? 'Active' : 'Expired'),
                _pdfCell(DateFormat('dd/MM/yyyy').format(m.expiryDate)),
              ]);
            }),
          ],
        ),
        if (filteredMembers.length > 50)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 8),
            child: pw.Text(
              '* Showing first 50 of ${filteredMembers.length} records. Export CSV for full data.',
              style: const pw.TextStyle(
                  fontSize: 9, color: PdfColors.grey600),
            ),
          ),
      ];
    }
  }

  pw.Widget _pdfCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 9,
          fontWeight:
              isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
