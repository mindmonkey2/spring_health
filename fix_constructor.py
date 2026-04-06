with open("spring_health_studio/lib/models/member_model.dart", "r") as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    if "required this.gender," in line:
        new_lines.append(line)
        new_lines.append("    this.loyaltyMilestonesAwarded = const [],\n")
    else:
        new_lines.append(line)

with open("spring_health_studio/lib/models/member_model.dart", "w") as f:
    f.writelines(new_lines)
