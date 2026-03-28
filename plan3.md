1. **Model & Service Setup:**
   - Use `write_file` to create `spring_health_member_app/lib/models/member_goal_model.dart` representing `memberGoals` collection.
   - Use `write_file` to create `spring_health_member_app/lib/services/member_goal_service.dart`.
   - Use `write_file` to create `spring_health_studio/lib/models/member_goal_model.dart`.
   - Use `write_file` to create `spring_health_studio/lib/services/member_goal_service.dart`.
   - Verify creation by using `run_in_bash_session` to `ls` these files.
2. **Sub-Task 1: Member App - Goal Setup Screen**
   - Use `write_file` to create `spring_health_member_app/lib/screens/profile/member_goal_screen.dart` with Neon Dark theme.
   - Implement the 4-step wizard:
     * Step 1: 6 Goal Cards with neonLime selection borders.
     * Step 2: Target inputs based on selected goal.
     * Step 3: Deadline selector and Weekly sessions picker.
     * Step 4: Review Summary, initial milestone generation, and Firestore write to `memberGoals/{authUid}`. Show SnackBar (NO EMOJIS) and Navigator.pop.
   - Verify creation by using `run_in_bash_session` to `cat` or `ls` the screen file.
3. **Sub-Task 2: Member App - Wiring**
   - Use `replace_with_git_merge_diff` to update `spring_health_member_app/lib/screens/profile/profile_screen.dart`: Add an Action Tile for "My Goal & Target" (Icons.flag, neonLime) that pushes `MemberGoalScreen`.
   - Use `replace_with_git_merge_diff` to update `spring_health_member_app/lib/screens/home/home_screen.dart`: Add a Goal Progress card. I will place it ABOVE the `_buildAiCoachBanner()` (which represents the session banner/AI Coach banner) in the `build` method. Fetch the active goal and display progress without emojis.
   - Verify changes by running `run_in_bash_session` to `grep` for the new code in both files.
4. **Sub-Task 3: Studio App - Trainer Goal Setup**
   - Use `write_file` to create `spring_health_studio/lib/screens/members/trainer_set_goal_screen.dart` with Wellness & Balance theme.
   - Replicate the logic from the member app's screen but geared for a trainer setting it on behalf of a member (takes `memberAuthUid`).
   - Write to `memberGoals/{authUid}` setting `createdBy: 'trainer'`.
   - Verify creation by using `run_in_bash_session` to `ls` the file.
5. **Run Analysis:**
   - Use `run_in_bash_session` to run `cd spring_health_member_app && flutter analyze` and `cd spring_health_studio && flutter analyze` on both apps to ensure exactly "No issues found!".
6. **Pre-commit Steps**
   - Complete pre-commit steps to ensure proper testing, verification, review, and reflection are done.
