import re

with open("spring_health_member_app/lib/screens/workout/workout_logger_screen.dart", "r") as f:
    content = f.read()

content = re.sub(
    r"      final badges = await _gamService\.awardXp\([\s\S]*?workoutVolumeKg: _totalVolume,\n      \);",
    r"      await GamificationService.instance.processEvent('workout', widget.memberId);",
    content
)

with open("spring_health_member_app/lib/screens/workout/workout_logger_screen.dart", "w") as f:
    f.write(content)
