import re

with open('spring_health_member_app/lib/screens/fitness/live_session_screen.dart', 'r') as f:
    content = f.read()

content = content.replace("bool _navigatedToSummary = false;", "")

content = content.replace("""class LiveSessionScreen extends StatelessWidget {
  final String sessionId;
  final String memberId;
  const LiveSessionScreen({super.key, required this.sessionId, required this.memberId});""", """class LiveSessionScreen extends StatefulWidget {
  final String sessionId;
  final String memberId;
  const LiveSessionScreen({super.key, required this.sessionId, required this.memberId});

  @override
  State<LiveSessionScreen> createState() => _LiveSessionScreenState();
}

class _LiveSessionScreenState extends State<LiveSessionScreen> {
  bool _navigatedToSummary = false;
""")

content = content.replace("import 'post_session_summary_screen.dart';", "import 'package:spring_health_member_app/screens/fitness/post_session_summary_screen.dart';")

content = content.replace(".doc(sessionId)", ".doc(widget.sessionId)")

old_complete = """  Widget _buildCompleteView(BuildContext context, Map<String, dynamic> data) {
    if (!_navigatedToSummary) {
      _navigatedToSummary = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PostSessionSummaryScreen(
                memberId: memberId,
                sessionId: sessionId,
                memberAuthUid: FirebaseAuthService.instance.currentUser!.uid,
              ),
            ),
          );
        }
      });
    }
    return const SizedBox.shrink();
  }"""

new_complete = """  Widget _buildCompleteView(BuildContext context, Map<String, dynamic> data) {
    if (!_navigatedToSummary) {
      _navigatedToSummary = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PostSessionSummaryScreen(
                memberId: widget.memberId,
                sessionId: widget.sessionId,
                memberAuthUid: FirebaseAuthService.instance.currentUser!.uid,
              ),
            ),
          );
        }
      });
    }
    return const SizedBox.shrink();
  }"""

content = content.replace(old_complete, new_complete)

# Now we need to close the state class right before _StretchingView
old_cancelled = """  Widget _buildCancelledView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.bed_rounded,
            color: AppColors.gray400,
            size: 64,
          ),
          const SizedBox(height: 24),
          Text(
            'Session cancelled',
            style: AppTextStyles.heading3.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Rest day. See you tomorrow!',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
          ),
        ],
      ),
    );
  }
}

class _StretchingView extends StatefulWidget {"""

new_cancelled = """  Widget _buildCancelledView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.bed_rounded,
            color: AppColors.gray400,
            size: 64,
          ),
          const SizedBox(height: 24),
          Text(
            'Session cancelled',
            style: AppTextStyles.heading3.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Rest day. See you tomorrow!',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
          ),
        ],
      ),
    );
  }
}

class _StretchingView extends StatefulWidget {"""

content = content.replace(old_cancelled, new_cancelled)

with open('spring_health_member_app/lib/screens/fitness/live_session_screen.dart', 'w') as f:
    f.write(content)
