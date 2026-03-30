import re

with open("spring_health_studio/lib/screens/trainer/trainer_warmup_screen.dart", "r") as f:
    content = f.read()

# Revert previous global replace to be safe and manually fix the consts
content = content.replace("child: const Chip(", "child: Chip(")
content = content.replace("              child: Chip(\n                label: const Text(\n                  'AjAX Ready',", "              child: const Chip(\n                label: Text(\n                  'AjAX Ready',")

# Fix lines 165
content = content.replace("          Center(\n            child: Chip(\n              label: const Text(", "          const Center(\n            child: Chip(\n              label: Text(")

# Fix line 306
content = content.replace("                Padding(\n                  padding: const EdgeInsets.only(top: 8.0),\n                  child: Chip(\n                    label: const Text('Recommended', style: TextStyle(color: AppColors.textOnPrimary, fontSize: 12)),\n                    backgroundColor: AppColors.turquoise,\n                    visualDensity: VisualDensity.compact,\n                  ),\n                ),", "                const Padding(\n                  padding: EdgeInsets.only(top: 8.0),\n                  child: Chip(\n                    label: Text('Recommended', style: TextStyle(color: AppColors.textOnPrimary, fontSize: 12)),\n                    backgroundColor: AppColors.turquoise,\n                    visualDensity: VisualDensity.compact,\n                  ),\n                ),")

with open("spring_health_studio/lib/screens/trainer/trainer_warmup_screen.dart", "w") as f:
    f.write(content)
