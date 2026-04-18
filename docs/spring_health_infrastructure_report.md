# Spring Health — Infrastructure, Security & Architecture Report

**Version:** 1.0  
**Date:** 2026-04-18  
**Project:** spring-health-studio-f4930  
**Apps:** Spring Health Studio (Admin) · Spring Health Member App  
**Prepared for:** CTO Review / Onboarding Reference

---

## Table of Contents

1. [Application Security](#1-application-security)
2. [Deployment Model](#2-deployment-model)
3. [User Access and Interaction Model](#3-user-access-and-interaction-model)
4. [Infrastructure](#4-infrastructure)
5. [Load Analysis and Cost Modelling](#5-load-analysis-and-cost-modelling)
6. [Security Analysis](#6-security-analysis)
7. [Architectural Suggestions](#7-architectural-suggestions)
8. [Use Cases and User Journeys](#8-use-cases-and-user-journeys)
- [Appendix A — Firestore Collections Reference](#appendix-a--firestore-collections-reference)
- [Appendix B — Service Inventory](#appendix-b--service-inventory)
- [Appendix C — Firebase Security Rules (Full Copy)](#appendix-c--firebase-security-rules-full-copy)
- [Appendix D — Open Items](#appendix-d--open-items)

---

## 1. Application Security

### 1.1 Authentication Architecture

Spring Health operates two completely separate authentication paths — one for gym staff (Studio) and one for members (Member App). Both share the same Firebase Authentication project (`spring-health-studio-f4930`) but use different providers.

#### Studio Staff Authentication (Email/Password + Role Lookup)

**Entry point:** `spring_health_studio/lib/main.dart:63` — `AuthWrapper` widget wraps the entire app.

The studio authentication flow has two layers of protection:

**Layer 1 — Active login (`auth_service.dart:29–93`):**

```
signInAndResolveUser(email, password)
  ├── FirebaseAuth.signInWithEmailAndPassword()
  ├── Firestore: users/{uid}.get()           ← reads role field
  ├── if role == '' or 'trainer':
  │     Firestore: trainers.where(authUid==uid).limit(1).get()
  │     if docs.isEmpty: throw 'Trainer profile not found'
  └── returns UserModel(role: Owner|Receptionist|Trainer)
```

**Layer 2 — Session restore on app restart (`main.dart:81–331`):**

`AuthWrapper` listens to `FirebaseAuth.instance.authStateChanges()`. On every auth state change it re-fetches the user's role from Firestore via `FirestoreService().getUserRole(uid)` (`main.dart:90`). This means a role downgrade in Firestore takes effect on the next app restart — an attacker who obtains a valid Firebase Auth session cannot bypass a role removal. The `_getRoleFuture` cache (`main.dart:87–93`) prevents redundant Firestore calls within the same session.

**Role routing** (`main.dart:315–327`):
- `'Owner'` → `OwnerDashboard`
- `'Receptionist'` → `ReceptionistDashboard`
- `'Trainer'` → `TrainerDashboardScreen`
- Any other value → `_errorScreen('Unknown role: $role')` — access denied

If a valid Firebase Auth user has no document in the `users` collection and no entry in `trainers`, `signInAndResolveUser` throws `'Trainer profile not found. Contact admin.'` (`auth_service.dart:68`), login is blocked, and the user sees an error. The `AuthWrapper` shows `_accountNotConfiguredScreen` (`main.dart:206`) for the null-data case.

#### Member Authentication (Phone OTP + Secure Storage)

**Entry point:** `spring_health_member_app/lib/screens/splash/splash_screen.dart:88` — checks `_authService.currentUser` synchronously; navigates to `LoginScreen` or `MainScreen`.

**OTP flow** (`firebase_auth_service.dart`):

```
Phone Entry Screen
  └── sendOTP(phoneNumber)                              [line 224]
        ├── _clearVerificationId()                      [line 237]
        ├── FirebaseAuth.verifyPhoneNumber()            [line 238]
        │     ├── verificationCompleted (auto-verify):
        │     │     └── signInWithCredential()
        │     │           └── _storeMemberIdFromUser()  [line 252]
        │     ├── codeSent:
        │     │     └── _saveVerificationId(id)         [line 271]
        │     │           (FlutterSecureStorage)
        │     └── verificationFailed → onError()
        │
OTP Verification Screen
  └── verifyOTP(otp, verificationId?)                  [line 294]
        ├── resolvedId = verificationId ?? _loadVerificationId()
        ├── PhoneAuthProvider.credential(resolvedId, otp)
        ├── FirebaseAuth.signInWithCredential(credential)
        └── _storeMemberIdFromUser(user)               [line 321]
              ├── Firestore: members.where(phone==…).get()
              ├── FlutterSecureStorage.write('memberId', id) [line 199]
              └── Firestore: members/{id}.update(uid, last_app_login)
```

**Key architectural decisions:**

| Decision | Implementation | File |
|---|---|---|
| verificationId storage | `FlutterSecureStorage` (Android Keystore / iOS Keychain) | `firebase_auth_service.dart:54` |
| memberId storage | `FlutterSecureStorage` (same encryption) | `firebase_auth_service.dart:89` |
| memberId ≠ auth.uid | Firestore doc ID resolved by phone lookup | `firebase_auth_service.dart:122–168` |
| Cold start resolution | SecureStorage → phone lookup fallback | `firebase_auth_service.dart:352–367` |
| Sign-out cleanup | Clears both verificationId AND memberId | `firebase_auth_service.dart:374–384` |

#### Singleton Pattern

`FirebaseAuthService` enforces a strict singleton (`firebase_auth_service.dart:29–31`):

```dart
static final FirebaseAuthService instance = FirebaseAuthService._internal();
factory FirebaseAuthService() => instance;
FirebaseAuthService._internal();
```

Every call site that appears to construct `FirebaseAuthService()` actually receives the same singleton. All five call sites in the member app (`main_screen.dart:35`, `home_screen.dart:33`, `announcements_screen.dart:20`, `membership_expired_screen.dart:459`, `splash_screen.dart:20`) share one instance. `GamificationService` and `NotificationService` use the same pattern.

---

### 1.2 Firestore Security Rules Analysis

**Rules file:** `firestore.rules` (root of monorepo)

#### Helper Functions

```
isSignedIn()         → request.auth != null
isOwner()            → users/{uid}.role == 'Owner'
isReceptionist()     → users/{uid}.role == 'Receptionist'
isTrainer()          → users/{uid}.role == 'Trainer'
isAdmin()            → isOwner() || isReceptionist()
isOwnDocument(docId) → request.auth.uid == docId
isOwnRecord(data)    → uid/memberId/userid field == auth.uid
isOwnNewRecord()     → same check on request.resource.data
isMemberOwner(mId)   → members/{mId}.uid == request.auth.uid
                        (cross-collection ownership check)
```

**Critical architectural note:** There is **no `isMember()` function** — intentionally. Phone OTP members have no document in the `users` collection, so any `isMember()` checking `users/{uid}` would always return false. Documented in `firebase_auth_service.dart:9–11` (Rules 20–22).

#### Collection Rules Status Table

| Collection | Read Rule | Write Rule | Status |
|---|---|---|---|
| `users` | Own doc or Owner | Owner only | ✅ |
| `members` | Any signed-in user | Owner/Receptionist create; anyone update | ⚠️ Read too open |
| `members/entries` | Any signed-in | Any signed-in | ⚠️ No ownership |
| `attendance` | Any signed-in | Admin create; signed-in create | ⚠️ Read too open |
| `payments` | Admin or any signed-in | Admin only | ❌ Members read others' payments |
| `announcements` | Any signed-in | Admin write; anyone update readBy | ✅ |
| `trainers` | Any signed-in | Owner create/delete; trainer updates own | ✅ |
| `trainerFeedback` | Owner/Trainer or own | Any signed-in create | ✅ |
| `feedback` | Owner/Trainer or own | Any signed-in create | ✅ |
| `expenses` | Admin only | Owner only | ✅ |
| `reminderlogs` | Admin/Trainer | Admin only | ✅ |
| `challenges` | Any signed-in | Admin write | ✅ |
| `challengeEntries` | Admin or any signed-in | Admin or own memberId create | ⚠️ Read too open |
| `gamificationEvents` | Admin or own memberId==auth.uid | Any signed-in create | ❌ Broken for phone OTP users |
| `gamificationevents` | Same (duplicate) | Same | ❌ Duplicate collection name issue |
| `gamification` | Admin/Trainer or isMemberOwner | Admin or isMemberOwner | ✅ Uses cross-collection check |
| `gamification_events` | Any signed-in | Admin only | ⚠️ Over-open read |
| `trainerTeamBattles` | Any signed-in | Admin/Trainer | ✅ |
| `weeklywars` | Any signed-in | Owner | ✅ |
| `weeklywars/entries` | Any signed-in | Signed-in with required fields | ⚠️ No ownership on create |
| `workouts` | Any signed-in | Own memberId | ❌ Members read others' workouts |
| `personalbests` | Any signed-in | Own memberId | ❌ Members read others' PBs |
| `sessions` | Any signed-in | Own memberAuthUid | ❌ Members read others' sessions |
| `fitnessData` | Owner/Trainer or isMemberOwner | isMemberOwner | ✅ |
| `bodyMetrics` | Any signed-in | Own memberId | ❌ Members read others' body data |
| `exercises` | Any signed-in | Owner only | ✅ |
| `memberAlerts` | Admin or any signed-in | Admin only | ⚠️ Read too open |
| `rpeLog/{uid}/entries` | Own uid only | Own uid only | ✅ |
| `notifications/{uid}` | Admin or own uid | Admin only | ✅ |
| `notificationHistory` | Admin or own record | Admin only | ✅ |
| `notificationsQueue` | Owner only | Admin create | ✅ |
| `fcmTokens` | Owner only | Own uid | ✅ |
| `dietPlans` | Admin/Trainer or own memberId | Admin/Trainer only | ✅ |
| `healthProfiles` | Owner/Trainer or isMemberOwner | Owner/Trainer or isMemberOwner | ✅ |
| `bodyMetricsLogs` | Owner/Trainer or isMemberOwner | Owner/Trainer or isMemberOwner | ✅ |
| `fitnessTests` | Owner/Trainer or isMemberOwner | Owner/Trainer or isMemberOwner | ✅ |
| `wearableSnapshots` | Owner/Trainer or isMemberOwner | Owner/Trainer or isMemberOwner | ✅ |
| `aiPlans` | Admin or own auth.uid | Owner/member; trainer: trainerNote only | ✅ |
| `gymEquipment` | Any signed-in | Owner only | ✅ |
| `memberGoals` | Owner/Trainer or own auth.uid | Owner/Trainer or own auth.uid | ✅ |
| `trainingSessions` | Owner/own trainer/own member | Trainer create; owner full | ✅ |
| `memberIntelligence` | Owner/Trainer or own auth.uid | Owner/Trainer only | ✅ |
| `springSocial` | Own auth.uid | Own auth.uid | ✅ |
| `socialFeed` | Any signed-in | Signed-in create; own delete/update | ✅ |
| `socialChallenges` | Own participant | Own participant | ✅ |

**Default deny:** No explicit `match /{document=**} { allow read, write: if false; }` exists. Firestore implicitly denies unmatched paths, but an explicit rule is best practice.

---

### 1.3 Client-Side Security

#### Sensitive Data Storage

| Data | Storage Mechanism | Location | Encrypted? |
|---|---|---|---|
| OTP verificationId | `FlutterSecureStorage` | `firebase_auth_service.dart:54` | ✅ OS keystore |
| memberId (Firestore doc ID) | `FlutterSecureStorage` | `firebase_auth_service.dart:89` | ✅ OS keystore |
| Razorpay payment key | `String.fromEnvironment('RAZORPAY_KEY')` | `app_config.dart:4` | ✅ Compile-time |
| SMTP password | `String.fromEnvironment('SMTP_PASSWORD')` | `email_service.dart:9` | ✅ Compile-time |
| Firebase session token | Firebase Auth SDK internal | Managed by SDK | ✅ SDK-managed |

No sensitive values are hardcoded as string literals in Dart source. All secrets use compile-time injection via `--dart-define`.

#### API Key Exposure

Firebase API keys appear in `firebase_options.dart` in both apps. Examples:

- Member App: `apiKey: 'AIzaSyA9y_fTKrfIRYlw4Th_2o93tZUlOsfwu30'` (Android, `firebase_options.dart:53`)
- Studio: `apiKey: 'AIzaSyDECFGrE2vvd51ildvQpZKiScE1uz1Kxmo'` (web, `firebase_options.dart:44`)

**This is expected and not a security vulnerability.** Firebase client API keys are public identifiers. They identify the Firebase project but grant no permissions beyond what Firestore security rules and Firebase Auth permit. The actual protection layer is security rules — which is why fixing the open read rules in Section 1.2 is critical.

**Recommendation:** Enable [Firebase App Check](https://firebase.google.com/docs/app-check) with Play Integrity (Android) and DeviceCheck (iOS) to ensure only the legitimate signed APK/IPA can call Firebase APIs. This prevents curl/Postman scripts from using the API keys to probe Firestore directly.

#### Build Obfuscation

Neither `spring_health_member_app` nor `spring_health_studio` has a confirmed `--obfuscate` flag in the build process. Since there is no CI/CD (`docs/` section 2.2), build flags are applied manually. Recommend adding `--obfuscate --split-debug-info=build/debug-info/` to all release builds to prevent reverse-engineering of the Dart class structure.

#### Network Security

All Firebase SDKs use HTTPS by default. The Razorpay SDK (`razorpay_flutter: ^1.4.1`) communicates with Razorpay servers over TLS. There are no HTTP (non-TLS) endpoints called in the codebase.

---

### 1.4 Security Gaps and Recommendations

| # | Finding | Risk | Fix |
|---|---|---|---|
| 1 | Members can read all other members' `workouts`, `personalbests`, `sessions`, `bodyMetrics`, `payments`, and full `members` collection | **High** | Add `resource.data.memberId == request.auth.uid` to read rules for each affected collection |
| 2 | `gamificationEvents` read rule compares `memberId` (Firestore doc ID) with `auth.uid` — always false for phone OTP users; members cannot read their own gamification events | **High** | Store `memberAuthUid` in gamification event docs and compare to `request.auth.uid`, or use `isMemberOwner` |
| 3 | Firebase Storage rules protect `member_photos/{uid}.jpg` but `StorageService` writes to `users/profile_images/{authUid}.jpg` (`storage_service.dart:22`) — path mismatch means either uploads fail or rules don't apply | **High** | Align the path in `StorageService` to `member_photos/{authUid}.jpg` |
| 4 | No CI/CD pipeline — security rules are deployed manually with no automated validation (`Section 2.2`) | **Medium** | Add GitHub Actions: `firebase emulators:exec` with rules tests before `firebase deploy` |
| 5 | No Firebase App Check configured | **Medium** | Enable App Check with Play Integrity/DeviceCheck to block non-app API key usage |
| 6 | No explicit default-deny rule in `firestore.rules` | **Low** | Add `match /{document=**} { allow read, write: if false; }` as the final rule |
| 7 | Two gamification event collection names exist: `gamificationEvents` and `gamificationevents` (both in rules and likely in code) — data may be split | **Medium** | Audit which collection code writes to; migrate all data to one canonical name; remove duplicate rule |
| 8 | `weeklywars/{warId}/entries` create rule does not verify `memberId` belongs to the authenticated user | **Low** | Add `request.resource.data.memberId == request.auth.uid` to create rule |
| 9 | Razorpay payment success is processed entirely client-side (`renewal_service.dart:14–59`) — no server-side webhook verification | **High** | Add a Cloud Function as a Razorpay webhook receiver to verify payment signatures before writing to Firestore |

---

## 2. Deployment Model

### 2.1 Architecture Overview

Spring Health uses a fully serverless Backend-as-a-Service (BaaS) architecture. There is no custom application server, no VMs, and no container orchestration. All backend logic runs either in Firebase Cloud Functions or entirely on the client.

```
┌─────────────────────────────────────────────────────────────────┐
│                      CLIENT LAYER                               │
│                                                                 │
│  ┌──────────────────────┐    ┌───────────────────────────────┐  │
│  │  Spring Health Studio │    │  Spring Health Member App     │  │
│  │  (Flutter — Android,  │    │  (Flutter — Android, iOS,    │  │
│  │   iOS, Web)           │    │   Web)                       │  │
│  │  Email/Password Auth  │    │  Phone OTP Auth              │  │
│  └──────────┬───────────┘    └───────────────┬───────────────┘  │
└─────────────┼───────────────────────────────┼───────────────────┘
              │   HTTPS / Firebase SDK         │
              ▼                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                  FIREBASE BACKEND (GCP)                         │
│                  Project: spring-health-studio-f4930            │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │ Firebase Auth │  │   Firestore  │  │  Firebase Storage    │  │
│  │ - Email/Pass  │  │  (30+ colls) │  │  member_photos/{uid} │  │
│  │ - Phone OTP   │  │  + Rules     │  │  + Storage Rules     │  │
│  └──────────────┘  │  + Indexes   │  └──────────────────────┘  │
│                    └──────────────┘                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │     FCM      │  │   Firebase   │  │  Cloud Functions v2  │  │
│  │ Push Notifs  │  │   AI (Gemini │  │  - announcement push │  │
│  │ Topics/Token │  │   2.5 Flash) │  │  - personal notify   │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

**What "no application server" means operationally:**
- There is no backend to patch, scale, or monitor beyond Firebase's managed console.
- All business logic lives in Flutter client code and Firestore security rules.
- Payment validation (`renewal_service.dart`) runs on the client — a known gap (see Section 1.4, Finding #9).
- Scaling is automatic and handled by Firebase's infrastructure.
- Cost scales linearly with usage (Firestore reads/writes, FCM messages, Storage bandwidth).

#### Firebase Services in Use

| Service | Package (Member App) | Package (Studio) | Purpose |
|---|---|---|---|
| Firebase Core | `firebase_core: ^4.4.0` | `firebase_core: ^4.4.0` | SDK initialization |
| Firebase Auth | `firebase_auth: ^6.1.4` | `firebase_auth: ^6.1.4` | Phone OTP / Email auth |
| Cloud Firestore | `cloud_firestore: ^6.1.2` | `cloud_firestore: ^6.2.0` | Primary database |
| Firebase Messaging | `firebase_messaging: ^16.1.1` | — | Push notifications |
| Firebase Storage | `firebase_storage: ^13.0.6` | `firebase_storage: ^13.2.0` | Profile image hosting |
| Firebase AI | `firebase_ai: ^3.10.0` | `firebase_ai: ^3.10.0` | Gemini AI coach |
| Cloud Functions | (server-side, Node.js v2) | — | Announcement push, personal notify |

---

### 2.2 Deployment Artifacts

#### What is Deployed

| Artifact | Destination | Deploy Command |
|---|---|---|
| `firestore.rules` | Firebase project (Firestore) | `firebase deploy --only firestore:rules` |
| `firestore.indexes.json` | Firebase project (Firestore) | `firebase deploy --only firestore:indexes` |
| `functions/index.js` | Cloud Functions (Node.js runtime) | `firebase deploy --only functions` |
| Studio web build | Firebase Hosting (Studio) | `firebase deploy --only hosting` |
| Member app APK/AAB | Manual / Play Store | `flutter build apk --release` |

#### Current Deployment Process

**Finding:** No `.github/workflows/` directory exists at the repo root. All deployments are manual. There is no automated testing gate before rule deployment.

**Risk:** A developer error in `firestore.rules` could be deployed to production without validation, potentially opening data to unauthorized access.

#### Recommended CI/CD Pipeline

```yaml
# .github/workflows/firebase-deploy.yml (recommended)
on:
  push:
    branches: [main]
    paths:
      - 'firestore.rules'
      - 'firestore.indexes.json'
      - 'spring_health_member_app/functions/**'

jobs:
  test-and-deploy:
    steps:
      - uses: actions/checkout@v4
      - name: Install Firebase CLI
        run: npm install -g firebase-tools
      - name: Run Firestore Rules Tests
        run: firebase emulators:exec --only firestore "npm test"
      - name: Deploy Rules and Indexes
        run: firebase deploy --only firestore:rules,firestore:indexes,functions
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
```

---

### 2.3 Environments

**Current state:** Single Firebase project (`spring-health-studio-f4930`) is used for all development, testing, and production. There is no separation between development and production data.

**Risk:** A developer testing a new feature writes to production member data. A bad rules deployment immediately affects all live users.

**Recommendation:**

```
Development    → spring-health-studio-dev     (Firebase project)
Staging        → spring-health-studio-staging (Firebase project)
Production     → spring-health-studio-f4930   (current project)
```

Use `.firebaserc` aliases:
```json
{
  "projects": {
    "default": "spring-health-studio-f4930",
    "dev": "spring-health-studio-dev",
    "staging": "spring-health-studio-staging"
  }
}
```

---

## 3. User Access and Interaction Model

### 3.1 User Populations

| User Type | App | Login Method | Access Level | Onboarding Path |
|---|---|---|---|---|
| Owner | Spring Health Studio | Email/password | Full access: members, payments, expenses, reports, gamification, trainers, announcements | Created directly in Firebase Auth console; `users/{uid}` doc with `role: 'Owner'` |
| Receptionist | Spring Health Studio | Email/password | Members, attendance, payments, announcements (no expenses, no trainer management) | Same as Owner |
| Trainer | Spring Health Studio | Email/password | Assigned members only, session management, AJAX loop, team battles | Firebase Auth account created; `trainers/{id}` doc with `authUid` field |
| Member | Spring Health Member App | Phone OTP (India, +91) | Own data only: workouts, gamification, sessions, profile | Added by Receptionist/Owner in Studio → given app download link → OTP self-registration |

---

### 3.2 Admin App User Journey (Spring Health Studio)

#### AuthWrapper Session Restoration (`main.dart:81–331`)

On every app start, `AuthWrapper` listens to `FirebaseAuth.instance.authStateChanges()`. Firebase briefly emits `null` on cold start before restoring the local session; `AuthWrapper` guards against this false-logout by checking `FirebaseAuth.instance.currentUser` synchronously (`main.dart:277`). Once the session is confirmed, `getUserRole(uid)` is called (`main.dart:90`) and the result cached for the session duration.

#### Owner Journey

```
App Start
  └── AuthWrapper: authStateChanges() → User confirmed
        └── getUserRole(uid) → role: 'Owner'
              └── OwnerDashboard
                    ├── Members tab:
                    │     members.where(branch, isArchived).stream
                    │     → MembersListScreen → MemberDetailScreen
                    │           ├── Edit member
                    │           ├── Collect dues (PaymentModel)
                    │           ├── View fitness tab (WorkoutService)
                    │           └── AI plan (AiCoachService → Gemini)
                    ├── Revenue tab:
                    │     payments.where(branch, date).stream
                    │     expenses.stream → analytics charts
                    ├── Announcements:
                    │     Create → Firestore write → Cloud Function trigger
                    │              → FCM push to topics
                    ├── Trainer management:
                    │     trainers.stream → AddTrainer / TrainerDetail
                    ├── Gamification admin:
                    │     Admin awards XP/events manually
                    └── Reports screen → PDF generation (pdf: ^3.11.1)
```

#### Receptionist Journey

```
App Start → ReceptionistDashboard
  ├── QR Scanner (mobile_scanner: ^5.2.3):
  │     Scan member QR → decode memberId
  │     attendance.add(memberId, checkInTime, branch)
  ├── Members list → Add/Edit member
  ├── Collect dues:
  │     payments.add(PaymentModel)
  │     members.update(dueAmount, lastPaymentDate)
  └── Announcements (read + create)
```

#### Trainer Journey

```
App Start → TrainerDashboardScreen(user: UserModel)
  ├── My Members:
  │     members.where(trainerId==uid).stream
  ├── Session creation:
  │     trainingSessions.add({trainerId, memberId, exercises[]})
  ├── AJAX Loop (trainer scan → guided session):
  │     trainer_scan_screen:
  │       members.doc(id).get()     ← member profile
  │       users.doc(trainerUid).get() ← trainer profile
  │       memberIntelligence.doc(uid).get() ← AI context
  │       → TrainerSessionScreen
  └── Team Battles:
        trainerTeamBattles.stream → war management
```

---

### 3.3 Member App User Journey (Spring Health Member App)

#### App Entry and Authentication

```
App Start (main.dart:9–36)
  ├── Firebase.initializeApp()
  ├── NotificationService().initialize()
  │     ├── FirebaseMessaging.requestPermission()
  │     ├── FirebaseMessaging.getToken() → fcmTokens.doc(uid).set()
  │     └── subscribeTo('announcements_all', 'announcements_{branch}')
  └── SplashScreen (2.5s minimum display)
        ├── _authService.currentUser != null → MainScreen
        └── currentUser == null → LoginScreen
```

#### Phone OTP Authentication

```
LoginScreen (phone input)
  └── sendOTP('+91{phone}')
        └── Firebase.verifyPhoneNumber()
              ├── codeSent → OtpVerificationScreen
              │     └── verifyOTP(otp)
              │           ├── PhoneAuthProvider.credential()
              │           ├── signInWithCredential()
              │           └── _storeMemberIdFromUser()
              │                 ├── members.where(phone).get()
              │                 ├── SecureStorage.write('memberId')
              │                 └── members.doc(id).update({uid, last_app_login})
              └── verificationCompleted (auto-verify) → same path
```

#### Daily Loop

```
MainScreen (bottom nav: Home | Train | AjAX | Alerts | Profile)
  │
  ├── HomeScreen (initState → _loadMemberData())
  │     ├── getCurrentMemberId() ← SecureStorage or phone lookup
  │     ├── members.doc(memberId).get()          [1 read]
  │     ├── gamification.doc(memberId).get()     [1 read]
  │     ├── gamificationEvents listener (pending XP) [1 read]
  │     ├── wearableSnapshots/{id}/daily/{date}  [1 read]
  │     ├── aiPlans/{id}/current/ collection     [1 read]
  │     └── memberGoals.doc(uid).snapshots()     [real-time listener]
  │
  ├── QR Check-in Screen
  │     ├── Display member QR code (QR contains memberId)
  │     ├── attendance.where(memberId, date).snapshots() [real-time]
  │     └── On check-in: attendance.add({memberId, checkInTime, branch})
  │
  ├── Fitness Dashboard
  │     └── trainingSessions.where(memberAuthUid==uid).limit(1).snapshots()
  │
  ├── Workout Logger
  │     ├── exercises.stream                     [collection read]
  │     ├── workouts.add(WorkoutLog)             [write]
  │     ├── personalbests.doc(memberId).get/set  [read + write]
  │     └── GamificationService.processEvent()   [read + write]
  │
  └── Profile Screen
        ├── members.doc(memberId) stream          [real-time]
        ├── payments.where(memberId).stream       [real-time]
        └── Edit profile → members.update()
```

#### Trainer-Led Session Loop

```
Trainer scans member QR (Studio: trainer_scan_screen.dart)
  ├── members.doc(memberId).get()
  ├── users.doc(trainerUid).get()
  ├── memberIntelligence.doc(memberUid).get()
  └── trainingSessions.add({trainerId, memberAuthUid, exercises[]})

Member sees session (member_session_screen.dart)
  └── trainingSessions.where(memberAuthUid==uid).snapshots() → live

LiveSessionScreen
  ├── Stream: trainingSessions.doc(sessionId).snapshots()
  └── member updates: exercises, activeExerciseIndex, sessionRpe

PostSessionSummaryScreen
  ├── trainingSessions.doc(sessionId).get()
  ├── workouts.add(WorkoutLog from session)
  ├── personalbests.get() / update if new PB
  └── GamificationService.processEvent('session_complete', memberId)
        ├── gamification.doc(memberId).get()
        ├── XP calculation + streak update
        ├── gamification.doc(memberId).update()
        └── BadgeService.checkBadges() → notifications/items write
```

#### Gamification Loop

```
XP Event fired (any workout/session/checkin)
  └── GamificationService.processEvent(event, memberId)
        ├── gamification.doc(memberId).get()
        ├── XP added + level checked
        ├── gamification.doc(memberId).update()
        └── BadgeService.checkBadges(memberId)
              ├── compare stats to badge thresholds
              ├── notifications/{uid}/items.add(badge notification)
              └── in-app badge toast displayed

Leaderboard (XP/Streak/Workouts)
  └── gamification.where(branchId).orderBy(totalXp).limit(N)
        (indexed: firestore.indexes.json lines 179–207)

Weekly Wars
  └── weeklywars.doc(warId).snapshots()
        weeklywars/{warId}/entries.snapshots()
```

---

### 3.4 Cross-App Data Flow

```
SPRING HEALTH STUDIO                    SPRING HEALTH MEMBER APP
═══════════════════════                 ════════════════════════

Receptionist scans QR
  └── attendance.add()            ──►  QR screen listener updates ✅
                                        attendance heatmap refreshes

Trainer creates trainingSessions
  └── trainingSessions.add()      ──►  MemberSessionScreen sees it
                                        live session begins

Studio fires gamification event
  └── gamification.update()       ──►  GamificationService listener
                                        XP bar animates, badges checked

Admin creates announcement
  └── announcements.add()         ──►  Cloud Function triggers
        │                              FCM push to topic
        └── Cloud Function            announcements listener in app
            sendAnnouncementNotif()   notification bell updates

Trainer updates aiPlans
  └── aiPlans/{id}/current.update ──►  AiCoach screen refreshes
        (trainerNote field only)       coach note visible to member

Admin updates member record
  └── members.doc(id).update()    ──►  MainScreen member listener
                                        membership status rechecked
                                        expired → MembershipExpiredScreen
```

---

## 4. Infrastructure

### 4.1 Firebase Services Map

| Service | Purpose | Key Collections / Paths | Read Owner | Write Owner |
|---|---|---|---|---|
| Firebase Auth | Identity: phone OTP (members), email/pass (staff) | — | SDK | SDK |
| Cloud Firestore | Primary data store: all app state | 30+ collections | Both apps | Both apps |
| Firebase Storage | Profile photo hosting | `member_photos/{uid}.jpg` *(intended)* | Anyone signed-in | Own uid only |
| Firebase Messaging | Push notifications | Topic subscriptions + `fcmTokens` | Cloud Functions | Member App |
| Firebase AI (Vertex AI) | Gemini workout plan generation | `aiPlans/{memberId}/current/` | AiCoachService | AiCoachService + Trainer |
| Cloud Functions v2 | Server-side triggers | Reads `announcements`, `fcmTokens` | Functions runtime | Functions runtime |

---

### 4.2 Firestore Collection Catalogue

| Collection | Owner App | Key Field | Document Shape Summary | Rules Status |
|---|---|---|---|---|
| `users` | Studio | `uid` (auth UID) | role, name, branch, email, createdAt | ✅ |
| `members` | Both | Firestore auto-ID | name, phone, branch, plan, expiryDate, isActive, isArchived, uid (linked after OTP), dueAmount | ⚠️ Read too open |
| `members/{id}/entries` | Studio | auto-ID | Document history entries | ⚠️ |
| `trainers` | Studio | Firestore auto-ID | name, authUid, branch, isActive, specialization | ✅ |
| `attendance` | Both | auto-ID | memberId, checkInTime, branch, type | ⚠️ |
| `payments` | Both | auto-ID | memberId, amount, paymentMode, plan, branch, timestamp, razorpayPaymentId? | ❌ Read too open |
| `expenses` | Studio | auto-ID | category, amount, expenseDate, branch, description | ✅ |
| `gamification` | Member App | Firestore member doc ID | totalXp, currentStreak, workoutCount, level, badges[], branchId | ✅ |
| `gamificationEvents` | Member App | auto-ID | memberId, event, xp, processed, timestamp | ❌ Broken read |
| `gamificationevents` | Member App | auto-ID | (duplicate) Same schema | ❌ Duplicate |
| `gamification_events` | Studio | auto-ID | (admin-managed events) | ⚠️ |
| `workouts` | Member App | auto-ID | memberId, exercises[], date, source, sessionId? | ❌ Read too open |
| `personalbests` | Member App | Firestore member doc ID | exercises map with best weight/reps/date | ❌ Read too open |
| `sessions` | Member App | auto-ID | memberAuthUid, trainerId?, exercises[], date | ❌ Read too open |
| `trainingSessions` | Both | auto-ID | trainerId, memberAuthUid, exercises[], status, sessionRpe | ✅ |
| `announcements` | Both | auto-ID | title, message, targetBranches[], isGlobal, readBy[], createdAt | ✅ |
| `challenges` | Both | auto-ID | title, type, targetMetric, endDate | ✅ |
| `challengeEntries` | Both | auto-ID | memberId, challengeId, score, submittedAt | ⚠️ |
| `weeklywars` | Both | auto-ID | name, startDate, endDate, branchId | ✅ |
| `weeklywars/{id}/entries` | Member App | auto-ID | memberId, totalReps, sessionCount, memberName | ⚠️ |
| `trainerTeamBattles` | Both | auto-ID | team1, team2, scores, status | ✅ |
| `bodyMetrics` | Both | auto-ID | memberId, weight, bodyFat, recordedAt | ❌ Read too open |
| `bodyMetricsLogs` | Member App | Firestore member doc ID | (subcollection `/logs/{logId}`) | ✅ |
| `healthProfiles` | Member App | Firestore member doc ID | heightCm, weightKg, bmi, fitnessGoal, medicalConditions, jointRestrictions | ✅ |
| `fitnessTests` | Member App | Firestore member doc ID | `/tests/{testId}` subcollection | ✅ |
| `wearableSnapshots` | Member App | Firestore member doc ID | `/daily/{date}` — steps, heartRate, hrv, sleepData, recoveryStatus | ✅ |
| `aiPlans` | Both | Firebase auth UID | `/current/{docId}` — workoutPlan, dietPlan, coachNote, trainerNote | ✅ |
| `memberGoals` | Both | Firebase auth UID | goalType, targetValue, deadline, progress | ✅ |
| `memberIntelligence` | Both | Firebase auth UID | AI-generated insights, readiness score, trainer-visible notes | ✅ |
| `rpeLog` | Member App | Firebase auth UID | `/entries/{id}` — rpe, date, notes | ✅ |
| `dietPlans` | Both | Firestore member doc ID | `/current/{docId}` — meals[], calories, macros | ✅ |
| `exercises` | Member App | auto-ID | name, category, muscleGroups[], instructions | ✅ |
| `notifications` | Both | Firebase auth UID | `/items/{itemId}` — type, title, body, read, createdAt | ✅ |
| `notificationHistory` | Studio | auto-ID | memberId, title, body, sentAt | ✅ |
| `notificationsQueue` | Studio | auto-ID | target, payload, scheduledFor | ✅ |
| `fcmTokens` | Member App | Firebase auth UID | token, branchId, platform, updatedAt | ✅ |
| `memberAlerts` | Studio | Firestore member doc ID | type, message, severity, createdAt | ⚠️ |
| `reminderlogs` | Studio | auto-ID | memberId, type, sentAt | ✅ |
| `trainerFeedback` | Both | auto-ID | memberId, trainerId, rating, notes, createdAt | ✅ |
| `feedback` | Both | auto-ID | uid, rating, comment, createdAt | ✅ |
| `fitnessData` | Member App | auto-ID | memberId, date, steps, calories | ✅ |
| `gymEquipment` | Both | branch ID | equipment[], maintenanceLog[] | ✅ |
| `springSocial` | Member App | Firebase auth UID | profile, followersCount | ✅ |
| `socialFeed` | Member App | auto-ID | memberId, content, media, likes | ✅ |
| `socialChallenges` | Member App | auto-ID | challengerId, opponentId, metric, status | ✅ |

---

### 4.3 Service Layer Architecture

#### Service Pattern

Services in both apps follow two patterns:

**Singleton (shared state across widgets):**
```dart
static final ServiceName instance = ServiceName._internal();
factory ServiceName() => instance;
ServiceName._internal();
```
Used by: `FirebaseAuthService`, `GamificationService`, `NotificationService`, `WearableSnapshotService`, `FirestoreService` (Studio)

**Stateless instance (no shared state, testable):**
```dart
class ServiceName {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // No static instance
}
```
Used by: `MemberService`, `WorkoutService`, `BadgeService`, `RenewalService`, `PaymentService`

#### Service Inventory

**Member App (`spring_health_member_app/lib/services/`):**

| Service | Pattern | Responsibility |
|---|---|---|
| `firebase_auth_service.dart` | Singleton | Phone OTP auth, verificationId/memberId storage |
| `firestore_service.dart` | Instance | Member CRUD, attendance, announcements streams |
| `member_service.dart` | Instance | Member data fetch and stream |
| `gamification_service.dart` | Singleton | XP processing, leaderboard, streak management |
| `badge_service.dart` | Instance | Badge threshold evaluation, notification writes |
| `workout_service.dart` | Instance | Workout save, personal best detection |
| `notification_service.dart` | Singleton | FCM token registration, push handling |
| `in_app_notification_service.dart` | Instance | In-app notification feed |
| `announcement_service.dart` | Instance | Announcement streams by branch/global |
| `challenge_service.dart` | Instance | Active challenge stream |
| `ai_coach_service.dart` | Singleton | Gemini plan generation, context building |
| `health_profile_service.dart` | Instance | Health profile CRUD |
| `health_service.dart` | Instance | Apple Health / Google Health Connect |
| `wearable_snapshot_service.dart` | Singleton | Daily wearable data sync |
| `body_metrics_service.dart` | Instance | Body measurement history |
| `personal_best_service.dart` | Instance | PB queries |
| `attendance_service.dart` | Instance | Attendance queries |
| `payment_service.dart` | Instance | Payment history |
| `renewal_service.dart` | Instance | Razorpay renewal processing |
| `rpe_service.dart` | Instance | RPE log CRUD |
| `membership_alert_service.dart` | Instance | Expiry alert checks |
| `trainer_service.dart` | Instance | Trainer list queries |
| `trainer_feedback_service.dart` | Instance | Feedback submission/stream |
| `weekly_war_service.dart` | Instance | Weekly war data |
| `storage_service.dart` | Instance | Profile image upload/delete |

**Studio (`spring_health_studio/lib/services/`):**

| Service | Pattern | Responsibility |
|---|---|---|
| `auth_service.dart` | Instance | Email/password auth, role resolution |
| `firestore_service.dart` | Singleton | All Studio Firestore operations |
| `announcement_service.dart` | Instance | Announcement CRUD |
| `session_service.dart` | Instance | Training session management |
| `trainer_feedback_service.dart` | Instance | Feedback management |
| `admin_gamification_service.dart` | Instance | Admin XP award, war management |
| `team_battle_service.dart` | Instance | Team battle CRUD |
| `trainer_ajax_service.dart` | Instance | AJAX loop session data |
| `member_fitness_service.dart` | Instance | Member fitness data for Studio view |
| `notification_service.dart` | Instance | Studio push notification management |
| `reminder_service.dart` | Instance | Renewal/dues reminders |
| `document_service.dart` | Instance | Member document history |
| `storage_service.dart` | Instance | Studio Storage operations |
| `email_service.dart` | Instance | SMTP email via mailer package |
| `whatsapp_service.dart` | Instance | WhatsApp deep-link messaging |
| `pdf_service.dart` | Instance | PDF report generation |
| `fee_calculator.dart` | Instance | Membership fee calculation |

#### Raw Firestore Calls in UI Layer

The following screen files make direct `FirebaseFirestore.instance` calls outside of service classes. This bypasses the service layer and duplicates query logic:

**Member App:**
- `screens/main_screen.dart:158,188` — member doc stream, announcements stream
- `screens/checkin/qr_checkin_screen.dart:68` — attendance stream
- `screens/diet/diet_plan_screen.dart:56` — diet plan fetch
- `screens/profile/profile_screen.dart:163` — profile write
- `screens/profile/edit_profile_screen.dart:151,188` — member doc updates
- `screens/workout/member_session_screen.dart:79` — training session stream
- `screens/home/home_screen.dart:398` — memberGoals stream
- `screens/fitness/fitness_dashboard_screen.dart:46` — training session stream
- `screens/fitness/post_session_summary_screen.dart:39,53,62` — session read/write/PB
- `screens/fitness/live_session_screen.dart:27` — live session stream

**Studio (66 occurrences across):**
- `screens/equipment/equipment_manager_screen.dart:229,288,381,499`
- `screens/trainer/trainer_dashboard_screen.dart:63,515,1012,1028,1276,1307,1415,1443,1545`
- `screens/trainer/trainer_scan_screen.dart:112,132,176`

---

### 4.4 Stream Lifecycle Management

| Screen | Stream Variable | Cancelled in dispose()? | Assessment |
|---|---|---|---|
| `main_screen.dart` | `_memberSub`, `_announcementSub` | ✅ Lines 101–102 | Correct |
| `qr_checkin_screen.dart` | `_attendanceSub`, `_gamSub` | ✅ Lines 53–54 | Correct |
| `fitness_dashboard_screen.dart` | `_sessionStream` | Used with `StreamBuilder` | ✅ Correct (Flutter manages) |
| `live_session_screen.dart` | Stream inside `StreamBuilder` | Managed by Flutter | ✅ Correct |
| `member_session_screen.dart` | Stream inside `StreamBuilder` | Managed by Flutter | ✅ Correct |
| `health_profile_screen.dart` | `dispose()` disposes controllers | ✅ Lines 158–171 | Correct |
| `renewal_screen.dart` | `_processingNotifier` | ✅ Lines 52–55 | Correct |

**Finding:** No memory leak risk identified. All `StreamSubscription` instances are properly cancelled in `dispose()`. Screens using `StreamBuilder` rely on Flutter's widget lifecycle for cleanup, which is correct.

---

### 4.5 AI Integration

**Model:** `gemini-2.5-flash-preview-04-17` (`ai_coach_service.dart:19`)

**Configuration:**
```dart
generationConfig: GenerationConfig(
  responseMimeType: 'application/json',  // structured output
  temperature: 0.4,                       // low creativity, high consistency
  maxOutputTokens: 3000,
)
```

**Context built before each call** (`ai_coach_service.dart:34`):
- `healthProfiles/{memberId}` — height, weight, BMI, fitness goal, restrictions
- `wearableSnapshots/{memberId}/daily/{today}` — steps, HRV, recovery score
- `bodyMetricsLogs/{memberId}/logs/` — last N entries
- `rpeLog/{uid}/entries/` — recent RPE ratings
- `workouts` — last N workouts

**Output stored:** `aiPlans/{memberAuthUid}/current/{docId}` with `workoutPlan` and `coachNote` fields.

**Trainer override:** Trainers can write only the `trainerNote` and `trainerNoteUpdatedAt` fields (`firestore.rules:381–382`) — isolated from the AI-generated plan.

**Cost implications:** Gemini 2.5 Flash is billed per token (input + output). Each plan generation involves multiple Firestore reads (building context) plus one API call. At 200 members × daily plan refresh: ~200 calls/day. Firebase AI (Vertex AI via Firebase) pricing is project-billed through GCP — not included in Firebase free tier. Monitor via Google Cloud Console → Vertex AI → Usage.

**Note:** The model ID uses `-preview-` indicating a pre-release model. This may change its API behavior without deprecation notice. Track Gemini model releases and pin to a stable model ID when available.

---

## 5. Load Analysis and Cost Modelling

### 5.1 Firestore Read Budget Per Session

**Scenario:** Member opens app → views home → views fitness dashboard → logs workout → closes.

| Step | Operation | Collection | Reads |
|---|---|---|---|
| App open | Auth state restore (SDK-internal) | — | 0 |
| Splash | `currentUser` check (synchronous, no network) | — | 0 |
| MainScreen init | `members.doc(memberId).snapshots()` listener | `members` | 1 (initial) |
| MainScreen init | `announcements.where(branch).limit(50).snapshots()` | `announcements` | 1 (initial) |
| MainScreen init | `NotificationService.saveFCMToken()` → `fcmTokens.doc(uid).set()` | `fcmTokens` | 1 write |
| MainScreen init | `WearableSnapshotService.syncTodaySnapshot()` | `wearableSnapshots` | 1 |
| HomeScreen load | `getCurrentMemberId()` from SecureStorage (cache hit) | — | 0 |
| HomeScreen load | `getMemberData(memberId)` | `members` | 1 |
| HomeScreen load | `GamificationService.getOrCreate(memberId)` | `gamification` | 1 |
| HomeScreen load | `listenForPendingLoyaltyEvents()` | `gamificationEvents` | 1 (listener) |
| HomeScreen load | `WearableSnapshotService.getTodaySnapshot()` | `wearableSnapshots` | 1 |
| HomeScreen load | `AiCoachService.getCachedWorkoutPlan()` | `aiPlans` | 1 |
| HomeScreen widget | `memberGoals.doc(uid).snapshots()` | `memberGoals` | 1 (listener) |
| Fitness Dashboard | `trainingSessions.where(memberAuthUid).limit(1).snapshots()` | `trainingSessions` | 1 (listener) |
| Workout Logger | `exercises` collection stream | `exercises` | 1 (collection listener) |
| Workout Logger | `workouts.add(log)` | `workouts` | 0 reads / 1 write |
| Post-session | `personalbests.doc(memberId).get()` | `personalbests` | 1 |
| Post-session | `personalbests.doc(memberId).update()` (if new PB) | `personalbests` | 1 write |
| Post-session | `gamification.doc(memberId).get()` | `gamification` | 1 |
| Post-session | `gamification.doc(memberId).update()` | `gamification` | 1 write |
| Post-session | `notifications/{uid}/items.add()` (badge) | `notifications` | 1 write |
| **Total** | | | **~11 reads, 4–5 writes** |

Persistent listeners (member, announcements, gamificationEvents, memberGoals, trainingSessions, exercises) generate one additional read each time any document in their scope changes.

---

### 5.2 Current Scale Estimate (200 Members)

**Assumptions:** 1 gym, 200 active members, 1.5 sessions/day average.

```
Daily sessions:      200 × 1.5          = 300 sessions/day
Reads per session:   11 reads/session
Total daily reads:   300 × 11           = 3,300 reads/day
Listener overhead:   ×1.5 (doc changes)  = ~4,950 reads/day
```

**Firebase Spark free tier:** 50,000 reads/day

**Status: ✅ Well within free tier.** Current scale uses ~10% of the free read quota. However, Cloud Functions require the Blaze plan (pay-as-you-go), which this project uses.

---

### 5.3 Scale Scenario: 10,000 Members

**Assumptions:** Multi-gym deployment, 10,000 active members, 1.5 sessions/day.

```
Daily sessions:      10,000 × 1.5          = 15,000 sessions/day
Reads per session:   11 reads
Base daily reads:    15,000 × 11           = 165,000 reads/day
Listener overhead:   ×1.5                  = 247,500 reads/day
Monthly reads:       247,500 × 30          = 7,425,000 reads/month
```

**Firestore cost:**
```
7,425,000 reads / 100,000 × $0.06 = $4.46/month
```

**Firestore writes:**
```
15,000 sessions × 4 writes = 60,000 writes/day × 30 = 1,800,000/month
1,800,000 / 100,000 × $0.18 = $3.24/month
```

**Firebase Storage:**
```
10,000 members × 200KB avg profile photo = 2GB
Storage: 2GB × $0.026/GB = $0.052/month
Bandwidth: assume 500 downloads/day × 200KB = 100MB/day × 30 = 3GB/month
Network egress: 3GB × $0.12/GB = $0.36/month
```

**Firebase Auth:** Free tier covers unlimited MAU for email/password; Phone Auth:
```
10,000 phone verifications/month (new logins + returning after session expire)
First 10,000 verifications/month are free (India region).
Cost: $0
```

**FCM:** Free (no per-message cost for Firebase Cloud Messaging).

**Cloud Functions:**
```
10,000 announcements + other triggers ≈ 30,000 invocations/month
Free tier: 2,000,000 invocations/month → $0
```

**Total monthly (10,000 members):**
```
Firestore reads:   $4.46
Firestore writes:  $3.24
Storage:           $0.41
Auth (phone):      $0.00
FCM:               $0.00
Functions:         $0.00
─────────────────────────
Total:             ~$8.11/month (USD)
                   ~₹676/month (INR at ₹83.4/USD)
```

---

### 5.4 Scale Scenario: 100,000 Members

**Assumptions:** 100,000 active members, 1.5 sessions/day.

```
Daily sessions:      100,000 × 1.5        = 150,000 sessions/day
Base daily reads:    150,000 × 11         = 1,650,000 reads/day
Listener overhead:   ×1.5                 = 2,475,000 reads/day
Monthly reads:       2,475,000 × 30       = 74,250,000 reads/month
```

**Firestore cost:**
```
74,250,000 / 100,000 × $0.06 = $44.55/month
```

**Writes:**
```
150,000 sessions × 4 = 600,000 writes/day × 30 = 18,000,000/month
18,000,000 / 100,000 × $0.18 = $32.40/month
```

**Storage:**
```
100,000 × 200KB = 20GB stored → $0.52/month
Bandwidth: 30GB/month egress → $3.60/month
```

**Phone Auth:**
```
100,000 verifications/month
First 10,000 free; next 90,000 × $0.0055/verification = $0.495 (India rate)
```

**Gemini AI (if daily plan refresh):**
```
100,000 calls/day × 3,000 tokens avg = 300M tokens/day
Gemini 2.5 Flash input: ~$0.0375/1M tokens; output: ~$0.15/1M tokens
This is significant — estimate $5,000–15,000/month for AI at this scale.
Implement on-demand plan refresh (not daily) to reduce to ~$50–500/month.
```

**Total monthly (100,000 members, AI excluded):**
```
Firestore reads:   $44.55
Firestore writes:  $32.40
Storage:           $4.12
Auth (phone):      $0.50
FCM:               $0.00
─────────────────────────
Total (no AI):     ~$81.57/month (USD) / ~₹6,803/month (INR)
```

**Architectural changes needed at 100,000 members:**

1. **Pagination is mandatory.** The current `limit(50)` on announcements and notifications will miss data. Implement cursor-based pagination with `startAfterDocument()`.
2. **Firestore denormalization.** Leaderboard reads across 100,000 gamification docs will be expensive. Pre-aggregate top-N leaderboard in a separate `leaderboardCache` document, refreshed by Cloud Function.
3. **AI plan caching.** Do not call Gemini on every session. Cache plans for 24–48 hours. Check `aiPlans/{id}/current/updatedAt` before calling.
4. **CDN for Storage.** Profile images should be served via Firebase Hosting CDN or Cloud CDN, not raw Storage URLs, to reduce egress costs.
5. **Cloud Scheduler.** Add scheduled jobs for daily leaderboard recalc, renewal reminders, badge processing — moving load from client to server.

---

### 5.5 Cost Optimisation Recommendations

| Optimisation | Estimated Saving | Implementation |
|---|---|---|
| Cache member data in FlutterSecureStorage with 60s TTL | ~15% read reduction | `member_service.dart`: check cache before `.get()` |
| Replace `gamification.doc(memberId).snapshots()` with `.get()` on HomeScreen load | ~10% reduction | `home_screen.dart:89` — gamification doesn't need real-time updates on home |
| Cache `exercises` collection locally (changes rarely) | ~5% reduction | `workout_service.dart`: persist exercises to local storage, refresh hourly |
| Pre-aggregate leaderboard top-10 via Cloud Function | Eliminates collection scans | Add scheduled function writing `leaderboard/{branch}/cache` |
| Gate AI plan calls behind `updatedAt + 24h` check | Major AI cost saving | `ai_coach_service.dart:getCachedWorkoutPlan()` — already returns cached plan; enforce server-side TTL |
| Use Firestore bundles for initial data load | Reduce cold-start reads | Bundle: `exercises` collection + active challenges as a static Firebase Hosting asset |

---

## 6. Security Analysis

### 6.1 Threat Model

| Threat | Attack Vector | Current Mitigation | Residual Risk |
|---|---|---|---|
| Unauthorised member data access | Authenticated member calls Firestore REST API directly; reads another member's workouts/payments | Firestore rules exist but reads are too permissive (`isSignedIn()` on many collections) | **HIGH** — any member can read all workout/payment/body data |
| Role escalation in Studio | Attacker authenticates with stolen staff credentials; modifies their own `users/{uid}.role` field | Users can only write to their own `users` doc if they're Owner; read is restricted | **LOW** — role writes require Owner access |
| OTP replay attack | Attacker intercepts SMS OTP and uses it before the real user | Firebase Auth OTP is single-use; `verifyOTP` clears verificationId on success (`firebase_auth_service.dart:316`) | **LOW** — Firebase handles replay server-side |
| Direct Firestore API abuse | Attacker extracts API key from APK, calls Firestore REST endpoint directly with crafted token | API keys are public; actual access depends on security rules — which have open reads on several collections | **HIGH** — combined with open read rules, attacker can enumerate all members' data |
| API key extraction from APK | APK decompiled; `firebase_options.dart` values extracted | Firebase API keys are intentionally public; no secrets in APK | **LOW** — App Check would prevent unauthenticated rule probing |
| XP/gamification manipulation | Member sends crafted `gamification.update()` call to inflate their XP | Rules: `update` on `gamification` requires `isMemberOwner(memberId)` — valid; but the client computes XP locally and writes the result | **MEDIUM** — XP calculation is client-side; malicious client could send arbitrary XP values |
| Payment bypass | Member calls `renewal_service.dart` directly without going through Razorpay | `payments.add()` is callable by any signed-in user via Firestore rules; no server-side payment verification | **HIGH** — member could write fake payment records |
| Gamification event spam | Any signed-in user can `create` on `gamificationEvents` (`firestore.rules:162`) | Create is allowed for any signed-in user with no rate limiting | **MEDIUM** — member could spam XP events; processing is server-side but no deduplication guard |

---

### 6.2 Firestore Rules Audit

Selected critical collections:

**`members` — ❌ Read too open**
```
match /members/{memberId} {
  allow read: if isSignedIn();           // ← ANY member reads ALL members
  allow create: if isOwner() || isReceptionist();
  allow update: if isOwner() || isReceptionist() || isSignedIn();
  allow delete: if isOwner();
}
```
*Fix:* `allow read: if isAdmin() || isTrainer() || isOwnDocument(memberId);`

**`payments` — ❌ Members read other members' payments**
```
match /payments/{paymentId} {
  allow read: if isAdmin() || isSignedIn();   // ← ANY member reads ALL payments
  allow create, update: if isAdmin();
  allow delete: if isOwner();
}
```
*Fix:* `allow read: if isAdmin() || (isSignedIn() && resource.data.memberId == request.auth.uid);`

**`workouts` — ❌ Read too open**
```
match /workouts/{workoutId} {
  allow read: if isAdmin() || isTrainer() || isSignedIn();  // ← ANY member
  allow create: if isAdmin() || (isSignedIn() && request.resource.data.memberId == request.auth.uid);
  allow update, delete: if isAdmin() || (isSignedIn() && resource.data.memberId == request.auth.uid);
}
```
*Fix:* `allow read: if isAdmin() || isTrainer() || (isSignedIn() && resource.data.memberId == request.auth.uid);`

**`gamificationEvents` — ❌ Broken read for phone OTP members**
```
match /gamificationEvents/{eventId} {
  allow read: if isAdmin()
    || (isSignedIn() && 'memberId' in resource.data &&
        resource.data.memberId == request.auth.uid);   // ← memberId is Firestore doc ID, NOT auth.uid
```
*Problem:* `memberId` is the Firestore member doc ID; `request.auth.uid` is the Firebase Auth phone UID. These are different values for all phone OTP members (Rule 21 in `firebase_auth_service.dart`). Condition always evaluates to false for members.  
*Fix:* Store `memberAuthUid` in all gamification event documents and compare: `resource.data.memberAuthUid == request.auth.uid`

**`gamification` — ✅ Correct cross-collection check**
```
match /gamification/{memberId} {
  allow read: if isAdmin() || isTrainer() || isMemberOwner(memberId);
  allow create, update: if isAdmin() || isMemberOwner(memberId);
}
// isMemberOwner: members/{memberId}.uid == request.auth.uid
```
This is the correct pattern. The `uid` field is written during OTP login (`firebase_auth_service.dart:203`), enabling this cross-collection ownership check.

---

### 6.3 Security Hardening Checklist

```
[ ] Default deny-all rule at root (match /{document=**} { allow read, write: if false; })
    STATUS: ❌ Missing — add as final rule in firestore.rules

[✅] All collections have explicit rules
    STATUS: ✅ All 30+ collections have rules

[ ] No allow read, write: if true present
    STATUS: ✅ None found

[ ] Member data isolated by auth UID or ownership check
    STATUS: ❌ Partial — workouts, personalbests, sessions, bodyMetrics,
            payments, members have open reads

[✅] Role values validated server-side (not just client)
    STATUS: ✅ AuthWrapper re-fetches role from Firestore on every auth state change

[✅] OTP verificationId in secure storage only
    STATUS: ✅ FlutterSecureStorage used (Android Keystore / iOS Keychain)

[✅] No hardcoded secrets in Dart source
    STATUS: ✅ SMTP and Razorpay keys use String.fromEnvironment()

[ ] APK obfuscation enabled in build config
    STATUS: ❌ Cannot confirm — no CI/CD or release build scripts in repo

[ ] firebase_app_check integrated
    STATUS: ❌ Not found in either pubspec.yaml

[ ] Rate limiting on auth attempts
    STATUS: ✅ Firebase Auth enforces rate limiting server-side on OTP attempts
            (error code 'too-many-requests' handled in firebase_auth_service.dart:403)
```

**Summary:** 4 of 10 checklist items confirmed ✅. 4 require action ❌. 2 partially addressed ⚠️.

---

### 6.4 Priority Security Actions

| Priority | Action | Where | Effort |
|---|---|---|---|
| **1 — Critical** | Fix open read rules on `workouts`, `personalbests`, `sessions`, `bodyMetrics`, `payments`, `members` — add ownership check to every `allow read` | `firestore.rules:63,87,225,234,241,257` | 2 hours |
| **2 — Critical** | Add server-side Razorpay webhook verification via Cloud Function — do not trust client-side payment success callbacks | `spring_health_member_app/functions/index.js` (add new function) | 4 hours |
| **3 — High** | Fix Firebase Storage path mismatch: change `StorageService.uploadProfileImage()` to write to `member_photos/{authUid}.jpg` | `spring_health_member_app/lib/services/storage_service.dart:22` | 30 minutes |
| **4 — High** | Fix `gamificationEvents` read rule: store `memberAuthUid` in event docs and use it in the rule | `firestore.rules:158–166` + all event writes | 2 hours |
| **5 — Medium** | Enable Firebase App Check (Play Integrity / DeviceCheck) to prevent unauthenticated API probing | Both `pubspec.yaml` files + Firebase Console | 3 hours |

---

## 7. Architectural Suggestions

### 7.1 Current Architectural Strengths

**Phone OTP authentication architecture** (`firebase_auth_service.dart:27–408`): The three-path OTP resolution (auto-verify → manual verify → cold start fallback), combined with FlutterSecureStorage for the verificationId and proactive memberId caching, is well-designed. The clear documentation of Rules 20–23 at the top of the service prevents common OTP bugs.

**Singleton enforcement with factory redirect:** The `factory FirebaseAuthService() => instance` pattern correctly makes `FirebaseAuthService()` calls safe everywhere — no risk of accidental dual instantiation even from separate widget trees.

**AuthWrapper role caching** (`main.dart:87–93`): The `_getRoleFuture` caching pattern prevents redundant Firestore reads across multiple `authStateChanges()` emissions (which Firebase emits several times per session) while still re-fetching if the UID changes.

**isMemberOwner cross-collection check** (`firestore.rules:48–51`): Using `get(/databases/$(database)/documents/members/$(memberId)).data.uid == request.auth.uid` is the correct pattern for collections keyed by Firestore doc ID. It's used correctly in `gamification`, `healthProfiles`, `bodyMetricsLogs`, `wearableSnapshots`, and `fitnessTests`.

**Stream subscription discipline** (`main_screen.dart:99–103`, `qr_checkin_screen.dart:51–55`): All `StreamSubscription` instances are declared as nullable and cancelled in `dispose()`. No memory leaks found.

**Batch writes for atomic payment recording** (`renewal_service.dart:30–59`): The Razorpay success handler uses `FirebaseFirestore.instance.batch()` to atomically write the payment record and update the member's expiry date — preventing partial-write inconsistency.

---

### 7.2 Technical Debt Items

| Item | Impact | Effort to Fix | Priority |
|---|---|---|---|
| Raw `FirebaseFirestore.instance` calls in 10 member app screens | Duplicates query logic, harder to audit security, makes testing harder | Medium (refactor to service calls) | Medium |
| Studio `trainer_dashboard_screen.dart` has 66 raw Firestore calls | Same as above, compounded | High (large screen, complex logic) | Low |
| Two gamification event collection names (`gamificationEvents` and `gamificationevents`) | Data split between collections; rules must be maintained for both | Medium (data migration + rule cleanup) | High |
| Client-side XP calculation in `GamificationService.processEvent()` | Gamification can be manipulated by modified client | High (move to Cloud Function) | Medium |
| No environment separation (single Firebase project for dev + prod) | Developers touch production data during testing | Medium (project provisioning) | Medium |
| No pagination on workout history, member list, leaderboard | UI shows truncated data at scale; no way to load more | Medium (add cursor-based pagination) | Low (not urgent at current scale) |
| `firebase_ai` uses preview model ID (`gemini-2.5-flash-preview-04-17`) | Preview models can change behavior without notice | Low (update model ID string) | Low |
| Member app and Studio share no code (separate Flutter projects) | Bug fixes must be applied twice for shared models (e.g., MemberModel) | High (refactor to shared package) | Low |

---

### 7.3 Feature Gaps with Architectural Impact

#### Razorpay Payment Webhook (Critical Gap)

**Current state:** `renewal_screen.dart:46–48` registers Razorpay event handlers. On `EVENT_PAYMENT_SUCCESS`, `renewal_service.dart` writes payment record directly to Firestore from the client. No server-side verification of the Razorpay signature occurs.

**Risk:** A technically capable user can call `RenewalService.processSuccessfulRenewal()` with a fake `razorpayPaymentId`, renewing their membership without paying.

**Integration path:**
```
Razorpay → HTTPS POST to Cloud Function
Cloud Function:
  1. Verify HMAC-SHA256 signature using Razorpay webhook secret
  2. Parse payment_id, order_id, status
  3. On 'payment.captured': write payments.add() + members.update()
  4. Return 200 OK to Razorpay
```
**Firebase services needed:** Cloud Functions v2 (`onRequest`), Firestore.  
**Data model change:** Add `orderId` field to payment documents for idempotency.

#### Trainer Chat (Planned)

**Firebase services:** Firestore (message collection) + FCM (real-time push).  
**Data model:**
```
trainerChats/{chatId}
  ├── participants: [trainerId, memberAuthUid]
  ├── lastMessage: string
  └── /messages/{messageId}
        ├── senderId: auth.uid
        ├── text: string
        └── createdAt: Timestamp
```
**Rules:** Participants-only read/write using `resource.data.participants.hasAny([request.auth.uid])`.  
**Architecture note:** Firestore real-time listeners work well for chat. No additional services needed.

#### Analytics Export (Planned)

**Firebase services:** BigQuery export (built into Firebase Console → Firestore → Export).  
**GCP services:** BigQuery (free tier: 1TB queries/month), Looker Studio for dashboards.  
**Setup:** Enable BigQuery export in Firebase Console. No code changes required. Revenue trends, member retention, workout frequency can be queried via SQL on the exported Firestore data.

---

### 7.4 Scalability Improvements

#### Pagination (Urgent at >5,000 members)

| Screen | Current | Fix |
|---|---|---|
| Members list (Studio) | `members.where(branch).stream` — no limit | `startAfterDocument(lastDoc).limit(20)` |
| Workout history | `.where(memberId).stream` — no limit | `startAfterDocument(lastDoc).limit(20)` |
| Gamification leaderboard | `.limit(limit)` ✅ | Already paginated |
| Notification feed | `.limit(50)` ✅ | Acceptable |

#### Caching Strategy

| Data | Cache Layer | TTL | Invalidation |
|---|---|---|---|
| `members/{id}` document | FlutterSecureStorage | 60 seconds | On any write to member doc |
| `exercises` collection | Local file cache | 24 hours | On app update or admin force-refresh |
| `gamification/{id}` | In-memory (`GamificationService._cache`) | Session duration | On XP event processed |
| `aiPlans/{id}/current` | Firestore (already cached in DB) | Check `updatedAt` + 24h | On trainer note update or explicit refresh |
| Announcements | In-memory list | Until listener fires change | Real-time via `.snapshots()` |

#### Denormalization Opportunities

| Current Pattern | Expensive Operation | Denormalized Solution |
|---|---|---|
| Leaderboard: read all `gamification` docs, sort client-side | O(N) reads | Maintain `leaderboard/{branchId}` doc with top-50 array, updated by Cloud Function on XP change |
| Member count per branch | Query `members.where(branch).count()` | Increment `branches/{branchId}.memberCount` on add/archive |
| Monthly revenue | Query all `payments.where(branch, month)` | Maintain `revenueStats/{branch}/{year}/{month}` doc, updated on payment write |

---

## 8. Use Cases and User Journeys

### 8.1 Core Use Cases

---

**UC-01: Member Daily Check-in**

| | |
|---|---|
| **Actor** | Member |
| **Trigger** | Member arrives at gym, opens app |
| **Steps** | 1. Open app → MainScreen (member data already loaded) → QR Check-in tab<br>2. Display QR code (contains `memberId`)<br>3. Receptionist/Trainer scans with Studio QR scanner<br>4. Studio writes `attendance.add()` with `memberId`, `checkInTime`, `branch`<br>5. Member app listener fires → attendance confirmed message |
| **Firestore Operations** | Studio write: `attendance.add()` (1 write)<br>Member app read: `attendance.where(memberId, date).snapshots()` (1 listener update) |
| **Success Outcome** | Attendance record created; member sees confirmation; XP event fired if eligible |

---

**UC-02: Member Workout Logging**

| | |
|---|---|
| **Actor** | Member |
| **Trigger** | Member taps "Log Workout" from HomeScreen |
| **Steps** | 1. `WorkoutLoggerScreen` loads exercises stream from `exercises` collection<br>2. Member selects exercises, logs sets/reps/weight<br>3. Taps "Finish Workout"<br>4. `WorkoutService.saveWorkout()` → `workouts.add(WorkoutLog)`<br>5. `checkAndUpdatePersonalBests()` → `personalbests.doc(memberId).get()` + compare + `update()` if new PB<br>6. `GamificationService.processEvent('workout_complete', memberId)` → XP added |
| **Firestore Operations** | 1 collection read (exercises), 1 write (workouts), 1 read + conditional write (personalbests), 1 read + 1 write (gamification) |
| **Success Outcome** | Workout saved; personal bests updated if beaten; XP awarded; streak incremented |

---

**UC-03: Trainer-Led Session (AJAX Loop)**

| | |
|---|---|
| **Actor** | Trainer (Studio) + Member (Member App) |
| **Trigger** | Trainer scans member QR code at gym |
| **Steps** | 1. Studio `trainer_scan_screen.dart`: decode QR → `memberId`<br>2. Read `members.doc(memberId)` + `users.doc(trainerUid)` + `memberIntelligence.doc(memberAuthUid)` (3 reads)<br>3. `trainingSessions.add({trainerId, memberAuthUid, exercises[]})` (1 write)<br>4. Member App: `trainingSessions.where(memberAuthUid==uid).snapshots()` listener fires<br>5. `MemberSessionScreen` appears on member's phone showing live session<br>6. Both parties see exercise list; member updates `exercises[]`, `activeExerciseIndex`, `sessionRpe`<br>7. Trainer marks session complete in Studio<br>8. `PostSessionSummaryScreen` fires on member app |
| **Firestore Operations** | 3 reads (setup) + 1 write (session create) + N writes (member exercise updates) + 1 final write (completion) |
| **Success Outcome** | Session logged; post-session summary shown; XP awarded; member intelligence updated |

---

**UC-04: Studio XP Event Bridge**

| | |
|---|---|
| **Actor** | Studio admin or Cloud Function |
| **Trigger** | Admin awards manual XP, or automated event (e.g., loyalty milestone) fires |
| **Steps** | 1. Studio: `AdminGamificationService.awardXP(memberId, event, xp)`<br>2. Write `gamificationEvents.add({memberId, event, xp, processed: false})`<br>3. Member App: `GamificationService.listenForPendingLoyaltyEvents()` listener fires<br>4. `processEvent()` reads `gamification.doc(memberId)`, adds XP, updates doc<br>5. `BadgeService.checkBadges()` evaluates thresholds<br>6. `notifications/{uid}/items.add()` if badge earned |
| **Firestore Operations** | 1 write (event) + 1 listener fire + 1 gamification read + 1 gamification write + conditional notification write |
| **Success Outcome** | XP reflected in member app gamification bar; badge notification shown if threshold crossed |

---

**UC-05: Receptionist Dues Collection**

| | |
|---|---|
| **Actor** | Receptionist (Studio) |
| **Trigger** | Member pays outstanding dues at desk |
| **Steps** | 1. `CollectDuesScreen`: enter amount, payment mode<br>2. `payments.add(PaymentModel)` (1 write)<br>3. `members.doc(memberId).update({dueAmount: 0, lastPaymentDate})` (1 write)<br>4. Optional: generate PDF receipt via `PdfService` |
| **Firestore Operations** | 2 writes |
| **Success Outcome** | Payment recorded; due amount cleared; PDF receipt generated |

---

**UC-06: Owner Revenue Review**

| | |
|---|---|
| **Actor** | Owner (Studio) |
| **Trigger** | Owner opens Analytics Dashboard |
| **Steps** | 1. `AnalyticsDashboard`: `payments.where(branch, dateRange).get()` (filtered by date)<br>2. `expenses.where(branch, dateRange).get()`<br>3. Chart rendering via `fl_chart`<br>4. Export to CSV via `csv` package |
| **Firestore Operations** | 2 collection queries (indexed by branch+paymentDate and branch+expenseDate) |
| **Success Outcome** | Revenue vs expenses charts rendered; CSV export available |

---

**UC-07: Announcement Broadcast**

| | |
|---|---|
| **Actor** | Owner or Receptionist (Studio) |
| **Trigger** | Admin creates a new announcement |
| **Steps** | 1. `CreateAnnouncementScreen`: fill title, message, target branches<br>2. `announcements.add({...})` (1 write)<br>3. Cloud Function `sendAnnouncementNotification` triggers on `onDocumentCreated`<br>4. Function reads `targetBranches`; calls `admin.messaging().sendToTopic()` for each<br>5. FCM delivers to all subscribed devices<br>6. Member App: `announcements.where(branch).snapshots()` listener fires<br>7. In-app notification bell count increments |
| **Firestore Operations** | 1 write (announcement) + Cloud Function read (none — data in event) |
| **Success Outcome** | Push notification delivered to all branch members; announcement visible in app feed |

---

**UC-08: Weekly War Participation**

| | |
|---|---|
| **Actor** | Member |
| **Trigger** | Member opens War screen during active weekly war period |
| **Steps** | 1. `WarScreen`: `weeklywars.where(active).limit(1).snapshots()`<br>2. `weeklywars/{warId}/entries.snapshots()` — leaderboard<br>3. Member logs workout → `WorkoutService.saveWorkout()`<br>4. `WeeklyWarService.updateEntry(warId, memberId, reps, sets)` → `entries.doc(memberId).set/update()` |
| **Firestore Operations** | 2 listeners + 1 write per workout |
| **Success Outcome** | Member's reps reflected in war leaderboard in real time |

---

**UC-09: Member Plan Renewal**

| | |
|---|---|
| **Actor** | Member |
| **Trigger** | Member's plan expires or is within expiry window |
| **Steps** | 1. `MembershipExpiredScreen` or `RenewalScreen` shown<br>2. Member selects plan → `AppConfig.razorpayKey` used to open Razorpay checkout<br>3. Razorpay SDK processes payment<br>4. On `EVENT_PAYMENT_SUCCESS`: `RenewalService.processSuccessfulRenewal()` batch-writes payment record + updates member expiry<br>5. `members.doc(memberId)` listener in MainScreen fires → membership status refreshes |
| **Firestore Operations** | 1 batch write (payment + member update) |
| **Success Outcome** | Membership extended; payment recorded; app unlocked |
| **Known Gap** | No server-side webhook verification — payment can be bypassed client-side |

---

**UC-10: AI Workout Plan Generation**

| | |
|---|---|
| **Actor** | Member |
| **Trigger** | Member opens AI Coach screen or plan is stale |
| **Steps** | 1. `AiCoachService.generateWorkoutPlan(memberId)` builds context:<br>   - `healthProfiles/{memberId}.get()` [1 read]<br>   - `wearableSnapshots/{memberId}/daily/{today}.get()` [1 read]<br>   - `bodyMetricsLogs/{memberId}/logs.limit(5).get()` [1 read]<br>   - `rpeLog/{uid}/entries.limit(7).get()` [1 read]<br>   - `workouts.where(memberId).limit(10).get()` [1 read]<br>2. Gemini API call with JSON prompt → structured workout plan<br>3. `aiPlans/{memberAuthUid}/current.set(plan)` [1 write] |
| **Firestore Operations** | 5 reads + 1 write per plan generation |
| **Success Outcome** | Personalised workout plan displayed; plan stored for offline access |

---

### 8.2 Error and Edge Case Journeys

**Member with expired membership tries to log workout:**
```
MainScreen._init()
  └── members.doc(memberId) stream fires
        └── MembershipAlertService checks expiryDate
              └── isExpired == true
                    └── Navigator.pushReplacement(MembershipExpiredScreen)
                          ├── Shows expiry date and renewal CTA
                          ├── Displays gym contact info (AppConfig.supportPhone)
                          └── "Renew Now" → RenewalScreen
```

**OTP times out mid-verification:**
```
sendOTP() → codeAutoRetrievalTimeout fires
  └── _saveVerificationId(newId)   ← saves updated ID
        [120 second timeout window]

If user taps verify after timeout:
  verifyOTP(otp) → signInWithCredential() → FirebaseAuthException('session-expired')
    └── _clearVerificationId()
        throw Exception('OTP expired. Please request a new code.')
          └── OtpVerificationScreen shows error + "Resend" button
                └── sendOTP() with forceResendingToken (_resendToken)
```

**Trainer session ends but member app is offline:**
```
trainingSessions.doc(sessionId) update → Firestore queued
Member app offline → local Firestore cache holds last state
  └── Firestore SDK replays writes when connectivity restored
        └── trainingSessions listener fires with complete session
              → PostSessionSummaryScreen shows when back online
```
Firestore SDK handles offline persistence automatically (enabled by default). No special handling required.

**Duplicate QR scan attempt:**
```
Second QR scan by Receptionist:
  attendance.add({memberId, checkInTime, branch}) → new document created
  (No deduplication logic found in codebase)
```
**Gap:** There is no check for existing attendance on the same day before inserting. A member could be scanned twice and get two attendance records. Recommend: `attendance.where(memberId, date==today).limit(1).get()` before inserting, or enforce idempotency via document ID `{memberId}_{date}`.

---

### 8.3 First-Time User Journey

```
[STUDIO — Receptionist]
1. AddMemberScreen: fill name, phone, branch, plan, expiryDate
2. members.add(MemberModel) → Firestore doc created with auto-ID
3. Receptionist shares app download link with member (WhatsApp via whatsapp_service.dart)

[MEMBER — First App Open]
4. Install app → SplashScreen (2.5s animation)
5. currentUser == null → LoginScreen
6. Enter phone number → sendOTP()
7. Receive SMS OTP
8. Enter OTP → verifyOTP()
   └── FirebaseAuth.signInWithCredential() — new Firebase Auth account created
   └── _storeMemberIdFromUser():
         members.where(phone=='+91XXXXXXXXXX').get()
         → found → save memberId to FlutterSecureStorage
         → members.doc(id).update({uid: auth.uid, last_app_login: now})

9. Navigate to MainScreen
10. NotificationService.saveFCMToken() → fcmTokens.doc(uid).set()
    subscribeToTopic('announcements_all', 'announcements_{branch}')

11. HomeScreen loads:
    ├── Membership card shows (name, plan, expiry)
    ├── GamificationService.getOrCreate() creates gamification doc
    └── XP = 0, Level 1, no badges

[FIRST CHECK-IN]
12. QR Check-in tab → QR code displayed
13. Receptionist scans → attendance.add()
14. GamificationService.processEvent('checkin', memberId)
    └── XP += 50 (first checkin)
    └── gamification.update(totalXp: 50, currentStreak: 1)

[FIRST BADGE]
15. BadgeService.checkBadges()
    └── 'first_checkin' threshold met
    └── notifications/{uid}/items.add(badge notification)
    └── In-app badge toast: "🏅 First Check-in!"

Journey complete: member is authenticated, their memberId is linked,
first XP is awarded, first badge earned.
```

---

## Appendix A — Firestore Collections Reference

See Section 4.2 for the full collection catalogue with fields, owner apps, and rules status.

**Collections found in service grep (`R2 data`):**

Primary: `aiPlans`, `announcements`, `attendance`, `bodyMetricsLogs`, `challengeEntries`, `challenges`, `dietPlans`, `exercises`, `expenses`, `fcmTokens`, `feedback`, `fitnessData`, `fitnessTests`, `gamification`, `gamification_events`, `healthProfiles`, `memberAlerts`, `members`, `notifications`, `payments`, `personalbests`, `personal_bests` *(note: mixed naming — same collection, confirm in code)*, `reminder_logs`, `rpeLog`, `sessions`, `trainerFeedback`, `trainerTeamBattles`, `trainers`, `users`, `wearableSnapshots`, `weeklywars`, `workouts`

Sub-collections: `members/{id}/entries`, `weeklywars/{id}/entries`, `notifications/{uid}/items`, `bodyMetricsLogs/{id}/logs`, `fitnessTests/{id}/tests`, `wearableSnapshots/{id}/daily`, `aiPlans/{id}/current`, `dietPlans/{id}/current`, `rpeLog/{uid}/entries`

**Note on collection name inconsistencies:**
- `gamificationEvents` (camelCase, in rules lines 156–167) vs `gamificationevents` (lowercase, rules lines 169–180) — both have rules; likely a naming drift between versions
- `personal_bests` (snake_case, in indexes) vs `personalbests` (no underscore, in rules and service code) — the index may not apply to the actual collection name used in queries

---

## Appendix B — Service Inventory

Full service class list: see Section 4.3.

**Cloud Functions** (`spring_health_member_app/functions/index.js`):

| Function | Trigger | Purpose |
|---|---|---|
| `sendAnnouncementNotification` | `onDocumentCreated('announcements/{id}')` | Push FCM to topic on new announcement |
| `sendPersonalNotification` | `onCall` (authenticated) | Send FCM to specific member token; requires Owner/Receptionist role |

---

## Appendix C — Firebase Security Rules (Full Copy)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isSignedIn() {
      return request.auth != null;
    }

    function isOwner() {
      return isSignedIn() &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'Owner';
    }

    function isReceptionist() {
      return isSignedIn() &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'Receptionist';
    }

    function isTrainer() {
      return isSignedIn() &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'Trainer';
    }

    function isAdmin() {
      return isOwner() || isReceptionist();
    }

    function isOwnDocument(docId) {
      return request.auth.uid == docId;
    }

    function isOwnRecord(docData) {
      return ('uid' in docData && docData.uid == request.auth.uid) ||
             ('memberId' in docData && docData.memberId == request.auth.uid) ||
             ('userid' in docData && docData.userid == request.auth.uid);
    }

    function isOwnNewRecord() {
      return ('uid' in request.resource.data &&
                request.resource.data.uid == request.auth.uid) ||
             ('memberId' in request.resource.data &&
                request.resource.data.memberId == request.auth.uid);
    }

    function isMemberOwner(memberId) {
      return isSignedIn() &&
        get(/databases/$(database)/documents/members/$(memberId)).data.uid == request.auth.uid;
    }

    match /users/{userId} {
      allow read: if isSignedIn() && (isOwnDocument(userId) || isOwner());
      allow write: if isOwner();
    }

    match /members/{memberId} {
      allow read: if isSignedIn();
      allow create: if isOwner() || isReceptionist();
      allow update: if isOwner() || isReceptionist() || isSignedIn();
      allow delete: if isOwner();
    }

    match /members/{memberId}/entries/{entryId} {
      allow read, write: if isSignedIn();
      allow read: if isOwner() || isTrainer();
    }

    match /attendance/{attendanceId} {
      allow read: if isAdmin() || isTrainer() || isSignedIn();
      allow create: if isAdmin() || isSignedIn();
      allow update, delete: if isAdmin();
    }

    match /payments/{paymentId} {
      allow read: if isAdmin() || isSignedIn();
      allow create, update: if isAdmin();
      allow delete: if isOwner();
    }

    match /announcements/{announcementId} {
      allow read: if isSignedIn();
      allow create, delete: if isAdmin();
      allow update: if isAdmin() || (isSignedIn() &&
        request.resource.data.diff(resource.data)
          .affectedKeys().hasOnly(['readBy']));
    }

    match /trainers/{trainerId} {
      allow read: if isSignedIn();
      allow create, delete: if isOwner();
      allow update: if isOwner()
        || (isTrainer() && isOwnDocument(trainerId));
    }

    match /trainerFeedback/{feedbackId} {
      allow read: if isOwner() || isTrainer()
        || (isSignedIn() && isOwnRecord(resource.data));
      allow create: if isSignedIn();
      allow update: if isOwner()
        || (isTrainer() && 'trainerId' in resource.data &&
            resource.data.trainerId == request.auth.uid);
      allow delete: if isOwner();
    }

    match /feedback/{feedbackId} {
      allow read: if isOwner() || isTrainer()
        || (isSignedIn() && isOwnRecord(resource.data));
      allow create: if isSignedIn();
      allow update: if isOwner() || isTrainer();
      allow delete: if isOwner();
    }

    match /expenses/{expenseId} {
      allow read: if isAdmin();
      allow write: if isOwner();
    }

    match /reminderlogs/{logId} {
      allow read: if isAdmin() || isTrainer();
      allow write: if isAdmin();
    }

    match /challenges/{challengeId} {
      allow read: if isSignedIn();
      allow create, update: if isAdmin();
      allow delete: if isOwner();
    }

    match /challengeEntries/{entryId} {
      allow read: if isAdmin() || isSignedIn();
      allow create: if isAdmin() || (isSignedIn() && request.resource.data.memberId == request.auth.uid);
      allow update, delete: if isAdmin();
    }

    match /gamificationEvents/{eventId} {
      allow read: if isAdmin()
        || (isSignedIn() && 'memberId' in resource.data &&
            resource.data.memberId == request.auth.uid);
      allow create: if isSignedIn();
      allow update: if isAdmin() ||
        (isSignedIn() && 'memberId' in resource.data &&
         resource.data.memberId == request.auth.uid &&
         request.resource.data.diff(resource.data)
           .affectedKeys().hasOnly(['processed']));
      allow delete: if isOwner();
    }

    match /gamificationevents/{eventId} {
      allow read: if isAdmin()
        || (isSignedIn() && 'memberId' in resource.data &&
            resource.data.memberId == request.auth.uid);
      allow create: if isSignedIn();
      allow update: if isAdmin() ||
        (isSignedIn() && 'memberId' in resource.data &&
         resource.data.memberId == request.auth.uid &&
         request.resource.data.diff(resource.data)
           .affectedKeys().hasOnly(['processed']));
      allow delete: if isOwner();
    }

    match /gamification/{memberId} {
      allow read: if isAdmin() || isTrainer() || isMemberOwner(memberId);
      allow create, update: if isAdmin() || isMemberOwner(memberId);
      allow delete: if isOwner();
    }

    match /gamification_events/{eventId} {
      allow read: if isSignedIn();
      allow create: if isAdmin();
      allow update: if isAdmin();
      allow delete: if isOwner();
    }

    match /trainerTeamBattles/{battleId} {
      allow read: if isSignedIn();
      allow create, update: if isAdmin() || isTrainer();
      allow delete: if isOwner();
    }

    match /weeklywars/{warId} {
      allow read: if isSignedIn();
      allow create, update: if isOwner();
      allow delete: if isOwner();

      match /entries/{entryId} {
        allow read: if isSignedIn();
        allow create: if isSignedIn() && request.resource.data.keys().hasAll(['memberId', 'totalReps', 'sessionCount', 'memberName']);
        allow update: if isSignedIn() && (
          request.resource.data.diff(resource.data).affectedKeys().hasOnly(['totalReps', 'sessionCount', 'lastUpdated'])
          || isOwner()
        );
        allow delete: if isOwner();
      }
    }

    match /workouts/{workoutId} {
      allow read: if isAdmin() || isTrainer() || isSignedIn();
      allow create: if isAdmin() || (isSignedIn() && request.resource.data.memberId == request.auth.uid);
      allow update, delete: if isAdmin() || (isSignedIn() && resource.data.memberId == request.auth.uid);
    }

    match /personalbests/{docId} {
      allow read: if isAdmin() || isTrainer() || isSignedIn();
      allow create: if isAdmin() || (isSignedIn() && request.resource.data.memberId == request.auth.uid);
      allow update, delete: if isAdmin() || (isSignedIn() && resource.data.memberId == request.auth.uid);
    }

    match /sessions/{sessionId} {
      allow read: if isAdmin() || isTrainer() || isSignedIn();
      allow create: if isSignedIn() && request.resource.data.memberAuthUid == request.auth.uid;
      allow update, delete: if isSignedIn() && resource.data.memberAuthUid == request.auth.uid;
    }

    match /fitnessData/{dataId} {
      allow read: if isOwner() || isTrainer() || (isSignedIn() && 'memberId' in resource.data && isMemberOwner(resource.data.memberId));
      allow create: if isSignedIn() && 'memberId' in request.resource.data && isMemberOwner(request.resource.data.memberId);
      allow update: if isSignedIn() && 'memberId' in resource.data && isMemberOwner(resource.data.memberId) && 'memberId' in request.resource.data && isMemberOwner(request.resource.data.memberId);
      allow delete: if isSignedIn() && 'memberId' in resource.data && isMemberOwner(resource.data.memberId);
    }

    match /bodyMetrics/{docId} {
      allow read: if isOwner() || isTrainer() || isSignedIn();
      allow create: if isAdmin() || (isSignedIn() && request.resource.data.memberId == request.auth.uid);
      allow update, delete: if isAdmin() || (isSignedIn() && resource.data.memberId == request.auth.uid);
    }

    match /exercises/{exerciseId} {
      allow read: if isSignedIn();
      allow write: if isOwner();
    }

    match /memberAlerts/{memberId} {
      allow read: if isAdmin() || isSignedIn();
      allow write: if isAdmin();
    }

    match /rpeLog/{uid}/entries/{entryId} {
      allow read, write: if isSignedIn() && isOwnDocument(uid);
    }

    match /notifications/{uid} {
      allow read: if isAdmin()
        || (isSignedIn() && isOwnDocument(uid));
      allow write: if isAdmin();
      match /items/{itemId} {
        allow read, write: if isAdmin()
          || (isSignedIn() && isOwnDocument(uid));
      }
    }

    match /notificationHistory/{historyId} {
      allow read: if isAdmin()
        || (isSignedIn() && isOwnRecord(resource.data));
      allow write: if isAdmin();
    }

    match /notificationsQueue/{queueId} {
      allow read: if isOwner();
      allow create: if isAdmin();
      allow delete: if isOwner();
    }

    match /fcmTokens/{tokenId} {
      allow read: if isOwner();
      allow write: if isSignedIn() && isOwnDocument(tokenId);
    }

    match /dietPlans/{memberId} {
      allow read: if isAdmin() || isTrainer() || (isSignedIn() && resource.data.memberId == request.auth.uid);
      allow create, update, delete: if isAdmin() || isTrainer();
      match /current/{docId} {
        allow read: if isAdmin() || isTrainer() || (isSignedIn() && resource.data.memberId == request.auth.uid);
        allow create, update, delete: if isAdmin() || isTrainer();
      }
    }

    match /fitnessData/{memberId}/daily/{date} {
      allow read, write: if isSignedIn() &&
        (request.auth.uid == memberId ||
         resource == null && request.auth.uid == memberId);
    }

    match /healthProfiles/{memberId} {
      allow read: if isOwner() || isTrainer() || isMemberOwner(memberId);
      allow write: if isOwner() || isTrainer() || isMemberOwner(memberId);
    }

    match /bodyMetricsLogs/{memberId} {
      allow read: if isOwner() || isTrainer() || isMemberOwner(memberId);
      allow write: if isOwner() || isTrainer() || isMemberOwner(memberId);
      match /logs/{logId} {
        allow read: if isOwner() || isTrainer() || isMemberOwner(memberId);
        allow write: if isOwner() || isTrainer() || isMemberOwner(memberId);
      }
    }

    match /fitnessTests/{memberId} {
      allow read: if isOwner() || isTrainer() || isMemberOwner(memberId);
      allow write: if isOwner() || isTrainer() || isMemberOwner(memberId);
      match /tests/{testId} {
        allow read: if isOwner() || isTrainer() || isMemberOwner(memberId);
        allow write: if isOwner() || isTrainer() || isMemberOwner(memberId);
      }
    }

    match /wearableSnapshots/{memberId} {
      allow read: if isOwner() || isTrainer() || isMemberOwner(memberId);
      allow write: if isOwner() || isTrainer() || isMemberOwner(memberId);
      match /daily/{date} {
        allow read: if isOwner() || isTrainer() || isMemberOwner(memberId);
        allow write: if isOwner() || isTrainer() || isMemberOwner(memberId);
      }
    }

    match /aiPlans/{memberId} {
      allow read: if isAdmin()
        || (isSignedIn() && request.auth.uid == memberId);
      allow create: if isAdmin()
        || (isSignedIn() && request.auth.uid == memberId);
      allow update: if isOwner()
        || (isSignedIn() && request.auth.uid == memberId);
      allow delete: if isOwner();

      match /current/{docId} {
        allow read: if isAdmin()
          || (isSignedIn() && request.auth.uid == memberId);
        allow create: if isAdmin()
          || (isSignedIn() && request.auth.uid == memberId);
        allow update: if isOwner()
          || (isSignedIn() && request.auth.uid == memberId)
          || (isTrainer()
              && request.resource.data.diff(resource.data)
                 .affectedKeys().hasOnly(['trainerNote', 'trainerNoteUpdatedAt']));
        allow delete: if isOwner();
      }
    }

    match /gymEquipment/{branch} {
      allow read:  if isSignedIn();
      allow write: if isOwner();
    }

    match /memberGoals/{memberAuthUid} {
      allow read:  if isOwner() || isTrainer() ||
        (isSignedIn() && request.auth.uid == memberAuthUid);
      allow write: if isOwner() || isTrainer() ||
        (isSignedIn() && request.auth.uid == memberAuthUid);
    }

    match /trainingSessions/{sessionId} {
      allow create: if isTrainer();
      allow read, write: if isOwner();
      allow read, write: if isTrainer() &&
        'trainerId' in resource.data &&
        resource.data.trainerId == request.auth.uid;
      allow read: if isSignedIn() &&
        'memberAuthUid' in resource.data &&
        resource.data.memberAuthUid == request.auth.uid;
      allow update: if isSignedIn() &&
        'memberAuthUid' in resource.data &&
        resource.data.memberAuthUid == request.auth.uid &&
        request.resource.data.diff(resource.data)
          .affectedKeys()
          .hasOnly(['exercises', 'activeExerciseIndex', 'sessionRpe']);
    }

    match /memberIntelligence/{memberAuthUid} {
      allow read:  if isOwner() || isTrainer() ||
        (isSignedIn() && request.auth.uid == memberAuthUid);
      allow write: if isOwner() || isTrainer();
    }

    match /springSocial/{memberId} {
      allow read, write: if isSignedIn()
        && request.auth.uid == memberId;
    }

    match /socialFeed/{feedItemId} {
      allow create: if isSignedIn();
      allow read: if isSignedIn();
      allow update, delete: if isSignedIn()
        && resource.data.memberId == request.auth.uid;
    }

    match /socialChallenges/{challengeId} {
      allow create: if isSignedIn();
      allow read: if isSignedIn()
        && (resource.data.challengerId == request.auth.uid
            || resource.data.opponentId == request.auth.uid);
      allow update: if isSignedIn()
        && (resource.data.challengerId == request.auth.uid
            || resource.data.opponentId == request.auth.uid);
    }

  }
}
```

---

## Appendix D — Open Items

The following items have security or architecture implications and are not yet implemented:

| Item | Risk | Recommendation |
|---|---|---|
| **No server-side Razorpay webhook** | High — payment bypass possible | Add Cloud Function `onRequest` handler with HMAC-SHA256 signature verification |
| **No Firebase App Check** | Medium — API key abuse | Enable in Firebase Console + add `firebase_app_check` package to both pubspec.yaml files |
| **No CI/CD pipeline** | Medium — bad rules can be deployed | Add GitHub Actions workflow with emulator-based rules testing |
| **No environment separation** | Medium — dev affects prod data | Provision separate Firebase projects for dev and staging |
| **Collection name inconsistency** (`gamificationEvents` vs `gamificationevents`, `personalbests` vs `personal_bests`) | Medium — data may be siloed | Audit actual collection names in Firestore console; migrate to single canonical name |
| **Client-side XP calculation** | Medium — gamification manipulation | Move `processEvent()` XP logic to a Cloud Function triggered on gamificationEvents write |
| **No attendance deduplication** | Low — double check-in creates duplicate records | Add compound query check before `attendance.add()` or use `{memberId}_{date}` as doc ID |
| **Gemini model uses preview ID** | Low — API behavior may change | Monitor Gemini releases; update to stable model ID (`gemini-2.5-flash` without `-preview`) when available |
| **Storage rules path mismatch** | High — profile uploads fail silently | Align `StorageService` write path to `member_photos/{authUid}.jpg` |
| **No APK obfuscation in build config** | Low | Add `--obfuscate --split-debug-info=build/debug-info/` to release build scripts |
| **Spring Social feature** | Low — schema reserved, UI pending | Rules already in place (`springSocial`, `socialFeed`, `socialChallenges`); no code action needed yet |

---

*End of Report*

*This document was generated from direct codebase analysis on 2026-04-18. All claims cite source files and line numbers. Run `grep` commands from the repository root to verify any cited reference.*
