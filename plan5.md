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
   - Use `replace_with_git_merge_diff` to update `spring_health_member_app/lib/screens/home/home_screen.dart`: Add a Goal Progress card. Since I read `home_screen.dart` lines 320-350 previously, I saw that `_buildAiCoachBanner()` is indeed the banner directly below `MembershipCardWidget()`. The prompt asks to add the progress card "ABOVE the session banner". Therefore, I will insert the new `_buildGoalProgressCard()` call immediately BEFORE the line `_buildAiCoachBanner().animate().fadeIn(delay: 250.ms),` within the `children` list. Fetch the active goal in `_HomeScreenState` and pass it to `_buildGoalProgressCard()`.
   - Verify changes by running `run_in_bash_session` to `grep` for the new code in both files.
4. **Sub-Task 3: Studio App - Trainer Goal Setup**
   - Use `write_file` to create `spring_health_studio/lib/screens/members/trainer_set_goal_screen.dart` with Wellness & Balance theme.
   - Implement the 4-step wizard for the trainer (mirroring member logic but with different theme and slightly different text):
     * Step 1: 6 Goal Cards with teal/sage borders (Wellness & Balance).
     * Step 2: Target inputs for weight loss, muscle gain, strength, or endurance.
     * Step 3: Deadline and weekly sessions picker.
     * Step 4: Summary card and save button. Writes to `memberGoals/{authUid}` setting `createdBy: 'trainer'`.
   - Verify creation by using `run_in_bash_session` to `ls` the file.
5. **Run Analysis:**
   - Use `run_in_bash_session` to run `cd spring_health_member_app && flutter analyze && flutter test` and `cd spring_health_studio && flutter analyze && flutter test` on both apps to ensure exactly "No issues found!".
6. **Pre-commit Steps**
   - Complete pre-commit steps to ensure proper testing, verification, review, and reflection are done.
