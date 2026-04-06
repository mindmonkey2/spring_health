import re

with open("spring_health_member_app/lib/services/gamification_service.dart", "r") as f:
    content = f.read()

content = content.replace("void listenToEvents(String memberId)", "void listenForPendingLoyaltyEvents(String memberId)")

with open("spring_health_member_app/lib/services/gamification_service.dart", "w") as f:
    f.write(content)
