import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_text_styles.dart';
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

  final List<Map<String, dynamic>> _personalBests = [];

  @override
  void initState() {
    super.initState();
    _loadSummaryData();
  }

  Future<void> _loadSummaryData() async {
    try {
      final db = FirebaseFirestore.instance;

      // Read 1: sessions/{sessionId}
      final sessionDoc = await db.collection('sessions').doc(widget.sessionId).get();
      if (sessionDoc.exists) {
        final data = sessionDoc.data()!;
        _xpAwarded = (data['xpAwarded'] as num?)?.toInt() ?? 0;
        _exerciseCount = (data['exerciseCount'] as num?)?.toInt() ?? 0;
        _durationMinutes = (data['durationMinutes'] as num?)?.toInt() ?? 0;
        _sessionDate = data['sessionDate'] as Timestamp?;
      }

      // Read 2: workouts query
      await db
          .collection('workouts')
          .where('memberId', isEqualTo: widget.memberAuthUid)
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      // Read 3: personalbests/{memberAuthUid}
      if (_sessionDate != null) {
        final pbDoc = await db.collection('personalbests').doc(widget.memberAuthUid).get();
        if (pbDoc.exists) {
          final data = pbDoc.data()!;
          for (final key in data.keys) {
            final val = data[key];
            if (val is Map<String, dynamic>) {
              // the instructions say "It contains a map of exercise entries... Each entry has these fields... exerciseName, value, date"
              // wait, the instructions literally say "It contains a map of exercise entries. Each entry has these fields..."
              // I will just check if the map has those fields directly
              if (val.containsKey('date') && val['date'] is Timestamp) {
                final entryDate = val['date'] as Timestamp;
                if (entryDate.compareTo(_sessionDate!) >= 0) {
                  _personalBests.add({
                    'exerciseName': val['exerciseName'] ?? key,
                    'value': val['value'],
                  });
                }
              } else if (val.containsKey('history') && val['history'] is List) {
                // Just in case it's nested like the model (from Map)
                final entries = val['history'] as List<dynamic>;
                for (final e in entries) {
                  final entryMap = e as Map<String, dynamic>;
                  final entryDate = entryMap['date'] as Timestamp?;
                  if (entryDate != null && entryDate.compareTo(_sessionDate!) >= 0) {
                    _personalBests.add({
                      'exerciseName': entryMap['exerciseName'] ?? val['exerciseName'] ?? key,
                      'value': entryMap['value'],
                    });
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading summary: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFC6F135))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // 1. "Session Complete ✓" header
              Column(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFFC6F135), size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Session Complete ✓',
                    style: AppTextStyles.heading1.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
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
                    style: AppTextStyles.heading3.copyWith(
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
                    child: _buildStatCard('$_exerciseCount exercises', const Color(0xFFC6F135)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard('$_durationMinutes min', const Color(0xFFC6F135)),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 4. PBs section
              Text(
                'Personal Bests This Session',
                style: AppTextStyles.heading3.copyWith(color: const Color(0xFFC6F135)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (_personalBests.isNotEmpty)
                ..._personalBests.map((pb) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        '${pb['exerciseName']}  ${pb['value']}',
                        style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ))
              else
                Text(
                  'Keep pushing — PBs coming!',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54),
                  textAlign: TextAlign.center,
                ),

              const Spacer(),

              // 5. "Back to Home" button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC6F135),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 600.ms),
        ),
      ),
    );
  }

  Widget _buildStatCard(String text, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          text,
          style: AppTextStyles.heading3.copyWith(color: accentColor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
