# Spring Health Ecosystem - Project State Audit

## 1. Implemented Features

### Spring Health Studio (Admin App)
**Path**: `/spring_health_studio/lib/`
- **UI Screens**:
  - **Auth**: Login Screen (`screens/auth/login_screen.dart`).
  - **Dashboard**: Owner Dashboard & Web (`screens/owner/`), Receptionist Dashboard & Web (`screens/receptionist/`).
  - **Members Management**: Add, Edit, Detail, Rejoin, Collect Dues, Fitness Tab (`screens/members/`).
  - **Trainers Management**: Add, List, Detail (`screens/trainers/`).
  - **Financials**: Add Expense, Expenses List (`screens/expenses/`).
  - **Attendance**: QR Scanner, Attendance History (`screens/attendance/`).
  - **Communication/Engagement**: Announcements (`screens/announcements/`), Notifications Dashboard/Push (`screens/notifications/`), Reminders Dashboard (`screens/reminders/`), Admin Gamification Dashboard (`screens/gamification/`).
  - **Analytics**: Reports, Analytics Dashboard (`screens/analytics/`, `screens/reports/`).
- **Backend Services**:
  - Admin Gamification (`admin_gamification_service.dart`)
  - Announcements (`announcement_service.dart`)
  - Authentication (`auth_service.dart`)
  - Document & PDF Generation (`document_service.dart`, `pdf_service.dart`)
  - Email & WhatsApp (`email_service.dart`, `whatsapp_service.dart`)
  - Fee Calculation (`fee_calculator.dart`)
  - Firestore integration (`firestore_service.dart`)
  - Member Fitness (`member_fitness_service.dart`)
  - Notification & Reminder (`notification_service.dart`, `reminder_service.dart`)
  - Storage (`storage_service.dart`)
  - Trainer Feedback (`trainer_feedback_service.dart`)

### Spring Health Member App (Client App)
**Path**: `/spring_health_member_app/lib/`
- **UI Screens**:
  - **Auth**: Login, OTP Verification (`screens/auth/`).
  - **Dashboard**: Main Screen, Home (`screens/home/`), Settings (`screens/settings/`).
  - **Profile Management**: Profile, Membership Info, Settings Tile (`screens/profile/`).
  - **Fitness & Tracking**: Body Metrics, Fitness Dashboard, Workout Logger, History, Detail (`screens/fitness/`, `screens/workout/`). Health Profile Screen (HealthProfileModel with BP classification and BMI calculation, BodyMetricsLogModel for time-series metrics tracking, FitnessTestModel with 8-test battery and auto-derived fitness level, HealthProfileScreen with two tabs, BP warning system, Trend charts).
  - **Engagement**: Gamification (Leaderboard, XP) (`screens/gamification/`), Clash Wars (Weekly Wars UI, 3-tabs, WeeklyWarModel, WeeklyWarService) (`screens/war/war_screen.dart`), Announcements (`screens/announcements/`), Notifications (`screens/notifications/`), Social Coming Soon (`screens/social/`).
  - **Phase 3 — AI Personal Trainer Engine**:
    - WearableSnapshotModel: full daily wearable data snapshot with auto-derived recoveryStatus and sleepQuality
    - WearableSnapshotService: reads 25 health data types from Health Connect / HealthKit, writes daily snapshot to Firestore, auto-updates HealthProfileModel with latest vitals
    - AiCoachService: Gemini 2.0 Flash integration via firebase_ai, reads full wearable + health + fitness context, generates 7-day workout plans and 5-meal Indian diet plans
    - Three-tier safety gate: BP crisis / cardiac event / fever all blocked before Gemini call (rule-based, never AI)
    - 24-hour plan cache: prevents redundant Gemini calls
    - syncWearablesAndGenerate: convenience method for refresh flow
    - Auto wearable sync on every app open (silent, non-blocking)
  - **Trainers**: Trainer List, Feedback (`screens/trainers/`).
  - **Check-in/Attendance**: QR Check-in, Member Attendance (`screens/checkin/`, `screens/attendance/`).
  - **Payments & Lockout**: Payment History, Renewal, Membership Expired Lockout (`screens/payments/`, `screens/renewal/`, `screens/lockout/`).
- **Backend Services**:
  - Announcements (`announcement_service.dart`)
  - Attendance (`attendance_service.dart`)
  - Body Metrics & Health (`body_metrics_service.dart`, `health_service.dart`, `health_profile_service.dart`)
  - Challenges & Gamification (`challenge_service.dart`, `gamification_service.dart`)
  - Firebase Auth (`firebase_auth_service.dart`)
  - Firestore (`firestore_service.dart`)
  - Membership & Renewal (`membership_alert_service.dart`, `renewal_service.dart`)
  - Notifications (`notification_service.dart`, `in_app_notification_service.dart`)
  - Payments (`payment_service.dart`)
  - Trainer & Feedback (`trainer_service.dart`, `trainer_feedback_service.dart`)
  - Workouts (`workout_service.dart`)

