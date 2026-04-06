import re

with open("spring_health_studio/lib/models/member_model.dart", "r") as f:
    content = f.read()

# Add loyaltyMilestonesAwarded to MemberModel
if "final List<String> loyaltyMilestonesAwarded;" not in content:
    content = content.replace("final bool isActive;", "final bool isActive;\n  final List<String> loyaltyMilestonesAwarded;")
    content = content.replace("this.isActive = true,", "this.isActive = true,\n    this.loyaltyMilestonesAwarded = const [],")
    content = content.replace("isActive: map['isActive'] as bool? ?? true,", "isActive: map['isActive'] as bool? ?? true,\n      loyaltyMilestonesAwarded: List<String>.from(map['loyaltyMilestonesAwarded'] as List? ?? []),")
    content = content.replace("'isActive': isActive,", "'isActive': isActive,\n      'loyaltyMilestonesAwarded': loyaltyMilestonesAwarded,")
    content = content.replace("bool? isActive,", "bool? isActive,\n    List<String>? loyaltyMilestonesAwarded,")
    content = content.replace("isActive: isActive ?? this.isActive,", "isActive: isActive ?? this.isActive,\n      loyaltyMilestonesAwarded: loyaltyMilestonesAwarded ?? this.loyaltyMilestonesAwarded,")

with open("spring_health_studio/lib/models/member_model.dart", "w") as f:
    f.write(content)
