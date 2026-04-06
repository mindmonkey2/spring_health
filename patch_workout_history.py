with open("spring_health_member_app/lib/screens/workout/workout_history_screen.dart", "r") as f:
    content = f.read()

content = content.replace("final _gamService = GamificationService();", "")

with open("spring_health_member_app/lib/screens/workout/workout_history_screen.dart", "w") as f:
    f.write(content)
