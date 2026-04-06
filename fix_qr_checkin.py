import re

with open("spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart", "r") as f:
    content = f.read()

# Make sure it imports gamification_service.dart
if "import '../../services/gamification_service.dart';" not in content:
    content = content.replace("import '../../models/gamification_model.dart';", "import '../../models/gamification_model.dart';\nimport '../../services/gamification_service.dart';")


new_award_checkin = """  Future<void> _awardCheckInXp() async {
    try {
      await GamificationService.instance.processEvent('checkin', widget.member.id);
      if (mounted) {
        setState(() {
          _earnedXp = 20; // Changed according to processEvent checkin
        });
      }
    } catch (e) {
      debugPrint(' QrCheckInScreen processEvent error: $e');
    }
  }"""

content = re.sub(r'  Future<void> _awardCheckInXp\(\) async \{.*?    \}\n  \}', new_award_checkin, content, flags=re.DOTALL)

with open("spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart", "w") as f:
    f.write(content)
