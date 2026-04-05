import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/ai_plan_model.dart';

import '../../theme/app_colors.dart';

class MemberAiPlanScreen extends StatefulWidget {
  final String memberName;
  final String memberDocId;
  final String currentUserRole;

  const MemberAiPlanScreen({
    super.key,
    required this.memberName,
    required this.memberDocId,
    required this.currentUserRole,
  });

  @override
  State<MemberAiPlanScreen> createState() => _MemberAiPlanScreenState();
}

class _MemberAiPlanScreenState extends State<MemberAiPlanScreen> {
  String? _memberAuthUid;
  bool _loadingUid = true;
  String? _uidError;

  final _noteController = TextEditingController();
  bool _savingNote = false;

  @override
  void initState() {
    super.initState();
    _fetchMemberAuthUid();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _fetchMemberAuthUid() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('members')
          .doc(widget.memberDocId)
          .get();
      if (!doc.exists) {
        setState(() {
          _uidError = 'Member document not found.';
          _loadingUid = false;
        });
        return;
      }
      final data = doc.data()!;
      final uid =
          data['uid'] as String? ?? data['user_id'] as String?;
      if (uid == null || uid.isEmpty) {
        setState(() {
          _uidError = 'Member has not linked app account yet.';
          _loadingUid = false;
        });
        return;
      }
      setState(() {
        _memberAuthUid = uid;
        _loadingUid = false;
      });
    } catch (e) {
      setState(() {
        _uidError = 'Error fetching member: $e';
        _loadingUid = false;
      });
    }
  }

  Future<void> _saveNote() async {
    if (_savingNote || _memberAuthUid == null) return;
    setState(() => _savingNote = true);
    try {
      await FirebaseFirestore.instance
          .collection('aiPlans')
          .doc(_memberAuthUid)
          .collection('current')
          .doc('current')
          .update({
        'trainerNote': _noteController.text.trim(),
        'trainerNoteUpdatedAt': Timestamp.now(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note saved successfully'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save note: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _savingNote = false);
    }
  }

  bool get _canEdit =>
      widget.currentUserRole == 'Owner' ||
      widget.currentUserRole == 'Trainer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Plan'),
            Text(
              widget.memberName,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.success, AppColors.turquoise],
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loadingUid) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.turquoise),
      );
    }
    if (_uidError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.link_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                _uidError!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: () {
                  setState(() {
                    _uidError = null;
                    _loadingUid = true;
                  });
                  _fetchMemberAuthUid();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.turquoise,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('aiPlans')
          .doc(_memberAuthUid)
          .collection('current')
          .doc('current')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
                color: AppColors.turquoise),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 64, color: Colors.red),
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
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.smart_toy_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Member has not generated an plan yet',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final plan = AiWorkoutPlanModel.fromMap(data, snapshot.data!.id);

        // Populate note field once
        if (_noteController.text.isEmpty &&
            (plan.trainerNote?.isNotEmpty ?? false)) {
          _noteController.text = plan.trainerNote!;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewCard(plan),
              const SizedBox(height: 16),
              if (plan.status == 'medicalhold')
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.medical_services,
                          color: Colors.red[700]),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Medical Hold — Plan is paused. '
                          'Member should consult doctor before resuming.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              _buildWeeklyPlan(plan),
              const SizedBox(height: 16),
              _buildAnnotationPanel(plan),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewCard(AiWorkoutPlanModel plan) {
    final fmt =
        DateFormat('dd MMM yyyy, hh:mm a');
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Plan Overview',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                _statusChip(plan.status),
              ],
            ),
            const Divider(height: 20),
            Text(
              'Generated: ${fmt.format(plan.generatedAt.toDate())}',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            if ((plan.basedOn as Map).isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Based On:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              ...(plan.basedOn)
                  .entries
                  .map(
                    (e) => Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${e.key}: ',
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13),
                          ),
                          Expanded(
                            child: Text(
                              '${e.value}',
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
            if (plan.trainerNote != null &&
                plan.trainerNote!.isNotEmpty) ...[
              const Divider(height: 20),
              const Row(
                children: [
                  Icon(Icons.note_alt_outlined,
                      size: 16, color: AppColors.turquoise),
                  SizedBox(width: 6),
                  Text('Trainer Note:',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.turquoise)),
                ],
              ),
              const SizedBox(height: 6),
              Text(plan.trainerNote!,
                  style: const TextStyle(fontSize: 13)),
              if (plan.trainerNoteUpdatedAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Updated: ${fmt.format(plan.trainerNoteUpdatedAt!.toDate())}',
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final isActive = status == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withValues(alpha: 0.15)
            : Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? Colors.green.withValues(alpha: 0.5)
              : Colors.red.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        status == 'medicalhold' ? 'Medical Hold' : 'Active',
        style: TextStyle(
          color: isActive ? Colors.green[700] : Colors.red[700],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildWeeklyPlan(AiWorkoutPlanModel plan) {
    if (plan.weeklyPlan.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '7-Day Plan',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...plan.weeklyPlan.map((day) => _buildDayTile(day)),
          ],
        ),
      ),
    );
  }

  Widget _buildDayTile(Map<String, dynamic> day) {
    final dayName = day['day'] as String? ?? 'Day';
    final isRest = day['isRestDay'] as bool? ?? false;
    final exercises =
        (day['exercises'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();

    return ExpansionTile(
      title: Row(
        children: [
          Text(dayName,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isRest
                  ? Colors.grey.withValues(alpha: 0.2)
                  : AppColors.turquoise.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              isRest ? 'Rest' : 'Training',
              style: TextStyle(
                fontSize: 11,
                color: isRest
                    ? Colors.grey[600]
                    : AppColors.turquoise,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      children: isRest
          ? [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  'Active Recovery / Rest',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ]
          : exercises
              .map(
                (ex) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.fitness_center,
                      size: 16, color: AppColors.turquoise),
                  title: Text(
                    ex['name'] as String? ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: Text(
                    '${ex['sets'] ?? '-'} × ${ex['reps'] ?? '-'}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.success),
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildAnnotationPanel(AiWorkoutPlanModel plan) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.rate_review_outlined,
                    color: AppColors.turquoise),
                SizedBox(width: 8),
                Text(
                  'Trainer Annotation',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!_canEdit) ...[
              // Receptionist — read-only
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  plan.trainerNote?.isNotEmpty ?? false
                      ? plan.trainerNote!
                      : 'No trainer note yet.',
                  style: TextStyle(
                      fontSize: 14,
                      color: plan.trainerNote?.isNotEmpty ?? false
                          ? Colors.black87
                          : Colors.grey),
                ),
              ),
              if (plan.trainerNoteUpdatedAt != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Last updated: ${DateFormat('dd MMM yyyy, hh:mm a').format(plan.trainerNoteUpdatedAt!.toDate())}',
                  style: const TextStyle(
                      fontSize: 11, color: Colors.grey),
                ),
              ],
            ] else ...[
              // Owner / Trainer — editable
              TextFormField(
                controller: _noteController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'Add a note for this member\'s plan...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: AppColors.turquoise
                            .withValues(alpha: 0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: AppColors.turquoise),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _savingNote
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_savingNote ? 'Saving...' : 'Save Note'),
                  onPressed: _savingNote ? null : _saveNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.turquoise,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
