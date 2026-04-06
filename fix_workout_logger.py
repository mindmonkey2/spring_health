import re

with open("spring_health_member_app/lib/screens/workout/workout_logger_screen.dart", "r") as f:
    content = f.read()

content = re.sub(r'      final badges = await _gamService\.awardXp\([^;]+;\n\n      if \(mounted\) \{\n        if \(badges\.isNotEmpty\) \{\n          _showBadgeToast\(badges\.first\);\n        \}\n      \}',
                 r"      await GamificationService.instance.processEvent('workout', widget.memberId);",
                 content, flags=re.DOTALL)

with open("spring_health_member_app/lib/screens/workout/workout_logger_screen.dart", "w") as f:
    f.write(content)
