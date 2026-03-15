// lib/screens/trainers/trainers_list_screen.dart
import 'package:flutter/material.dart';
import '../../models/trainer_model.dart';
import '../../services/firestore_service.dart';
import 'add_trainer_screen.dart';
import 'trainer_detail_screen.dart';
import '../../theme/app_colors.dart';

class TrainersListScreen extends StatefulWidget {
  final String? branch;

  const TrainersListScreen({super.key, this.branch});

  @override
  State<TrainersListScreen> createState() => _TrainersListScreenState();
}

class _TrainersListScreenState extends State<TrainersListScreen> {
  final _firestoreService = FirestoreService();
  final _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedSpecialization = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TrainerModel> _filterTrainers(List<TrainerModel> trainers) {
    return trainers.where((trainer) {
      final matchesSearch = trainer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      trainer.phone.contains(_searchQuery);
      final matchesSpecialization = _selectedSpecialization == 'All' ||
      trainer.specialization == _selectedSpecialization;
      return matchesSearch && matchesSpecialization;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.branch != null ? '${widget.branch} Trainers' : 'All Trainers'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.success, AppColors.turquoise],
            ),
          ),
        ),
        foregroundColor: Colors.white,
          elevation: 0,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search trainers by name or phone...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.success),
                    suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                    : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.success, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                const SizedBox(height: 12),

                // Specialization Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      _buildFilterChip('Gym Training'),
                      _buildFilterChip('Yoga'),
                      _buildFilterChip('Cardio'),
                      _buildFilterChip('Zumba'),
                      _buildFilterChip('CrossFit'),
                      _buildFilterChip('Personal Training'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Trainers List
          Expanded(
            child: StreamBuilder<List<TrainerModel>>(
              stream: widget.branch != null
              ? _firestoreService.getTrainersByBranch(widget.branch!)
              : _firestoreService.getAllTrainers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.success),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading trainers',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                final allTrainers = snapshot.data ?? [];
                final filteredTrainers = _filterTrainers(allTrainers);

                if (filteredTrainers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty ? 'No trainers yet' : 'No trainers found',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty
                          ? 'Add your first trainer'
                        : 'Try a different search',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTrainers.length,
                  itemBuilder: (context, index) {
                    final trainer = filteredTrainers[index];
                    return _buildTrainerCard(trainer);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTrainerScreen(branch: widget.branch),
            ),
          );
          if (result == true) {
            // Refresh handled by StreamBuilder
          }
        },
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
          icon: const Icon(Icons.person_add),
          label: const Text('Add Trainer'),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedSpecialization == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedSpecialization = label;
          });
        },
        selectedColor: AppColors.success.withValues(alpha: 0.2),
        checkmarkColor: AppColors.success,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.success : AppColors.textSecondary,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.success : AppColors.border,
        ),
      ),
    );
  }

  Widget _buildTrainerCard(TrainerModel trainer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrainerDetailScreen(trainerId: trainer.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.success.withValues(alpha: 0.1),
                child: trainer.photoUrl != null
                ? ClipOval(
                  child: Image.network(
                    trainer.photoUrl!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        trainer.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      );
                    },
                  ),
                )
                : Text(
                  trainer.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            trainer.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: trainer.isActive
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            trainer.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: trainer.isActive ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.fitness_center, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          trainer.specialization,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.timeline, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          trainer.experience,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          trainer.phone,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: AppColors.turquoise),
                        const SizedBox(width: 4),
                        Text(
                          trainer.branch,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.turquoise,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.people, size: 12, color: AppColors.warning),
                              const SizedBox(width: 4),
                              Text(
                                '${trainer.assignedMembers.length} members',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.warning,
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
              const SizedBox(width: 8),

              // Arrow
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
