# Spring Health Applications — Engineering Memory Document
**Last Updated:** March 25, 2026
**Admin App:** 92% (49/53 features) | **Member App:** 82% (all core flows + AI Phase 3)

---

## Table of Contents
1. [System Architecture](#1-system-architecture)
2. [Admin App — Spring Health Studio](#2-admin-app--spring-health-studio)
3. [Member App — Spring Health Member App](#3-member-app--spring-health-member-app)
4. [Cross-App Feature Mapping](#4-cross-app-feature-mapping)
5. [Firebase Configuration](#5-firebase-configuration)
6. [Project Completion Snapshot](#6-project-completion-snapshot)
7. [Known Pitfalls and Rules — DO NOT REGRESS](#7-known-pitfalls-and-rules--do-not-regress)
8. [How to Use This Document](#8-how-to-use-this-document)

---

## 1. System Architecture

### 1.1 High-Level Ecosystem

- **Shared Backend:** Single Firebase project `spring-health-studio-f4930`
  - Firestore, Authentication, Storage, FCM
- **Admin App:** `spring_health_studio` — Email/password login, role-based (Owner/Receptionist/Trainer)
- **Member App:** `spring_health_member_app` — Phone OTP login, member-facing features
- **Trainer App:** Roadmap only — not yet started

### 1.2 Role and App Boundaries

| Role | App | Access |
|---|---|---|
| Owner | Studio | All branches, revenue, analytics, reminders, trainer/diet mgmt, clash wars |
| Receptionist | Studio | Branch-specific member mgmt, check-ins, payment collection, dues tracking |
| Trainer | Studio | Assigned members read-only, own profile update |
| Member | Member App | Own membership, workouts, attendance, gamification, announcements |

### 1.3 CRITICAL — Role Casing in Firestore

**Firestore `users/{uid}` documents store roles with Title Case:**
```
role: "Owner"        ← capital O
role: "Receptionist" ← capital R
role: "Trainer"      ← capital T
role: "Member"       ← capital M
```

**Firestore rules must match this casing exactly:**
```javascript
function isOwner() {
  return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'Owner';
}
```
**Never use lowercase `'owner'` in rules — it will deny all admin access.**
Fixed: March 25, 2026

### 1.4 CRITICAL — Member App Has No `users` Collection Document

Member app users authenticate via **Phone OTP** — they are never written to the `users` collection.
The `users` collection is **Admin app only** (email/password login).

Consequence for Firestore rules:
- `isMember()` function (which reads `users/{uid}`) will **always return false** for phone OTP users
- Member app rules must use `isSignedIn()` + `isOwnRecord()` instead of `isMember()`
- `isOwnRecord()` checks `uid`, `memberId`, or `user_id` fields on the document

```javascript
// WRONG for member app — isMember() always false for phone OTP users
allow read: if isMember() && isOwnRecord(resource.data);

// CORRECT for member app
allow read: if isSignedIn() && isOwnRecord(resource.data);
```
Fixed: March 25, 2026

### 1.5 Core Firestore Collections

**Admin-managed:**
`users`, `members`, `attendance`, `payments`, `trainers`, `announcements`,
`expenses`, `reminder_logs`, `trainerFeedback`, `challenges`, `challengeEntries`,
`gamificationEvents`, `fcmTokens`, `notifications`, `notificationHistory`

**Member-managed:**
`workouts`, `gamification`, `personal_bests`, `sessions`, `fitnessData`,
`bodyMetrics`, `dietPlans`

**AI / Health (Phase 1–3):**
`healthProfiles`, `aiPlans/{memberId}/current`, `wearableSnapshots/{memberId}/daily/{date}`,
`bodyMetricsLogs/{memberId}/logs`, `fitnessTests/{memberId}/tests`

### 1.6 MemberModel Final Shape

**Identity:** `id`, `name`, `phone`, `email` (nullable), `dateOfBirth` (nullable), `photoUrl` (nullable)
**Branch:** `branch`, `branchName` (field is `branch` not `branchId`)
**Membership:** `plan` (1m/3m/6m/1y), `category` (standard/premium), `joiningDate`, `expiryDate`
**Payments:** `totalFee`, `discount`, `finalAmount`, `cashAmount`, `upiAmount`, `dueAmount`, `paymentMode` (cash/upi/mixed)
**Status:** `isActive` (derived from expiry), `nearExpiry` (3-day window), `isArchived`, `loyaltyMilestonesAwarded` (List<String>)
**Admin:** `lastCheckInTime`, `createdAt`, `updatedAt`

**Business Rules:**
- `isActive`: `expiryDate > now`
- `nearExpiry`: `expiryDate < now + 3 days`
- Mixed payment: `cashAmount + upiAmount == finalAmount`
- QR code generated per member for check-in

---

## 2. Admin App — Spring Health Studio

### 2.1 Tech Stack

```yaml
dependencies:
  firebase_core, firebase_auth, cloud_firestore
  intl, qr_flutter, mobile_scanner
  pdf, printing, path_provider, share_plus, mailer
  url_launcher
```

**Build config:** AGP 8.9.1, Gradle 8.10.2, Kotlin 2.1.0, compileSdk/targetSdk 35, minSdk 26

### 2.2 Core Screens

1. **Auth** — Email/password login with role lookup, rotating gym logo animation
2. **Owner Dashboard** — Branch selector, this-month revenue, branch-wise stats, quick actions, reminders badges
3. **Receptionist Dashboard** — Per-branch metrics, Members, QR scanner, Reports access
4. **Member Management** — List, Add, Edit/Renew, Detail, Archive/Restore, Collect Dues
5. **QR Attendance** — MobileScanner, duplicate prevention, manual phone lookup
6. **Reports** — Members (All/Active/Expired/NearExpiry/PendingDues), Revenue, Payments, Attendance — PDF + Excel export
7. **Reminders Dashboard** — Dues, Expiring (3-day/1-day), Birthdays, Templates — WhatsApp deep links
8. **Announcements Manager** — Create branch-targeted or global, FCM topic publish
9. **Trainers Manager** — Assign trainers to members
10. **Diet Plans Manager** — Configure diet plans linked to members
11. **Clash Wars Manager** — Configure fitness challenges with XP rewards

### 2.3 Key Implemented Features (49/53)

1. Email-password authentication with role lookup
2. Owner Dashboard with branch filter, revenue, stats, reminders badges
3. Receptionist Dashboard with per-branch metrics
4. Member List, Add, Edit, Renew, Detail screens
5. Member archive/restore workflow
6. QR attendance scanning with duplicate prevention (`hasCheckedInToday` guard)
7. Manual attendance lookup by phone
8. Attendance history per member
9. Payment recording (initial/dues/renewal)
10. Mixed payment mode (cash/UPI split)
11. Revenue analytics by month and branch
12. Members report (All/Active/Expired/NearExpiry/PendingDues)
13. Revenue report with monthly breakdown
14. Payments report by type and mode
15. Attendance report by date range
16. PDF export for all report types
17. Membership card generation with QR code
18. Membership card PDF export
19. Membership card WhatsApp share with deep link
20. Membership card email share
21. Collect Dues screen with payment recording
22. Dues reminders via WhatsApp
23. Expiry alerts (3-day and 1-day windows) via WhatsApp
24. Birthday wishes via WhatsApp
25. Reminders Dashboard (Dues/Expiring/Birthdays/Templates tabs)
26. Bulk WhatsApp reminder send
27. Individual member reminder targeting
28. Announcements manager (create branch/global)
29. Announcements sync to member app via Firestore
30. FCM topic publishing for announcements
31. Trainer manager screen
32. Diet plan manager screen
33. Clash Wars configuration
34. Clash Wars leaderboard sync to member app
35. Gamification event bridge (loyalty3m/6m/1y)
36. Profile photo upload to Storage (fixed March 2026)
37. Payment invoice generation (generateInvoiceNewJoinings, generatePaymentReceipt)
38. Payment receipt as PDF per transaction
39. Excel/CSV export for reports
40. Scheduled daily reminders (runDailyReminders with ExpiryReminderResult)
41. Automated reminder execution
42. QR scanner duplicate check-in prevention
43. QR scanner hang fix (isProcessing reset, resetScanner helper)
44. QR scanner re-entrant onDetect fix (scannerController.stop before async)
45. Wellness & Balance theme on dashboards
46. `Rs.` ASCII in PDFs instead of ₹ (glyph issue fix)
47. Model factory alignment (fromMap consolidation)
48. Null-safe ReminderService with DOB handling
49. APK build fixes (Gradle 8.6→8.9.1, AGP, Kotlin 2.1.0)

**Remaining High-Priority:**
- Online payment gateway (Razorpay) for member renewals
- In-app trainer chat or structured workout feedback
- Trainer commission calculation and tracking
- Email-based daily/weekly summary reports
- Advanced analytics (charts, filters, trends)

### 2.4 Major Bug Fixes History

**Thread 6 (March 2026):**
1. Revenue month label hardcoded → `getMonthName(DateTime.now().month, DateTime.now().year)`
2. `fromFirestore` vs `fromMap` mismatch → consolidated to `fromMap(map, id)` everywhere
3. Rupee symbol in PDFs → `Rs.` ASCII string
4. APK build failures → AGP 8.9.1 + Gradle 8.10.2 + Kotlin 2.1.0
5. ReminderService nullable DOB → hardened with null-safe filters

**Thread 7 (March 2026):**
6. QR scanner no duplicate guard → `hasCheckedInToday(memberId, branch)`
7. QR scanner hang → `resetScanner` helper, `barrierDismissible: false`
8. QR scanner re-entrant onDetect → `await scannerController.stop()` as first line

**Thread 9 (March 2026):**
9. Gamification event bridge → Studio fires `gamificationEvents`, member app processes with idempotency
10. Profile photo upload → Storage rules wildcard fixed to match `memberPhotos/{uid}.jpg`

---

## 3. Member App — Spring Health Member App

### 3.1 Tech Stack

```yaml
dependencies:
  firebase_core, firebase_auth, cloud_firestore, firebase_messaging, firebase_storage
  flutter_secure_storage, pinput, flutter_animate, fl_chart
  lottie, cached_network_image, timeago, url_launcher
  health (Health Connect), permission_handler
```

**Build config:** minSdk 26 (Health Connect requirement), compileSdk/targetSdk 35

### 3.2 Authentication Architecture

- **Phone OTP** via `FirebaseAuthService.instance` singleton
- `FlutterSecureStorage` for `verificationId` persistence (not SharedPreferences)
- `currentVerificationId` state in OTP screen, updated on resend + timeout
- `verifyOTP(verificationId)` accepts explicit parameter — never reads from storage alone
- Auto-verification on Android via `verificationCompleted` callback
- **NEVER creates a `users/{uid}` document** — member identity lives in `members` collection only

### 3.3 Member Lookup Pattern

```dart
// Member lookup by document ID (document ID = admin-assigned ID, NOT auth UID)
// Step 1: Find member by phone number during login
FirebaseFirestore.instance
  .collection('members')
  .where('phone', isEqualTo: '+91XXXXXXXXXX')
  .limit(1)
  .get()

// Step 2: Store member document ID (NOT auth UID) as memberId
// Step 3: All subsequent calls use memberId (the Firestore doc ID)
FirebaseFirestore.instance
  .collection('members')
  .doc(memberId)   // ← this is the Firestore document ID, not auth UID
  .get()
```

**`firebase_auth_service.dart` `checkMemberExists()`** looks up by phone,
returns `{'id': doc.id, ...data}` — the `id` is the Firestore document ID.

### 3.4 Implemented Features (55/55 core flows + AI Phase 1-3)

**Auth (Phase 1):**
1. Phone OTP authentication via FirebaseAuthService singleton
2. Local verificationId tracking (currentVerificationId state)
3. Secure verificationId persistence (FlutterSecureStorage)
4. OTP resend with verificationId update
5. Auto-verification on Android with proper sign-in

**Core UI (Phase 2):**
6. Splash screen with animated logo
7. Login screen with phone input validation
8. OTP Verification screen with Pinput code entry
9. Home screen — membership card (plan, expiry, status countdown)
10. Bottom navigation with 5 tabs

**Attendance (Phase 3):**
11. Attendance History with calendar heatmap
12. Attendance streak cards and calculations
13. Time-of-day attendance distribution chart

**Fitness & Workouts (Phase 4):**
14. Fitness Dashboard overview
15. Workout Logger with live timer
16. Workout Logger with set tracking
17. Workout Logger with calorie estimates
18. Workout History list with detail screens
19. Workout history charts and summaries

**Gamification (Phase 4):**
20. Gamification XP tracking
21. Gamification levels and badges
22. Loyalty milestones (3m/6m/1y) with processEvent idempotency
23. Leaderboard XP tab with podium view
24. Leaderboard Streak tab
25. Leaderboard Workouts tab
26. Leaderboard parallel Firestore fetches (performance optimized)

**Announcements (Phase 3):**
27. Announcements list with branch filtering
28. Announcements timeago formatting
29. Announcements read/unread state tracking (`readBy` array)
30. Announcements detail view with image

**Notifications (Phase 5):**
31. Notifications Center — XP tab
32. Notifications Center — Badges tab
33. Notifications Center — Gym tab
34. Notifications Center — All tab
35. Notifications Center unread badge on nav
36. Notifications Center swipe-to-dismiss / mark-as-read
37. FCM foreground message handler
38. FCM background message handler
39. FCM terminated state handling
40. In-app Notifications Center backed by Firestore (`notifications/{uid}/items`)
41. AppNotification model with InAppNotificationService CRUD
42. Global navigatorKey for deep-link navigation from notification taps

**Profile:**
43. Profile screen with member info
44. Profile screen logout

**Theme & Quality:**
45. Neon dark theme with glassmorphism
46. flutter_animate transitions on all screens
47. AnnouncementModel content getter (message aliasing)
48. AnnouncementModel isReadByMemberId helper
49. Attendance Model reuse with dedicated AttendanceService
50. Model factory alignment (fromMap consolidation)
51. flutter analyze 0 issues all checks passing
52. Secured OTP with FlutterSecureStorage v9
53. Android auto-verify with proper sign-in completion
54. Gamification event bridge integration
55. Loyalty milestone event processing from Studio

**AI Health Foundation — Phase 1 (March 2026):**
- HealthProfileModel, HealthProfileService, HealthProfileScreen
- FitnessTestModel — fitness test recording
- Firestore: `healthProfiles`, `fitnessTests`

**AI Health Foundation — Phase 2 (March 2026):**
- WearableSnapshotModel, WearableSnapshotService
- Health Connect integration (steps, heart rate, HRV, sleep, calories)
- AiCoachService, AiWorkoutPlanModel, AiDietPlanModel
- Firestore: `wearableSnapshots`, `aiPlans`, `dietPlans`

**Pending Features:**
- Online member renewal with Razorpay
- Enhanced trainer interaction (chat, feedback)
- Body measurements and progress photo tracking
- Class booking and scheduling
- Social/community features (feeds, friend leaderboards)
- AI Coach Screen UI (Phase 4 — submitted to Jules March 24, 2026)

---

## 4. Cross-App Feature Mapping

### 4.1 Data Flows (Studio → Member App)

| Flow | Admin Action | Firestore Write | Member Effect |
|---|---|---|---|
| Member onboarding | Add member with plan, branch, expiry | `members/{id}` | New membership card appears |
| Plan renewal | Rejoin expired member | Update `members/{id}`, add `payments`, fire `gamificationEvents` | New expiry + XP event |
| Payment collection | Record initial/dues/renewal | `payments` collection entry | Payment history updates |
| Attendance | Scan QR or manual check-in | `attendance` record | Heatmap + streaks refresh |
| Announcements | Create branch/global announcement | `announcements/{id}` + FCM topic | Push + in-app entry |
| Challenges | Configure challenge, XP rewards | `challenges/{id}` + `gamificationEvents` | Leaderboard + XP notifications |
| Trainer assignment | Assign trainer | `trainers/{trainerId}` linked to member | (Trainer app — future) |

### 4.2 Themes

**Admin App:** Wellness & Balance — sage green, teal gradients. PDFs retain purple-pink brand gradient.

**Member App:** Neon Dark:
```dart
backgroundBlack: Color(0xFF0A0A0A)
neonLime:        Color(0xFFC6F135)
neonTeal:        Color(0xFF00BFA5)
neonOrange:      Color(0xFFFF6D00)
```
Glassmorphism cards, flutter_animate transitions (300–500ms easing).

### 4.3 Shared Model Architecture

- All models use `fromMap(map, id)` — never `fromFirestore`
- Services always pass `doc.data()` + `doc.id` to `fromMap`
- Shared logic: expiry, near-expiry, payment calculations, branch isolation

---

## 5. Firebase Configuration

### 5.1 Project

- **Project ID:** `spring-health-studio-f4930`
- **Firebase console:** https://console.firebase.google.com/project/spring-health-studio-f4930

### 5.2 Firestore Rules — Critical Facts

1. Role values in `users` collection are **Title Case**: `'Owner'`, `'Receptionist'`, `'Trainer'`, `'Member'`
2. Rules must match exactly — `'owner'` ≠ `'Owner'`
3. Phone OTP members have **NO** `users` collection document — rules must NOT use `isMember()` for member-side reads
4. Member-side reads must use `isSignedIn() && isOwnRecord(resource.data)` pattern
5. `isOwnRecord()` checks three field names: `uid`, `memberId`, `user_id`

### 5.3 Firestore Indexes — Critical Facts

1. **Never say "Yes" to "Would you like to delete these indexes?"** during deploy — always `n`
2. Add all live indexes to `firestore.indexes.json` to suppress the prompt permanently
3. Field name `branch` (not `branchId`) in `members` and `attendance` collections
4. Field name `paymentDate` (not `createdAt`) in `payments` collection
5. Workout collection uses lowercase `memberid` (not `memberId`) in some documents
6. Do NOT add single-field subcollection indexes — causes 400 error on deploy

### 5.4 Firestore Rules Deploy Pitfall

If CLI says **"already up to date, skipping upload"** — the rules file on disk was not changed.
Fix: paste rules directly in Firebase Console → Firestore → Rules → Publish.
Then sync back: `firebase firestore:rules:get > firestore.rules`

### 5.5 Storage Rules

```
match /memberPhotos/{filename}
```
- Upload path in Dart must be `memberPhotos/{uid}.jpg` — exact match including extension
- Wildcard `{userId}` captures full filename including `.jpg` — must match `request.auth.uid` exactly
- Any path mismatch causes silent `No object exists at desired reference` error

---

## 6. Project Completion Snapshot

### 6.1 Admin App — 92% (49/53)

**Remaining:**
- Razorpay online payment gateway
- Trainer in-app chat / workout feedback
- Trainer commission calculation
- Email-based summary reports (daily/weekly)

### 6.2 Member App — 82%

**Remaining:**
- AI Coach Screen UI (Phase 4 — in Jules)
- Razorpay online renewal
- Trainer interaction
- Body measurements + progress photos
- Class booking / scheduling
- Social/community features

### 6.3 Trainer App — 0% (Roadmap)

Planned features: member list by branch, attendance marking, workout assignment, notes per member, commission tracking, schedule/timetable, announcements from admin.

---

## 7. Known Pitfalls and Rules — DO NOT REGRESS

### Critical Architectural Rules

**1. Never store gamification state on MemberModel**
- Gamification state (loyaltyMilestonesAwarded, XP counters, badges) lives exclusively in `gamification/{memberId}`
- Studio fires events to `gamificationEvents` collection — member app's GamificationService processes with idempotency guard
- All `processEvent` calls must check `loyaltyMilestonesAwarded` array before awarding, write back after
- Fixed: Thread 9

**2. FirebaseAuthService is a singleton — use `.instance`, never instantiate new**
- `static final FirebaseAuthService instance = FirebaseAuthService._internal()`
- Always: `FirebaseAuthService.instance`
- Creating `new FirebaseAuthService()` bypasses saved state (verificationId, resend token)
- Fixed: Thread 10

**3. Never rely solely on SharedPreferences for verificationId during active OTP session**
- Always pass `verificationId` explicitly to `verifyOTP()`
- Screen stores as `currentVerificationId` state, updated on resend and timeout
- SharedPreferences is fallback only, not primary source
- Fixed: Thread 7

**4. Firebase Storage paths must match exactly between Dart upload and Storage rules**
- `match /memberPhotos/{uid}.jpg` — captures filename including extension
- Upload path: `memberPhotos/${uid}.jpg` — no subfolder, exact extension
- Fixed: Thread 9

**5. QR Scanner lifecycle — always call `scannerController.stop()` before async work**
- First line of `handleQRCode()` after `isProcessing = true`: `await scannerController.stop()`
- Prevents re-entrant `onDetect` fires while dialogs are open
- Pair with `resetScanner()` after every dialog closes
- Set `barrierDismissible: false` on all scanner dialogs
- Fixed: Thread 7

**6. Always use `hasCheckedInToday` guard to prevent duplicate attendance records**
- Query `attendance` with start-of-day/end-of-day Timestamp range, `limit(1)`
- Check result before writing new attendance record
- Fixed: Thread 7

**7. Model factory pattern — use `fromMap(map, id)` exclusively, never `fromFirestore`**
- Services always pass `doc.data()` + `doc.id` to `fromMap`
- Fixed: Thread 6

**8. String interpolation in exported Dart files must avoid Python escaping**
- After export, verify `+91$phoneNumber` not `+91\$phoneNumber`
- Causes OTP verification failures if escaped incorrectly
- Fixed: Thread 7

**9. Unicode symbols in PDFs render as missing glyphs — use ASCII fallback**
- Never use `₹` in PDF templates — use `Rs.` instead
- Fixed: Thread 6

**10. minSdkVersion must stay at 26**
- Health Connect requires 26; FlutterSecureStorage requires 23 (26 satisfies both)
- Never downgrade below 26
- Fixed: Thread 10

**11. Never use `?? false` on `Vibration.hasVibrator()`**
- Returns non-nullable bool in current package version
- Analyzer warns dead code
- Fixed: Thread 7

**12. debugPrint with map access inside string interpolation causes analyzer issues**
- Extract to local variable first: `final name = data['name']; debugPrint('Name: $name')`
- Fixed: Thread 7

**13. Announcements `readBy` array — never use boolean `isRead` field**
- `readBy`: List<String> of memberIds who have read
- Compute `isNew` at screen layer: `!announcement.readBy.contains(currentMemberId)`
- Fixed: Thread 8

**14. Attendance, Announcements, Notifications — reuse existing shared collections**
- Do not create parallel minimal models — reuse rich existing models
- `AttendanceModel` already has check-in/out, duration, helpers (`isToday`, `isThisWeek`)
- Fixed: Thread 9

**15. Gamification event bridge — mark `processed: true` after firing**
- Events in `gamificationEvents` start with `processed: false`
- After `processEvent()` completes successfully, update to `processed: true`
- Prevents re-firing events on app restart
- Fixed: Thread 9

**16. Firestore rules deploy may silently skip upload**
- If CLI shows "already up to date, skipping" — rules file on disk was not actually changed
- Always verify rules are live via Firebase Console after deploy
- Force update: paste directly in Console → Firestore → Rules → Publish
- Then sync: `firebase firestore:rules:get > firestore.rules`
- Fixed: March 25, 2026

**17. Never delete live Firestore indexes via CLI prompt**
- When `firebase deploy` asks "Would you like to delete these indexes?" — always answer **No**
- Add missing indexes to `firestore.indexes.json` instead of deleting live ones
- Fixed: March 25, 2026

**18. Member document lookup uses Firestore document ID, not Firebase Auth UID**
- Admin creates member doc with auto/custom ID — this becomes `memberId`
- Member app login: look up by phone → get `doc.id` → store as `memberId`
- All subsequent calls use `memberId` (Firestore doc ID), NOT `auth.uid`
- `firebase_auth_service.dart` `checkMemberExists()` returns `{'id': doc.id, ...data}`
- Fixed: March 25, 2026

**19. Firestore role values are Title Case — rules must match**
- `users` collection stores: `'Owner'`, `'Receptionist'`, `'Trainer'`, `'Member'`
- Rules `isOwner()` must check `== 'Owner'` not `== 'owner'`
- Jules-generated rules often use lowercase — always verify after merging Jules PRs
- Fixed: March 25, 2026

**20. Phone OTP members have no `users` collection document**
- Member app uses phone OTP — `FirebaseAuthService` never writes to `users` collection
- `isMember()` in rules (which does `get(users/{uid})`) will **always return false** for members
- All member-side collection rules must use `isSignedIn() && isOwnRecord()` not `isMember()`
- Fixed: March 25, 2026

### Build and Deployment Safeguards

- AGP 8.9.1 (required by `androidx.browser:browser:1.9.0`)
- Gradle wrapper: 8.10.2 (in sync with AGP)
- Kotlin: 2.1.0
- compileSdk/targetSdk: 35
- `flutter analyze` must return 0 issues before any `git push`

### Code Review Checklist (Pre-PR)

- [ ] `flutter analyze` returns 0 issues
- [ ] No hardcoded dates, IDs, or branch names
- [ ] No SharedPreferences for sensitive data — use FlutterSecureStorage
- [ ] All new fields in existing models updated in `toMap`/`fromMap`/`copyWith`
- [ ] `gamificationEvents` fired instead of direct MemberModel mutations
- [ ] `verificationId` passed explicitly to `verifyOTP`, not loaded from storage only
- [ ] `scannerController.stop()` called before async work in QR scanner
- [ ] `resetScanner()` called after every dialog closes in QR scanner
- [ ] `hasCheckedInToday` guard added before writing attendance
- [ ] String interpolation verified after export — no escaping corruption
- [ ] Firebase Storage paths match exactly between Dart and rules
- [ ] All DateTime comparisons use Timestamp correctly
- [ ] Model `fromMap` uses consistent pattern `fromMap(data, id)`
- [ ] Firestore role strings verified as Title Case after Jules PRs
- [ ] Member-side rules use `isSignedIn()` not `isMember()`
- [ ] No Firestore indexes deleted via CLI prompt

---

## 8. How to Use This Document

**When planning sprints:** Use Section 6 completion stats to identify backlog items.

**When working on Admin App:** See Section 2 for data models, screen responsibilities, and bug fix history. Check Section 7 for known pitfalls before any change.

**When working on Member App:** See Section 3 for auth architecture, service separation, and member lookup pattern. Section 7 rules 18–20 are critical.

**When fixing bugs:** Always check Section 7 first — most issues are regressions of known pitfalls.

**Before merging any Jules PR:** Verify role casing (Rule 19), member-side rule pattern (Rule 20), and run `flutter analyze`.

**After merging any PR:** Update this document with new rules if the fix prevents future regression.

---

*Document Maintenance: Update after every bug fix, feature addition, or architectural decision.*
*New rules added to Section 7 prevent future regressions.*
*Last updated: March 25, 2026 — Added rules 16–20 (Firestore rules casing, deploy pitfalls, member lookup pattern, phone OTP users architecture)*
