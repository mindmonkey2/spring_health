import re
import os

def replace_in_file(filepath, pattern, replacement):
    with open(filepath, "r") as f:
        content = f.read()
    content = re.sub(pattern, replacement, content, flags=re.DOTALL)
    with open(filepath, "w") as f:
        f.write(content)

# In workout_service.dart
# await _gamificationService.awardXp(
#   memberId,
#   'Workout Complete',
#   XpSource.workoutComplete,
#   isWorkout: true,
#   workoutVolumeKg: totalVolume,
# );
replace_in_file("spring_health_member_app/lib/services/workout_service.dart",
                r'await _gamificationService\.awardXp\([^;]+;\n',
                r"await _gamificationService.processEvent('workout', memberId);\n")

# In home_screen.dart
# final badges = await _gamService.awardXp(
#   _memberId!,
#   'Workout Logged',
#   XpSource.workoutLogged,
#   isWorkout: true,
# );
# if (mounted) { ... _showBadgeToast ...
replace_in_file("spring_health_member_app/lib/screens/home/home_screen.dart",
                r'final badges = await _gamService\.awardXp\([^;]+;\n\s+if \(mounted\) \{\n\s+_loadMemberData\(\);\n\s+if \(badges\.isNotEmpty\) _showBadgeToast\(badges\.first\);\n\s+\}',
                r"await GamificationService.instance.processEvent('workout', _memberId!);\n              if (mounted) _loadMemberData();")

# In workout_history_screen.dart
# await _gamService.awardXp(
#   widget.memberId,
#   'Logged Missing Workout',
#   XpSource.workoutLogged,
#   isWorkout: true,
# );
replace_in_file("spring_health_member_app/lib/screens/workout/workout_history_screen.dart",
                r'await _gamService\.awardXp\([^;]+;\n',
                r"await GamificationService.instance.processEvent('workout', widget.memberId);\n")


# In workout_logger_screen.dart
# final badges = await _gamService.awardXp(
#   widget.memberId,
#   'Workout Complete',
#   XpSource.workoutComplete,
#   isWorkout: true,
# );
replace_in_file("spring_health_member_app/lib/screens/workout/workout_logger_screen.dart",
                r'final badges = await _gamService\.awardXp\([^;]+;\n\n\s+if \(mounted\) \{\n\s+if \(badges\.isNotEmpty\) \{\n\s+_showBadgeToast\(badges\.first\);\n\s+\}\n\s+\}',
                r"await GamificationService.instance.processEvent('workout', widget.memberId);")
