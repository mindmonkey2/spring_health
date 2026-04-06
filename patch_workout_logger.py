with open("spring_health_member_app/lib/screens/workout/workout_logger_screen.dart", "r") as f:
    lines = f.readlines()

new_lines = []
skip = False
for i, line in enumerate(lines):
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

    if "if (mounted) {" in line and i > 1400:
        if "if (badges.isNotEmpty) {" in lines[i+1]:
            # skip the next few lines
            continue
    if "if (badges.isNotEmpty) {" in line and i > 1400:
        continue
    if "_showBadgeToast(badges.first);" in line and i > 1400:
        continue
    if "}" in line and i > 1400 and "if (badges.isNotEmpty) {" in lines[i-2]:
        continue
    if "}" in line and i > 1400 and "if (mounted) {" in lines[i-4]:
        continue

    new_lines.append(line)

# Wait let me do it simply:
