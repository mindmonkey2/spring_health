import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../models/trainer_model.dart';
import '../../models/member_model.dart';
import '../../models/trainer_feedback_model.dart';
class TrainerDashboardScreen extends StatefulWidget {
  final UserModel user;

  const TrainerDashboardScreen({super.key, required this.user});

  @override
  State<TrainerDashboardScreen> createState() => _TrainerDashboardScreenState();
}

class _TrainerDashboardScreenState extends State<TrainerDashboardScreen> {
  final ValueNotifier<int> _tabNotifier = ValueNotifier<int>(0);
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _tabNotifier.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _tabNotifier.value = index;
  }

  Future<void> _logout() async {
    await _authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trainer Dashboard - ${widget.user.branch}'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: _tabNotifier,
        builder: (context, currentIndex, child) {
          switch (currentIndex) {
            case 0:
              return _MyClientsTab(user: widget.user);
            case 1:
              return _DietPlansTab(user: widget.user);
            case 2:
              return _FeedbackTab(user: widget.user);
            default:
              return _MyClientsTab(user: widget.user);
          }
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _tabNotifier,
        builder: (context, currentIndex, child) {
          return BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'My Clients',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_menu),
                label: 'Diet Plans',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.feedback),
                label: 'Feedback',
              ),
            ],
            currentIndex: currentIndex,
            selectedItemColor: AppColors.primaryDark,
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
          );
        },
      ),
    );
  }
}

class _MyClientsTab extends StatelessWidget {
  final UserModel user;

  const _MyClientsTab({required this.user});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return FutureBuilder<TrainerModel?>(
      future: firestoreService.getTrainerById(user.uid),
      builder: (context, trainerSnapshot) {
        if (trainerSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (trainerSnapshot.hasError || trainerSnapshot.data == null) {
          return const Center(child: Text('Could not load trainer profile.'));
        }

        final trainer = trainerSnapshot.data!;

        return FutureBuilder<List<MemberModel>>(
          future: firestoreService.getAssignedMembers(user.branch ?? '', trainer.assignedMembers),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error loading clients: ${snapshot.error}'));
            }

            final clients = snapshot.data ?? [];

            if (clients.isEmpty) {
              return const Center(child: Text('No clients assigned yet.'));
            }

            return ListView.builder(
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final client = clients[index];
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(client.name),
                  subtitle: Text(client.phone),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.primaryDark),
                  onTap: () {
                    // Navigate to client detail if needed
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _DietPlansTab extends StatelessWidget {
  final UserModel user;

  const _DietPlansTab({required this.user});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Diet Plans Module (Select Client to view/edit)'),
    );
  }
}

class _FeedbackTab extends StatelessWidget {
  final UserModel user;

  const _FeedbackTab({required this.user});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return StreamBuilder<List<TrainerFeedbackModel>>(
      stream: firestoreService.getTrainerFeedback(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading feedback: ${snapshot.error}'));
        }

        final feedbacks = snapshot.data ?? [];

        if (feedbacks.isEmpty) {
          return const Center(child: Text('No feedback received yet.'));
        }

        return ListView.builder(
          itemCount: feedbacks.length,
          itemBuilder: (context, index) {
            final feedback = feedbacks[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          feedback.memberName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(feedback.rating.toString()),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (feedback.comment != null && feedback.comment!.isNotEmpty)
                      Text('Note: ${feedback.comment!}'),
                    const SizedBox(height: 8),
                    if (feedback.trainerReply != null && feedback.trainerReply!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Your Reply: ${feedback.trainerReply!}',
                          style: const TextStyle(color: AppColors.primaryDark),
                        ),
                      )
                    else
                      ElevatedButton(
                        onPressed: () {
                          _showReplyDialog(context, feedback, firestoreService, user.uid);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('Reply'),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showReplyDialog(BuildContext context, TrainerFeedbackModel feedback, FirestoreService firestoreService, String trainerId) {
    final TextEditingController replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reply to Feedback'),
          content: TextField(
            controller: replyController,
            decoration: const InputDecoration(
              hintText: 'Enter your reply...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final reply = replyController.text.trim();
                if (reply.isNotEmpty) {
                  try {
                    await firestoreService.replyToFeedback(trainerId, feedback.id, reply);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reply submitted successfully.')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to reply: $e')),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
