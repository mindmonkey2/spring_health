1. **Model & Service Setup:**
   - Create `MemberGoalModel` in both member and studio apps (duplicate/sync). It will represent the `memberGoals` collection.
   - Create `MemberGoalService` to manage fetching, creating, and updating goals.
2. **Sub-Task 1: Member App - Goal Setup Screen**
   - Create `lib/screens/profile/member_goal_screen.dart` with Neon Dark theme.
   - Implement the 4-step wizard using `PageView` or separate build sections controlled by state.
   - Step 1: 6 Goal Cards with neonLime selection borders.
   - Step 2: Target inputs based on selected goal.
   - Step 3: Deadline selector and Weekly sessions picker.
   - Step 4: Review Summary, initial milestone generation, and Firestore write to `memberGoals/{authUid}`.
   - Show SnackBar and pop navigator.
3. **Sub-Task 2: Member App - Wiring**
   - In `profile_screen.dart`, add an Action Tile for "My Goal & Target" (Icons.flag, neonLime) that pushes `MemberGoalScreen`.
   - In `home_screen.dart`, add a Goal Progress card above the session banner. Use a StreamBuilder or future to fetch the active goal and display progress without emojis.
4. **Sub-Task 3: Studio App - Trainer Goal Setup**
   - Create `lib/screens/members/trainer_set_goal_screen.dart` with Wellness & Balance theme.
   - Replicate the logic from the member app's screen but geared for a trainer setting it on behalf of a member.
   - Write to `memberGoals/{authUid}` setting `createdBy: 'trainer'`.
5. **Pre-commit Steps**
   - Complete pre-commit steps to ensure proper testing, verification, review, and reflection are done.
