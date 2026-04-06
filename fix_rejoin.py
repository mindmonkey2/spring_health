import re

with open("spring_health_studio/lib/screens/members/rejoin_member_screen.dart", "r") as f:
    content = f.read()

# Let's change widget.member back to member to exactly match the request (Wait, the instructions say 'member.id', so I will use renewedMember.id or member.id depending on what's available, widget.member is member).
# "member" in that context refers to widget.member because it's in the state class.
# The instruction:
#   final joinDate = member.joiningDate;
#   final monthsActive = DateTime.now().difference(joinDate).inDays ~/ 30;
#   final alreadyAwarded = member.loyaltyMilestonesAwarded ?? [];

new_loyalty_logic = """      final joinDate = widget.member.joiningDate;
      final monthsActive = DateTime.now().difference(joinDate).inDays ~/ 30;
      final alreadyAwarded = widget.member.loyaltyMilestonesAwarded ?? [];

      if (monthsActive >= 12 && !alreadyAwarded.contains('loyalty_1y')) {
        await FirebaseFirestore.instance.collection('gamification_events').add({
          'memberId': widget.member.id, 'event': 'loyalty_1y', 'timestamp': Timestamp.now(), 'processed': false,
        });
      } else if (monthsActive >= 6 && !alreadyAwarded.contains('loyalty_6m')) {
        await FirebaseFirestore.instance.collection('gamification_events').add({
          'memberId': widget.member.id, 'event': 'loyalty_6m', 'timestamp': Timestamp.now(), 'processed': false,
        });
      } else if (monthsActive >= 3 && !alreadyAwarded.contains('loyalty_3m')) {
        await FirebaseFirestore.instance.collection('gamification_events').add({
          'memberId': widget.member.id, 'event': 'loyalty_3m', 'timestamp': Timestamp.now(), 'processed': false,
        });
      }"""

old_loyalty_logic = """      final joinDate = renewedMember.joiningDate;
      final monthsActive = DateTime.now().difference(joinDate).inDays ~/ 30;
      final alreadyAwarded = widget.member.loyaltyMilestonesAwarded ?? [];

      if (monthsActive >= 12 && !alreadyAwarded.contains('loyalty_1y')) {
        await FirebaseFirestore.instance.collection('gamification_events').add({
          'memberId': renewedMember.id, 'event': 'loyalty_1y', 'timestamp': Timestamp.now(), 'processed': false,
        });
      } else if (monthsActive >= 6 && !alreadyAwarded.contains('loyalty_6m')) {
        await FirebaseFirestore.instance.collection('gamification_events').add({
          'memberId': renewedMember.id, 'event': 'loyalty_6m', 'timestamp': Timestamp.now(), 'processed': false,
        });
      } else if (monthsActive >= 3 && !alreadyAwarded.contains('loyalty_3m')) {
        await FirebaseFirestore.instance.collection('gamification_events').add({
          'memberId': renewedMember.id, 'event': 'loyalty_3m', 'timestamp': Timestamp.now(), 'processed': false,
        });
      }"""
content = content.replace(old_loyalty_logic, new_loyalty_logic)

with open("spring_health_studio/lib/screens/members/rejoin_member_screen.dart", "w") as f:
    f.write(content)
