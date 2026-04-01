import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class PersonalBestsScreen extends StatelessWidget {
  final String memberId;

  const PersonalBestsScreen({super.key, required this.memberId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.cardSurface,
        elevation: 0,
        title: Text(
          'Personal Bests',
          style: AppTextStyles.heading3.copyWith(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('personalbests')
            .doc(memberId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.neonLime,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading personal bests',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
              ),
            );
          }

          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final exercisesMap = data?['exercises'] as Map<String, dynamic>? ?? {};

          if (exercisesMap.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    size: 64,
                    color: AppColors.gray600,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Complete a workout to set your first PB',
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.gray400),
                  ),
                ],
              ).animate().fadeIn().scale(),
            );
          }

          // Convert map to list and sort by setAt descending
          final exercisesList = exercisesMap.entries.toList();
          exercisesList.sort((a, b) {
            final aSetAt = a.value['setAt'] as Timestamp?;
            final bSetAt = b.value['setAt'] as Timestamp?;
            if (aSetAt == null && bSetAt == null) return 0;
            if (aSetAt == null) return 1;
            if (bSetAt == null) return -1;
            return bSetAt.compareTo(aSetAt);
          });

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: exercisesList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final entry = exercisesList[index];
              final exerciseName = entry.key;
              final details = entry.value as Map<String, dynamic>;

              final value = details['value'] as num;
              final unit = details['unit'] as String? ?? '';
              final setAt = details['setAt'] as Timestamp?;

              final dateStr = setAt != null
                  ? DateFormat('MMM d, yyyy').format(setAt.toDate())
                  : 'Unknown Date';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.neonLime.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.fitness_center_rounded,
                        color: AppColors.neonLime,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exerciseName,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Set on $dateStr',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.gray400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${value.toInt()}$unit',
                          style: AppTextStyles.heading2.copyWith(
                            color: AppColors.neonLime,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gray800,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'In session',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.gray400,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
            },
          );
        },
      ),
    );
  }
}
