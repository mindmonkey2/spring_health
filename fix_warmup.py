import re

with open("spring_health_studio/lib/screens/trainer/trainer_warmup_screen.dart", "r") as f:
    content = f.read()

# Fix consts and onTap
content = content.replace("Colors.blueGrey.withValues(alpha: 0.1);", "const Color(0x1A607D8B);")
content = content.replace("AppColors.turquoise.withValues(alpha: 0.1);", "const Color(0x1A4ECDC4);")
content = content.replace("AppColors.primaryLight.withValues(alpha: 0.1);", "const Color(0x1A8B9FF7);")
content = content.replace("Colors.black.withValues(alpha: 0.1)", "const Color(0x1A000000)")

# Remove onTap from ElevatedButton
content = content.replace("                  onTap: () {}, // Handled by InkWell above\n", "")

with open("spring_health_studio/lib/screens/trainer/trainer_warmup_screen.dart", "w") as f:
    f.write(content)
