with open("spring_health_studio/lib/models/member_model.dart", "r") as f:
    lines = f.readlines()

new_lines = []
for i, line in enumerate(lines):
    if "final bool isActive;" in line:
        new_lines.append(line)
        new_lines.append("  final List<String> loyaltyMilestonesAwarded;\n")
    elif "this.isActive = true," in line:
        new_lines.append(line)
        new_lines.append("    this.loyaltyMilestonesAwarded = const [],\n")
    elif "isActive: map['isActive'] as bool? ?? true," in line:
        new_lines.append(line)
        new_lines.append("      loyaltyMilestonesAwarded: List<String>.from(map['loyaltyMilestonesAwarded'] as List? ?? []),\n")
    elif "'isActive': isActive," in line:
        new_lines.append(line)
        new_lines.append("      'loyaltyMilestonesAwarded': loyaltyMilestonesAwarded,\n")
    elif "bool? isActive," in line:
        new_lines.append(line)
        new_lines.append("    List<String>? loyaltyMilestonesAwarded,\n")
    elif "isActive: isActive ?? this.isActive," in line:
        new_lines.append(line)
        new_lines.append("      loyaltyMilestonesAwarded: loyaltyMilestonesAwarded ?? this.loyaltyMilestonesAwarded,\n")
    else:
        new_lines.append(line)

with open("spring_health_studio/lib/models/member_model.dart", "w") as f:
    f.writelines(new_lines)
