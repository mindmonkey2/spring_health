import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/member_model.dart';
import '../../models/team_battle_model.dart';
import '../../services/team_battle_service.dart';
import '../../theme/app_colors.dart';

class TrainerTeamBattleScreen extends StatelessWidget {
  final String trainerId;
  final String trainerName;
  final List<MemberModel> assignedMembers;

  const TrainerTeamBattleScreen({
    super.key,
    required this.trainerId,
    required this.trainerName,
    required this.assignedMembers,
  });

  void _showCreateBattleBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CreateBattleBottomSheet(
        trainerId: trainerId,
        trainerName: trainerName,
        assignedMembers: assignedMembers,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<List<TeamBattleModel>>(
        stream: TeamBattleService.instance.getActiveBattlesForTrainer(trainerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final battles = snapshot.data ?? [];

          if (battles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sports_kabaddi, size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text(
                    'No active battles.',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Challenge another trainer to a team battle!',
                    style: GoogleFonts.inter(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: battles.length,
            itemBuilder: (context, index) {
              final battle = battles[index];

              final daysLeft = battle.endDate.difference(DateTime.now()).inDays;
              final maxScore = (battle.team1Score > battle.team2Score ? battle.team1Score : battle.team2Score).clamp(1.0, double.infinity);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              battle.title,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.refresh, size: 20, color: AppColors.primary),
                                tooltip: 'Refresh Scores',
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Computing scores...'), duration: Duration(seconds: 1)),
                                  );
                                  TeamBattleService.instance.computeAndUpdateScores(battle.id);
                                },
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  daysLeft > 0 ? '$daysLeft days left' : 'Ends today',
                                  style: GoogleFonts.inter(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatMetric(battle.metric),
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Team 1 Score
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            battle.team1['name'] ?? 'Your Team',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            battle.team1Score.toStringAsFixed(1),
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: battle.team1Score / maxScore,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        color: AppColors.primary,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 12),
                      // Team 2 Score
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            battle.team2['name'] ?? 'Opponent',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            battle.team2Score.toStringAsFixed(1),
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.warning),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: battle.team2Score / maxScore,
                        backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                        color: AppColors.warning,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'Team 2 scores are computed manually',
                          style: GoogleFonts.inter(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateBattleBottomSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Create Battle',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _formatMetric(String metric) {
    switch (metric) {
      case 'total_sessions':
        return 'Total Sessions';
      case 'total_weight_lifted':
        return 'Total Weight Lifted';
      case 'combined_attendance_days':
        return 'Combined Attendance Days';
      default:
        return metric;
    }
  }
}

class _CreateBattleBottomSheet extends StatefulWidget {
  final String trainerId;
  final String trainerName;
  final List<MemberModel> assignedMembers;

  const _CreateBattleBottomSheet({
    required this.trainerId,
    required this.trainerName,
    required this.assignedMembers,
  });

  @override
  State<_CreateBattleBottomSheet> createState() => _CreateBattleBottomSheetState();
}

class _CreateBattleBottomSheetState extends State<_CreateBattleBottomSheet> {
  final _titleController = TextEditingController();
  final _opponentTrainerController = TextEditingController();
  final _team2MembersController = TextEditingController();

  String _selectedMetric = 'total_sessions';
  int _selectedDuration = 7;
  final Set<String> _selectedTeam1MemberIds = {};

  bool _isCreating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _opponentTrainerController.dispose();
    _team2MembersController.dispose();
    super.dispose();
  }

  Future<void> _createBattle() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title'), backgroundColor: AppColors.error),
      );
      return;
    }
    if (_selectedTeam1MemberIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 1 member for your team'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      await TeamBattleService.instance.createBattle(
        organizerTrainerId: widget.trainerId,
        organizerName: widget.trainerName,
        team1Name: '${widget.trainerName}\'s Team',
        team1MemberIds: _selectedTeam1MemberIds.toList(),
        team2TrainerId: _opponentTrainerController.text.trim(),
        team2Name: '${_opponentTrainerController.text.trim()}\'s Team',
        team2MemberIds: [], // Manual text input not linked to DB yet
        metric: _selectedMetric,
        title: _titleController.text.trim(),
        durationDays: _selectedDuration,
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Battle created successfully!'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create battle: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create Team Battle',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Battle Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Metric
            Text(
              'Metric',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChoiceChip('Total Sessions', 'total_sessions', _selectedMetric, (v) => setState(() => _selectedMetric = v)),
                _buildChoiceChip('Total Weight', 'total_weight_lifted', _selectedMetric, (v) => setState(() => _selectedMetric = v)),
                _buildChoiceChip('Attendance Days', 'combined_attendance_days', _selectedMetric, (v) => setState(() => _selectedMetric = v)),
              ],
            ),
            const SizedBox(height: 16),

            // Duration
            Text(
              'Duration',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildDurationChip(7),
                _buildDurationChip(14),
                _buildDurationChip(30),
              ],
            ),
            const SizedBox(height: 16),

            // Team 1 Members
            Text(
              'Team 1 (YOUR TEAM)',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            widget.assignedMembers.isEmpty
                ? Text('No assigned members to select.', style: GoogleFonts.inter(color: AppColors.textMuted))
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.assignedMembers.map((m) {
                      final isSelected = _selectedTeam1MemberIds.contains(m.id);
                      return FilterChip(
                        label: Text(m.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTeam1MemberIds.add(m.id);
                            } else {
                              _selectedTeam1MemberIds.remove(m.id);
                            }
                          });
                        },
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primary,
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 16),

            // Opponent Trainer
            TextField(
              controller: _opponentTrainerController,
              decoration: const InputDecoration(
                labelText: 'Opponent Trainer Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Team 2 Members
            TextField(
              controller: _team2MembersController,
              decoration: const InputDecoration(
                labelText: 'Team 2 Members (Comma separated names)',
                border: OutlineInputBorder(),
                helperText: 'Note: Full cross-trainer member lookup is out of scope. Team 2 scores are computed manually.',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isCreating ? null : _createBattle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isCreating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Create Battle',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label, String value, String groupValue, Function(String) onSelect) {
    return ChoiceChip(
      label: Text(label),
      selected: groupValue == value,
      onSelected: (selected) {
        if (selected) onSelect(value);
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
    );
  }

  Widget _buildDurationChip(int days) {
    return ChoiceChip(
      label: Text('$days Days'),
      selected: _selectedDuration == days,
      onSelected: (selected) {
        if (selected) setState(() => _selectedDuration = days);
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
    );
  }
}
