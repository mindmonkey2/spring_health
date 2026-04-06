with open("spring_health_member_app/lib/screens/workout/workout_logger_screen.dart", "r") as f:
    content = f.read()

content = content.replace("final _gamService = GamificationService();", "")
content = content.replace("_showWorkoutSummary(workout, badges);", "_showWorkoutSummary(workout, []);") # provide empty list or null if supported

with open("spring_health_member_app/lib/screens/workout/workout_logger_screen.dart", "w") as f:
    f.write(content)
