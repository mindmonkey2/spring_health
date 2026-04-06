import re

with open("spring_health_studio/lib/models/member_model.dart", "r") as f:
    content = f.read()

# Let's cleanly replace the file to what it should be.
# First undo the messes.
content = re.sub(r'this\.loyaltyMilestonesAwarded = const \[\],\n    List<String>\? loyaltyMilestonesAwarded,', 'List<String>? loyaltyMilestonesAwarded,', content)

# It says MemberModel({ at 34
content = re.sub(r'this\.isActive = true,\n    this\.loyaltyMilestonesAwarded = const \[\],\n    this\.loyaltyMilestonesAwarded = const \[\],', 'this.isActive = true,\n    this.loyaltyMilestonesAwarded = const [],', content)

# Check line 221
content = re.sub(r'loyaltyMilestonesAwarded: map\[\'loyaltyMilestonesAwarded\'\] \?\? \[\]', 'loyaltyMilestonesAwarded: List<String>.from(map[\'loyaltyMilestonesAwarded\'] as List? ?? [])', content)

# I will just write a python script to regex find the MemberModel class constructor and add the variable correctly without duplicates.
