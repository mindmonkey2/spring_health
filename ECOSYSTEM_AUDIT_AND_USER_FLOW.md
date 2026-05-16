# Spring Health Ecosystem Audit, User Flow, and Feature Register
Last Updated: 2026-05-15

## 1. Purpose of this document

This document serves as a living audit of the entire Spring Health ecosystem. Its purpose is to track the system architecture, app boundaries, end-to-end user flows, and a comprehensive register of feature completion across all applications. It must be kept up-to-date as development progresses to ensure alignment between active development and the current true state of the project.

## 2. Ecosystem overview

The Spring Health ecosystem is a multi-branch gym management system built to operate on a shared backend, consisting of the following key components:

- **Spring Health Studio:** The administrative application used by owners, receptionists, and trainers to manage memberships, attendance, payments, gym analytics, and operations.
- **Spring Health Member App:** The client-facing application used by gym members to track workouts, access AI coaching, monitor their health profile, track attendance, and engage with gym gamification.
- **Trainer App:** Currently in roadmap status (not yet launched). It will provide dedicated tools for trainers to assign workouts, log notes, and track commissions.
- **Shared Backend:** A single Firebase project (`spring-health-studio-f4930`) serving both applications, providing Authentication, Firestore (real-time database), Cloud Storage, and Cloud Messaging (FCM).

The high-level business purpose is to provide a seamless, integrated digital experience that connects gym management with member engagement.

## 3. App boundaries and roles

| Role | App Access | Primary Capabilities |
|---|---|---|
| **Owner** | Studio | Global access to all branches. Can view cross-branch revenue, analytics, reports, manage staff (trainers/receptionists), setup Clash Wars, and broadcast global announcements. |
| **Receptionist** | Studio | Branch-specific access. Can manage members, process check-ins/attendance, collect manual payments, track dues, and broadcast branch-specific announcements. |
| **Trainer** | Studio | Read-only access to assigned members. Can view member progress, manage their own sessions, and update their own profile. |
| **Member** | Member App | Restricted to their own data. Can log workouts, view AI Coach insights, check in via QR code, participate in Weekly Wars/Gamification, and view announcements. |

## 4. End-to-end user flows

### New member onboarding flow
- **Trigger:** Member visits gym or signs up via reception.
- **Main steps:** Receptionist creates member profile in Studio -> Member downloads app -> Member logs in via Phone OTP -> Member completes initial health profile -> Member receives first AI Coach plan.
- **Firestore collections touched:** `members`, `healthProfiles`
- **Member-facing result:** Logged into Member App, views dashboard with initial AI plan and 0 XP.
- **Status marker:** [COMPLETED]

### Existing member login flow
- **Trigger:** Member opens the app after being logged out.
- **Main steps:** Enters phone number -> Receives OTP -> Verifies OTP -> App retrieves `memberId` -> Dual-guard auth check verifies session -> Navigates to Home screen.
- **Firestore collections touched:** `members`
- **Member-facing result:** Member accesses their dashboard and personal data.
- **Status marker:** [COMPLETED]

### Attendance / check-in flow
- **Trigger:** Member arrives at the gym.
- **Main steps:** Receptionist opens QR scanner in Studio or Member generates QR in app -> Scan occurs -> `attendance` record created -> Gamification service fires `check_in` event (XP + streak calculation) -> Member app processes event.
- **Firestore collections touched:** `attendance`, `gamificationEvents`, `gamification`
- **Member-facing result:** Member sees attendance logged, receives check-in XP, and sees streak increase (if applicable).
- **Status marker:** [COMPLETED]

### Payment and renewal flow
- **Trigger:** Membership expires or payment is due.
- **Main steps:** Receptionist flags dues in Studio -> Member notified (FCM) -> Receptionist records manual payment in Studio -> Membership dates updated. (Online renewal flow is pending).
- **Firestore collections touched:** `payments`, `members`, `notifications`
- **Member-facing result:** Membership expiry date is extended.
- **Status marker:** [IN PROGRESS] (Manual payments completed, Razorpay online payments pending)

### Announcement flow
- **Trigger:** Owner or Receptionist creates announcement in Studio.
- **Main steps:** Target audience (Branch or All) selected -> Announcement saved -> FCM notification triggered -> Members open app and view in Announcements tab -> Mark as read updates tracking.
- **Firestore collections touched:** `announcements`
- **Member-facing result:** Sees push notification and in-app announcement card.
- **Status marker:** [COMPLETED]

