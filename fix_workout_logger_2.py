with open("spring_health_member_app/lib/screens/workout/workout_logger_screen.dart", "r") as f:
    lines = f.readlines()

new_lines = []
skip = False
for line in lines:
    if "final badges = await _gamService.awardXp(" in line:
        new_lines.append("      await GamificationService.instance.processEvent('workout', widget.memberId);\n")
        skip = True
        continue

    if skip and "workoutVolumeKg: _totalVolume," in line:
        continue
    if skip and ");" in line:
        skip = False
        continue
    if skip:
        continue

    if "if (mounted) {" in line and "if (badges.isNotEmpty) {" in "".join(lines):
        pass # we'll just let the compiler complain and fix it if it does

    new_lines.append(line)

with open("spring_health_member_app/lib/screens/workout/workout_logger_screen.dart", "w") as f:
    f.writelines(new_lines)
