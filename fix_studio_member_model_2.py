import re

with open("spring_health_studio/lib/models/member_model.dart", "r") as f:
    content = f.read()

# MemberModel.empty initialization missing
content = content.replace("isActive: true,", "isActive: true,\n      loyaltyMilestonesAwarded: const [],")
content = content.replace("this.isActive = true,\n    this.loyaltyMilestonesAwarded = const [],", "this.isActive = true,\n    this.loyaltyMilestonesAwarded = const [],")

# check where final_not_initialized_constructor is
with open("spring_health_studio/lib/models/member_model.dart", "w") as f:
    f.write(content)
