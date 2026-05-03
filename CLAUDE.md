# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Structure

This is a monorepo containing two Flutter applications and Firebase backend:

- `spring_health_member_app/` — Member-facing mobile app (iOS, Android, Web)
- `spring_health_studio/` — Admin/Studio management app (iOS, Android, macOS, Web)
- Each app has a `functions/` subdirectory for Firebase Cloud Functions (Node.js)

## Commands

### Flutter Apps (run from within each app directory)

```bash
flutter pub get              # Install dependencies
flutter analyze              # Lint (should show 0 issues)
flutter test                 # Run all tests
flutter test test/path/to/test_file.dart  # Run single test file
flutter run -d <device>      # Run on device/emulator
flutter build apk            # Build Android APK
flutter build ios            # Build iOS
```

### Firebase Cloud Functions (run from `functions/` inside each app)

```bash
npm install
npm run lint
firebase emulators:start --only functions
firebase deploy --only functions
firebase functions:log
```

## Architecture

### Apps and Role Separation

- **Member App**: Used by gym members. Auth is phone OTP via Firebase Auth. Member identity is Firestore doc ID (`memberId`), not `auth.uid`.
- **Studio App**: Used by owners, receptionists, and trainers. Role-based routing in `main.dart` — each role gets its own dashboard screen.

### Firestore Data Model

Key collections:
- `members` — Base member records (source of truth for `memberId`)
- `users` — Studio staff only (NOT used for phone OTP members)
- `healthProfiles/{memberId}` — Member health data
- `bodyMetricsLogs/{memberId}/logs` — Time-series body metrics
- `wearableSnapshots/{memberId}/daily/{YYYY-MM-DD}` — Daily health snapshots from wearables
- `trainingSessions/{sessionId}` — Trainer-led session logs
- `memberGoals/{memberId}` — Fitness goals (4-step onboarding flow)
- `aiPlans/{memberId}/current` — AI-generated 7-day workout plans
- `dietPlans/{memberId}/current` — AI-generated 5-meal diet plans
- `gamification_events` — XP/badge event processing
- `weeklywars/{warId}/entries/{memberId}` — Team battle entries

**Identity rule**: `MemberModel.id` = Firestore doc ID = `memberId`. Auth UID is stored separately and never used as a Firestore document ID for members.

### Service Layer

- Singleton pattern: `static final _instance = MyService._(); factory MyService() => _instance;`
- `FirestoreService` is the central read/write hub in both apps
- AI calls use Firebase AI (Gemini 2.0 Flash) with 24-hour caching to avoid redundant calls
- Safety gates (BP crisis, cardiac event, fever) are rule-based checks that run before any AI call

### Data Models

- All models use `fromMap(Map<String, dynamic> data, String id)` — **not** `fromFirestore`
- All models have `toMap()` for serialization
- Use `Equatable` + `copyWith` for immutability

### UI Patterns

- **Member App**: Dark neon theme — `#CDFF00` lime, teal accents, black background
- **Studio App**: Light theme — sage green and navy blue accents
- Real-time updates via `StreamBuilder` on Firestore streams
- Local state via `ValueNotifier` (timers, counters, form state)
- Both apps define their theme in `theme/` via `AppTheme.darkTheme` / `AppTheme.lightTheme`
- Asset paths are centralized in `core/constants/` (`AssetPaths` class)

### AI Integration

- Firebase AI SDK + Gemini 2.0 Flash
- Member App: `ai_coach_service.dart` — generates 7-day workout + 5-meal diet plans
- Studio App: `trainer_ajax_service.dart` — post-session summaries + readiness scoring
- All AI responses are cached for 24 hours

### Notifications

- FCM for push notifications; topic-based for announcements (`announcements_{branch}`)
- Local notifications for in-app alerts
- Cloud Functions trigger: `sendAnnouncementNotification` on Firestore write

### Cloud Functions (Node.js, Node 24)

- `sendInvoiceEmail` — PDF + membership card via Nodemailer/Gmail SMTP
- `sendExpiryReminderEmail` — Scheduled membership expiry reminders
- `sendAnnouncementNotification` — Triggered on Firestore announcement doc creation
- `sendPersonalNotification` — Staff-to-member direct push

## Testing

- Member app: 38 unit tests using `fake_cloud_firestore` for Firestore mocking
- Run `flutter analyze` in both apps before committing — both should show 0 issues
- No unit tests exist for Cloud Functions

## Debug Conventions

Debug prints use emoji prefixes for readability: `✅` success, `❌` error, `📢` notification, `🔒` auth, etc.
