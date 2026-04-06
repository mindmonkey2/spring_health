import re

with open("spring_health_member_app/lib/screens/home/home_screen.dart", "r") as f:
    content = f.read()

content = content.replace("_gamService.listenToEvents(memberId);", "_gamService.listenForPendingLoyaltyEvents(memberId);")

with open("spring_health_member_app/lib/screens/home/home_screen.dart", "w") as f:
    f.write(content)
