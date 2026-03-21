# Spring Health Ecosystem - Project State Audit

## 1. IMPLEMENTED FEATURES
### Spring Health Studio (Admin App)
- **Auth**: Login
- **Dashboard**: Owner Dashboard, Receptionist Dashboard
- **Members Management**: Add, Edit, Detail, Rejoin, Collect Dues, Fitness Tab, List
- **Trainers Management**: Add, List, Detail, Dashboard
- **Financials**: Add Expense, Expenses List
- **Attendance**: QR Scanner, Attendance History
- **Communication/Engagement**: Announcements List/Create, Notifications Dashboard, Send Push Notification, Reminders Dashboard, Admin Gamification Dashboard
- **Analytics**: Analytics Dashboard, Reports Dashboard

### Spring Health Member App (Client App)
- **Auth**: Login, OTP Verification
- **Dashboard**: Main Screen, Home
- **Profile Management**: Profile, Membership Info
- **Fitness & Tracking**: Body Metrics, Fitness Dashboard, Workout Logger, Workout History, Workout Detail, Health Permission Screen
- **Engagement**: Gamification (Leaderboard, Personal Best, XP), Clash/War Screen, Announcements, Notifications
- **Trainers**: Trainer List, Trainer Feedback
- **Check-in/Attendance**: QR Check-in, Member Attendance
- **Payments & Lockout**: Payment History, Renewal, Renewal Confirmation, Membership Expired Lockout
- **Settings**: Settings UI scaffold (features pending)
- **Social**: Social UI placeholder (features pending)

## 2. SERVICES INVENTORY

### Spring Health Studio Services
- `admin_gamification_service.dart`: Manages manual gamification interventions and rewards for members.
- `announcement_service.dart`: Handles creating and fetching global or branch-specific announcements.
- `auth_service.dart`: Manages admin/receptionist authentication via Email/Password.
- `document_service.dart`: Provides generic document generation and management.
- `email_service.dart`: Handles sending transactional and marketing emails via SMTP.
- `fee_calculator.dart`: Calculates member dues, renewal fees, and applicable discounts.
- `firestore_service.dart`: Core database service providing generic CRUD operations and queries.
- `member_fitness_service.dart`: Manages and tracks member fitness progress, goals, and metrics.
- `notification_service.dart`: Handles push notifications creation and delivery to members.
- `pdf_service.dart`: Generates PDF receipts and reports using the printing package.
- `reminder_service.dart`: Schedules and manages automated reminders for dues and events.
- `storage_service.dart`: Handles uploading and managing media (like profile photos) in Firebase Storage.
- `trainer_feedback_service.dart`: Manages feedback and ratings given to trainers by members.
- `whatsapp_service.dart`: Integrates with WhatsApp APIs for member communication.

### Spring Health Member App Services
- `announcement_service.dart`: Fetches and caches current gym announcements.
- `attendance_service.dart`: Logs and retrieves the member's gym attendance history.
- `badge_service.dart`: Evaluates criteria and awards milestone badges to members.
- `body_metrics_service.dart`: Tracks and charts member body measurements over time.
- `challenge_service.dart`: Manages participation and progress tracking for gym-wide challenges.
- `firebase_auth_service.dart`: Singleton service for Firebase Phone Authentication and OTP handling.
- `firestore_service.dart`: Core database abstraction for all member data queries and updates.
- `gamification_service.dart`: Processes gamification_events queue and manages member XP, levels, and leaderboards.
- `health_service.dart`: Integrates with Health Connect to import step counts and activity data.
- `in_app_notification_service.dart`: Manages local in-app alerts and message inbox.
- `member_service.dart`: Manages the current user's profile and membership status.
- `membership_alert_service.dart`: Checks membership expiry and triggers UI lockouts or warnings.
- `notification_service.dart`: Handles receiving FCM push notifications.
- `payment_service.dart`: Retrieves the member's payment and transaction history.
- `personal_best_service.dart`: Tracks and records personal records (PRs) for various exercises.
- `renewal_service.dart`: Initiates membership renewal flows and integrates with Razorpay.
- `storage_service.dart`: Handles member profile photo uploads to Firebase Storage.
- `trainer_feedback_service.dart`: Allows members to submit and review feedback for their trainers.
- `trainer_service.dart`: Fetches available trainers and handles assignment details.
- `weekly_war_service.dart`: Manages weekly head-to-head member clashes and score tracking.
- `workout_service.dart`: Handles logging, history, and detail views of user workouts.

## 3. SCREENS INVENTORY

### Spring Health Studio Screens
- `analytics/analytics_dashboard.dart`
- `announcements/announcements_list_screen.dart`
- `announcements/create_announcement_screen.dart`
- `attendance/attendance_history_screen.dart`
- `attendance/qr_scanner_screen.dart`
- `auth/login_screen.dart`
- `expenses/add_expense_screen.dart`
- `expenses/expenses_screen.dart`
- `gamification/admin_gamification_dashboard_screen.dart`
- `members/add_member_screen.dart`
- `members/collect_dues_screen.dart`
- `members/edit_member_screen.dart`
- `members/member_detail_screen.dart`
- `members/member_fitness_tab.dart`
- `members/members_list_screen.dart`
- `members/rejoin_member_screen.dart`
- `notifications/notifications_dashboard.dart`
- `notifications/notifications_screen.dart`
- `notifications/send_push_notification_screen.dart`
- `owner/owner_dashboard.dart`
- `owner/owner_dashboard_web.dart`
- `receptionist/receptionist_dashboard.dart`
- `receptionist/receptionist_dashboard_web.dart`
- `reminders/reminders_dashboard.dart`
- `reports/reports_screen.dart`
- `trainers/add_trainer_screen.dart`
- `trainers/trainer_dashboard_screen.dart`
- `trainers/trainer_detail_screen.dart`
- `trainers/trainers_list_screen.dart`

