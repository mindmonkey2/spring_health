1. **Explore the Trainer Dashboard:**
   - Review `trainer_dashboard_screen.dart` to see how the dashboard is laid out.
   - We need to add the requested sections (Quick Stats Row, My Assigned Members Card, Today's Sessions Card, Pending Trainer Feedback Card, Member AI Plan Quick Access) to the dashboard.
   - We will create a new tab "Home" as the first tab (index 0) and shift the other tabs over, or insert these sections into a scrollable area if there's an existing Home tab. Since there is currently no "Home" tab (Tab 1 is "My Clients"), we'll create a `_HomeTab` widget and add it as the first tab in `TrainerDashboardScreen`.

2. **Update the Navigation/Tabs in `TrainerDashboardScreen`:**
   - Update `_tabNotifier` logic to have 4 tabs instead of 3.
   - Update the `BottomNavigationBar` to include a "Home" item at the beginning.
   - Create a `_HomeTab` widget that will house all the new cards/sections requested.

3. **Build `_HomeTab` Components:**
   - **Section A (Quick Stats Row):**
     - Tile 1: Assigned Members (using `firestoreService.getMembersByTrainer(trainer.id)`).
     - Tile 2: Feedback Pending (querying `trainerFeedback` collection for `trainerId == trainer.id` where `trainerReply` is null or empty).
     - Tile 3: Sessions Today (using `firestoreService.getRecentCheckIns(trainer.branch)` or query attendance for today's date for `branch` if no trainerId field exists on attendance). Since `attendance` model only has `branch` and `memberId`, we will filter by today's date and branch.
   - **Section B (My Assigned Members Card):**
     - Show max 5 avatars from `getMembersByTrainer(trainer.id)`. On tap, navigate to `MembersListScreen(initialFilter: 'Active')`? No, we will just pass a parameter if there is one, or navigate to `MembersListScreen`. Since `MembersListScreen` doesn't have a trainer filter, we'll just navigate.
   - **Section C (Today's Sessions Card):**
     - Show today's check-ins for the branch (using `getRecentCheckIns(trainer.branch)` and filtering for today in memory or querying). We can use `firestoreService.getAttendanceByBranch(trainer.branch, DateTime.now())`.
   - **Section D (Pending Trainer Feedback Card):**
     - Query `trainerFeedback` where `trainerId == trainer.id`. Filter in memory or query where `trainerReply` is empty or null.
     - Add inline reply functionality using `setState` with a local map `_expandedFeedback`.
   - **Section E (Member AI Plan Quick Access):**
     - Take the last 3 assigned members. For each, show a `ListTile`. `onTap` navigates to `MemberAiPlanScreen(memberName: ..., memberDocId: ..., currentUserRole: 'Trainer')`.

4. **Verify Variables and Fields:**
   - Trainer auth uid vs Trainer Doc ID: We use `trainer.id` for queries (`trainerId` in `members` and `trainerFeedback`).
   - `MemberModel`: The field is `trainerId` (checked).
   - `TrainerFeedbackModel`: The reply field is `trainerReply` (checked).
   - `AttendanceModel`: There is no `trainerId` field, only `branch` and `memberId`. We fall back to branch-wide attendance for today.
   - Currency: Rs. ASCII only. No emojis. Theme: Wellness Balance (sage green/teal).

5. **Pre-commit Checks:**
   - Run `flutter analyze` in both apps to ensure 0 issues.
