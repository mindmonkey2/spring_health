with open('spring_health_member_app/lib/screens/fitness/live_session_screen.dart', 'r') as f:
    content = f.read()

content = content.replace("import 'package:spring_health_member_app/screens/fitness/post_session_summary_screen.dart';", "import 'package:spring_health_member/screens/fitness/post_session_summary_screen.dart';")

with open('spring_health_member_app/lib/screens/fitness/live_session_screen.dart', 'w') as f:
    f.write(content)
