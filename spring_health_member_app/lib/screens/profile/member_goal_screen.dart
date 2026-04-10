import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/goal_set_sheet.dart';
import '../../services/firebase_auth_service.dart';

class MemberGoalScreen extends StatefulWidget {
  const MemberGoalScreen({super.key});

  @override
  State<MemberGoalScreen> createState() => _MemberGoalScreenState();
}

class _MemberGoalScreenState extends State<MemberGoalScreen> {
  String? _selectedGoal;
  String? _memberId;

  @override
  void initState() {
    super.initState();
    FirebaseAuthService.instance.getCurrentMemberId().then((id) {
      if (mounted) setState(() => _memberId = id);
    });
  }

  final List<Map<String, dynamic>> _goals = [
    {'id': 'weight_loss', 'title': 'Weight Loss', 'icon': Icons.monitor_weight_outlined},
    {'id': 'muscle_gain', 'title': 'Muscle Gain', 'icon': Icons.fitness_center},
    {'id': 'strength', 'title': 'Strength', 'icon': Icons.bar_chart},
    {'id': 'endurance', 'title': 'Endurance', 'icon': Icons.directions_run},
    {'id': 'flexibility', 'title': 'Flexibility', 'icon': Icons.self_improvement},
    {'id': 'general_fitness', 'title': 'General Fitness', 'icon': Icons.sports_gymnastics},
  ];

  void _openGoalSetSheet() {
    if (_selectedGoal == null) return;

    if (_memberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Not authenticated')),
      );
      return;
    }

    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GoalSetSheet(
          authUid: _memberId!,
          primaryGoal: _selectedGoal!,
          createdBy: 'member',
        );
      },
    ).then((result) {
      if (result == true && mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Goal Setup'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'What is your primary fitness goal?',
                style: AppTextStyles.heading2,
                textAlign: TextAlign.center,
              ).animate().fadeIn().slideY(begin: -0.2, end: 0),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _goals.length,
                  itemBuilder: (context, index) {
                    final goal = _goals[index];
                    final isSelected = _selectedGoal == goal['id'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGoal = goal['id'];
                        });
                        // Automatically progress after a tiny delay
                        Future.delayed(const Duration(milliseconds: 300), _openGoalSetSheet);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.neonLime.withValues(alpha: 0.1) : AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.neonLime : AppColors.cardSurface,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              goal['icon'],
                              size: 48,
                              color: isSelected ? AppColors.neonLime : AppColors.gray400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              goal['title'],
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isSelected ? AppColors.neonLime : Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideY(begin: 0.2, end: 0);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