### Workout logging flow
- **Trigger:** Member starts a workout session in the app.
- **Main steps:** Member selects exercises or uses AI Coach plan -> Logs sets/reps/RPE -> Saves workout -> Gamification service processes `workout` event for XP -> Weekly War entry updated if active.
- **Firestore collections touched:** `workouts`, `gamificationEvents`, `gamification`, `weeklywars/{warId}/entries/{memberId}`
- **Member-facing result:** Workout saved to history, XP awarded, and war contribution updated.
- **Status marker:** [COMPLETED]

### AI coach flow
- **Trigger:** Member accesses the AI Coach tab.
- **Main steps:** App fetches member's health profile, wearable snapshot, and recent workouts -> Calls Gemini API via AiCoachService -> Generates Today/Week/Diet plans -> Stores in Firestore -> Renders UI with recovery status and coach notes.
- **Firestore collections touched:** `healthProfiles`, `aiPlans`, `wearableSnapshots`
- **Member-facing result:** Views personalized workout and diet recommendations, or a medical hold screen if flagged.
- **Status marker:** [COMPLETED]

### Gamification / war / loyalty flow
- **Trigger:** Member completes an XP-eligible action (check-in, workout, personal best).
- **Main steps:** Action occurs -> `gamificationEvents` document created -> `processEvent` updates XP/streak -> Member checks leaderboard -> At week's end, top 3 in war receive bonus XP (`warwinner`, `wartop3`).
- **Firestore collections touched:** `gamificationEvents`, `gamification`, `weeklywars`
- **Member-facing result:** Sees level progress, badges, and leaderboard position. (War auto-post deferred to Studio admin side).
- **Status marker:** [COMPLETED]

### Social flow
- **Trigger:** Member interacts with community.
- **Main steps:** View global/branch feed -> Like/comment on workouts -> Challenge another member to a duel. System generates achievement auto-posts.
- **Firestore collections touched:** `socialFeed`, `socialChallenges`, `posts`, `comments`, `likes`
- **Member-facing result:** Sees friends' activities, interacts, and broadcasts milestones (e.g. Personal Bests).
- **Status marker:** [PARTIAL] (Infrastructure, IDOR fixes, and PB auto-post completed. War auto-post blocked. 1v1 duels deferred. Pending remaining roadmap).

### Trainer-assisted flow
- **Trigger:** Member requests trainer guidance or trainer needs to assign a plan.
- **Main steps:** Trainer views member profile -> Writes notes/feedback -> Assigns custom workout -> Member views feedback in app.
- **Firestore collections touched:** `trainerFeedback`
- **Member-facing result:** Views trainer notes in their profile/dashboard.
- **Status marker:** [PENDING] (Basic structure exists, dedicated chat/feedback features incomplete)


## 5. Feature register by app

### Spring Health Studio
- Authentication
  - Email/Password login: [COMPLETED]
  - Role-based routing: [COMPLETED]
  - Dual-guard auth check: [COMPLETED]
- Dashboard
  - Multi-branch stats aggregation: [COMPLETED]
  - Live attendance overview: [COMPLETED]
- Members
  - Add/Edit member: [COMPLETED]
  - View member details: [COMPLETED]
  - Medical/health profile viewer: [IN PROGRESS]
- Payments
  - Record cash/manual payment: [COMPLETED]
  - Dues tracking: [COMPLETED]
  - Razorpay online gateway: [PENDING]
- Attendance
  - QR Code scanner: [COMPLETED]
  - Manual check-in: [COMPLETED]
- Reports
  - PDF/Excel export: [COMPLETED]
  - Email summary reports: [PENDING]
- Reminders
  - Automatic expiry/dues tracking: [COMPLETED]
- Announcements
  - Create global/branch announcement: [COMPLETED]
- Gamification
  - Clash Wars setup: [COMPLETED]
  - Admin manual XP awarding/correction: [COMPLETED]
- Settings / profile
  - Manage trainers/receptionists: [COMPLETED]
- Security / rules / architecture hardening
  - `users` collection Title Case enforcement: [COMPLETED]

### Spring Health Member App
- Authentication
  - Phone OTP login: [COMPLETED]
  - Dual-guard auth check: [COMPLETED]
- Dashboard
  - Home screen overview: [COMPLETED]
  - Fitness dashboard: [COMPLETED]
- Attendance
  - Generate QR code: [COMPLETED]
  - View attendance history: [COMPLETED]
- Workouts
  - Log custom workout: [COMPLETED]
  - Personal Bests tracking: [COMPLETED]
- AI / health
  - AI Coach Tab (Phase 4 UI): [COMPLETED]
  - Diet plan generation: [COMPLETED]
  - Medical holds / Recovery status: [COMPLETED]
  - Wearable syncing (Health Connect): [COMPLETED]