### Spring Health Member App Screens
- `announcements/announcements_screen.dart`
- `attendance/member_attendance_screen.dart`
- `auth/login_screen.dart`
- `auth/otp_verification_screen.dart`
- `checkin/qr_checkin_screen.dart`
- `clash/war_screen.dart`
- `fitness/body_metrics_screen.dart`
- `fitness/fitness_dashboard_screen.dart`
- `fitness/health_permission_screen.dart`
- `fitness/widgets/fitness_chart_widget.dart`
- `fitness/widgets/stats_card_widget.dart`
- `fitness/widgets/weekly_chart_widget.dart`
- `fitness/widgets/workout_card_widget.dart`
- `gamification/leaderboard_screen.dart`
- `gamification/personal_best_screen.dart`
- `gamification/xp_screen.dart`
- `home/home_screen.dart`
- `home/widgets/membership_card_widget.dart`
- `home/widgets/membership_expiry_banner.dart`
- `home/widgets/stats_overview_widget.dart`
- `lockout/membership_expired_screen.dart`
- `main_screen.dart`
- `notifications/notifications_screen.dart`
- `notifications/widgets/notification_tile.dart`
- `payments/payment_history_screen.dart`
- `profile/profile_screen.dart`
- `profile/widgets/membership_info_card.dart`
- `profile/widgets/profile_header_widget.dart`
- `profile/widgets/settings_tile_widget.dart`
- `renewal/renewal_confirmation_screen.dart`
- `renewal/renewal_screen.dart`
- `settings/settings_screen.dart`
- `social/social_coming_soon_screen.dart`
- `splash/splash_screen.dart`
- `trainers/trainer_feedback_screen.dart`
- `trainers/trainer_screen.dart`
- `workout/workout_detail_screen.dart`
- `workout/workout_history_screen.dart`
- `workout/workout_logger_screen.dart`

## 4. KNOWN RULES
- FirebaseAuthService is singleton — always use .instance
- minSdkVersion is 26 (driven by Health Connect)
- Never store gamification state on MemberModel
- Firebase Storage rules wildcards capture full filename including extension
- flutter_secure_storage requires minSdk 23+ (satisfied by 26)
- FlutterSecureStorage instance declared once as _secureStorage — never instantiate const FlutterSecureStorage() inline
- pubspec.yaml must never have duplicate dependency keys
- Always run flutter clean after merge/rebase before building
- gamification_events collection is write-only from Studio — member app GamificationService is the sole processor
- All loyalty processEvent() calls must be idempotent

## 5. PENDING / ROADMAP
- **Class Booking**: UI alert "Class Booking — Coming Soon! 🗓️" found in `home_screen.dart`.
- **Social Flex Zone**: UI placeholder "COMING SOON" found in `social_coming_soon_screen.dart`.
- **Edit Profile**: Stubbed with a "Coming soon!" snackbar in `profile_screen.dart`.
- **Trainer Additional Features**: A "Coming Soon" sub-label exists in `trainer_screen.dart`.
- **Settings Features**: Generic features stubbed with "Coming soon!" snackbar in `settings_screen.dart`.
- **Diet Plan**: Trainer dashboard indicates "Diet plan for [client.name] — Coming soon!" in `trainer_dashboard_screen.dart`.
- **Export Data Feature**: Export feature indicated as coming soon via snackbar in `members_list_screen.dart`.

## 6. ARCHITECTURAL HEALTH

Evaluating adherence to the directives outlined in `AGENTS.md`:

- **State Management & ValueNotifier (`AGENTS.md` 4)**: The directive strictly prohibits calling `setState()` at the root of complex widget trees and enforces the use of `ValueNotifier` for temporal state/animations.
  - *Current Status*: A grep analysis shows `ValueNotifier` is being correctly utilized in some areas, specifically `spring_health_member_app/lib/screens/clash/clash_screen.dart` indicating `// ✅ FIX: ValueNotifier so only the countdown Text rebuilds, not the whole screen`. However, there are still hundreds of `setState` calls scattered throughout both the Member App and the Studio Admin App, spanning dashboards, list screens, and authentication flows, which may not strictly adhere to the isolation requirement or might be functioning at root levels.
- **Strict Code Generation Rules (`AGENTS.md` 3)**: Code MUST pass `flutter analyze` with 0 errors and 0 warnings.
  - *Current Status*: Both apps currently pass `flutter analyze` with 0 issues after resolving dependency issues and running `flutter pub get`.
- **Deprecations/Print Statements**: Did not deeply verify all occurrences, but given the severe compilation errors, the general health of the codebase requires an immediate dependency resolution and code correction pass.

## 7. LAST UPDATED
March 21, 2026
