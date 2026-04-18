import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../main_screen.dart';

class PostSessionSummaryScreen extends StatefulWidget {
  final String memberId;
  final String sessionId;
  final String memberAuthUid;

  const PostSessionSummaryScreen({
    super.key,
    required this.memberId,
    required this.sessionId,
    required this.memberAuthUid,
  });

  @override
  State<PostSessionSummaryScreen> createState() => _PostSessionSummaryScreenState();
}

class _PostSessionSummaryScreenState extends State<PostSessionSummaryScreen> {
  bool _isLoading = true;
  int _xpAwarded = 0;
  int _exerciseCount = 0;
  int _durationMinutes = 0;
  Timestamp? _sessionDate;
  List<Map<String, dynamic>> _pbsThisSession = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // READ 1 - sessions/{sessionId}
      final sessionDoc = await FirebaseFirestore.instance
          .collection('sessions')
          .doc(widget.sessionId)
          .get();

      if (sessionDoc.exists) {
        final data = sessionDoc.data()!;
        _xpAwarded = (data['xpAwarded'] as int?) ?? 0;
        _exerciseCount = (data['exerciseCount'] as int?) ?? 0;
        _durationMinutes = (data['durationMinutes'] as int?) ?? 0;
        _sessionDate = data['sessionDate'] as Timestamp?;
      }

      // READ 2 - workouts (informational)
      await FirebaseFirestore.instance
          .collection('workouts')
          .where('memberId', isEqualTo: widget.memberAuthUid)
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      // READ 3 - personalbests/{memberAuthUid}
      if (_sessionDate != null) {
        final pbDoc = await FirebaseFirestore.instance
            .collection('personalbests')
            .doc(widget.memberAuthUid)
            .get();

        if (pbDoc.exists) {
          final pbData = pbDoc.data()!;
          final List<Map<String, dynamic>> foundPBs = [];
          pbData.forEach((key, value) {
            if (value is Map) {
              final pbDate = value['date'] as Timestamp?;
              if (pbDate != null && pbDate.compareTo(_sessionDate!) >= 0) {
                foundPBs.add({
                  'exerciseName': value['exerciseName']?.toString() ?? 'Exercise',
                  'value': value['value'] as num? ?? 0,
                });
              }
            }
          });
          _pbsThisSession = foundPBs;
        }
      }
    } catch (e) {
      // Silent catch or add some error logging if needed
      debugPrint('Error fetching summary data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFC6F135)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // 1. Session Complete text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Session Complete',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFFC6F135),
                    size: 32,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 2. XP chip
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Text(
                    _xpAwarded > 0 ? '+$_xpAwarded XP' : 'XP Awarded',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _xpAwarded > 0 ? Colors.white : Colors.white54,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 3. Stats row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$_exerciseCount',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC6F135),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'exercises',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$_durationMinutes',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC6F135),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'min',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // 4. PBs section
              const Text(
                'Personal Bests This Session',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC6F135),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (_pbsThisSession.isNotEmpty)
                ..._pbsThisSession.map((pb) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              pb['exerciseName'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            pb['value'].toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00E5FF),
                            ),
                          ),
                        ],
                      ),
                    ))
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    'Keep pushing — PBs coming!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const Spacer(),

              // 5. Back to Home button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC6F135),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 600.ms),
        ),
      ),
    );
  }
}
