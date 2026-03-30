with open("spring_health_studio/lib/screens/trainer/trainer_warmup_screen.dart", "r") as f:
    content = f.read()

content = content.replace("              child: Chip(\n                label: Text(\n                  session.sessionFocus!,\n                  style: const TextStyle(color: AppColors.turquoiseDark),\n                ),", "              child: Chip(\n                label: Text(\n                  session.sessionFocus!,\n                  style: const TextStyle(color: AppColors.turquoiseDark),\n                ),")
content = content.replace("                backgroundColor: AppColors.turquoise.withValues(alpha: 0.1),\n              ),\n            ),", "                backgroundColor: const Color(0x1A4ECDC4),\n              ),\n            ),")

with open("spring_health_studio/lib/screens/trainer/trainer_warmup_screen.dart", "w") as f:
    f.write(content)