## 2. Active Firestore Schema

Mapped from `services/` across both applications:
- `announcements`
- `attendance`
- `challengeEntries`
- `challenges`
- `daily`
- `dietPlans`
- `expenses`
- `fcmTokens`
- `feedback`
- `fitnessData`
- `healthProfiles/{memberId}`           — current health profile and goals
- `bodyMetricsLogs/{memberId}/logs/`    — time-series metrics history
- `fitnessTests/{memberId}/tests/`      — fitness test battery results
- `gamification`
- `wearableSnapshots/{memberId}/daily/{YYYY-MM-DD}` — daily wearable data snapshots
- `aiPlans/{memberId}/current`          — active AI workout plan (7 days)
- `dietPlans/{memberId}/current`        — active AI diet plan (5 meals)
- `items`
- `memberAlerts`
- `members`
- `notifications`
- `payments`
- `reminder_logs`
- `sessions`
- `trainerFeedback`
- `trainers`
- `users`
- `workouts`
- `weeklywars/{warId}`
- `weeklywars/{warId}/entries/{memberId}`
- `gamification_events`

## 3. Pending/Stubbed Features

Resolved in Thread 12:
  ✓ CSV Export (Admin members list) — T11 carry-forward, done Thread 12
  ✓ RPE scale corrected to 1–10 (was 1–5 — audit-discovered bug)
  ✓ AI Coach nav wired — main_screen.dart SizedBox() removed
  ✓ Firestore rules: 5 uncovered collections now secured + aiPlans
    trainer write scope hardened
  ✓ Privacy Policy + ToS — url_launcher live (springhealthapp.in)
  ✓ member_ai_plan_screen.dart — Trainer Override screen (T11 carry-forward)
Resolved in Thread 13:
  ✓ T1 GamificationService.processEvent single XP entry point,
    BadgeService 11 badges, loyalty hooks Thread 13
  ✓ T2 WeeklyWarModel + WarEntryModel + WeeklyWarService
    6 methods, 7-week schedule Thread 13
  ✓ T3 WarScreen 3-tab UI THIS WEEK / 1v1 DUELS / HISTORY Thread 13
  ✓ T4 Studio WarAdminScreen + Weekly Wars tile in
    AdminGamificationDashboardScreen Thread 13
  ✓ T5 WorkoutLogger → WeeklyWarService.recordWorkoutEntry
    per exercise Thread 13

Resolved in Thread 13_2:
  ✓ Thread 13_2 — Firestore schema:
    4 new collections added to studio app:
    memberGoals/{memberAuthUid}, trainingSessions/{sessionId},
    memberIntelligence/{memberAuthUid}, gymEquipment/{branch}.
    4 new models: MemberGoalModel, TrainingSessionModel,
    MemberIntelligenceModel, GymEquipmentModel.
    All use fromMap(data, id) pattern. No fromFirestore.
    firebase_ai: ^2.2.0 added to studio pubspec only.
    Firestore rules deployed for all 4 collections.

  ✓ MemberModel has no auth UID field (Thread 13_2):
    MemberModel.id = Firestore document ID only.
    No uid, userId, authUid, firebaseUid field exists.
    Auth UID is stored in trainingSessions.memberAuthUid.
    All writes to memberGoals, memberIntelligence,
    notifications, workouts must use
    sessionData['memberAuthUid'] — not member.id.

  ✓ Thread 13_2 — AjAX trainer loop complete:
    Studio app received full trainer session flow:
    FlexibilityAssessmentScreen (7-test, first session only),
    TrainerScanScreen (QR + attendance + parallel data fetch
    + readiness score computed locally, default 70, clamp 0-100),
    TrainerReadinessScreen (4 info cards + trainer input form
    + gymEquipment chips + session doc create),
    TrainerAjaxService (firebase_ai Gemini 2.0 Flash,
    responseMimeType json, temperature 0.4),
    TrainerWarmupScreen (ValueNotifier countdown, 3 plan cards,
    AjAX recommended badge by readiness score),
    TrainerSessionScreen (ValueNotifier elapsed timer,
    transaction-based set logging, end session writes to
    workouts + memberIntelligence + memberGoals + notifications).
    Member app: MemberSessionScreen (Neon Dark, StreamBuilder
    on trainingSessions, goal insight card, log set bottom sheet,
    nutrition card on complete).
    Equipment Manager: OwnerDashboard quick action,
    gymEquipment Firestore read/write with merge.
    Member Goal: MemberGoalScreen 4-step flow,
    home screen goal progress card, trainer dashboard chips,
    shared GoalSetSheet widget.
    flutter analyze 0 issues both apps.