- Payments
  - View payment history: [COMPLETED]
  - Razorpay online renewal: [PENDING]
- Announcements
  - View and mark as read: [COMPLETED]
- Gamification
  - XP tracking and leveling: [COMPLETED]
  - Badges and Streaks: [COMPLETED]
  - Weekly War participation: [COMPLETED]
- Social
  - Social Feed: [IN PROGRESS]
  - 1v1 Duels: [DEFERRED]
- Settings / profile
  - Manage profile: [COMPLETED]
  - Body measurements / progress photos: [PENDING]
- Security / rules / architecture hardening
  - IDOR prevention on document creation: [COMPLETED]

### Trainer App / future app
- Authentication: [PLANNED]
- Member list by branch: [PLANNED]
- Workout assignment: [PLANNED]
- Trainer commission calculation: [PLANNED]
- In-app chat: [PLANNED]

## 6. Social roadmap snapshot

The social features are currently in a transition state, having been prioritized for foundational work in Thread 15 but requiring future sprints to complete the vision.
- **Completed pieces:** Basic social feed infrastructure, Firestore collections (`socialFeed`, `socialChallenges`, `posts`, `comments`, `likes`), IDOR prevention on social document creation, optimistic UI state patterns using `ValueNotifier`, and PB auto-post hooks.
- **In-progress / next pieces:** Further refinement of the social feed, comment/like UI polish, and cross-member interactions.
- **Blocked/Deferred pieces:** Weekly War auto-post hooks (blocked pending Studio-side integration) and 1v1 Duels (deferred to a dedicated "Spring Social" sprint).
- **Future pieces:** Advanced leaderboards, and direct messaging/friend systems.

## 7. Architecture and data ownership rules

To maintain system integrity, the following rules must be strictly adhered to:
- **`memberId` vs `auth.uid` split:** Member documents in the `members` collection use admin-assigned document IDs (`memberId`). This is NEVER the same as the Firebase Auth UID (`auth.uid`). All member data (workouts, attendance, gamification) must be keyed by `memberId`.
- **Never use `auth.uid` as a Firestore document key:** For collections requiring `memberId`, using `auth.uid` is an architectural violation and will result in data loss or lookup failure.
- **Member app users do not have `users/{uid}` docs:** Member app users authenticate via phone OTP and exist only in `members`, not the admin `users` collection. Member-side rules must use `isSignedIn()`, not `isMember()`.
- **Title Case roles in Studio users collection:** Roles must be stored as "Owner", "Receptionist", "Trainer", "Member". Firestore rules check for these exact case-sensitive strings.
- **`FirebaseAuthService.instance` singleton:** Must be used exclusively for auth operations to preserve state (like `verificationId`).
- **`fromMap(data, id)` only:** All Firestore models must implement this factory constructor pattern and never use `fromFirestore`. The document ID must be explicitly passed.
- **`GamificationService.instance.processEvent()` only:** This is the single, exclusive entry point for awarding XP. Never directly modify XP or call direct award functions from UI screens.
- **0 analyze issues before commit:** Both apps must pass `flutter analyze --no-pub` with 0 issues before any commit or push.
- **Security IDOR prevention:** Always validate ownership on document creation using `allow create: if isSignedIn() && isOwnNewRecord();`.

## 8. Completed vs planned summary

| Domain | Studio status | Member status | Trainer status | Notes |
|---|---|---|---|---|
| Core / Auth | [COMPLETED] | [COMPLETED] | [PLANNED] | Dual-guard implemented |
| Dashboard | [COMPLETED] | [COMPLETED] | [PLANNED] | |
| Gamification | [COMPLETED] | [COMPLETED] | [N/A] | Clash Wars / XP fully operational |
| AI / Health | [IN PROGRESS] | [COMPLETED] | [PLANNED] | Phase 4 UI done on Member side |
| Payments | [IN PROGRESS] | [IN PROGRESS] | [N/A] | Manual done; Razorpay pending |
| Social | [N/A] | [PARTIAL] | [N/A] | Foundation laid; Duels deferred |
| Trainer Tools | [PENDING] | [PENDING] | [PLANNED] | Feedback/Chat/Commissions pending |

## 9. Living-document maintenance rules

- This file **must be updated** after any feature merge, significant bug fix, roadmap change, or architecture change.
- It must stay perfectly aligned with `Spring-Health-Memory.md` and `PROJECT_CURRENT_STATE_AND_DEVELOPMENT_PLAN.md`.
- Status markers must be updated explicitly. Do not assume completion without verified proof in the project state.