Resolved in Thread 15 (System Health Fixes):
  ✓ auth.uid replaced with memberId in rpe_service, member_goal_screen,
    fitness_dashboard_screen, home_screen Thread 15
  ✓ FCM token registration wired in main_screen.dart Thread 15
  ✓ Gemini model updated to gemini-2.5-flash-preview-04-17 Thread 15
  ✓ personal_best_service processEvent routing Thread 15
  ✓ AnnouncementModel targetBranches + createdByUid fields Thread 15
  ✓ WeeklyWarModel.fromMap date parsing fixed, 4 tests resolved Thread 15
  ✓ Member app tests: 38/38 passing Thread 15

STILL PENDING:
  - Class Booking / Scheduling
  - Razorpay (do not start without payment contract)
  - Social Flex Zone (social_coming_soon_screen.dart)
  - Trainer App (springhealthtrainer) — not started

## 4. Testing & Coverage
- **Model Tests**:
  - `spring_health_member_app/test/models/fitness_stats_model_test.dart`: Unit tests for `WorkoutType.fromString` covering all keywords, case-insensitivity, and default cases. (Verified via standalone logic test due to environment restrictions).

## 5. Architectural Health
## 5. Architectural Health

Evaluating adherence to the directives outlined in `AGENTS.md`:

- **State Management & ValueNotifier (`AGENTS.md` 4)**: The directive strictly prohibits calling `setState()` at the root of complex widget trees and enforces the use of `ValueNotifier` for temporal state/animations.
  - *Current Status*: A grep analysis shows `ValueNotifier` is being correctly utilized in some areas, specifically `spring_health_member_app/lib/screens/clash/clash_screen.dart` indicating `// ✅ FIX: ValueNotifier so only the countdown Text rebuilds, not the whole screen`. However, there are still hundreds of `setState` calls scattered throughout both the Member App and the Studio Admin App, spanning dashboards, list screens, and authentication flows, which may not strictly adhere to the isolation requirement or might be functioning at root levels.
- **Strict Code Generation Rules (`AGENTS.md` 3)**: Code MUST pass `flutter analyze` with 0 errors and 0 warnings.
  - *Current Status*: `flutter analyze`: Both apps at 0 issues as of April 2026.
    Member app test suite: 38/38 passing.
    Studio app test suite: 28/28 passing.
- **Deprecations/Print Statements**: Did not deeply verify all occurrences, but given the severe compilation errors, the general health of the codebase requires an immediate dependency resolution and code correction pass.

## 6. Known Rules
- **Member IDs in Health Collections**: `memberId` in `healthProfiles`, `bodyMetricsLogs`, and `fitnessTests` collections is the Firebase Auth UID (not Firestore member doc ID). Verify via `FirebaseAuthService.instance.currentUser.uid`.
- **BP Warnings**: BP Stage 2 or Crisis must always show a non-dismissible warning.
- **BMI Calculation**: BMI is always auto-calculated — never stored as a raw input field.
- **WearableSnapshotService must NEVER block app startup**: Always call from Future.microtask() or compute()
- **Three conditions block Gemini entirely (never adjust)**: BP > 180/120, irregular heart rate event, body temp > 37.5°C
- **All other health flags (Stage 1/2 HTN, low HRV, poor sleep)**: are passed to Gemini as context — AI adjusts the plan
- **responseMimeType: 'application/json' is mandatory in GenerationConfig**: Without it, Gemini may return markdown-wrapped JSON that breaks jsonDecode()
- **temperature: 0.4**: keep low for medical/fitness context; higher temperature causes hallucinated exercise names
- **WearableSnapshotService.syncTodaySnapshot() also updates HealthProfileModel**: do not manually update BP/weight/RHR from wearables elsewhere, let the service handle it
- **firebase_ai package version must stay in sync with firebase_core**: Check pub.dev for compatible versions before updating

## 7. Known Pitfalls and Rules

  16. Firestore rules deploy may silently skip upload
      if CLI detects no file change on disk.
      Always verify rules are live via Firebase Console
      after deploy. If "already up to date, skipping" —
      open Console → Firestore → Rules and compare
      manually. Use firebase firestore:rules:release
      or paste directly in Console to force update.

  17. Never delete live Firestore indexes via CLI prompt.
      When firebase deploy asks "Would you like to delete
      these indexes?" — always answer NO.
      Add missing indexes to firestore.indexes.json
      instead of deleting live ones.

  18. Member document lookup pattern:
      The Member App looks up a member's document by first finding the `member_id` from the current user's document in the `users` collection. It then looks up the `members` collection using that `member_id` as the document ID. The `user_id` field on the member document links back to the Firebase Auth `uid`. This is a critical architectural rule — must match exactly what Studio writes when creating members.


  19. MemberModel.id is Firestore doc ID not auth UID.
      Never use member.uid or member.userId — field does not exist.
      Auth UID for Firestore writes comes from
      trainingSessions.memberAuthUid (in session screens) or
      from the QR scan fetch (in scan screen).